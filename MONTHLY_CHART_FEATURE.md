# Monthly Pages Chart Feature

## Overview
Added an interactive bar chart to the dashboard showing pages read per month over the last 12 months.

## Visual Example
```
📊 Pages Read Per Month

    Pages
    1200│
    1000│         ╔═══╗
     800│         ║   ║     ╔═══╗
     600│   ╔═══╗ ║   ║     ║   ║
     400│   ║   ║ ║   ║ ╔═╗ ║   ║ ╔═╗
     200│   ║   ║ ║   ║ ║ ║ ║   ║ ║ ║
       0└───┴───┴─┴───┴─┴─┴─┴───┴─┴─┴──
          Aug  Oct  Nov  Dec  Jan
          2025      2025 2025 2026
```

## Features

### 📊 Interactive Chart
- **Bar Chart:** Clean, modern visualization
- **Responsive:** Adapts to screen size
- **Tooltips:** Hover to see exact page counts
- **Color Scheme:** Blue bars matching app theme
- **Rounded Corners:** Modern aesthetic

### 📈 Data Display
- **Last 12 Months:** Shows recent reading history
- **Chronological:** Oldest to newest (left to right)
- **Formatted Labels:** "Jan 2026", "Dec 2025", etc.
- **Number Formatting:** Comma separators (1,039)
- **Zero Handling:** Shows months with no pages

### 🎯 Smart States
- **Loading State:** Shows "Loading chart data..."
- **Error State:** Displays error message
- **Empty State:** Prompts user to add finished books
- **Data State:** Beautiful chart visualization

## Implementation

### Component: `MonthlyPagesChart.vue`

**Location:** `frontend/src/components/MonthlyPagesChart.vue`

**Dependencies:**
- `chart.js` v4.4.1
- `vue-chartjs` v5.3.0

**Chart.js Modules:**
```javascript
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend
} from 'chart.js'
```

**Data Structure:**
```javascript
chartData = {
  labels: ['Aug 2025', 'Oct 2025', 'Nov 2025', 'Dec 2025', 'Jan 2026'],
  datasets: [{
    label: 'Pages Read',
    backgroundColor: '#3b82f6',
    borderColor: '#2563eb',
    borderWidth: 2,
    borderRadius: 6,
    data: [0, 443, 688, 180, 1039]
  }]
}
```

### API Integration

**Endpoint Used:** `GET /api/stats/monthly`

**Response:**
```json
[
  {
    "month": "2026-01",
    "books_finished": "3",
    "pages_read": "1039"
  },
  {
    "month": "2025-12",
    "books_finished": "1",
    "pages_read": "180"
  }
]
```

**Data Processing:**
1. Fetch monthly data from API
2. Sort by month (ascending)
3. Format month labels (YYYY-MM → "Mon YYYY")
4. Extract pages_read values
5. Populate chart data structure

### Chart Configuration

**Responsive:**
```javascript
responsive: true
maintainAspectRatio: true
aspectRatio: 2.5  // Wide chart
```

**Y-Axis:**
- Starts at zero
- Number formatting with commas
- Light grid lines
- Custom font (Inter)

**X-Axis:**
- Month labels
- No grid lines (cleaner look)
- Custom font (Inter)

**Tooltips:**
- Dark background
- Formatted numbers
- Custom padding
- "Pages: 1,039" format

**Legend:**
- Top position
- "Pages Read" label
- Custom styling

## Dashboard Integration

**Location:** `frontend/src/views/Dashboard.vue`

**Import:**
```javascript
import MonthlyPagesChart from '../components/MonthlyPagesChart.vue'
```

**Placement:**
- After Top Genres section
- Before Quick Actions
- Full width of container
- 8px margin bottom

**Template:**
```vue
<!-- Monthly Pages Chart -->
<MonthlyPagesChart class="mb-8" />
```

## Chart Customization

### Colors
```javascript
backgroundColor: '#3b82f6'  // Tailwind blue-500
borderColor: '#2563eb'      // Tailwind blue-600
```

### Dimensions
```javascript
aspectRatio: 2.5  // Wide format (2.5:1 ratio)
```

### Border Radius
```javascript
borderRadius: 6  // Rounded bar tops
```

## User Experience

### Loading Flow
1. User lands on dashboard
2. "Loading chart data..." appears
3. API call to `/api/stats/monthly`
4. Chart renders with data
5. User can hover for details

### Empty State
If no finished books with dates:
```
No reading data yet. Start adding finished books 
with dates to see your progress!
```

### Interactive Features
- **Hover:** Shows tooltip with exact page count
- **Responsive:** Works on mobile, tablet, desktop
- **Animated:** Smooth transitions on load
- **Accessible:** Screen reader friendly

## Data Requirements

For chart to display meaningful data:

1. **Books must be finished** (`end_date` must be set)
2. **Books must have pages** (`pages` field must have value)
3. **End date within 12 months** (older data not shown)

## Technical Details

### Date Formatting
```javascript
const formatMonthLabel = (monthString) => {
  // "2026-01" → "Jan 2026"
  const [year, month] = monthString.split('-')
  const date = new Date(year, parseInt(month) - 1)
  return date.toLocaleDateString('en-US', { 
    month: 'short', 
    year: 'numeric' 
  })
}
```

### Data Sorting
```javascript
// Sort chronologically (oldest first)
monthlyData.sort((a, b) => a.month.localeCompare(b.month))
```

### Number Parsing
```javascript
// Convert string to number
parseInt(item.pages_read)
```

## Performance

- **Lazy Loading:** Chart only loads when dashboard viewed
- **Cached Data:** API results cached by browser
- **Efficient Rendering:** Chart.js optimized for performance
- **Small Bundle:** Chart components tree-shaken

## Browser Compatibility

Supported Browsers:
- ✅ Chrome/Edge (latest)
- ✅ Firefox (latest)
- ✅ Safari (latest)
- ✅ Mobile browsers (iOS Safari, Chrome)

## Future Enhancements

Potential improvements:
- 📊 **Books Finished Chart:** Companion chart for book counts
- 🎯 **Goal Line:** Add target pages/month line
- 📈 **Trend Line:** Show reading trend
- 🔄 **Toggle View:** Switch between pages/books
- 📱 **Mobile Optimization:** Vertical bars on small screens
- 📊 **Export Chart:** Download as image
- �� **Theme Options:** Light/dark mode
- 📅 **Date Range Picker:** Custom time periods
- 🏆 **Achievements:** Highlight milestone months
- 📉 **Comparison:** YoY comparison

## Testing

### View Chart
1. Navigate to Dashboard
2. Scroll down below statistics
3. See "📊 Pages Read Per Month" chart

### Test with Data
```bash
# Add test book
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Book",
    "author": "Test Author",
    "pages": 300,
    "genres": ["Test"],
    "start_date": "2025-12-01",
    "end_date": "2025-12-15"
  }'

# Refresh dashboard to see updated chart
```

### Verify API Data
```bash
curl http://localhost:3000/api/stats/monthly | jq
```

## Styling

**Card Container:**
- White background
- Rounded corners (rounded-lg)
- Box shadow
- Padding: 2rem (p-8)

**Chart Title:**
- 2xl font size
- Bold weight
- Gray-800 color
- Bottom margin: 1.5rem

**Chart Canvas:**
- Full width
- Responsive height (aspect ratio)
- Smooth rendering

## Accessibility

- **Screen Readers:** Chart.js ARIA labels
- **Keyboard Navigation:** Focusable elements
- **High Contrast:** Visible in all modes
- **Text Alternatives:** Loading/error messages

## Dependencies

```json
{
  "chart.js": "^4.4.1",
  "vue-chartjs": "^5.3.0"
}
```

**Already Installed:** ✅ No additional dependencies needed!

## File Structure

```
frontend/
├── src/
│   ├── components/
│   │   └── MonthlyPagesChart.vue  (NEW)
│   └── views/
│       └── Dashboard.vue          (UPDATED)
```

## Commit Details

**Files Changed:**
1. `frontend/src/components/MonthlyPagesChart.vue` (NEW)
2. `frontend/src/views/Dashboard.vue` (UPDATED)
3. `MONTHLY_CHART_FEATURE.md` (NEW)

**Lines of Code:**
- MonthlyPagesChart.vue: ~165 lines
- Dashboard.vue: +2 lines (import and component)

---

**Status:** ✅ Complete
**Chart Library:** Chart.js v4.4.1
**Framework:** Vue 3 + vue-chartjs
**Last Updated:** 2026-01-25
