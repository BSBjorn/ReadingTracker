## Two Isolated Environments

This project supports **two completely separate environments** to avoid conflicts:

### 🔧 Local Development (Recommended for Coding)
- Database: `reading-tracker-db-dev` on port **5432**
- Backend: `npm run dev` on port **3000**
- Frontend: `npm run dev` on port **5173**
- Use: `./db.sh` + `npm run dev`

### 🐳 Docker Compose (Production Testing)
- Database: `reading-tracker-db` on port **5433**
- Backend: Container on port **3001**
- Frontend: Container on port **8080**
- Use: `podman-compose up -d`

**Both can run simultaneously without conflicts!**

See [DEVELOPMENT.md](DEVELOPMENT.md) for detailed instructions.

---

## Quick Start

### Local Development
```bash
# Terminal 1: Database
./db.sh start

# Terminal 2: Backend
cd backend && npm run dev

# Terminal 3: Frontend
cd frontend && npm run dev

# Access: http://localhost:5173
```

### Docker Mode
```bash
podman-compose up -d
# Access: http://localhost:8080
```

