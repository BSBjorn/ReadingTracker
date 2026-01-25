-- Reading Tracker Database Schema
-- This script initializes the database with required tables and indexes

-- Books Table
CREATE TABLE IF NOT EXISTS books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255),
    pages INTEGER,
    genres TEXT[],
    isbn VARCHAR(20),
    cover_url VARCHAR(500),
    source VARCHAR(20), -- 'manual', 'google_books', or 'open_library'
    created_at TIMESTAMP DEFAULT NOW()
);

-- Reading Sessions Table
CREATE TABLE IF NOT EXISTS reading_sessions (
    id SERIAL PRIMARY KEY,
    book_id INTEGER REFERENCES books(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    finish_date DATE,
    status VARCHAR(20) DEFAULT 'reading', -- 'reading', 'finished', 'abandoned'
    created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_reading_sessions_book_id ON reading_sessions(book_id);
CREATE INDEX IF NOT EXISTS idx_reading_sessions_finish_date ON reading_sessions(finish_date);
CREATE INDEX IF NOT EXISTS idx_reading_sessions_status ON reading_sessions(status);
CREATE INDEX IF NOT EXISTS idx_books_title ON books(title);
CREATE INDEX IF NOT EXISTS idx_books_author ON books(author);

-- Optional: Insert sample data for testing
INSERT INTO books (title, author, pages, genres, source) VALUES
    ('The Hobbit', 'J.R.R. Tolkien', 310, ARRAY['Fantasy', 'Adventure'], 'manual'),
    ('1984', 'George Orwell', 328, ARRAY['Dystopian', 'Science Fiction'], 'manual'),
    ('To Kill a Mockingbird', 'Harper Lee', 281, ARRAY['Classic', 'Fiction'], 'manual')
ON CONFLICT DO NOTHING;

-- Output success message
SELECT 'Database initialized successfully!' as message;
