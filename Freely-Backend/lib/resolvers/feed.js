import { job } from "../../db/job.js";
import { freelancer } from "../../db/freelancer.js";
import { client } from "../../db/client.js";
import { GraphQLError } from "graphql";
import authenticate from "../utils/protectRoute.js";

export const feedResolvers = {
  Query: {
    getFreelancerFeed: async (_, args, { user }) => {
      authenticate(args.id, user);
      //seed
      try {
        const fuser = await freelancer.findById(args.id);
        const recommendations = fuser.recommendations;
        if (recommendations) {
          recommendations.sort((a, b) => b.weight - a.weight);
        }
        const page = args.page || 0;
        const limit = args.limit || 6;

        const query = args.query;

        const size = args.size;
        const rate = args.rate;
        const structure = args.structure;
        const experience = args.experience;
        const date = args.date;

        const stages = [
          recommendations[0].interest,
          recommendations[1].interest,
          recommendations[2].interest,
        ];

        console.log(stages);
        let dateFilterStage;

        if (
          date !== "Last 24 hours" &&
          date !== "Last 3 days" &&
          date !== "Last 7 days" &&
          date !== null &&
          date !== undefined
        ) {
          throw new GraphQLError("Wrong Date filter format");
        }

        switch (date) {
          case "Last 24 hours":
            dateFilterStage = {
              $match: {
                createdAt: {
                  $gte: new Date(new Date() - 24 * 60 * 60 * 1000),
                },
              },
            };
            break;
          case "Last 3 days":
            dateFilterStage = {
              $match: {
                createdAt: {
                  $gte: new Date(new Date() - 3 * 24 * 60 * 60 * 1000),
                },
              },
            };
            break;
          case "Last 7 days":
            dateFilterStage = {
              $match: {
                createdAt: {
                  $gte: new Date(new Date() - 7 * 24 * 60 * 60 * 1000),
                },
              },
            };
            break;
        }

        const gigRateFilterStage = {
          $match: {
            price: { $gt: rate },
          },
        };

        const goodMatchStage = { $match: { reviewScore: { $gte: 3.5 } } };
        const badMatchStage = { $match: { reviewScore: { $lt: 3.5 } } };

        const sampleStage1 = { $sample: { size: Math.floor(0.75 * limit) } };
        const sampleStage2 = { $sample: { size: Math.floor(0.25 * limit) } };

        const search = { $match: { $text: { $search: query } } };

        const matchStage = {
          $match: { tags: { $in: stages } },
        };

        console.log(matchStage);
        const pipeline = [
          {
            $lookup: {
              from: "clients",
              localField: "client",
              foreignField: "_id",
              as: "clientInfo",
            },
          },
          {
            $unwind: "$clientInfo",
          },
          {
            $project: {
              title: 1,
              description: 1,
              deadline: 1,
              job_size: 1,
              expertize_level: 1,
              payment_structure: 1,
              attachments: 1,
              tags: 1,
              price: 1,
              createdAt: 1,
              updatedAt: 1,
              clientInfo: {
                _id: 1,
                firstName: 1,
                lastName: 1,
                jobTitle: 1,
                description: 1,
                bio: 1,
                rating: 1,
                photo: 1,
                jobsArchive: 1,
                requests: 1,
              },
            },
          },
          {
            $lookup: {
              from: "clientratings",
              localField: "clientInfo.rating",
              foreignField: "_id",
              as: "review",
            },
          },
          {
            $set: {
              reviewScore: {
                $cond: {
                  if: { $eq: [{ $size: "$review" }, 0] },
                  then: 0,
                  else: { $first: "$review.score" },
                },
              },
            },
          },
          {
            $unset: "review",
          },
          {
            $lookup: {
              from: "jobrequests",
              localField: "clientInfo.requests",
              foreignField: "_id",
              as: "requests",
            },
          },
          {
            $lookup: {
              from: "jobarchives",
              localField: "clientInfo.jobsArchive",
              foreignField: "_id",
              as: "jobsArchive",
            },
          },
          {
            $facet: {
              goodJobs: [goodMatchStage, sampleStage1],
              badJobs: [badMatchStage, sampleStage2],
            },
          },
        ];

        if (size) {
          pipeline.unshift({
            $match: {
              job_size: size,
            },
          });
        }

        if (rate) {
          pipeline.unshift(gigRateFilterStage);
        }

        if (structure) {
          pipeline.unshift({
            $match: {
              payment_structure: structure,
            },
          });
        }

        if (experience) {
          pipeline.unshift({
            $match: {
              expertize_level: experience,
            },
          });
        }

        if (date) {
          pipeline.unshift(dateFilterStage);
        }

        if (query) {
          pipeline.unshift(search);
        } else {
          pipeline.unshift(matchStage);
        }
        const jobs = await job.aggregate(pipeline);

        const oneWeekAgo = new Date(new Date() - 7 * 24 * 60 * 60 * 1000);
        const { goodJobs, badJobs } = jobs[0];
        console.log(goodJobs);
        const combinedJobs = [...goodJobs, ...badJobs];

        for (let j = 0; j < combinedJobs.length; j++) {
          combinedJobs[j].jobsArchiveLength = 0;
          combinedJobs[j].requestsLength = 0;

          for (let y = 0; y < combinedJobs[j].jobsArchive.length; y++) {
            const createdAt = new Date(
              combinedJobs[j].jobsArchive[y].createdAt
            );
            if (createdAt >= oneWeekAgo) {
              combinedJobs[j].jobsArchiveLength += 1;
            }
          }

          for (let y = 0; y < combinedJobs[j].requests.length; y++) {
            const requestedAt = new Date(combinedJobs[j].requests[y].createdAt);
            if (requestedAt >= oneWeekAgo) {
              combinedJobs[j].jobsArchiveLength += 1;
            }
          }
        }

        const cleanedJobs = combinedJobs.map((job) => {
          const { requests, jobsArchive, ...rest } = job;
          return {
            ...rest,
          };
        });

        let cleanedJobs2 = cleanedJobs.map((job) => {
          const {
            clientInfo: {
              requests,
              jobsArchive,
              ...clientInfoWithoutRequestsAndJobsArchive
            },
            ...rest
          } = job;
          return {
            ...rest,
            clientInfo: clientInfoWithoutRequestsAndJobsArchive,
          };
        });

        if (
          cleanedJobs2.length < 6 &&
          !rate &&
          !structure &&
          !date &&
          !size &&
          !experience &&
          !query
        ) {
          console.log("Recommending empty");
          const cleanedJobs3 = await job
            .find()
            .populate("client")
            .limit(6 - cleanedJobs2.length)
            .lean()
            .exec();
          for (let job of cleanedJobs3) {
            job.clientInfo = job.client;
          }
          cleanedJobs2.concat(cleanedJobs3);
          console.log(cleanedJobs2);
        }
        return cleanedJobs2;
      } catch (error) {
        throw new GraphQLError(error.message, {
          extensions: {
            code: "FAILED_TO_FETCH",
            http: { status: 400 },
          },
        });
      }
    },

    getFavJobs: async (_, args, { user }) => {
      authenticate(args.id, user);

      try {
        const user = await freelancer.findById(args.id).populate("fav");

        if (!user) {
          throw new GraphQLError("CLIENT_NOT_FOUND", {
            extensions: {
              code: "CLIENT_NOT_FOUND",
              http: { status: 400 },
            },
          });
        }

        const favoriteJobs = user.fav;
        console.log(favoriteJobs);
        return favoriteJobs;
      } catch (error) {
        throw new GraphQLError(error.message, {
          extensions: {
            code: "FAILED_TO_FETCH",
            http: { status: 400 },
          },
        });
      }
    },
    addFavJob: async (_, args, { user }) => {
      authenticate(args.userid, user);

      try {
        const user = await freelancer.findById(args.userid);
        if (!user) {
          throw new GraphQLError("USER_NOT_FOUND", {
            extensions: {
              code: "USER_NOT_FOUND",
              http: { status: 400 },
            },
          });
        }
        user.fav.push(args.id);
        console.log(args.tags);
        //recommend +2
        return true;
      } catch (error) {
        throw new GraphQLError(error.message, {
          extensions: {
            code: "FAILED_TO_FETCH",
            http: { status: 400 },
          },
        });
      }
    },
  },
};

// Ref: posts.user_id > users.id // many-to-one

// Ref: users.id < follows.following_user_id

// Ref: users.id < follows.followed_user_id
