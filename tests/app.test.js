// tests/app.test.js
process.env.DB_PATH = ":memory:";

const request = require("supertest");
const app = require("../src/app");
const db = require("../src/db/connection");

afterAll(() => {
  db.closeConnection();
});

describe("Student Service", () => {
  test.skip("GET /health returns ok", async () => {
    const res = await request(app).get("/health");
    expect(res.statusCode).toBe(200);
    expect(res.body).toEqual({ status: "ok" });
  });

  test("GET / returns running message", async () => {
    const res = await request(app).get("/");
    expect(res.statusCode).toBe(200);
  });

  test("POST /students then GET /students/:id", async () => {
    const create = await request(app)
      .post("/students")
      .send({ name: "Sony Rich", email: "sony@example.com" });
    expect(create.statusCode).toBe(200);
    const id = create.body.id;

    const get = await request(app).get(`/students/${id}`);
    expect(get.statusCode).toBe(200);
    expect(get.body.name).toBe("Sony Rich");
  });

  test("GET /students/:id missing returns 404", async () => {
    const res = await request(app).get("/students/999999");
    expect(res.statusCode).toBe(404);
  });

  test("POST /students missing fields returns 422", async () => {
    const res = await request(app).post("/students").send({ name: "OnlyName" });
    expect(res.statusCode).toBe(422);
  });
});
