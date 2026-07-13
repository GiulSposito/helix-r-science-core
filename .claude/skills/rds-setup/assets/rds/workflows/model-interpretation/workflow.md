---
name: model-interpretation
description: Comprehensive model interpretation and explainability workflow
installed_path: '{project-root}/_bmad/rds/workflows/model-interpretation'
---

# Model Interpretation Workflow

## Overview

This workflow provides comprehensive model interpretation and explainability for machine learning models. It combines global interpretation methods (understanding overall model behavior) with local interpretation methods (explaining individual predictions) to build trust and meet regulatory requirements.

**Owner:** Alan
**Duration:** 1-2 days
**Best for:** Regulated industries, stakeholder communication, model validation, building trust

---

## Workflow Structure

This is a **4-step sequential workflow** that progressively builds a complete interpretation package:

```
Step 1: Global Interpretation → Step 2: Local Interpretation → Step 3: Feature Importance → Step 4: Documentation
```

Each step builds on previous insights to create comprehensive model understanding.

---

## When to Use This Workflow

Use model-interpretation when you need:

- **Regulatory Compliance**: Healthcare, finance, insurance models requiring explainability
- **Stakeholder Communication**: Explaining model decisions to non-technical audiences
- **Model Debugging**: Understanding unexpected predictions or bias
- **Trust Building**: Validating model behavior before deployment
- **Feature Engineering**: Identifying which features drive predictions

**Prerequisites:**
- Trained model (tidymodels, xgboost, random forest, etc.)
- Test/validation dataset
- Understanding of business domain

---

## Workflow Steps

### Step 1: Global Interpretation
**Focus:** Overall model behavior understanding

Load: `exec="{installed_path}/steps/step-01-global-interpretation.md"`

**Deliverables:**
- Variable importance plots (VIP)
- Partial dependence plots (PDPs)
- Individual conditional expectation (ICE) curves
- Overall feature rankings

---

### Step 2: Local Interpretation
**Focus:** Individual prediction explanations

Load: `exec="{installed_path}/steps/step-02-local-interpretation.md"`

**Deliverables:**
- SHAP values for selected predictions
- LIME explanations
- Breakdown plots
- Prediction contribution visualizations

---

### Step 3: Feature Importance Analysis
**Focus:** Robust importance measures

Load: `exec="{installed_path}/steps/step-03-feature-importance.md"`

**Deliverables:**
- Permutation importance
- SHAP-based importance
- Correlated feature analysis
- Importance stability assessment

---

### Step 4: Documentation & Communication
**Focus:** Synthesize insights into reports

Load: `exec="{installed_path}/steps/step-04-documentation.md"`

**Deliverables:**
- Comprehensive interpretation report
- Executive summary
- Technical appendix
- Visual communication assets

---

## Required R Packages

```r
# Core interpretation packages
library(vip)           # Variable importance plots
library(DALEX)         # Model-agnostic explainers
library(iml)           # Interpretable ML methods
library(shapviz)       # SHAP visualizations

# Model-specific packages
library(SHAPforxgboost)  # SHAP for xgboost/lightgbm
library(treeshap)        # SHAP for tree models

# Tidymodels ecosystem
library(tidymodels)
library(parsnip)
library(recipes)

# Visualization
library(ggplot2)
library(patchwork)
library(plotly)

# Reporting
library(quarto)
library(gt)
library(gtExtras)
```

---

## Workflow Data Files

The workflow includes reference materials in `data/`:

- **interpretability-methods.md**: Comprehensive guide to interpretation methods, when to use each, strengths/limitations

Load these files in relevant steps for method selection guidance.

---

## Workflow Configuration

```yaml
---
name: model-interpretation
description: Deep model interpretation with SHAP, VIP, PDPs
web_bundle: true
installed_path: '{project-root}/_bmad/rds/workflows/model-interpretation'
output_folder: '{project-root}/_bmad-output'
---
```

---

## Navigation

**Current Step:** Workflow Overview (You are here)

**Next Action:**
- Run Step 1 to begin global interpretation
- Review `data/interpretability-methods.md` to understand available methods
- Prepare your trained model and test data

**To Start:**
```
Load: exec="{installed_path}/steps/step-01-global-interpretation.md"
```

---

## Tips for Success

1. **Start Global, Then Local**: Understand overall patterns before diving into individual predictions
2. **Choose Methods by Model Type**: Tree models → SHAP/TreeSHAP; Linear → coefficients + VIP; Neural nets → LIME/SHAP
3. **Visualize Everything**: Plots communicate better than tables for interpretation
4. **Consider Audience**: Technical vs business stakeholders need different depth
5. **Validate Explanations**: Cross-check multiple methods for consistency
6. **Document Assumptions**: Note any interpretation limitations or caveats

---

## Integration with RDS Module

This workflow is part of the **RDS (R Data Science) module** Phase 8 deep dive. It connects to:

- **Phase 3 (EDA)**: Feature understanding informs interpretation
- **Phase 5 (Modeling)**: Models from model-training workflow
- **Phase 6 (Evaluation)**: Performance metrics guide interpretation focus
- **Phase 8 (Model Interpretation)**: Core interpretability workflow

**Agents:**
- **Alan**: Owns this workflow, provides technical guidance
- **Marie**: Assists with stakeholder communication (Step 4)

---

_Model Interpretation Workflow — Part of RDS Module v1.0.0_
_Created: 2026-03-17_
