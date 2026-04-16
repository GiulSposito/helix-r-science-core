# Step 1: Prepare Artifacts

**Workflow:** deploy-model
**Phase:** Pre-Deployment Validation
**Duration:** 2-4 hours

---

## Objective

Collect and validate all model artifacts, dependencies, and configurations for deployment.

---

## Instructions

Act as Tim, the deployment specialist. Verify everything is production-ready before touching infrastructure.

### 1. Collect Model Artifacts

Gather from Alan's evaluation phase:
- **Model file** — Final trained model (.rds)
- **Recipe** — Feature engineering recipe (.rds)
- **Workflow** — Complete tidymodels workflow (if available)
- **Vetiver bundle** — Vetiver model object (create if missing)

Verify files exist and are loadable:
```r
model <- readRDS(here::here("models/final_model.rds"))
recipe <- readRDS(here::here("models/recipe.rds"))
```

### 2. Validate Model Performance

Confirm model is deployment-ready:
- [ ] Test set evaluation complete (by Alan)
- [ ] Performance meets requirements
- [ ] No data leakage detected
- [ ] Model interpretation available

Load test metrics from Alan's sidecar.

### 3. Document Dependencies

Create `requirements.txt` or capture with renv:
```r
# Snapshot current environment
renv::snapshot()

# Review renv.lock for deployment
# Verify all packages from CRAN or documented sources
```

**Key packages to verify:**
- tidymodels (version)
- vetiver (version)
- plumber (version)
- Any custom packages

### 4. Create Vetiver Bundle

If not already created:
```r
library(vetiver)

# Create vetiver model
v_model <- vetiver_model(
  model = model,
  model_name = "my-model",
  description = "Production model v1.0"
)

# Test prediction
predict(v_model, new_data = test_sample)
```

### 5. Prepare Configuration

Create `config.yaml` for deployment:
```yaml
model:
  name: my-model
  version: 1.0.0

api:
  host: 0.0.0.0
  port: 8080
  workers: 4

monitoring:
  health_check_path: /ping
  metrics_path: /metrics

resources:
  memory_limit: 2Gi
  cpu_limit: 1000m
```

### 6. Security Check

Verify:
- [ ] No secrets in code (use environment variables)
- [ ] API authentication plan (if needed)
- [ ] Input validation implemented
- [ ] CORS configured appropriately

---

## Validation Checklist

Before proceeding to Step 2:
- [ ] Model artifacts collected and validated
- [ ] Dependencies documented (renv.lock)
- [ ] Vetiver bundle created and tested
- [ ] Configuration file ready
- [ ] Security reviewed

---

## Output

**Files ready for deployment:**
- Model artifacts (model.rds, recipe.rds)
- Vetiver bundle
- renv.lock (dependencies)
- config.yaml (deployment config)

**Next:** Proceed to Step 2 (Create API)
