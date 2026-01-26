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
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_books_title ON books(title);
CREATE INDEX IF NOT EXISTS idx_books_author ON books(author);
CREATE INDEX IF NOT EXISTS idx_books_start_date ON books(start_date);
CREATE INDEX IF NOT EXISTS idx_books_end_date ON books(end_date);

-- Optional: Insert sample data for testing
INSERT INTO books (title, author, pages, genres, source) VALUES
    ('The Hobbit', 'J.R.R. Tolkien', 310, ARRAY['Fantasy', 'Adventure'], 'manual'),
    ('1984', 'George Orwell', 328, ARRAY['Dystopian', 'Science Fiction'], 'manual'),
    ('To Kill a Mockingbird', 'Harper Lee', 281, ARRAY['Classic', 'Fiction'], 'manual')
ON CONFLICT DO NOTHING;

-- Output success message
SELECT 'Database initialized successfully!' as message;
