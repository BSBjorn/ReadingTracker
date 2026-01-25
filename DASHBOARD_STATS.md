# Dashboard Statistics Feature

## Overview
The dashboard now displays real-time statistics from your reading library, providing insights into your reading habits and progress.

## Features

### 📊 Main Statistics Cards

1. **Total Books**
   - Count of all books in your library
   - Includes all books regardless of reading status

2. **Currently Reading** (Purple)
   - Books with a start date but no end date
   - Shows active reading progress

3. **Finished This Month** (Green)
   - Books completed in the current calendar month
   - Based on `end_date` field

4. **Pages Read** (Blue)
   - Total pages from all finished books
   - Only counts books with both `end_date` and `pages` fields

### 📈 Additional Statistics

1. **Finished This Year**
   - Books completed in the current calendar year
   - Tracks annual reading goal progress

2. **Average Reading Time**
   - Average days to complete a book
   - Calculated from books with both start and end dates
   - Displayed in days

3. **Top Genre**
   - Your most-read genre based on finished books
   - Shows "None yet" if no books completed

### 🏆 Top Genres List

- Displays top 5 most-read genres
- Ranked by number of books
- Shows book count for each genre
- Only includes genres from finished books

### 🎯 Dynamic Content

**If No Books:**
- Shows "Getting Started" section
- Call-to-action to add first book

**If Books Exist:**
- Shows "Quick Actions" section
- Buttons to add new book or view library

## Backend Implementation

### Stats Routes (`backend/routes/stats.js`)

#### GET /api/stats/dashboard
Returns comprehensive dashboard statistics:

```json
{
  "totalBooks": 6,
  "currentlyReading": 1,
  "finishedThisMonth": 3,
  "finishedThisYear": 3,
  "pagesRead": 1039,
  "avgReadingDays": 33,
  "topGenres": [
    {
      "genre": "Fiction",
      "count": "2"
    }
  ]
}
```

**Calculation Details:**

- **Total Books:** `SELECT COUNT(*) FROM books`
- **Currently Reading:** `WHERE start_date IS NOT NULL AND end_date IS NULL`
- **Finished This Month:** `WHERE DATE_TRUNC('month', end_date) = DATE_TRUNC('month', CURRENT_DATE)`
- **Pages Read:** `SUM(pages) WHERE end_date IS NOT NULL`
- **Avg Reading Days:** `AVG(end_date - start_date)` for books with both dates
- **Top Genres:** `UNNEST(genres)` with `GROUP BY` and `ORDER BY count DESC`

#### GET /api/stats/monthly
Returns monthly reading statistics for the last 12 months:

```json
[
  {
    "month": "2026-01",
    "books_finished": 3,
    "pages_read": 1039
  }
]
```

#### GET /api/stats/genres
Returns all genres with book counts:

```json
[
  {
    "genre": "Fiction",
    "book_count": "5"
  }
]
```

## Frontend Implementation

### Dashboard Component (`frontend/src/views/Dashboard.vue`)

**Data Fetching:**
```javascript
import { statsApi } from '../services/api'

const fetchStats = async () => {
  const response = await statsApi.getDashboard()
  stats.value = response.data
}
```

**Features:**
- Loading state while fetching data
- Error handling with error message display
- Conditional rendering based on data availability
- Responsive grid layout for stats cards

**UI/UX:**
- Color-coded statistics (purple, green, blue)
- Number formatting with `toLocaleString()` for large numbers
- Ranked genre list with visual badges
- Dynamic content based on library state

## Database Queries

### Currently Reading
Books that have been started but not finished:
```sql
SELECT COUNT(*) 
FROM books 
WHERE start_date IS NOT NULL 
  AND end_date IS NULL
```

### Finished This Month
Books completed in the current month:
```sql
SELECT COUNT(*) 
FROM books 
WHERE end_date IS NOT NULL 
  AND DATE_TRUNC('month', end_date) = DATE_TRUNC('month', CURRENT_DATE)
```

### Total Pages Read
Sum of pages from finished books:
```sql
SELECT COALESCE(SUM(pages), 0) 
FROM books 
WHERE end_date IS NOT NULL 
  AND pages IS NOT NULL
```

### Average Reading Time
Average days between start and end dates:
```sql
SELECT AVG(end_date - start_date) 
FROM books 
WHERE start_date IS NOT NULL 
  AND end_date IS NOT NULL
```

### Top Genres
Most popular genres from finished books:
```sql
SELECT genre, COUNT(*) as count
FROM books, UNNEST(genres) as genre
WHERE end_date IS NOT NULL
GROUP BY genre
ORDER BY count DESC
LIMIT 5
```

## API Service

The stats API is already defined in `frontend/src/services/api.js`:

```javascript
export const statsApi = {
  getDashboard: () => api.get('/stats/dashboard'),
  getMonthly: () => api.get('/stats/monthly'),
  getGenres: () => api.get('/stats/genres'),
}
```

## Visual Design

### Stats Cards Layout
```
┌────────────┬────────────┬────────────┬────────────┐
│  Total     │ Currently  │ Finished   │   Pages    │
│  Books     │  Reading   │ This Month │   Read     │
│     6      │     1      │     3      │   1,039    │
└────────────┴────────────┴────────────┴────────────┘
```

### Top Genres List
```
📊 Top Genres

1  Fiction         [2 books]
2  Habits          [1 book]
3  Classic         [1 book]
4  Fantasy         [1 book]
5  Space           [1 book]
```

## Requirements for Accurate Stats

To get the most value from dashboard statistics:

1. **Add Reading Dates:**
   - Set `start_date` when you begin a book
   - Set `end_date` when you finish

2. **Include Page Counts:**
   - Add `pages` field for total pages stat
   - Can be auto-filled from Google Books

3. **Tag with Genres:**
   - Add genres to categorize books
   - Enables genre-based statistics

## Future Enhancements

Potential additions:
- 📅 Reading streak (consecutive days)
- 📊 Monthly/yearly trends chart
- 🎯 Reading goals with progress bars
- 📈 Reading pace (pages per day)
- 🏅 Achievements/badges
- 📚 Recommended books based on genres
- 📱 Mobile-optimized stats view
- 📊 Export stats as CSV/PDF
- 🔔 Reading reminders
- 📖 DNF (Did Not Finish) tracking

## Testing

### Test Dashboard Endpoint
```bash
curl http://localhost:3000/api/stats/dashboard | jq
```

### Add Test Book with Dates
```bash
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Book",
    "author": "Test Author",
    "pages": 300,
    "genres": ["Fiction", "Test"],
    "start_date": "2026-01-01",
    "end_date": "2026-01-15"
  }'
```

## Performance Considerations

- All statistics queries are optimized with indexes
- Page count uses `COALESCE` to handle NULL values
- Genre queries use `UNNEST` for efficient array processing
- Date calculations use PostgreSQL's `DATE_TRUNC` function
- Queries are cached on the backend (consider adding Redis)

## Error Handling

The dashboard gracefully handles:
- Empty library (shows "Getting Started")
- Missing dates (excludes from calculations)
- NULL values (uses COALESCE)
- API errors (displays error message)
- Loading states (shows loading indicator)

---

**Status:** ✅ Complete
**Last Updated:** 2026-01-25
