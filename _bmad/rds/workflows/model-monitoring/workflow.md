---
name: model-monitoring
description: Configure monitoring dashboards alerting and SLOs for production models
installed_path: '{project-root}/_bmad/rds/workflows/model-monitoring'
---

# Model Monitoring Workflow

**Module:** RDS (R Data Science)
**Owner:** Tim (The Deployer)
**Status:** Active
**Duration:** 1-2 days

---

## Workflow Overview

**Goal:** Establish comprehensive monitoring and alerting for production models with SLOs, dashboards, and incident response

**Description:** Configure observability stack for deployed models. Defines metrics, creates monitoring dashboards, sets up alerting thresholds, and establishes SLOs. Ensures production models are never flying blind.

**Workflow Type:** Core — Multi-step observability setup

---

## Activation Sequence

<activation>

### Step 1: Welcome & Context

**Output:**
```
╔══════════════════════════════════════════════════════════════╗
║            MODEL MONITORING WORKFLOW                         ║
║        Production Observability & Alerting                   ║
╚══════════════════════════════════════════════════════════════╝

Tim here! Let's make sure your production model stays healthy and observable.

This workflow will guide you through:
  • Step 1: Define Metrics (RED: Rate, Errors, Duration)
  • Step 2: Configure Alerts (thresholds, channels, runbooks)
  • Step 3: Build Dashboards (Grafana/Shiny for visibility)
  • Step 4: Establish SLOs (service level objectives and budgets)

Monitoring philosophy:
  → Monitor BEFORE deploy (observability first)
  → Alert on symptoms, not causes (user impact)
  → Dashboards for investigation, alerts for action
  → SLOs tie monitoring to business outcomes

Duration: 1-2 days

Prerequisites:
  ☐ Model deployed via [DM] Deploy Model
  ☐ API endpoints accessible
  ☐ Logging infrastructure available

Let's make this production-grade!
```

### Step 2: Execute Workflow Steps

Load and execute each step sequentially:

1. **Step 1 — Define Metrics**
   - File: `{installed_path}/steps/step-01-define-metrics.md`
   - Goal: Identify RED metrics (Rate, Errors, Duration) and business KPIs
   - Action: Load and execute

2. **Step 2 — Configure Alerts**
   - File: `{installed_path}/steps/step-02-configure-alerts.md`
   - Goal: Set thresholds, notification channels, and incident runbooks
   - Action: Load and execute

3. **Step 3 — Build Dashboards**
   - File: `{installed_path}/steps/step-03-build-dashboards.md`
   - Goal: Create monitoring dashboards (Grafana, Shiny, or custom)
   - Action: Load and execute

4. **Step 4 — Establish SLOs**
   - File: `{installed_path}/steps/step-04-establish-slos.md`
   - Goal: Define service level objectives and error budgets
   - Action: Load and execute

### Step 3: Completion

**Output:**
```
╔══════════════════════════════════════════════════════════════╗
║         MONITORING CONFIGURED SUCCESSFULLY!                  ║
╚══════════════════════════════════════════════════════════════╝

Your model is now observable and monitored!

Monitoring stack summary:
  • Metrics: RED + Model-specific KPIs
  • Dashboards: [dashboard-url]
  • Alerts: [alert-manager-url]
  • SLO Target: 99.9% availability, <200ms p95 latency

Generated artifacts:
  • monitoring-config/ — Alert rules and SLO definitions
  • dashboards/ — Dashboard specifications (JSON/code)
  • runbooks/ — Incident response procedures
  • prometheus.yml — Metrics scraping config (if Prometheus)

Configured alerts:
  ✓ Error rate > 0.5% (Critical)
  ✓ P95 latency > 300ms (Warning)
  ✓ API availability < 99.5% (Critical)
  ✓ Prediction volume anomaly (Info)
  ✓ Model staleness (Warning)

Alert channels:
  • Email: [team@example.com]
  • Slack: [#ml-ops-alerts]
  • PagerDuty: [on-call rotation]

Defined SLOs:
  • Availability: 99.9% (43 min downtime/month)
  • Latency (p95): <200ms
  • Error rate: <0.1%

Next steps:
  • Test alert delivery (trigger test alert)
  • Share dashboard with team
  • Review SLOs with stakeholders
  • Schedule weekly monitoring review

Production visibility achieved! 👀
```

</activation>

---

## Workflow Properties

**Input Requirements:**
- Deployed model endpoint (from deploy-model workflow)
- Access to deployment infrastructure
- Alerting notification channels

**Optional Inputs:**
- Existing monitoring stack (Prometheus, Grafana, etc.)
- Custom business metrics
- SLO targets from stakeholders

**Outputs:**
- `monitoring-config/` — Alert rules, metric definitions
- `dashboards/` — Dashboard specs (Grafana JSON, Shiny app, or custom)
- `runbooks/` — Incident response procedures
- `slo-definitions.yaml` — Service level objectives
- `prometheus.yml` — Metrics config (if Prometheus)

---

## Agent Integration

**Primary Agent:** Tim (The Deployer)
- Defines monitoring strategy
- Configures alerts and dashboards
- Establishes SLOs and error budgets

**Supporting Agents:**
- **Alan** — Provides model performance baselines for anomaly detection
- **Marie** — Builds stakeholder-facing monitoring dashboards (if needed)

---

## Implementation Notes

**Philosophy:**
- Monitor symptoms (user impact) not causes (internal state)
- Alert on actionable conditions only (reduce noise)
- Dashboards for investigation, alerts for immediate action
- SLOs connect technical metrics to business outcomes
- Incident response readiness before first alert

**RED Metrics (Core):**
- **Rate** — Requests per second (traffic volume)
- **Errors** — Error rate percentage (availability)
- **Duration** — Response latency (p50, p95, p99)

**Model-Specific Metrics:**
- **Prediction accuracy** — Online validation (if ground truth available)
- **Feature drift** — Distribution shifts in input data
- **Model staleness** — Time since last training
- **Resource usage** — CPU, memory, disk

**Monitoring Stack Options:**

**Lightweight (Vetiver built-in):**
- Vetiver metrics endpoints
- Simple Shiny dashboard
- Email alerts via R
- Best for: Small teams, simple deployments

**Production (Prometheus + Grafana):**
- Prometheus scraping Vetiver metrics
- Grafana dashboards with drill-downs
- Alertmanager for notifications
- Best for: Multiple models, SRE teams

**Enterprise (Full observability):**
- Datadog, New Relic, or Dynatrace
- Distributed tracing
- Log aggregation
- Best for: Large-scale ML platforms

**Best For:**
- Production model deployment
- SLA-driven services
- Regulated industries (audit trails)
- Multi-model deployments

**Not Ideal For:**
- Prototype/development models (overkill)
- Batch prediction jobs (different monitoring needs)
- Models not yet deployed

---

## Technical Requirements

**R Packages:**
- Core: vetiver, pins
- Monitoring: shiny (for dashboards), httr (for webhooks)
- Optional: prometheus (if using Prometheus exporter)

**Monitoring Tools:**
- **Prometheus** — Metrics collection and storage
- **Grafana** — Visualization and dashboarding
- **Alertmanager** — Alert routing and notification
- **Shiny** — Custom R-based dashboards

**Alert Channels:**
- Email (SMTP)
- Slack (webhooks)
- PagerDuty (API integration)
- Custom webhooks

**SLO Framework:**
- Availability target (e.g., 99.9% = 43 min downtime/month)
- Latency target (e.g., p95 < 200ms)
- Error budget (allowed failures within SLO)
- Measurement window (e.g., 30-day rolling)

**Expected Duration:**
- Step 1 (Define Metrics): 2-4 hours
- Step 2 (Configure Alerts): 3-6 hours
- Step 3 (Build Dashboards): 4-8 hours
- Step 4 (Establish SLOs): 2-4 hours

---

_Workflow created on 2026-03-26 for RDS Module v0.2.0_
