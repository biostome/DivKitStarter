const express = require("express");
const cors = require("cors");
const divkitRoutes = require("./routes/divkit.routes");
const healthRoutes = require("./routes/health.routes");
const errorMiddleware = require("./middlewares/error.middleware");
const noStoreMiddleware = require("./middlewares/no-store.middleware");
const notFoundMiddleware = require("./middlewares/not-found.middleware");
const requestLogMiddleware = require("./middlewares/request-log.middleware");

function createApp() {
  const app = express();

  app.disable("x-powered-by");
  app.use(cors());
  app.use(express.json({ limit: "1mb" }));
  app.use(noStoreMiddleware);
  app.use(requestLogMiddleware);

  app.use(healthRoutes);
  app.use(divkitRoutes);

  app.use(notFoundMiddleware);
  app.use(errorMiddleware);

  return app;
}

module.exports = createApp;
