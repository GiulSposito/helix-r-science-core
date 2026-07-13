---
name: technical-report
description: Generate comprehensive technical report with full methodology
installed_path: '{project-root}/_bmad/rds/workflows/technical-report'
---

# Technical Report Workflow

**Module:** RDS (R Data Science)
**Owner:** Marie (The Reporter)
**Status:** Active
**Duration:** 1-2 days

---

## Workflow Overview

**Goal:** Create comprehensive technical documentation (30-50 pages) with full methodology, analysis, and reproducible code

**Description:** Generate publication-quality technical reports using Quarto. Includes complete data lineage, statistical methodology, model validation, and reproducible code chunks. Designed for technical stakeholders, peer review, and archival documentation.

**Workflow Type:** Core — Multi-step report generation

---

## Activation Sequence

<activation>

### Step 1: Welcome & Context

**Output:**
```
╔══════════════════════════════════════════════════════════════╗
║              TECHNICAL REPORT GENERATION                     ║
║        Comprehensive Documentation Workflow                  ║
╚══════════════════════════════════════════════════════════════╝

Marie here! Ready to document your data science work with publication-quality rigor.

This workflow will guide you through:
  • Step 1: Gather Inputs (collect artifacts from Alan, Grace, Ada)
  • Step 2: Structure Report (define sections, outline, narrative flow)
  • Step 3: Generate Report (build Quarto document with code/plots)
  • Step 4: Review & Refine (technical review, reproducibility check)

Duration: 1-2 days total

Let's create documentation that does your work justice!
```

### Step 2: Execute Workflow Steps

Load and execute each step sequentially:

1. **Step 1 — Gather Inputs**
   - File: `{installed_path}/steps/step-01-gather-inputs.md`
   - Goal: Collect all artifacts (models, metrics, plots, code) from previous phases
   - Action: Load and execute

2. **Step 2 — Structure Report**
   - File: `{installed_path}/steps/step-02-structure-report.md`
   - Goal: Define sections, create outline, establish narrative flow
   - Action: Load and execute

3. **Step 3 — Generate Report**
   - File: `{installed_path}/steps/step-03-generate-report.md`
   - Goal: Build complete Quarto document with code chunks, plots, tables
   - Action: Load and execute

4. **Step 4 — Review & Refine**
   - File: `{installed_path}/steps/step-04-review-refine.md`
   - Goal: Technical review, verify reproducibility, polish formatting
   - Action: Load and execute

### Step 3: Completion

**Output:**
```
╔══════════════════════════════════════════════════════════════╗
║           TECHNICAL REPORT COMPLETE!                         ║
╚══════════════════════════════════════════════════════════════╝

Your technical documentation is ready!

Generated artifacts:
  • technical-report.qmd — Source Quarto document
  • technical-report.html — Rendered report
  • figures/ — All embedded plots
  • code/ — Reproducible R scripts

Report sections:
  ✓ Executive Summary
  ✓ Problem Statement & Objectives
  ✓ Data Sources & Preparation
  ✓ Exploratory Analysis
  ✓ Methodology & Approach
  ✓ Results & Interpretation
  ✓ Model Performance & Validation
  ✓ Limitations & Assumptions
  ✓ Recommendations
  ✓ Appendix

Next steps:
  • Share with technical stakeholders
  • Use /bmad:rds:agents:marie for executive-report
  • Archive for reproducibility

Well documented! 📝
```

</activation>

---

## Workflow Properties

**Input Requirements:**
- Model evaluation results from Alan
- EDA plots and insights from Grace
- Data cleaning documentation from Ada
- Code artifacts from all phases

**Optional Inputs:**
- Project title and context
- Target audience specifications
- Formatting preferences
- Report template overrides

**Outputs:**
- `technical-report.qmd` — Quarto source document
- `technical-report.html` — Rendered HTML report
- `technical-report.pdf` — Optional PDF export
- `figures/` — All embedded visualizations
- `code/` — Reproducible R scripts referenced in report

---

## Agent Integration

**Primary Agent:** Marie (The Reporter)
- Owns and orchestrates this workflow
- Structures narrative flow
- Ensures statistical rigor and reproducibility

**Supporting Agents:**
- **Alan** — Provides model artifacts and validation metrics
- **Grace** — Provides EDA insights and feature engineering rationale
- **Ada** — Provides data quality documentation

---

## Implementation Notes

**Philosophy:**
- Reproducibility is non-negotiable — all code must run from scratch
- Statistical rigor over storytelling — methodology section explains all choices
- Code chunks shown with comments explaining decisions
- Appendix contains full diagnostic plots

**Report Structure:**
- Executive summary (1 page) for quick context
- Methodology deep dive (10-15 pages)
- Results with statistical tests and confidence intervals
- Full code in appendix for reproducibility

**Best For:**
- Peer review and publication
- Regulatory compliance documentation
- Archival technical documentation
- Training materials for team

**Not Ideal For:**
- Executive presentations (use executive-report)
- Quick updates (too detailed)
- Non-technical audiences (use executive-report or dashboard)

---

## Technical Requirements

**R Packages:**
- Core: tidyverse, here, fs
- Modeling: tidymodels, vetiver
- Reporting: quarto, rmarkdown, knitr
- Visualization: ggplot2, patchwork
- Tables: gt, kableExtra, flextable

**Quarto Extensions:**
- Code folding
- Cross-references
- Bibliography support
- Syntax highlighting

**Expected Duration:**
- Step 1 (Gather Inputs): 2-4 hours
- Step 2 (Structure Report): 2-4 hours
- Step 3 (Generate Report): 4-8 hours
- Step 4 (Review & Refine): 2-4 hours

---

_Workflow created on 2026-03-26 for RDS Module v0.2.0_
