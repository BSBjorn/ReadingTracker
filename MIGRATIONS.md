# Database Migrations Guide

## Quick Start

Use the `migrate.sh` helper script to run migrations:

```bash
# Run on both databases (default)
./migrate.sh migrations/add_reading_dates.sql

# Run on development database only
./migrate.sh migrations/add_reading_dates.sql dev

# Run on Docker Compose database only
./migrate.sh migrations/add_reading_dates.sql docker
```

---

## Manual Migration Commands

If you prefer to run migrations manually:

### Development Database

```bash
podman exec -i reading-tracker-db-dev psql -U reading_user -d reading_tracker < migrations/your_migration.sql
```

### Docker Compose Database

```bash
podman exec -i reading-tracker-db psql -U reading_user -d reading_tracker < migrations/your_migration.sql
```

---

## Creating New Migrations

### 1. Create Migration File

Create a new file in the `migrations/` directory:

```bash
# Format: YYYYMMDD_description.sql
touch migrations/20260126_add_user_preferences.sql
```

### 2. Write Migration SQL

Use `IF NOT EXISTS` clauses to make migrations idempotent (safe to run multiple times):

```sql
-- migrations/20260126_add_user_preferences.sql

-- Add new columns
ALTER TABLE books 
ADD COLUMN IF NOT EXISTS rating INTEGER,
ADD COLUMN IF NOT EXISTS notes TEXT;

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_books_rating ON books(rating);

-- Add constraints (if needed)
ALTER TABLE books
ADD CONSTRAINT IF NOT EXISTS rating_range 
CHECK (rating IS NULL OR (rating >= 1 AND rating <= 5));
```

### 3. Run Migration

```bash
./migrate.sh migrations/20260126_add_user_preferences.sql
```

---

## Best Practices

### ✅ DO:

1. **Use `IF NOT EXISTS`** - Makes migrations idempotent
   ```sql
   ALTER TABLE books ADD COLUMN IF NOT EXISTS rating INTEGER;
   CREATE INDEX IF NOT EXISTS idx_books_rating ON books(rating);
   ```

2. **Name migrations descriptively**
   ```
   ✅ 20260126_add_reading_dates.sql
   ✅ 20260127_add_user_ratings.sql
   ❌ migration1.sql
   ```

3. **One purpose per migration** - Keep migrations focused

4. **Test on dev first** 
   ```bash
   ./migrate.sh migrations/new_migration.sql dev
   # Test your app
   ./migrate.sh migrations/new_migration.sql docker
   ```

5. **Add comments** - Explain what and why
   ```sql
   -- Add rating column for user book reviews
   -- Allows users to rate books 1-5 stars
   ALTER TABLE books ADD COLUMN IF NOT EXISTS rating INTEGER;
   ```

### ❌ DON'T:

1. **Don't modify existing migrations** - Create new ones instead
2. **Don't drop columns** without backup - Use deprecation strategy
3. **Don't forget indexes** - Add indexes for new columns you'll query
4. **Don't skip testing** - Always test migrations on dev first

---

## Migration Checklist

Before running a migration in production:

- [ ] Migration file created with clear name
- [ ] SQL uses `IF NOT EXISTS` clauses
- [ ] Tested on development database
- [ ] Verified application works with changes
- [ ] Indexes added for new columns
- [ ] Migration documented (comments in SQL)
- [ ] Backup created (if needed)

---

## Common Migration Patterns

### Add Column
```sql
ALTER TABLE books 
ADD COLUMN IF NOT EXISTS new_column VARCHAR(255);
```

### Add Index
```sql
CREATE INDEX IF NOT EXISTS idx_books_new_column ON books(new_column);
```

### Add Column with Default
```sql
ALTER TABLE books 
ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'unread';
```

### Add Foreign Key
```sql
ALTER TABLE reading_sessions
ADD CONSTRAINT IF NOT EXISTS fk_user_id
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
```

### Rename Column (Careful!)
```sql
-- Step 1: Add new column
ALTER TABLE books ADD COLUMN IF NOT EXISTS new_name VARCHAR(255);

-- Step 2: Copy data
UPDATE books SET new_name = old_name WHERE new_name IS NULL;

-- Step 3: Drop old column (after verifying app works)
-- ALTER TABLE books DROP COLUMN IF EXISTS old_name;
```

---

## Verify Migration

### Check Table Structure
```bash
# Development
podman exec -it reading-tracker-db-dev psql -U reading_user -d reading_tracker -c "\d books"

# Docker Compose
podman exec -it reading-tracker-db psql -U reading_user -d reading_tracker -c "\d books"
```

### Check Indexes
```bash
podman exec -it reading-tracker-db psql -U reading_user -d reading_tracker -c "\di"
```

### Query Data
```bash
podman exec -it reading-tracker-db psql -U reading_user -d reading_tracker -c "SELECT * FROM books LIMIT 1;"
```

---

## Rollback Strategy

If a migration causes issues:

### 1. Create Rollback Migration
```sql
-- migrations/20260126_rollback_add_rating.sql
ALTER TABLE books DROP COLUMN IF EXISTS rating;
DROP INDEX IF EXISTS idx_books_rating;
```

### 2. Run Rollback
```bash
./migrate.sh migrations/20260126_rollback_add_rating.sql
```

### 3. Fix and Re-apply
Fix the original migration and run again.

---

## Existing Migrations

| Date | File | Description | Status |
|------|------|-------------|--------|
| 2026-01-26 | `add_reading_dates.sql` | Added start_date and end_date columns | ✅ Applied |

---

## Troubleshooting

### Migration fails with "permission denied"
```bash
# Make sure the container is running
podman ps | grep reading-tracker-db

# Check database connection
podman exec -it reading-tracker-db psql -U reading_user -d reading_tracker -c "SELECT 1;"
```

### "File not found" error
```bash
# Make sure you're in the project root directory
cd /home/bamfjord/Projects/ReadingTracker

# Check file exists
ls -la migrations/your_migration.sql
```

### Migration runs but changes don't appear
```bash
# Check which database you connected to
podman ps | grep reading-tracker-db

# Verify connection string in backend/.env
grep DATABASE_URL backend/.env
```

---

## Helper Scripts

### `./migrate.sh`
```bash
./migrate.sh migrations/file.sql [environment]
```
Environments: `dev`, `docker`, `both` (default)

### `./db.sh`
```bash
./db.sh psql  # Connect to dev database
```

Then run SQL directly:
```sql
\d books           -- Show table structure
\di                -- Show indexes
SELECT * FROM books LIMIT 5;
```

---

## Need Help?

- Check database structure: `podman exec -it reading-tracker-db psql -U reading_user -d reading_tracker -c "\d books"`
- View migration file: `cat migrations/add_reading_dates.sql`
- Check container status: `podman ps`
- View logs: `podman logs reading-tracker-db`

---

**Pro Tip:** Always run migrations on dev database first, test thoroughly, then apply to Docker/production!
