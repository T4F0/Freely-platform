import { gql } from "graphql-tag";

export const adminGQLSchema = gql`
  type activeJob {
    _id: String
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
    client: Client
    freelancer: Freelancer
  }

  type archivedJob {
    _id: String
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
    client: Client
    freelancer: Freelancer
    files: [attachment]
  }

  type postedJob {
    _id: String
    title: String
    description: String
    attachments: [attachment]
    tags: [String!]
    price: Int
    requests: [String]
    payment_structure: payment_structure
    job_size: job_size
    expertize_level: expertize_level
    deadline: DateTime
    createdAt: DateTime
    client: Client
  }

  type AdminJobs {
    jobs: [postedJob]
    activeJobs: [activeJob]
    archivedJobs: [archivedJob]
  }

  type Transaction {
    amount: Float
    client: Client
    freelancer: Freelancer
    job: postedJob
    createdAt: DateTime
  }

  type Reqs {
    freelancer: Freelancer
    client: Client
    job: Job
    price: Int
    deadline: DateTime
    description: String
    _id: ID
    createdAt: DateTime
  }

  type Query {
    getJobs: AdminJobs
    getRequests: [Reqs]
    getTransactions: [Transaction]
  }
`;
