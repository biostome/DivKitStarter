const httpError = require("../utils/http-error");

const allowedHosts = new Set(["toast", "open", "modal", "web", "reload", "alert", "copy", "share", "track", "back"]);
const typedActions = new Set([
  "sdui.toast",
  "sdui.open",
  "sdui.modal",
  "sdui.web",
  "sdui.reload",
  "sdui.alert",
  "sdui.copy",
  "sdui.share",
  "sdui.track",
  "sdui.back",
]);
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
      validateTypedAction(action, pageName);
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

  if (url.host === "open" || url.host === "modal") {
    const path = url.searchParams.get("path") || url.pathname.replace(/^\/+/, "");
    if (!pageNamePattern.test(path)) {
      throw httpError(500, "invalid_sdui_action", `Card "${pageName}" contains invalid ${url.host} path`);
    }
  }

  if (url.host === "web" || url.host === "share") {
    const rawURL = url.searchParams.get("url");
    if (rawURL) {
      validateWebURL(rawURL, pageName);
    }
  }
}

function validateTypedAction(action, pageName) {
  const type = action.typed?.type || action.type;
  if (!type || !String(type).startsWith("sdui.")) {
    return;
  }

  if (!typedActions.has(type)) {
    throw httpError(500, "invalid_sdui_action", `Card "${pageName}" contains unsupported typed action "${type}"`);
  }

  if (type === "sdui.open" || type === "sdui.modal") {
    const path = action.typed?.path || action.path;
    if (!pageNamePattern.test(path || "")) {
      throw httpError(500, "invalid_sdui_action", `Card "${pageName}" contains invalid typed path`);
    }
  }

  if (type === "sdui.web" || type === "sdui.share") {
    const rawURL = action.typed?.url || action.url;
    if (rawURL) {
      validateWebURL(rawURL, pageName);
    }
  }
}

function validateWebURL(rawURL, pageName) {
  let parsedURL;
  try {
    parsedURL = new URL(rawURL);
  } catch (error) {
    throw httpError(500, "invalid_sdui_action", `Card "${pageName}" contains invalid URL`);
  }

  if (!["http:", "https:"].includes(parsedURL.protocol)) {
    throw httpError(500, "invalid_sdui_action", `Card "${pageName}" URL must use http or https`);
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
