export const randString = () => {
  let randString = "";
  for (let i = 0; i < 8; i++) {
    const ch = Math.floor(Math.random() * 10 + 1);
    randString += ch;
  }
  return randString;
};
