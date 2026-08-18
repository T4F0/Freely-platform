import http from "http";
import express from "express";
import * as dotenv from "dotenv";

import logger from "morgan";
import cors from "cors";
// routes

import indexRouter from "./routes/index.js";
import userRouter from "./routes/user.js";
import chatRoomRouter from "./routes/chatRoom.js";
import deleteRouter from "./routes/delete.js";
// middlewares

import { decode } from "./middlewares/jwt.js";

//DB
import connectDB from "./mongoDB/connect.js";

//ws
import ws from "./lib/ws.js";
import { Server } from "socket.io";
import user from "./controllers/user.js";
import UserModel from "./mongoDB/models/user.js";

dotenv.config();
const app = express();

const port = process.env.PORT || "3000";
app.set("port", port);

app.use(cors());
app.use(logger("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

app.use("/", indexRouter);
app.use("/users", userRouter);
app.use("/room", decode, chatRoomRouter);
app.use("/delete", decode, deleteRouter);

app.use("*", (req, res) => {
  return res.status(404).json({
    success: false,
    message: "API endpoint doesnt exist",
  });
});



const server = http.createServer(app);
global.io = new Server(server, { cors: { origin: "*" } });
global.io.on("connection", (socket) => {
  console.log("connected");
  ws.connection(socket);
});
server.listen(port);
server.on("listening", () => {
  try {
    connectDB(process.env.MONGODB_URL);
    console.log(`Listening on port:: http://localhost:${port}/`);
  } catch (err) {
    console.log(err);
  }
});
