# Phase 10: Deploy

**Owner:** Marie (Communicator)
**Duration:** 2-4 hours
**Status:** Active

---

## Phase Goal

Deploy model to production as a Vetiver API, setup monitoring, establish feedback loops, and create maintenance plan.

---

## Prerequisites

- Phase 9 complete (communication materials ready)
- Final model in `outputs/models/final_model.rds`
- Feature recipe in `outputs/models/feature_recipe.rds`
- Deployment environment identified (local, cloud, Posit Connect)
- IT/DevOps coordination (if needed)

---

## Continuation from Phase 9

**Marie continues:**
With our model validated and communicated, it's time to deploy to production and establish the infrastructure for long-term success.

---

## Step-by-Step Instructions

### 1. Define Deployment Strategy

**What I need from you:**

1. **Deployment Target**:
   - Local server (RStudio Connect, Posit Connect)?
   - Cloud platform (AWS, Azure, GCP)?
   - Edge deployment (on-device)?
   - Batch predictions (scheduled jobs)?

2. **API Requirements**:
   - Expected request volume (requests/second)?
   - Latency requirements (response time)?
   - Authentication needed?
   - Logging requirements?

3. **Infrastructure**:
   - Docker container?
   - Kubernetes?
   - Serverless functions?

### 2. Setup Vetiver for Model Deployment

**Vetiver = MLOps framework for R models**

```r
library(tidyverse)
library(tidymodels)
library(vetiver)
library(plumber)
library(pins)
library(here)

# Load final model
final_model <- read_rds(here("outputs", "models", "final_model.rds"))

# Create vetiver model object
v <- final_model |>
  vetiver_model(
    model_name = "{project-name-model}",
    description = "{Brief description}",
    metadata = list(
      version = "1.0",
      created = Sys.Date(),
      performance = list(
        test_accuracy = {value},
        test_auc = {value}
      ),
      owner = "Data Science Team"
    )
  )

cat("Vetiver model created:\n")
print(v)
```

### 3. Create Model Pin

**Pin = versioned model storage**

```r
# Option 1: Local pin board (for testing)
board <- board_folder(here("outputs", "models", "pins"))

# Option 2: Posit Connect
# board <- board_connect()

# Option 3: Cloud storage
# board <- board_s3(bucket = "my-models")
# board <- board_azure(container = "models")

# Pin the model
board |>
  vetiver_pin_write(v)

cat("Model pinned successfully!\n")

# Verify
pinned_model <- board |>
  vetiver_pin_read("{project-name-model}")

cat("\nPinned model verified:\n")
print(pinned_model)
```

### 4. Create API Endpoint

**Build Plumber API:**

```r
# Generate API definition
vetiver_write_plumber(board, "{project-name-model}")

# This creates: plumber.R
# Customize if needed
```

**`plumber.R` (auto-generated, customize as needed):**

```r
library(vetiver)
library(plumber)

# Load model from pin
board <- board_folder(here("outputs", "models", "pins"))
v <- vetiver_pin_read(board, "{project-name-model}")

#* @apiTitle {Project Name} Model API
#* @apiDescription Predict {outcome} using trained model

#* Health check
#* @get /health
function() {
  list(
    status = "healthy",
    model_name = "{project-name-model}",
    version = "1.0",
    timestamp = Sys.time()
  )
}

#* Model metadata
#* @get /metadata
function() {
  list(
    model_type = class(v$model)[1],
    features = names(v$prototype),
    performance = v$metadata$performance,
    created = v$metadata$created
  )
}

#* Predict endpoint
#* @post /predict
#* @param req:body Data frame of features
function(req) {
  # Parse request body
  data <- jsonlite::fromJSON(req$postBody)

  # Validate inputs
  required_features <- names(v$prototype)
  missing_features <- setdiff(required_features, names(data))

  if (length(missing_features) > 0) {
    stop("Missing required features: ", paste(missing_features, collapse = ", "))
  }

  # Make prediction
  prediction <- predict(v, new_data = data)

  # Return result
  list(
    predictions = prediction$.pred,
    prediction_class = prediction$.pred_class,  # For classification
    confidence = max(prediction$.pred_{positive_class}),  # For classification
    model_version = "1.0",
    timestamp = Sys.time()
  )
}

#* Batch predict
#* @post /predict_batch
function(req) {
  data <- jsonlite::fromJSON(req$postBody)
  predictions <- predict(v, new_data = data)

  list(
    n_predictions = nrow(predictions),
    predictions = predictions,
    model_version = "1.0",
    timestamp = Sys.time()
  )
}
```

### 5. Test API Locally

```r
# Run API locally
pr <- plumber::plumb(here("plumber.R"))
pr$run(port = 8000)

# In another R session or terminal, test:
# curl http://127.0.0.1:8000/health
# curl -X POST http://127.0.0.1:8000/predict -H "Content-Type: application/json" -d '{"feature1": value, "feature2": value}'
```

**Create test script:**

```r
# scripts/10-deploy.R

# Test API endpoints
library(httr)

base_url <- "http://127.0.0.1:8000"

# Test health check
response <- GET(paste0(base_url, "/health"))
content(response)

# Test metadata
response <- GET(paste0(base_url, "/metadata"))
content(response)

# Test prediction
test_data <- list(
  feature1 = value,
  feature2 = value,
  feature3 = value
)

response <- POST(
  paste0(base_url, "/predict"),
  body = test_data,
  encode = "json"
)

prediction <- content(response)
cat("\nPrediction result:\n")
print(prediction)

# Test batch prediction
test_batch <- list(
  data.frame(
    feature1 = c(value1, value2),
    feature2 = c(value1, value2)
  )
)

response <- POST(
  paste0(base_url, "/predict_batch"),
  body = jsonlite::toJSON(test_batch),
  encode = "json",
  content_type_json()
)

batch_predictions <- content(response)
cat("\nBatch predictions:\n")
print(batch_predictions)
```

### 6. Containerize with Docker

**Create Dockerfile:**

```dockerfile
FROM rocker/r-ver:4.3.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('tidyverse', 'tidymodels', 'vetiver', 'plumber', 'pins'))"

# Copy application files
WORKDIR /app
COPY plumber.R /app/
COPY outputs/models/ /app/outputs/models/

# Expose port
EXPOSE 8000

# Run API
CMD ["R", "-e", "pr <- plumber::plumb('plumber.R'); pr$run(host='0.0.0.0', port=8000)"]
```

**Build and test container:**

```bash
# Build image
docker build -t {project-name-model}:1.0 .

# Run container
docker run -p 8000:8000 {project-name-model}:1.0

# Test
curl http://localhost:8000/health
```

### 7. Deploy to Production

**Option A: Posit Connect**

```r
library(rsconnect)

# Configure Connect
rsconnect::addConnectServer(
  url = "https://connect.example.com",
  name = "prod-connect"
)

# Deploy API
vetiver_deploy_rsconnect(
  board = board,
  name = "{project-name-model}",
  predict_args = list(
    type = "class"  # Or "prob" for classification
  ),
  server = "prod-connect"
)

cat("Model deployed to Posit Connect!\n")
cat("URL: https://connect.example.com/content/{content-id}/\n")
```

**Option B: Cloud Platform (AWS)**

```r
# Deploy to AWS SageMaker, Lambda, or ECS
# (Requires additional setup with AWS CLI and boto3/reticulate)

# Example: Push Docker image to ECR
system("aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin {account}.dkr.ecr.us-east-1.amazonaws.com")
system("docker tag {project-name-model}:1.0 {account}.dkr.ecr.us-east-1.amazonaws.com/{project-name-model}:1.0")
system("docker push {account}.dkr.ecr.us-east-1.amazonaws.com/{project-name-model}:1.0")

cat("Docker image pushed to AWS ECR\n")
cat("Next: Deploy via ECS, Lambda, or SageMaker\n")
```

**Option C: Self-Hosted Server**

```bash
# Copy files to server
scp -r plumber.R outputs/ user@server:/path/to/app/

# SSH into server
ssh user@server

# Run with systemd or pm2 for process management
# Create systemd service file: /etc/systemd/system/{project-name-model}.service
```

### 8. Setup Monitoring

**A. Model Performance Monitoring**

```r
# Create monitoring dashboard with vetiver
library(vetiver)

# Log predictions for monitoring
vetiver_write_docker(v)

# Create monitoring metrics
monitoring_metrics <- tibble(
  timestamp = Sys.time(),
  n_predictions = {n},
  mean_confidence = {value},
  prediction_distribution = list({distribution})
)

# Save to database or pin
write_csv(monitoring_metrics, here("outputs", "monitoring", paste0("metrics_", Sys.Date(), ".csv")))
```

**B. Create Monitoring Dashboard (Quarto)**

**`reports/monitoring-dashboard.qmd`:**

```markdown
---
title: "{Project Name} - Model Monitoring"
format:
  dashboard:
    theme: cosmo
    orientation: rows
---

```{r}
#| include: false
library(tidyverse)
library(here)

# Load monitoring data
monitoring_data <- read_csv(here("outputs", "monitoring", "latest_metrics.csv"))
predictions_log <- read_csv(here("outputs", "monitoring", "predictions_log.csv"))
```

## Row {height=25%}

### {.value-box}
Total Predictions
```{r}
nrow(predictions_log)
```

### {.value-box}
Avg Confidence
```{r}
round(mean(predictions_log$confidence), 3)
```

### {.value-box}
API Uptime
```{r}
"99.8%"
```

## Row {height=75%}

### Prediction Volume Over Time
```{r}
predictions_log |>
  count(date = as.Date(timestamp)) |>
  ggplot(aes(x = date, y = n)) +
  geom_line() +
  geom_point() +
  labs(title = "Daily Predictions", y = "Count") +
  theme_minimal()
```

### Confidence Distribution
```{r}
predictions_log |>
  ggplot(aes(x = confidence)) +
  geom_histogram(bins = 30, fill = "steelblue") +
  labs(title = "Prediction Confidence", x = "Confidence") +
  theme_minimal()
```
```

**C. Setup Alerts**

```r
# Create alert function
check_model_health <- function() {
  # Load recent predictions
  recent_preds <- read_csv(here("outputs", "monitoring", "predictions_log.csv"))

  # Calculate metrics
  avg_confidence <- mean(recent_preds$confidence, na.rm = TRUE)
  prediction_rate <- nrow(recent_preds)

  # Define thresholds
  alerts <- list()

  if (avg_confidence < 0.7) {
    alerts <- append(alerts, "⚠ Average confidence below threshold (0.7)")
  }

  if (prediction_rate < 100) {
    alerts <- append(alerts, "⚠ Low prediction volume (< 100 daily)")
  }

  # Check for data drift (simplified)
  # In production, use proper drift detection methods

  if (length(alerts) > 0) {
    cat("ALERTS:\n")
    for (alert in alerts) {
      cat("-", alert, "\n")
    }

    # Send email/Slack notification
    # send_notification(alerts)
  } else {
    cat("✓ All systems healthy\n")
  }
}

# Schedule with cron or taskscheduleR
library(taskscheduleR)
taskscheduler_create(
  taskname = "{project-name}-health-check",
  rscript = here("scripts", "check-health.R"),
  schedule = "DAILY",
  starttime = "09:00"
)
```

### 9. Create Feedback Loop

**Collect ground truth for continuous improvement:**

```r
# Create feedback collection endpoint
#* Provide feedback
#* @post /feedback
#* @param prediction_id:string ID of prediction
#* @param actual:string Actual outcome
function(prediction_id, actual) {
  feedback <- tibble(
    prediction_id = prediction_id,
    actual = actual,
    timestamp = Sys.time()
  )

  # Append to feedback log
  write_csv(
    feedback,
    here("outputs", "monitoring", "feedback_log.csv"),
    append = TRUE
  )

  list(
    status = "success",
    message = "Feedback recorded"
  )
}

# Analyze feedback periodically
analyze_feedback <- function() {
  feedback <- read_csv(here("outputs", "monitoring", "feedback_log.csv"))
  predictions <- read_csv(here("outputs", "monitoring", "predictions_log.csv"))

  # Join feedback with predictions
  performance <- predictions |>
    inner_join(feedback, by = "prediction_id") |>
    mutate(correct = (prediction_class == actual))

  # Calculate actual performance
  actual_accuracy <- mean(performance$correct)

  cat("Current production accuracy:", round(actual_accuracy, 3), "\n")

  # Compare to test set
  test_accuracy <- {test_set_value}
  degradation <- test_accuracy - actual_accuracy

  if (degradation > 0.05) {
    cat("⚠ Performance degradation detected:", round(degradation, 3), "\n")
    cat("Consider retraining model\n")
  }

  # Save report
  write_csv(
    tibble(
      date = Sys.Date(),
      accuracy = actual_accuracy,
      n_samples = nrow(performance)
    ),
    here("outputs", "monitoring", "performance_log.csv"),
    append = TRUE
  )
}
```

### 10. Document Deployment

**Create deployment guide:**

**`reports/deployment-guide.md`:**

```markdown
# Deployment Guide: {Project Name}

**Version:** 1.0
**Deployed:** {date}
**Owner:** Marie (Communicator)

---

## Production Environment

### API Endpoint
**URL:** {production_url}
**Method:** POST `/predict`
**Authentication:** {method}

### Infrastructure
- **Platform:** {Posit Connect / AWS / Azure / Self-hosted}
- **Container:** Docker image `{project-name-model}:1.0`
- **Resources:** {CPU/memory specs}
- **Scaling:** {auto-scaling rules}

### Dependencies
```r
tidyverse = {version}
tidymodels = {version}
vetiver = {version}
plumber = {version}
```

---

## Using the API

### Health Check
```bash
curl {url}/health
```

### Make Prediction
```bash
curl -X POST {url}/predict \
  -H "Content-Type: application/json" \
  -d '{
    "feature1": value,
    "feature2": value,
    "feature3": value
  }'
```

**Response:**
```json
{
  "prediction": "class",
  "confidence": 0.85,
  "model_version": "1.0",
  "timestamp": "2026-03-17T10:30:00Z"
}
```

### R Client Example
```r
library(httr)

# Make prediction
response <- POST(
  "{url}/predict",
  body = list(feature1 = value, feature2 = value),
  encode = "json"
)

result <- content(response)
print(result$prediction)
```

### Python Client Example
```python
import requests

response = requests.post(
    "{url}/predict",
    json={"feature1": value, "feature2": value}
)

result = response.json()
print(result["prediction"])
```

---

## Monitoring

### Dashboard
**URL:** {monitoring_dashboard_url}

**Key Metrics:**
- Total predictions
- Average confidence
- Prediction distribution
- API latency
- Error rate

### Alerts
- Low confidence (< 0.7)
- Low volume (< 100 daily)
- High error rate (> 5%)
- Data drift detected

**Alert Recipient:** {email/Slack channel}

### Logs
- **Prediction logs:** `outputs/monitoring/predictions_log.csv`
- **Performance logs:** `outputs/monitoring/performance_log.csv`
- **Feedback logs:** `outputs/monitoring/feedback_log.csv`

---

## Maintenance

### Retraining Schedule
**Frequency:** {Monthly / Quarterly / On-demand}

**Triggers:**
- Performance degradation (> 5% drop)
- Data drift detected
- New data patterns observed
- Business requirement changes

### Update Process
1. Retrain model with updated data
2. Evaluate on new test set
3. Update model pin with new version
4. Deploy to staging environment
5. Validate in staging
6. Deploy to production (blue-green deployment)
7. Monitor for 48 hours
8. Rollback if issues detected

### Rollback Plan
```r
# Pin previous version as default
board |> pin_versions("{project-name-model}")
board |> vetiver_pin_read("{project-name-model}", version = "{previous_version}")
```

---

## Troubleshooting

### API Not Responding
1. Check health endpoint: `curl {url}/health`
2. Review logs: `docker logs {container_id}`
3. Restart service: `docker restart {container_id}`

### Low Performance
1. Check monitoring dashboard for drift
2. Review recent predictions for patterns
3. Analyze feedback log for actual vs predicted
4. Consider retraining

### High Latency
1. Check resource utilization
2. Scale up instances if needed
3. Optimize feature preprocessing
4. Consider model compression

---

## Support

**Primary Contact:** {name} ({email})
**Backup Contact:** {name} ({email})
**Issue Tracker:** {github/jira link}
**Documentation:** {confluence/wiki link}

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | {date} | Initial deployment |
```

### 11. Final Validation Checklist

Before completing Phase 10:

- [ ] Vetiver model created and pinned
- [ ] Plumber API implemented and tested locally
- [ ] Docker container built and tested
- [ ] Model deployed to production environment
- [ ] API endpoint accessible and functional
- [ ] Monitoring dashboard created
- [ ] Alerts configured
- [ ] Feedback loop established
- [ ] Deployment guide documented
- [ ] Handoff to operations team completed

---

## Outputs

**Created Files:**
- `plumber.R` (API definition)
- `Dockerfile` (containerization)
- `scripts/10-deploy.R` (deployment and testing)
- `scripts/check-health.R` (monitoring script)
- `reports/monitoring-dashboard.qmd`
- `reports/deployment-guide.md`
- `outputs/models/pins/` (pinned model)
- `outputs/monitoring/` (logs and metrics)
- `checkpoints/10-deploy.complete`

**Git Commit:**
```bash
git add plumber.R Dockerfile scripts/10-deploy.R reports/ outputs/
git commit -m "feat: deploy model to production

- Create Vetiver API endpoint
- Containerize with Docker
- Deploy to {environment}
- Setup monitoring and alerts
- Establish feedback loop
- Complete deployment guide

Phase 10/10 COMPLETE - Project finished!

Co-Authored-By: Marie (Communicator) <noreply@bmad.com>"
```

---

## Project Completion

### 🎉 Congratulations! Full Lifecycle Complete

You've successfully completed all 10 phases:

1. ✅ Setup - Project structure and dependencies
2. ✅ Import & Inspect - Data loading and profiling
3. ✅ Clean - Data wrangling and quality
4. ✅ EDA - Exploratory analysis and insights
5. ✅ Feature Engineering - Transform and create features
6. ✅ Modeling - Build and compare models
7. ✅ Tuning - Optimize hyperparameters
8. ✅ Evaluation - Test set performance
9. ✅ Communication - Stakeholder materials
10. ✅ Deploy - Production deployment

### Final Deliverables

**Code & Models:**
- Complete R project structure
- Trained model (`final_model.rds`)
- Feature recipe (`feature_recipe.rds`)
- All analysis scripts (01-10)

**Documentation:**
- README with project overview
- EDA report
- Model evaluation report
- Technical documentation
- Deployment guide

**Deployment:**
- Production API endpoint
- Monitoring dashboard
- Feedback collection system
- Maintenance plan

### What's Next?

**Immediate:**
- Monitor model performance daily
- Collect feedback from users
- Track business impact

**Ongoing:**
- Review monitoring alerts
- Analyze prediction logs
- Update documentation as needed

**Future:**
- Retrain model {frequency}
- Explore alternative algorithms
- Expand to additional use cases

---

## Troubleshooting

**Issue:** API deployment fails
- **Solution**: Check Docker logs, verify dependencies, test locally first

**Issue:** Model performance degrades in production
- **Solution**: Analyze feedback data, check for data drift, retrain if needed

**Issue:** High API latency
- **Solution**: Profile code, optimize preprocessing, scale infrastructure

**Issue:** Monitoring data not updating
- **Solution**: Check cron jobs, verify file permissions, review logging code

---

## Thank You!

This project was completed using the **RDS Module Full-Lifecycle Workflow**.

**Team:**
- Ada (Project Architect) - Phases 1-3
- Grace (Data Explorer) - Phases 4-5
- Alan (Model Master) - Phases 6-8
- Marie (Communicator) - Phases 9-10

**Framework:** BMAD (BMad Method) Data Science v6.0

For questions or support, contact the Data Science team.

---

_Phase 10 of 10 | Owner: Marie | RDS Module Full-Lifecycle Workflow | PROJECT COMPLETE_
