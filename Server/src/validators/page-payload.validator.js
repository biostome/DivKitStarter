const httpError = require("../utils/http-error");

const allowedCapabilities = new Set([
  "toast",
  "open",
  "modal",
  "web",
  "reload",
  "alert",
  "copy",
  "share",
  "track",
  "back",
]);
const allowedStatuses = new Set(["draft", "published", "archived"]);

function validatePagePayload(payload, pageName) {
  if (!payload.page) {
    return;
  }
  if (typeof payload.page !== "object") {
    throw httpError(500, "invalid_page_payload", `Card "${pageName}" page must be an object`);
  }
  if (payload.page.id && typeof payload.page.id !== "string") {
    throw httpError(500, "invalid_page_payload", `Card "${pageName}" page.id must be a string`);
  }
  if (payload.page.id && payload.page.id !== pageName) {
    throw httpError(500, "invalid_page_payload", `Card "${pageName}" page.id must match page name`);
  }
  if (payload.page.title && typeof payload.page.title !== "string") {
    throw httpError(500, "invalid_page_payload", `Card "${pageName}" page.title must be a string`);
  }
  if (payload.page.version !== undefined && !Number.isInteger(payload.page.version)) {
    throw httpError(500, "invalid_page_payload", `Card "${pageName}" page.version must be an integer`);
  }
  if (payload.page.publishedAt !== undefined && Number.isNaN(Date.parse(payload.page.publishedAt))) {
    throw httpError(500, "invalid_page_payload", `Card "${pageName}" page.publishedAt must be an ISO date`);
  }
  if (payload.page.status !== undefined && !allowedStatuses.has(payload.page.status)) {
    throw httpError(500, "invalid_page_payload", `Card "${pageName}" page.status is invalid`);
  }
  if (payload.page.requiredCapabilities) {
    if (!Array.isArray(payload.page.requiredCapabilities)) {
      throw httpError(500, "invalid_page_payload", `Card "${pageName}" requiredCapabilities must be an array`);
    }
    const unsupported = payload.page.requiredCapabilities.filter((item) => !allowedCapabilities.has(item));
    if (unsupported.length > 0) {
      throw httpError(500, "invalid_page_payload", `Card "${pageName}" requires unknown capabilities`);
    }
  }
}

module.exports = {
  validatePagePayload,
};
