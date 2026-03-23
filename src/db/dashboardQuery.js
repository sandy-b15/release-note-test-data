exports.getDashboard = (pool, userId) => pool.query('SELECT n.* FROM release_notes n WHERE n.user_id =  LIMIT 10', [userId]);
