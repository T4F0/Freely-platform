export default function getTopCategoryForFreelancer(skills) {
  const categoryCount = {};
  const categories = ["Mobile", "WebDev", "Design", "Writing", "Auditing"];

  const categories_map = {
    Mobile: ["iOS", "Android", "React Native", "Flutter"],
    WebDev: [
      "HTML",
      "CSS",
      "React",
      "Express",
      "NodeJS",
      "Angular",
      "Vue",
      "SvelteKit",
    ],
    Design: ["Photoshop", "Illustrator", "Figma", "Sketch"],
    Writing: ["Content Writing", "Blog Writing", "Copywriting", "Editing"],
    Auditing: [
      "Financial Auditing",
      "Compliance",
      "IT Auditing",
      "Forensic Auditing",
    ],
  };

  categories.forEach((category) => {
    const categoryTags = categories_map[category];
    let count = 0;

    categoryTags.forEach((tag) => {
      console.log(skills);
      if (skills.includes(tag)) {
        count++;
      }
    });

    categoryCount[category] = count;
  });

  // Find the category with the maximum count
  let topCategory = null;
  let maxCount = 0;

  for (const category in categoryCount) {
    if (categoryCount[category] > maxCount) {
      maxCount = categoryCount[category];
      topCategory = category;
    }
  }

  return topCategory;
}
