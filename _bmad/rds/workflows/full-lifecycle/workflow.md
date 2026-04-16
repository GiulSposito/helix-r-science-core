---
name: full-lifecycle
description: Complete 10-phase DS lifecycle from setup to deployment
installed_path: '{project-root}/_bmad/rds/workflows/full-lifecycle'
---

# Full-Lifecycle Data Science Workflow

**Module:** rds
**Owner:** Ada (Project Architect)
**Duration:** 2-4 weeks
**Created:** 2026-03-17

---

## Overview

This is the **MASTER workflow** for the RDS module. It orchestrates the complete data science lifecycle, from raw data to production deployment, following Tidyverse and Tidymodels best practices.

**Orchestration Pattern:**
- Ada coordinates overall progress and phase transitions
- Grace handles exploratory and feature engineering phases
- Alan manages modeling, tuning, and evaluation
- Marie produces communication artifacts and deployment

**Validation Strategy:**
Each phase validates completion before proceeding. Checkpoints allow resume if interrupted.

---

## Workflow Phases

### Phase 1: Setup Project
**Step:** `step-01-setup.md`
**Owner:** Ada
**Goal:** Create project structure, initialize renv, setup Git

<exec file="{installed_path}/steps/step-01-setup.md" />

---

### Phase 2: Import & Inspect
**Step:** `step-02-import-inspect.md`
**Owner:** Ada
**Goal:** Load data, run glimpse/skim, identify data quality issues

<exec file="{installed_path}/steps/step-02-import-inspect.md" />

---

### Phase 3: Clean Data
**Step:** `step-03-clean.md`
**Owner:** Ada
**Goal:** Wrangle data, handle missings, address outliers

<exec file="{installed_path}/steps/step-03-clean.md" />

---

### Phase 4: Exploratory Data Analysis (EDA)
**Step:** `step-04-eda.md`
**Owner:** Grace
**Goal:** Explore distributions, relationships, patterns with visualizations

<exec file="{installed_path}/steps/step-04-eda.md" />

---

### Phase 5: Feature Engineering
**Step:** `step-05-feature-engineering.md`
**Owner:** Grace
**Goal:** Transform variables, encode categoricals, create new features

<exec file="{installed_path}/steps/step-05-feature-engineering.md" />

---

### Phase 6: Modeling
**Step:** `step-06-modeling.md`
**Owner:** Alan
**Goal:** Build baseline and multiple candidate models

<exec file="{installed_path}/steps/step-06-modeling.md" />

---

### Phase 7: Tuning
**Step:** `step-07-tuning.md`
**Owner:** Alan
**Goal:** Hyperparameter optimization with cross-validation

<exec file="{installed_path}/steps/step-07-tuning.md" />

---

### Phase 8: Evaluation
**Step:** `step-08-evaluation.md`
**Owner:** Alan
**Goal:** Test set performance, diagnostics, model interpretation

<exec file="{installed_path}/steps/step-08-evaluation.md" />

---

### Phase 9: Communication
**Step:** `step-09-communication.md`
**Owner:** Marie
**Goal:** Generate reports, dashboards, and presentation materials

<exec file="{installed_path}/steps/step-09-communication.md" />

---

### Phase 10: Deploy
**Step:** `step-10-deploy.md`
**Owner:** Marie
**Goal:** Deploy model as Vetiver API with monitoring

<exec file="{installed_path}/steps/step-10-deploy.md" />

---

## Workflow State Management

**Progress Tracking:**
- Each phase creates a `.complete` marker file in `/checkpoints/`
- Resume capability: workflow checks for existing markers
- Artifacts saved at each phase for reproducibility

**Phase Transition Checklist:**
See `data/phase-transitions.md` for detailed handoff protocols between phases.

---

## Usage

Invoke via bmad-master menu or directly:

```
/bmad:rds:workflows:full-lifecycle
```

**Required Inputs:**
- Project name (optional, defaults to directory name)
- Data source (file path or database connection)

**Optional Inputs:**
- Modeling preferences (algorithms, metrics)
- Deployment target (local, cloud, Posit Connect)

---

## Integration Points

**Skills Activated:**
- r-datascience (phases 1-3)
- r-tidymodels (phases 6-8)
- ggplot2 (phase 4)
- quarto (phase 9)
- r-shiny (phase 9, optional dashboards)

**External Resources:**
- Git repository (initialized in phase 1)
- renv lock file (managed throughout)
- Vetiver pin board (phase 10)

---

_Created on 2026-03-17 via RDS Module workflow (Create Mode)_
