<template>
  <div class="py-8">
    <h1 class="text-4xl font-bold text-gray-800 mb-2">📚 Reading Dashboard</h1>
    <p class="text-gray-600 mb-8">Welcome to your Reading Tracker!</p>
    
    <div v-if="loading" class="text-center py-12 text-gray-600 text-lg">
      Loading statistics...
    </div>

    <div v-else-if="error" class="bg-red-50 text-red-600 p-6 rounded-lg mb-8">
      {{ error }}
    </div>

    <div v-else>
      <!-- Stats Cards -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-gray-600 text-sm mb-2">Total Books</h3>
          <p class="text-4xl font-bold text-gray-800">{{ stats.totalBooks }}</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-gray-600 text-sm mb-2">Currently Reading</h3>
          <p class="text-4xl font-bold text-purple-600">{{ stats.currentlyReading }}</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-gray-600 text-sm mb-2">Finished This Month</h3>
          <p class="text-4xl font-bold text-green-600">{{ stats.finishedThisMonth }}</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-gray-600 text-sm mb-2">Pages Read</h3>
          <p class="text-4xl font-bold text-blue-600">{{ stats.pagesRead.toLocaleString() }}</p>
        </div>
      </div>

      <!-- Additional Stats -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-gray-600 text-sm mb-2">Finished This Year</h3>
          <p class="text-3xl font-bold text-gray-800">{{ stats.finishedThisYear }}</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-gray-600 text-sm mb-2">Average Reading Time</h3>
          <p class="text-3xl font-bold text-gray-800">
            {{ stats.avgReadingDays }} 
            <span class="text-lg text-gray-600">days</span>
          </p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-gray-600 text-sm mb-2">Top Genre</h3>
          <p class="text-2xl font-bold text-gray-800">
            {{ stats.topGenres[0]?.genre || 'None yet' }}
          </p>
        </div>
      </div>

      <!-- Top Genres List -->
      <div v-if="stats.topGenres.length > 0" class="bg-white rounded-lg shadow p-8 mb-8">
        <h2 class="text-2xl font-bold text-gray-800 mb-4">📊 Top Genres</h2>
        <div class="space-y-3">
          <div 
            v-for="(genre, index) in stats.topGenres" 
            :key="genre.genre"
            class="flex items-center justify-between"
          >
            <div class="flex items-center gap-3">
              <span class="text-2xl font-bold text-gray-400">{{ index + 1 }}</span>
              <span class="text-lg font-medium text-gray-800">{{ genre.genre }}</span>
            </div>
            <div class="flex items-center gap-2">
              <div class="bg-blue-100 rounded-full px-4 py-1">
                <span class="text-blue-700 font-semibold">{{ genre.count }} books</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Monthly Pages Chart -->
      <MonthlyPagesChart class="mb-8" />

      <!-- Getting Started (only show if no books) -->
      <div v-if="stats.totalBooks === 0" class="bg-white rounded-lg shadow p-8 text-center">
        <h2 class="text-2xl font-bold text-gray-800 mb-4">Getting Started</h2>
        <p class="text-gray-600 mb-6">Start tracking your reading journey by adding books to your library.</p>
        <router-link 
          to="/add-book" 
          class="inline-block bg-primary hover:bg-primary-hover text-white px-6 py-3 rounded transition-colors"
        >
          Add Your First Book
        </router-link>
      </div>

      <!-- Quick Actions (if has books) -->
      <div v-else class="bg-white rounded-lg shadow p-8">
        <h2 class="text-2xl font-bold text-gray-800 mb-4">Quick Actions</h2>
        <div class="flex flex-wrap gap-4">
          <router-link 
            to="/add-book" 
            class="bg-primary hover:bg-primary-hover text-white px-6 py-3 rounded transition-colors"
          >
            ➕ Add New Book
          </router-link>
          <router-link 
            to="/books" 
            class="bg-gray-200 hover:bg-gray-300 text-gray-800 px-6 py-3 rounded transition-colors"
          >
            📖 View All Books
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { statsApi } from '../services/api'
import MonthlyPagesChart from '../components/MonthlyPagesChart.vue'

const stats = ref({
  totalBooks: 0,
  currentlyReading: 0,
  finishedThisMonth: 0,
  finishedThisYear: 0,
  pagesRead: 0,
  avgReadingDays: 0,
  topGenres: []
})
const loading = ref(true)
const error = ref(null)

const fetchStats = async () => {
  loading.value = true
  error.value = null
  
  try {
    const response = await statsApi.getDashboard()
    stats.value = response.data
  } catch (err) {
    console.error('Error fetching stats:', err)
    error.value = 'Failed to load statistics. Please try again.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchStats()
})
</script>
