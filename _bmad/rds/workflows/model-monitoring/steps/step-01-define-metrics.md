# Step 1: Define Metrics

**Workflow:** model-monitoring
**Phase:** Metrics Design
**Duration:** 2-4 hours

---

## Objective

Identify RED metrics (Rate, Errors, Duration) and model-specific KPIs for monitoring.

---

## Instructions

Act as Tim. Define what to measure to ensure production model health.

### 1. RED Metrics (Core Infrastructure)

**Rate (Request Volume):**
- Requests per second (RPS)
- Requests per minute (RPM)
- Daily prediction volume
- Traffic patterns (hourly, daily, weekly)

**Errors (Availability):**
- 4xx error rate (client errors)
- 5xx error rate (server errors)
- Total error percentage
- Error types and patterns

**Duration (Latency):**
- P50 latency (median)
- P95 latency (95th percentile)
- P99 latency (tail latency)
- Max latency (outliers)

### 2. Model-Specific Metrics

**Prediction Quality:**
- Online validation accuracy (if ground truth available)
- Prediction confidence distribution
- Outlier prediction rate
- Null prediction rate

**Data Drift:**
- Feature distribution shifts
- Missing value rate changes
- Categorical value changes
- Numeric range violations

**Model Health:**
- Model staleness (days since training)
- Feature engineering pipeline health
- Dependency version mismatches

**Business KPIs:**
- Predictions impacting business decisions
- Model-driven revenue/savings
- User engagement with predictions

### 3. Define Collection Methods

**Built-in Vetiver metrics:**
```r
# Vetiver tracks these automatically
- Prediction endpoint hits
- Response times
- Error rates
```

**Custom metrics:**
```r
# Log additional context
library(logger)

log_prediction <- function(input, output, latency) {
  log_info("Prediction made",
           features = length(input),
           latency_ms = latency,
           confidence = output$conf)
}
```

**External monitoring:**
- Prometheus exporter for metrics
- Application logs for debugging
- Custom Shiny dashboard

### 4. Set Baseline Values

From Alan's test set evaluation:
- Expected prediction distribution
- Typical feature ranges
- Normal error rates
- Performance benchmarks

Document in `metrics-baseline.md`.

### 5. Create Metrics Specification

Generate `metrics-spec.yaml`:

```yaml
metrics:
  infrastructure:
    - name: request_rate
      type: counter
      unit: requests/sec
      baseline: 10

    - name: error_rate
      type: gauge
      unit: percentage
      baseline: 0.05

    - name: latency_p95
      type: histogram
      unit: milliseconds
      baseline: 150

  model_specific:
    - name: prediction_confidence
      type: histogram
      baseline_mean: 0.85

    - name: feature_drift
      type: gauge
      detection_method: KS_test
      threshold: 0.05
```

---

## Validation Checklist

Before proceeding to Step 2:
- [ ] RED metrics defined
- [ ] Model-specific metrics identified
- [ ] Baselines documented
- [ ] Collection methods specified
- [ ] Metrics spec created

---

## Output

**Files created:**
- `metrics-spec.yaml` — Complete metrics definition
- `metrics-baseline.md` — Baseline values from Alan

**Next:** Proceed to Step 2 (Configure Alerts)
