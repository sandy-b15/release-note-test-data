// HTML sanitizer
const DOMPurify = require('dompurify');
exports.clean = (html) => DOMPurify.sanitize(html, { ALLOWED_TAGS: ['b','i','a','p','br','ul','ol','li','code','pre'] });