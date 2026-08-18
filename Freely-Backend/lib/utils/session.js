import jwt from "jsonwebtoken";

const getToken = (token) => {
  return new Promise((resolve, reject) => {
    if (!token) {
      return resolve(null);
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
      if (err) {
        return reject("Unauthorized");
      }
      resolve(decoded);
    });
  });
};

export default getToken;
