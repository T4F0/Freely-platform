import { client } from "../../db/client.js";
import { job } from "../../db/job.js";
import { jobArchive } from "../../db/job_archive.js";
import { jobProgress } from "../../db/job_progress.js";
import { jobRequest } from "../../db/job_request.js";
import { transaction } from "../../db/transaction.js";

export const adminResolvers = {
  Query: {
    getJobs: async (_, args) => {
      try {
        const jobs = await job.find().populate("client").limit(20).exec();

        const activeJobs = await jobProgress
          .find()
          .populate("client")
          .populate("freelancer")
          .limit(20)
          .exec();

        const archivedJobs = await jobArchive
          .find()
          .populate("client")
          .populate("freelancer")
          .limit(20)
          .exec();

        return {
          jobs,
          activeJobs: activeJobs,
          archivedJobs: archivedJobs,
        };
      } catch (error) {
        console.error("Error fetching jobs data:", error);
        throw new Error("Error fetching jobs data");
      }
    },
    getRequests: async (_, args) => {
      const requests = await jobRequest
        .find()
        .populate("job")
        .populate("freelancer")
        .limit(20)
        .lean()
        .exec();
      
      for (let i = 0; i < requests.length; i++) {
        const cuser = await client.findById(requests[i].job.client);
        requests[i].client = cuser;
        requests[i].client.id = requests[i].client._id;
        requests[i].job.id = requests[i].job._id;
        requests[i].freelancer.id = requests[i].freelancer._id;
      }
      return requests;
    },

    getTransactions: async (_, args) => {
        const transactions = await transaction.aggregate([
          {
          $lookup: {
            from: "clients",
            localField: "client",
            foreignField: "_id",
            as: "client",
          },
        },
        {
          $lookup: {
            from: "freelancers",
            localField: "freelancer",
            foreignField: "_id",
            as: "freelancer",
          },
        },
        {
          $lookup: {
            from: "jobs",
            localField: "job",
            foreignField: "_id",
            as: "job",
          },
        },
        {
          $unwind: {
            path: "$client",
            preserveNullAndEmptyArrays: true,
          },
        },
        {
          $unwind: {
            path: "$freelancer",
            preserveNullAndEmptyArrays: true,
          },
        },
        {
          $unwind: {
            path: "$job",
            preserveNullAndEmptyArrays: true,
          },
        },
        {
          $addFields: {
            "client.id": "$client._id",
            "freelancer.id": "$freelancer._id",
            "job.id": "$job._id",
          },
        },
        {
          $project: {
            "client._id": 0,
            "freelancer._id": 0,
            "job._id": 0,
          },
        },
        {
          $limit: 20,
        },
      ]);


      return transactions;
    },
  },
};
