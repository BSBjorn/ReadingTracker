# Reading Tracker - Quick Start Guide

## Project Setup

### 1. Backend Setup (Node.js + Express)

```bash
mkdir reading-tracker-backend
cd reading-tracker-backend
npm init -y
npm install express pg cors dotenv
npm install --save-dev nodemon
```

**Create `server.js`:**
```javascript
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// Middleware
app.use(cors({ origin: process.env.CORS_ORIGIN }));
app.use(express.json());

// Test route
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Start server
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
```

**Update `package.json` scripts:**
```json
"scripts": {
  "start": "node server.js",
  "dev": "nodemon server.js"
}
```

**Create `.env` file:**
```
DATABASE_URL=postgresql://user:password@localhost:5432/reading_tracker
PORT=3000
CORS_ORIGIN=http://localhost:5173
NODE_ENV=development
```

---

### 2. Frontend Setup (Vue.js 3)

```bash
npm create vue@latest reading-tracker-frontend
cd reading-tracker-frontend
npm install
npm install axios chart.js vue-chartjs
```

When prompted:
- TypeScript: No (unless you want it)
- JSX: No
- Vue Router: Yes
- Pinia: Yes (for state management)
- ESLint: Yes

**Create `.env` file:**
```
VITE_API_URL=http://localhost:3000/api
```

**Update `src/main.js`:**
```javascript
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.mount('#app')
```

---

### 3. Database Setup

**Connect to PostgreSQL and run:**

```sql
CREATE DATABASE reading_tracker;

\c reading_tracker

CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255),
    pages INTEGER,
    genres TEXT[],
    isbn VARCHAR(20),
    cover_url VARCHAR(500),
    source VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE reading_sessions (
    id SERIAL PRIMARY KEY,
    book_id INTEGER REFERENCES books(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    finish_date DATE,
    status VARCHAR(20) DEFAULT 'reading',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Useful indexes
CREATE INDEX idx_reading_sessions_book_id ON reading_sessions(book_id);
CREATE INDEX idx_reading_sessions_finish_date ON reading_sessions(finish_date);
```

---

### 4. Project Structure

**Backend:**
```
reading-tracker-backend/
├── server.js
├── package.json
├── .env
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

**Frontend:**
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
└── .env
```

---

### 5. Basic API Client (Frontend)

**Create `src/services/api.js`:**
```javascript
import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const bookApi = {
  getAll: () => api.get('/books'),
  getOne: (id) => api.get(`/books/${id}`),
  create: (data) => api.post('/books', data),
  update: (id, data) => api.put(`/books/${id}`, data),
  delete: (id) => api.delete(`/books/${id}`),
  search: (query) => api.get(`/books/search?q=${query}`),
};

export const readingApi = {
  getAll: () => api.get('/reading'),
  create: (data) => api.post('/reading', data),
  update: (id, data) => api.put(`/reading/${id}`, data),
};

export const statsApi = {
  getDashboard: () => api.get('/stats/dashboard'),
  getMonthly: () => api.get('/stats/monthly'),
  getGenres: () => api.get('/stats/genres'),
};

export default api;
```

---

### 6. Deploying to Coolify

#### Step 1: Push Code to Git
```bash
# In backend directory
git init
git add .
git commit -m "Initial backend setup"
git remote add origin <your-repo-url>
git push -u origin main

# In frontend directory
git init
git add .
git commit -m "Initial frontend setup"
git remote add origin <your-repo-url>
git push -u origin main
```

#### Step 2: Coolify - Database
1. Go to Coolify dashboard
2. Create new PostgreSQL service
3. Note the connection details

#### Step 3: Coolify - Backend
1. Create new application from Git
2. Select your backend repository
3. Set build pack: Node.js
4. Add environment variables:
   - `DATABASE_URL`: (from PostgreSQL service)
   - `PORT`: 3000
   - `CORS_ORIGIN`: https://your-frontend-domain.com
   - `NODE_ENV`: production
5. Deploy!

#### Step 4: Coolify - Frontend
1. Create new application from Git
2. Select your frontend repository
3. Set build pack: Node.js (Static)
4. Add environment variables:
   - `VITE_API_URL`: https://your-backend-domain.com/api
5. Build command: `npm run build`
6. Publish directory: `dist`
7. Deploy!

---

### 7. Development Workflow

**Local Development:**
```bash
# Terminal 1 - Backend
cd reading-tracker-backend
npm run dev

# Terminal 2 - Frontend
cd reading-tracker-frontend
npm run dev

# Terminal 3 - Database (if using Docker)
docker run --name postgres-dev -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres
```

**Making Changes:**
1. Make changes locally
2. Test thoroughly
3. Commit and push to Git
4. Coolify auto-deploys (if configured)
5. Or manually trigger deployment in Coolify

---

### 8. Google Books API Integration

**Sign up for API key (optional):**
- Go to Google Cloud Console
- Enable Google Books API
- Create credentials (API key)
- Add to backend `.env`: `GOOGLE_BOOKS_API_KEY=your_key`

**Note:** Google Books API works without key for basic usage, but rate-limited.

---

## Next Steps

1. Set up repositories and push initial code
2. Create PostgreSQL database in Coolify
3. Deploy backend and frontend
4. Start building features:
   - Book CRUD endpoints
   - Reading session tracking
   - Dashboard statistics
   - Book search from Google Books API

Happy coding! 🚀
