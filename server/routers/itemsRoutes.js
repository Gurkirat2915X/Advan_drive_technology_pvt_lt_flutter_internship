import express from "express";
import Item, {itemTypes} from "../models/item.js";

const itemsRouter = express.Router();

itemsRouter.get("/health", (req, res) => {
  res.status(200).json({ message: "OK" });
});

itemsRouter.get("/all", async (req, res) => {
  try {
    const items = await Item.find();
    res.status(200).json({ message: "Fetched all items successfully", items });
  } catch (error) {
    res.status(500).json({ message: "Failed to fetch items", error: error.message });
  }
});

itemsRouter.post("/add", async (req, res) => {
  const { name, description,  } = req.body;
  try {
    const newItem = new Item({ name, description, price });
    await newItem.save();
    res.status(201).json({ message: "Item added successfully", item: newItem });
  } catch (error) {
    res.status(400).json({ message: "Failed to add item", error: error.message });
  }
});

itemsRouter.get("/types", async (req, res) => {
  res.status(200).json({ message: "Fetched item types successfully", itemTypes });
});

export default itemsRouter;
