# Reading Tracker - Backend

Node.js + Express API for the Reading Tracker application.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file (see `.env.example`)

3. Initialize database with schema from `../docs/reading-tracker-detailed-architecture.md`

4. Start development server:
```bash
npm run dev
```

## API Endpoints

### Health Check
- `GET /api/health` - Basic health check
- `GET /api/db-health` - Database connection check

### Books (To be implemented)
- `GET /api/books` - List all books
- `POST /api/books` - Add new book
- `GET /api/books/:id` - Get book details
- `PUT /api/books/:id` - Update book
- `DELETE /api/books/:id` - Delete book
- `GET /api/books/search?q=` - Search external APIs

### Reading Sessions (To be implemented)
- `GET /api/reading` - Get all sessions
- `POST /api/reading` - Create session
- `PUT /api/reading/:id` - Update session

### Statistics (To be implemented)
- `GET /api/stats/dashboard` - Dashboard overview
- `GET /api/stats/monthly` - Monthly reading stats
- `GET /api/stats/genres` - Genre breakdown
