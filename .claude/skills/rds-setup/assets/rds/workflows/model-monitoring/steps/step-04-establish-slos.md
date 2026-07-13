# Step 4: Establish SLOs

**Workflow:** model-monitoring
**Phase:** Service Level Objectives
**Duration:** 2-4 hours

---

## Objective

Define service level objectives (SLOs) and error budgets that connect technical metrics to business outcomes.

---

## Instructions

Act as Tim. Establish SLOs that balance reliability with development velocity.

### 1. Understand SLO Framework

**SLO vs SLA:**
- **SLO** — Internal target (e.g., 99.9% availability)
- **SLA** — External commitment with penalties (e.g., 99.5%)
- SLO should be stricter than SLA to provide buffer

**Error Budget:**
- Allowed failures within SLO window
- Example: 99.9% over 30 days = 43 minutes downtime allowed
- Burned budget = room for risks, deploys, experiments

### 2. Define Core SLOs

**Availability SLO:**
```yaml
availability:
  target: 99.9%
  measurement_window: 30_days
  error_budget: 43_minutes_per_month
  measurement_method: |
    (successful_requests / total_requests) >= 0.999
```

**Latency SLO:**
```yaml
latency_p95:
  target: 200ms
  measurement_window: 30_days
  error_budget: 5%_of_requests_above_threshold
  measurement_method: |
    95th percentile response time < 200ms
```

**Error Rate SLO:**
```yaml
error_rate:
  target: 0.1%
  measurement_window: 30_days
  error_budget: 43_minutes_equivalent
  measurement_method: |
    (error_requests / total_requests) < 0.001
```

### 3. Align with Business Requirements

Confirm with stakeholders:
- Are these targets sufficient for business needs?
- What's the cost of downtime?
- What latency affects user experience?
- Are there regulatory requirements?

Document stakeholder input.

### 4. Calculate Error Budgets

**Example for 99.9% availability:**
- Measurement window: 30 days
- Total minutes: 43,200 minutes
- Error budget: 43.2 minutes
- Daily budget: ~1.4 minutes

**Budget consumption tracking:**
```r
calculate_error_budget <- function() {
  window_start <- Sys.Date() - 30

  incidents <- fetch_downtime(window_start, Sys.Date())
  consumed <- sum(incidents$duration_minutes)

  budget_remaining <- 43.2 - consumed
  budget_pct <- (budget_remaining / 43.2) * 100

  list(
    consumed = consumed,
    remaining = budget_remaining,
    pct_remaining = budget_pct
  )
}
```

### 5. Create SLO Dashboard

Add SLO tracking to monitoring dashboard:
- Current SLO compliance (%)
- Error budget remaining (minutes and %)
- Trend over last 6 months
- Incident history affecting SLO

### 6. Document SLO Policy

Create `SLO-POLICY.md`:

```markdown
## Model API Service Level Objectives

### Availability: 99.9%
- **Target:** API responds successfully 99.9% of the time
- **Measurement:** 30-day rolling window
- **Error Budget:** 43 minutes downtime per month
- **Current Status:** [99.95% - 🟢 Healthy]

### Latency (P95): < 200ms
- **Target:** 95% of requests complete in under 200ms
- **Measurement:** 30-day rolling window
- **Error Budget:** 5% of requests may exceed threshold
- **Current Status:** [P95: 142ms - 🟢 Healthy]

### Error Rate: < 0.1%
- **Target:** Fewer than 0.1% requests return errors
- **Measurement:** 30-day rolling window
- **Error Budget:** Equivalent to availability budget
- **Current Status:** [0.03% - 🟢 Healthy]

## Error Budget Policy

**When budget > 50% remaining:**
- Normal deployment cadence
- Can take calculated risks
- Experimentation encouraged

**When budget 25-50% remaining:**
- Slow deployments
- Extra testing required
- Review recent incidents

**When budget < 25% remaining:**
- Deployment freeze (emergency only)
- Focus on reliability improvements
- Investigate root causes

**When budget exhausted:**
- Complete deployment freeze
- Incident post-mortem required
- SLO review with stakeholders

## Review Cadence

- **Weekly:** Error budget status review
- **Monthly:** SLO compliance report
- **Quarterly:** SLO targets review with stakeholders
```

### 7. Setup SLO Reporting

Create automated SLO report:
```r
generate_slo_report <- function() {
  # Calculate compliance
  compliance <- calculate_slo_compliance()

  # Generate report
  rmarkdown::render("slo-report.Rmd",
                    params = list(
                      availability = compliance$availability,
                      latency = compliance$latency,
                      error_rate = compliance$error_rate,
                      period = "last 30 days"
                    ))
}

# Run monthly
cronR::cron_add(
  command = "Rscript generate-slo-report.R",
  frequency = "monthly"
)
```

---

## Validation Checklist

Monitoring complete when:
- [ ] SLOs defined with measurable targets
- [ ] Error budgets calculated
- [ ] SLO dashboard created
- [ ] Policy documented
- [ ] Stakeholders reviewed and approved

---

## Output

**Files created:**
- `slo-definitions.yaml` — SLO specifications
- `SLO-POLICY.md` — Policy and procedures
- `slo-report.Rmd` — Automated reporting template

**Workflow complete!** Return to Tim's menu.

---

## Post-Monitoring Setup

Recommended next steps:
- Schedule weekly SLO review meeting
- Set calendar reminder for monthly stakeholder review
- Run [DH] Deployment Health check regularly
- Iterate on alert thresholds based on false positive rate
