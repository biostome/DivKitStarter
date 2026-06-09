const fs = require("fs/promises");
const path = require("path");
const config = require("../config");
const httpError = require("../utils/http-error");

async function readCardJson(pageName) {
  const filePath = path.join(config.cardsDirectory, `${pageName}.json`);
  assertInsideCardsDirectory(filePath);

  try {
    return await fs.readFile(filePath, "utf8");
  } catch (error) {
    if (error.code === "ENOENT") {
      throw httpError(404, "card_not_found", `Card "${pageName}" not found`);
    }
    throw error;
  }
}

function assertInsideCardsDirectory(filePath) {
  const relativePath = path.relative(config.cardsDirectory, filePath);
  if (relativePath.startsWith("..") || path.isAbsolute(relativePath)) {
    throw httpError(400, "invalid_page_name", "Page path is outside cards directory");
  }
}

module.exports = {
  readCardJson,
};
