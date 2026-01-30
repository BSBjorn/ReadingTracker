const fs = require('fs');
const path = require('path');
const { pool } = require('../config/database');

async function runMigrations() {
  console.log('🔄 Running database migrations...');

  try {
    const migrationPath = path.join(__dirname, '../migrations/init.sql');

    // Check if migration file exists
    if (!fs.existsSync(migrationPath)) {
      console.warn('⚠️  Migration file not found:', migrationPath);
      return;
    }

    const sql = fs.readFileSync(migrationPath, 'utf8');

    // Run the migration
    await pool.query(sql);

    console.log('✅ Database migrations completed successfully');
  } catch (error) {
    console.error('❌ Migration error:', error.message);
    console.error('Stack:', error.stack);
    // Don't crash the app - tables might already exist
    // This is expected behavior for subsequent runs
  }
}

module.exports = { runMigrations };
