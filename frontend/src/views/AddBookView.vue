<template>
    <div class="py-8">
        <h1 class="text-4xl font-bold text-gray-800 mb-8">
            {{ isEditMode ? "✏️ Edit Book" : "➕ Add New Book" }}
        </h1>

        <!-- Search Section (only show in add mode) -->
        <div v-if="!isEditMode" class="bg-white rounded-lg shadow p-8 mb-8">
            <h2 class="text-2xl font-semibold text-gray-800 mb-4">
                Search Google Books
            </h2>

            <!-- ISBN Detection Badge -->
            <div
                v-if="isISBNQuery && searchQuery.trim()"
                class="mb-4 inline-flex items-center gap-2 bg-blue-50 text-blue-700 px-4 py-2 rounded-full text-sm font-medium"
            >
                <span>📖</span>
                <span>ISBN detected - searching by ISBN</span>
            </div>

            <div class="flex gap-4 mb-8">
                <input
                    type="text"
                    v-model="searchQuery"
                    placeholder="Search by title, author, or ISBN..."
                    @keyup.enter="searchBooks"
                    class="flex-1 px-4 py-3 border border-gray-300 rounded focus:outline-none focus:border-primary"
                />
                <button
                    @click="searchBooks"
                    :disabled="searching"
                    class="bg-primary hover:bg-primary-hover text-white px-8 py-3 rounded transition-colors disabled:opacity-60 disabled:cursor-not-allowed"
                >
                    {{ searching ? "🔍 Searching..." : "🔍 Search" }}
                </button>
            </div>

            <!-- Search Results -->
            <div v-if="searchResults.length > 0">
                <h3 class="text-gray-600 text-lg mb-4">
                    Search Results ({{ searchResults.length }})
                </h3>
                <div
                    class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4"
                >
                    <div
                        v-for="book in searchResults"
                        :key="book.googleBooksId"
                        @click="selectBook(book)"
                        class="border-2 border-gray-200 rounded-lg p-4 cursor-pointer transition-all hover:border-primary hover:-translate-y-1 hover:shadow-lg text-center"
                    >
                        <img
                            v-if="book.cover_url"
                            :src="book.cover_url"
                            :alt="book.title"
                            class="w-full h-48 object-contain mb-2"
                        />
                        <div
                            v-else
                            class="w-full h-48 flex items-center justify-center bg-gray-100 rounded mb-2 text-6xl"
                        >
                            📚
                        </div>
                        <h4
                            class="font-semibold text-sm text-gray-800 mb-1 line-clamp-2"
                        >
                            {{ book.title }}
                        </h4>
                        <p class="text-xs text-gray-600 mb-1">
                            {{ book.author || "Unknown Author" }}
                        </p>
                        <p class="text-xs text-gray-500 mb-2">
                            {{
                                book.pages
                                    ? `${book.pages} pages`
                                    : "Pages unknown"
                            }}
                        </p>

                        <!-- Display genres if available -->
                        <div
                            v-if="book.genres && book.genres.length > 0"
                            class="flex flex-wrap gap-1 justify-center"
                        >
                            <span
                                v-for="genre in book.genres.slice(0, 2)"
                                :key="genre"
                                class="bg-blue-50 text-blue-600 text-xs px-2 py-0.5 rounded-full"
                            >
                                {{ genre }}
                            </span>
                            <span
                                v-if="book.genres.length > 2"
                                class="text-xs text-gray-400"
                            >
                                +{{ book.genres.length - 2 }}
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <div
                v-if="searchError"
                class="bg-red-50 text-red-600 p-4 rounded mt-4"
            >
                {{ searchError }}
            </div>
        </div>

        <!-- Divider (only show in add mode) -->
        <div v-if="!isEditMode" class="relative text-center my-8">
            <div class="absolute inset-0 flex items-center">
                <div class="w-full border-t border-gray-300"></div>
            </div>
            <span class="relative bg-gray-50 px-4 text-gray-500">OR</span>
        </div>

        <!-- Manual Entry Form -->
        <div class="bg-white rounded-lg shadow p-8 max-w-2xl">
            <h2 class="text-2xl font-semibold text-gray-800 mb-6">
                {{ isEditMode ? "Edit Book Details" : "Add Manually" }}
            </h2>
            <form @submit.prevent="handleSubmit">
                <div class="mb-6">
                    <label
                        for="title"
                        class="block text-gray-700 font-medium mb-2"
                        >Title *</label
                    >
                    <input
                        type="text"
                        id="title"
                        v-model="book.title"
                        placeholder="Enter book title"
                        required
                        class="w-full px-4 py-3 border border-gray-300 rounded focus:outline-none focus:border-primary"
                    />
                </div>

                <div class="mb-6">
                    <label
                        for="author"
                        class="block text-gray-700 font-medium mb-2"
                        >Author</label
                    >
                    <input
                        type="text"
                        id="author"
                        v-model="book.author"
                        placeholder="Enter author name"
                        class="w-full px-4 py-3 border border-gray-300 rounded focus:outline-none focus:border-primary"
                    />
                </div>

                <div class="mb-6">
                    <label
                        for="pages"
                        class="block text-gray-700 font-medium mb-2"
                        >Pages</label
                    >
                    <input
                        type="number"
                        id="pages"
                        v-model.number="book.pages"
                        placeholder="Number of pages"
                        class="w-full px-4 py-3 border border-gray-300 rounded focus:outline-none focus:border-primary"
                    />
                </div>

                <div class="mb-6">
                    <label
                        for="genres"
                        class="block text-gray-700 font-medium mb-2"
                        >Genres</label
                    >
                    <input
                        type="text"
                        id="genres"
                        v-model="genresInput"
                        placeholder="Fiction, Fantasy, Adventure (comma-separated)"
                        class="w-full px-4 py-3 border border-gray-300 rounded focus:outline-none focus:border-primary"
                    />
                    <p class="text-gray-500 text-sm mt-1">
                        Separate multiple genres with commas
                    </p>
                </div>

                <div class="mb-6">
                    <label
                        for="isbn"
                        class="block text-gray-700 font-medium mb-2"
                        >ISBN</label
                    >
                    <input
                        type="text"
                        id="isbn"
                        v-model="book.isbn"
                        placeholder="ISBN (optional)"
                        class="w-full px-4 py-3 border border-gray-300 rounded focus:outline-none focus:border-primary"
                    />
                </div>

                <div class="mb-6">
                    <label
                        for="cover_url"
                        class="block text-gray-700 font-medium mb-2"
                        >Cover Image URL</label
                    >
                    <input
                        type="url"
                        id="cover_url"
                        v-model="book.cover_url"
                        placeholder="https://example.com/cover.jpg"
                        class="w-full px-4 py-3 border border-gray-300 rounded focus:outline-none focus:border-primary"
                    />
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
                    <div>
                        <label
                            for="start_date"
                            class="block text-gray-700 font-medium mb-2"
                            >Started Reading</label
                        >
                        <input
                            type="date"
                            id="start_date"
                            v-model="book.start_date"
                            class="w-full px-4 py-3 border border-gray-300 rounded focus:outline-none focus:border-primary"
                        />
                    </div>
                    <div>
                        <label
                            for="end_date"
                            class="block text-gray-700 font-medium mb-2"
                            >Finished Reading</label
                        >
                        <input
                            type="date"
                            id="end_date"
                            v-model="book.end_date"
                            class="w-full px-4 py-3 border border-gray-300 rounded focus:outline-none focus:border-primary"
                        />
                    </div>
                </div>

                <div class="flex gap-4">
                    <button
                        type="submit"
                        :disabled="submitting || loading"
                        class="bg-primary hover:bg-primary-hover text-white px-6 py-3 rounded transition-colors disabled:opacity-60 disabled:cursor-not-allowed"
                    >
                        {{
                            submitting
                                ? isEditMode
                                    ? "💾 Saving..."
                                    : "💾 Adding..."
                                : isEditMode
                                  ? "💾 Save Changes"
                                  : "💾 Add Book"
                        }}
                    </button>
                    <router-link
                        to="/books"
                        class="bg-gray-200 hover:bg-gray-300 text-gray-800 px-6 py-3 rounded transition-colors"
                    >
                        Cancel
                    </router-link>
                </div>
            </form>
        </div>
    </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from "vue";
import { useRouter, useRoute } from "vue-router";
import { bookApi } from "../services/api";
import { isISBN, cleanISBN } from "../utils/isbn";

const router = useRouter();
const route = useRoute();

// Detect if we're in edit mode
const isEditMode = computed(() => !!route.params.id);
const bookId = computed(() => route.params.id);

const searchQuery = ref("");
const searching = ref(false);
const searchResults = ref([]);
const searchError = ref(null);
const genresInput = ref(""); // For comma-separated genre input
const loading = ref(false);

// Computed property to detect if query is ISBN
const isISBNQuery = computed(() => isISBN(searchQuery.value));

const book = reactive({
    title: "",
    author: "",
    pages: null,
    isbn: "",
    cover_url: "",
    genres: [],
    source: "manual",
    start_date: "",
    end_date: "",
});

const submitting = ref(false);

// Load book data if in edit mode
onMounted(async () => {
    if (isEditMode.value) {
        loading.value = true;
        try {
            const response = await bookApi.getOne(bookId.value);
            const bookData = response.data;

            // Populate form fields
            book.title = bookData.title;
            book.author = bookData.author || "";
            book.pages = bookData.pages || null;
            book.isbn = bookData.isbn || "";
            book.cover_url = bookData.cover_url || "";
            book.genres = bookData.genres || [];
            book.source = bookData.source || "manual";
            book.start_date = bookData.start_date || "";
            book.end_date = bookData.end_date || "";

            // Update genres input field
            genresInput.value = book.genres.join(", ");
        } catch (error) {
            console.error("Error loading book:", error);
            alert("❌ Failed to load book data. Redirecting...");
            router.push("/books");
        } finally {
            loading.value = false;
        }
    }
});

const searchBooks = async () => {
    if (!searchQuery.value.trim()) {
        return;
    }

    searching.value = true;
    searchError.value = null;
    searchResults.value = [];

    try {
        if (isISBNQuery.value) {
            // Search by ISBN
            const cleanedISBN = cleanISBN(searchQuery.value);
            const response = await bookApi.searchByISBN(cleanedISBN);

            // ISBN endpoint returns a single book, not an array
            if (response.data) {
                searchResults.value = [response.data];
            } else {
                searchResults.value = [];
                searchError.value = "No book found with this ISBN.";
            }
        } else {
            // Regular search
            const response = await bookApi.search(searchQuery.value);
            searchResults.value = response.data.books || [];

            if (searchResults.value.length === 0) {
                searchError.value =
                    "No books found. Try a different search term.";
            }
        }
    } catch (error) {
        console.error("Search error:", error);
        if (error.response?.status === 404 && isISBNQuery.value) {
            searchError.value = "No book found with this ISBN.";
        } else {
            searchError.value = "Failed to search books. Please try again.";
        }
    } finally {
        searching.value = false;
    }
};

const selectBook = (selectedBook) => {
    book.title = selectedBook.title;
    book.author = selectedBook.author || "";
    book.pages = selectedBook.pages || null;
    book.isbn = selectedBook.isbn || "";
    book.cover_url = selectedBook.cover_url || "";
    book.genres = selectedBook.genres || [];
    book.source = "google_books";

    // Update genres input field
    genresInput.value = book.genres.join(", ");

    // Scroll to form
    window.scrollTo({ top: document.body.scrollHeight, behavior: "smooth" });
};

const handleSubmit = async () => {
    submitting.value = true;

    try {
        // Parse genres from comma-separated string
        const genresArray = genresInput.value
            .split(",")
            .map((g) => g.trim())
            .filter((g) => g.length > 0);

        // Update book genres
        book.genres = genresArray;

        if (isEditMode.value) {
            // Update existing book
            await bookApi.update(bookId.value, book);
            alert("✅ Book updated successfully!");
        } else {
            // Create new book
            await bookApi.create(book);
            alert("✅ Book added successfully!");
        }
        router.push("/books");
    } catch (error) {
        console.error("Error saving book:", error);
        alert(
            `❌ Failed to ${isEditMode.value ? "update" : "add"} book. Please try again.`,
        );
    } finally {
        submitting.value = false;
    }
};
</script>
