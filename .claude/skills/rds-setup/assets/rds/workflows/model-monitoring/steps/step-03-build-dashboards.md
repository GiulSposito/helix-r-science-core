# Step 3: Build Dashboards

**Workflow:** model-monitoring
**Phase:** Visualization & Observability
**Duration:** 4-8 hours

---

## Objective

Create monitoring dashboards for production model observability (Grafana, Shiny, or custom).

---

## Instructions

Act as Tim. Build dashboards that make production health immediately visible.

### 1. Choose Dashboard Platform

**Grafana (Recommended for Prometheus):**
- Pre-built visualization panels
- Time-series focus
- Alert integration
- Team collaboration

**Shiny (Custom R Dashboard):**
- Full control over visuals
- R-native (ggplot2)
- Custom business logic
- Stakeholder-friendly

**Hybrid:**
- Grafana for technical metrics (SRE team)
- Shiny for business metrics (stakeholders)

### 2. Design Dashboard Layout

**Panel structure:**

**Row 1: Health Status**
- API Status (🟢/🟡/🔴)
- Error Rate (gauge)
- Current RPS (number)
- P95 Latency (number)

**Row 2: Traffic Trends**
- Request rate over time (line chart)
- Error rate over time (line chart)
- Latency percentiles (line chart)

**Row 3: Model Performance**
- Prediction confidence distribution (histogram)
- Feature drift indicators (bar chart)
- Model staleness (days badge)

**Row 4: Resource Usage**
- CPU usage (gauge)
- Memory usage (gauge)
- Disk I/O (if applicable)

### 3. Build Grafana Dashboard (If using)

Create `grafana-dashboard.json`:

```json
{
  "dashboard": {
    "title": "Model API Monitoring",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(api_requests_total[5m])"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(api_errors_total[5m]) / rate(api_requests_total[5m])"
          }
        ]
      }
    ]
  }
}
```

Import to Grafana:
```bash
curl -X POST http://grafana:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @grafana-dashboard.json
```

### 4. Build Shiny Dashboard (If using)

Create `monitoring-dashboard/app.R`:

```r
library(shiny)
library(bslib)
library(plotly)

ui <- page_sidebar(
  title = "Model Monitoring",
  sidebar = sidebar(
    dateRangeInput("date_range", "Date Range"),
    selectInput("metric", "Metric",
                choices = c("Error Rate", "Latency", "Volume"))
  ),
  layout_columns(
    value_box(
      title = "API Status",
      value = textOutput("status"),
      theme = "success"
    ),
    value_box(
      title = "Error Rate",
      value = textOutput("error_rate"),
      theme = "danger"
    ),
    value_box(
      title = "P95 Latency",
      value = textOutput("latency"),
      theme = "info"
    )
  ),
  card(
    card_header("Metrics Over Time"),
    plotlyOutput("metrics_plot")
  )
)

server <- function(input, output, session) {
  # Fetch metrics from Prometheus or logs
  metrics_data <- reactive({
    fetch_metrics(input$date_range)
  })

  output$status <- renderText({
    if (metrics_data()$error_rate < 0.01) "🟢 Healthy"
    else if (metrics_data()$error_rate < 0.05) "🟡 Warning"
    else "🔴 Critical"
  })

  output$error_rate <- renderText({
    paste0(round(metrics_data()$error_rate * 100, 2), "%")
  })

  output$latency <- renderText({
    paste0(round(metrics_data()$p95_latency), "ms")
  })

  output$metrics_plot <- renderPlotly({
    plot_ly(metrics_data(), x = ~timestamp, y = ~value,
            type = "scatter", mode = "lines")
  })
}

shinyApp(ui, server)
```

### 5. Add Real-Time Updates

For live dashboards:
```r
# Auto-refresh every 30 seconds
observe({
  invalidateLater(30000)  # 30 seconds
  # Fetch new data
})
```

### 6. Create Dashboard Documentation

Document in `DASHBOARD-GUIDE.md`:
- Dashboard URL
- Panels and their meaning
- How to interpret metrics
- When to escalate

---

## Validation Checklist

Before proceeding to Step 4:
- [ ] Dashboard displays all key metrics
- [ ] Visuals update with real data
- [ ] Dashboard accessible to team
- [ ] Documentation complete
- [ ] Performance acceptable (< 3s load)

---

## Output

**Files created:**
- `grafana-dashboard.json` or `monitoring-dashboard/app.R`
- `DASHBOARD-GUIDE.md`

**Next:** Proceed to Step 4 (Establish SLOs)
