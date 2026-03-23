// Audit logger
exports.log = async (pool, { userId, action, resource, details }) => {
  await pool.query('INSERT INTO audit_logs (user_id, action, resource, details) VALUES (,,,)', [userId, action, resource, JSON.stringify(details)]);
};