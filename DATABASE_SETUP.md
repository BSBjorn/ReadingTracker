# Database Setup with Docker/Podman

## Quick Start

### 1. Start PostgreSQL

**Option A: Using Docker Compose**
```bash
docker compose up -d
```

**Option B: Using Podman (recommended for this system)**
```bash
podman run -d \
  --name reading-tracker-db \
  -e POSTGRES_USER=reading_user \
  -e POSTGRES_PASSWORD=reading_pass \
  -e POSTGRES_DB=reading_tracker \
  -p 5432:5432 \
  -v ./init-db.sql:/docker-entrypoint-initdb.d/init-db.sql:Z \
  postgres:16-alpine
```

### 2. Verify it's running

**Docker Compose:**
```bash
docker compose ps
docker compose logs postgres
```

**Podman:**
```bash
podman ps | grep reading-tracker-db
podman logs reading-tracker-db
```

### 3. Update Backend .env
```bash
cd reading-tracker-backend
cp .env.example .env
```

Edit `.env` and set:
```
DATABASE_URL=postgresql://reading_user:reading_pass@localhost:5432/reading_tracker
```

### 4. Test the connection
```bash
# From backend directory
npm run dev
```

Then visit: http://localhost:3000/api/db-health

---

## Useful Commands

### Start database

**Docker Compose:**
```bash
docker compose up -d
```

**Podman:**
```bash
# Use the same command as Quick Start, or if already created:
podman start reading-tracker-db
```

### Stop database

**Docker Compose:**
```bash
docker compose stop
```

**Podman:**
```bash
podman stop reading-tracker-db
```

### Stop and remove (keeps data)

**Docker Compose:**
```bash
docker compose down
```

**Podman:**
```bash
podman stop reading-tracker-db
podman rm reading-tracker-db
```

### Stop and remove ALL data (fresh start)

**Docker Compose:**
```bash
docker compose down -v
```

**Podman:**
```bash
podman stop reading-tracker-db
podman rm -v reading-tracker-db
```

### View logs

**Docker Compose:**
```bash
docker compose logs -f postgres
```

**Podman:**
```bash
podman logs -f reading-tracker-db
```

### Connect to database with psql

**Docker Compose:**
```bash
docker compose exec postgres psql -U reading_user -d reading_tracker
```

**Podman:**
```bash
podman exec -it reading-tracker-db psql -U reading_user -d reading_tracker
```

### Run SQL file

**Docker Compose:**
```bash
docker compose exec -T postgres psql -U reading_user -d reading_tracker < your-file.sql
```

**Podman:**
```bash
podman exec -i reading-tracker-db psql -U reading_user -d reading_tracker < your-file.sql
```

### Backup database

**Docker Compose:**
```bash
docker compose exec -T postgres pg_dump -U reading_user reading_tracker > backup.sql
```

**Podman:**
```bash
podman exec reading-tracker-db pg_dump -U reading_user reading_tracker > backup.sql
```

### Restore database

**Docker Compose:**
```bash
docker compose exec -T postgres psql -U reading_user reading_tracker < backup.sql
```

**Podman:**
```bash
podman exec -i reading-tracker-db psql -U reading_user reading_tracker < backup.sql
```

---

## Database Info

- **Host:** localhost
- **Port:** 5432
- **Database:** reading_tracker
- **User:** reading_user
- **Password:** reading_pass
- **Connection String:** `postgresql://reading_user:reading_pass@localhost:5432/reading_tracker`

---

## Troubleshooting

### Port already in use
If port 5432 is already taken:
```bash
# Check what's using port 5432
sudo lsof -i :5432

# Kill the process or change docker-compose.yml ports to "5433:5432"
```

### Reset database completely
```bash
docker compose down -v
docker compose up -d
```

### View database size

**Docker Compose:**
```bash
docker compose exec postgres psql -U reading_user -d reading_tracker -c "SELECT pg_size_pretty(pg_database_size('reading_tracker'));"
```

**Podman:**
```bash
podman exec reading-tracker-db psql -U reading_user -d reading_tracker -c "SELECT pg_size_pretty(pg_database_size('reading_tracker'));"
```

---

## Initial Schema

The database is automatically initialized with:
- ✅ `books` table
- ✅ `reading_sessions` table
- ✅ Indexes for performance
- ✅ Sample data (3 books for testing)

Schema details are in `init-db.sql`.

---

## Development Workflow

1. Start Docker: `docker compose up -d`
2. Start backend: `cd reading-tracker-backend && npm run dev`
3. Start frontend: `cd reading-tracker-frontend && npm run dev`
4. Code away! 🚀

Database persists between restarts unless you use `docker compose down -v`.
