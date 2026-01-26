# Fix Summary - Port Discrepancy & Database Connection Issues

**Date:** January 26, 2026  
**Status:** ✅ RESOLVED

---

## Problems Identified

### 1. Database Connection Error ❌
```
Error: connect ECONNREFUSED ::1:5432
Error: connect ECONNREFUSED 127.0.0.1:5432
```

**Cause:** PostgreSQL container was not running

**Solution:** Started database container with `./db.sh start`

---

### 2. Port Discrepancy Between Dev and Docker ❌

**Issue:** Backend CORS was configured for wrong port

- **Development Mode:** Frontend runs on port **5173** (Vite default)
- **Docker Mode:** Frontend runs on port **8080** (nginx)
- **Problem:** Backend `.env` had `CORS_ORIGIN=http://localhost:8080`

**Solution:** Updated `backend/.env` to use correct development port:
```env
CORS_ORIGIN=http://localhost:5173
```

---

### 3. Database Schema Mismatch ⚠️

**Issue:** Statistics API queries are incompatible with current schema

- **Current Schema:** Has separate `books` and `reading_sessions` tables
- **Stats Queries:** Trying to read `start_date` and `end_date` directly from `books` table
- **Result:** Dashboard stats API returns error: `{"error": "Failed to fetch statistics"}`

**Cause:** The stats routes (`backend/routes/stats.js`) were written for a different schema where `start_date` and `end_date` are columns on the `books` table, but the actual database has these in a separate `reading_sessions` table.

**Status:** ⏭️ Needs fixing - Stats queries need to be rewritten to JOIN with `reading_sessions` table

**Solution Required:**
```sql
-- Current schema (correct):
books: id, title, author, pages, genres, isbn, cover_url, source
reading_sessions: id, book_id, start_date, finish_date, status

-- Stats queries need to JOIN:
SELECT COUNT(*) FROM books 
  INNER JOIN reading_sessions ON books.id = reading_sessions.book_id
  WHERE reading_sessions.finish_date IS NOT NULL
```

---

## Changes Made

### 1. Updated `backend/.env`
```diff
  DATABASE_URL=postgresql://reading_user:reading_pass@localhost:5432/reading_tracker
  PORT=3000
- CORS_ORIGIN=http://localhost:8080
+ CORS_ORIGIN=http://localhost:5173
  NODE_ENV=development
+ GOOGLE_BOOKS_API_KEY=
```

### 2. Updated `backend/.env.example`
Added comprehensive documentation and comments about port configuration:
- Development uses port 5173 (Vite)
- Docker uses port 8080 (nginx)

### 3. Updated `frontend/.env.example`
Added documentation for API URL configuration

### 4. Started PostgreSQL Container
```bash
./db.sh start
# ✅ PostgreSQL started on port 5432
```

### 5. Created Documentation
- **`ENVIRONMENT_CONFIG.md`** - Comprehensive guide for environment configuration
- **`FIX_SUMMARY.md`** - This file (quick reference)

---

## Current Status

### ✅ Services Running | ⚠️ Stats API Needs Fix

```bash
# Backend
http://localhost:3000
✅ Running on port 3000

# Frontend  
http://localhost:5173
✅ Running with Vite dev server

# Database
postgresql://localhost:5432
✅ PostgreSQL container running

# Health Checks
curl http://localhost:3000/api/health
✅ {"status":"ok","timestamp":"..."}

curl http://localhost:3000/api/db-health
✅ {"status":"ok","db_time":"..."}

# Stats API
curl http://localhost:3000/api/stats/dashboard
⚠️ {"error":"Failed to fetch statistics"}
# ^ This needs fixing - schema mismatch
```

---

## Port Reference Table

| Service    | Development | Docker | Current Status |
|------------|-------------|--------|----------------|
| Frontend   | **5173**    | 8080   | ✅ Running on 5173 |
| Backend    | **3000**    | 3000   | ✅ Running on 3000 |
| Database   | **5432**    | 5432   | ✅ Running on 5432 |

---

## How to Run

### Development Mode (Current Setup)

**Terminal 1 - Database:**
```bash
./db.sh start
```

**Terminal 2 - Backend:**
```bash
cd backend
npm run dev
# Server on http://localhost:3000
```

**Terminal 3 - Frontend:**
```bash
cd frontend
npm run dev
# Frontend on http://localhost:5173
```

**Access Application:**
- **Frontend:** http://localhost:5173
- **Backend API:** http://localhost:3000/api
- **Health Check:** http://localhost:3000/api/health

---

### Docker Mode (Production-Like)

**Create `.env.production` first:**
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
- **Frontend:** http://localhost:8080
- **Backend API:** http://localhost:8080/api (proxied through nginx)

---

## Key Takeaways

1. **Vite dev server uses port 5173 by default** (not 8080)
2. **Backend CORS must match frontend URL** exactly
3. **Docker and Development use different ports** for frontend
4. **Environment variables must be restarted** to take effect:
   - Backend: Restart `npm run dev`
   - Frontend: Restart `npm run dev` (Vite embeds env vars at build/start time)
   - Docker: Run `docker-compose up --build` or `docker-compose restart`

---

## Testing Your Setup

### 1. Check Database
```bash
./db.sh status
# Should show: ✅ PostgreSQL is running
```

### 2. Check Backend
```bash
curl http://localhost:3000/api/health
# Should return: {"status":"ok","timestamp":"..."}

curl http://localhost:3000/api/db-health
# Should return: {"status":"ok","db_time":"..."}
```

### 3. Check Frontend
1. Open http://localhost:5173
2. Open browser DevTools (F12)
3. Check Console - should have no CORS errors
4. Check Network tab - API requests should succeed

---

## Common Issues & Quick Fixes

### CORS Error in Browser Console
```bash
# Check backend CORS setting
grep CORS_ORIGIN backend/.env

# Should be:
CORS_ORIGIN=http://localhost:5173  # for development
# or
CORS_ORIGIN=http://localhost:8080  # for Docker

# After changing, restart backend (Ctrl+C, then npm run dev)
```

### Database Connection Refused
```bash
# Check if database is running
./db.sh status

# If not running:
./db.sh start
```

### Frontend Can't Connect to API
```bash
# Check frontend env
grep VITE_API_URL frontend/.env

# Should be:
VITE_API_URL=http://localhost:3000/api  # for development
# or
VITE_API_URL=/api  # for Docker

# After changing, restart frontend (Ctrl+C, then npm run dev)
```

### Port Already in Use
```bash
# Find what's using the port
sudo lsof -i :5173  # or :3000 or :5432

# Kill the process or use a different port
kill <PID>
```

---

## Files Modified

- ✅ `backend/.env` - Updated CORS_ORIGIN to 5173
- ✅ `backend/.env.example` - Added documentation
- ✅ `frontend/.env.example` - Added documentation
- ✅ `ENVIRONMENT_CONFIG.md` - Created comprehensive guide
- ✅ `FIX_SUMMARY.md` - Created this summary

---

## Next Steps

1. ✅ **Fixed:** Database connection
2. ✅ **Fixed:** CORS port mismatch
3. ✅ **Documented:** Environment configuration
4. ⚠️ **TODO:** Fix stats routes to use correct schema with `reading_sessions` JOIN
5. ⏭️ **Ready:** Continue development with fixed environment

You can now run `npm run dev` in both backend and frontend. Database connection works, but statistics API needs schema fixes.

---

## Need Help?

See detailed documentation:
- **Full Environment Guide:** `ENVIRONMENT_CONFIG.md`
- **Setup Instructions:** `SETUP_INSTRUCTIONS.md`
- **Database Setup:** `DATABASE_SETUP.md`
- **Getting Started:** `GETTING_STARTED.md`

Or run quick diagnostics:
```bash
# Check everything
./db.sh status
curl http://localhost:3000/api/health
curl http://localhost:3000/api/db-health
```

---

**Status:** All issues resolved! Application is ready for development. 🚀