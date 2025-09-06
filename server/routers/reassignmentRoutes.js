import { updateAll } from "../index.js";
import Item from "../models/item.js";
import Request from "../models/request.js";
import express from "express";

const reassignmentRouter = express.Router();


reassignmentRouter.get("/all", async (req, res) => {
    try {
        if (!req.user) {
            return res.status(401).json({ message: "Unauthorized" });
        }

        // Find all items that are reassigned to the current user
        const reassignedItems = await Item.find({ 
            reassignedTo: req.user._id,
            status: 'reassigned'
        });
        const itemIds = reassignedItems.map(item => item._id);
        const requests = await Request.find({ 
            items: { $in: itemIds } 
        }).populate({
            path: 'items',
            match: { _id: { $in: itemIds } }
        }).populate('user', 'username').populate('receiver', 'username');

        // Create simplified response with item data
        const reassignedItemsWithContext = [];
        
        for (const request of requests) {
            for (const item of request.items) {
                if (item.reassignedTo && item.reassignedTo.toString() === req.user._id.toString()) {
                    reassignedItemsWithContext.push({
                        _id: item._id,
                        name: item.name,
                        type: item.type,
                        quantity: item.quantity,
                        status: item.status,
                        reassignedTo: item.reassignedTo,
                        notes: item.notes,
                        requestName: request.name,
                        requestId: request._id,
                        originalReceiver: request.receiver?.username || 'Unknown'
                    });
                }
            }
        }

        res.status(200).json(reassignedItemsWithContext);
    } catch (error) {
        console.error('Error fetching reassigned items:', error);
        res.status(500).json({ 
            message: "Failed to fetch reassigned items", 
            error: error.message 
        });
    }
});

reassignmentRouter.post("/accept/:itemId", async (req, res) => {
    try {
        if (!req.user) {
            return res.status(401).json({ message: "Unauthorized" });
        }

        const { itemId } = req.params;

        // Verify the item is reassigned to the current user
        const item = await Item.findById(itemId);
        if (!item) {
            return res.status(404).json({ message: "Item not found" });
        }

        if (!item.reassignedTo || item.reassignedTo.toString() !== req.user._id.toString()) {
            return res.status(403).json({ message: "This item is not reassigned to you" });
        }

        // Update item: mark as fulfilled and remove reassignment
        await Item.findByIdAndUpdate(itemId, {
            status: 'fulfilled',
            reassignedTo: null,
            notes: ''
        });

        // Calculate and update request status
        const request = await Request.findOne({ items: itemId }).populate('items');
        let updatedRequest = null;
        let originalReceiverId = null;
        if (request) {
            originalReceiverId = request.receiver; // The original receiver who made the reassignment
            const itemStatuses = request.items.map(item => item.status);
            const fulfilledCount = itemStatuses.filter(status => status === 'fulfilled').length;
            const totalCount = itemStatuses.length;
            
            let newRequestStatus;
            if (fulfilledCount === totalCount) {
                newRequestStatus = 'approved';
            } else if (fulfilledCount > 0) {
                newRequestStatus = 'partially_fulfilled';
            } else {
                newRequestStatus = 'pending';
            }
            
            updatedRequest = await Request.findByIdAndUpdate(request._id, { status: newRequestStatus }, { new: true })
                .populate('items')
                .populate('user', 'username')
                .populate('receiver', 'username');
        }
        updateAll(); 

        res.status(200).json({ 
            message: "Reassignment accepted successfully",
            itemId: itemId,
            newStatus: 'fulfilled'
        });
    } catch (error) {
        console.error('Error accepting reassignment:', error);
        res.status(500).json({ 
            message: "Failed to accept reassignment", 
            error: error.message 
        });
    }
});

reassignmentRouter.post("/reject/:itemId", async (req, res) => {
    try {
        if (!req.user) {
            return res.status(401).json({ message: "Unauthorized" });
        }

        const { itemId } = req.params;

        
        const item = await Item.findById(itemId);
        if (!item) {
            return res.status(404).json({ message: "Item not found" });
        }

        if (!item.reassignedTo || item.reassignedTo.toString() !== req.user._id.toString()) {
            return res.status(403).json({ message: "This item is not reassigned to you" });
        }

       updateAll(); 
        await Item.findByIdAndUpdate(itemId, {
            status: 'pending',
            reassignedTo: null,
            notes: ''
        });

        const request = await Request.findOne({ items: itemId }).populate('items');
        let updatedRequest = null;
        let originalReceiverId = null;
        if (request) {
            originalReceiverId = request.receiver; // The original receiver who made the reassignment
            const itemStatuses = request.items.map(item => item.status);
            const fulfilledCount = itemStatuses.filter(status => status === 'fulfilled').length;
            
            let newRequestStatus;
            if (fulfilledCount === itemStatuses.length) {
                newRequestStatus = 'approved';
            } else if (fulfilledCount > 0) {
                newRequestStatus = 'partially_fulfilled';
            } else {
                newRequestStatus = 'pending';
            }
            
            updatedRequest = await Request.findByIdAndUpdate(request._id, { status: newRequestStatus }, { new: true })
                .populate('items')
                .populate('user', 'username')
                .populate('receiver', 'username');
        }
        res.status(200).json({
            message: "Reassignment rejected successfully",
            itemId: itemId,
            newStatus: 'pending'
        });
    } catch (error) {
        console.error('Error rejecting reassignment:', error);
        res.status(500).json({ 
            message: "Failed to reject reassignment", 
            error: error.message 
        });
    }
});

export default reassignmentRouter;