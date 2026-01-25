<template>
    <div class="py-8">
        <div class="flex justify-between items-center mb-8">
            <h1 class="text-4xl font-bold text-gray-800">📖 My Books</h1>
            <router-link
                to="/add-book"
                class="bg-primary hover:bg-primary-hover text-white px-6 py-2 rounded transition-colors"
            >
                ➕ Add Book
            </router-link>
        </div>

        <div v-if="loading" class="text-center py-12 text-gray-600 text-lg">
            Loading books...
        </div>

        <div
            v-else-if="error"
            class="bg-red-50 text-red-600 p-6 rounded-lg text-center"
        >
            {{ error }}
        </div>

        <div
            v-else-if="books.length === 0"
            class="bg-white rounded-lg shadow p-12 text-center"
        >
            <p class="text-gray-600 text-lg mb-6">
                No books yet. Start building your library!
            </p>
            <router-link
                to="/add-book"
                class="inline-block bg-primary hover:bg-primary-hover text-white px-6 py-3 rounded transition-colors"
            >
                Add Book
            </router-link>
        </div>

        <div
            v-else
            class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6"
        >
            <div
                v-for="book in books"
                :key="book.id"
                class="bg-white rounded-lg shadow overflow-hidden transition-all hover:-translate-y-1 hover:shadow-lg"
            >
                <img
                    v-if="book.cover_url"
                    :src="book.cover_url"
                    :alt="book.title"
                    class="w-full h-80 object-cover"
                />
                <div
                    v-else
                    class="w-full h-80 flex items-center justify-center text-8xl bg-gradient-to-br from-purple-500 to-purple-700"
                >
                    📚
                </div>

                <div class="p-4">
                    <h3
                        class="text-gray-800 font-semibold text-lg mb-2 line-clamp-2 min-h-[3.5rem]"
                    >
                        {{ book.title }}
                    </h3>
                    <p class="text-gray-600 text-sm mb-1">
                        {{ book.author || "Unknown Author" }}
                    </p>
                    <p class="text-gray-500 text-xs mb-2">
                        {{
                            book.pages ? `${book.pages} pages` : "Pages unknown"
                        }}
                    </p>

                    <div
                        v-if="book.genres && book.genres.length > 0"
                        class="flex flex-wrap gap-2 mb-2"
                    >
                        <span
                            v-for="genre in book.genres.slice(0, 2)"
                            :key="genre"
                            class="bg-blue-50 text-blue-600 text-xs px-2 py-1 rounded-full"
                        >
                            {{ genre }}
                        </span>
                    </div>

                    <!-- Reading Dates -->
                    <div
                        v-if="book.start_date || book.end_date"
                        class="text-xs text-gray-500 mb-2 space-y-1"
                    >
                        <div
                            v-if="book.start_date"
                            class="flex items-center gap-1"
                        >
                            <span
                                >📅 Started:
                                {{ formatDate(book.start_date) }}</span
                            >
                        </div>
                        <div
                            v-if="book.end_date"
                            class="flex items-center gap-1"
                        >
                            <span
                                >✅ Finished:
                                {{ formatDate(book.end_date) }}</span
                            >
                        </div>
                    </div>

                    <div
                        class="flex justify-between items-center pt-2 border-t border-gray-100"
                    >
                        <span class="text-gray-400 text-xs">{{
                            getSourceLabel(book.source)
                        }}</span>
                        <div class="flex gap-2">
                            <router-link
                                :to="`/edit-book/${book.id}`"
                                class="text-xl opacity-60 hover:opacity-100 transition-opacity p-1"
                                title="Edit book"
                            >
                                ✏️
                            </router-link>
                            <button
                                @click="deleteBook(book.id)"
                                class="text-xl opacity-60 hover:opacity-100 transition-opacity p-1"
                                title="Delete book"
                            >
                                🗑️
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { bookApi } from "../services/api";

const books = ref([]);
const loading = ref(true);
const error = ref(null);

const fetchBooks = async () => {
    loading.value = true;
    error.value = null;

    try {
        const response = await bookApi.getAll();
        books.value = response.data;
    } catch (err) {
        console.error("Error fetching books:", err);
        error.value = "Failed to load books. Please try again.";
    } finally {
        loading.value = false;
    }
};

const deleteBook = async (id) => {
    if (!confirm("Are you sure you want to delete this book?")) {
        return;
    }

    try {
        await bookApi.delete(id);
        books.value = books.value.filter((book) => book.id !== id);
    } catch (err) {
        console.error("Error deleting book:", err);
        alert("Failed to delete book. Please try again.");
    }
};

const getSourceLabel = (source) => {
    const labels = {
        manual: "✏️ Manual",
        google_books: "📚 Google Books",
        open_library: "📖 Open Library",
    };
    return labels[source] || source;
};

const formatDate = (dateString) => {
    if (!dateString) return "";
    const date = new Date(dateString);
    return date.toLocaleDateString("nb-NO", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
    });
};

onMounted(() => {
    fetchBooks();
});
</script>
