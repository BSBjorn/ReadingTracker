# 📚 Reading Tracker

A full-stack web application for tracking your reading journey. Search for books using Google Books API, manage your library, and keep track of when you read each book.

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ 
- Podman or Docker
- PostgreSQL (via container)

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd ReadingTracker

# Start the database
./db.sh start

# Install backend dependencies
cd backend
npm install
cp .env.example .env  # Configure if needed

# Install frontend dependencies
cd ../frontend
npm install
cp .env.example .env  # Configure if needed
```

### Running the Application

**Start Backend (Terminal 1):**
```bash
cd backend
npm run dev
# Runs on http://localhost:3000
```

**Start Frontend (Terminal 2):**
```bash
cd frontend
npm run dev
# Runs on http://localhost:5173
```

**Access the App:**
Open http://localhost:5173 in your browser

## 📁 Project Structure

```
ReadingTracker/
├── backend/                 # Node.js + Express API
│   ├── config/             # Database configuration
│   ├── routes/             # API routes
│   ├── services/           # Business logic (Google Books integration)
│   ├── package.json
│   └── server.js           # Entry point
├── frontend/               # Vue 3 + Vite frontend
│   ├── public/            # Static assets
│   ├── src/
│   │   ├── assets/        # Styles (Tailwind CSS)
│   │   ├── components/    # Vue components
│   │   ├── router/        # Vue Router configuration
│   │   ├── services/      # API client
│   │   ├── stores/        # Pinia stores
│   │   ├── utils/         # Utilities (ISBN detection)
│   │   ├── views/         # Page components
│   │   ├── App.vue
│   │   └── main.js
│   ├── package.json
│   └── vite.config.js
├── docs/                   # Original project documentation
├── migrations/             # Database migrations
├── docker-compose.yml      # PostgreSQL container
├── init-db.sql            # Database schema
├── db.sh                  # Database management script
└── *.md                   # Feature documentation
```

## 🛠️ Technology Stack

### Backend
- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** PostgreSQL 16
- **API Integration:** Google Books API (via axios)
- **Container:** Podman/Docker

### Frontend
- **Framework:** Vue 3 (Composition API)
- **Build Tool:** Vite
- **Styling:** Tailwind CSS v4
- **Routing:** Vue Router
- **State Management:** Pinia
- **HTTP Client:** Axios

## ✨ Features

- 🔍 **Book Search** - Search Google Books API by title, author, or ISBN
- 📖 **ISBN Detection** - Smart ISBN recognition (ISBN-10 & ISBN-13)
- 📚 **Library Management** - Add, edit, and delete books
- 🏷️ **Genre Tagging** - Organize books by genres
- 📅 **Reading Dates** - Track when you started and finished reading
- 🎨 **Modern UI** - Clean, responsive design with Tailwind CSS
- ✏️ **Book Editing** - Update book details anytime
- 🇳🇴 **Norwegian Dates** - Date display in dd.mm.yyyy format

## 📊 Database

The app uses PostgreSQL running in a container. The database helper script makes management easy:

```bash
./db.sh start      # Start PostgreSQL container
./db.sh stop       # Stop container
./db.sh status     # Check status
./db.sh psql       # Open PostgreSQL shell
./db.sh logs       # View logs
./db.sh backup     # Backup database
./db.sh reset      # Reset database
```

### Database Schema

**Books Table:**
- id, title, author, pages, genres, isbn, cover_url, source
- start_date, end_date (reading tracking)
- created_at

**Reading Sessions Table** (planned):
- For tracking re-reads and detailed reading history

## 🔌 API Endpoints

### Books
- `GET /api/books` - Get all books
- `GET /api/books/:id` - Get single book
- `GET /api/books/search?q=query` - Search Google Books
- `GET /api/books/isbn/:isbn` - Search by ISBN
- `POST /api/books` - Create book
- `PUT /api/books/:id` - Update book
- `DELETE /api/books/:id` - Delete book

## 📝 Environment Variables

### Backend (.env)
```env
PORT=3000
NODE_ENV=development
DB_HOST=localhost
DB_PORT=5432
DB_NAME=reading_tracker
DB_USER=reading_user
DB_PASSWORD=reading_pass
```

### Frontend (.env)
```env
VITE_API_URL=http://localhost:3000/api
```

## 🚢 Deployment (Coolify)

This monorepo structure is optimized for deployment with Coolify:

1. **Connect Repository** - Point Coolify to this git repository
2. **Configure Services:**
   - **Backend:** Build from `/backend`, Port 3000
   - **Frontend:** Build from `/frontend`, Port 5173 (or build to static)
3. **Environment Variables** - Set via Coolify UI
4. **Database** - Use Coolify's PostgreSQL service or external DB

### Docker Compose (Optional)
For self-hosting, the included `docker-compose.yml` sets up PostgreSQL. You can extend it to include backend and frontend services.

## 🧪 Development

### Running Tests
```bash
# Backend
cd backend
npm test

# Frontend  
cd frontend
npm test
```

### API Testing
Use the included test script:
```bash
./test-api.sh
```

## 📖 Documentation

- `SETUP_INSTRUCTIONS.md` - Detailed setup guide
- `GETTING_STARTED.md` - Quick start tutorial
- `DATABASE_SETUP.md` - Database configuration
- `GOOGLE_BOOKS_IMPLEMENTATION.md` - API integration details
- `TAILWIND_V4_SETUP.md` - Styling setup
- `VUE_COMPOSITION_API.md` - Vue patterns used
- `BOOK_EDIT_FEATURE.md` - Edit functionality
- `READING_DATES_FEATURE.md` - Date tracking feature

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- Google Books API for book data
- Vue.js and Vite teams
- Tailwind CSS team
- Open source community

---

**Happy Reading! 📚✨**
