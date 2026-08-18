import { model, Schema, Types } from "mongoose";
import { v4 as uuidv4 } from "uuid";

const clientCommentSchema = new Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4().replace(/\-/g, ""),
    },
    score: Number,
    comment: { type: String },
    client: {
      type: String,
      ref: "Client",
    },
    job: String,
  },
  { timestamps: true }
);

const clientComment = model("ClientComment", clientCommentSchema);

export { clientComment };
