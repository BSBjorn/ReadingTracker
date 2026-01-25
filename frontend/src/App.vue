<template>
  <div id="app" class="min-h-screen bg-gray-50">
    <header class="bg-gray-800 text-white">
      <nav class="max-w-7xl mx-auto px-4 py-4">
        <div class="flex gap-8">
          <RouterLink 
            to="/" 
            class="px-4 py-2 rounded hover:bg-gray-700 transition-colors"
            active-class="bg-gray-700"
          >
            Dashboard
          </RouterLink>
          <RouterLink 
            to="/books" 
            class="px-4 py-2 rounded hover:bg-gray-700 transition-colors"
            active-class="bg-gray-700"
          >
            My Books
          </RouterLink>
          <RouterLink 
            to="/add-book" 
            class="px-4 py-2 rounded hover:bg-gray-700 transition-colors"
            active-class="bg-gray-700"
          >
            Add Book
          </RouterLink>
        </div>
      </nav>
    </header>
    <main class="max-w-7xl mx-auto px-4 py-8">
      <RouterView />
    </main>
  </div>
</template>

<script setup>
// No logic needed for App.vue
</script>
