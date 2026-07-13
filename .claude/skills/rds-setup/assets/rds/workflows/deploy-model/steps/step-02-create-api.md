# Step 2: Create Vetiver API

**Workflow:** deploy-model
**Phase:** API Development
**Duration:** 2-4 hours

---

## Objective

Build Vetiver REST API with prediction, health, and metadata endpoints.

---

## Instructions

Act as Tim. Create a production-grade API with proper error handling and logging.

### 1. Generate Vetiver API

Create plumber API file:
```r
library(vetiver)
library(plumber)

# Load vetiver model
v_model <- readRDS("vetiver-bundle.rds")

# Create API
pr <- vetiver_api(v_model)

# Run API
pr |> pr_run(port = 8080)
```

### 2. Add Health Check Endpoint

```r
#* Health check
#* @get /ping
function() {
  list(
    status = "healthy",
    timestamp = Sys.time(),
    model_version = "1.0.0"
  )
}
```

### 3. Add Prediction Endpoint

Vetiver creates this automatically, but customize if needed:
```r
#* Predict
#* @post /predict
#* @param req:body Request body with features
function(req) {
  # Input validation
  if (!all(required_features %in% names(req))) {
    stop("Missing required features")
  }

  # Make prediction
  predict(v_model, new_data = req)
}
```

### 4. Add Metadata Endpoint

```r
#* Model metadata
#* @get /metadata
function() {
  list(
    model_name = "my-model",
    version = "1.0.0",
    algorithm = "xgboost",
    features = colnames(v_model$ptype),
    training_date = "2026-03-26",
    performance = list(
      test_rmse = 0.123,
      test_accuracy = 0.89
    )
  )
}
```

### 5. Add Error Handling

Wrap endpoints with tryCatch:
```r
#* @post /predict
function(req, res) {
  tryCatch({
    result <- predict(v_model, new_data = req)
    return(result)
  }, error = function(e) {
    res$status <- 400
    list(error = e$message)
  })
}
```

### 6. Add Logging

Log all requests:
```r
#* @filter logger
function(req, res) {
  cat(paste0(
    Sys.time(), " ",
    req$REQUEST_METHOD, " ",
    req$PATH_INFO, "\n"
  ))
  plumber::forward()
}
```

### 7. Test API Locally

Start API and test:
```r
# Run API
pr |> pr_run(port = 8080)
```

Test endpoints:
```bash
# Health check
curl http://localhost:8080/ping

# Prediction
curl -X POST http://localhost:8080/predict \
  -H "Content-Type: application/json" \
  -d '{"feature1": 1.0, "feature2": 2.0}'

# Metadata
curl http://localhost:8080/metadata
```

---

## Validation Checklist

Before proceeding to Step 3:
- [ ] Prediction endpoint functional
- [ ] Health check returns 200
- [ ] Metadata endpoint accurate
- [ ] Error handling works
- [ ] Logging configured
- [ ] Local testing passed

---

## Output

**Files created:**
- `plumber.R` — API definition
- `api-tests.sh` — curl test scripts

**Next:** Proceed to Step 3 (Containerize)
