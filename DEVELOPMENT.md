# Development Guide

## Two Separate Environments

This project supports two completely isolated environments to avoid conflicts.

---

## 🔧 Local Development Mode (Recommended for Coding)

**Ports:**
- Database: `5432` (container: `reading-tracker-db-dev`)
- Backend: `3000` (npm run dev)
- Frontend: `5173` (npm run dev)

### Setup

```bash
# 1. Start development database
./db.sh start

# 2. Install dependencies (first time only)
cd backend && npm install
cd frontend && npm install

# 3. Configure environment (first time only)
cd backend
cp .env.example .env
# Edit .env if needed (defaults should work)

cd frontend
cp .env.example .env
# Edit .env if needed (defaults should work)
```

### Daily Workflow

```bash
# Terminal 1: Database
./db.sh start
./db.sh status  # Check it's running

# Terminal 2: Backend
cd backend
npm run dev
# Runs on http://localhost:3000

# Terminal 3: Frontend
cd frontend
npm run dev
# Runs on http://localhost:5173
```

### Database Commands

```bash
./db.sh status    # Check status
./db.sh psql      # Connect to database
./db.sh logs      # View logs
./db.sh stop      # Stop database
./db.sh restart   # Restart database
./db.sh reset     # Fresh start (deletes data)
./db.sh info      # Show connection info
```

### Benefits
- ✅ Hot reload for code changes
- ✅ Direct console output
- ✅ Easy debugging
- ✅ Faster iteration

---

## 🐳 Docker Compose Mode (Production-Like Testing)

**Ports:**
- Database: `5433` (container: `reading-tracker-db`)
- Backend: `3001` (container: `reading-tracker-backend`)
- Frontend: `8080` (container: `reading-tracker-frontend`)

### Setup

```bash
# 1. Create production environment file
cp .env.production .env.production.local
# Edit if needed

# 2. Build and start all services
podman-compose up --build -d
```

### Daily Workflow

```bash
# Start all services
podman-compose up -d

# View logs
podman-compose logs -f

# Stop all services
podman-compose down
```

### Commands

```bash
podman-compose ps              # Check status
podman-compose logs -f         # View logs
podman-compose restart backend # Restart service
podman-compose down            # Stop all
podman-compose up --build -d   # Rebuild and start
```

### Benefits
- ✅ Tests Docker builds
- ✅ Production-like environment
- ✅ Tests nginx configuration
- ✅ All services containerized

---

## 🔄 Switching Between Modes

### From Docker to Local Dev

```bash
# Stop Docker services
podman-compose down

# Start local dev
./db.sh start
cd backend && npm run dev
cd frontend && npm run dev
```

### From Local Dev to Docker

```bash
# Stop local services (Ctrl+C in terminals)
./db.sh stop

# Start Docker services
podman-compose up -d
```

---

## 📊 Port Summary

| Service | Local Dev | Docker Compose |
|---------|-----------|----------------|
| Database | 5432 | 5433 |
| Backend | 3000 | 3001 |
| Frontend | 5173 | 8080 |
| Database Container | `reading-tracker-db-dev` | `reading-tracker-db` |

---

## 🐛 Troubleshooting

### "Container name already in use"

This error happens if you try to run both modes simultaneously.

**Solution:**
```bash
# Check what's running
podman ps

# Stop Docker Compose
podman-compose down

# OR stop local dev
./db.sh stop

# Then choose one mode
```

### "Port already in use"

**Solution:**
```bash
# Find what's using the port
sudo lsof -i :5432  # or :3000, :5173, etc.

# Kill the process or stop the service
```

### CORS Errors

Make sure backend `.env` has correct CORS_ORIGIN:
- Local dev: `http://localhost:5173`
- Docker: `http://localhost:8080`

### Database Connection Refused

**Local dev:**
```bash
./db.sh status
./db.sh start  # if not running
```

**Docker:**
```bash
podman-compose ps
podman-compose up -d  # if not running
```

---

## 💡 Tips

- **Use local dev** for day-to-day coding (faster, hot reload)
- **Use Docker** before deploying (test production build)
- **Don't run both at once** to avoid conflicts
- **Check status first**: `./db.sh status` or `podman-compose ps`
- **Environment changes require restart** (Ctrl+C and restart npm/docker)

---

## 📝 Quick Commands Cheat Sheet

```bash
# LOCAL DEV
./db.sh start && cd backend && npm run dev   # Start backend
cd frontend && npm run dev                   # Start frontend
./db.sh psql                                 # Database console

# DOCKER
podman-compose up -d                         # Start all
podman-compose logs -f                       # View logs
podman-compose down                          # Stop all

# STATUS CHECK
./db.sh status                               # Check dev database
podman-compose ps                            # Check Docker services
podman ps                                    # All containers
```

---

**Happy coding! 🚀**
