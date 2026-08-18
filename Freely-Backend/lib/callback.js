import { jobResolvers } from "./resolvers/jobs.js";
import { requestResolvers } from "./resolvers/request.js";
import { userResolvers } from "./resolvers/user.js";
import { feedResolvers } from "./resolvers/feed.js";
import { reviewResolvers } from "./resolvers/review.js";
import { reportResolvers } from "./resolvers/report.js";
import { adminResolvers } from "./resolvers/admin.js";

export const resolvers = [
  userResolvers,
  requestResolvers,
  jobResolvers,
  feedResolvers,
  reviewResolvers,
  reportResolvers,
  adminResolvers,
];
