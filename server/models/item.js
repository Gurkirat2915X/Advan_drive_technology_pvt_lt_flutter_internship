import mongoose from "mongoose";
export const itemTypes = ["stationary", "electronics", "furniture", "other"];
const itemSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  status: {
    type: String,
    enum: ["pending", "fulfilled", "out_of_stock", "reassigned"],
    default: "pending",
  },
  type: {
    type: String,
    enum: itemTypes,
    default: "other",
  },
  quantity: {
    type: Number,
    required: true,
    min: 0
  }
});

const Item = mongoose.model("Item", itemSchema);

export default Item;
