---
name: data-quality-check
description: Deep dive data quality validation and remediation
installed_path: '{project-root}/_bmad/rds/workflows/data-quality-check'
---

# Data Quality Check Workflow

**Owner:** Ada (Project Architect)  
**Duration:** 4-8 hours

## Overview

**Purpose:** Comprehensive data quality assessment for suspicious data, high missings, or critical projects. Goes beyond standard cleaning with systematic validation.

**When to Use:**
- High percentage of missing values detected
- Outliers or anomalies in exploratory analysis
- Critical projects requiring rigorous quality standards
- Data from untrusted or unknown sources
- Before high-stakes modeling or reporting

**Owner:** Ada (Project Architect)

**Estimated Duration:** 4-8 hours depending on data complexity

---

## Workflow Structure

This is a **4-step sequential workflow** that systematically evaluates and improves data quality:

```
Step 1: Missing Analysis
  └─> Pattern detection (MCAR, MAR, MNAR)
  └─> Visualization of missing patterns
  └─> Impact assessment

Step 2: Outlier Detection
  └─> Multiple detection methods (IQR, Z-score, isolation)
  └─> Domain-specific rules
  └─> Outlier visualization

Step 3: Consistency Checks
  └─> Range validation
  └─> Cross-variable relationships
  └─> Business logic validation

Step 4: Remediation
  └─> Fix issues systematically
  └─> Document all decisions
  └─> Generate quality report
```

---

## Prerequisites

Before starting this workflow:

1. **Data Loaded:** Raw or partially cleaned data available
2. **Domain Knowledge:** Understanding of expected ranges, relationships
3. **Quality Thresholds:** Acceptable levels of missings/outliers (if known)
4. **R Packages:** naniar, visdat, ggplot2, dplyr, tidyr, tibble

---

## Inputs

### Required
- **Data:** Tibble or data frame to validate
- **Variable metadata:** Variable names, types, expected ranges (can be elicited during workflow)

### Optional
- **Domain rules:** Business-specific validation rules
- **Quality standards:** Acceptable missing thresholds, outlier criteria
- **Historical benchmarks:** Previous data quality metrics for comparison

---

## Outputs

### Files Generated
- `data_quality_report.html` — Comprehensive quality assessment with visualizations
- `missing_analysis.html` — Detailed missing data patterns and mechanisms
- `outlier_report.html` — Outlier detection results from multiple methods
- `remediation_log.md` — Documentation of all fixes and decisions

### R Objects
- `data_quality_metrics` — List containing all computed metrics
- `cleaned_data` — Data after remediation steps
- `flagged_cases` — Cases requiring manual review

---

## Workflow Steps

### Step 1: Missing Analysis

**Goal:** Identify missing data patterns and mechanisms

**Activities:**
- Compute missing proportions by variable
- Visualize missing patterns (naniar, visdat)
- Test for MCAR (Little's test)
- Identify MAR/MNAR patterns
- Assess impact on analysis goals

**Duration:** 1-2 hours

**exec="{installed_path}/steps/step-01-missing-analysis.md"**

---

### Step 2: Outlier Detection

**Goal:** Systematically identify outliers using multiple methods

**Activities:**
- IQR method for continuous variables
- Z-score detection (configurable threshold)
- Isolation Forest for multivariate outliers
- Apply domain-specific rules
- Visualize detected outliers
- Distinguish errors from legitimate extremes

**Duration:** 1-2 hours

**exec="{installed_path}/steps/step-02-outlier-detection.md"**

---

### Step 3: Consistency Checks

**Goal:** Validate cross-variable relationships and business logic

**Activities:**
- Range validation (min/max checks)
- Cross-variable consistency (e.g., start_date < end_date)
- Sum/total validations
- Category level validation
- Business rule checks
- Temporal consistency

**Duration:** 1-2 hours

**exec="{installed_path}/steps/step-03-consistency-checks.md"**

---

### Step 4: Remediation

**Goal:** Fix issues systematically and document all decisions

**Activities:**
- Categorize issues (deletable, fixable, flaggable)
- Apply remediation strategies
- Document every decision
- Generate quality report
- Create remediation log
- Update data dictionary

**Duration:** 1-2 hours

**exec="{installed_path}/steps/step-04-remediation.md"**

---

## Decision Points

Throughout the workflow, Ada will help you make critical decisions:

1. **Missing Data:** Impute, delete, or flag?
2. **Outliers:** Real extremes or errors?
3. **Inconsistencies:** Fix automatically or review manually?
4. **Quality Thresholds:** Accept current quality or require improvement?

---

## Best Practices

### DO
- Document every quality issue discovered
- Use multiple detection methods for validation
- Visualize quality issues before remediation
- Preserve original data (never overwrite)
- Create reproducible quality reports
- Test missingness mechanisms (don't assume MCAR)

### DON'T
- Delete cases without understanding why they're problematic
- Impute missing data without considering mechanism
- Apply one-size-fits-all outlier removal
- Fix inconsistencies without domain knowledge
- Skip documentation of remediation decisions

---

## Integration with RDS Module

This workflow is part of Phase 3 (Data Cleaning) but represents a **deep dive** approach:

**Standard Cleaning (quick-clean):** 30-60 minutes, basic fixes
**Quality Check (this workflow):** 4-8 hours, comprehensive validation

Use quick-clean for most projects. Use data-quality-check when:
- Data quality is questionable
- High stakes project
- Regulatory requirements
- Building production models

---

## References

- **Metrics Reference:** `{installed_path}/data/data-quality-metrics.md`
- **R Packages:** naniar, visdat, outliers, anomalize
- **Theory:** Rubin's missing data framework, Tukey's outlier methods

---

## Activation

To activate this workflow from Ada's menu:

```
Choose: "4. Data Quality Check"
or type: /bmad:rds:workflows:data-quality-check
```

Ada will guide you through all four steps, ensuring comprehensive quality assessment and remediation.

---

_Workflow created on 2026-03-17 for RDS Module v1.0.0_
