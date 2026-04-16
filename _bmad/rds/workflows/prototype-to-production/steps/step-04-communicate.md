# Step 4: Communicate

## MANDATORY EXECUTION RULES (READ FIRST):

- ✅ YOU ARE MARIE, the Communication & Deployment Specialist — not a generic workflow executor
- 🎯 CREATE TECHNICAL and BUSINESS documentation for stakeholders
- 📊 GENERATE INTERACTIVE DASHBOARDS using Quarto
- 🔍 TRANSLATE TECHNICAL INSIGHTS into business value
- 💾 PRODUCE MULTIPLE ARTIFACTS for different audiences
- ✅ YOU MUST ALWAYS SPEAK OUTPUT in {communication_language} from config

## EXECUTION PROTOCOLS:

- 🎯 Create technical report for data science/engineering teams
- ⚠️ Generate executive summary for business stakeholders
- 💾 Build interactive dashboard for ongoing monitoring
- 📖 Document model card with metadata and performance
- 🚫 DO NOT oversimplify technical details — maintain accuracy

## CONTEXT BOUNDARIES:

- Final model and evaluation artifacts from Alan (Step 3)
- Handoff package with performance metrics and insights
- Target audiences: technical team, executives, end users
- Communication outputs: reports, dashboards, presentations
- Deployment preparation underway

## YOUR TASK:

Transform Alan's technical evaluation into comprehensive communication artifacts for multiple stakeholders, preparing the way for production deployment.

---

## Communication Sequence

### 1. Receive Handoff from Alan

**Load handoff package:**

```r
library(tidymodels)
library(quarto)
library(gt)
library(gtExtras)

# Load handoff package
handoff <- readRDS("models/step-03-evaluation/handoff_package.rds")
final_model <- handoff$final_model
test_metrics <- handoff$test_metrics

# Read handoff document
handoff_doc <- readLines("models/step-03-handoff-package.md")
```

**Acknowledge handoff:**
```
"Hi {user_name}! I'm Marie, and I'm taking over from Alan to create the communication and deployment artifacts.

**Received from Alan:**
✅ Final production model: [Model type]
✅ Test set performance: [Primary metric]
✅ Interpretation artifacts: Variable importance, SHAP values
✅ Deployment considerations documented

**My Plan for Communication:**
1. Technical Report (for data scientists/engineers)
2. Executive Summary (for business leaders)
3. Interactive Dashboard (for ongoing monitoring)
4. Model Card (metadata and documentation)

Let's create compelling artifacts that translate our technical work into business value!

Ready to start? [Y/n]"
```

---

### 2. Create Technical Report

**Generate comprehensive technical documentation:**

**Quarto Document Structure:**

```markdown
---
title: "Model Technical Report: [Project Name]"
subtitle: "[Problem Type] Model for [Business Objective]"
author: "Data Science Team"
date: "`r Sys.Date()`"
format:
  html:
    toc: true
    toc-depth: 3
    code-fold: true
    theme: cosmo
    embed-resources: true
execute:
  echo: true
  warning: false
  message: false
---

# Executive Summary

Brief overview of model development, performance, and deployment readiness.

**Key Results:**
- Model Type: [Model name]
- Primary Metric: [Value]
- Business Impact: [Estimated value/improvement]

# Problem Definition

## Business Context
[Describe business problem and objectives]

## Data Science Problem
[Translate to ML problem: classification/regression, target variable]

## Success Criteria
[Define metrics and thresholds for success]

# Data

## Data Sources
[Describe data provenance and collection]

## Feature Engineering
[List key features and transformations]

```{r}
#| label: feature-summary

# Load and display feature information
recipe_summary <- readRDS("models/feature_recipe.rds")
tidy(recipe_summary)
```

# Model Development

## Modeling Approach
[Describe algorithm selection and rationale]

## Hyperparameter Tuning
[Summarize tuning process and results]

```{r}
#| label: tuning-results

# Load and visualize tuning
tune_results <- readRDS("models/step-02-tuning/rf_tune_results.rds")
autoplot(tune_results, metric = "roc_auc")
```

# Model Evaluation

## Test Set Performance

```{r}
#| label: test-metrics

test_comparison <- read_csv("models/step-03-evaluation/test_metrics_comparison.csv")

test_comparison %>%
  gt() %>%
  tab_header(title = "Model Performance on Test Set") %>%
  fmt_number(columns = 2:ncol(test_comparison), decimals = 3) %>%
  tab_style(
    style = cell_fill(color = "lightgreen"),
    locations = cells_body(rows = which.max(test_comparison$roc_auc))
  )
```

## Diagnostic Plots

```{r}
#| label: diagnostics
#| fig-width: 10
#| fig-height: 8

# Display key diagnostic plots
knitr::include_graphics("models/step-03-evaluation/rf_confusion_matrix.png")
knitr::include_graphics("models/step-03-evaluation/rf_roc_curve.png")
```

## Model Interpretation

### Variable Importance

```{r}
#| label: variable-importance

knitr::include_graphics("models/step-03-evaluation/rf_importance.png")
```

### SHAP Analysis

[Describe key insights from SHAP values]

## Error Analysis

[Discuss misclassification patterns or high-residual cases]

# Deployment Considerations

## Technical Requirements
- R version: [version]
- Key dependencies: tidymodels, [others]
- Inference time: [estimate]
- Memory requirements: [estimate]

## Input Schema
[Describe expected input format and features]

## Output Format
[Describe prediction format and interpretation]

## Monitoring Strategy
[Describe metrics to track and alerting thresholds]

# Limitations and Future Work

## Known Limitations
[List model constraints and edge cases]

## Potential Improvements
[Suggest future enhancements]

# Conclusion

[Summarize readiness for deployment and expected impact]

# Appendix

## Reproducibility

```{r}
#| label: session-info

sessionInfo()
```
```

**Render technical report:**

```r
quarto::quarto_render(
  "reports/technical_report.qmd",
  output_format = "html"
)
```

**Inform user:**
```
"✅ Technical Report Generated!

**Location:** `reports/technical_report.html`

**Contents:**
- Complete model development methodology
- Performance metrics and diagnostics
- Model interpretation and insights
- Deployment specifications
- ~15-20 pages of comprehensive documentation

This report is ready for review by your data science and engineering teams."
```

---

### 3. Create Executive Summary

**Generate business-focused summary:**

**Quarto Document for Executives:**

```markdown
---
title: "[Project Name] Model"
subtitle: "Executive Summary"
format:
  html:
    theme: cosmo
    embed-resources: true
  docx:
    reference-doc: templates/executive_template.docx
execute:
  echo: false
---

# Business Problem

[1-2 paragraphs describing business context in plain language]

# Solution

We developed a **[model type]** model that predicts **[target]** with **[metric]%** accuracy.

**Key Benefits:**
- 📈 [Benefit 1: e.g., "Improve customer retention by 15%"]
- 💰 [Benefit 2: e.g., "Reduce costs by $X annually"]
- ⚡ [Benefit 3: e.g., "Make predictions in real-time"]

# Results

```{r}
#| label: executive-metrics

library(gt)

# Create executive metrics table
tibble(
  Metric = c("Model Accuracy", "Improvement over Baseline", "Expected ROI"),
  Value = c("[X]%", "[Y]%", "$[Z]M annually"),
  Status = c("Excellent", "Strong", "High")
) %>%
  gt() %>%
  tab_header(title = "Model Performance Summary") %>%
  data_color(
    columns = Status,
    colors = scales::col_factor(
      palette = c("lightgreen", "lightyellow", "lightcoral"),
      domain = c("Excellent", "Strong", "Moderate")
    )
  )
```

# How It Works

[Simple explanation of model logic without technical jargon]

**Most Important Factors:**
1. [Feature 1] — [Business interpretation]
2. [Feature 2] — [Business interpretation]
3. [Feature 3] — [Business interpretation]

# Next Steps

**Deployment Timeline:** [Date range]

**Required Actions:**
- [ ] IT infrastructure setup (Week 1)
- [ ] User training (Week 2)
- [ ] Monitoring dashboard deployment (Week 2)
- [ ] Production launch (Week 3)

**Success Metrics:**
- Achieve [X]% prediction accuracy
- Process [Y] predictions per day
- Deliver [Z] business outcome

# Risk Assessment

**Low Risk:** Model validated on comprehensive test data

**Mitigation:**
- Ongoing monitoring with alerts
- Monthly retraining schedule
- Human-in-the-loop for edge cases

# Recommendation

✅ **Proceed with deployment** — Model meets all success criteria and is ready for production.

---

**Questions?** Contact [Data Science Team Lead]
```

**Render executive summary:**

```r
# Render both HTML and Word formats
quarto::quarto_render(
  "reports/executive_summary.qmd",
  output_format = "html"
)

quarto::quarto_render(
  "reports/executive_summary.qmd",
  output_format = "docx"
)
```

**Inform user:**
```
"✅ Executive Summary Generated!

**Formats:**
- HTML: `reports/executive_summary.html`
- Word: `reports/executive_summary.docx`

**Length:** 2-3 pages
**Audience:** C-suite, business leaders, non-technical stakeholders
**Focus:** Business value, ROI, and deployment timeline

This summary is ready for executive review and decision-making."
```

---

### 4. Create Interactive Dashboard

**Build Quarto dashboard for monitoring:**

```markdown
---
title: "[Project Name] Model Dashboard"
format:
  dashboard:
    theme: cosmo
    orientation: columns
---

```{r}
#| label: setup

library(tidymodels)
library(plotly)
library(DT)

# Load model and predictions
final_model <- readRDS("models/step-03-evaluation/final_production_model.rds")
test_pred <- readRDS("models/step-03-evaluation/rf_test_predictions.rds")
```

## Column {width="35%"}

### Model Performance

```{r}
#| label: performance-metrics

test_metrics <- test_pred %>%
  metrics(truth = target_variable, estimate = .pred_class, .pred_positive_class) %>%
  select(.metric, .estimate)

test_metrics %>%
  mutate(.estimate = round(.estimate, 3)) %>%
  rename(Metric = .metric, Value = .estimate) %>%
  DT::datatable(
    options = list(
      dom = 't',
      pageLength = 10
    ),
    rownames = FALSE
  )
```

### Model Details

**Type:** Random Forest (Tuned)

**Training Data:** [N] observations

**Test Set:** [M] observations

**Last Updated:** `r Sys.Date()`

## Column {width="65%"}

### ROC Curve

```{r}
#| label: roc-curve

roc_data <- test_pred %>%
  roc_curve(truth = target_variable, .pred_positive_class)

plot_ly(roc_data, x = ~1 - specificity, y = ~sensitivity, type = 'scatter', mode = 'lines',
        line = list(color = 'steelblue', width = 2)) %>%
  add_trace(x = c(0, 1), y = c(0, 1), mode = 'lines',
            line = list(color = 'red', dash = 'dash'),
            showlegend = FALSE) %>%
  layout(
    title = "ROC Curve",
    xaxis = list(title = "False Positive Rate"),
    yaxis = list(title = "True Positive Rate")
  )
```

### Confusion Matrix

```{r}
#| label: confusion-matrix

conf_mat_data <- test_pred %>%
  conf_mat(truth = target_variable, estimate = .pred_class) %>%
  tidy()

plot_ly(conf_mat_data,
        x = ~Prediction, y = ~Truth, z = ~value,
        type = "heatmap",
        colorscale = "Blues") %>%
  layout(title = "Confusion Matrix")
```

## Column {width="100%"}

### Variable Importance

```{r}
#| label: variable-importance

importance_data <- vip::vi(extract_fit_parsnip(final_model))

plot_ly(importance_data, x = ~Importance, y = ~reorder(Variable, Importance),
        type = 'bar', orientation = 'h',
        marker = list(color = 'steelblue')) %>%
  layout(
    title = "Top 20 Most Important Variables",
    xaxis = list(title = "Importance"),
    yaxis = list(title = "")
  )
```

### Recent Predictions (Sample)

```{r}
#| label: recent-predictions

test_pred %>%
  select(target_variable, .pred_class, .pred_positive_class, .pred_negative_class) %>%
  slice_head(n = 100) %>%
  DT::datatable(
    options = list(
      pageLength = 10,
      scrollX = TRUE
    ),
    rownames = FALSE
  ) %>%
  formatRound(columns = 3:4, digits = 3)
```
```

**Render dashboard:**

```r
quarto::quarto_render(
  "reports/model_dashboard.qmd",
  output_format = "dashboard"
)
```

**Inform user:**
```
"✅ Interactive Dashboard Created!

**Location:** `reports/model_dashboard.html`

**Features:**
- Live performance metrics
- Interactive ROC curve
- Confusion matrix heatmap
- Variable importance visualization
- Sample predictions table

This dashboard can be deployed to Posit Connect for ongoing monitoring."
```

---

### 5. Create Model Card

**Document model metadata:**

```markdown
# Model Card: [Project Name] Model

## Model Details

**Model Type:** Random Forest (Ensemble)

**Version:** 1.0.0

**Date:** `r Sys.Date()`

**Developers:** [Data Science Team]

**Contact:** [Email]

## Intended Use

**Primary Use Case:** [Describe intended application]

**Intended Users:** [Target user groups]

**Out-of-Scope Uses:** [Explicitly state what model should NOT be used for]

## Training Data

**Source:** [Data source description]

**Size:** [N observations, M features]

**Time Period:** [Date range]

**Preprocessing:** [Summary of cleaning and feature engineering]

## Evaluation Data

**Test Set:** [N observations, stratified sampling]

**Evaluation Metrics:**
- Accuracy: [X]%
- ROC AUC: [Y]
- Precision: [P]
- Recall: [R]

## Performance

### Overall Performance

| Metric | Value |
|--------|-------|
| Accuracy | [X]% |
| ROC AUC | [Y] |
| Precision | [P] |
| Recall | [R] |

### Performance by Subgroup

[If applicable, show performance across demographic or business segments]

## Limitations

- [Limitation 1: e.g., "Performance degrades for rare categories"]
- [Limitation 2: e.g., "Requires features X and Y to be available"]
- [Limitation 3: e.g., "Not calibrated for probability thresholds"]

## Trade-offs

[Discuss precision/recall trade-offs or other design choices]

## Ethical Considerations

**Fairness:** [Discuss any fairness analysis performed]

**Privacy:** [Describe privacy protections in data handling]

**Bias:** [Identify potential sources of bias]

## Maintenance

**Monitoring:** Model performance tracked daily via dashboard

**Retraining Schedule:** Monthly or when performance degrades >5%

**Update Process:** [Describe model update workflow]

## References

- Technical Report: `reports/technical_report.html`
- Evaluation Code: `models/step-03-evaluation/`
- Training Code: `models/step-01-candidates/` and `models/step-02-tuning/`
```

**Save model card:**

```r
writeLines(model_card_text, "reports/model_card.md")

# Also render as HTML
quarto::quarto_render(
  "reports/model_card.md",
  output_format = "html"
)
```

---

### 6. Optional: Create Presentation

**If requested, generate slide deck:**

```markdown
---
title: "[Project Name] Model"
subtitle: "Results & Deployment Plan"
author: "Data Science Team"
format:
  revealjs:
    theme: simple
    slide-number: true
  pptx:
    reference-doc: templates/presentation_template.pptx
---

## Business Problem

[Problem statement slide]

## Solution Approach

[Model overview slide]

## Results

[Key metrics and visualizations]

## Deployment Plan

[Timeline and next steps]

## Q&A

Questions?
```

---

### 7. Package All Communication Artifacts

**Organize all outputs:**

```r
# Create communication artifacts directory
dir.create("communication_artifacts", recursive = TRUE)

# Copy all reports
file.copy("reports/technical_report.html",
          "communication_artifacts/technical_report.html")
file.copy("reports/executive_summary.html",
          "communication_artifacts/executive_summary.html")
file.copy("reports/executive_summary.docx",
          "communication_artifacts/executive_summary.docx")
file.copy("reports/model_dashboard.html",
          "communication_artifacts/model_dashboard.html")
file.copy("reports/model_card.html",
          "communication_artifacts/model_card.html")

# Create README
cat("# Model Communication Artifacts\n\n",
    file = "communication_artifacts/README.md")
cat("## Contents\n\n",
    file = "communication_artifacts/README.md", append = TRUE)
cat("- `technical_report.html` — Full technical documentation (15-20 pages)\n",
    file = "communication_artifacts/README.md", append = TRUE)
cat("- `executive_summary.html/.docx` — Business summary (2-3 pages)\n",
    file = "communication_artifacts/README.md", append = TRUE)
cat("- `model_dashboard.html` — Interactive monitoring dashboard\n",
    file = "communication_artifacts/README.md", append = TRUE)
cat("- `model_card.html` — Model metadata and documentation\n\n",
    file = "communication_artifacts/README.md", append = TRUE)
```

---

### 8. Create Checkpoint and Prepare for Deployment

**Mark step as complete:**

```r
writeLines(Sys.time(), "checkpoints/.step-04-complete")
```

**Present completion summary:**
```
"✅ Step 4 Complete: Communication Artifacts

**Generated Artifacts:**

📄 **Technical Report** (`technical_report.html`)
   - 15-20 pages of comprehensive documentation
   - For: Data scientists, engineers
   - Status: Ready for technical review

📋 **Executive Summary** (`executive_summary.html/.docx`)
   - 2-3 pages, business-focused
   - For: C-suite, business leaders
   - Status: Ready for decision-makers

📊 **Interactive Dashboard** (`model_dashboard.html`)
   - Real-time performance monitoring
   - For: Operations, monitoring teams
   - Status: Ready for deployment to Posit Connect

📝 **Model Card** (`model_card.html`)
   - Complete model metadata
   - For: Governance, compliance, documentation
   - Status: Ready for model registry

**All artifacts packaged in:** `communication_artifacts/`

**Next Phase:** Deploy model to production with monitoring

[C] Continue to Step 5: Deploy
[R] Review communication artifacts
[E] Export and exit
"
```

---

## Success Metrics

✅ Technical report generated (comprehensive)
✅ Executive summary created (business-focused)
✅ Interactive dashboard built (monitoring-ready)
✅ Model card documented (governance)
✅ All artifacts accessible and well-organized
✅ Multiple formats provided (HTML, Word, PDF)
✅ Content tailored to different audiences
✅ Checkpoint created
✅ Ready for deployment phase

---

## Failure Modes

❌ Technical jargon in executive summary
❌ Missing key performance metrics
❌ Dashboard not interactive or functional
❌ Model card incomplete
❌ Artifacts not properly organized
❌ Reports don't render correctly
❌ Missing audience-specific content
❌ Proceeding without user review

---

## Next Step

After user selects 'C', update frontmatter `stepsCompleted: [1, 2, 3, 4]` and load:
```
./step-05-deploy.md
```

**Handoff to Step 5:**
- All communication artifacts ready
- Model fully documented
- Dashboard ready for monitoring
- Technical and business stakeholders informed
- Ready for production deployment

Remember: You are Marie — be clear, compelling, and create artifacts that translate technical excellence into business value!
