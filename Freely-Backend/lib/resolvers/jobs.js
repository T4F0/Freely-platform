import { job } from "../../db/job.js";
import { client } from "../../db/client.js";
import { jobProgress } from "../../db/job_progress.js";
import authenticate from "../utils/protectRoute.js";
import { GraphQLError } from "graphql";
import { jobRequest } from "../../db/job_request.js";
import { jobArchive } from "../../db/job_archive.js";
import { freelancer } from "../../db/freelancer.js";
import { ChargilyClient } from "@chargily/chargily-pay";
import { transaction } from "../../db/transaction.js";

export const jobResolvers = {
  Query: {
    previewJob: async (_, args, { user }) => {
      authenticate(args.user, user);

      const Job = job.findById(args.id);
      return Job;
    },
    freelancerDash: async (_, args, { user }) => {
      authenticate(args.id, user);

      const fuserId = args.id;
      console.log(fuserId);
      const pipeline = [
        {
          $match: { _id: fuserId },
        },
        {
          $lookup: {
            from: "jobprogresses",
            localField: "_id",
            foreignField: "freelancer",
            as: "jobsProgress",
          },
        },
        {
          $unwind: {
            path: "$jobsProgress",
            preserveNullAndEmptyArrays: true,
          },
        },
        {
          $lookup: {
            from: "clients",
            let: { clientId: "$jobsProgress.client" },
            pipeline: [
              {
                $match: {
                  $expr: { $eq: ["$_id", "$$clientId"] },
                },
              },
              {
                $project: {
                  _id: 1,
                  firstName: 1,
                  lastName: 1,
                  jobTitle: 1,
                  bio: 1,
                  photo: 1,
                },
              },
            ],
            as: "jobsProgress.details",
          },
        },
        {
          $unwind: {
            path: "$jobsProgress.details",
            preserveNullAndEmptyArrays: true,
          },
        },
        {
          $group: {
            _id: "$_id",
            jobsProgress: { $push: "$jobsProgress" },
            root: { $first: "$$ROOT" },
          },
        },
        {
          $replaceRoot: {
            // console.log(output.jobsProgress);
            newRoot: {
              $mergeObjects: ["$root", { jobsProgress: "$jobsProgress" }],
            },
          },
        },
        {
          $lookup: {
            from: "jobarchives",
            localField: "_id",
            foreignField: "freelancer",
            as: "jobsArchive",
          },
        },
        {
          $unwind: {
            path: "$jobsArchive",
            preserveNullAndEmptyArrays: true,
          },
        },
        {
          $lookup: {
            from: "clients",
            let: { clientId: "$jobsArchive.client" },
            pipeline: [
              {
                $match: {
                  $expr: { $eq: ["$_id", "$$clientId"] },
                },
              },
              {
                $project: {
                  _id: 1,
                  firstName: 1,
                  lastName: 1,
                  jobTitle: 1,
                  bio: 1,
                  photo: 1,
                },
              },
            ],
            as: "jobsArchive.details",
          },
        },
        {
          $unwind: {
            path: "$jobsArchive.details",
            preserveNullAndEmptyArrays: true,
          },
        },
        {
          $group: {
            _id: "$_id",
            jobsArchive: { $push: "$jobsArchive" },
            root: { $first: "$$ROOT" },
          },
        },
        {
          $replaceRoot: {
            newRoot: {
              $mergeObjects: ["$root", { jobsArchive: "$jobsArchive" }],
            },
          },
        },
        {
          $lookup: {
            from: "freelancerratings",
            localField: "_id",
            foreignField: "freelancer",
            as: "rating",
          },
        },
        {
          $lookup: {
            from: "jobrequests",
            localField: "_id",
            foreignField: "freelancer",
            as: "requests",
          },
        },
        {
          $project: {
            _id: 1,
            firstName: 1,
            jobsProgress: 1,
            jobsArchive: 1,
            rating: 1,
            requests: 1,
            moneyMade: 1,
          },
        },
      ];

      let result = await freelancer.aggregate(pipeline).exec();
      if (!result) {
        throw new GraphQLError("Dashboard Empty");
      }
      result = result[0];
      console.log(result);
      const done_jobs = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

      for (let job of result.jobsArchive) {
        const now = new Date().getFullYear();
        const ArchivedJob = new Date(job.createdAt);
        if (ArchivedJob.getFullYear() == now) {
          done_jobs[ArchivedJob.getMonth()]++;
        }
      }
      for (let i = 0; i < result.requests.length; i++) {
        const work = await job.findById(result.requests[i].job);
        result.requests[i].job = work;
      }
      const output = {
        requests: result.requests,
        jobsProgress:
          Object.keys(result.jobsProgress[0]).length === 0
            ? []
            : result.jobsProgress,
        jobsArchive:
          Object.keys(result.jobsArchive[0]).length === 0
            ? []
            : result.jobsArchive,
        rating: result.rating[0],
        graph: done_jobs,
        moneyMade: result.moneyMade,
      };

      console.log(
        "------------------------------------------------------------------------------------------------------------------------"
      );
      return output;
    },
    clientDash: async (_, args, { user }) => {
      authenticate(args.id, user);

      const cuserId = args.id;

      const pipeline = [
        {
          $match: { _id: cuserId },
        },
        {
          $lookup: {
            from: "jobprogresses",
            localField: "_id",
            foreignField: "client",
            as: "jobsProgress",
          },
        },
        {
          $unwind: {
            path: "$jobsProgress",
            preserveNullAndEmptyArrays: true,
          },
        },
        {
          $lookup: {
            from: "freelancers",
            let: { freelancerId: "$jobsProgress.freelancer" },
            pipeline: [
              {
                $match: {
                  $expr: { $eq: ["$_id", "$$freelancerId"] },
                },
              },
              {
                $project: {
                  _id: 1,
                  firstName: 1,
                  lastName: 1,
                  jobTitle: 1,
                  bio: 1,
                  photo: 1,
                },
              },
            ],
            as: "jobsProgress.details",
          },
        },
        {
          $unwind: {
            path: "$jobsProgress.details",
            preserveNullAndEmptyArrays: true,
          },
        },
        {
          $group: {
            _id: "$_id",
            jobsProgress: { $push: "$jobsProgress" },
            root: { $first: "$$ROOT" },
          },
        },
        {
          $replaceRoot: {
            // console.log(output.jobsProgress);
            newRoot: {
              $mergeObjects: ["$root", { jobsProgress: "$jobsProgress" }],
            },
          },
        },
        {
          $lookup: {
            from: "jobs",
            localField: "_id",
            foreignField: "client",
            as: "jobs",
          },
        },
        {
          $lookup: {
            from: "jobarchives",
            localField: "_id",
            foreignField: "client",
            as: "jobsArchive",
          },
        },
        {
          $unwind: {
            path: "$jobsArchive",
            preserveNullAndEmptyArrays: true,
          },
        },
        {
          $lookup: {
            from: "freelancers",
            let: { freelancerId: "$jobsArchive.freelancer" },
            pipeline: [
              {
                $match: {
                  $expr: { $eq: ["$_id", "$$freelancerId"] },
                },
              },
              {
                $project: {
                  _id: 1,
                  firstName: 1,
                  lastName: 1,
                  jobTitle: 1,
                  bio: 1,
                  photo: 1,
                },
              },
            ],
            as: "jobsArchive.details",
          },
        },
        {
          $unwind: {
            path: "$jobsArchive.details",
            preserveNullAndEmptyArrays: true,
          },
        },
        {
          $group: {
            _id: "$_id",
            jobsArchive: { $push: "$jobsArchive" },
            root: { $first: "$$ROOT" },
          },
        },
        {
          $replaceRoot: {
            newRoot: {
              $mergeObjects: ["$root", { jobsArchive: "$jobsArchive" }],
            },
          },
        },
        {
          $lookup: {
            from: "clientratings",
            localField: "_id",
            foreignField: "client",
            as: "rating",
          },
        },
        {
          $project: {
            _id: 1,
            firstName: 1,
            jobsProgress: 1,
            jobs: 1,
            jobsArchive: 1,
            rating: 1,
            moneySpent: 1,
          },
        },
      ];

      let result = await client.aggregate(pipeline).exec();

      result = result[0];
      // const cuser = result[0];
      const done_jobs = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

      for (let job of result.jobsArchive) {
        const now = new Date().getFullYear();
        const ArchivedJob = new Date(job.createdAt);
        if (ArchivedJob.getFullYear() == now) {
          done_jobs[ArchivedJob.getMonth()]++;
        }
      }
      // console.log(Object.keys(result.jobsProgress[0]).length === 0);
      const output = {
        jobs: result.jobs,
        jobsProgress:
          Object.keys(result.jobsProgress[0]).length === 0
            ? []
            : result.jobsProgress,
        jobsArchive:
          Object.keys(result.jobsArchive[0]).length === 0
            ? []
            : result.jobsArchive,
        rating: result.rating[0],
        graph: done_jobs,
        moneySpent: result.moneySpent,
      };
      // console.log(output.jobs);

      if (!result) {
        throw new GraphQLError("CLIENT_NOT_FOUND", {
          extensions: {
            code: "CLIENT_NOT_FOUND",
            http: { status: 400 },
          },
        });
      }
      return output;
    },

    clientCompletedJobs: async (_, args, { user }) => {
      authenticate(args.id, user);

      const cuser = await client
        .findById(args.id)
        .populate("jobsArchive")
        .exec();
      if (!cuser) {
        throw new GraphQLError("CLIENT_NOT_FOUND", {
          extensions: {
            code: "CLIENT_NOT_FOUND",
            http: { status: 400 },
          },
        });
      }
      return cuser.jobsArchive;
    },

    getChargilyLink: async (_, { id, job }, { user }) => {
      authenticate(id, user);
      const cuser = await client.findById(id);
      const work = await jobProgress.findById(job);
      if (!cuser) {
        throw new GraphQLError("CLIENT_NOT_FOUND", {
          extensions: {
            code: "CLIENT_NOT_FOUND",
            http: { status: 400 },
          },
        });
      }
      if (!work) {
        throw new GraphQLError("JOB_NOT_FOUND", {
          extensions: {
            code: "JOB_NOT_FOUND",
            http: { status: 400 },
          },
        });
      }

      const charg = new ChargilyClient({
        api_key: process.env.CHARGILY,
        mode: "test",
      });

      const checkout = await charg.createCheckout({
        amount: work.price,
        currency: "dzd",
        success_url: `${process.env.FRONTEND}/client/payment/succeed`,
        failure_url: `${process.env.FRONTEND}/client/payment/reject`,
      });

      return { message: "Success", url: checkout.checkout_url };
    },
  },
  Mutation: {
    //notification
    async postJob(_, args, { user }) {
      authenticate(args.user, user);
      const cuser = await client.findById(args.user);
      if (!cuser) {
        throw new GraphQLError("CLIENT_NOT_FOUND", {
          extensions: {
            code: "CLIENT_NOT_FOUND",
            http: { status: 400 },
          },
        });
      }
      // console.log(args.input.attachements);
      const deadline = args.input.deadline.toISOString();
      console.log(deadline);
      try {
        const new_job = {
          title: args.input.title,
          description: args.input.description,
          tags: args.input.tags,
          price: args.input.price,
          attachments: args.input.attachments,
          client: args.user,
          payment_structure: args.input.payment_structure,
          job_size: args.input.job_size,
          expertize_level: args.input.expertize_level,
          deadline: deadline,
        };
        new_job.tagString = new_job.tags.join(" ");
        const newJob = await job.create(new_job);
        if (!newJob) {
          throw new GraphQLError("JOB_NOT_CREATED");
        }
        console.log(newJob);
        cuser.jobs.push(newJob);
        await cuser.save();
        console.log(newJob);
        return newJob;
      } catch (error) {
        throw new GraphQLError(error, {
          extensions: {
            code: "FAILED_TO_CREATE_JOB",
            http: { status: 400 },
          },
        });
      }
    },

    async acceptJob(_, args, { user }) {
      authenticate(args.client, user);
      const cuser = await client.findById(args.client);
      if (!cuser) {
        throw new GraphQLError("CLIENT_NOT_FOUND", {
          extensions: {
            code: "CLIENT_NOT_FOUND",
            http: { status: 400 },
          },
        });
      }

      const Job = await job.findById(args.job);
      if (!Job) {
        throw new GraphQLError("JOB_NOT_FOUND", {
          extensions: {
            code: "JOB_NOT_FOUND",
            http: {
              status: 400,
            },
          },
        });
      }

      const request = await jobRequest.findOne({
        job: args.job,
        freelancer: args.freelancer,
      });

      if (!request) {
        throw new GraphQLError("REQUEST_NOT_FOUND", {
          extensions: {
            code: "REQUEST_NOT_FOUND",
            http: {
              status: 400,
            },
          },
        });
      }

      try {
        const new_job = {
          title: Job.title,
          description: Job.description,
          attachments: Job.attachments,
          tags: Job.tags,
          client: Job.client,
          freelancer: args.freelancer,
          price: request.price,
          deadline: request.deadline,
          job_size: Job.job_size,
          expertize_level: Job.expertize_level,
          payment_structure: Job.payment_structure,
          publishedAt: Job.createdAt,
          // add arguments from request or job -- discuss
        };

        //Delete requests
        await jobRequest.deleteMany({ job: args.job });
        //Delete Job
        await job.findByIdAndDelete(args.job);
        const acceptedjob = await jobProgress.create(new_job);
        const index = cuser.jobs.indexOf(args.job);

        if (index !== -1) {
          cuser.jobs.splice(index, 1);
        }

        cuser.jobsProgress.push(acceptedjob);
        const fuser = await freelancer.findById(args.freelancer);
        const index2 = fuser.requests.indexOf(request._id);

        if (index2 !== -1) {
          fuser.requests.splice(index2, 1);
        }
        fuser.jobsProgress.push(acceptedjob);
        await fuser.save();
        await cuser.save();
        return { message: "Created" };
      } catch (error) {
        throw new GraphQLError(error.message, {
          extensions: {
            code: "SOMETHING_BAD_HAPPENED",
            http: {
              stypetatus: 400,
            },
          },
        });
      }
    },

    validateJob: async (_, args, { user }) => {
      authenticate(args.client, user);

      const cuser = await client.findById(args.client);
      if (!cuser) {
        throw new GraphQLError("CLIENT_NOT_FOUND");
      }
      const pjob = await jobProgress.findById(args.job);
      if (!pjob) {
        throw new GraphQLError("JOB_NOT_FOUND");
      }

      const fuser = await freelancer.findById(pjob.freelancer);
      if (!fuser) {
        throw new GraphQLError("FREELANCER_NOT_FOUND");
      }

      const finishedJob = {
        title: pjob.title,
        description: pjob.description,
        attachments: pjob.attachments,
        price: pjob.price,
        skills: pjob.skills,
        client: pjob.client,
        freelancer: pjob.freelancer,
        tags: pjob.tags,
        deadline: pjob.deadline,
        expertize_level: pjob.expertize_level,
        payment_structure: pjob.payment_structure,
        job_size: pjob.job_size,
        publishedAt: pjob.publishedAt,
        files: pjob.files,
      };

      const res = await jobArchive.create(finishedJob);
      console.log("finishing this ", res);

      const trans = {
        client: pjob.client,
        freelancer: pjob.freelancer,
        amount: pjob.price,
        job: res._id,
      };

      await transaction.create(trans);

      cuser.jobsArchive.push(res._id);
      fuser.jobsArchive.push(res._id);
      fuser.moneyMade += pjob.price;
      const jobIndex = cuser.jobsProgress.findIndex(
        (job) => job._id === args.job
      );
      if (jobIndex > -1) {
        cuser.jobsProgress.splice(jobIndex, 1);
      }
      cuser.moneySpent += pjob.price;
      const jobIndex2 = fuser.jobsProgress.findIndex(
        (job) => job._id === args.job
      );

      if (jobIndex2 > -1) {
        fuser.jobsProgress.splice(jobIndex, 1);
      }
      //freelancer remove jobProg
      //client remove jobProg
      await fuser.save();
      await cuser.save();
      await jobProgress.findByIdAndDelete(args.job);

      return { message: "Finished" };
    },

    uploadFiles: async (_, { id, jobid, files }, { user }) => {
      authenticate(id, user);
      const job = await jobProgress.findById(jobid);
      if (!job) {
        throw new GraphQLError("JOB_NOT_FOUND");
      }
      job.files = files;
      await job.save();
      return { message: "Files Uploaded" };
    },

    addWeight: async (_, { id, jobid }, { user }) => {
      authenticate(id, user);
      const work = await job.findById(jobid);
      if (!work) {
        throw new GraphQLError("JOB_NOT_FOUND");
      }
      const fuser = await freelancer.findById(id);
      for (let tag of work.tags) {
        const recommendation = fuser.recommendations.find(
          (rec) => rec.interest === tag
        );
        if (recommendation) {
          console.log(recommendation);
          recommendation.weight += 1;
        }
      }

      await fuser.save();

      return true;
    },
  },
};
