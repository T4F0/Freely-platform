import chatRoomModel from "../mongoDB/models/chatRoom.js";
import chatMessageModel from "../mongoDB/models/message.js";
export default {
  deleteRoomById: async (req, res) => {
    const { roomId } = req.params;
    try {
      let result = await chatRoomModel.deleteOne({ _id: roomId });
      result = await chatMessageModel.deleteMany({ chatRoomId: roomId });
      return res.status(200).json({
        success: true,
        message: "Deleted " + result.deletedCount + " messages",
      });
    } catch (err) {
      return res.status(500).json({
        success: false,
        error: err,
      });
    }
  },
  deleteMessageById: async (req, res) => {
    const { messageId } = req.params;
    try {
      const result = await chatMessageModel.deleteOne({ _id: messageId });
      res.status(200).json({success : true , message : `Message ${messageId} deleted successfully` })
    } catch (error) {
      return res.status(500).json({ success: false, error });
    }
  },
};
