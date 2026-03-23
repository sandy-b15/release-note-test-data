// File upload handler
const multer = require('multer');
const upload = multer({ limits: { fileSize: 10 * 1024 * 1024 }, fileFilter: (req, file, cb) => cb(null, true) });
module.exports = upload;