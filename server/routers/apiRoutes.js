import express from "express";
import authRouter from "./authRouter.js";
import itemsRouter from "./itemsRoutes.js";
import requestRouter from "./requestRoutes.js";
import { authMiddleware } from "../middleware/authMiddleware.js";
import User from "../models/user.js";
import reassignmentRouter from "./reassignmentRoutes.js";

const apiRouter = express.Router();

apiRouter.get("/health", (req, res) => {
  res.json({ status: "healthy" });
});

apiRouter.use("/auth", authRouter);
apiRouter.use("/item", authMiddleware, itemsRouter);
apiRouter.use("/request", authMiddleware, requestRouter);
apiRouter.use("/reassignment", authMiddleware, reassignmentRouter);
apiRouter.get("/verifyToken", authMiddleware, (req, res) => {
  res.status(200).json({ message: "Token is valid" });
});

apiRouter.get("/receivers", authMiddleware, async (req, res) => {
  const receivers = await User.find({ role: "receiver" }).select(
    "username _id"
  );
  res.json(receivers);
});

export default apiRouter;
