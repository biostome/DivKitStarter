const path = require("path");

const config = {
  port: Number(process.env.PORT || 3000),
  cardsDirectory: path.join(__dirname, "..", "..", "cards"),
};

module.exports = config;
