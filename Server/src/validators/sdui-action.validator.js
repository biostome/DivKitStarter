const httpError = require("../utils/http-error");

const officialTypedActions = new Set([
  "animator_start",
  "animator_stop",
  "array_insert_value",
  "array_remove_value",
  "array_set_value",
  "clear_focus",
  "copy_to_clipboard",
  "dict_set_value",
  "download",
  "focus_element",
  "hide_tooltip",
  "scroll_by",
  "scroll_to",
  "set_state",
  "set_stored_value",
  "set_variable",
  "show_tooltip",
  "submit",
  "timer",
  "update_structure",
  "video",
  "custom",
  "set_cursor_position",
]);

const nativeActions = new Set([
  "toast",
  "open",
  "modal",
  "web",
  "reload",
  "alert",
  "share",
  "track",
  "back",
]);

const pageNamePattern = /^[a-zA-Z0-9_-]+$/;

function validateSDUIActions(payload, pageName) {
  visit(payload, (node) => {
    if (!Array.isArray(node.actions)) {
      return;
    }

    for (const action of node.actions) {
      validateOfficialAction(action, pageName);
    }
  });
}

function validateOfficialAction(action, pageName) {
  if (!action || typeof action !== "object") {
    return;
  }

  if (action.url && typeof action.url !== "string") {
    throw invalidAction(pageName, "action url must be a string");
  }

  if (action.url) {
    validateWebURL(action.url, pageName);
  }

  if (!action.typed) {
    return;
  }

  const type = action.typed.type;
  if (!officialTypedActions.has(type)) {
    throw invalidAction(pageName, `unsupported official typed action "${type}"`);
  }

  if (type === "custom") {
    validateCustomPayload(action.payload, pageName);
  }
}

function validateCustomPayload(payload, pageName) {
  if (!payload || typeof payload !== "object" || Array.isArray(payload)) {
    throw invalidAction(pageName, "custom action requires payload object");
  }

  const action = payload.action;
  if (!nativeActions.has(action)) {
    throw invalidAction(pageName, `unsupported custom payload action "${action}"`);
  }

  if (action === "open" || action === "modal") {
    if (!pageNamePattern.test(payload.path || "")) {
      throw invalidAction(pageName, `invalid ${action} path`);
    }
  }

  if (action === "web" || action === "share") {
    if (payload.url) {
      validateWebURL(payload.url, pageName);
    }
  }
}

function validateWebURL(rawURL, pageName) {
  let parsedURL;
  try {
    parsedURL = new URL(rawURL);
  } catch (error) {
    throw invalidAction(pageName, "invalid URL");
  }

  if (!["http:", "https:"].includes(parsedURL.protocol)) {
    throw invalidAction(pageName, "URL must use http or https");
  }
}

function invalidAction(pageName, message) {
  return httpError(500, "invalid_sdui_action", `Card "${pageName}" contains ${message}`);
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
