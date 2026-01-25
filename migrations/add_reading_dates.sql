-- Add start_date and end_date columns to books table
-- Migration: Add reading date tracking

ALTER TABLE books 
ADD COLUMN IF NOT EXISTS start_date DATE,
ADD COLUMN IF NOT EXISTS end_date DATE;

-- Add index for querying by dates
CREATE INDEX IF NOT EXISTS idx_books_start_date ON books(start_date);
CREATE INDEX IF NOT EXISTS idx_books_end_date ON books(end_date);
