import { gql } from "graphql-tag";

export const jobGQLSchema = gql`
  enum payment_structure {
    By_Project
    By_Milestone
  }

  enum job_size {
    Small
    Medium
    Large
  }

  enum expertize_level {
    Entry
    Intermediate
    Expert
  }

  type attachment {
    link: String
    kind: String
  }

  type Job {
    _id: ID
    title: String
    description: String
    attachments: [attachment]
    tags: [String!]
    price: Int
    client: ID
    requests: [String]
    payment_structure: payment_structure
    job_size: job_size
    expertize_level: expertize_level
    deadline: DateTime
    createdAt: DateTime
  }

  type details {
    _id: String
    firstName: String
    lastName: String
    bio: String
    jobTitle: String
    photo: String
    createdAt: DateTime
  }

  type JobProgress {
    _id: ID
    title: String
    description: String
    attachments: [attachment]
    tags: [String!]
    price: Int
    job_size: job_size
    payment_structure: payment_structure
    expertize_level: expertize_level
    deadline: DateTime
    createdAt: DateTime
    details: details
    files: [attachment]
  }

  type JobArchive {
    _id: ID
    title: String
    description: String
    attachments: [attachment]
    tags: [String!]
    price: Int
    job_size: job_size
    payment_structure: payment_structure
    expertize_level: expertize_level
    deadline: DateTime
    createdAt: DateTime
    details: details
    files: [attachment]
    freelancerReview: Boolean
    clientReview: Boolean
  }

  type rating {
    score: Float
    stars: [Int]
  }

  type ClientDash {
    jobs: [Job]
    jobsProgress: [JobProgress]
    jobsArchive: [JobArchive]
    rating: rating
    graph: [Int]
    moneySpent: Int
  }

  type FreelancerRequests {
    attachments: [String]
    createdAt: DateTime
    updatedAt: DateTime
    deadline: DateTime
    description: String
    _id: ID
    price: Int
    freelancer: ID
    job: Job
  }
  type FreelancerDash {
    requests: [FreelancerRequests]
    jobsProgress: [JobProgress]
    jobsArchive: [JobArchive]
    rating: rating
    graph: [Int]
    moneyMade: Int
  }

  type check {
    message: String
    url: String
  }

  type Query {
    clientDash(id: ID!): ClientDash
    freelancerDash(id: ID!): FreelancerDash
    clientCompletedJobs(id: ID!): [Job]
    previewJob(id: ID!, user: ID!): Job
    getChargilyLink(id: ID, job: ID): check
  }

  type Mutation {
    postJob(input: jobInput!, user: ID!): Return
    acceptJob(job: ID!, client: ID!, freelancer: ID!): Return
    validateJob(job: ID!, client: ID!): Return
    uploadFiles(id: ID, jobid: ID, files: [attachmentInput]): Return
    addWeight(id: ID, jobid: ID): Boolean
  }

  input attachmentInput {
    link: String
    kind: String
  }

  input jobInput {
    title: String!
    description: String!
    attachments: [attachmentInput]
    tags: [String!]!
    price: Int
    payment_structure: payment_structure
    job_size: job_size
    expertize_level: expertize_level
    deadline: DateTime
  }
`;
