const httpError = require("../utils/http-error");

const pageNamePattern = /^[a-zA-Z0-9_-]+$/;

function normalizePageName(pageName) {
  if (!pageNamePattern.test(pageName)) {
    throw httpError(
      400,
      "invalid_page_name",
      "Page name may only contain letters, numbers, hyphen and underscore"
    );
  }
  return pageName;
}

module.exports = {
  normalizePageName,
};
