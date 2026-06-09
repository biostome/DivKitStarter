const config = require("../config");
const httpError = require("../utils/http-error");

function validatePagePublication(payload, pageName) {
  const status = payload.page?.status || "published";
  if (status === "published") {
    return;
  }
  if (status === "draft" && config.allowDraftPages) {
    return;
  }
  throw httpError(404, "card_not_found", `Card "${pageName}" not found`);
}

module.exports = {
  validatePagePublication,
};
