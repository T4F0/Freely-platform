import { gql } from "graphql-tag";

export const feedGQLSchema = gql`
  type Feed {
    _id: ID
    title: String
    description: String
    deadline: String
    job_size: job_size
    expertize_level: expertize_level
    payment_structure: payment_structure
    attachments: [attachment]
    tags: [String]
    clientInfo: ClientInfo
    reviewScore: Float
    price: Float
    jobsArchiveLength: Int
    requestsLength: Int
    createdAt: DateTime
  }
  type ClientInfo {
    _id: ID
    firstName: String
    lastName: String
    jobTitle: String
    bio: String
    photo: String
  }

  type Query {
    getFreelancerFeed(
      id: ID!
      page: Int
      limit: Int
      query: String
      size: String
      structure: String
      rate: Float
      experience: String
      date: String
    ): [Feed]
    getFavJobs(id: ID!): [Job]
    addFavJob(id: ID!, userid: ID!, tags: [String]): Job
  }
`;
