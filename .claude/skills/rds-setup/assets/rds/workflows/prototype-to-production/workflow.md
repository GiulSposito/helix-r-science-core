---
name: prototype-to-production
description: Modeling + communication + deploy for production
installed_path: '{project-root}/_bmad/rds/workflows/prototype-to-production'
---

# Prototype-to-Production Workflow

**Module:** rds
**Owner:** Marie (with handoff from Alan)
**Duration:** 1-2 weeks
**Created:** 2026-03-17

---

## Overview

This workflow takes **validated features and recipes** through the complete modeling-to-production pipeline. It focuses on **Phases 6-10** of the data science lifecycle, assuming data wrangling and feature engineering are complete.

**Orchestration Pattern:**
- Alan drives modeling, tuning, and evaluation (Phases 6-8)
- Marie takes ownership of communication and deployment (Phases 9-10)
- Handoff occurs after Phase 8 with complete model documentation

**Prerequisites:**
- Feature engineering complete (recipe or processed data ready)
- Target variable identified
- Problem type defined (classification/regression)

**Ideal For:**
- Teams with validated features ready for modeling
- Projects requiring production deployment
- Scenarios where EDA/feature work is separate from modeling

---

## Workflow Steps

### Step 1: Build Model
**File:** `step-01-build-model.md`
**Owner:** Alan
**Goal:** Create baseline and candidate models, compare performance

<exec file="{installed_path}/steps/step-01-build-model.md" />

---

### Step 2: Tune
**File:** `step-02-tune.md`
**Owner:** Alan
**Goal:** Optimize hyperparameters using cross-validation and tuning grids

<exec file="{installed_path}/steps/step-02-tune.md" />

---

### Step 3: Evaluate
**File:** `step-03-evaluate.md`
**Owner:** Alan
**Goal:** Assess performance on test set, generate diagnostics and interpretation

<exec file="{installed_path}/steps/step-03-evaluate.md" />

---

### Step 4: Communicate
**File:** `step-04-communicate.md`
**Owner:** Marie
**Goal:** Generate technical reports, executive summaries, and interactive dashboards

<exec file="{installed_path}/steps/step-04-communicate.md" />

---

### Step 5: Deploy
**File:** `step-05-deploy.md`
**Owner:** Marie
**Goal:** Deploy model as Vetiver API with monitoring and documentation

<exec file="{installed_path}/steps/step-05-deploy.md" />

---

## Workflow Outputs

**Model Artifacts:**
- `final_model.rds` — Production-ready model object
- `model_workflow.rds` — Complete tidymodels workflow
- `tuning_results.rds` — Hyperparameter tuning history

**Documentation:**
- `technical_report.qmd/.html` — Detailed technical documentation
- `executive_summary.qmd/.html` — Business-focused summary
- `model_card.md` — Model metadata and performance summary

**Communication:**
- `dashboard.qmd/.html` — Interactive performance dashboard
- `presentation_slides.qmd/.pptx` — Stakeholder presentation (optional)

**Deployment:**
- `model_api/` — Vetiver API directory with plumber files
- `deployment_checklist.md` — Pre-deployment validation checklist
- `monitoring_setup.md` — Monitoring configuration and maintenance guide

---

## Workflow State Management

**Checkpoints:**
Each step creates a completion marker in `/checkpoints/`:
- `.step-01-complete` — Models built and compared
- `.step-02-complete` — Tuning completed
- `.step-03-complete` — Evaluation finished, ready for handoff
- `.step-04-complete` — Documentation and reports generated
- `.step-05-complete` — Deployment complete

**Handoff Protocol (Step 3 → Step 4):**
After Alan completes evaluation, Marie receives:
- Final model object and metrics
- Test set performance summary
- Key insights and interpretation
- Technical constraints and considerations

See `templates/deployment-checklist.md` for detailed handoff requirements.

---

## Usage

Invoke via bmad-master menu or directly:

```
/bmad:rds:workflows:prototype-to-production
```

**Required Inputs:**
- Recipe or processed data ready for modeling
- Target variable name
- Problem type (classification/regression)

**Optional Inputs:**
- Specific algorithms to test
- Tuning budget (time/iterations)
- Deployment target (Posit Connect, Docker, local)
- Monitoring preferences

---

## Integration Points

**Skills Activated:**
- r-tidymodels (Steps 1-3)
- r-performance (Step 2, tuning optimization)
- quarto (Step 4, reporting)
- r-shiny (Step 4, optional dashboards)

**External Resources:**
- Git repository (assumed initialized)
- renv lock file (dependencies tracked)
- Vetiver pin board (Step 5, model registry)
- Deployment infrastructure (Posit Connect, Docker, cloud)

**Related Workflows:**
- `feature-engineering` — Prepare features before this workflow
- `full-lifecycle` — Complete 10-phase workflow including earlier phases

---

## Templates

**Pre-Deployment:**
- `templates/deployment-checklist.md` — Validation before production
- `templates/monitoring-setup.md` — Monitoring configuration guide

Access templates during workflow execution or use directly for deployment planning.

---

_Created on 2026-03-17 via RDS Module workflow (Create Mode)_
