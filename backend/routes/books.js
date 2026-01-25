const express = require('express');
const router = express.Router();
const { pool } = require('../config/database');
const bookApiService = require('../services/bookApiService');

// GET /api/books - Get all books
router.get('/', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM books ORDER BY created_at DESC'
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching books:', error);
    res.status(500).json({ error: 'Failed to fetch books' });
  }
});

// GET /api/books/search - Search books from Google Books API
router.get('/search', async (req, res) => {
  try {
    const { q } = req.query;

    if (!q || q.trim() === '') {
      return res.status(400).json({ error: 'Search query is required' });
    }

    const maxResults = parseInt(req.query.maxResults) || 10;
    const books = await bookApiService.searchBooks(q, maxResults);

    res.json({
      query: q,
      results: books.length,
      books: books,
    });
  } catch (error) {
    console.error('Error searching books:', error);
    res.status(500).json({ error: 'Failed to search books' });
  }
});

// GET /api/books/isbn/:isbn - Get book by ISBN from Google Books API
router.get('/isbn/:isbn', async (req, res) => {
  try {
    const { isbn } = req.params;
    const book = await bookApiService.getBookByISBN(isbn);

    if (!book) {
      return res.status(404).json({ error: 'Book not found' });
    }

    res.json(book);
  } catch (error) {
    console.error('Error fetching book by ISBN:', error);
    res.status(500).json({ error: 'Failed to fetch book' });
  }
});

// GET /api/books/:id - Get single book by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM books WHERE id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Book not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error fetching book:', error);
    res.status(500).json({ error: 'Failed to fetch book' });
  }
});

// POST /api/books - Add new book
router.post('/', async (req, res) => {
  try {
    const { title, author, pages, genres, isbn, cover_url, source, start_date, end_date } = req.body;

    if (!title || title.trim() === '') {
      return res.status(400).json({ error: 'Title is required' });
    }

    const result = await pool.query(
      `INSERT INTO books (title, author, pages, genres, isbn, cover_url, source, start_date, end_date)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING *`,
      [title, author, pages, genres || [], isbn, cover_url, source || 'manual', start_date || null, end_date || null]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating book:', error);
    res.status(500).json({ error: 'Failed to create book' });
  }
});

// PUT /api/books/:id - Update book
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { title, author, pages, genres, isbn, cover_url, start_date, end_date } = req.body;

    if (!title || title.trim() === '') {
      return res.status(400).json({ error: 'Title is required' });
    }

    const result = await pool.query(
      `UPDATE books 
       SET title = $1, author = $2, pages = $3, genres = $4, isbn = $5, cover_url = $6, start_date = $7, end_date = $8
       WHERE id = $9
       RETURNING *`,
      [title, author, pages, genres || [], isbn, cover_url, start_date || null, end_date || null, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Book not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error updating book:', error);
    res.status(500).json({ error: 'Failed to update book' });
  }
});

// DELETE /api/books/:id - Delete book
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'DELETE FROM books WHERE id = $1 RETURNING *',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Book not found' });
    }

    res.json({ message: 'Book deleted successfully', book: result.rows[0] });
  } catch (error) {
    console.error('Error deleting book:', error);
    res.status(500).json({ error: 'Failed to delete book' });
  }
});

module.exports = router;
