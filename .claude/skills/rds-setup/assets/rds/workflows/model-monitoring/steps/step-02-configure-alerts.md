# Step 2: Configure Alerts

**Workflow:** model-monitoring
**Phase:** Alerting Setup
**Duration:** 3-6 hours

---

## Objective

Set alert thresholds, notification channels, and incident runbooks.

---

## Instructions

Act as Tim. Configure alerts that are actionable and reduce noise.

### 1. Define Alert Thresholds

**Critical (Immediate Action Required):**
- Error rate > 1% for 5 minutes
- API availability < 99% for 10 minutes
- P95 latency > 500ms for 5 minutes
- Zero predictions for 10 minutes

**Warning (Investigation Needed):**
- Error rate > 0.5% for 10 minutes
- P95 latency > 300ms for 10 minutes
- Feature drift detected (KS test p < 0.01)
- Prediction confidence drop > 10%

**Info (Awareness Only):**
- Traffic spike > 2x normal
- New error types appearing
- Model staleness > 30 days

### 2. Configure Notification Channels

**Email:**
```r
send_email_alert <- function(severity, message) {
  blastula::smtp_send(
    email = blastula::compose_email(
      body = message
    ),
    to = "team@example.com",
    from = "alerts@example.com",
    subject = paste0("[", severity, "] Model Alert")
  )
}
```

**Slack:**
```r
send_slack_alert <- function(severity, message) {
  httr::POST(
    url = Sys.getenv("SLACK_WEBHOOK"),
    body = list(
      text = paste0("🚨 ", severity, ": ", message)
    ),
    encode = "json"
  )
}
```

**PagerDuty (Critical only):**
```r
send_pagerduty <- function(message) {
  httr::POST(
    url = "https://events.pagerduty.com/v2/enqueue",
    body = list(
      routing_key = Sys.getenv("PAGERDUTY_KEY"),
      event_action = "trigger",
      payload = list(
        summary = message,
        severity = "critical",
        source = "model-api"
      )
    ),
    encode = "json"
  )
}
```

### 3. Create Alert Rules

**If using Prometheus Alertmanager:**

Create `alert-rules.yml`:
```yaml
groups:
  - name: model_api_alerts
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: rate(api_errors_total[5m]) > 0.01
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Error rate above 1%"
          description: "Current error rate: {{ $value }}"

      - alert: HighLatency
        expr: histogram_quantile(0.95, api_latency_seconds) > 0.5
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "P95 latency above 500ms"
```

**If using custom R monitoring:**

Create `alert-checker.R`:
```r
check_alerts <- function() {
  metrics <- fetch_current_metrics()

  # Check error rate
  if (metrics$error_rate > 0.01) {
    send_slack_alert("CRITICAL",
                     paste0("Error rate: ", metrics$error_rate))
  }

  # Check latency
  if (metrics$p95_latency > 500) {
    send_slack_alert("CRITICAL",
                     paste0("P95 latency: ", metrics$p95_latency, "ms"))
  }

  # Check feature drift
  if (metrics$drift_detected) {
    send_slack_alert("WARNING", "Feature drift detected")
  }
}

# Run every minute
later::later(check_alerts, delay = 60, loop = TRUE)
```

### 4. Create Incident Runbooks

For each alert, document response:

**Runbook: High Error Rate**
```markdown
## Alert: High Error Rate (>1%)

**Severity:** Critical
**Expected Response Time:** < 15 minutes

**Investigation Steps:**
1. Check API logs for error details
   ```bash
   docker logs model-api-prod --tail 100
   ```
2. Verify input data quality
3. Check recent deployments (was this just deployed?)
4. Review prediction errors for patterns

**Common Causes:**
- Invalid input data format
- Model deserialization failure
- Out-of-memory errors
- Network issues

**Remediation:**
- If deployment-related → rollback to previous version
- If data-related → Fix upstream data pipeline
- If load-related → Scale up resources

**Escalation:**
If not resolved in 30 minutes, page on-call engineer.
```

Create runbook for each critical/warning alert.

### 5. Test Alert Delivery

Trigger test alerts:
```r
# Send test alert to each channel
send_slack_alert("INFO", "🧪 Test alert - please acknowledge")
send_email_alert("INFO", "Test alert from model monitoring setup")
```

Verify team receives and can access alerts.

### 6. Document Alert Configuration

Create `ALERT-GUIDE.md`:
```markdown
## Alert Channels

- **Slack:** #ml-ops-alerts
- **Email:** ml-team@example.com
- **PagerDuty:** On-call rotation (critical only)

## Alert Severities

- **Critical** → Immediate action (page on-call)
- **Warning** → Investigate within 1 hour
- **Info** → Awareness, no action required

## Runbook Location

See `runbooks/` directory for incident response procedures.
```

---

## Validation Checklist

Before proceeding to Step 3:
- [ ] Alert thresholds defined for all critical metrics
- [ ] Notification channels configured and tested
- [ ] Runbooks created for critical alerts
- [ ] Test alerts delivered successfully
- [ ] Team aware of alert system

---

## Output

**Files created:**
- `alert-rules.yml` or `alert-checker.R`
- `runbooks/` — Incident response procedures
- `ALERT-GUIDE.md` — Team documentation

**Next:** Proceed to Step 3 (Build Dashboards)
