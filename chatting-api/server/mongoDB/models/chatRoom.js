import mongoose from "mongoose";
import { v4 as uuidv4 } from "uuid";

const chatRoomSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4().replace(/\-/g, ""),
    },
    userIds: Array,
    chatInitiator: String,
    notifications: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
    collection: "chatrooms",
  }
);

chatRoomSchema.statics.initiateChat = async function (userIds, chatInitiator) {
  try {
    const availableRoom = await this.findOne({
      userIds: {
        $size: userIds.length,
        $all: [...userIds],
      },
    });
    console.log(availableRoom);
    if (availableRoom) {
      return {
        isNew: false,
        message: "retrieving an old chat room",
        chatRoomId: availableRoom._doc._id,
      };
    }

    const newRoom = await this.create({ userIds, chatInitiator });
    return {
      isNew: true,
      message: "creating a new chatroom",
      chatRoomId: newRoom._doc._id,
    };
  } catch (error) {
    console.log("error on start chat method", error);
    throw error;
  }
};
chatRoomSchema.statics.getChatRoomByRoomId = async function (roomId) {
  try {
    const room = await this.findOne({ _id: roomId });
    return room;
  } catch (error) {
    throw error;
  }
};

chatRoomSchema.statics.getChatRoomsByUserId = async function (userId) {
  try {
    const convos = await this.aggregate([
      {
        $match: {
          userIds: { $in: [userId] },
        },
      },
      {
        $addFields: {
          userIds: { $slice: ["$userIds", 1, { $size: "$userIds" }] },
        },
      },
      {
        $unwind: "$userIds",
      },
      {
        $lookup: {
          from: "users",
          localField: "userIds",
          foreignField: "_id",
          as: "userDetails",
        },
      },
      {
        $unwind: "$userDetails",
      },
      {
        $lookup: {
          from: "users",
          localField: "chatInitiator",
          foreignField: "_id",
          as: "chatInitiator",
        },
      },
      { $unwind: "$chatInitiator" },
      {
        $lookup: {
          from: "chatmessages",
          let: { chatRoomId: "$_id" },
          pipeline: [
            {
              $match: {
                $expr: {
                  $eq: ["$chatRoomId", "$$chatRoomId"],
                },
              },
            },
            { $sort: { createdAt: -1 } },
            { $limit: 1 },
          ],
          as: "lastMessage",
        },
      },
      {
        $unwind: {
          path: "$lastMessage",
          preserveNullAndEmptyArrays: true,
        },
      },
      {
        $addFields: {
          lastMessageCreatedAt: {
            $cond: {
              if: { $eq: ["$lastMessage", null] },
              then: "$createdAt",
              else: "$lastMessage.createdAt",
            },
          },
        },
      },
      {
        $group: {
          _id: "$_id",
          userIds: { $push: "$userDetails" },
          chatInitiator: { $first: "$chatInitiator" },
          notifications: { $first: "$notifications" },
          lastMessage: { $first: "$lastMessage" },
          createdAt: { $first: "$createdAt" },
          updatedAt: { $first: "$updatedAt" },
          __v: { $first: "$__v" },
          lastMessageCreatedAt: { $first: "$lastMessageCreatedAt" }, // Ensure it's available for sorting
        },
      },
      {
        $sort: { lastMessageCreatedAt: -1 },
      },
      {
        $project: {
          _id: 1,
          userIds: 1,
          chatInitiator: 1,
          notifications: 1,
          lastMessage: 1,
          createdAt: 1,
          updatedAt: 1,
          __v: 1,
        },
      },
    ]);

    return convos;
  } catch (error) {
    console.error("Error in aggregation:", error);
  }
};
export default mongoose.model("ChatRoom", chatRoomSchema);
