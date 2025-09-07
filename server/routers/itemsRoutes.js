import express from "express";
import Item, { itemTypes } from "../models/item.js";

const itemsRouter = express.Router();

itemsRouter.get("/types", async (req, res) => {
  res
    .status(200)
    .json({ message: "Fetched item types successfully", itemTypes });
});

export default itemsRouter;
