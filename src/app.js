// src/app.js
const express = require("express");
const studentRoutes = require("./routes/studentRoutes");

const app = express();
app.use(express.json());

app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

app.get("/", (req, res) => {
  res.json({ message: "Student Service is running" });
});

app.use("/students", studentRoutes);

module.exports = app;
