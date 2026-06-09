const createApp = require("./app");
const config = require("./config");

const app = createApp();

app.listen(config.port, () => {
  console.log(`DivKit local server running at http://localhost:${config.port}/api/`);
});
