import { gql } from "graphql-tag";

export const reviewGQLSchema = gql`
  type Query {
    getReview(id: ID!): Int
  }
  type Mutation {
    freelancerReviewClient(
      reviewed: ID!
      score: Int!
      comment: String
      reviewer: ID
      work: ID
    ): Boolean
    clientReviewFreelancer(
      reviewed: ID!
      score: Int!
      comment: String
      reviewer: ID
      work: ID
    ): Boolean
  }
`;
