<template>
  <div class="py-8">
    <h1 class="text-4xl font-bold text-gray-800 mb-2">📚 Reading Dashboard</h1>
    <p class="text-gray-600 mb-8">Welcome to your Reading Tracker!</p>
    
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-gray-600 text-sm mb-2">Total Books</h3>
        <p class="text-4xl font-bold text-gray-800">0</p>
      </div>
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-gray-600 text-sm mb-2">Currently Reading</h3>
        <p class="text-4xl font-bold text-gray-800">0</p>
      </div>
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-gray-600 text-sm mb-2">Finished This Month</h3>
        <p class="text-4xl font-bold text-gray-800">0</p>
      </div>
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-gray-600 text-sm mb-2">Pages Read</h3>
        <p class="text-4xl font-bold text-gray-800">0</p>
      </div>
    </div>

    <div class="bg-white rounded-lg shadow p-8 text-center">
      <h2 class="text-2xl font-bold text-gray-800 mb-4">Getting Started</h2>
      <p class="text-gray-600 mb-6">Start tracking your reading journey by adding books to your library.</p>
      <router-link 
        to="/add-book" 
        class="inline-block bg-primary hover:bg-primary-hover text-white px-6 py-3 rounded transition-colors"
      >
        Add Your First Book
      </router-link>
    </div>
  </div>
</template>

<script setup>
// No reactive data needed yet - stats will be added later
</script>
