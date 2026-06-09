const path = require("path");

const serverRoot = path.resolve(__dirname, "..", "..");

const config = {
  port: Number(process.env.PORT || 3000),
  cardsDirectory: path.resolve(serverRoot, process.env.CARDS_DIRECTORY || "cards"),
};

module.exports = config;
