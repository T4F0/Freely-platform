import makeValidation from "@withvoid/make-validation";
import chatRoomModel from "../mongoDB/models/chatRoom.js";
import chatMessageModel, { MESSAGE_TYPES } from "../mongoDB/models/message.js";
import userModel from "../mongoDB/models/user.js";
import chatRoom from "../mongoDB/models/chatRoom.js";
export default {
  initiate: async (req, res) => {
    try {
      const valid = makeValidation((types) => ({
        payload: req.body,
        checks: {
          userIds: {
            type: types.array,
            options: { unique: true, empty: false, stringOnly: true },
          },
        },
      }));
      if (!valid.success) return res.status(400).json({ ...valid });

      const { userIds } = req.body;
      const chatInitiator = userIds[0];
      const allUserIds = [...userIds, chatInitiator];
      const chatRoom = await chatRoomModel.initiateChat(
        allUserIds,
        chatInitiator
      );
      return res.status(200).json({ success: true, chatRoom });
    } catch (err) {
      return res.status(500).json({ success: false, error: err });
    }
  },
  postMessage: async (req, res) => {
    try {
      console.log("sad");
      const { roomId } = req.params;
      const validation = makeValidation((types) => ({
        payload: req.body,
        checks: {
          senderId: { type: types.string },
          type: { type: types.enum, options: { enum: MESSAGE_TYPES } },
        },
      }));
      if (!validation.success) return res.status(400).json({ ...validation });
      const messagePayload = req.body.message;
      const type = req.body.type;
      const senderId = req.body.senderId;

      const post = await chatMessageModel.createPostInChatRoom(
        roomId,
        messagePayload,
        senderId,
        type
      );
      await chatRoomModel.findOneAndUpdate(
        { _id: roomId },
        { $inc: { notifications: 1 } }
      );
      global.io.to(roomId).emit("new message", { message: post });

      // get the other user FCMToken
      const room = await chatRoomModel.getChatRoomByRoomId(roomId);
      const otherUser = room.userIds.find((id) => id !== senderId);
      const user = await userModel.findOne({ _id: otherUser });
      if (user.FCMToken) {
        const message = {
          notification: {
            title: "New Message",
            body: post,
          },
          token: user.FCMToken,
        };
      }
      return res.status(200).json({ success: true, post });
    } catch (error) {
      return res.status(500).json({ success: false, error: error });
    }
  },
  getConversationByRoomId: async (req, res) => {
    try {
      const { roomId } = req.params;
      console.log(roomId);
      const room = await chatRoomModel.getChatRoomByRoomId(roomId);
      if (!room) {
        return res.status(400).json({
          success: false,
          message: "No room exists for this id",
        });
      }
      const users = await userModel.getUserByIds([
        room.userIds[0],
        room.userIds[1],
      ]);
      const options = {
        page: parseInt(req.query.page) || 0,
        limit: parseInt(req.query.limit) || 30,
      };
      console.log(options);
      const conversation = await chatMessageModel.getConversationByRoomId(
        roomId,
        options
      );
      return res.status(200).json({
        success: true,
        conversation,
        users,
      });
    } catch (error) {
      return res.status(500).json({ success: false, error });
    }
  },
  markConversationReadByRoomId: async (req, res) => {
    try {
      const { roomId } = req.params;
      const room = await chatRoomModel.getChatRoomByRoomId(roomId);
      if (!room) {
        return res.status(400).json({
          success: false,
          message: "No room exists for this id",
        });
      }

      const readerId = req.body.readerId;
      const result = await chatMessageModel.markMessageRead(roomId, readerId);
      await chatRoomModel.findOneAndUpdate(
        { _id: roomId },
        { notifications: 0 }
      );
      global.io.to(roomId).emit("read");
      return res.status(200).json({ success: true, data: result });
    } catch (error) {
      console.log(error);
      return res.status(500).json({ success: false, error });
    }
  },
  getAllConversationsByUserId: async (req, res) => {
    try {
      const { userId } = req.params;
      const convos = await chatRoomModel.getChatRoomsByUserId(userId);
      console.log(convos);
      return res.status(200).json({ success: true, conversations: convos });
    } catch (err) {
      return res.status(500).json({ success: false, error: err });
    }
  },
};
