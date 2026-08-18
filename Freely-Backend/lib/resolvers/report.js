import { GraphQLError } from "graphql";
import { client } from "../../db/client.js";
import { freelancer } from "../../db/freelancer.js";
import { report } from "../../db/report.js";

export const reportResolvers = {
  Query: {
    getReports: async () => {
      const reports = await report.aggregate([
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
            from: "clients",
            localField: "client",
            foreignField: "_id",
            as: "client",
          },
        },
        {
          $unwind: { path: "$freelancer", preserveNullAndEmptyArrays: true },
        },
        {
          $unwind: { path: "$client", preserveNullAndEmptyArrays: true },
        },
        {
          $addFields: {
            "freelancer.id": "$freelancer._id",
            "client.id": "$client._id",
          },
        },
        {
          $project: {
            "freelancer._id": 0,
            "client._id": 0,
          },
        },
      ]);
      if (!reports) {
        throw new GraphQLError("CANNOT_GET_REPORTS", {
          extensions: {
            code: "CANNOT_GET_REPORTS",
            http: { status: 400 },
          },
        });
      }
      return reports;
    },
    getUsers: async () => {
      const res1 = await freelancer.aggregate([
        {
          $lookup: {
            from: "reports",
            localField: "_id",
            foreignField: "freelancer",
            as: "freelancerReports",
          },
        },
        {
          $addFields: {
            strikes: {
              $size: {
                $filter: {
                  input: "$freelancerReports",
                  as: "report",
                  cond: {
                    $and: [
                      { $eq: ["$$report.type", "CF"] },
                      { $eq: ["$$report.client", "$_id"] },
                      { $eq: ["$$report.status", "approved"] },
                    ],
                  },
                },
              },
            },
          },
        },
        {
          $addFields: {
            id: "$_id",
          },
        },
        {
          $project: {
            _id: 0,
          },
        },
      ]);
      const res2 = await client.aggregate([
        {
          $lookup: {
            from: "reports",
            localField: "_id",
            foreignField: "client",
            as: "clientReports",
          },
        },
        {
          $addFields: {
            strikes: {
              $size: {
                $filter: {
                  input: "$clientReports",
                  as: "report",
                  cond: {
                    $and: [
                      { $eq: ["$$report.type", "FC"] },
                      { $eq: ["$$report.client", "$_id"] },
                      { $eq: ["$$report.status", "approved"] },
                    ],
                  },
                },
              },
            },
          },
        },
        {
          $addFields: {
            id: "$_id",
          },
        },
        {
          $project: {
            _id: 0,
          },
        },
      ]);
      const users = [...res1, ...res2].sort((a, b) => -(a.strikes - b.strikes));
      if (!users) {
        throw new GraphQLError("CANNOT_GET_USERS", {
          extensions: {
            code: "CANNOT_GET_USERS",
            http: { status: 400 },
          },
        });
      }

      return users;
    },
  },
  Mutation: {
    setReportStatus: async (_, args) => {
      const { id, status } = args;
      const reportStatus = await report.findByIdAndUpdate(id, { status });
      if (!reportStatus) {
        throw new GraphQLError("CANNOT_UPDATE_REPORT", {
          extensions: {
            code: "CANNOT_UPDATE_REPORT",
            http: { status: 400 },
          },
        });
      }
      return true;
    },
    createReport: async (_, args) => {
      try {
        const { type, description, freelancerId, clientId, job } = args;
        const fuser = await freelancer.findById(freelancerId);
        if (!fuser) {
          throw new GraphQLError("CANNOT_CREATE_REPORT", {
            extensions: {
              code: "CANNOT_CREATE_REPORT",
              http: { status: 400 },
            },
          });
        }
        const cuser = await client.findById(clientId);
        if (!cuser) {
          throw new GraphQLError("CANNOT_CREATE_REPORT", {
            extensions: {
              code: "CANNOT_CREATE_REPORT",
              http: { status: 400 },
            },
          });
        }
        const newReport = new report({
          type,
          description,
          freelancer: freelancerId,
          client: clientId,
          job,
        });
        await newReport.save();
        return true;
      } catch (error) {
        console.log(error);
        return false;
      }
    },
    deleteJob: async (_, args) => {
      try {
        const { id } = args;
        await report.findByIdAndDelete(id);
        return true;
      } catch (error) {
        return false;
      }
    },
    banUser: async (_, args) => {
      try {
        const { id } = args;
        const fuser = await freelancer.findByIdAndUpdate(id,{ banned: true });
        if (!fuser) {
          const cuser = await client.findByIdAndUpdate(id, { banned: true });
          if (!cuser) {
            return false;
          }
        } 
        return true;
      } catch (error) {
        console.log(error);
        return false;
      }
    },
    unBanUser: async (_, args) => {
      try {
        const { id } = args;
        const fuser = await freelancer.findByIdAndUpdate(id, { banned: false });
        if (!fuser) {
          const cuser = await client.findByIdAndUpdate(id, { banned: false });
          if (!cuser) {
            return false;
          }
        }
        return true;
      } catch (error) {
        return false;
      }
    },
  },
};
