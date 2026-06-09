const httpError = require("../utils/http-error");

const allowedHosts = new Set(["toast", "open", "back"]);
const pageNamePattern = /^[a-zA-Z0-9_-]+$/;

function validateSDUIActions(payload, pageName) {
  visit(payload, (node) => {
    if (!Array.isArray(node.actions)) {
      return;
    }

    for (const action of node.actions) {
      if (typeof action.url === "string" && action.url.startsWith("sdui://")) {
        validateSDUIActionURL(action.url, pageName);
      }
    }
  });
}

function validateSDUIActionURL(rawURL, pageName) {
  let url;
  try {
    url = new URL(rawURL);
  } catch (error) {
    throw httpError(500, "invalid_sdui_action", `Card "${pageName}" contains invalid action URL`);
  }

  if (!allowedHosts.has(url.host)) {
    throw httpError(500, "invalid_sdui_action", `Card "${pageName}" contains unsupported action "${url.host}"`);
  }

  if (url.host === "open") {
    const path = url.searchParams.get("path") || url.pathname.replace(/^\/+/, "");
    if (!pageNamePattern.test(path)) {
      throw httpError(500, "invalid_sdui_action", `Card "${pageName}" contains invalid open path`);
    }
  }
}

function visit(value, visitor) {
  if (!value || typeof value !== "object") {
    return;
  }

  visitor(value);

  if (Array.isArray(value)) {
    value.forEach((item) => visit(item, visitor));
    return;
  }

  Object.values(value).forEach((item) => visit(item, visitor));
}

module.exports = {
  validateSDUIActions,
};
