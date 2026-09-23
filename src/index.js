// src/index.js
const app = require("./app");

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Student Service listening on port ${PORT}`);
});
