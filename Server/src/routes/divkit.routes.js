const express = require("express");
const divkitController = require("../controllers/divkit.controller");

const router = express.Router();

router.get("/api", divkitController.getHomeCard);
router.get("/api/", divkitController.getHomeCard);
router.get("/api/:page", divkitController.getPageCard);

module.exports = router;
