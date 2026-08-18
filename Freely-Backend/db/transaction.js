import { model, Schema, Types } from "mongoose";
import { v4 as uuidv4 } from "uuid";

const transactionSchema = new Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4().replace(/\-/g, ""),
    },
    client: String,
    freelancer: String,
    amount: Number,
    job: String,
  },
  { timestamps: true }
);

const transaction = model("Transaction", transactionSchema);

export { transaction };
