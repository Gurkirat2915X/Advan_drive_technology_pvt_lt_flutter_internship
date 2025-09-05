import User from "../models/user.js";
import jwt from "jsonwebtoken";

export const authMiddleware = async (req, res, next) => {
  const token = req.headers.token || req.cookies.token;
  if (!token) return res.status(401).json({ message: "Unauthorized" });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = await User.findById(decoded.id);
    console.log(req.user);
    next();
  } catch (error) {
    return res.status(401).json({ message: "Unauthorized" });
  }
};
