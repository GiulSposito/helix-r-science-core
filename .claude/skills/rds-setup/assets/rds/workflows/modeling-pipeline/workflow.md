---
name: modeling-pipeline
description: Feature engineering + modeling + tuning + evaluation
installed_path: '{project-root}/_bmad/rds/workflows/modeling-pipeline'
---

# Modeling Pipeline Workflow

## Workflow Overview

**Purpose:** Execute a complete modeling pipeline from feature engineering through final evaluation for clean datasets.

**Owner:** Alan (ML Engineer)

**Duration:** 1-2 weeks

**Prerequisites:** Clean data ready for modeling (from Ada's data-pipeline workflow)

---

## Workflow Architecture

This workflow implements **Phases 5-8** of the RDS methodology:

- **Phase 5:** Feature Engineering (recipes, transformations)
- **Phase 6:** Baseline Models (quick comparison)
- **Phase 7:** Tuning (hyperparameter optimization)
- **Phase 8:** Evaluation (test set, diagnostics, interpretation)

### Key Principles

1. **Data Budgeting:** Test set touched ONCE at the end
2. **Honest Estimation:** All preprocessing inside CV folds
3. **Breadth Before Depth:** Compare multiple model types before tuning
4. **Documentation:** Track all decisions and reasoning

---

## Workflow Steps

### Step 1: Feature Engineering

**Goal:** Transform, encode, and create features using recipes

**Handler:** `exec="{installed_path}/steps/step-01-feature-engineering.md"`

**Inputs:**
- Clean data (data frame or path)
- Target variable name
- Problem type (classification/regression)

**Outputs:**
- `recipe.rds` — Preprocessing recipe object
- `feature_engineering_report.html` — Documentation

---

### Step 2: Baseline Models

**Goal:** Build and compare multiple model types

**Handler:** `exec="{installed_path}/steps/step-02-baseline-models.md"`

**Inputs:**
- Recipe from Step 1
- Data split strategy
- Model types to compare

**Outputs:**
- `baseline_comparison.html` — Model comparison report
- `baseline_models/` — Saved model objects
- Top 2-3 candidates for tuning

---

### Step 3: Tuning

**Goal:** Hyperparameter optimization for selected models

**Handler:** `exec="{installed_path}/steps/step-03-tuning.md"`

**Inputs:**
- Top models from Step 2
- Tuning strategy (grid/Bayesian/racing)
- Compute budget

**Outputs:**
- `tuning_results.html` — Optimization report
- `tuned_models/` — Best model configurations
- `final_model.rds` — Champion model

---

### Step 4: Evaluation

**Goal:** Test set evaluation, diagnostics, and interpretation

**Handler:** `exec="{installed_path}/steps/step-04-evaluation.md"`

**Inputs:**
- Final model from Step 3
- Test set (held out from beginning)
- Evaluation metrics

**Outputs:**
- `evaluation_report.html` — Complete test set results
- `interpretation/` — VIP plots, SHAP values, PDPs
- `diagnostics/` — Residual plots, calibration curves
- `production_artifacts/` — Deployment-ready files

---

## Activation Sequence

<activation>

### Step 1: Load Configuration

Load module configuration:

```path
{project-root}/_bmad/rds/config.yaml
```

Extract variables:
- `{user_name}` — User's name
- `{communication_language}` — Preferred language
- `{output_folder}` — Output directory
- `{project_root}` — Repository root

---

### Step 2: Present Workflow Menu

Olá, **{user_name}**! Sou **Alan**, seu engenheiro de ML.

Esta é a **Modeling Pipeline Workflow** — um pipeline completo de feature engineering até avaliação final.

**Pipeline Overview:**
- **Step 1:** Feature Engineering (recipes)
- **Step 2:** Baseline Models (quick comparison)
- **Step 3:** Tuning (hyperparameter optimization)
- **Step 4:** Evaluation (test set results)

**Prerequisites:**
- Clean data ready for modeling
- Clear problem definition (classification/regression)
- Target variable identified

---

### Workflow Menu

```menu
1. Start Complete Pipeline — Run all 4 steps sequentially
2. Step 1: Feature Engineering — Create preprocessing recipe
3. Step 2: Baseline Models — Compare multiple model types
4. Step 3: Tuning — Optimize hyperparameters
5. Step 4: Evaluation — Test set evaluation and interpretation
6. View Model Selection Guide — Choose appropriate algorithms
7. View Metric Selection Guide — Choose evaluation metrics
8. Resume from Step — Continue interrupted workflow
9. Help — Workflow guidance and best practices
```

**What would you like to do?** (Enter number or description)

---

### Step 3: Wait for Input

</activation>

---

## Menu Handlers

### Handler 1: Start Complete Pipeline

**Action:** Execute all 4 steps in sequence

**Workflow:**
1. Confirm prerequisites (clean data, target variable, problem type)
2. Execute Step 1 (Feature Engineering)
3. Review recipe, proceed to Step 2 (Baseline Models)
4. Review comparison, select models for Step 3 (Tuning)
5. Execute Step 3, proceed to Step 4 (Evaluation)
6. Generate final deliverables

**Output Location:** `{output_folder}/modeling-pipeline-{timestamp}/`

---

### Handler 2-5: Individual Steps

**Action:** Execute single step

**Handler:** Load corresponding step file:
- Handler 2: `exec="{installed_path}/steps/step-01-feature-engineering.md"`
- Handler 3: `exec="{installed_path}/steps/step-02-baseline-models.md"`
- Handler 4: `exec="{installed_path}/steps/step-03-tuning.md"`
- Handler 5: `exec="{installed_path}/steps/step-04-evaluation.md"`

---

### Handler 6: View Model Selection Guide

**Action:** Display model selection reference

**Exec:** `{installed_path}/data/model-selection-guide.md`

---

### Handler 7: View Metric Selection Guide

**Action:** Display metric selection reference

**Exec:** `{installed_path}/data/metric-selection-guide.md`

---

### Handler 8: Resume from Step

**Action:** Resume interrupted workflow

**Workflow:**
1. Ask which step to resume from
2. Verify previous step outputs exist
3. Load context from previous steps
4. Continue pipeline from selected step

---

### Handler 9: Help

**Action:** Display workflow guidance

**Content:**

```markdown
## Modeling Pipeline Help

### Prerequisites Checklist
- [ ] Clean data (no missing values, outliers handled)
- [ ] Target variable identified and understood
- [ ] Problem type clear (classification/regression)
- [ ] Domain knowledge available for feature engineering
- [ ] Compute resources available for tuning

### Best Practices
1. **Test Set Discipline:** Never touch test set until Step 4
2. **Honest CV:** All preprocessing inside CV folds
3. **Baseline First:** Compare multiple model types before tuning
4. **Document Everything:** Track decisions and reasoning

### Common Workflows
- **Quick exploration:** Steps 1-2 only
- **Production model:** All 4 steps
- **Iterative improvement:** Steps 1-2, then return with better features

### Typical Timeline
- Step 1: 1-2 days
- Step 2: 2-3 days
- Step 3: 3-5 days (depends on compute)
- Step 4: 1-2 days

**Total:** 1-2 weeks for complete pipeline

### When to Use This Workflow
- Clean data ready for modeling
- Need production-quality model
- Time available for proper evaluation
- Want interpretable results

### When NOT to Use
- Data still needs cleaning (use data-pipeline first)
- Quick prototype needed (use exploratory-analysis)
- Unsupervised learning (different workflow)
```

---

## Workflow State Management

### Context Files

The workflow maintains state through:

1. `workflow_state.yaml` — Current step, inputs, outputs
2. `decisions_log.md` — All modeling decisions and reasoning
3. `artifacts_index.md` — Generated files and their purposes

### State Transitions

```
[Step 1] → recipe.rds → [Step 2] → baseline_models/ → [Step 3] → final_model.rds → [Step 4] → evaluation_report.html
```

Each step verifies required inputs before execution.

---

## Integration with RDS Module

### Input from Ada's Workflow

This workflow expects clean data from Ada's `data-pipeline` workflow:
- No missing values
- Outliers handled
- Data types correct
- Initial EDA complete

### Output to Production

Step 4 generates production-ready artifacts:
- `final_model.rds` — Trained model object
- `recipe.rds` — Preprocessing pipeline
- `deployment_guide.md` — Usage instructions
- `monitoring_metrics.yaml` — Performance thresholds

---

## Technical Notes

### Tidymodels Integration

This workflow uses the tidymodels ecosystem:
- **recipes** — Feature engineering
- **parsnip** — Model specifications
- **tune** — Hyperparameter optimization
- **yardstick** — Metrics
- **workflows** — Bundling recipe + model

### Compute Considerations

- **Step 2:** Moderate (parallel CV for multiple models)
- **Step 3:** High (grid search or Bayesian optimization)
- Consider using `doFuture` or `doParallel` for parallelization

### Data Size Guidelines

- **Small (<10K rows):** All steps quick, use generous CV
- **Medium (10K-1M rows):** Step 3 may take hours
- **Large (>1M rows):** Consider sampling for Step 2, full data for Step 3-4

---

**Workflow created on 2026-03-17 for RDS Module**
**Owner:** Alan (ML Engineer)
**Status:** Production-ready
