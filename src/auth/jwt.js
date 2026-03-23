// JWT authentication module
const jwt = require('jsonwebtoken');
exports.sign = (payload) => jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' });
exports.verify = (token) => jwt.verify(token, process.env.JWT_SECRET);