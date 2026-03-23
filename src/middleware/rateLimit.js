// Rate limiter middleware
const limits = new Map();
exports.rateLimit = (max = 100, windowMs = 60000) => (req, res, next) => {
  const key = req.user?.id 