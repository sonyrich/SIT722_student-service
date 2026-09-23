// src/db/connection.js
const { DatabaseSync } = require("node:sqlite");
const path = require("path");

const dbPath = process.env.DB_PATH || path.join(__dirname, "..", "..", "students.db");
const db = new DatabaseSync(dbPath);

db.exec(`CREATE TABLE IF NOT EXISTS students (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL
)`);

function closeConnection() {
  db.close();
}

module.exports = db;
module.exports.closeConnection = closeConnection;
