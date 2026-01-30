-- Reading Tracker Database Schema
-- Auto-run migration for initial table setup

CREATE TABLE IF NOT EXISTS books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255),
    pages INTEGER,
    genres TEXT[],
    isbn VARCHAR(20),
    cover_url VARCHAR(500),
    source VARCHAR(20),
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_books_title ON books(title);
CREATE INDEX IF NOT EXISTS idx_books_author ON books(author);
CREATE INDEX IF NOT EXISTS idx_books_start_date ON books(start_date);
CREATE INDEX IF NOT EXISTS idx_books_end_date ON books(end_date);

CREATE TABLE IF NOT EXISTS reading_sessions (
    id SERIAL PRIMARY KEY,
    book_id INTEGER NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    start_date DATE,
    finish_date DATE,
    status VARCHAR(20) DEFAULT 'reading',
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reading_sessions_book_id ON reading_sessions(book_id);
CREATE INDEX IF NOT EXISTS idx_reading_sessions_status ON reading_sessions(status);
