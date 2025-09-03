import mongoose from "mongoose";

const requestSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User_",
    required: true,
  },
  status: {
    type: String,
    enum: ["pending", "approved", "partially_fulfilled"],
    default: "pending",
  },
  items: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Item",
      required: true,
    },
  ],
  receiver: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User_",
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

const Request = mongoose.model("Request", requestSchema);

export default Request;
