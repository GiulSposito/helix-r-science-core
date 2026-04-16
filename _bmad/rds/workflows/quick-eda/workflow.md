---
name: quick-eda
description: Streamlined 4-step workflow for rapid data exploration
installed_path: '{project-root}/_bmad/rds/workflows/quick-eda'
---

# Quick-EDA Workflow

**Module:** RDS (R Data Science)
**Owner:** Grace (R Data Science Lead)
**Status:** Active
**Duration:** 4-8 hours

---

## Workflow Overview

**Goal:** Rapidly explore new datasets with streamlined setup, import, cleaning, and EDA

**Description:** Fast-track workflow for data exploration and prototyping. This streamlined workflow skips some validation steps of the full data science lifecycle for speed, but maintains reproducibility. Ideal for new datasets, prototyping, and exploratory projects.

**Workflow Type:** Core — Streamlined, 4-phase exploration

---

## Activation Sequence

<activation>

### Step 1: Welcome & Context

**Output:**
```
╔══════════════════════════════════════════════════════════════╗
║                   QUICK-EDA WORKFLOW                         ║
║              Streamlined Data Exploration                    ║
╚══════════════════════════════════════════════════════════════╝

Grace here! Ready to fast-track your data exploration.

This workflow will guide you through:
  • Step 1: Quick Setup (minimal project structure)
  • Step 2: Import Data (load your dataset)
  • Step 3: Quick Clean (basic automated cleaning)
  • Step 4: EDA (comprehensive exploratory analysis)

Duration: 4-8 hours total

Let's get started!
```

### Step 2: Execute Workflow Steps

Load and execute each step sequentially:

1. **Step 1 — Quick Setup**
   - File: `{installed_path}/steps/step-01-quick-setup.md`
   - Goal: Create minimal project structure with renv initialization
   - Action: Load and execute

2. **Step 2 — Import Data**
   - File: `{installed_path}/steps/step-02-import-data.md`
   - Goal: Load data quickly with automatic type detection
   - Action: Load and execute

3. **Step 3 — Quick Clean**
   - File: `{installed_path}/steps/step-03-quick-clean.md`
   - Goal: Fast cleaning with automated decisions
   - Action: Load and execute

4. **Step 4 — EDA**
   - File: `{installed_path}/steps/step-04-eda.md`
   - Goal: Generate comprehensive EDA report with visualizations
   - Action: Load and execute

### Step 3: Completion

**Output:**
```
╔══════════════════════════════════════════════════════════════╗
║                 QUICK-EDA COMPLETE!                          ║
╚══════════════════════════════════════════════════════════════╝

Your exploratory data analysis is ready!

Generated artifacts:
  • eda-report.html — Comprehensive EDA report
  • plots/ — Individual visualization files
  • data/ — Processed datasets
  • scripts/ — Reproducible R scripts

Next steps:
  • Review the EDA report for insights
  • Use /bmad:rds:agents:grace for deeper analysis
  • Consider full-eda workflow if more rigor needed

Happy exploring! 📊
```

</activation>

---

## Workflow Properties

**Input Requirements:**
- Data source (file path, URL, or database connection)

**Optional Inputs:**
- Project name (defaults to "quick-eda-{timestamp}")
- Output format (HTML, PDF — defaults to HTML)

**Outputs:**
- `eda-report.html` — Comprehensive EDA report with visualizations
- `plots/` — Individual EDA plots (PNG/PDF)
- `data/` — Cleaned datasets (RDS/CSV)
- `scripts/` — Reproducible R scripts

---

## Agent Integration

**Primary Agent:** Grace (R Data Science Lead)
- Owns and orchestrates this workflow
- Guides data exploration decisions
- Interprets EDA findings

**Supporting Agent:** Ada (Project Architect)
- Quick setup assistance (Phase 1-2)
- Project structure recommendations

---

## Implementation Notes

**Philosophy:**
- Trade validation depth for speed
- Automate more decisions (imputation strategies, transformation choices)
- Generate rich HTML report at end (Quarto)
- Maintain reproducibility without sacrificing agility

**Key Differences from Full-EDA:**
- Minimal setup (no extensive renv catalog)
- Automated cleaning decisions (less user consultation)
- Single EDA report (no iterative refinement)
- Fast iterations prioritized over comprehensive validation

**Best For:**
- New datasets requiring quick assessment
- Prototyping and proof-of-concept work
- Exploratory projects
- Time-sensitive analysis

**Not Ideal For:**
- Production pipelines (use full-eda)
- High-stakes decision making (use full-eda)
- Complex data quality issues (use full-eda)

---

## Technical Requirements

**R Packages:**
- Core: tidyverse, here, fs
- Import: readr, haven, readxl, vroom
- Cleaning: janitor, naniar, skimr
- EDA: DataExplorer, inspectdf, summarytools
- Visualization: ggplot2, patchwork, plotly
- Reporting: quarto, rmarkdown

**Expected Duration:**
- Step 1 (Quick Setup): 30-60 minutes
- Step 2 (Import): 15-30 minutes
- Step 3 (Quick Clean): 1-2 hours
- Step 4 (EDA): 2-4 hours

---

_Workflow created on 2026-03-17 for RDS Module_
