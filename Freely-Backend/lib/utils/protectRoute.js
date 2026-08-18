import { GraphQLError } from "graphql";

const authenticate = (serverid, user) => {
  if (user?.banned) {
    throw new GraphQLError("MCHI_9WED", {
      extensions: {
        code: "BANNED_USER",
        http: { status: 403 },
      },
    });
  }
  if (serverid !== user?.id )
    throw new GraphQLError("Not Authorized", {
      extensions: {
        code: "UNAUTHENTICATED",
        http: { status: 401 },
      },
    });
};

export default authenticate;
