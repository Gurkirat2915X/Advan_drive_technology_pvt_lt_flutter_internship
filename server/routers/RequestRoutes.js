import express from "express";
import mongoose from "mongoose";
import Request from "../models/request.js";
import Item from "../models/item.js";
import User from "../models/user.js";
import { updateAll } from "../index.js";
const requestRouter = express.Router();

function calculateRequestStatus(items) {
  if (!items || items.length === 0) {
    return "pending";
  }

  const itemStatuses = items.map((item) => item.status);
  const fulfilledCount = itemStatuses.filter(
    (status) => status === "fulfilled"
  ).length;
  const totalCount = itemStatuses.length;

  if (fulfilledCount === totalCount) {
    return "approved";
  } else if (fulfilledCount > 0) {
    return "partially_fulfilled";
  } else {
    return "pending";
  }
}

async function handleItemReassignment(
  itemId,
  newReceiverId,
  originalRequestId,
  currentUserId,
  reason = ""
) {
  try {
    await Item.findByIdAndUpdate(itemId, {
      status: "reassigned",
      reassignedTo: newReceiverId,
      notes: reason,
    });

    console.log(
      `Item ${itemId} reassigned from ${currentUserId} to ${newReceiverId}`
    );
    return { success: true, itemId, newReceiverId, reason };
  } catch (error) {
    console.error("Error handling item reassignment:", error);
    throw error;
  }
}

requestRouter.get("/health", (req, res) => {
  res.status(200).json({ message: "OK" });
});

requestRouter.get("/all", async (req, res) => {
  try {
    if (!req.user) {
      return res.status(401).json({ message: "Unauthorized1" });
    }

    let allRequests;
    if (req.user.role == "receiver") {
      const requests = await Request.find({ receiver: req.user._id })
        .populate("items")
        .sort({ createdAt: -1 });

      console.log(
        `Receiver ${req.user._id} found ${requests.length} original requests`
      );
      allRequests = requests;

      console.log(
        `Receiver ${req.user._id} final result: ${allRequests.length} requests`
      );
    } else {
      allRequests = await Request.find({ user: req.user._id })
        .populate("items")
        .sort({ createdAt: -1 });
      console.log(
        `End user ${req.user._id} found ${allRequests.length} requests`
      );
    }

    res.status(200).json({
      message: "Fetched all requests successfully",
      requests: allRequests,
    });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Failed to fetch all requests", error: error.message });
  }
});

requestRouter.post("/add", async (req, res) => {
  const { name, receiver, items } = req.body;
  console.log(req.body);

  if (!req.user) {
    return res.status(401).json({ message: "Unauthorized" });
  }
  if (req.user.role !== "end_user") {
    return res
      .status(403)
      .json({ message: "Forbidden: You are not allowed to create requests" });
  }

  if (!name || typeof name !== "string" || !name.trim()) {
    return res.status(400).json({ message: "Invalid name" });
  }
  if (!receiver || !mongoose.Types.ObjectId.isValid(receiver)) {
    return res.status(400).json({ message: "Invalid receiver" });
  }
  if (!Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ message: "Items must be a non-empty array" });
  }

  try {
    const receiverUser = await User.findById(receiver).select("_id");
    if (!receiverUser) {
      return res.status(404).json({ message: "Receiver not found" });
    }

    const itemIds = await Promise.all(
      items.map(async (item, idx) => {
        if (!item || typeof item !== "object") {
          throw new Error(`Item at index ${idx} is invalid`);
        }
        const { name, type, quantity } = item;
        if (!name || !type || typeof quantity !== "number") {
          throw new Error(
            `Item at index ${idx} missing required fields (name, type, quantity)`
          );
        }
        const created = await Item.create({
          name,
          type,
          status: "pending",
          quantity,
        });
        return created._id;
      })
    );

    const newRequest = await Request.create({
      name,
      receiver: receiverUser._id,
      items: itemIds,
      user: req.user._id,
      status: "pending",
    });
    await newRequest.populate("items");
    updateAll();
    res
      .status(201)
      .json({ message: "Request created successfully", request: newRequest });
  } catch (error) {
    console.error(error);
    res
      .status(400)
      .json({ message: "Failed to create request", error: error.message });
  }
});

requestRouter.post("/update", async (req, res) => {
  try {
    console.log("Update request body:", req.body);

    if (!req.user) {
      return res.status(401).json({ message: "Unauthorized" });
    }

    const { id, name, status, items, receiver, reassignments } = req.body;

    if (!id || !mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: "Invalid request ID" });
    }

    const existingRequest = await Request.findById(id).populate("items");
    if (!existingRequest) {
      return res.status(404).json({ message: "Request not found" });
    }
    if (
      req.user.role === "end_user" &&
      existingRequest.user.toString() !== req.user._id.toString()
    ) {
      return res
        .status(403)
        .json({ message: "Forbidden: You can only update your own requests" });
    }
    if (
      req.user.role === "receiver" &&
      existingRequest.receiver.toString() !== req.user._id.toString()
    ) {
      return res.status(403).json({
        message: "Forbidden: You can only update requests assigned to you",
      });
    }
    if (items && Array.isArray(items)) {
      for (const itemData of items) {
        if (itemData.id && mongoose.Types.ObjectId.isValid(itemData.id)) {
          const currentItem = existingRequest.items.find(
            (item) => item._id.toString() === itemData.id
          );

          if (currentItem) {
            if (itemData.status === "reassigned" && itemData.reassignedTo) {
              const newReceiver = await User.findById(itemData.reassignedTo);
              if (!newReceiver || newReceiver.role !== "receiver") {
                return res.status(400).json({
                  message: `Invalid receiver for item reassignment: ${itemData.id}`,
                });
              }
              await handleItemReassignment(
                itemData.id,
                itemData.reassignedTo,
                existingRequest._id,
                req.user._id,
                itemData.reassignmentReason || ""
              );
            } else {
              await Item.findByIdAndUpdate(itemData.id, {
                name: itemData.name || currentItem.name,
                type: itemData.type || currentItem.type,
                quantity: itemData.quantity || currentItem.quantity,
                status: itemData.status || currentItem.status,
              });
            }
          }
        } else if (itemData.name && itemData.type && itemData.quantity) {
          const newItem = await Item.create({
            name: itemData.name,
            type: itemData.type,
            quantity: itemData.quantity,
            status: itemData.status || "pending",
          });
          existingRequest.items.push(newItem._id);
        }
      }
    }

    const updatedRequest = await Request.findById(id).populate("items");
    const newRequestStatus = calculateRequestStatus(updatedRequest.items);

    const updateData = {
      status: newRequestStatus,
    };

    if (name) updateData.name = name;
    if (receiver && mongoose.Types.ObjectId.isValid(receiver)) {
      updateData.receiver = receiver;
    }

    const finalUpdatedRequest = await Request.findByIdAndUpdate(
      id,
      updateData,
      { new: true }
    ).populate("items");

    console.log(`Request ${id} status updated to: ${newRequestStatus}`);

    updateAll();

    res.status(200).json({
      message: "Request updated successfully",
      request: finalUpdatedRequest,
      calculatedStatus: newRequestStatus,
    });
  } catch (error) {
    console.error("Update request error:", error);
    res.status(500).json({
      message: "Failed to update request",
      error: error.message,
    });
  }
});

export default requestRouter;
