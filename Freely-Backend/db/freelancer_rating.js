import { model, Schema, Types } from "mongoose";
import { v4 as uuidv4 } from "uuid";

const FreelancerRatingSchema = new Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4().replace(/\-/g, ""),
    },

    score: { type: Number, min: 0, max: 5, required: true },
    comments: [{ type: String, ref: "Comment" }],
    freelancer: { type: String, ref: "Freelancer" },
    stars: [{ type: Number, default: 0 }],
  },
  { timestamps: true }
);

const freelancerRating = model("FreelancerRating", FreelancerRatingSchema);

export { freelancerRating };
