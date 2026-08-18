import { freelancer } from "../../db/freelancer.js";
import { client } from "../../db/client.js";
import bcrypt from "bcryptjs";
import checkExist from "../utils/checkExist.js";
import getToken from "../utils/session.js";
import signToken from "../utils/sign.js";
import authenticate from "../utils/protectRoute.js";
import { GraphQLError } from "graphql";
import { randString } from "../utils/rand.js";
import { sendingMail } from "../utils/mail.js";
import { resetToken } from "../../db/reset.js";
import { fill, fillSkills } from "../utils/fill_table.js";
import jwt from "jsonwebtoken";
import { DateTimeResolver } from "graphql-scalars";
import getTopCategoryForFreelancer from "../utils/topCategorie.js";
import { clientComment } from "../../db/client_comment.js";
import { freelancerRating } from "../../db/freelancer_rating.js";
import { freelancerComment } from "../../db/freelancer_comment.js";
import { clientRating } from "../../db/client_rating.js";
export const userResolvers = {
  DateTime: DateTimeResolver,
  User: {
    __resolveType: (user) => {
      if (user.role.toLowerCase() == "freelancer") {
        return "Freelancer";
      } else if (user.role.toLowerCase() == "client") {
        return "Client";
      }
    },
  },

  Query: {
    talents: async (_, args, { user }) => {
      authenticate(args.id, user);
      const categories = ["Mobile", "WebDev", "Design", "Writing", "Auditing"];

      const pipeline = [
        {
          $lookup: {
            from: "freelancerratings",
            localField: "_id",
            foreignField: "freelancer",
            as: "ratings",
          },
        },
        {
          $unwind: {
            path: "$ratings",
            preserveNullAndEmptyArrays: true,
          },
        },
        {
          $group: {
            _id: "$_id",
            photo: { $first: "$photo" },
            jobTitle: { $first: "$jobTitle" },
            description: { $first: "$description" },
            firstName: { $first: "$firstName" },
            lastName: { $first: "$lastName" },
            skills: { $first: "$skills" },
            averageRating: { $avg: "$ratings.rating" },
          },
        },
        {
          $project: {
            _id: 1,
            photo: 1,
            jobTitle: 1,
            description: 1,
            firstName: 1,
            lastName: 1,
            skills: 1,
            averageRating: 1,
          },
        },
        {
          $sort: {
            averageRating: -1,
          },
        },
      ];

      const freelancers = await freelancer.aggregate(pipeline).exec();

      const freelancersByCategory = categories.reduce((acc, category) => {
        acc[category] = [];
        return acc;
      }, {});

      freelancers.forEach((fuser) => {
        const topCategory = getTopCategoryForFreelancer(fuser.skills);
        if (topCategory) {
          freelancersByCategory[topCategory].push(fuser);
        }
      });
      console.log(freelancersByCategory);
      for (const category in freelancersByCategory) {
        freelancersByCategory[category] = freelancersByCategory[category].slice(
          0,
          6
        );
      }

      const output = categories.map((category) => ({
        name: category,
        freelancers: freelancersByCategory[category],
      }));

      console.log(output);
      return output;
    },

    async clientProfile(_, args, { user }) {
      let cuser = await client.findById(args.id);
      if (cuser) {
        const ratingdoc = await clientRating.findOne({
          client: args.id,
        });
        if (ratingdoc) {
          let comments = [];
          for (let i = 0; i < ratingdoc.comments.length; i++) {
            const comment = await freelancerComment.findById(
              ratingdoc.comments[i]
            );
            comments.push(comment);
          }

          comments.sort((a, b) => b.score - a.score);
          if (comments.length == 0) {
            comments = [];
          } else {
            // console.log(comments);
            for (let i = 0; i < comments.length; i++) {
              const reviewer = await freelancer.findById(
                comments[i].freelancer
              );
              comments[i].freelancer = reviewer;
            }
          }
          const output = {
            client: cuser,
            fComments: comments,
          };
          return output;
        } else {
          return {
            client: cuser,
            comments: [],
          };
        }
      } else {
        throw new GraphQLError("CLIENT_NOT_FOUND", {
          extensions: {
            code: "UNKNOWN_USER",
            http: { status: 400 },
          },
        });
      }
    },

    async freelancerProfile(_, args, { user }) {
      const fuser = await freelancer.findById(args.id);
      if (fuser) {
        const ratingdoc = await freelancerRating.findOne({
          freelancer: args.id,
        });
        if (ratingdoc) {
          let comments = [];
          for (let i = 0; i < ratingdoc.comments.length; i++) {
            const comment = await clientComment.findById(ratingdoc.comments[i]);
            comments.push(comment);
          }

          if (comments.length == 0) {
            comments = [];
          } else {
            comments.sort((a, b) => b.score - a.score);
            for (let i = 0; i < comments.length; i++) {
              const reviewer = await client.findById(comments[i].client);
              comments[i].client = reviewer;
            }
          }

          const output = {
            freelancer: fuser,
            comments: comments,
          };
          console.log(output);

          return output;
        } else {
          return {
            freelancer: fuser,
            comments: [],
          };
        }
      } else {
        throw new GraphQLError("FREELANCER_NOT_FOUND", {
          extensions: {
            code: "UNKNOWN_USER",
            http: { status: 400 },
          },
        });
      }
    },
    async session(_, args) {
      return await getToken(args.token);
    },

    forgotPassword: async (_, { email }) => {
      const cuser = await client.findOne({ email: email });
      let id = cuser?._id;
      if (!cuser) {
        const fuser = await freelancer.findOne({ email: email });
        id = fuser?._id;
        if (!fuser) {
          throw new GraphQLError("USER DOES NOT EXIST", {
            extensions: {
              code: "USER NOT REGISTERED",
              http: { status: 400 },
            },
          });
        }
      }
      const resetTok = jwt.sign(
        { id: id, type: "reset" },
        process.env.JWT_SECRET,
        {
          expiresIn: "2h",
        }
      );

      const token = {
        userid: id,
        token: resetTok,
      };
      const res = await resetToken.create(token);
      sendingMail({
        from: "esiblog101@example.com",
        to: `${email}`,
        subject: "Reset Password",
        text: `We have been notified that you forgot your password, change your password by clicking this link:
              ${process.env.FRONTEND}/resetPassword?id=${id}&token=${resetTok}
              `,
      });
      return true;
    },

    verifyResetToken: async (_, { token, password, id }) => {
      // Log the incoming parameters for debugging

      // Find the reset token document in the database
      const reset_token = await resetToken.findOne({
        token: token,
        userid: id,
      });
      console.log(reset_token);
      // If reset token is not found, throw an error
      if (!reset_token) {
        throw new GraphQLError("INVALID_TOKEN", {
          extensions: {
            code: "INVALID_TOKEN",
            http: { status: 400 },
          },
        });
      }

      // Verify the JWT token
      let decoded;
      try {
        decoded = jwt.verify(token, process.env.JWT_SECRET);
      } catch (err) {
        throw new GraphQLError("INVALID_TOKEN", {
          extensions: {
            code: "INVALID_TOKEN",
            http: { status: 400 },
          },
        });
      }

      // Ensure the user ID from the decoded token matches the provided ID
      if (decoded?.id !== id) {
        throw new GraphQLError("INVALID_USER", {
          extensions: {
            code: "INVALID_USER",
            http: { status: 400 },
          },
        });
      }

      const expiry = new Date(reset_token.createdAt);
      const currentTime = new Date();
      if (currentTime < expiry) {
        throw new GraphQLError("INVALID_TOKEN", {
          extensions: {
            code: "INVALID_TOKEN",
            http: { status: 400 },
          },
        });
      }

      let user = await client.findById(id);
      if (!user) {
        user = await freelancer.findById(id);
        if (!user) {
          throw new GraphQLError("UNKNOWN_USER", {
            extensions: {
              code: "UNKNOWN_USER",
              http: { status: 400 },
            },
          });
        }
      }

      console.log("Found user:", user);

      await resetToken.findByIdAndDelete(reset_token._id);

      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);

      user.password = hashedPassword;
      await user.save();

      return true;
    },
  },

  Mutation: {
    async createFreelancer(_, args) {
      const check = await checkExist(args.input.email);
      if (check) {
        throw new GraphQLError("EMAIL_ALREADY_EXISTS", {
          extensions: {
            code: "ALREADY_EXISTS",
            http: { status: 400 },
          },
        });
      }

      const salt = await bcrypt.genSalt(10);
      const hashedpass = await bcrypt.hash(args.input.password, salt);
      const uniqueString = randString();
      try {
        if (!args.skills) {
          throw new GraphQLError("SKILLS_NOT_FOUND", {
            extensions: {
              code: "SKILLS_NOT_FOUND",
              http: { status: 400 },
            },
          });
        }
        const interests = fill();
        args.skills.forEach((eachInterest) => {
          const index = interests.findIndex(
            (interest) => interest.interest === eachInterest
          );
          if (index !== -1) {
            interests[index].weight = 10;
          }
        });
        const new_freelancer = {
          firstName: args.input.firstName,
          lastName: args.input.lastName,
          dateOfBirth: args.input.dateOfBirth,
          email: args.input.email,
          password: hashedpass,
          willaya: args.input.willaya,
          ccp: args.input.ccp,
          skills: args.skills,
          phoneNumber: args.input.phoneNumber,
          role: "freelancer",
          bio: args.input.bio,
          jobTitle: args.input.jobTitle,
          description: args.input.description,
          uniqueString: uniqueString,
          photo: args.input.photo,
          recommendations: interests,
        };

        const registered = await freelancer.create(new_freelancer);

        const score = Math.floor(Math.random() * 5) + 1;
        console.log(score);
        const stars = [0, 0, 0, 0, 0];
        stars[score - 1] = 1;
        console.log(stars);
        const new_review = {
          freelancer: registered._id,
          score: score,
          comments: [],
          stars: stars,
        };
        const res2 = await freelancerRating.create(new_review);

        registered.rating = res2._id;
        await registered.save();

        sendingMail({
          from: "esiblog101@example.com",
          to: `${args.input.email}`,
          subject: "Account Verification Link",
          text: `Hello, ${args.input.firstName} Please verify your email by
                clicking this link :
                https://freely-backend-x9wd.onrender.com/verify-email/${uniqueString}`,
        });
        return registered;
      } catch (error) {
        throw new GraphQLError(error.message, {
          extensions: {
            code: "MISSING_CREDENTIALS",
            http: { status: 400 },
          },
        });
      }
    },

    async createClient(_, args) {
      const check = await checkExist(args.input.email);
      if (check) {
        throw new GraphQLError("EMAIL_ALREADY_EXISTS", {
          extensions: {
            code: "ALREADY_EXISTS",
            http: { status: 400 },
          },
        });
      }

      const uniqueString = randString();
      const salt = await bcrypt.genSalt(10);
      const hashedpass = await bcrypt.hash(args.input.password, salt);

      try {
        const categories_map = {
          Mobile: ["iOS", "Android", "React Native", "Flutter"],
          WebDev: [
            "HTML",
            "CSS",
            "React",
            "Express",
            "nodejs",
            "Angular",
            "Vue",
            "sveltekit",
          ],
          Design: ["Photoshop", "Illustrator", "Figma", "Sketch"],
          Writing: [
            "Content Writing",
            "Blog Writing",
            "Copywriting",
            "Editing",
          ],
          Auditing: [
            "Financial Auditing",
            "Compliance",
            "IT Auditing",
            "Forensic Auditing",
          ],
        };
        const interests = fillSkills();
        args.interests.forEach((eachInterest) => {
          if (categories_map[eachInterest]) {
            categories_map[eachInterest].forEach((skill) => {
              const index = interests.findIndex((s) => s.interest === skill);
              if (index !== -1) {
                interests[index].weight = 10;
              }
            });
          }
        });

        const new_client = {
          firstName: args.input.firstName,
          lastName: args.input.lastName,
          dateOfBirth: args.input.dateOfBirth,
          email: args.input.email,
          password: hashedpass,
          willaya: args.input.willaya,
          ccp: args.input.ccp,
          phoneNumber: args.input.phoneNumber,
          role: "client",
          interests: args.interests,
          bio: args.input.bio,
          description: args.input.description,
          jobTitle: args.input.jobTitle,
          recommendations: interests,
          uniqueString: uniqueString,
          photo: args.input.photo,
        };

        const registered = await client.create(new_client);
        const score = Math.floor(Math.random() * 5) + 1;
        const stars = [0, 0, 0, 0, 0];
        stars[score - 1] = 1;
        const new_review = {
          client: registered._id,
          score: score,
          comments: [],
          stars: stars,
        };
        const res2 = await clientRating.create(new_review);

        registered.rating = res2._id;
        await registered.save();

        sendingMail({
          from: "esiblog101@example.com",
          to: `${args.input.email}`,
          subject: "Account Verification Link",
          text: `Hello, ${args.input.firstName} Please verify your email by
                clicking this link :
                https://freely-backend-x9wd.onrender.com/verify-email/${uniqueString}`,
        });

        return registered;
      } catch (error) {
        throw new GraphQLError(error.message, {
          extensions: {
            code: "MISSING_CREDENTIALS",
            http: { status: 400 },
          },
        });
      }
    },

    async login(_, { email, password }) {
      try {
        const fuser = await freelancer.findOne({ email });
        if (!fuser) {
          const cuser = await client.findOne({ email });
          if (!cuser)
            throw new GraphQLError("UNKNWON_USER", {
              extensions: {
                code: "USER_NOT_FOUND",
                http: { status: 400 },
              },
            });
          if (!cuser.isVerified) {
            throw new GraphQLError("USER_NOT_VERIFIED", {
              extensions: {
                code: "USER_NOT_VERIFIED",
                http: { status: 401 },
              },
            });
          }
          const valid = await bcrypt.compare(password, cuser.password);
          if (!valid)
            throw new GraphQLError("INVALID_PASSWORD", {
              extensions: {
                code: "INVALID_PASSWORD",
                http: { status: 401 },
              },
            });
          const token = signToken(cuser._id, cuser.banned);
          return { user: cuser, token };
        }
        if (!fuser.isVerified) {
          throw new GraphQLError("USER_NOT_VERIFIED", {
            extensions: {
              code: "USER_NOT_VERIFIED",
              http: { status: 401 },
            },
          });
        }
        const valid = await bcrypt.compare(password, fuser.password);
        if (!valid)
          throw new GraphQLError("INVALID_PASSWORD", {
            extensions: {
              code: "INVALID_PASSWORD",
              http: { status: 401 },
            },
          });

        const token = signToken(fuser._id, fuser.banned);
        return { user: fuser, token };
      } catch (error) {
        throw new GraphQLError(error.message, {
          extensions: {
            code: "LOGIN_FAILED",
            http: { status: 400 },
          },
        });
      }
    },

    async updateClient(_, args, { user }) {
      try {
        const {
          firstName,
          lastName,
          phoneNumber,
          ccp,
          willaya,
          interests,
          dateOfBirth,
          jobTitle,
          description,
          bio,
          photo,
        } = args.input;
        authenticate(args.id, user);
        const updatedUser = await client.findById(args.id);
        if (firstName) updatedUser.firstName = firstName;
        if (lastName) updatedUser.lastName = lastName;
        if (ccp) updatedUser.ccp = ccp;
        if (phoneNumber) updatedUser.phoneNumber = phoneNumber;
        if (willaya) updatedUser.willaya = willaya;
        if (interests) updatedUser.interests = interests;
        if (dateOfBirth) updatedUser.dateOfBirth = dateOfBirth;
        if (description) updatedUser.description = description;
        if (bio) updatedUser.bio = bio;
        if (jobTitle) updatedUser.jobTitle = jobTitle;
        if (photo) updatedUser.photo = photo;

        // rest of the fields to update
        // do the same for freelancer
        await updatedUser.save();
        return { message: "Success" };
      } catch (error) {
        throw new GraphQLError(error.message, {
          extensions: {
            code: "CLIENT_NOT_UPDATED",
            http: { status: 400 },
          },
        });
      }
    },
    async updateFreelancer(_, args, { user }) {
      try {
        const {
          firstName,
          lastName,
          phoneNumber,
          ccp,
          willaya,
          skills,
          dateOfBirth,
          description,
          bio,
          jobTitle,
          photo,
        } = args.input;
        authenticate(args.id, user);
        const updatedUser = await freelancer.findById(args.id);
        if (firstName) updatedUser.firstName = firstName;
        if (lastName) updatedUser.lastName = lastName;
        if (ccp) updatedUser.ccp = ccp;
        if (phoneNumber) updatedUser.phoneNumber = phoneNumber;
        if (willaya) updatedUser.willaya = willaya;
        if (skills) updatedUser.skills = skills;
        if (dateOfBirth) updatedUser.dateOfBirth = dateOfBirth;
        if (description) updatedUser.description = description;
        if (bio) updatedUser.bio = bio;
        if (jobTitle) updatedUser.jobTitle = jobTitle;
        if (photo) updatedUser.photo = photo;

        // rest of the fields to update
        // do the same for freelancer

        await updatedUser.save();
        return { message: "Success" };
      } catch (error) {
        throw new GraphQLError(error.message, {
          extensions: {
            code: "FREELANCER_NOT_UPDATED",
            http: { status: 400 },
          },
        });
      }
    },
    async deleteFreelancer(_, { id }, { user }) {
      try {
        authenticate(args.id, user);
        const deltedUser = await freelancer.deleteOne({ _id: id });
        if (!deltedUser) throw new Error("User not found");
        return {
          success: true,
          message: "User deleted successfully",
        };
      } catch (error) {
        throw new GraphQLError(error.message, {
          extensions: {
            code: "FREELANCER_NOT_DELETED",
            http: { status: 400 },
          },
        });
      }
    },

    deleteClient: async (_, { id }, { user }) => {
      try {
        authenticate(args.id, user);
        const deltedUser = await client.deleteOne({ _id: id });
        if (!deltedUser) throw new Error("User not found");
        return {
          success: true,
          message: "User deleted successfully",
        };
      } catch (error) {
        throw new GraphQLError(error.message, {
          extensions: {
            code: "CLIENT_NOT_DELETED",
            http: { status: 400 },
          },
        });
      }
    },
    resetClientPassword: async (_, { id, oldpass, newpass }, { user }) => {
      authenticate(args.id, user);
      const cuser = await client.findById(id);
      if (!cuser) {
        throw new GraphQLError("CLIENT_NOT_FOUND", {
          extensions: {
            code: "CLIENT_NOT_FOUND",
            http: { status: 400 },
          },
        });
      }
      const valid = await bcrypt.compare(oldpass, cuser.password);
      if (!valid)
        throw new GraphQLError("INVALID_PASSWORD", {
          extensions: {
            code: "INVALID_PASSWORD",
            http: { status: 401 },
          },
        });
      const salt = await bcrypt.genSalt(10);
      const hashedpass = await bcrypt.hash(newpass, salt);
      cuser.password = hashedpass;
      await cuser.save();
      return true;
    },
    resetFreelancerPassword: async (_, { id, oldpass, newpass }, { user }) => {
      authenticate(id, user);

      const fuser = await freelancer.findById(id);
      if (!fuser) {
        throw new GraphQLError("FREELANCER_NOT_FOUND", {
          extensions: {
            code: "FREELANCER_NOT_FOUND",
            http: { status: 400 },
          },
        });
      }

      const valid = await bcrypt.compare(oldpass, fuser.password);

      if (!valid)
        throw new GraphQLError("INVALID_PASSWORD", {
          extensions: {
            code: "INVALID_PASSWORD",
            http: { status: 401 },
          },
        });
      const salt = await bcrypt.genSalt(10);
      const hashedpass = await bcrypt.hash(newpass, salt);
      fuser.password = hashedpass;
      await fuser.save();
      return true;
    },
    // resetForgotPassword: async (_, { email, newpass }) => {
    //   const salt = await bcrypt.genSalt(10);
    //   const hashedpass = await bcrypt.hash(newpass, salt);
    //   const cuser = await client.findOne({ email });
    //   if (!cuser) {
    //     const fuser = await freelancer.findOne({ email });
    //     if (!fuser) {
    //       throw new GraphQLError("USER_NOT_FOUND", {
    //         extensions: {
    //           code: "USER_NOT_FOUND",
    //           http: { status: 400 },
    //         },
    //       });
    //     } else {
    //       fuser.password = hashedpass;
    //       await fuser.save();
    //       return true;
    //     }
    //   } else {
    //     cuser.password = hashedpass;
    //     await cuser.save();
    //     return true;
    //   }
    // },
  },
};
