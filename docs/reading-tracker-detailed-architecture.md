# Reading Tracker - Software Architecture

## Overview
A web application for tracking personal reading habits with automated book data retrieval and reading statistics.

---

## Architecture Components

### 1. Frontend (Client Layer)
**Technology:** React or Vue.js

**Key Features:**
- Book registration form (manual entry + API search)
- Reading session tracker (start/finish dates)
- Dashboard with statistics and visualizations
- Simple, clean interface

**Pages:**
- Home/Dashboard (statistics overview)
- My Books (list/grid view with filters)
- Add Book (search API or manual entry)
- Book Details (reading history for specific book)

---

### 2. Backend (Application Layer)
**Technology:** Node.js + Express OR Python + FastAPI

**Core Services:**

#### API Endpoints
```
GET    /api/books              # List all books
POST   /api/books              # Add new book (manual or from API)
GET    /api/books/:id          # Get book details
PUT    /api/books/:id          # Update book info
DELETE /api/books/:id          # Remove book

GET    /api/books/search?q=    # Search external APIs for book data

POST   /api/reading            # Start/log reading session
GET    /api/reading            # Get all reading sessions
PUT    /api/reading/:id        # Update session (e.g., finish date)

GET    /api/stats/dashboard    # Dashboard statistics
GET    /api/stats/monthly      # Pages per month
GET    /api/stats/genres       # Genre breakdown
```

#### External Book APIs Integration
- **Google Books API** (primary - free, comprehensive)
- **Open Library API** (fallback - also free)

Fetches: title, author, page count, genres, cover image, ISBN

---

### 3. Database Layer
**Technology:** PostgreSQL (or SQLite for simpler setup)

**Schema:**

```sql
-- Books Table
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255),
    pages INTEGER,
    genres TEXT[],
    isbn VARCHAR(20),
    cover_url VARCHAR(500),
    source VARCHAR(20), -- 'manual' or 'google_books' or 'open_library'
    created_at TIMESTAMP DEFAULT NOW()
);

-- Reading Sessions Table
CREATE TABLE reading_sessions (
    id SERIAL PRIMARY KEY,
    book_id INTEGER REFERENCES books(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    finish_date DATE,
    status VARCHAR(20) DEFAULT 'reading', -- 'reading', 'finished', 'abandoned'
    created_at TIMESTAMP DEFAULT NOW()
);

-- Optional: Users Table (for future multi-user support)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);
```

---

### 4. Caching Layer (Optional but Recommended)
**Technology:** Redis

**Purpose:**
- Cache dashboard statistics (refresh every hour or on-demand)
- Cache external API responses (reduce API calls)

---

## Data Flow Examples

### Adding a Book
1. User searches for book title in UI
2. Frontend calls `GET /api/books/search?q=title`
3. Backend queries Google Books API
4. Returns list of matches to frontend
5. User selects book or enters manually
6. Frontend sends `POST /api/books` with book data
7. Backend stores in database

### Viewing Dashboard
1. User navigates to dashboard
2. Frontend calls `GET /api/stats/dashboard`
3. Backend checks Redis cache
4. If cache miss: calculates from database, stores in cache
5. Returns statistics (total books, pages read, current month stats, top genres)
6. Frontend renders charts/visualizations

---

## Statistics Calculations

### Pages Per Month
```sql
SELECT 
    DATE_TRUNC('month', finish_date) as month,
    SUM(b.pages) as total_pages
FROM reading_sessions rs
JOIN books b ON rs.book_id = b.id
WHERE rs.finish_date IS NOT NULL
GROUP BY month
ORDER BY month DESC;
```

### Most Popular Genre
```sql
SELECT 
    UNNEST(genres) as genre,
    COUNT(*) as count
FROM books b
JOIN reading_sessions rs ON b.id = rs.book_id
WHERE rs.finish_date IS NOT NULL
GROUP BY genre
ORDER BY count DESC;
```

---

## Deployment on Coolify

### Project Structure
```
reading-tracker/
├── frontend/          # Vue.js app
├── backend/           # Node.js Express API
└── docker-compose.yml # For local development (optional)
```

### Coolify Setup

**Three Services to Deploy:**

1. **PostgreSQL Database**
   - Use Coolify's one-click PostgreSQL service
   - Note the connection details (host, port, database, user, password)
   - Or use existing PostgreSQL instance on your server

2. **Backend API**
   - Deploy as Node.js application
   - Set environment variables:
     ```
     DATABASE_URL=postgresql://user:password@postgres:5432/reading_tracker
     PORT=3000
     GOOGLE_BOOKS_API_KEY=your_key (optional, API works without)
     NODE_ENV=production
     CORS_ORIGIN=https://your-frontend-domain.com
     ```
   - Build command: `npm install`
   - Start command: `npm start`

3. **Vue Frontend**
   - Deploy as static site or Node app
   - Set environment variable:
     ```
     VITE_API_URL=https://your-backend-domain.com/api
     ```
   - Build command: `npm run build`
   - Serve from `dist/` folder

### Docker Setup (Optional)

If you prefer Docker deployment, you can create Dockerfiles:

**Backend Dockerfile:**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

**Frontend Dockerfile:**
```dockerfile
FROM node:18-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Networking in Coolify
- Backend and PostgreSQL can communicate via internal network
- Frontend makes API calls to backend via public URL
- Set up SSL certificates through Coolify for both frontend and backend

---

## Tech Stack (Final)

- **Frontend:** Vue.js 3 + Chart.js (for visualizations)
- **Backend:** Node.js + Express
- **Database:** PostgreSQL
- **Deployment:** Coolify (self-hosted)
- **Cache (optional):** Redis

---

## Next Steps

1. **Setup Project Structure**
   - Initialize frontend and backend repos
   - Set up database (local or cloud)

2. **Core Features First**
   - Book CRUD operations
   - Manual book entry
   - Basic reading session tracking

3. **Enhancements**
   - External API integration
   - Dashboard statistics
   - Data visualizations

4. **Polish**
   - UI/UX improvements
   - Caching
   - Error handling

---

## Security Considerations

- Input validation on all forms
- SQL injection prevention (use parameterized queries)
- Rate limiting on external API calls
- CORS configuration for frontend-backend communication
- Optional: Add authentication if you want to access from multiple devices
