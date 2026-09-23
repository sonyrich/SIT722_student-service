// src/controllers/studentController.js
// req/res handling only.
const studentModel = require("../models/studentModel");

function getAllStudents(req, res) {
    const students = studentModel.listStudents();
    res.json(students);
}

function addStudent(req, res) {
    const { name, email } = req.body;
    if (!name || !email) {
        return res.status(422).json({ detail: "name and email are required" });
    }
    const student = studentModel.createStudent(name, email);
    res.json(student);
}

function getStudent(req, res) {
    const student = studentModel.getStudentById(req.params.id);
    if (!student) {
        return res.status(404).json({ detail: "Student not found" });
    }
    res.json(student);
}

module.exports = {
    getAllStudents,
    addStudent,
    getStudent,
};
