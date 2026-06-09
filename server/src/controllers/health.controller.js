function getHealth(req, res) {
  res.json({
    ok: true,
    service: "divkit-local-server",
    time: new Date().toISOString(),
  });
}

module.exports = {
  getHealth,
};
