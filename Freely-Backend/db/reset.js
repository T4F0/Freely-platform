import { model, Schema, Types } from "mongoose";
import { v4 as uuidv4 } from "uuid";

const resetTokenSchema = new Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4().replace(/\-/g, ""),
    },
    token: String,
    userid: String,
  },
  { timestamps: true }
);

const resetToken = model("ResetToken", resetTokenSchema);

export { resetToken };
