import mongoose from "mongoose";
import { v4 as uuidv4 } from "uuid";

export const USER_TYPES = {
  FREELANCER: "freelancer",
  CLIENT: "client",
};

const userSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4().replace(/\-/g, ""),
    },
    username: String,
    pfp: String,
    type: String,
    active: { type: Boolean, default: false },
    FCMToken: { type: String, default: "" },
  },
  {
    timestamps: true,
    collection: "users",
  }
);
userSchema.statics.getUserByIds = async function (ids) {
  try {
    const users = await this.find({ _id: { $in: ids } });
    return users;
  } catch (error) {
    throw error;
  }
};
userSchema.statics.setUserOnline = async function (userId) {
  try {
    const user = await this.findOneAndUpdate(
      { _id: userId },
      { active: true },
      { new: true }
    );
    return user;
  } catch (error) {
    throw error;
  }
};
userSchema.statics.setUserOffline = async function (userId) {
  try {
    const user = await this.findOneAndUpdate(
      { _id: userId },
      { active: false },
      { new: true }
    );
    return user;
  } catch (error) {
    throw error;
  }
};
const UserModel = mongoose.model("User", userSchema);
export default UserModel;
