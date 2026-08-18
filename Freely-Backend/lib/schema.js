import { jobGQLSchema } from "./types/jobs.js";
import { userGQLSchema } from "./types/user.js";
import { feedGQLSchema } from "./types/feed.js";
import { requestGQLSchema } from "./types/request.js";
import { mergeTypeDefs } from "@graphql-tools/merge";
import { reviewGQLSchema } from "./types/review.js";
import { reportGQLSchema } from "./types/report.js";
import { adminGQLSchema } from "./types/admin.js";

export const mergedGQLSchema = mergeTypeDefs([
  userGQLSchema,
  jobGQLSchema,
  requestGQLSchema,
  feedGQLSchema,
  reviewGQLSchema,
  reportGQLSchema,
  adminGQLSchema,
]);
