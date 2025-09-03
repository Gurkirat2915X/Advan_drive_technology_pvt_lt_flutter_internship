import express from "express";
import itemsRouter from "./routers/itemsRoutes.js";
import requestRouter from "./routers/RequestRoutes.js";
import authRouter from "./routers/authRouter.js";
import dotenv from "dotenv";
import ConnectDBWithRetry from "./db/db.js";
import apiRouter from "./routers/apiRoutes.js";
import cookieParser from "cookie-parser";
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
try {
    ConnectDBWithRetry();
} catch (error) {
    console.error("Database connection failed:", error);
}

app.use("/api", apiRouter);

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
