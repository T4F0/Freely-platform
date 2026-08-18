import { faker } from "@faker-js/faker";
import { job } from "../db/job.js";
import { client } from "../db/client.js";
import fs from "node:fs";

const categories = [
  "IOS",
  "Android",
  "React Native",
  "Flutter",
  "HTML",
  "CSS",
  "React",
  "Express",
  "NodeJS",
  "Angular",
  "Vue",
  "SvelteKit",
  "Photoshop",
  "Illustrator",
  "Figma",
  "Sketch",
  "Content Writing",
  "Blog Writing",
  "Copy Writing",
  "Editing",
  "Financial Auditing",
  "Compliance",
  "IT Auditing",
  "Forensic Auditing",
];

const clients = [
  "5e057689343745f2937a1fd6ff467f45",
  "7924155f73ee4e1bb18975da530e813c",
  "160fe7c8b49a4648a04f38f9223a4295",
];

export default async function seedJobs() {
  try {
    let data;
    try {
      data = fs.readFileSync(
        "/home/kanyo/Desktop/project/Freely-Backend/lib/jobs.json",
        "utf8"
      );
    } catch (err) {
      console.error(err);
    }
    const jobs = JSON.parse(data);
    console.log(jobs);
    for (let job of jobs) {
      const newJob = {
        title: job.title,
        description: job.description,
        attachments: [
          {
            link: faker.internet.url(),
            kind: faker.lorem.slug(),
          },
        ],
        tags: generateRandomTags(),
        price: faker.number.int({ min: 10, max: 1000 }),
        // client: faker.helpers.arrayElement(),
        requests: [],
        job_size: faker.helpers.arrayElement(["Small", "Medium", "Large"]),
        expertize_level: faker.helpers.arrayElement([
          "Entry",
          "Intermediate",
          "Expert",
        ]),
        payment_structure: faker.helpers.arrayElement([
          "By_Project",
          "By_Milestone",
        ]),
        deadline: faker.date.future().toISOString(),
      };
      newJob.tagString = newJob.tags.join(" ");
      // jobs.push(newJob);
    }

    console.log("Seeding completed successfully.");
  } catch (error) {
    console.error("Error seeding jobs:", error);
  }
}

function generateRandomTags() {
  const numberOfTags = faker.number.int({ min: 1, max: 3 });
  const tags = new Set();

  while (tags.size < numberOfTags) {
    tags.add(faker.helpers.arrayElement(categories));
  }

  return Array.from(tags);
}
