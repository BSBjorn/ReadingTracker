const express = require("express");
const router = express.Router();
const { pool } = require("../config/database");

// GET /api/stats/dashboard - Get dashboard statistics
router.get("/dashboard", async (req, res) => {
  try {
    // Total books
    const totalBooksResult = await pool.query(
      "SELECT COUNT(*) as count FROM books",
    );
    const totalBooks = parseInt(totalBooksResult.rows[0].count);

    // Currently reading (has start_date but no end_date)
    const currentlyReadingResult = await pool.query(`
      SELECT COUNT(*) as count
      FROM books
      WHERE start_date IS NOT NULL AND end_date IS NULL
    `);
    const currentlyReading = parseInt(currentlyReadingResult.rows[0].count);

    // Finished this month (end_date in current month)
    const finishedThisMonthResult = await pool.query(`
      SELECT COUNT(*) as count
      FROM books
      WHERE end_date IS NOT NULL
      AND DATE_TRUNC('month', end_date) = DATE_TRUNC('month', CURRENT_DATE)
    `);
    const finishedThisMonth = parseInt(finishedThisMonthResult.rows[0].count);

    // Total pages read (only from finished books)
    const pagesReadResult = await pool.query(`
      SELECT COALESCE(SUM(pages), 0) as total
      FROM books
      WHERE end_date IS NOT NULL
      AND pages IS NOT NULL
    `);
    const pagesRead = parseInt(pagesReadResult.rows[0].total);

    // Additional stats - Books finished this year
    const finishedThisYearResult = await pool.query(`
      SELECT COUNT(*) as count
      FROM books
      WHERE end_date IS NOT NULL
      AND DATE_TRUNC('year', end_date) = DATE_TRUNC('year', CURRENT_DATE)
    `);
    const finishedThisYear = parseInt(finishedThisYearResult.rows[0].count);

    // Top genres (from finished books)
    const topGenresResult = await pool.query(`
      SELECT genre, COUNT(*) as count
      FROM books
      CROSS JOIN UNNEST(genres) as genre
      WHERE end_date IS NOT NULL
      GROUP BY genre
      ORDER BY count DESC
      LIMIT 5
    `);
    const topGenres = topGenresResult.rows;

    // Average reading time (for books with both dates)
    const avgReadingTimeResult = await pool.query(`
      SELECT AVG(end_date - start_date) as avg_days
      FROM books
      WHERE start_date IS NOT NULL
      AND end_date IS NOT NULL
    `);
    const avgReadingDays = avgReadingTimeResult.rows[0].avg_days
      ? Math.round(parseFloat(avgReadingTimeResult.rows[0].avg_days))
      : 0;

    res.json({
      totalBooks,
      currentlyReading,
      finishedThisMonth,
      finishedThisYear,
      pagesRead,
      avgReadingDays,
      topGenres,
    });
  } catch (error) {
    console.error("Error fetching dashboard stats:", error);
    res
      .status(500)
      .json({ error: "Failed to fetch statistics", details: error.message });
  }
});

// GET /api/stats/monthly - Get monthly reading statistics
router.get("/monthly", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        TO_CHAR(end_date, 'YYYY-MM') as month,
        COUNT(*) as books_finished,
        COALESCE(SUM(pages), 0) as pages_read
      FROM books
      WHERE end_date IS NOT NULL
        AND end_date >= CURRENT_DATE - INTERVAL '12 months'
      GROUP BY TO_CHAR(end_date, 'YYYY-MM')
      ORDER BY month DESC
    `);

    res.json(result.rows);
  } catch (error) {
    console.error("Error fetching monthly stats:", error);
    res.status(500).json({
      error: "Failed to fetch monthly statistics",
      details: error.message,
    });
  }
});

// GET /api/stats/genres - Get genre statistics
router.get("/genres", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        genre,
        COUNT(*) as book_count
      FROM books
      CROSS JOIN UNNEST(genres) as genre
      GROUP BY genre
      ORDER BY book_count DESC
    `);

    res.json(result.rows);
  } catch (error) {
    console.error("Error fetching genre stats:", error);
    res.status(500).json({
      error: "Failed to fetch genre statistics",
      details: error.message,
    });
  }
});

module.exports = router;
