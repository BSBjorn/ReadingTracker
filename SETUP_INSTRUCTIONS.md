# Reading Tracker - Project Setup Instructions

## Project Overview
A web application for tracking personal reading habits with automated book data retrieval and reading statistics visualization.

**Tech Stack:**
- Frontend: Vue.js 3 + Chart.js
- Backend: Node.js + Express
- Database: PostgreSQL
- Deployment: Coolify (self-hosted)

---

## Repository Structure

This project consists of two separate Git repositories:

1. **reading-tracker-backend** - Node.js Express API
2. **reading-tracker-frontend** - Vue.js 3 application

---

## Prerequisites

- Node.js 18+ and npm
- PostgreSQL database
- Git
- (Optional) Google Books API key

---

## Backend Setup

### 1. Navigate to backend directory
```bash
cd reading-tracker-backend
```

### 2. Install dependencies
```bash
npm install
```

### 3. Configure environment variables
Create `.env` file with:
```
DATABASE_URL=postgresql://user:password@localhost:5432/reading_tracker
PORT=3000
CORS_ORIGIN=http://localhost:5173
NODE_ENV=development
GOOGLE_BOOKS_API_KEY=your_key_here  # Optional
```

### 4. Initialize database
Run the SQL schema found in `docs/reading-tracker-detailed-architecture.md`

### 5. Start development server
```bash
npm run dev
```

Backend will run on http://localhost:3000

---

## Frontend Setup

### 1. Navigate to frontend directory
```bash
cd reading-tracker-frontend
```

### 2. Install dependencies
```bash
npm install
```

### 3. Configure environment variables
Create `.env` file with:
```
VITE_API_URL=http://localhost:3000/api
```

### 4. Start development server
```bash
npm run dev
```

Frontend will run on http://localhost:5173

---

## Database Schema

### Books Table
Stores book information (title, author, pages, genres, ISBN, cover URL)

### Reading Sessions Table
Tracks reading progress (start date, finish date, status)

### Key Features
- Foreign key relationship: reading_sessions.book_id → books.id
- Cascading deletes
- Indexes on frequently queried columns

---

## API Endpoints

### Books
- `GET /api/books` - List all books
- `POST /api/books` - Add new book
- `GET /api/books/:id` - Get book details
- `PUT /api/books/:id` - Update book
- `DELETE /api/books/:id` - Delete book
- `GET /api/books/search?q=` - Search external APIs

### Reading Sessions
- `GET /api/reading` - Get all sessions
- `POST /api/reading` - Create session
- `PUT /api/reading/:id` - Update session

### Statistics
- `GET /api/stats/dashboard` - Dashboard overview
- `GET /api/stats/monthly` - Monthly reading stats
- `GET /api/stats/genres` - Genre breakdown

---

## Deployment to Coolify

### Step 1: Push to Git Repositories
Both backend and frontend should be in separate Git repositories.

### Step 2: Create PostgreSQL Database
1. In Coolify dashboard, create PostgreSQL service
2. Note connection string

### Step 3: Deploy Backend
1. Create new application from Git (backend repo)
2. Set environment variables (DATABASE_URL, PORT, CORS_ORIGIN, NODE_ENV)
3. Build command: `npm install`
4. Start command: `npm start`
5. Deploy

### Step 4: Deploy Frontend
1. Create new application from Git (frontend repo)
2. Set environment variable: VITE_API_URL
3. Build command: `npm run build`
4. Publish directory: `dist`
5. Deploy

---

## Development Workflow

### Local Development
Run three terminals:
1. Backend: `npm run dev` in reading-tracker-backend
2. Frontend: `npm run dev` in reading-tracker-frontend
3. PostgreSQL: Running locally or via Docker

### Making Changes
1. Develop and test locally
2. Commit and push to Git
3. Coolify auto-deploys (if configured) or trigger manually

---

## Project Structure

### Backend
```
reading-tracker-backend/
├── server.js
├── package.json
├── .env
├── .gitignore
├── routes/
│   ├── books.js
│   ├── reading.js
│   └── stats.js
├── controllers/
│   ├── bookController.js
│   ├── readingController.js
│   └── statsController.js
└── services/
    └── bookApiService.js
```

### Frontend
```
reading-tracker-frontend/
├── src/
│   ├── components/
│   │   ├── BookCard.vue
│   │   ├── BookForm.vue
│   │   ├── ReadingSessionForm.vue
│   │   └── StatsChart.vue
│   ├── views/
│   │   ├── Dashboard.vue
│   │   ├── BooksView.vue
│   │   └── AddBookView.vue
│   ├── stores/
│   │   └── books.js
│   ├── services/
│   │   └── api.js
│   └── router/
│       └── index.js
├── package.json
├── .env
└── .gitignore
```

---

## Next Steps

1. ✅ Scaffold project structure
2. ✅ Initialize Git repositories
3. ⏳ Set up basic backend with health check
4. ⏳ Set up basic frontend with routing
5. ⏳ Implement book CRUD endpoints
6. ⏳ Implement reading session tracking
7. ⏳ Add Google Books API integration
8. ⏳ Create dashboard with statistics
9. ⏳ Add data visualizations
10. ⏳ Deploy to Coolify

---

## External API Integration

### Google Books API
- Free tier available (no key needed for basic usage)
- Rate limited without API key
- Provides: title, author, page count, genres, cover images, ISBN

### Open Library API (Fallback)
- Completely free
- No API key required
- Similar data to Google Books

---

## Security Notes

- Input validation on all endpoints
- Parameterized SQL queries (prevents SQL injection)
- CORS configuration for frontend-backend communication
- Rate limiting on external API calls
- Environment variables for sensitive data

---

## Support & Documentation

- Architecture details: `docs/reading-tracker-detailed-architecture.md`
- Quick start guide: `docs/reading-tracker-quickstart.md`
- Architecture diagram: `docs/reading-tracker-architecture.mermaid`

---

Happy coding! 🚀📚
