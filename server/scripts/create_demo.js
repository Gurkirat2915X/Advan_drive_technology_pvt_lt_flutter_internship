import User from "../models/user.js";
import Request from "../models/request.js";
import Item from "../models/item.js";
import dotenv from "dotenv";
import mongoose from "mongoose";
import bcrypt from "bcryptjs";
import ConnectDBWithRetry from "../db/db.js";

dotenv.config();
async function create_users(username,password,role="end_user") {
  // implement user creation logic here
  console.log(password)
  const hashed_password = await bcrypt.hash(password, 10);
  if(role=="end_user"){
    const user = new User({ username, hashed_password, role });
    await user.save();
    return true;

  }else{
    const user = new User({ username, hashed_password, role});
    await user.save();
    return true;
  }

}



// Clear existing data
const clearDatabase = async () => {
    try {
        await User.deleteMany({});
        await Item.deleteMany({});
        await Request.deleteMany({});
        console.log('🗑️ Cleared existing data');
    } catch (error) {
        console.error('❌ Error clearing database:', error);
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

console.log("Creating the some of the requests")
const users = await User.find({ role: 'end_user' });
const receivers = await User.find({ role: 'receiver' });
const item = await Item.create({ name: 'Sample Item', type:"other",status:"fulfilled",quantity:100 });
const item2 = await Item.create({ name: 'Sample Item 2', type:"other",status:"pending",quantity:50 });
const request = new Request({
  name: "Sample Request 1",
  user: users[0]._id,
  receiver: receivers[0]._id,
  items: [item._id, item2._id],
  status: "pending"
});

const request2 = new Request({
  name: "Sample Request 2",
  user: users[1]._id,
  receiver: receivers[1]._id,
  items: [item2._id],
    status: "pending"
});

await request.save();
await request2.save();

mongoose.connection.close();