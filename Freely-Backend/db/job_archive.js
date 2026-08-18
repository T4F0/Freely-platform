import { model, Schema, Types } from "mongoose";
import { v4 as uuidv4 } from "uuid";

const JobArchiveSchema = new Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4().replace(/\-/g, ""),
    },

    title: { type: String, required: true },
    description: { type: String, required: true },
    attachments: [
      {
        link: String,
        kind: String,
      },
    ],
    tags: [{ type: String, required: true }],

    price: { type: Number, required: true },
    client: { type: String, ref: "Client" },
    freelancer: { type: String, ref: "Freelancer", required: true },
    files: [
      {
        link: String,
        kind: String,
      },
    ],
    requests: [{ type: String, ref: "applyRequest" }],
    job_size: { type: String, enum: ["Small", "Medium", "Large"] },
    expertize_level: {
      type: String,
      enum: ["Entry", "Intermediate", "Expert"],
    },
    payment_structure: { type: String, enum: ["By_Project", "By_Milestone"] },
    deadline: { type: String },
    publishedAt: { type: String },
    clientReview: { type: Boolean, default: false },
    freelancerReview: { type: Boolean, default: false },
  },
  { timestamps: true }
);

const jobArchive = model("JobArchive", JobArchiveSchema);

export { jobArchive };
