# Monorepo Setup Documentation

## Overview
The Reading Tracker project has been converted from separate repositories to a **monorepo** structure for easier management and deployment.

## What Changed

### Before (Multi-Repo)
```
reading-tracker-backend/  (separate git repo)
  ├── .git/
  └── ...
reading-tracker-frontend/ (separate git repo)
  ├── .git/
  └── ...
```

### After (Monorepo)
```
ReadingTracker/            (single git repo)
  ├── .git/
  ├── backend/
  ├── frontend/
  └── ...
```

## Benefits

### 🚀 **Deployment**
- **Single repository** to connect to Coolify
- **Coordinated deployments** - Backend and frontend versions stay in sync
- **Easier CI/CD** - One configuration for both services

### 💻 **Development**
- **Atomic commits** - API changes and UI changes in same commit
- **Single git history** - Track full feature evolution
- **Simpler workflow** - One clone, one pull, one push
- **Shared tooling** - Common linting, formatting, CI/CD configs

### 📦 **Project Management**
- **Unified versioning** - Tag releases for the entire app
- **Centralized documentation** - All docs in one place
- **Single issue tracker** - When using GitHub/GitLab
- **Easier onboarding** - New developers clone once

## Structure

```
ReadingTracker/
├── .git/                   # Single git repository
├── .gitignore             # Monorepo-wide gitignore
├── README.md              # Main project README
│
├── backend/               # Express.js API
│   ├── config/
│   ├── routes/
│   ├── services/
│   ├── .env.example
│   ├── package.json
│   └── server.js
│
├── frontend/              # Vue 3 SPA
│   ├── src/
│   ├── public/
│   ├── .env.example
│   ├── package.json
│   └── vite.config.js
│
├── docs/                  # Original documentation
├── migrations/            # Database migrations
├── docker-compose.yml     # PostgreSQL setup
├── init-db.sql           # Database schema
├── db.sh                 # Database helper script
└── *.md                  # Feature documentation
```

## Git Workflow

### Commits
Changes to frontend and backend can be committed together:

```bash
# Make changes to both frontend and backend
git add backend/routes/books.js
git add frontend/src/views/BooksView.vue
git commit -m "Add reading statistics feature

- Backend: Add /api/stats/reading endpoint
- Frontend: Add stats display to dashboard"
```

### Branches
Create feature branches for coordinated changes:

```bash
git checkout -b feature/reading-stats
# Work on backend
# Work on frontend
git commit -m "Complete reading statistics feature"
git push origin feature/reading-stats
```

### Versioning
Tag releases for the entire application:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

## Development Workflow

### Initial Setup
```bash
# Clone once
git clone <your-repo-url>
cd ReadingTracker

# Setup backend
cd backend
npm install
cp .env.example .env

# Setup frontend
cd ../frontend
npm install
cp .env.example .env

# Start database
cd ..
./db.sh start
```

### Daily Development
```bash
# Pull latest changes
git pull

# Terminal 1: Backend
cd backend
npm run dev

# Terminal 2: Frontend
cd frontend
npm run dev

# Make changes, commit both
git add .
git commit -m "Your changes"
git push
```

## Coolify Deployment

### Configuration

**Repository Setup:**
1. Connect your git repository to Coolify
2. Select the `main` branch

**Backend Service:**
- **Root Directory:** `/backend`
- **Build Command:** `npm install`
- **Start Command:** `npm start` or `node server.js`
- **Port:** 3000
- **Environment Variables:**
  - `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`
  - `PORT=3000`
  - `NODE_ENV=production`

**Frontend Service:**
- **Root Directory:** `/frontend`
- **Build Command:** `npm install && npm run build`
- **Start Command:** (serve from `dist/` folder)
- **Port:** 80 (or serve as static files)
- **Environment Variables:**
  - `VITE_API_URL=https://your-backend-url.com/api`

**Database:**
- Use Coolify's managed PostgreSQL service
- Or connect to external PostgreSQL instance

### Deployment Strategies

**Strategy 1: Monolithic Deployment**
Deploy both as one service, serving frontend from backend:
```javascript
// backend/server.js
app.use(express.static(path.join(__dirname, '../frontend/dist')));
```

**Strategy 2: Separate Services** (Recommended)
Deploy as two separate Coolify services from same repo:
- Service 1: Backend API (from `/backend`)
- Service 2: Frontend SPA (from `/frontend`)

**Strategy 3: Static Frontend**
- Backend: Coolify service
- Frontend: Build and serve via CDN/nginx

## CI/CD Considerations

### GitHub Actions Example
```yaml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - working-directory: ./backend
        run: |
          npm install
          npm test
          # Deploy to Coolify

  deploy-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - working-directory: ./frontend
        run: |
          npm install
          npm run build
          # Deploy to Coolify
```

### Selective Builds
You can configure CI/CD to only build what changed:
- If only `backend/**` changed → Deploy backend
- If only `frontend/**` changed → Deploy frontend
- If both changed → Deploy both

## Migration Notes

### What Was Preserved
✅ All source code
✅ All dependencies (package.json)
✅ All configuration files
✅ All documentation
✅ Database scripts and migrations

### What Changed
❌ Separate git repositories removed
✅ Combined into single repository
✅ Directories renamed:
  - `reading-tracker-backend` → `backend`
  - `reading-tracker-frontend` → `frontend`

### Git History
The original git histories from the separate repos were not preserved in order to start with a clean monorepo structure. All code and documentation is intact, but commit history starts fresh with the monorepo conversion.

## Best Practices

### Commits
- **Descriptive messages** - Mention which part changed
  ```
  ✅ "Backend: Add date filtering to books endpoint"
  ✅ "Frontend: Update book card styling"
  ✅ "Full-stack: Implement reading statistics feature"
  ❌ "Update stuff"
  ```

### Branches
- Use feature branches for new features
- Use descriptive branch names: `feature/stats`, `fix/date-display`, etc.
- Merge to main via pull requests

### Dependencies
- Keep `package.json` files up to date
- Run `npm audit` regularly in both directories
- Update dependencies together when possible

### Documentation
- Update main README.md for user-facing changes
- Keep feature docs (*.md files) up to date
- Document breaking changes

## Troubleshooting

### Issue: Frontend can't reach backend
**Solution:** Check `VITE_API_URL` in `frontend/.env`

### Issue: Coolify build fails
**Solution:** Ensure correct root directory is set (`/backend` or `/frontend`)

### Issue: Database connection fails
**Solution:** Verify environment variables in Coolify match your database

### Issue: Git conflicts
**Solution:** Pull latest before making changes, use feature branches

## Resources

- [Monorepo Best Practices](https://monorepo.tools/)
- [Coolify Documentation](https://coolify.io/docs)
- [GitHub Monorepo Examples](https://github.com/topics/monorepo)

## Support

For questions or issues:
1. Check this documentation
2. Review README.md
3. Check feature-specific .md files
4. Create an issue in the repository

---

**Migration Date:** 2026-01-25
**Migrated By:** GitHub Copilot CLI
**Status:** ✅ Complete
