# 📚 Reading Tracker

A full-stack web application for tracking your personal reading journey. Search books via Google Books API, manage your library, track reading dates, and visualize your reading statistics.

## ✨ Features

- 🔍 **Smart Book Search** - Search Google Books API by title, author, or ISBN
- 📖 **ISBN Detection** - Automatically recognizes ISBN-10 and ISBN-13 formats
- 📚 **Library Management** - Add, edit, and delete books from your collection
- 📅 **Reading Dates** - Track when you started and finished each book
- 🏷️ **Genre Tagging** - Organize books with multiple genre tags
- 📊 **Dashboard Statistics** - View reading stats (books read, pages, top genres)
- 📈 **Monthly Charts** - Visualize pages read per month with interactive charts
- 🎨 **Modern UI** - Clean, responsive design with Tailwind CSS v4
- 🇳🇴 **Norwegian Date Format** - Dates displayed as dd.mm.yyyy

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

# Start PostgreSQL database
./db.sh start

# Install backend dependencies
cd backend
npm install
cp .env.example .env

# Install frontend dependencies
cd ../frontend
npm install
cp .env.example .env
```

### Running the Application

**Terminal 1 - Backend:**
```bash
cd backend
npm run dev
# Runs on http://localhost:3000
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
# Runs on http://localhost:5173
```

**Access:** Open http://localhost:5173 in your browser

## 🛠️ Technology Stack

### Backend
- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** PostgreSQL 16
- **API Integration:** Google Books API
- **Container:** Podman/Docker

### Frontend
- **Framework:** Vue 3 (Composition API with `<script setup>`)
- **Build Tool:** Vite
- **Styling:** Tailwind CSS v4
- **Routing:** Vue Router
- **State Management:** Pinia
- **Charts:** Chart.js + vue-chartjs
- **HTTP Client:** Axios

## 📁 Project Structure

```
ReadingTracker/
├── backend/                    # Express.js API server
│   ├── config/                # Database configuration
│   ├── routes/                # API endpoints
│   │   ├── books.js          # Book CRUD + Google Books search
│   │   └── stats.js          # Statistics endpoints
│   ├── services/              # Business logic
│   │   └── bookApiService.js # Google Books integration
│   ├── server.js              # Entry point
│   └── .env                   # Environment configuration
│
├── frontend/                   # Vue 3 SPA
│   ├── src/
│   │   ├── assets/           # Styles (Tailwind CSS)
│   │   ├── components/       # Vue components
│   │   │   └── MonthlyPagesChart.vue
│   │   ├── router/           # Vue Router config
│   │   ├── services/         # API client
│   │   ├── utils/            # Utilities (ISBN detection)
│   │   └── views/            # Page components
│   │       ├── Dashboard.vue      # Stats & charts
│   │       ├── BooksView.vue      # Library view
│   │       └── AddBookView.vue    # Add/edit books
│   └── .env                   # Environment configuration
│
├── migrations/                 # Database migrations
├── docker-compose.yml          # PostgreSQL container setup
├── init-db.sql                # Database schema
├── db.sh                      # Database helper script
└── README.md                  # This file
```

## 🗄️ Database

The app uses PostgreSQL running in a container. Manage it easily with the helper script:

```bash
./db.sh start      # Start PostgreSQL
./db.sh stop       # Stop PostgreSQL
./db.sh status     # Check status
./db.sh psql       # Open PostgreSQL shell
./db.sh logs       # View logs
./db.sh backup     # Backup database
./db.sh reset      # Reset database
```

### Schema

**Books Table:**
- Core fields: id, title, author, pages, genres (array), isbn
- Tracking: start_date, end_date
- Metadata: cover_url, source, created_at

## 🔌 API Endpoints

### Books
- `GET /api/books` - Get all books
- `GET /api/books/:id` - Get single book
- `GET /api/books/search?q=query` - Search Google Books
- `GET /api/books/isbn/:isbn` - Search by ISBN
- `POST /api/books` - Create book
- `PUT /api/books/:id` - Update book
- `DELETE /api/books/:id` - Delete book

### Statistics
- `GET /api/stats/dashboard` - Dashboard overview (total books, currently reading, pages read, etc.)
- `GET /api/stats/monthly` - Monthly reading data for last 12 months
- `GET /api/stats/genres` - Genre breakdown

## ⚙️ Configuration

### Backend Environment Variables (`.env`)
```env
PORT=3000
NODE_ENV=development
DB_HOST=localhost
DB_PORT=5432
DB_NAME=reading_tracker
DB_USER=reading_user
DB_PASSWORD=reading_pass
CORS_ORIGIN=http://localhost:5173
GOOGLE_BOOKS_API_KEY=          # Optional
```

### Frontend Environment Variables (`.env`)
```env
VITE_API_URL=http://localhost:3000/api
```

## 🎨 Key Features Explained

### Smart Book Search
- Type any search query (title, author, ISBN)
- Automatically detects ISBN-10 and ISBN-13 formats
- Displays results in a visual grid with cover images
- Click any book to auto-fill the add form

### Reading Date Tracking
- Optional start and end date fields
- Track books you're currently reading (start date only)
- Track finished books (both dates)
- Calculate reading statistics based on dates

### Dashboard Statistics
- **Total Books** - Your entire library count
- **Currently Reading** - Books with start date but no end date
- **Finished This Month** - Books completed in current month
- **Pages Read** - Total pages from all finished books
- **Average Reading Time** - Average days to complete a book
- **Top Genres** - Your most-read genres

### Monthly Progress Chart
- Interactive bar chart showing pages read per month
- Last 12 months of data
- Hover for exact counts
- Responsive and mobile-friendly

## 🚢 Deployment

This monorepo is optimized for deployment with Coolify or any container platform.

### Docker Compose
The included `docker-compose.yml` sets up PostgreSQL. Extend it for backend/frontend services.

### Coolify Deployment
1. Connect this repository to Coolify
2. **Backend Service:**
   - Build directory: `/backend`
   - Port: 3000
   - Set environment variables via Coolify UI
3. **Frontend Service:**
   - Build directory: `/frontend`
   - Build command: `npm install && npm run build`
   - Serve from `dist/` directory

## 🧪 Testing

### API Testing
```bash
# Test backend health
curl http://localhost:3000/api/health
curl http://localhost:3000/api/db-health

# Test book search
curl "http://localhost:3000/api/books/search?q=tolkien"

# Run included test script
./test-api.sh
```

### Manual Testing
1. Start backend and frontend
2. Navigate to http://localhost:5173
3. Add books via search or manual entry
4. Set reading dates
5. View statistics on dashboard
6. Check monthly chart

## 📚 Documentation

- **Database Setup:** See `DATABASE_SETUP.md`
- **Environment Config:** See `ENVIRONMENT_CONFIG.md`
- **Getting Started:** See `GETTING_STARTED.md`
- **Original Documentation:** See `docs/` directory

## 🔧 Development

### Port Reference

| Service | Development | Docker |
|---------|-------------|--------|
| Frontend | 5173 | 8080 |
| Backend | 3000 | 3000 |
| Database | 5432 | 5432 |

### Common Commands

```bash
# Database
./db.sh start
./db.sh status
./db.sh psql

# Backend
cd backend
npm run dev

# Frontend
cd frontend
npm run dev

# Docker
docker-compose up -d
docker-compose logs -f
docker-compose down
```

## 🐛 Troubleshooting

### Database Connection Error
```bash
# Check if database is running
./db.sh status

# Start if needed
./db.sh start
```

### CORS Error in Browser
```bash
# Check backend CORS setting matches frontend port
grep CORS_ORIGIN backend/.env
# Should be: CORS_ORIGIN=http://localhost:5173

# Restart backend after changes
```

### Port Already in Use
```bash
# Find what's using the port
sudo lsof -i :5173  # or :3000

# Kill process or use different port
```

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
- Vue.js team for excellent framework
- Tailwind CSS for utility-first styling
- Chart.js for beautiful visualizations

---

**Happy Reading! 📚✨**

For detailed setup instructions and feature documentation, see the additional `.md` files in the project root.