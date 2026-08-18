import { model, Schema, Types } from "mongoose";
import { v4 as uuidv4 } from "uuid";

const freelancerCommentSchema = new Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4().replace(/\-/g, ""),
    },
    score: Number,
    comment: { type: String },
    freelancer: {
      type: String,
      ref: "Freelancer",
    },
    job: String,
  },
  { timestamps: true }
);

const freelancerComment = model("FreelancerComment", freelancerCommentSchema);

export { freelancerComment };
