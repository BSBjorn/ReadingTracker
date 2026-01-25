# Reading Dates Feature Documentation

## Overview
Added start date and end date tracking for books to record when you started and finished reading them.

## ✅ Status: **IMPLEMENTED**

Users can now track when they started and finished reading each book. The dates are optional and displayed on book cards in the library view.

## Changes Made

### 1. Database Schema (`migrations/add_reading_dates.sql`)
- Added `start_date DATE` column to books table
- Added `end_date DATE` column to books table
- Created indexes on both date columns for query performance
- Migration applied successfully to existing database

### 2. Backend Updates (`reading-tracker-backend/routes/books.js`)

#### POST Endpoint
- Added `start_date` and `end_date` parameters to request body
- Updated INSERT query to include date fields
- Dates default to NULL if not provided

#### PUT Endpoint
- Added `start_date` and `end_date` parameters to request body
- Updated UPDATE query to include date fields
- Dates can be updated along with other book details

### 3. Frontend Form (`reading-tracker-frontend/src/views/AddBookView.vue`)

#### UI Changes
- Added two date input fields in a responsive grid layout
- **Started Reading** - input for start date
- **Finished Reading** - input for end date
- Uses native HTML5 date input for better UX
- Fields are optional (not required)

#### Data Model
- Added `start_date: ''` to book reactive object
- Added `end_date: ''` to book reactive object
- Dates loaded from API when editing existing books
- Dates saved when creating or updating books

### 4. Books View (`reading-tracker-frontend/src/views/BooksView.vue`)

#### Display Changes
- Added reading dates section on book cards
- Shows start date with 📅 icon
- Shows end date with ✅ icon
- Only displays if dates are present
- Formatted as **dd.mm.yyyy** using Norwegian locale (e.g., "10.01.2026")

#### Helper Function
```javascript
const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('nb-NO', { 
    day: '2-digit',
    month: '2-digit',
    year: 'numeric' 
  })
}
```
**Output format:** dd.mm.yyyy (Norwegian standard, e.g., "10.01.2026")

## User Flow

### Adding Dates to a New Book
1. Navigate to "Add Book" page
2. Fill in book details (title, author, etc.)
3. Scroll to "Reading Dates" section (two fields side-by-side)
4. Click "Started Reading" to select start date
5. Click "Finished Reading" to select end date (optional)
6. Submit form
7. Dates are saved with the book

### Adding Dates to Existing Book
1. Navigate to "My Books" page
2. Click ✏️ edit icon on a book card
3. Form loads with current book data
4. Fill in or modify the date fields
5. Click "Save Changes"
6. Updated dates appear on the book card

### Viewing Dates
- Books with dates show them below genres on the card
- Format: **dd.mm.yyyy** (Norwegian standard)
  - 📅 Started: 10.01.2026
  - ✅ Finished: 20.01.2026
- If only start date exists, only that shows
- If only end date exists, only that shows
- If no dates, section doesn't appear

## Database Schema

```sql
ALTER TABLE books 
ADD COLUMN IF NOT EXISTS start_date DATE,
ADD COLUMN IF NOT EXISTS end_date DATE;

CREATE INDEX IF NOT EXISTS idx_books_start_date ON books(start_date);
CREATE INDEX IF NOT EXISTS idx_books_end_date ON books(end_date);
```

## API Changes

### POST /api/books
**Request Body (new fields):**
```json
{
  "title": "The Hobbit",
  "author": "J.R.R. Tolkien",
  "start_date": "2026-01-10",
  "end_date": "2026-01-20"
}
```

### PUT /api/books/:id
**Request Body (new fields):**
```json
{
  "title": "The Hobbit",
  "start_date": "2026-01-10",
  "end_date": "2026-01-20"
}
```

### GET /api/books
**Response (new fields):**
```json
{
  "id": 1,
  "title": "The Hobbit",
  "start_date": "2026-01-09T23:00:00.000Z",
  "end_date": "2026-01-19T23:00:00.000Z"
}
```

## Features

✅ Optional date fields (not required)
✅ Native HTML5 date picker
✅ Responsive layout (side-by-side on desktop, stacked on mobile)
✅ Dates persist in database
✅ Dates editable after creation
✅ Formatted display in book cards
✅ Icons for visual clarity (📅 for start, ✅ for finished)
✅ Conditional display (only shows if dates exist)
✅ Indexed for query performance

## UI/UX Details

### Form Layout
```
┌─────────────────────────────────────────────────┐
│  Started Reading     │  Finished Reading        │
│  [Date Picker]       │  [Date Picker]           │
└─────────────────────────────────────────────────┘
```

### Book Card Display
```
┌─────────────────────┐
│   📚 Book Cover     │
│                     │
│  The Hobbit         │
│  J.R.R. Tolkien     │
│  310 pages          │
│                     │
│  [Fantasy] [Adventure]
│                     │
│  📅 Started: 10.01.2026
│  ✅ Finished: 20.01.2026
│                     │
│  ✏️ Manual    ✏️ 🗑️  │
└─────────────────────┘
```

## Future Enhancements

Potential improvements:
- Calculate reading duration automatically (days between start and end)
- Show "Currently Reading" status if start date but no end date
- Filter/sort books by reading dates
- Show reading timeline/calendar view
- Statistics: books read per month/year
- Average reading time per book
- Reading streak tracking
- Re-reading support (multiple date ranges per book)
- Reading goals based on dates

## Migration

If you have an existing database, run the migration:
```bash
cd /home/bamfjord/Projects/ReadingTracker
podman exec -i reading-tracker-db psql -U reading_user -d reading_tracker < migrations/add_reading_dates.sql
```

## Testing Checklist

✅ Date fields appear in add/edit form
✅ Date fields are optional (form submits without them)
✅ Start date can be set independently
✅ End date can be set independently
✅ Both dates can be set together
✅ Dates persist after save
✅ Dates display on book cards with correct format
✅ Dates can be edited after creation
✅ Dates can be removed (set to empty)
✅ Book cards without dates don't show date section
✅ Date picker shows correct format
✅ Responsive layout works on mobile
✅ Database indexes created successfully

## Date Format and Localization

### Display Format
All dates are displayed in Norwegian format using the `nb-NO` locale:
- Format: **dd.mm.yyyy** (e.g., 10.01.2026)
- Used in: Book cards in "My Books" view

### Input Format
Date inputs use native HTML5 `<input type="date">`:
- **Display**: Automatically formatted based on browser/OS locale settings
  - If your system is set to Norwegian → shows dd.mm.yyyy
  - If your system is set to English → shows mm/dd/yyyy
- **Storage**: Always uses ISO format (yyyy-mm-dd) internally
- **Benefits**:
  - Native date picker UI with calendar popup
  - Better mobile experience
  - Automatic validation
  - Better accessibility
  - No manual date parsing needed

### Technical Details
The browser automatically handles locale formatting for date inputs. The `v-model` binding works with ISO format (yyyy-mm-dd), which is the standard for `<input type="date">` elements. The display format adapts to your system's locale settings.

