import mongoose from "mongoose";

const CONNECTION_OPTIONS = {
  maxPoolSize: 10,
  serverSelectionTimeoutMS: 5000,
  socketTimeoutMS: 45000,
  family: 4,
};

const MAX_RETRIES = 3;
const RETRY_INTERVAL = 5000; 

async function ConnectDBWithRetry(retryCount = 0) {
  try {
    await mongoose.connect(process.env.MONGO_DB_URL, CONNECTION_OPTIONS);
    console.log("✅ Database connected successfully");
    mongoose.connection.on("error", (err) => {
      console.error("❌ MongoDB connection error:", err);
    });

    mongoose.connection.on("disconnected", () => {
      console.warn("⚠️ MongoDB disconnected");
    });

    process.on("SIGINT", async () => {
      await mongoose.connection.close();
      console.log("MongoDB connection closed through app termination");
      process.exit(0);
    });
  } catch (err) {
    console.error(
      `❌ Database connection attempt ${retryCount + 1} failed:`,
      err.message
    );

    if (retryCount < MAX_RETRIES) {
      console.log(`Retrying connection in ${RETRY_INTERVAL / 1000} seconds...`);
      await new Promise((resolve) => setTimeout(resolve, RETRY_INTERVAL));
      return ConnectDBWithRetry(retryCount + 1);
    }

    console.error("❌ Max retries reached. Could not connect to database.");
    process.exit(1);
  }
}

export default ConnectDBWithRetry;
