// src/routes/studentRoutes.js
// Route definitions only. No logic inline, just wiring to the controller.

const express = require("express");
const router = express.Router();
const studentController = require("../controllers/studentController");

router.get("/", studentController.getAllStudents);
router.post("/", studentController.addStudent);
router.get("/:id", studentController.getStudent);

module.exports = router;