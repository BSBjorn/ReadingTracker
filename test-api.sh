#!/bin/bash
# Test script for Google Books API search

echo "📚 Testing Google Books API Search"
echo "===================================="
echo ""

# Wait for server to be ready
echo "⏳ Checking if server is running..."
if ! curl -s http://localhost:3000/api/health > /dev/null; then
    echo "❌ Server is not running. Please start it with: npm run dev"
    exit 1
fi
echo "✅ Server is running"
echo ""

# Test 1: Search for "The Hobbit"
echo "Test 1: Searching for 'The Hobbit'"
echo "-----------------------------------"
curl -s "http://localhost:3000/api/books/search?q=The%20Hobbit&maxResults=3" | jq -r '.books[] | "📖 \(.title) by \(.author) (\(.pages) pages)"'
echo ""

# Test 2: Search for "Harry Potter"
echo "Test 2: Searching for 'Harry Potter'"
echo "-------------------------------------"
curl -s "http://localhost:3000/api/books/search?q=Harry%20Potter&maxResults=3" | jq -r '.books[] | "📖 \(.title) by \(.author)"'
echo ""

# Test 3: Get book by ISBN (The Hobbit)
echo "Test 3: Get book by ISBN (The Hobbit: 9780547928227)"
echo "-----------------------------------------------------"
curl -s "http://localhost:3000/api/books/isbn/9780547928227" | jq '{ title, author, pages, genres, isbn }'
echo ""

# Test 4: Get all books from database
echo "Test 4: Get all books from database"
echo "------------------------------------"
curl -s "http://localhost:3000/api/books" | jq -r '.[] | "📚 \(.title) by \(.author)"'
echo ""

echo "✅ All tests complete!"
