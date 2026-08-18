import jwt from "jsonwebtoken";

const signToken = (id,banned) => {
  const token = jwt.sign(
    { id: id, type: "user", banned },
    process.env.JWT_SECRET,
    {
      expiresIn: "30d",
    }
  );
  return token;
};

export default signToken;
