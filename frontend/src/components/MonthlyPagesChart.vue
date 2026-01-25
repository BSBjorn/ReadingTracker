<template>
  <div class="bg-white rounded-lg shadow p-8">
    <h2 class="text-2xl font-bold text-gray-800 mb-6">📊 Pages Read Per Month</h2>
    
    <div v-if="loading" class="text-center py-8 text-gray-600">
      Loading chart data...
    </div>
    
    <div v-else-if="error" class="text-center py-8 text-red-600">
      {{ error }}
    </div>
    
    <div v-else-if="chartData.labels.length === 0" class="text-center py-8 text-gray-600">
      No reading data yet. Start adding finished books with dates to see your progress!
    </div>
    
    <div v-else>
      <Bar :data="chartData" :options="chartOptions" />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Bar } from 'vue-chartjs'
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend
} from 'chart.js'
import { statsApi } from '../services/api'

// Register Chart.js components
ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend
)

const loading = ref(true)
const error = ref(null)

const chartData = ref({
  labels: [],
  datasets: [
    {
      label: 'Pages Read',
      backgroundColor: '#3b82f6',
      borderColor: '#2563eb',
      borderWidth: 2,
      borderRadius: 6,
      data: []
    }
  ]
})

const chartOptions = ref({
  responsive: true,
  maintainAspectRatio: true,
  aspectRatio: 2.5,
  plugins: {
    legend: {
      display: true,
      position: 'top',
      labels: {
        font: {
          size: 14,
          family: "'Inter', sans-serif"
        },
        padding: 20
      }
    },
    tooltip: {
      backgroundColor: 'rgba(0, 0, 0, 0.8)',
      padding: 12,
      titleFont: {
        size: 14,
        family: "'Inter', sans-serif"
      },
      bodyFont: {
        size: 13,
        family: "'Inter', sans-serif"
      },
      callbacks: {
        label: function(context) {
          return `Pages: ${context.parsed.y.toLocaleString()}`
        }
      }
    }
  },
  scales: {
    y: {
      beginAtZero: true,
      ticks: {
        font: {
          size: 12,
          family: "'Inter', sans-serif"
        },
        callback: function(value) {
          return value.toLocaleString()
        }
      },
      grid: {
        color: 'rgba(0, 0, 0, 0.05)'
      }
    },
    x: {
      ticks: {
        font: {
          size: 12,
          family: "'Inter', sans-serif"
        }
      },
      grid: {
        display: false
      }
    }
  }
})

const formatMonthLabel = (monthString) => {
  // Convert "2026-01" to "Jan 2026"
  const [year, month] = monthString.split('-')
  const date = new Date(year, parseInt(month) - 1)
  return date.toLocaleDateString('en-US', { month: 'short', year: 'numeric' })
}

const fetchMonthlyData = async () => {
  loading.value = true
  error.value = null
  
  try {
    const response = await statsApi.getMonthly()
    const monthlyData = response.data
    
    if (monthlyData.length === 0) {
      chartData.value.labels = []
      chartData.value.datasets[0].data = []
      return
    }
    
    // Sort by month ascending (oldest first)
    monthlyData.sort((a, b) => a.month.localeCompare(b.month))
    
    // Extract labels and data
    chartData.value.labels = monthlyData.map(item => formatMonthLabel(item.month))
    chartData.value.datasets[0].data = monthlyData.map(item => parseInt(item.pages_read))
    
  } catch (err) {
    console.error('Error fetching monthly data:', err)
    error.value = 'Failed to load chart data. Please try again.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchMonthlyData()
})
</script>
