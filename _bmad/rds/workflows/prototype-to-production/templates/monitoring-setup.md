# Monitoring Setup Guide

This guide provides comprehensive instructions for setting up production monitoring for deployed models using Vetiver, Quarto dashboards, and alerting systems.

---

## Overview

**Monitoring Goals:**
1. Track model performance over time
2. Detect data drift and distribution shifts
3. Monitor system health (latency, throughput, errors)
4. Alert on anomalies and performance degradation
5. Support model retraining decisions

**Key Components:**
- **Vetiver Metrics**: Model performance tracking
- **Quarto Dashboard**: Real-time visualization
- **Alerting System**: Automated notifications
- **Logging**: Detailed request/response tracking

---

## 1. Baseline Metrics Capture

Before deploying to production, capture baseline metrics from test set evaluation.

### Capture Test Set Performance

```r
library(vetiver)
library(pins)
library(yardstick)

# Load model and test predictions
final_model <- readRDS("models/step-03-evaluation/final_production_model.rds")
test_pred <- readRDS("models/step-03-evaluation/rf_test_predictions.rds")

# Calculate baseline metrics
baseline_metrics <- test_pred %>%
  metrics(
    truth = target_variable,
    estimate = .pred_class,
    .pred_positive_class  # For classification
  )

# For classification
baseline_accuracy <- baseline_metrics %>%
  filter(.metric == "accuracy") %>%
  pull(.estimate)

baseline_roc_auc <- baseline_metrics %>%
  filter(.metric == "roc_auc") %>%
  pull(.estimate)

# Save baseline for reference
baseline <- list(
  date = Sys.Date(),
  accuracy = baseline_accuracy,
  roc_auc = baseline_roc_auc,
  n_test_samples = nrow(test_pred)
)

saveRDS(baseline, "monitoring/baseline_metrics.rds")
```

### Document Baseline Feature Distributions

```r
# Capture feature statistics from training data
train_data <- readRDS("models/data_splits/train_data.rds")

feature_stats <- train_data %>%
  select(-target_variable) %>%
  summarise(across(everything(), list(
    mean = ~mean(., na.rm = TRUE),
    sd = ~sd(., na.rm = TRUE),
    min = ~min(., na.rm = TRUE),
    max = ~max(., na.rm = TRUE),
    q25 = ~quantile(., 0.25, na.rm = TRUE),
    q75 = ~quantile(., 0.75, na.rm = TRUE)
  )))

saveRDS(feature_stats, "monitoring/baseline_feature_stats.rds")
```

---

## 2. Setup Model Board for Monitoring

### Initialize Vetiver Board

```r
library(vetiver)
library(pins)

# Create or connect to model board
# Local board for testing
board_local <- board_folder("model_board", versioned = TRUE)

# Posit Connect board for production
board_connect <- board_connect(
  server = "https://connect.example.com",
  key = Sys.getenv("CONNECT_API_KEY")
)

# Pin the model
v_model <- vetiver_model(final_model, model_name = "production_model_v1")
vetiver_pin_write(board_connect, v_model)
```

### Create Metrics Pinboard

```r
# Initialize metrics storage
initial_metrics <- tibble(
  date = Sys.Date(),
  accuracy = baseline_accuracy,
  roc_auc = baseline_roc_auc,
  n_obs = 0,  # Will increment with production predictions
  avg_latency_ms = NA,
  error_rate = 0
)

# Pin initial metrics
pin_write(
  board = board_connect,
  x = initial_metrics,
  name = "production_model_v1_metrics",
  type = "rds"
)
```

---

## 3. Implement Prediction Logging

### Add Logging to API

Modify the Plumber API to log predictions and performance:

```r
# In model_api/plumber.R

library(plumber)
library(vetiver)
library(logger)

# Setup logging
log_appender(appender_file("logs/api_predictions.log"))

#* @apiTitle Production Model API
#* @apiDescription API for model predictions with monitoring

#* Log a new prediction
#* @post /predict
function(req, res) {
  start_time <- Sys.time()

  # Extract input data
  input_data <- jsonlite::fromJSON(req$postBody)

  # Make prediction
  tryCatch({
    prediction <- predict(v_model, new_data = input_data)

    # Calculate latency
    latency_ms <- as.numeric(difftime(Sys.time(), start_time, units = "secs")) * 1000

    # Log prediction
    log_info(paste0(
      "Prediction: ", prediction$.pred_class,
      " | Probability: ", round(prediction$.pred_positive, 3),
      " | Latency: ", round(latency_ms, 2), "ms"
    ))

    # Store prediction for daily aggregation
    log_prediction(input_data, prediction, latency_ms)

    return(prediction)

  }, error = function(e) {
    log_error(paste("Prediction error:", e$message))
    res$status <- 500
    return(list(error = "Prediction failed"))
  })
}

# Helper function to log detailed prediction data
log_prediction <- function(input, prediction, latency) {
  prediction_log <- list(
    timestamp = Sys.time(),
    input = input,
    prediction = prediction,
    latency_ms = latency
  )

  # Append to daily log file
  log_file <- paste0("logs/predictions_", Sys.Date(), ".rds")

  if (file.exists(log_file)) {
    existing_logs <- readRDS(log_file)
    all_logs <- c(existing_logs, list(prediction_log))
  } else {
    all_logs <- list(prediction_log)
  }

  saveRDS(all_logs, log_file)
}
```

---

## 4. Create Monitoring Dashboard

### Quarto Dashboard for Real-Time Monitoring

Create `monitoring/monitoring_dashboard.qmd`:

```markdown
---
title: "Production Model Monitoring Dashboard"
format:
  dashboard:
    theme: cosmo
    orientation: columns
server: shiny
---

```{r}
#| context: setup
#| message: false

library(tidyverse)
library(pins)
library(plotly)
library(DT)
library(vetiver)
library(scales)

# Connect to model board
board <- board_connect(
  server = "https://connect.example.com",
  key = Sys.getenv("CONNECT_API_KEY")
)

# Load baseline
baseline <- readRDS("monitoring/baseline_metrics.rds")
```

```{r}
#| context: server

# Reactive data loading
metrics_data <- reactive({
  pin_read(board, "production_model_v1_metrics")
})

# Auto-refresh every 5 minutes
autoInvalidate <- reactiveTimer(300000)

observe({
  autoInvalidate()
  metrics_data()
})
```

## Column {width="60%"}

### Performance Over Time

```{r}
#| label: performance-trends
#| context: server

output$performance_plot <- renderPlotly({
  metrics <- metrics_data()

  plot_ly(metrics) %>%
    add_trace(
      x = ~date, y = ~accuracy, type = 'scatter', mode = 'lines+markers',
      name = 'Accuracy', line = list(color = 'steelblue')
    ) %>%
    add_trace(
      x = ~date, y = ~roc_auc, type = 'scatter', mode = 'lines+markers',
      name = 'ROC AUC', line = list(color = 'darkgreen')
    ) %>%
    add_lines(
      x = range(metrics$date),
      y = baseline$accuracy,
      name = 'Baseline Accuracy',
      line = list(dash = 'dash', color = 'lightblue')
    ) %>%
    layout(
      title = "Model Performance Trends",
      xaxis = list(title = "Date"),
      yaxis = list(title = "Metric Value", range = c(0, 1)),
      hovermode = 'x unified'
    )
})

plotlyOutput("performance_plot")
```

### Prediction Volume & Latency

```{r}
#| label: volume-latency
#| context: server

output$volume_plot <- renderPlotly({
  metrics <- metrics_data()

  plot_ly(metrics, x = ~date, y = ~n_obs, type = 'bar',
          marker = list(color = 'steelblue'),
          name = 'Predictions') %>%
    layout(
      title = "Daily Prediction Volume",
      xaxis = list(title = "Date"),
      yaxis = list(title = "Number of Predictions")
    )
})

plotlyOutput("volume_plot")
```

## Column {width="40%"}

### Current Status

```{r}
#| label: status-summary
#| context: server

output$status_summary <- renderUI({
  metrics <- metrics_data()
  latest <- tail(metrics, 1)

  # Calculate status
  accuracy_change <- latest$accuracy - baseline$accuracy
  accuracy_status <- if(accuracy_change < -0.05) {
    "⚠️ ALERT"
  } else if(accuracy_change < 0) {
    "⚡ WARNING"
  } else {
    "✅ HEALTHY"
  }

  tagList(
    div(style = "padding: 20px; background-color: #f8f9fa; border-radius: 5px;",
      h3(style = "margin-top: 0;", "Model Status: ", accuracy_status),
      hr(),
      p(strong("Current Accuracy: "), round(latest$accuracy, 3)),
      p(strong("Baseline Accuracy: "), round(baseline$accuracy, 3)),
      p(strong("Change: "),
        span(style = if(accuracy_change < 0) "color: red;" else "color: green;",
             paste0(if(accuracy_change > 0) "+" else "",
                    round(accuracy_change * 100, 2), "%"))),
      hr(),
      p(strong("Predictions Today: "), comma(latest$n_obs)),
      p(strong("Avg Latency: "), round(latest$avg_latency_ms, 2), " ms"),
      p(strong("Error Rate: "), percent(latest$error_rate, accuracy = 0.01))
    )
  )
})

uiOutput("status_summary")
```

### Alert History

```{r}
#| label: alert-history
#| context: server

output$alert_table <- renderDT({
  # Load alert log
  if(file.exists("monitoring/alert_history.csv")) {
    alerts <- read_csv("monitoring/alert_history.csv", show_col_types = FALSE) %>%
      arrange(desc(timestamp)) %>%
      head(10)

    datatable(
      alerts,
      options = list(
        pageLength = 5,
        dom = 't',
        scrollX = TRUE
      ),
      rownames = FALSE
    )
  } else {
    datatable(
      data.frame(message = "No alerts recorded"),
      options = list(dom = 't'),
      rownames = FALSE
    )
  }
})

DTOutput("alert_table")
```

### Actions

```{r}
#| label: actions
#| context: server

output$action_buttons <- renderUI({
  div(style = "padding: 20px;",
    actionButton("refresh_data", "🔄 Refresh Data", class = "btn-primary"),
    br(), br(),
    actionButton("export_report", "📄 Export Report", class = "btn-secondary"),
    br(), br(),
    actionButton("retrain_model", "🔧 Trigger Retraining", class = "btn-warning")
  )
})

uiOutput("action_buttons")
```

## Column {width="100%"}

### Data Drift Detection

```{r}
#| label: data-drift
#| context: server

output$drift_plot <- renderPlotly({
  # Load recent predictions
  recent_logs <- list.files("logs/", pattern = "predictions_.*\\.rds$", full.names = TRUE) %>%
    tail(7) %>%  # Last 7 days
    map_dfr(~{
      logs <- readRDS(.x)
      map_dfr(logs, ~as_tibble(.x$input))
    })

  # Load baseline feature stats
  baseline_stats <- readRDS("monitoring/baseline_feature_stats.rds")

  # Calculate drift (simplified example with one feature)
  # In production, use more sophisticated drift detection
  feature_name <- "feature1"  # Replace with actual important feature

  plot_ly() %>%
    add_histogram(
      x = train_data[[feature_name]],
      name = "Training Distribution",
      opacity = 0.6,
      marker = list(color = 'blue')
    ) %>%
    add_histogram(
      x = recent_logs[[feature_name]],
      name = "Recent Production",
      opacity = 0.6,
      marker = list(color = 'red')
    ) %>%
    layout(
      title = paste("Feature Distribution:", feature_name),
      xaxis = list(title = feature_name),
      yaxis = list(title = "Count"),
      barmode = 'overlay'
    )
})

plotlyOutput("drift_plot")
```
```

**Deploy Dashboard:**

```r
# Deploy to Posit Connect
rsconnect::deployApp(
  appDir = "monitoring/",
  appFiles = "monitoring_dashboard.qmd",
  appTitle = "Production Model Monitoring",
  server = "https://connect.example.com",
  account = "your_account"
)
```

---

## 5. Setup Automated Alerting

### Create Alert System

Create `monitoring/alerting_system.R`:

```r
#!/usr/bin/env Rscript

# Production Model Alerting System
# Run this script on a schedule (e.g., daily via cron)

library(tidyverse)
library(pins)
library(blastula) # For email alerts
library(slackr)   # For Slack alerts (optional)

# Configuration
ALERT_EMAIL <- "datascience-team@example.com"
SLACK_CHANNEL <- "#model-alerts"
PERFORMANCE_THRESHOLD <- 0.05  # Alert if accuracy drops >5%
VOLUME_THRESHOLD <- 100        # Alert if daily predictions < 100

# Load board and metrics
board <- board_connect(
  server = "https://connect.example.com",
  key = Sys.getenv("CONNECT_API_KEY")
)

metrics <- pin_read(board, "production_model_v1_metrics")
baseline <- readRDS("monitoring/baseline_metrics.rds")

# Get latest metrics
latest <- tail(metrics, 1)
previous <- if(nrow(metrics) > 1) metrics[nrow(metrics) - 1, ] else latest

# Initialize alert log
alert_log_file <- "monitoring/alert_history.csv"
if(!file.exists(alert_log_file)) {
  alert_log <- tibble(
    timestamp = as.POSIXct(character()),
    alert_type = character(),
    severity = character(),
    message = character()
  )
  write_csv(alert_log, alert_log_file)
}

# Function to log and send alert
send_alert <- function(alert_type, severity, message) {
  # Log alert
  alert_entry <- tibble(
    timestamp = Sys.time(),
    alert_type = alert_type,
    severity = severity,
    message = message
  )

  write_csv(alert_entry, alert_log_file, append = TRUE)

  # Send email
  if(severity %in% c("HIGH", "CRITICAL")) {
    email <- compose_email(
      body = md(paste0(
        "# Model Alert: ", severity, "\n\n",
        "**Type:** ", alert_type, "\n\n",
        "**Message:** ", message, "\n\n",
        "**Timestamp:** ", Sys.time(), "\n\n",
        "**Action Required:** Review monitoring dashboard immediately.\n\n",
        "[View Dashboard](https://connect.example.com/model-dashboard)"
      ))
    )

    smtp_send(
      email,
      to = ALERT_EMAIL,
      from = "model-monitoring@example.com",
      subject = paste0("🚨 Model Alert: ", alert_type),
      credentials = creds_file("~/.email_creds")
    )
  }

  # Send Slack notification (optional)
  # slackr_msg(
  #   txt = paste0("*", severity, " Alert:* ", message),
  #   channel = SLACK_CHANNEL
  # )

  message(paste0("[", severity, "] ", message))
}

# Check 1: Performance Degradation
accuracy_drop <- baseline$accuracy - latest$accuracy
if(accuracy_drop > PERFORMANCE_THRESHOLD) {
  send_alert(
    alert_type = "Performance Degradation",
    severity = "HIGH",
    message = sprintf(
      "Accuracy dropped by %.2f%% (baseline: %.3f, current: %.3f). Consider retraining.",
      accuracy_drop * 100, baseline$accuracy, latest$accuracy
    )
  )
}

# Check 2: Low Prediction Volume
if(latest$n_obs < VOLUME_THRESHOLD) {
  send_alert(
    alert_type = "Low Volume",
    severity = "MEDIUM",
    message = sprintf(
      "Only %d predictions made today (threshold: %d). Check data pipeline.",
      latest$n_obs, VOLUME_THRESHOLD
    )
  )
}

# Check 3: High Error Rate
if(!is.na(latest$error_rate) && latest$error_rate > 0.01) {
  send_alert(
    alert_type = "High Error Rate",
    severity = "HIGH",
    message = sprintf(
      "Error rate at %.2f%% (threshold: 1%%). Check API logs.",
      latest$error_rate * 100
    )
  )
}

# Check 4: High Latency
if(!is.na(latest$avg_latency_ms) && latest$avg_latency_ms > 1000) {
  send_alert(
    alert_type = "High Latency",
    severity = "MEDIUM",
    message = sprintf(
      "Average latency at %.0fms (threshold: 1000ms). Check system resources.",
      latest$avg_latency_ms
    )
  )
}

# Check 5: Sudden Volume Change
if(nrow(metrics) > 1) {
  volume_change <- abs(latest$n_obs - previous$n_obs) / previous$n_obs
  if(volume_change > 0.5) {  # 50% change
    send_alert(
      alert_type = "Volume Anomaly",
      severity = "LOW",
      message = sprintf(
        "Prediction volume changed by %.0f%% (previous: %d, current: %d).",
        volume_change * 100, previous$n_obs, latest$n_obs
      )
    )
  }
}

message("Alert check complete at ", Sys.time())
```

**Schedule Alerting Script:**

```bash
# Add to crontab for daily execution at 9 AM
crontab -e

# Add this line:
0 9 * * * Rscript /path/to/monitoring/alerting_system.R >> /path/to/monitoring/alert_logs.txt 2>&1
```

---

## 6. Daily Metrics Update Script

Create `monitoring/update_metrics.R`:

```r
#!/usr/bin/env Rscript

# Daily Metrics Update
# Aggregates daily predictions and updates metrics pinboard

library(tidyverse)
library(pins)
library(yardstick)

# Load board
board <- board_connect(
  server = "https://connect.example.com",
  key = Sys.getenv("CONNECT_API_KEY")
)

# Load yesterday's prediction logs
yesterday <- Sys.Date() - 1
log_file <- paste0("logs/predictions_", yesterday, ".rds")

if(!file.exists(log_file)) {
  message("No predictions logged for ", yesterday)
  quit()
}

# Load prediction logs
daily_logs <- readRDS(log_file)

# Extract predictions and true labels (if available)
predictions <- map_dfr(daily_logs, ~{
  tibble(
    timestamp = .x$timestamp,
    prediction = .x$prediction$.pred_class,
    probability = .x$prediction$.pred_positive,
    latency_ms = .x$latency_ms
    # Add true_label if available from feedback loop
  )
})

# Calculate daily metrics
n_predictions <- nrow(predictions)
avg_latency <- mean(predictions$latency_ms, na.rm = TRUE)

# If true labels available (from feedback/monitoring system)
# Calculate actual performance
# For now, use predicted performance or manual review
daily_accuracy <- NA  # Update with actual accuracy if labels available
daily_roc_auc <- NA   # Update with actual ROC AUC if labels available

# Load existing metrics
existing_metrics <- pin_read(board, "production_model_v1_metrics")

# Append new daily metrics
new_metrics <- existing_metrics %>%
  add_row(
    date = yesterday,
    accuracy = daily_accuracy,
    roc_auc = daily_roc_auc,
    n_obs = n_predictions,
    avg_latency_ms = avg_latency,
    error_rate = 0  # Calculate from API error logs
  )

# Update pinboard
pin_write(
  board = board,
  x = new_metrics,
  name = "production_model_v1_metrics",
  type = "rds"
)

message("Metrics updated for ", yesterday)
message("Predictions: ", n_predictions)
message("Avg Latency: ", round(avg_latency, 2), "ms")
```

**Schedule Metrics Update:**

```bash
# Run daily at midnight
0 0 * * * Rscript /path/to/monitoring/update_metrics.R >> /path/to/monitoring/update_logs.txt 2>&1
```

---

## 7. Retraining Triggers

Define conditions that trigger model retraining:

### Automatic Retraining Conditions

1. **Performance Degradation**: Accuracy drops >5% below baseline
2. **Data Drift**: Feature distributions shift significantly (KS test p < 0.05)
3. **Time-Based**: Monthly scheduled retraining
4. **Volume-Based**: After N new predictions (e.g., 10,000)

### Retraining Workflow

Create `monitoring/trigger_retraining.R`:

```r
# Trigger Model Retraining
# Called automatically when conditions met

library(tidyverse)
library(pins)

# Load metrics
board <- board_connect(
  server = "https://connect.example.com",
  key = Sys.getenv("CONNECT_API_KEY")
)

metrics <- pin_read(board, "production_model_v1_metrics")
baseline <- readRDS("monitoring/baseline_metrics.rds")

# Check retraining conditions
latest <- tail(metrics, 1)
should_retrain <- FALSE
retrain_reason <- ""

# Condition 1: Performance drop
if(!is.na(latest$accuracy) && (baseline$accuracy - latest$accuracy) > 0.05) {
  should_retrain <- TRUE
  retrain_reason <- "Performance degradation >5%"
}

# Condition 2: Time-based (monthly)
days_since_deployment <- as.numeric(difftime(Sys.Date(), baseline$date, units = "days"))
if(days_since_deployment >= 30) {
  should_retrain <- TRUE
  retrain_reason <- paste0(retrain_reason, " | 30+ days since last training")
}

# Condition 3: Volume-based
total_predictions <- sum(metrics$n_obs, na.rm = TRUE)
if(total_predictions >= 10000) {
  should_retrain <- TRUE
  retrain_reason <- paste0(retrain_reason, " | 10K+ new predictions")
}

# If retraining needed
if(should_retrain) {
  message("RETRAINING TRIGGERED: ", retrain_reason)

  # Log retraining trigger
  trigger_log <- tibble(
    timestamp = Sys.time(),
    reason = retrain_reason,
    status = "pending"
  )

  write_csv(trigger_log, "monitoring/retraining_triggers.csv", append = TRUE)

  # Notify data science team
  # Send email/Slack notification

  # Optionally: Automatically start retraining pipeline
  # system("Rscript /path/to/retraining_pipeline.R &")
}
```

---

## Summary

**Monitoring Infrastructure Checklist:**

- [ ] Baseline metrics captured and saved
- [ ] Vetiver board configured for metrics storage
- [ ] Prediction logging implemented in API
- [ ] Quarto dashboard created and deployed
- [ ] Alerting system configured and scheduled
- [ ] Daily metrics update script scheduled
- [ ] Retraining triggers defined
- [ ] Documentation complete

**Key Files:**

- `monitoring/baseline_metrics.rds` — Test set performance baseline
- `monitoring/monitoring_dashboard.qmd` — Real-time dashboard
- `monitoring/alerting_system.R` — Automated alert script
- `monitoring/update_metrics.R` — Daily metrics aggregation
- `monitoring/trigger_retraining.R` — Retraining decision logic
- `monitoring/alert_history.csv` — Alert log
- `logs/predictions_YYYY-MM-DD.rds` — Daily prediction logs

**Maintenance Schedule:**

- **Daily**: Metrics update, alert checks
- **Weekly**: Dashboard review, alert log review
- **Monthly**: Retraining evaluation, documentation update

---

_Monitoring guide version: 1.0_
_Created: 2026-03-17_
_Part of: RDS prototype-to-production workflow_
