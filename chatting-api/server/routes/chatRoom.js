import express from "express";

import chatRoom from "../controllers/chatRoom.js";

const router = express.Router();

router
  .get("/user/:userId", chatRoom.getAllConversationsByUserId)
  .get("/:roomId", chatRoom.getConversationByRoomId)
  .post("/initiate", chatRoom.initiate)
  .post("/:roomId/message", chatRoom.postMessage)
  .put("/:roomId/mark-read", chatRoom.markConversationReadByRoomId);
export default router;
