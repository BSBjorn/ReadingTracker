# Environment Configuration Guide

## Overview

This document explains how to configure environment variables for development and production environments, and resolves the port discrepancy between development (5173) and Docker (8080) setups.

---

## Quick Fix Summary

### Issues Resolved ✅

1. **Database Connection Error** - PostgreSQL container wasn't running
2. **CORS Port Mismatch** - Backend was configured for port 8080 instead of 5173 (Vite dev server)

### What Was Fixed

- ✅ Updated `backend/.env` to use `CORS_ORIGIN=http://localhost:5173`
- ✅ Started PostgreSQL container with `./db.sh start`
- ✅ Updated `.env.example` files with proper documentation

---

## Environment Variables by Mode

### 🔧 Development Mode (npm run dev)

When running locally with `npm run dev`:

**Frontend runs on:** `http://localhost:5173` (Vite default)
**Backend runs on:** `http://localhost:3000`
**Database:** `localhost:5432` (local PostgreSQL container)

#### Backend `.env`
```env
DATABASE_URL=postgresql://reading_user:reading_pass@localhost:5432/reading_tracker
PORT=3000
CORS_ORIGIN=http://localhost:5173
NODE_ENV=development
GOOGLE_BOOKS_API_KEY=
```

#### Frontend `.env`
```env
VITE_API_URL=http://localhost:3000/api
```

---

### 🐳 Docker Mode (docker-compose up)

When running with Docker Compose:

**Frontend runs on:** `http://localhost:8080` (nginx in container)
**Backend runs on:** `http://localhost:3000`
**Database:** `postgres:5432` (Docker network)

#### `.env.production` (root directory)
```env
CORS_ORIGIN=http://localhost:8080
NODE_ENV=production
VITE_API_URL=/api
GOOGLE_BOOKS_API_KEY=your_key_here
```

**Note:** In Docker mode, the frontend is built statically and served by nginx. API requests go through nginx proxy to backend.

---

## Port Reference

| Service | Development | Docker | Notes |
|---------|-------------|--------|-------|
| **Frontend** | 5173 | 8080 | Vite dev server vs nginx |
| **Backend** | 3000 | 3000 | Same in both modes |
| **Database** | 5432 | 5432 | Exposed to host |

---

## Configuration Files

### Backend Environment Variables

**File:** `backend/.env`

| Variable | Development | Docker | Description |
|----------|-------------|--------|-------------|
| `DATABASE_URL` | `localhost:5432` | `postgres:5432` | Database connection |
| `PORT` | `3000` | `3000` | Backend server port |
| `CORS_ORIGIN` | `http://localhost:5173` | `http://localhost:8080` | Frontend URL |
| `NODE_ENV` | `development` | `production` | Environment mode |
| `GOOGLE_BOOKS_API_KEY` | (optional) | (optional) | External API key |

### Frontend Environment Variables

**File:** `frontend/.env`

| Variable | Development | Docker | Description |
|----------|-------------|--------|-------------|
| `VITE_API_URL` | `http://localhost:3000/api` | `/api` | Backend API URL |

**Important:** In Docker, `/api` uses nginx reverse proxy to route to backend container.

---

## Setup Instructions

### Initial Setup (First Time)

1. **Copy example files:**
   ```bash
   cd /home/bamfjord/Projects/ReadingTracker
   cp backend/.env.example backend/.env
   cp frontend/.env.example frontend/.env
   ```

2. **Start PostgreSQL:**
   ```bash
   ./db.sh start
   ```

3. **Verify database is running:**
   ```bash
   ./db.sh status
   # Should show: ✅ PostgreSQL is running
   ```

4. **Install dependencies:**
   ```bash
   cd backend && npm install
   cd ../frontend && npm install
   ```

---

## Running the Application

### Method 1: Development Mode (Recommended for Development)

**Terminal 1 - Database:**
```bash
./db.sh start
./db.sh status  # Verify it's running
```

**Terminal 2 - Backend:**
```bash
cd backend
npm run dev
# Server running on http://localhost:3000
```

**Terminal 3 - Frontend:**
```bash
cd frontend
npm run dev
# Frontend running on http://localhost:5173
```

**Access Application:**
- Frontend: http://localhost:5173
- Backend API: http://localhost:3000/api
- Health Check: http://localhost:3000/api/health

---

### Method 2: Docker Mode (Production-like)

**Important:** For Docker mode, you need to create `.env.production`:

```bash
cat > .env.production << 'EOF'
CORS_ORIGIN=http://localhost:8080
NODE_ENV=production
VITE_API_URL=/api
GOOGLE_BOOKS_API_KEY=
EOF
```

**Start all services:**
```bash
docker-compose up -d
```

**Access Application:**
- Frontend: http://localhost:8080
- Backend API: http://localhost:3000/api (or through nginx at http://localhost:8080/api)

**View logs:**
```bash
docker-compose logs -f
```

**Stop services:**
```bash
docker-compose down
```

---

## Switching Between Modes

### Switching to Development Mode

1. Stop Docker containers (if running):
   ```bash
   docker-compose down
   ```

2. Update `backend/.env`:
   ```bash
   CORS_ORIGIN=http://localhost:5173
   NODE_ENV=development
   ```

3. Update `frontend/.env`:
   ```bash
   VITE_API_URL=http://localhost:3000/api
   ```

4. Start PostgreSQL container:
   ```bash
   ./db.sh start
   ```

5. Run dev servers as shown above

---

### Switching to Docker Mode

1. Stop dev servers (Ctrl+C in terminals)

2. Stop standalone database:
   ```bash
   ./db.sh stop
   ```

3. Create/update `.env.production`:
   ```bash
   CORS_ORIGIN=http://localhost:8080
   NODE_ENV=production
   VITE_API_URL=/api
   ```

4. Start Docker Compose:
   ```bash
   docker-compose up -d
   ```

---

## Common Issues & Solutions

### Issue: ECONNREFUSED on port 5432

**Cause:** PostgreSQL container is not running

**Solution:**
```bash
./db.sh start
./db.sh status  # Verify
```

---

### Issue: CORS errors in browser console

**Cause:** Backend CORS_ORIGIN doesn't match frontend URL

**Solutions:**

For development (Vite on 5173):
```bash
# In backend/.env
CORS_ORIGIN=http://localhost:5173
```

For Docker (nginx on 8080):
```bash
# In .env.production or docker-compose.yaml
CORS_ORIGIN=http://localhost:8080
```

**Restart backend after changing:**
```bash
# If using npm run dev: Ctrl+C and restart
# If using Docker: docker-compose restart backend
```

---

### Issue: Frontend shows "Network Error" or can't connect to API

**Cause:** Frontend is pointing to wrong API URL

**Solutions:**

For development:
```bash
# In frontend/.env
VITE_API_URL=http://localhost:3000/api
```

For Docker:
```bash
# In frontend/.env or build args
VITE_API_URL=/api
```

**Important:** After changing Vite environment variables, you must restart the dev server or rebuild:
```bash
# Development: Ctrl+C and npm run dev
# Docker: docker-compose up --build
```

---

### Issue: Port 5173 or 3000 already in use

**Check what's using the port:**
```bash
sudo lsof -i :5173  # or :3000
```

**Kill the process or use a different port:**
```bash
# Use different port for Vite
npm run dev -- --port 5174

# Update backend/.env
CORS_ORIGIN=http://localhost:5174
```

---

### Issue: Database connection works in dev but not in Docker

**Cause:** In Docker, services use Docker network names, not `localhost`

**Solution:** Docker Compose automatically sets this via environment variables:
```yaml
environment:
  DATABASE_URL: postgresql://reading_user:reading_pass@postgres:5432/reading_tracker
```

Note: `postgres` is the service name, not `localhost`

---

## Best Practices

### 1. Never Commit .env Files
```bash
# .gitignore already includes:
.env
.env.local
.env.production
.env.*.local
```

### 2. Keep .env.example Updated
When adding new environment variables, update the example files:
- `backend/.env.example`
- `frontend/.env.example`

### 3. Use Different Credentials in Production
For production deployment (Coolify), use strong passwords:
```env
DATABASE_URL=postgresql://prod_user:STRONG_PASSWORD@db.host/prod_db
```

### 4. API Keys
Never commit API keys. For Google Books API:
- Development: Optional (rate limited but works)
- Production: Highly recommended (get free key from Google Cloud Console)

---

## Environment Variable Loading

### Backend (Node.js + Express)
- Uses `dotenv` package
- Loads from `backend/.env`
- Accessed via `process.env.VARIABLE_NAME`

### Frontend (Vue + Vite)
- Vite automatically loads `.env` files
- Only variables starting with `VITE_` are exposed
- Accessed via `import.meta.env.VITE_VARIABLE_NAME`
- **Important:** Env vars are embedded at build time, not runtime

---

## Testing Configuration

### Test Backend Connection
```bash
# Health check
curl http://localhost:3000/api/health

# Database health check
curl http://localhost:3000/api/db-health

# Should return JSON with status: "ok"
```

### Test Frontend Connection
1. Open http://localhost:5173 (or :8080 in Docker)
2. Open browser DevTools (F12)
3. Check Console for errors
4. Check Network tab for API requests

### Test Database
```bash
# Connect to database
./db.sh psql

# Inside psql:
SELECT * FROM books;
\q
```

---

## Quick Reference Commands

```bash
# Database Management
./db.sh start       # Start PostgreSQL
./db.sh stop        # Stop PostgreSQL
./db.sh status      # Check status
./db.sh psql        # Connect to database
./db.sh logs        # View logs

# Development
cd backend && npm run dev
cd frontend && npm run dev

# Docker
docker-compose up -d           # Start all services
docker-compose down            # Stop all services
docker-compose logs -f         # View logs
docker-compose restart backend # Restart backend
docker-compose up --build      # Rebuild and start
```

---

## Summary

The key difference between development and Docker modes is the **port the frontend runs on**:

- **Development (npm run dev):** Frontend on 5173, direct API calls to localhost:3000
- **Docker (docker-compose up):** Frontend on 8080 (nginx), API proxied through nginx

Always ensure your backend `CORS_ORIGIN` matches your frontend URL!

---

## Need Help?

1. Check `./db.sh status` - Is database running?
2. Check `backend/.env` - Does CORS_ORIGIN match frontend port?
3. Check `frontend/.env` - Does VITE_API_URL point to backend?
4. Check browser DevTools Console - Any CORS or network errors?
5. Check backend terminal - Any error messages?

For more detailed documentation, see:
- `DATABASE_SETUP.md` - Database configuration
- `SETUP_INSTRUCTIONS.md` - Full setup guide
- `GETTING_STARTED.md` - Quick start guide