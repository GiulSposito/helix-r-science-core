---
name: build-dashboard
description: Create interactive Shiny dashboard with KPIs and drill-downs
installed_path: '{project-root}/_bmad/rds/workflows/build-dashboard'
---

# Build Dashboard Workflow

**Module:** RDS (R Data Science)
**Owner:** Marie (The Reporter)
**Status:** Active
**Duration:** 1-3 days

---

## Workflow Overview

**Goal:** Create interactive Shiny dashboards for exploratory analysis and stakeholder self-service

**Description:** Build production-ready Shiny applications with KPIs, interactive filters, and drill-down capabilities. Supports both standalone exploration dashboards and integrated reporting dashboards. Emphasizes user experience, reactivity, and performance.

**Workflow Type:** Core — Multi-step interactive development

---

## Activation Sequence

<activation>

### Step 1: Welcome & Context

**Output:**
```
╔══════════════════════════════════════════════════════════════╗
║             DASHBOARD DEVELOPMENT WORKFLOW                   ║
║         Interactive Data Exploration & Reporting             ║
╚══════════════════════════════════════════════════════════════╝

Marie here! Let's build an interactive dashboard that brings your data to life.

This workflow will guide you through:
  • Step 1: Design Dashboard (KPIs, layout, interactivity)
  • Step 2: Build Application (Shiny components, reactivity)
  • Step 3: Test & Optimize (UX testing, performance)
  • Step 4: Deploy (Local/Server deployment)

Dashboard types available:
  • Exploration Dashboard — Interactive EDA with filters
  • Reporting Dashboard — KPIs with drill-downs
  • Monitoring Dashboard — Real-time model metrics (with Tim)

Duration: 1-3 days depending on complexity

Let's create something users will actually enjoy using!
```

### Step 2: Execute Workflow Steps

Load and execute each step sequentially:

1. **Step 1 — Design Dashboard**
   - File: `{installed_path}/steps/step-01-design-dashboard.md`
   - Goal: Define KPIs, layout, user interactions, and data flows
   - Action: Load and execute

2. **Step 2 — Build Application**
   - File: `{installed_path}/steps/step-02-build-application.md`
   - Goal: Develop Shiny UI and server logic with reactive components
   - Action: Load and execute

3. **Step 3 — Test & Optimize**
   - File: `{installed_path}/steps/step-03-test-optimize.md`
   - Goal: UX testing, performance profiling, responsiveness
   - Action: Load and execute

4. **Step 4 — Deploy**
   - File: `{installed_path}/steps/step-04-deploy.md`
   - Goal: Deploy to shinyapps.io, Posit Connect, or local server
   - Action: Load and execute

### Step 3: Completion

**Output:**
```
╔══════════════════════════════════════════════════════════════╗
║               DASHBOARD DEPLOYED!                            ║
╚══════════════════════════════════════════════════════════════╝

Your interactive dashboard is live!

Generated artifacts:
  • app.R or ui.R/server.R — Shiny application code
  • global.R — Data loading and shared logic
  • www/ — CSS, JS, images for styling
  • modules/ — Reusable Shiny modules (if modular design)
  • data/ — Processed datasets for dashboard

Dashboard features:
  ✓ Interactive KPI cards
  ✓ Drill-down visualizations
  ✓ Dynamic filters and controls
  ✓ Responsive layout (mobile-friendly)
  ✓ Export capabilities (plots/data)

Access:
  • Local: Run with `shiny::runApp()`
  • Deployed: [URL from deployment service]

Next steps:
  • Share with stakeholders
  • Monitor usage analytics
  • Iterate based on feedback

Happy dashboarding! 📊
```

</activation>

---

## Workflow Properties

**Input Requirements:**
- Data source (CSV, RDS, database connection, or API)
- KPIs to display
- Target audience and use cases

**Optional Inputs:**
- Brand guidelines (colors, logos, fonts)
- Existing dashboard wireframes
- Deployment target (shinyapps.io, Connect, Docker)

**Outputs:**
- `app.R` or `ui.R/server.R` — Shiny application
- `global.R` — Shared logic and data loading
- `www/` — Static assets (CSS, JS, images)
- `modules/` — Reusable Shiny modules (if applicable)
- `README.md` — Deployment and maintenance instructions

---

## Agent Integration

**Primary Agent:** Marie (The Reporter)
- Designs dashboard UX and information architecture
- Builds Shiny application with reactive logic
- Ensures visual consistency and usability

**Supporting Agents:**
- **Grace** — Provides EDA insights for exploration dashboards
- **Alan** — Provides model metrics for reporting dashboards
- **Tim** — Handles production deployment and monitoring integration

---

## Implementation Notes

**Philosophy:**
- User-centric design — every widget must serve a specific analytical question
- Performance matters — lazy loading, caching, efficient queries
- Mobile-responsive — dashboards should work on tablets/phones
- Interactivity serves exploration, not decoration

**Dashboard Types:**

**Exploration Dashboard:**
- Interactive filters and slicing
- Multiple visualization tabs
- Data export capabilities
- Ad-hoc analysis support

**Reporting Dashboard:**
- KPI cards with trend indicators
- Drill-down from summary to detail
- Scheduled refresh capabilities
- Stakeholder-friendly formatting

**Monitoring Dashboard:**
- Real-time or near-real-time data
- Alert thresholds and notifications
- Time-series plots with zoom
- System health indicators

**Best For:**
- Self-service data exploration
- Regular stakeholder updates
- Interactive storytelling
- Operational monitoring (with Tim)

**Not Ideal For:**
- Static reports (use Quarto reports)
- One-time presentations (use presentation-generation)
- Complex statistical modeling (build in R, summarize in dashboard)

---

## Technical Requirements

**R Packages:**
- Core: shiny, shinydashboard or bslib
- Data: tidyverse, DT, reactable
- Visualization: ggplot2, plotly, highcharter
- Styling: bslib, thematic, fresh
- Deployment: rsconnect (for shinyapps.io/Connect)

**Shiny Patterns:**
- Modular design for reusable components
- Reactive values and observers
- Async programming for long-running tasks
- Caching strategies for performance

**Deployment Options:**
- **shinyapps.io** — Quick cloud deployment
- **Posit Connect** — Enterprise deployment
- **Shiny Server** — Self-hosted open-source
- **Docker** — Containerized deployment (with Tim)

**Expected Duration:**
- Step 1 (Design): 4-8 hours
- Step 2 (Build): 8-16 hours (varies by complexity)
- Step 3 (Test & Optimize): 4-8 hours
- Step 4 (Deploy): 2-4 hours

---

_Workflow created on 2026-03-26 for RDS Module v0.2.0_
