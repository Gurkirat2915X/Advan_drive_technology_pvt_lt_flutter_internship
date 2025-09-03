import mongoose from "mongoose";
import { itemTypes } from "./item.js";

const userSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        unique: true
    },
    hashed_password: {
        type: String,
        required: true
    },
    role: {
        type: String,
        enum: ['end_user', 'receiver'],
        required: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});


const User = mongoose.model("User_", userSchema);

export default User;