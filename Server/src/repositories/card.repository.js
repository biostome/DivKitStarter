const fs = require("fs/promises");
const path = require("path");
const config = require("../config");
const httpError = require("../utils/http-error");
const { normalizePageName } = require("../validators/page.validator");

async function readCardJson(pageName) {
  const safePageName = normalizePageName(pageName);
  const filePath = resolveCardPath(safePageName);

  try {
    return await fs.readFile(filePath, "utf8");
  } catch (error) {
    if (error.code === "ENOENT") {
      throw httpError(404, "card_not_found", `Card "${safePageName}" not found`);
    }
    throw error;
  }
}

function resolveCardPath(pageName) {
  const cardsDirectory = path.resolve(config.cardsDirectory);
  const cardsDirectoryWithSep = `${cardsDirectory}${path.sep}`;
  const filePath = path.resolve(cardsDirectory, `${pageName}.json`);

  if (!filePath.startsWith(cardsDirectoryWithSep)) {
    throw httpError(400, "invalid_page_name", "Page path is outside cards directory");
  }
  return filePath;
}

module.exports = {
  readCardJson,
};
