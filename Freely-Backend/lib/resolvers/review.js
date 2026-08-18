import { job } from "../../db/job.js";
import { freelancer } from "../../db/freelancer.js";
import { client } from "../../db/client.js";
import { GraphQLError } from "graphql";
import authenticate from "../utils/protectRoute.js";
import { clientRating } from "../../db/client_rating.js";
import { freelancerRating } from "../../db/freelancer_rating.js";
import { freelancerComment } from "../../db/freelancer_comment.js";
import { clientComment } from "../../db/client_comment.js";
import { jobArchive } from "../../db/job_archive.js";
import { jobProgress } from "../../db/job_progress.js";

export const reviewResolvers = {
  Query: {},
  Mutation: {
    freelancerReviewClient: async (_, args, { user }) => {
      authenticate(args.reviewer, user);

      try {
        const reviewed = await client.findById(args.reviewed);
        if (!reviewed) {
          throw new GraphQLError("CLIENT_NOT_FOUND", {
            extensions: {
              code: "CLIENT_NOT_FOUND",
              http: { status: 400 },
            },
          });
        }
        const reviewer = await freelancer.findById(args.reviewer);
        if (!reviewer) {
          throw new GraphQLError("FREELANCER_NOT_FOUND", {
            extensions: {
              code: "FREELANCER_NOT_FOUND",
              http: { status: 400 },
            },
          });
        }

        const work = await jobArchive.findById(args.work);
        if (!work) {
          throw new GraphQLError("JOB_NOT_FOUND", {
            extensions: {
              code: "JOB_NOT_FOUND",
              http: { status: 400 },
            },
          });
        }
        work.freelancerReview = true;
        await work.save();
        console.log("freelancer review done ");

        const fComment = {
          freelancer: args.reviewer,
          comment: args.comment,
          score: args.score,
          job: args.work,
        };

        const findComment = await freelancerComment.findOne({
          freelancer: args.reviewer,
          job: args.work,
        });

        if (findComment) {
          throw new GraphQLError("JOB_ALREADY_REVIEWED", {
            extensions: {
              code: "JOB_ALREADY_REVIEWED",
              http: { status: 400 },
            },
          });
        }

        const res = await freelancerComment.create(fComment);

        const review = await clientRating.findOne({ client: args.reviewed });
        review.score =
          (review.score * review.comments.length + args.score) /
          (review.comments.length + 1);
        review.stars[args.score - 1]++;
        review.comments.push(res._id);
        await review.save();
        return true;
      } catch (err) {
        throw new GraphQLError(err.message, {
          extensions: {
            code: "REQUEST_FAILED",
            http: { status: 400 },
          },
        });
      }
    },
    clientReviewFreelancer: async (_, args, { user }) => {
      authenticate(args.reviewer, user);

      try {
        const reviewed = await freelancer.findById(args.reviewed);
        if (!reviewed) {
          throw new GraphQLError("FREELANCER_NOT_FOUND", {
            extensions: {
              code: "FREELANCER_NOT_FOUND",
              http: { status: 400 },
            },
          });
        }
        const reviewer = await client.findById(args.reviewer);
        if (!reviewer) {
          throw new GraphQLError("CLIENT_NOT_FOUND", {
            extensions: {
              code: "CLIENT_NOT_FOUND",
              http: { status: 400 },
            },
          });
        }

        const work = await jobArchive.findById(args.work);
        if (!work) {
          throw new GraphQLError("JOB_NOT_FOUND", {
            extensions: {
              code: "JOB_NOT_FOUND",
              http: { status: 400 },
            },
          });
        }
        work.clientReview = true;

        const change = await work.save();
        console.log(change);
        console.log("client review done ");
        const cComment = {
          client: args.reviewer,
          comment: args.comment,
          score: args.score,
          job: args.work,
        };
        const review = await freelancerRating.findOne({
          freelancer: args.reviewed,
        });
        const findComment = await clientComment.findOne({
          client: args.reviewer,
          job: args.work,
        });

        if (findComment) {
          throw new GraphQLError("JOB_ALREADY_REVIEWED", {
            extensions: {
              code: "JOB_ALREADY_REVIEWED",
              http: { status: 400 },
            },
          });
        }

        const res = await clientComment.create(cComment);

        review.score =
          (review.score * review.comments.length + args.score) /
          (review.comments.length + 1);
        review.stars[args.score - 1]++;
        review.comments.push(res._id);
        await review.save();
        return true;
      } catch (err) {
        throw new GraphQLError(err.message, {
          extensions: {
            code: "REQUEST_FAILED",
            http: { status: 400 },
          },
        });
      }
    },
  },
};
