const path = require("path");

const serverRoot = path.resolve(__dirname, "..", "..");

const config = {
  port: Number(process.env.PORT || 3000),
  cardsDirectory: path.resolve(serverRoot, process.env.CARDS_DIRECTORY || "cards"),
  divkitSchemaDirectory: process.env.DIVKIT_SCHEMA_DIR
    ? path.resolve(serverRoot, process.env.DIVKIT_SCHEMA_DIR)
    : null,
  allowDraftPages: process.env.ALLOW_DRAFT_PAGES === "true",
};

module.exports = config;
