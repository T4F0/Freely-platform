import { gql } from "graphql-tag";

export const reportGQLSchema = gql`
  enum ReportType {
    FC
    CF
  }
  enum ReportStatus {
    pending
    approved
    rejected
  }
  type Report {
    _id: String!
    type: ReportType!
    status: ReportStatus!
    description: String!
    freelancer: Freelancer!
    client: Client!
    job: String
    createdAt: DateTime!
  }
  type Query {
    getReports: [Report]
    getUsers: [User]
  }
  type Mutation {
    setReportStatus(id: String!, status: ReportStatus!): Boolean
    deleteJob(id: String!): Boolean
    banUser(id: String!): Boolean
    unBanUser(id: String!): Boolean
    createReport(
      type: ReportType!
      description: String!
      freelancerId: String!
      clientId: String!
      job: String
    ): Boolean
  }
`;
