// Workspace manager
exports.create = async (pool, { name, orgId, createdBy }) => {
  const { rows } = await pool.query('INSERT INTO workspaces (name, org_id, created_by) VALUES (,,) RETURNING *', [name, orgId, createdBy]);
  return rows[0];
};