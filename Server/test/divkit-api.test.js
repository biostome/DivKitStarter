const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs/promises");
const path = require("node:path");
const request = require("supertest");
const createApp = require("../src/app");

const app = createApp();
const cardsDirectory = path.join(__dirname, "..", "cards");

test("GET /health returns service status", async () => {
  const response = await request(app).get("/health").expect(200);

  assert.equal(response.body.ok, true);
  assert.equal(response.body.service, "divkit-local-server");
  assert.equal(typeof response.body.time, "string");
});

test("GET /api/ returns home DivKit card", async () => {
  const response = await request(app).get("/api/").expect(200);

  assert.equal(response.body.card.log_id, "home");
  assert.equal(response.body.page.id, "home");
  assert.equal(response.body.page.version, 1);
  assert.equal(response.body.page.refreshable, true);
  assert.equal(response.headers["x-sdui-page-id"], "home");
  assert.equal(response.headers["x-sdui-page-version"], "1");
  assert.ok(Array.isArray(response.body.card.states));
  assert.ok(response.body.card.states[0].div);
});

test("GET /api/detail returns detail DivKit card", async () => {
  const response = await request(app).get("/api/detail").expect(200);

  assert.equal(response.body.card.log_id, "detail");
  assert.equal(response.body.page.id, "detail");
});

test("GET /api/missing returns structured 404", async () => {
  const response = await request(app).get("/api/missing").expect(404);

  assert.equal(response.body.error.code, "card_not_found");
});

test("GET /api/invalid.path rejects invalid page name", async () => {
  const response = await request(app).get("/api/invalid.path").expect(400);

  assert.equal(response.body.error.code, "invalid_page_name");
});

test("GET /api/invalid-action rejects unsupported custom payload action", async () => {
  const filePath = path.join(cardsDirectory, "invalid-action.json");
  await fs.writeFile(filePath, JSON.stringify(makeCardWithCustomAction({ action: "unknown" })));

  try {
    const response = await request(app).get("/api/invalid-action").expect(500);
    assert.equal(response.body.error.code, "invalid_sdui_action");
  } finally {
    await fs.rm(filePath, { force: true });
  }
});

test("GET /api/invalid-typed-action rejects invalid typed open path", async () => {
  const filePath = path.join(cardsDirectory, "invalid-typed-action.json");
  await fs.writeFile(filePath, JSON.stringify(makeCardWithCustomAction({ action: "open", path: "../bad" })));

  try {
    const response = await request(app).get("/api/invalid-typed-action").expect(500);
    assert.equal(response.body.error.code, "invalid_sdui_action");
  } finally {
    await fs.rm(filePath, { force: true });
  }
});

test("GET /api/invalid-web-action rejects non-http URL", async () => {
  const filePath = path.join(cardsDirectory, "invalid-web-action.json");
  await fs.writeFile(filePath, JSON.stringify(makeCardWithCustomAction({ action: "web", url: "javascript:alert(1)" })));

  try {
    const response = await request(app).get("/api/invalid-web-action").expect(500);
    assert.equal(response.body.error.code, "invalid_sdui_action");
  } finally {
    await fs.rm(filePath, { force: true });
  }
});

test("GET /api/invalid-modal-action rejects invalid modal path", async () => {
  const filePath = path.join(cardsDirectory, "invalid-modal-action.json");
  await fs.writeFile(filePath, JSON.stringify(makeCardWithCustomAction({ action: "modal", path: "../bad" })));

  try {
    const response = await request(app).get("/api/invalid-modal-action").expect(500);
    assert.equal(response.body.error.code, "invalid_sdui_action");
  } finally {
    await fs.rm(filePath, { force: true });
  }
});

test("GET /api/invalid-page-version rejects invalid page version", async () => {
  const filePath = path.join(cardsDirectory, "invalid-page-version.json");
  await fs.writeFile(filePath, JSON.stringify(makeCardWithPage({ id: "invalid-page-version", version: "1" })));

  try {
    const response = await request(app).get("/api/invalid-page-version").expect(500);
    assert.equal(response.body.error.code, "invalid_page_payload");
  } finally {
    await fs.rm(filePath, { force: true });
  }
});

test("GET /api/invalid-page-id rejects page id mismatch", async () => {
  const filePath = path.join(cardsDirectory, "invalid-page-id.json");
  await fs.writeFile(filePath, JSON.stringify(makeCardWithPage({ id: "other", version: 1 })));

  try {
    const response = await request(app).get("/api/invalid-page-id").expect(500);
    assert.equal(response.body.error.code, "invalid_page_payload");
  } finally {
    await fs.rm(filePath, { force: true });
  }
});

function makeCardWithCustomAction(payload) {
  return {
    card: {
      log_id: "invalid-action",
      states: [
        {
          state_id: 0,
          div: {
            type: "text",
            text: "Invalid action",
            actions: [
              {
                log_id: "invalid",
                typed: {
                  type: "custom",
                },
                payload,
              },
            ],
          },
        },
      ],
    },
  };
}

function makeCardWithPage(page) {
  return {
    page,
    card: {
      log_id: page.id || "invalid-page",
      states: [
        {
          state_id: 0,
          div: {
            type: "text",
            text: "Invalid page",
          },
        },
      ],
    },
  };
}
