exports.staticCache = (req, res, next) => { res.setHeader('Cache-Control', 'public, max-age=31536000, immutable'); next(); };
