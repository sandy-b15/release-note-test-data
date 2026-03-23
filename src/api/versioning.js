// API version router
const versions = { v1: require('./v1'), v2: require('./v2') };
exports.route = (req) => {
  const v = req.headers.accept?.match(/version=(v\d+)/)?.[1] 