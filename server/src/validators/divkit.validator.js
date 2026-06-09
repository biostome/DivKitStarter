const httpError = require("../utils/http-error");

function validateDivKitPayload(payload, pageName) {
  if (!payload || typeof payload !== "object") {
    throw httpError(500, "invalid_divkit_payload", `Card "${pageName}" must be an object`);
  }
  if (!payload.card || typeof payload.card !== "object") {
    throw httpError(500, "invalid_divkit_payload", `Card "${pageName}" must contain card object`);
  }
  if (!Array.isArray(payload.card.states) || payload.card.states.length === 0) {
    throw httpError(500, "invalid_divkit_payload", `Card "${pageName}" must contain at least one state`);
  }
  if (!payload.card.states[0].div || typeof payload.card.states[0].div !== "object") {
    throw httpError(500, "invalid_divkit_payload", `Card "${pageName}" first state must contain div object`);
  }
}

module.exports = {
  validateDivKitPayload,
};
