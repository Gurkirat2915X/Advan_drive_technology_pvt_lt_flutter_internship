import User from "../models/user.js";
import Request from "../models/request.js";
import Item from "../models/item.js";
import dotenv from "dotenv";
import mongoose from "mongoose";
import bcrypt from "bcryptjs";
import ConnectDBWithRetry from "../db/db.js";

dotenv.config();
async function create_users(username, password, role = "end_user") {
  console.log(password);
  const hashed_password = await bcrypt.hash(password, 10);
  if (role == "end_user") {
    const user = new User({ username, hashed_password, role });
    await user.save();
    return true;
  } else {
    const user = new User({ username, hashed_password, role });
    await user.save();
    return true;
  }
}

const clearDatabase = async () => {
  try {
    await User.deleteMany({});
    await Item.deleteMany({});
    await Request.deleteMany({});
    console.log("🗑️ Cleared existing data");
  } catch (error) {
    console.error("❌ Error clearing database:", error);
  }
};

console.log("Demo Creation Script");
console.log("Environment Variables Loaded:");
console.log("CleanUp of the db");
await ConnectDBWithRetry();
await clearDatabase();
console.log("Create Receivers");
console.log("password:", process.env.DEFAULT_PASSWORD);
for (const receiver of process.env.RECEIVERS.split(" ")) {
  await create_users(receiver, process.env.DEFAULT_PASSWORD, "receiver");
  console.log(`Created Receiver: ${receiver}`);
}

console.log("Create End Users");
for (const endUser of process.env.END_USERS.split(" ")) {
  await create_users(endUser, process.env.DEFAULT_PASSWORD);
  console.log(`Created End User: ${endUser}`);
}

mongoose.connection.close();
