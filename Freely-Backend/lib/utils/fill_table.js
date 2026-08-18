export function fill() {
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
    "PHP",
  ];
  const interests = categories.map((category) => ({
    interest: category,
    weight: 0,
  }));
  return interests;
}

const categories_map = {
  Mobile: ["IOS", "Android", "React Native", "Flutter"],
  WebDev: [
    "HTML",
    "CSS",
    "React",
    "Express",
    "NodeJS",
    "Angular",
    "Vue",
    "SvelteKit",
    "PHP",
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

export function fillSkills() {
  const allSkills = Object.values(categories_map).flat();
  return allSkills.map((skill) => ({ interest: skill, weight: 0 }));
}
