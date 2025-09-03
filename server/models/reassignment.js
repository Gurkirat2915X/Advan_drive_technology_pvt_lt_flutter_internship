import mongoose from "mongoose";
import Request from "./request.js";

const reassignmentSchema = new mongoose.Schema({
    request: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Request",
        required: true
    },
    reassignedFrom: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    reassignedTo: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    reassignedAt: {
        type: Date,
        default: Date.now
    }
});

const Reassignment = mongoose.model("Reassignment", reassignmentSchema);

export default Reassignment;