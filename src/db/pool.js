const { Pool } = require('pg'); const pool = new Pool({ max: 20 }); module.exports = pool;
