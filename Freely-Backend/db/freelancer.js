import { model, Schema, Types } from "mongoose";
import { v4 as uuidv4 } from "uuid";

const freelancerSchema = new Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4().replace(/\-/g, ""),
    },

    firstName: { type: String, required: true },
    lastName: { type: String, required: true },
    photo: {
      type: String,
      default:
        "https://e7.pngegg.com/pngimages/171/655/png-clipart-tarek-hamed-2018-world-cup-egypt-national-football-team-liga-mx-club-tijuana-hector-herrera-tshirt-photography-thumbnail.png",
    }, //URL
    email: { type: String, required: true },
    password: { type: String, required: true }, // Hashed Password
    willaya: { type: String, required: true },
    dateOfBirth: { type: String, required: true },
    phoneNumber: { type: String, required: true },
    skills: [String],
    jobTitle: { type: String },
    bio: { type: String },
    description: { type: String },
    role: {
      type: String,
      enum: ["client", "freelancer"],
      default: "freelancer",
    },
    jobs: [{ type: String, ref: "Job" }],
    jobsArchive: [{ type: String, ref: "JobArchive" }],
    jobsProgress: [{ type: String, ref: "JobProgress" }],
    requests: [{ type: String, ref: "JobRequest" }],
    rating: { type: String, ref: "FreelancerRating" },
    recommendations: [
      {
        interest: String,
        weight: Number,
        modified: Date,
      },
    ],
    ccp: { type: String, required: true },
    isVerified: { type: Boolean, default: false },
    uniqueString: { type: String },
    moneyMade: { type: Number, default: 0 },
    banned: { type: Boolean, default: false },
  },
  { timestamps: true }
);

const freelancer = model("Freelancer", freelancerSchema);
export { freelancer };
