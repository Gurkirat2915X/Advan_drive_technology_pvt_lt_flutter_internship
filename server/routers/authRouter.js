import express from "express";
import { authenticate, register } from "../auth/auth.js";

const authRouter = express.Router();

authRouter.get("/health", (req, res) => {
  res.status(200).json({ message: "OK" });
});

authRouter.post("/login", async (req, res) => {
  const { username, password } = req.body;

  const data = await authenticate(username, password);
  console.log(data);

  if (data) {
    res.cookie("token", data.token, { httpOnly: true });
    res.status(200).json({
      message: "Login successful",
      user: {
        id: data.user._id,
        username: data.user.username,
        role: data.user.role,
        itemTypes: data.user.itemTypes,
      },
      token: data.token,
    });
  } else {
    res.status(401).json({ message: "Invalid credentials" });
  }
});

authRouter.post("/register", (req, res) => {
  const { username, password, role } = req.body;
  try {
    const data = register(username, password, role);
    res.status(201).json({
      message: "User registered successfully",
      user: data.user,
      token: data.token,
    });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

export default authRouter;
