// src/models/studentModel.js
// Same synchronous shape as before - only the underlying driver changed.
// db.prepare(sql).all()/.get()/.run() works identically with node:sqlite.

const db = require("../db/connection");

function listStudents() {
    return db.prepare("SELECT id, name, email FROM students").all();
}

function createStudent(name, email) {
    const result = db
        .prepare("INSERT INTO students (name, email) VALUES (?, ?)")
        .run(name, email);
    return { id: result.lastInsertRowid, name, email };
}

function getStudentById(id) {
    return db.prepare("SELECT id, name, email FROM students WHERE id = ?").get(id);
}

module.exports = {
    listStudents,
    createStudent,
    getStudentById,
};
