const axios = require('axios');

const GOOGLE_BOOKS_BASE_URL = 'https://www.googleapis.com/books/v1/volumes';

/**
 * Search for books using Google Books API
 * @param {string} query - Search query
 * @param {number} maxResults - Maximum number of results (default: 10)
 * @returns {Promise<Array>} Array of formatted book results
 */
async function searchBooks(query, maxResults = 10) {
  try {
    const params = {
      q: query,
      maxResults: Math.min(maxResults, 40), // Google Books API max is 40
      printType: 'books',
    };

    // Add API key if available (optional)
    if (process.env.GOOGLE_BOOKS_API_KEY) {
      params.key = process.env.GOOGLE_BOOKS_API_KEY;
    }

    const response = await axios.get(GOOGLE_BOOKS_BASE_URL, { params });

    if (!response.data.items) {
      return [];
    }

    // Format the results
    return response.data.items.map(item => formatBookData(item));
  } catch (error) {
    console.error('Google Books API error:', error.message);
    throw new Error('Failed to search books from Google Books API');
  }
}

/**
 * Get book details by ISBN
 * @param {string} isbn - ISBN-10 or ISBN-13
 * @returns {Promise<Object|null>} Formatted book data or null
 */
async function getBookByISBN(isbn) {
  try {
    const params = {
      q: `isbn:${isbn}`,
    };

    if (process.env.GOOGLE_BOOKS_API_KEY) {
      params.key = process.env.GOOGLE_BOOKS_API_KEY;
    }

    const response = await axios.get(GOOGLE_BOOKS_BASE_URL, { params });

    if (!response.data.items || response.data.items.length === 0) {
      return null;
    }

    return formatBookData(response.data.items[0]);
  } catch (error) {
    console.error('Google Books API error:', error.message);
    throw new Error('Failed to fetch book by ISBN');
  }
}

/**
 * Format Google Books API response to our schema
 * @param {Object} item - Google Books API item
 * @returns {Object} Formatted book data
 */
function formatBookData(item) {
  const volumeInfo = item.volumeInfo || {};
  const industryIdentifiers = volumeInfo.industryIdentifiers || [];

  // Get ISBN (prefer ISBN-13, fallback to ISBN-10)
  const isbn13 = industryIdentifiers.find(id => id.type === 'ISBN_13');
  const isbn10 = industryIdentifiers.find(id => id.type === 'ISBN_10');
  const isbn = isbn13?.identifier || isbn10?.identifier || null;

  // Get cover image (prefer larger images)
  const imageLinks = volumeInfo.imageLinks || {};
  const coverUrl = imageLinks.large || 
                   imageLinks.medium || 
                   imageLinks.thumbnail || 
                   imageLinks.smallThumbnail || 
                   null;

  return {
    title: volumeInfo.title || 'Unknown Title',
    author: volumeInfo.authors?.join(', ') || null,
    pages: volumeInfo.pageCount || null,
    genres: volumeInfo.categories || [],
    isbn: isbn,
    cover_url: coverUrl,
    source: 'google_books',
    // Additional info (not stored in DB but useful for display)
    description: volumeInfo.description || null,
    publishedDate: volumeInfo.publishedDate || null,
    publisher: volumeInfo.publisher || null,
    googleBooksId: item.id,
  };
}

module.exports = {
  searchBooks,
  getBookByISBN,
  formatBookData,
};
