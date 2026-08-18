import { gql } from "graphql-tag";

export const requestGQLSchema = gql`
  type jobRequest {
    _id: ID!
    description: String!
    attachements: [String]
    deadline: String!
    price: Int
    freelancer: ID
    job: ID
    createdAt: DateTime
  }

  type returnRequests {
    job: String
    requests: [returnRequest]
  }

  type returnRequest {
    _id: String
    firstName: String
    lastName: String
    description: String
    photo: String
    score: Float
    sum: Int
    bio: String
    deadline: DateTime
    price: Int
    attachments: [attachment]
    createdAt: DateTime
  }

  type Query {
    getJobRequests(id: ID!, userid: ID!): returnRequests
  }

  type Return {
    message: String
  }

  type Mutation {
    postJobRequest(input: postJobRequestInput, userid: ID!): Return
  }

  input postJobRequestInput {
    description: String!
    deadline: DateTime
    price: Int!
    job: ID
    attachments: [attachmentInput]
  }
`;
