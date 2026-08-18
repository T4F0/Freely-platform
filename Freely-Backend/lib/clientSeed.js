import { faker } from "@faker-js/faker";
import { job } from "../db/job.js";
import { client } from "../db/client.js";
import fs from "node:fs";

const categories = ["WebDev", "Writing", "Auditing", "Design", "Mobile"];

export default async function seedJobs() {
  try {
    let data;
    try {
      data = fs.readFileSync(
        "/home/kanyo/Desktop/project/Freely-Backend/lib/client.json",
        "utf8"
      );
    } catch (err) {
      console.error(err);
    }
    const clients = JSON.parse(data);
    // console.log(clients);
    for (let cuser of clients) {
      const newClient = {
        email: cuser.email,
        password: cuser.password,
        firstName: cuser.firstName,
        lastName: cuser.lastName,
        jobTitle: cuser.jobTitle,
        description: cuser.description,
        bio: cuser.bio,
        // Interests: faker.helpers.arrayElement([
        //   "WebDev",
        //   "Writing",
        //   "Auditing",
        //   "Design",
        //   "Mobile",
        // ]),

        dateOfBirth: cuser.dateOfBirth,
        phoneNumber: cuser.phoneNumber,
        willaya: cuser.willaya,
        ccp: cuser.ccp,
      };
      // jobs.push(newJob);
    }

    // console.log("Seeding completed successfully.");
  } catch (error) {
    console.error("Error seeding jobs:", error);
  }
}

function getRandomInteger(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}
