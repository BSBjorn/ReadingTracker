import { createRouter, createWebHistory } from 'vue-router'
import Dashboard from '../views/Dashboard.vue'
import BooksView from '../views/BooksView.vue'
import AddBookView from '../views/AddBookView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'dashboard',
      component: Dashboard
    },
    {
      path: '/books',
      name: 'books',
      component: BooksView
    },
    {
      path: '/add-book',
      name: 'add-book',
      component: AddBookView
    },
    {
      path: '/edit-book/:id',
      name: 'edit-book',
      component: AddBookView
    }
  ]
})

export default router
