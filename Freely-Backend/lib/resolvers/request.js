import { freelancer } from "../../db/freelancer.js";
import { client } from "../../db/client.js";
import { jobRequest } from "../../db/job_request.js";
import authenticate from "../utils/protectRoute.js";
import { GraphQLError } from "graphql";
import { job } from "../../db/job.js";

export const requestResolvers = {
  Query: {
    async getJobRequests(_, args, { user }) {
      authenticate(args.userid, user);
      const cuser = await client.findById(args.userid).exec();
      if (!cuser) {
        throw new GraphQLError("CLIENT_NOT_FOUND", {
          extensions: {
            code: "UNKNOWN_USER",
            http: { status: 400 },
          },
        });
      }

      if (!cuser.jobs || cuser.jobs.length === 0) {
        throw new GraphQLError("No Jobs Found");
      }

      let found = false;

      for (let i = 0; i < cuser.jobs.length; i++) {
        if (cuser.jobs[i] == args.id) {
          found = true;
        }
      }

      if (!found) {
        throw new GraphQLError("Matching Job Not Found");
      }

      const pipeline = [
        {
          $match: { _id: args.id },
        },
        {
          $lookup: {
            from: "jobrequests",
            localField: "_id",
            foreignField: "job",
            as: "requests",
          },
        },
        {
          $unwind: "$requests",
        },
        {
          $lookup: {
            from: "freelancers",
            localField: "requests.freelancer",
            foreignField: "_id",
            as: "requests.freelancerDetails",
          },
        },
        {
          $unwind: "$requests.freelancerDetails",
        },
        {
          $lookup: {
            from: "freelancerratings",
            localField: "requests.freelancerDetails.rating",
            foreignField: "_id",
            as: "requests.freelancerDetails.ratingDetails",
          },
        },
        {
          $unwind: {
            path: "$requests.freelancerDetails.ratingDetails",
            preserveNullAndEmptyArrays: true,
          },
        },
      ];

      const requestsForJob = await job.aggregate(pipeline).exec();

      if (requestsForJob.length == 0) {
        return [];
      }
      let rqs = {
        job: requestsForJob[0].title,
        requests: [],
      };
      for (let job of requestsForJob) {
        const rq = {
          _id: job.requests.freelancerDetails._id,
          firstName: job.requests.freelancerDetails.firstName,
          lastName: job.requests.freelancerDetails.lastName,
          photo: job.requests.freelancerDetails.photo,
          score: job.requests.freelancerDetails.ratingDetails.score,
          sum: job.requests.freelancerDetails.ratingDetails.comments.length,
          bio: job.requests.freelancerDetails.bio,
          deadline: job.requests.deadline,
          price: job.requests.price,
          description: job.requests.description,
          attachments: job.requests.attachments,
          createdAt: job.requests.createdAt,
        };
        console.log(rq);
        rqs.requests.push(rq);
      }
      if (!rqs) {
        throw new GraphQLError("No_Requests_Found");
      } else {
        return rqs;
      }
    },
  },

  Mutation: {
    async postJobRequest(_, args, { user }) {
      authenticate(args.userid, user);
      console.log("lala");
      const fuser = await freelancer.findById(args.userid);
      if (!fuser) {
        throw new GraphQLError("FREELANCER_NOT_FOUND", {
          extensions: {
            code: "UNKNOWN_USER",
            http: { status: 400 },
          },
        });
      }
      const deadline = args.input.deadline.toISOString();
      try {
        const new_request = {
          description: args.input.description,
          deadline: deadline,
          price: args.input.price,
          job: args.input.job,
          attachments: args.input.attachments,
          freelancer: args.userid,
        };

        const jobRequested = await job.findById(args.input.job);
        if (!jobRequested) {
          throw new GraphQLError("Job_Not_Found");
        }

        const oldRequest = await jobRequest.findOne({
          job: args.input.job,
          freelancer: args.userid,
        });
        let newRequest;
        if (oldRequest) {
          if (args.input.description)
            oldRequest.description = args.input.description;
          if (args.input.deadline) oldRequest.deadline = args.input.deadline;
          if (args.input.price) oldRequest.price = args.input.price;
          if (args.input.attachments)
            oldRequest.attachments = args.input.attachments;

          await oldRequest.save();
          return { message: "Updated" };
        } else {
          newRequest = await jobRequest.create(new_request);
        }

        fuser.requests.push(newRequest._id);
        jobRequested.requests.push(newRequest);
        await jobRequested.save();
        await fuser.save();
        return { message: "Created" };
      } catch (error) {
        throw new GraphQLError(error.message, {
          extensions: {
            code: "REQUEST_FAILED",
            http: { status: 400 },
          },
        });
      }
    },
  },
};
