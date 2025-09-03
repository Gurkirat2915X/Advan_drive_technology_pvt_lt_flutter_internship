import User from "../models/user.js";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

export const authenticate = async (username, password) => {
  const user = await User.findOne({ username });
  if (!user) return null;
  

  const isMatch = await bcrypt.compare(password, user.hashed_password);
  if (!isMatch) return null;

  const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
    expiresIn: "10d",
  });
  return { user, token };
};
export const register = async (username, password, role) => {
  if (await User.findOne({ username })) {
    throw new Error("User already exists");
  }
  const hashedPassword = await bcrypt.hash(password, 10);
  const user = new User({ username, password: hashedPassword, role });
  await user.save();
  const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
    expiresIn: "10d",
  });
  return { user, token };
};