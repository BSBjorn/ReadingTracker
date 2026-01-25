/**
 * Check if a string looks like an ISBN
 * Supports ISBN-10 and ISBN-13 with or without hyphens/spaces
 */
export function isISBN(str) {
  if (!str) return false
  
  // Remove hyphens, spaces, and convert to uppercase
  const cleaned = str.replace(/[-\s]/g, '').toUpperCase()
  
  // ISBN-13: 13 digits
  const isbn13Pattern = /^\d{13}$/
  
  // ISBN-10: 9 digits followed by either a digit or X
  const isbn10Pattern = /^\d{9}[\dX]$/
  
  return isbn13Pattern.test(cleaned) || isbn10Pattern.test(cleaned)
}

/**
 * Clean ISBN for API calls (remove hyphens and spaces)
 */
export function cleanISBN(isbn) {
  return isbn.replace(/[-\s]/g, '')
}

/**
 * Format ISBN for display (add hyphens)
 * Note: Proper ISBN formatting requires knowledge of registration group, etc.
 * This is a simple version that just adds basic formatting
 */
export function formatISBN(isbn) {
  const cleaned = cleanISBN(isbn)
  
  if (cleaned.length === 13) {
    // ISBN-13: 978-0-123-45678-9
    return `${cleaned.slice(0, 3)}-${cleaned.slice(3, 4)}-${cleaned.slice(4, 7)}-${cleaned.slice(7, 12)}-${cleaned.slice(12)}`
  } else if (cleaned.length === 10) {
    // ISBN-10: 0-123-45678-9
    return `${cleaned.slice(0, 1)}-${cleaned.slice(1, 4)}-${cleaned.slice(4, 9)}-${cleaned.slice(9)}`
  }
  
  return isbn
}
