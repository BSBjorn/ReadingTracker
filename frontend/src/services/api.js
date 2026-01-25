import axios from 'axios'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:3000/api',
  headers: {
    'Content-Type': 'application/json',
  },
})

export const bookApi = {
  getAll: () => api.get('/books'),
  getOne: (id) => api.get(`/books/${id}`),
  create: (data) => api.post('/books', data),
  update: (id, data) => api.put(`/books/${id}`, data),
  delete: (id) => api.delete(`/books/${id}`),
  search: (query) => api.get(`/books/search?q=${query}`),
  searchByISBN: (isbn) => api.get(`/books/isbn/${isbn}`),
}

export const readingApi = {
  getAll: () => api.get('/reading'),
  create: (data) => api.post('/reading', data),
  update: (id, data) => api.put(`/reading/${id}`, data),
}

export const statsApi = {
  getDashboard: () => api.get('/stats/dashboard'),
  getMonthly: () => api.get('/stats/monthly'),
  getGenres: () => api.get('/stats/genres'),
}

export default api
