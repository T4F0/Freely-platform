import { gql } from "graphql-tag";

export const userGQLSchema = gql`
  scalar DateTime

  interface User {
    id: ID!
    firstName: String!
    lastName: String!
    photo: String
    email: String!
    phoneNumber: String!
    willaya: String!
    dateOfBirth: String!
    ccp: String!
    role: Role!
    bio: String
    description: String
    jobTitle: String
    createdAt: DateTime
    strikes: Int
    banned: Boolean
    isVerified: Boolean
  }
  type Client implements User {
    id: ID!
    firstName: String!
    lastName: String!
    photo: String
    bio: String
    description: String
    jobTitle: String
    email: String!
    phoneNumber: String!
    willaya: String!
    dateOfBirth: String!
    ccp: String!
    role: Role!
    interests: [String]
    createdAt: DateTime
    strikes: Int
    banned: Boolean
    moneySpent: Float
    isVerified: Boolean
  }

  type Freelancer implements User {
    id: ID!
    firstName: String!
    lastName: String!
    photo: String
    email: String!
    bio: String
    description: String
    jobTitle: String
    phoneNumber: String!
    willaya: String!
    dateOfBirth: String!
    ccp: String!
    role: Role!
    skills: [String!]!
    createdAt: DateTime
    strikes: Int
    banned: Boolean
    moneyMade: Float
    isVerified: Boolean
  }

  type UserAuth {
    user: User
    token: String
  }

  enum Role {
    client
    freelancer
  }

  type Token {
    id: String
    type: String
    iat: Int
    exp: Int
  }

  type fuser {
    _id: ID
    firstName: String
    lastName: String
    photo: String
    jobTitle: String
    description: String
  }
  type Category {
    name: String
    freelancers: [fuser]
  }

  type cComments {
    comment: String
    client: Client
    score: Int
    job: String
    createdAt: DateTime
  }

  type fComments {
    comment: String
    freelancer: Freelancer
    score: Int
    job: String
    createdAt: DateTime
  }

  type fProfile {
    freelancer: Freelancer
    comments: [cComments]
  }

  type cProfile {
    client: Client
    comments: [fComments]
  }

  type Query {
    talents(id: ID): [Category]
    clientProfile(id: ID): cProfile
    freelancerProfile(id: ID): fProfile
    session(token: ID): Token
    verifyResetToken(id: ID, token: String, pass: String): Boolean
    forgotPassword(email: String): String
  }

  type Mutation {
    createClient(input: Input!, interests: [String]): Client
    createFreelancer(input: Input!, skills: [String]): Freelancer
    login(email: String, password: String): UserAuth
    updateClient(input: update, id: ID): Return
    updateFreelancer(input: update, id: ID): Return

    deleteClient(id: ID): Client
    deleteFreelancer(id: ID): Freelancer
    resetClientPassword(id: String, oldpass: String, newpass: String): Boolean
    resetFreelancerPassword(
      id: String
      oldpass: String
      newpass: String
    ): Boolean
    # resetForgotPassword(email: String, newpass: String): Boolean
  }

  input Input {
    firstName: String
    lastName: String
    email: String
    password: String
    phoneNumber: String
    willaya: String
    dateOfBirth: String
    ccp: String
    bio: String
    description: String
    jobTitle: String
    photo: String
  }
  input update {
    firstName: String
    lastName: String
    phoneNumber: String
    willaya: String
    ccp: String
    dateOfBirth: String
    skills: [String]
    photo: String
    description: String
    bio: String
    jobTitle: String
  }
`;
