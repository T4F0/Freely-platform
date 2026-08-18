import { freelancer } from "../../db/freelancer.js";
import { client } from "../../db/client.js";

const checkExist = async (email) => {
  try {
    const existingFreelancer = await freelancer.findOne({ email });
    const existingClient = await client.findOne({ email });
    console.log(existingClient);
    console.log(existingFreelancer);
    return !!existingClient || !!existingFreelancer;
  } catch (error) {
    throw new GraphQLError("ERROR_CHECKING_EMAIL", {
      extensions: {
        code: "ERROR_CHECKING_EMAIL",
        http: { status: 400 },
      },
    });
  }
};

export default checkExist;
