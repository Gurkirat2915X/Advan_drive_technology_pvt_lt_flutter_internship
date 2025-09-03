import express from 'express';
import Request from '../models/request.js';

const requestRouter = express.Router();

requestRouter.get("/health", (req, res) => {
    res.status(200).json({ message: "OK" });
});

requestRouter.get("/all", async (req, res) => {
    try {
        const allRequests = req.user.role == "receiver"
            ? await Request.find({ receiver: req.user._id }).populate('items')
            : await Request.find({ user: req.user._id }).populate('items');
        res.status(200).json({ message: "Fetched all requests successfully", requests: allRequests });
    } catch (error) {
        res.status(500).json({ message: "Failed to fetch all requests", error: error.message });
    }
});

export default requestRouter;
