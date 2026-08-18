import { model, Schema, Types } from "mongoose";
import { v4 as uuidv4 } from "uuid";

const clientSchema = new Schema(
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
    },
    ccp: { type: String },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true }, // Hashed Password
    phoneNumber: { type: String, required: true },
    willaya: { type: String, required: true },
    dateOfBirth: { type: String, required: true },
    interests: [{ type: String, required: true }],
    jobTitle: { type: String },
    bio: { type: String },
    description: { type: String },
    role: {
      type: String,
      enum: ["client", "freelancer"],
      default: "client",
    },

    rating: { type: String, ref: "ClientRating" },
    fav: [{ type: String, ref: "Job" }],
    jobs: [{ type: String, ref: "Job" }],
    jobsArchive: [{ type: String, ref: "JobArchive" }],
    jobsProgress: [{ type: String, ref: "JobProgress" }],
    recommendations: [
      {
        interest: String,
        weight: Number,
        modified: Date,
      },
    ],
    isVerified: { type: Boolean, default: true },
    uniqueString: { type: String },
    moneySpent: { type: Number, default: 0 },
    banned: { type: Boolean, default: false },
  },
  { timestamps: true }
);

const client = model("Client", clientSchema);

export { client };
