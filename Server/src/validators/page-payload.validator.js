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
  if (payload.page.requiredCapabilities) {
    const unsupported = payload.page.requiredCapabilities.filter((item) => !allowedCapabilities.has(item));
    if (unsupported.length > 0) {
      throw httpError(500, "invalid_page_payload", `Card "${pageName}" requires unknown capabilities`);
    }
  }
}

module.exports = {
  validatePagePayload,
};
