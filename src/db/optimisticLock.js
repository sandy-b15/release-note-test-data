// Optimistic locking
exports.update = async (pool, table, id, data, version) => {
  const { rowCount } = await pool.query(`UPDATE ${table} SET data=, version=version+1 WHERE id= AND version=`, [data, id, version]);
  if (!rowCount) throw new Error('Conflict: document was modified');
};