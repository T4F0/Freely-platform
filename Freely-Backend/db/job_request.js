import { model, Schema, Types } from "mongoose";
import { v4 as uuidv4 } from "uuid";

const jobRequestSchema = new Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4().replace(/\-/g, ""),
    },

    description: { type: String, required: true },
    deadline: { type: String, required: true },
    attachments: [
      {
        link: String,
        kind: String,
      },
    ],
    price: { type: Number, default: true },
    freelancer: { type: String, ref: "Freelancer" },
    job: { type: String, ref: "Job" },
  },
  { timestamps: true }
);

const jobRequest = model("JobRequest", jobRequestSchema);

export { jobRequest };

// freelancer post request
// client get request

// get proposals for client to choose
