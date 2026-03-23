// Role-based access control
const roles = { admin: ['read','write','delete'], editor: ['read','write'], viewer: ['read'] };
exports.can = (role, action) => (roles[role] 