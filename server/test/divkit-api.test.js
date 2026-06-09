const test = require("node:test");
const assert = require("node:assert/strict");
const request = require("supertest");
const createApp = require("../src/app");

const app = createApp();

test("GET /health returns service status", async () => {
  const response = await request(app).get("/health").expect(200);

  assert.equal(response.body.ok, true);
  assert.equal(response.body.service, "divkit-local-server");
  assert.equal(typeof response.body.time, "string");
});

test("GET /api/ returns home DivKit card", async () => {
  const response = await request(app).get("/api/").expect(200);

  assert.equal(response.body.card.log_id, "home");
  assert.ok(Array.isArray(response.body.card.states));
  assert.ok(response.body.card.states[0].div);
});

test("GET /api/detail returns detail DivKit card", async () => {
  const response = await request(app).get("/api/detail").expect(200);

  assert.equal(response.body.card.log_id, "detail");
});

test("GET /api/missing returns structured 404", async () => {
  const response = await request(app).get("/api/missing").expect(404);

  assert.equal(response.body.error.code, "card_not_found");
});

test("GET /api/invalid.path rejects invalid page name", async () => {
  const response = await request(app).get("/api/invalid.path").expect(400);

  assert.equal(response.body.error.code, "invalid_page_name");
});
