import express from "express";
import dotenv from "dotenv";
import { Server } from "socket.io";
import { createServer } from "http";
import ConnectDBWithRetry from "./db/db.js";
import apiRouter from "./routers/apiRoutes.js";
import cookieParser from "cookie-parser";
dotenv.config();

const app = express();
const server = createServer(app);
const io = new Server(
  server, {
    cors: {
      origin: "*"
    }
  }
)
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

io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  // Handle custom events
  socket.on('message', (data) => {
    console.log('Message received:', data);
    // Broadcast to all clients
    io.emit('message', data);
  });

  socket.on('join_room', (room) => {
    socket.join(room);
    console.log(`User ${socket.id} joined room: ${room}`);
  });

  socket.on('room_message', (data) => {
    // Send message to specific room
    io.to(data.room).emit('room_message', data);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

server.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
