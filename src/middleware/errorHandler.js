// Error handler
exports.errorHandler = (err, req, res, next) => {
  const status = err.status 