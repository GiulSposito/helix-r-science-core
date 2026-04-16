# Step 2: Build Application

**Workflow:** build-dashboard
**Phase:** Shiny Development
**Duration:** 8-16 hours

---

## Objective

Develop Shiny UI and server logic with reactive components following the approved design.

---

## Instructions

Act as Marie with Shiny development expertise. Build a performant, maintainable dashboard.

### 1. Setup Project Structure

Create Shiny app structure:
```
dashboard/
├── app.R (single-file) OR
├── ui.R + server.R (two-file)
├── global.R (data loading, shared functions)
├── modules/ (if using Shiny modules)
├── www/ (CSS, JS, images)
└── data/ (cached datasets)
```

### 2. Implement UI

Build UI following design:

**Use bslib for modern styling:**
```r
library(shiny)
library(bslib)

ui <- page_sidebar(
  title = "Dashboard Title",
  sidebar = sidebar(...),  # Filters
  # Main content cards
  layout_columns(
    value_box(...),  # KPI cards
    card(plotOutput(...))  # Charts
  )
)
```

**Components:**
- Value boxes for KPIs with icons
- Cards for plots and tables
- Navset tabs for organization
- Responsive layout

### 3. Implement Server Logic

**Data loading (global.R):**
```r
# Load once at startup
data <- readRDS(here::here("data/cleaned.rds"))
```

**Reactive data filtering:**
```r
server <- function(input, output, session) {
  # Reactive filtered data
  filtered_data <- reactive({
    data |>
      filter(date >= input$date_range[1],
             date <= input$date_range[2])
  })

  # Render KPIs
  output$kpi_value <- renderText({
    calculate_kpi(filtered_data())
  })

  # Render plots
  output$trend_plot <- renderPlot({
    ggplot(filtered_data(), ...) + theme_minimal()
  })
}
```

### 4. Add Interactivity

Implement:
- **Reactive filters** — Update all outputs when filters change
- **Click interactions** — Drill down from summary to detail
- **Hover tooltips** — Show context on plot hover
- **Download handlers** — Export data and plots

### 5. Optimize Performance

- Use `bindCache()` for expensive computations
- Load data once in global.R
- Debounce rapid filter changes
- Limit data size (aggregate if needed)
- Use `reactable` for large tables (virtual scrolling)

### 6. Style and Polish

- Apply custom CSS in `www/custom.css`
- Add loading indicators for slow operations
- Ensure mobile responsiveness
- Test across browsers

---

## Validation Checklist

Before proceeding to Step 3:
- [ ] All UI components implemented
- [ ] Reactive logic functional
- [ ] KPIs update with filters
- [ ] Plots render correctly
- [ ] Interactivity works as designed

---

## Output

**Files created:**
- `app.R` (or `ui.R/server.R`)
- `global.R`
- `www/custom.css`
- `modules/` (if modular)

**Next:** Proceed to Step 3 (Test & Optimize)
