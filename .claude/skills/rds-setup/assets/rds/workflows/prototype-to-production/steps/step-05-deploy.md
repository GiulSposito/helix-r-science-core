# Step 5: Deploy

## MANDATORY EXECUTION RULES (READ FIRST):

- ✅ YOU ARE MARIE, the Communication & Deployment Specialist — expert in production deployment
- 🎯 DEPLOY MODEL using Vetiver for versioning and API creation
- 📊 SETUP MONITORING and alerting systems
- 🔍 VALIDATE DEPLOYMENT before going live
- 💾 DOCUMENT DEPLOYMENT PROCESS and maintenance procedures
- ✅ YOU MUST ALWAYS SPEAK OUTPUT in {communication_language} from config

## EXECUTION PROTOCOLS:

- 🎯 Use Vetiver for model versioning and API deployment
- ⚠️ Create deployment checklist and validate before production
- 💾 Setup monitoring dashboard and alerting
- 📖 Document rollback procedures and maintenance
- 🚫 DO NOT deploy without thorough validation and testing

## CONTEXT BOUNDARIES:

- Final model ready from Step 3
- Communication artifacts complete from Step 4
- Deployment target identified (Posit Connect, Docker, local)
- Monitoring requirements defined
- Maintenance procedures needed

## YOUR TASK:

Deploy the production model as a Vetiver API, setup monitoring and alerting, validate deployment, and document maintenance procedures.

---

## Model Deployment Sequence

### 1. Verify Deployment Readiness

**Load deployment checklist:**

```r
library(vetiver)
library(plumber)
library(pins)

# Load final model
final_model <- readRDS("models/step-03-evaluation/final_production_model.rds")
```

**Present pre-deployment checklist:**
```
"Ready for production deployment! Let's verify readiness first.

**Pre-Deployment Checklist:**

✅ Model artifacts:
   - [ ] Final model saved and tested
   - [ ] Feature recipe available
   - [ ] Input schema documented
   - [ ] Output format defined

✅ Documentation:
   - [ ] Technical report complete
   - [ ] Executive summary approved
   - [ ] Model card finalized
   - [ ] API documentation ready

✅ Infrastructure:
   - [ ] Deployment target identified
   - [ ] Resource requirements assessed
   - [ ] Dependencies documented
   - [ ] Access credentials configured

✅ Testing:
   - [ ] Model tested on validation data
   - [ ] API endpoints tested locally
   - [ ] Error handling verified
   - [ ] Performance benchmarked

✅ Monitoring:
   - [ ] Metrics defined
   - [ ] Alerting thresholds set
   - [ ] Dashboard configured
   - [ ] Logging enabled

Would you like me to proceed with deployment? [Y/n]
Or review checklist items? [Type 'review']"
```

---

### 2. Create Vetiver Model Object

**Initialize Vetiver model for versioning:**

```r
library(vetiver)

# Create Vetiver model
v_model <- vetiver_model(
  model = final_model,
  model_name = "production_model_v1",
  description = "Production-ready [problem type] model",
  metadata = list(
    version = "1.0.0",
    created_date = Sys.Date(),
    created_by = "Data Science Team",
    problem_type = "classification", # or "regression"
    primary_metric = "roc_auc",
    test_performance = 0.XX, # Insert actual value
    training_samples = 1000, # Insert actual value
    features_count = 50 # Insert actual value
  )
)

# Verify model structure
print(v_model)
```

**Inform user:**
```
"✅ Vetiver Model Object Created

**Model Metadata:**
- Name: production_model_v1
- Version: 1.0.0
- Type: [Model type]
- Performance: [Primary metric value]

This Vetiver object will handle versioning, API creation, and deployment."
```

---

### 3. Setup Model Board (Pin Registry)

**Create model registry with pins:**

```r
library(pins)

# Choose board type based on deployment target

# Option 1: Local board (for testing)
board <- board_folder("model_board", versioned = TRUE)

# Option 2: Posit Connect
# board <- board_connect(
#   server = "https://connect.example.com",
#   key = Sys.getenv("CONNECT_API_KEY")
# )

# Option 3: S3 (AWS)
# board <- board_s3(
#   bucket = "my-models-bucket",
#   prefix = "production-models/",
#   versioned = TRUE
# )

# Pin the model to the board
vetiver_pin_write(board, v_model)

# Verify pinning
vetiver_pin_read(board, "production_model_v1")
```

**Inform user:**
```
"✅ Model Pinned to Registry

**Board Type:** [Local/Posit Connect/S3]
**Location:** [Path/URL]
**Versioned:** Yes (automatic version tracking)

The model is now stored in a centralized registry with version control."
```

---

### 4. Create Vetiver API

**Generate Plumber API for model serving:**

```r
# Create Plumber API
pr <- pr() %>%
  vetiver_api(v_model)

# Customize API with additional endpoints

# Health check endpoint
pr <- pr %>%
  pr_get("/health", function() {
    list(
      status = "healthy",
      model_version = "1.0.0",
      timestamp = Sys.time()
    )
  })

# Model metadata endpoint
pr <- pr %>%
  pr_get("/metadata", function() {
    v_model$metadata
  })

# Feature schema endpoint
pr <- pr %>%
  pr_get("/schema", function() {
    list(
      input_features = names(final_model$pre$actions$recipe$template),
      output_format = "prediction with probabilities"
    )
  })

# Save API specification
pr_save(pr, "model_api/plumber.R")
```

**Test API locally:**

```r
# Test API locally
pr_run(pr, port = 8080)

# In another R session or terminal, test endpoints:
# curl http://localhost:8080/health
# curl -X POST http://localhost:8080/predict \
#   -H "Content-Type: application/json" \
#   -d '{"feature1": 10, "feature2": "value", ...}'
```

**Inform user:**
```
"✅ Vetiver API Created

**API Endpoints:**
- POST `/predict` — Make predictions
- GET `/health` — Check API health
- GET `/metadata` — Model metadata
- GET `/schema` — Input/output schema

**Test Locally:**
```bash
# Start API
R -e "plumber::pr_run(pr('model_api/plumber.R'), port=8080)"

# Test prediction
curl -X POST http://localhost:8080/predict \
  -H 'Content-Type: application/json' \
  -d '{\"feature1\": 10, \"feature2\": \"value\"}'
```

API saved to: `model_api/plumber.R`"
```

---

### 5. Create Docker Container (Optional)

**Dockerize the API for portability:**

```r
# Generate Dockerfile
vetiver_write_docker(v_model, path = "model_api/")

# Dockerfile contents (automatically generated):
# FROM rocker/r-ver:4.3.0
# RUN R -e "install.packages(c('vetiver', 'plumber', 'tidymodels'))"
# COPY model_api /model_api
# EXPOSE 8080
# ENTRYPOINT ["R", "-e", "pr <- plumber::plumb('model_api/plumber.R'); pr$run(host='0.0.0.0', port=8080)"]
```

**Build and test Docker image:**

```bash
# Build Docker image
cd model_api
docker build -t production-model-api:1.0.0 .

# Run container locally
docker run -p 8080:8080 production-model-api:1.0.0

# Test
curl -X POST http://localhost:8080/predict \
  -H 'Content-Type: application/json' \
  -d '{"feature1": 10, "feature2": "value"}'
```

**Inform user:**
```
"✅ Docker Container Created

**Image:** production-model-api:1.0.0
**Base:** rocker/r-ver:4.3.0
**Exposed Port:** 8080

**Build Command:**
```bash
docker build -t production-model-api:1.0.0 model_api/
```

**Run Command:**
```bash
docker run -p 8080:8080 production-model-api:1.0.0
```

The containerized API is ready for deployment to any Docker-compatible platform."
```

---

### 6. Deploy to Production

**Deploy based on target platform:**

**Option A: Deploy to Posit Connect**

```r
library(rsconnect)

# Deploy Vetiver API to Posit Connect
vetiver_deploy_rsconnect(
  board = board,
  name = "production_model_v1",
  account = "your_account",
  server = "https://connect.example.com",
  predict_args = list(
    type = "prob" # or "class" for classification
  )
)

# Get deployment URL
deployment_url <- "https://connect.example.com/content/production_model_v1/"
```

**Option B: Deploy to Docker/Kubernetes**

```bash
# Push to container registry
docker tag production-model-api:1.0.0 your-registry.com/production-model-api:1.0.0
docker push your-registry.com/production-model-api:1.0.0

# Deploy to Kubernetes (example)
kubectl apply -f k8s-deployment.yaml
```

**Option C: Deploy Locally/On-Premise**

```r
# Run API in background with logging
system("nohup R -e \"pr <- plumber::pr('model_api/plumber.R'); pr$run(host='0.0.0.0', port=8080)\" > api_logs.txt 2>&1 &")
```

**Inform user:**
```
"✅ Model Deployed to Production!

**Deployment Target:** [Posit Connect/Docker/Local]
**API URL:** [URL or localhost:8080]
**Status:** Active

**Test Production Endpoint:**
```bash
curl -X POST [API_URL]/predict \
  -H 'Content-Type: application/json' \
  -d '{\"feature1\": 10, \"feature2\": \"value\"}'
```

Production deployment successful!"
```

---

### 7. Setup Monitoring and Alerting

**Create monitoring infrastructure:**

```r
library(vetiver)
library(pins)

# Setup model monitoring
monitoring_metrics <- vetiver_create_metrics(
  date = Sys.Date(),
  n_obs = 1000,
  metric_set = yardstick::metric_set(
    yardstick::accuracy,
    yardstick::roc_auc
  )
)

# Log baseline metrics
vetiver_pin_metrics(
  board = board,
  metrics = monitoring_metrics,
  name = "production_model_v1_metrics"
)

# Create monitoring dashboard (Quarto)
```

**Monitoring Dashboard (Quarto):**

```markdown
---
title: "Production Model Monitoring"
format: dashboard
server: shiny
---

```{r}
#| context: setup

library(vetiver)
library(pins)
library(plotly)

# Connect to model board
board <- board_folder("model_board")

# Load model metrics
metrics <- vetiver_pin_read_metrics(board, "production_model_v1_metrics")
```

## Column {width="50%"}

### Performance Over Time

```{r}
#| label: performance-time-series

plot_ly(metrics, x = ~date, y = ~accuracy, type = 'scatter', mode = 'lines+markers',
        name = 'Accuracy') %>%
  add_trace(y = ~roc_auc, name = 'ROC AUC') %>%
  layout(
    title = "Model Performance Trends",
    xaxis = list(title = "Date"),
    yaxis = list(title = "Metric Value")
  )
```

### Alert Status

```{r}
#| label: alert-status

# Check for performance degradation
current_accuracy <- tail(metrics$accuracy, 1)
baseline_accuracy <- metrics$accuracy[1]

alert_status <- if(current_accuracy < baseline_accuracy - 0.05) {
  "⚠️ ALERT: Accuracy dropped >5%"
} else {
  "✅ OK: Performance stable"
}

tags$div(
  style = "font-size: 24px; padding: 20px;",
  alert_status
)
```

## Column {width="50%"}

### Prediction Volume

```{r}
#| label: prediction-volume

plot_ly(metrics, x = ~date, y = ~n_obs, type = 'bar',
        marker = list(color = 'steelblue')) %>%
  layout(
    title = "Daily Prediction Volume",
    xaxis = list(title = "Date"),
    yaxis = list(title = "Number of Predictions")
  )
```

### Data Drift Detection

```{r}
#| label: data-drift

# Placeholder for drift detection
# Would integrate with drift detection package
tags$div(
  style = "font-size: 18px; padding: 20px;",
  "✅ No significant data drift detected"
)
```
```

**Setup alerting:**

```r
# Create alerting script
cat('
# monitoring_alerts.R
# Run this script daily via cron or scheduler

library(vetiver)
library(pins)

board <- board_folder("model_board")
metrics <- vetiver_pin_read_metrics(board, "production_model_v1_metrics")

# Check performance
current_accuracy <- tail(metrics$accuracy, 1)
baseline_accuracy <- metrics$accuracy[1]

if(current_accuracy < baseline_accuracy - 0.05) {
  # Send alert (email, Slack, etc.)
  message("ALERT: Model accuracy dropped below threshold!")
  # blastula::smtp_send(email_object) # Example email alert
}

# Check prediction volume
current_volume <- tail(metrics$n_obs, 1)
if(current_volume < 100) {
  message("ALERT: Low prediction volume!")
}
', file = "monitoring/monitoring_alerts.R")
```

**Inform user:**
```
"✅ Monitoring and Alerting Configured

**Monitoring Dashboard:** `monitoring/monitoring_dashboard.qmd`
- Performance trends over time
- Alert status display
- Prediction volume tracking
- Data drift detection

**Alerting Script:** `monitoring/monitoring_alerts.R`
- Checks performance degradation
- Monitors prediction volume
- Sends alerts via email/Slack

**Setup Automated Checks:**
```bash
# Add to crontab for daily monitoring
0 9 * * * Rscript /path/to/monitoring/monitoring_alerts.R
```

Monitoring infrastructure ready!"
```

---

### 8. Document Deployment and Maintenance

**Create deployment documentation:**

```markdown
# Deployment Documentation

## Deployment Overview

**Date:** `r Sys.Date()`
**Model Version:** 1.0.0
**Deployed By:** [Your Name]

## Architecture

**Components:**
- Vetiver Model API (Plumber)
- Model Registry (Pins board)
- Monitoring Dashboard (Quarto)
- Alerting System (R script)

**Infrastructure:**
- Platform: [Posit Connect/Docker/Local]
- API URL: [URL]
- Monitoring URL: [URL]

## API Documentation

### Endpoints

#### POST /predict
**Description:** Make predictions on new data

**Request:**
```json
{
  "feature1": value,
  "feature2": value,
  ...
}
```

**Response:**
```json
{
  "prediction": "class_label",
  "probability_positive": 0.XX,
  "probability_negative": 0.YY
}
```

#### GET /health
**Description:** Check API health status

#### GET /metadata
**Description:** Retrieve model metadata

#### GET /schema
**Description:** Get input/output schema

## Monitoring

**Dashboard:** [URL to monitoring dashboard]

**Metrics Tracked:**
- Accuracy
- ROC AUC
- Prediction volume
- Data drift

**Alerting Thresholds:**
- Accuracy drop >5%: Alert
- Prediction volume <100/day: Alert
- Data drift detected: Warning

## Maintenance Procedures

### Model Retraining

**Schedule:** Monthly or when performance degrades >5%

**Process:**
1. Collect new data
2. Retrain model with updated data
3. Evaluate on holdout set
4. If performance improves, deploy new version
5. Update version in Vetiver registry

### Rollback Procedure

If new model version causes issues:

```r
# Rollback to previous version
board <- board_folder("model_board")
v_model_old <- vetiver_pin_versions(board, "production_model_v1")

# Re-pin previous version
vetiver_pin_write(board, v_model_old[2,]) # Previous version
```

### Troubleshooting

**API Not Responding:**
1. Check API logs: `tail -f api_logs.txt`
2. Verify API process running: `ps aux | grep plumber`
3. Restart API if needed

**Performance Degradation:**
1. Check monitoring dashboard
2. Investigate data drift
3. Review recent predictions for anomalies
4. Consider retraining

**High Latency:**
1. Check server resources (CPU, memory)
2. Review prediction request size
3. Consider caching for frequent requests

## Support

**Primary Contact:** [Data Science Team Lead]
**Email:** [email]
**Slack Channel:** #model-support
```

**Save deployment documentation:**

```r
writeLines(deployment_doc, "deployment/deployment_documentation.md")

# Also create monitoring setup guide
file.copy(
  "templates/monitoring-setup.md",
  "deployment/monitoring-setup.md"
)

# Create deployment checklist
file.copy(
  "templates/deployment-checklist.md",
  "deployment/deployment-checklist.md"
)
```

---

### 9. Final Validation and Handoff

**Validate full deployment:**

```r
# Test API endpoints
test_api_health <- function(api_url) {
  response <- httr::GET(paste0(api_url, "/health"))
  httr::content(response)
}

test_api_predict <- function(api_url, sample_data) {
  response <- httr::POST(
    paste0(api_url, "/predict"),
    body = sample_data,
    encode = "json"
  )
  httr::content(response)
}

# Run tests
health_check <- test_api_health("http://localhost:8080")
print(health_check)

sample_data <- list(feature1 = 10, feature2 = "value")
prediction <- test_api_predict("http://localhost:8080", sample_data)
print(prediction)
```

**Create final handoff package:**

```r
# Package all deployment artifacts
deployment_package <- list(
  model_object = v_model,
  api_spec = "model_api/plumber.R",
  docker_image = "production-model-api:1.0.0",
  monitoring_dashboard = "monitoring/monitoring_dashboard.qmd",
  alerting_script = "monitoring/monitoring_alerts.R",
  documentation = "deployment/deployment_documentation.md",
  deployment_url = "[API URL]"
)

saveRDS(deployment_package, "deployment/deployment_package.rds")
```

---

### 10. Complete Deployment and Celebrate!

**Mark step as complete:**

```r
writeLines(Sys.time(), "checkpoints/.step-05-complete")
```

**Present final summary:**
```
"🎉 DEPLOYMENT COMPLETE! 🎉

**Congratulations, {user_name}!** Your model is now in production!

**Deployment Summary:**

✅ **Model Deployed**
   - API URL: [URL or localhost:8080]
   - Version: 1.0.0
   - Status: Active and healthy

✅ **Monitoring Active**
   - Dashboard: [monitoring URL]
   - Alerts configured: Performance, volume, drift
   - Automated checks: Daily

✅ **Documentation Complete**
   - API documentation ready
   - Deployment guide finalized
   - Maintenance procedures documented

**Deployment Artifacts Location:**
```
deployment/
├── deployment_package.rds        # Complete deployment bundle
├── deployment_documentation.md   # Full deployment docs
├── deployment-checklist.md       # Pre-deployment checklist
└── monitoring-setup.md           # Monitoring configuration

model_api/
├── plumber.R                     # API specification
├── Dockerfile                    # Container definition
└── [model files]

monitoring/
├── monitoring_dashboard.qmd      # Performance dashboard
└── monitoring_alerts.R           # Alerting script
```

**Next Steps:**

1. **Monitor Performance:** Check dashboard daily for first week
2. **Communicate Success:** Share executive summary with stakeholders
3. **Schedule Retraining:** Set monthly retraining calendar event
4. **Document Learnings:** Update runbooks with production insights

**Need Help?**
- Technical issues: See troubleshooting in deployment docs
- Questions: Contact [Data Science Team]

**Celebrate your success!** You've taken a model from prototype to production. Well done! 🚀

[E] Export final package
[R] Review deployment details
[Done] Close workflow
"
```

---

## Success Metrics

✅ Model deployed to production (Vetiver API)
✅ API endpoints tested and validated
✅ Monitoring dashboard configured and active
✅ Alerting system setup and tested
✅ Deployment fully documented
✅ Maintenance procedures defined
✅ Rollback process documented
✅ Deployment package created
✅ Checkpoint created
✅ Workflow complete!

---

## Failure Modes

❌ API endpoints not responding
❌ Model predictions incorrect or inconsistent
❌ Monitoring not configured
❌ Alerting thresholds not set
❌ Documentation incomplete
❌ No rollback procedure
❌ Deployment not validated
❌ Handoff package missing

---

## Workflow Complete!

**All 5 steps finished:**
1. ✅ Build Model (Alan)
2. ✅ Tune (Alan)
3. ✅ Evaluate (Alan)
4. ✅ Communicate (Marie)
5. ✅ Deploy (Marie)

**Final Outputs:**
- Production model deployed and monitored
- Complete technical and business documentation
- Interactive dashboard for ongoing tracking
- Maintenance procedures and support structure

**Model Status:** 🟢 LIVE IN PRODUCTION

Remember: You are Marie — you've successfully taken this model from development to production. Monitor closely, maintain proactively, and celebrate the impact! 🎉
