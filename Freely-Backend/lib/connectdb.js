import mongoose from "mongoose";
import dotenv from "dotenv";
import colors from "colors";

dotenv.config();

const mongooseConnect = async () => {
  try {
    const connection = await mongoose.connect(process.env.DATABASE_URI);
    console.log(`MongoDB Connected: ${connection.connection.host}`.green.bold);
  } catch (error) {
    console.error(`Error: ${error.message}`.red.bold);
    process.exit(1);
  }
};

export default mongooseConnect;
