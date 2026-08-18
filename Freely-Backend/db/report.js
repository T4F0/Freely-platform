import { model, Schema, Types } from "mongoose";
import { v4 as uuidv4 } from "uuid";

const reportSchema = new Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4().replace(/\-/g, ""),
    },

    type: { type: String, required: true, enum: ["FC", "CF"] },
    description: { type: String, required: true },
    freelancer: { type: String, ref: "Freelancer" },
    client: { type: String, ref: "Client" },
    status: {
      type: String,
      default: "pending",
      enum: ["pending", "approved", "rejected"],
    },
    job: { type: String, ref: "Job", default: null },
  },
  { timestamps: true }
);

const report = model("Report", reportSchema);

export { report };
