# Phase 9: Communication

**Owner:** Marie (Communicator)
**Duration:** 2-4 hours
**Status:** Active

---

## Phase Goal

Translate model results into stakeholder-friendly materials: presentations, dashboards, and documentation for business and technical audiences.

---

## Prerequisites

- Phase 8 complete (model evaluated and documented)
- Evaluation report available in `reports/model-report.html`
- Test predictions and diagnostics in `outputs/`
- Clear understanding of business objectives and audience

---

## Handoff from Alan

**Context from Alan:**
- Model evaluated: Test {metric} = {value}
- Evaluation report complete
- All diagnostics and visualizations generated
- Model ready for communication to stakeholders

**Marie's role:**
As the Communicator, I'll transform these technical results into compelling, actionable materials for different audiences.

---

## Step-by-Step Instructions

### 1. Identify Audiences and Goals

**What I need from you:**

1. **Primary Audience**:
   - Executives (high-level impact, ROI)?
   - Business users (practical use cases)?
   - Technical team (implementation details)?
   - Data scientists (methodology)?

2. **Key Questions to Answer**:
   - What business problem does this solve?
   - How does the model work (simplified)?
   - What's the expected impact?
   - How confident are we?
   - What are the risks/limitations?
   - What actions should stakeholders take?

3. **Deliverable Preferences**:
   - Executive summary (1-pager)?
   - Slide deck presentation?
   - Interactive dashboard?
   - Technical documentation?
   - All of the above?

### 2. Create Executive Summary

**One-page business overview:**

```markdown
# {Project Name}: Model Evaluation Summary

**Date:** {date}
**Prepared by:** Data Science Team

---

## Business Problem

{1-2 sentences describing the business problem this model addresses}

## Solution

We developed a {model_type} model that {what it predicts} with {metric} of {value}%, representing a {improvement}% improvement over the current baseline approach.

## Key Results

| Metric | Current Approach | ML Model | Improvement |
|--------|-----------------|----------|-------------|
| {metric1} | {value} | {value} | +{pct}% |
| {metric2} | {value} | {value} | +{pct}% |

**Business Impact:** {Estimated annual value, cost savings, efficiency gains}

## How It Works

{2-3 sentences explaining model in simple terms, avoiding jargon}

The model identifies patterns in {data} to predict {outcome}. Key factors include:
1. {Factor 1}: {simple explanation}
2. {Factor 2}: {simple explanation}
3. {Factor 3}: {simple explanation}

## Confidence & Reliability

- **Tested on:** {n} real cases never seen during training
- **Accuracy:** Correct {pct}% of the time
- **Calibration:** {Well-calibrated / Needs monitoring}
- **Limitations:** {1-2 key limitations}

## Recommendations

### Immediate Actions
1. {Action 1}
2. {Action 2}

### Next Steps
- **Deploy:** {Timeline} to {environment}
- **Monitor:** Track {key metrics}
- **Iterate:** Retrain {frequency}

## Timeline

- Phase 10 (Deployment): {duration}
- Production launch: {target date}

---

**Questions?** Contact {name} at {email}
```

Save as `reports/executive-summary.md` and render to PDF:

```r
rmarkdown::render(
  here("reports", "executive-summary.md"),
  output_format = "pdf_document"
)
```

### 3. Create Stakeholder Presentation

**Build slide deck with Quarto:**

**`reports/stakeholder-presentation.qmd`:**

```markdown
---
title: "{Project Name}"
subtitle: "Model Results & Recommendations"
author: "Data Science Team"
date: today
format:
  revealjs:
    theme: solarized
    transition: slide
    slide-number: true
    preview-links: true
---

## Problem Statement

**Business Challenge:**
- {Current pain point}
- {Impact of problem}
- {Cost/inefficiency}

**Goal:**
{What we're trying to achieve}

## Solution Overview

**Machine Learning Model**

- **Type:** {model_name}
- **Predicts:** {outcome}
- **Based on:** {n} features from {data sources}

![](../outputs/figures/ml_vs_baseline.png){width=70%}

## Model Performance

**Test Set Results**

| Metric | Value |
|--------|-------|
| {metric1} | {value}% |
| {metric2} | {value}% |
| {metric3} | {value}% |

::: {.callout-note}
Tested on {n} cases never seen during training
:::

## Key Drivers

**What matters most?**

![](../outputs/figures/final_variable_importance.png){width=80%}

Top 3 factors:
1. **{Factor 1}**: {Business interpretation}
2. **{Factor 2}**: {Business interpretation}
3. **{Factor 3}**: {Business interpretation}

## How It Works

**Simplified Explanation**

::: {.columns}
::: {.column width="50%"}
**Inputs:**
- {Feature 1}
- {Feature 2}
- {Feature 3}
:::

::: {.column width="50%"}
**Output:**
- Prediction: {outcome}
- Confidence: {0-100%}
- Recommendation: {action}
:::
:::

![](../outputs/figures/actual_vs_predicted.png){width=60%}

## Model Reliability

**Calibration Check**

![](../outputs/figures/calibration_plot.png){width=70%}

- ✓ Well-calibrated predictions
- ✓ Confidence scores reliable
- ⚠ Monitor for {known limitation}

## Error Analysis

**When does it struggle?**

![](../outputs/figures/errors_by_probability.png){width=70%}

**Common error patterns:**
- {Pattern 1}: {recommendation}
- {Pattern 2}: {recommendation}

## Business Impact

**Expected Value**

| Impact Area | Current | With Model | Improvement |
|------------|---------|------------|-------------|
| {Metric 1} | {value} | {value} | +{pct}% |
| {Metric 2} | {value} | {value} | +{pct}% |

**Annual Value:** ${estimated_value} or {other_metric}

## Use Cases

**How will this be used?**

1. **{Use case 1}**
   - {Description}
   - {Expected benefit}

2. **{Use case 2}**
   - {Description}
   - {Expected benefit}

3. **{Use case 3}**
   - {Description}
   - {Expected benefit}

## Limitations & Risks

**What to watch out for**

::: {.callout-warning}
**Limitations:**
- {Limitation 1}
- {Limitation 2}

**Mitigation:**
- {Strategy 1}
- {Strategy 2}
:::

## Recommendations

**Immediate Actions**

1. ✓ {Action 1}
2. ✓ {Action 2}
3. → {Next action}

**Success Metrics**

- Monitor: {metric}
- Target: {value}
- Review: {frequency}

## Timeline

**Deployment Plan**

| Phase | Duration | Key Activities |
|-------|----------|----------------|
| Deployment | {weeks} | API, monitoring, integration |
| Pilot | {weeks} | {n} users, collect feedback |
| Scale | {weeks} | Full rollout |

**Target Launch:** {date}

## Questions?

**Contact:**
- {Name}: {email}
- Documentation: {link}
- Dashboard: {link}

---

*Thank you!*
```

Render presentation:

```r
quarto::quarto_render(
  here("reports", "stakeholder-presentation.qmd"),
  output_format = "revealjs"
)
```

### 4. Build Interactive Dashboard

**Create Shiny app for model exploration:**

**`reports/model-dashboard.R`:**

```r
library(shiny)
library(tidyverse)
library(here)
library(plotly)
library(DT)

# Load data
test_predictions <- read_rds(here("outputs", "tables", "test_predictions.rds"))
variable_importance <- read_csv(here("outputs", "tables", "final_variable_importance.csv"))
final_model <- read_rds(here("outputs", "models", "final_model.rds"))

# UI
ui <- fluidPage(
  titlePanel("{Project Name} - Model Dashboard"),

  tabsetPanel(
    # Tab 1: Overview
    tabPanel("Overview",
      fluidRow(
        column(4,
          h3("Model Performance"),
          tableOutput("metrics_table")
        ),
        column(8,
          plotlyOutput("confusion_matrix_plot")
        )
      ),
      fluidRow(
        column(6,
          plotlyOutput("roc_curve_plot")
        ),
        column(6,
          plotlyOutput("calibration_plot")
        )
      )
    ),

    # Tab 2: Feature Importance
    tabPanel("Features",
      fluidRow(
        column(12,
          h3("Feature Importance"),
          sliderInput("n_features", "Number of features:",
                     min = 5, max = 30, value = 15),
          plotlyOutput("importance_plot", height = "600px")
        )
      ),
      fluidRow(
        column(12,
          h3("Feature Details"),
          DTOutput("feature_table")
        )
      )
    ),

    # Tab 3: Predictions Explorer
    tabPanel("Predictions",
      fluidRow(
        column(3,
          h4("Filters"),
          selectInput("correct_filter", "Show:",
                     choices = c("All", "Correct", "Incorrect")),
          sliderInput("confidence_range", "Confidence:",
                     min = 0, max = 1, value = c(0, 1))
        ),
        column(9,
          h4("Individual Predictions"),
          DTOutput("predictions_table")
        )
      ),
      fluidRow(
        column(12,
          h4("Prediction Distribution"),
          plotlyOutput("prediction_dist_plot")
        )
      )
    ),

    # Tab 4: Model Simulator
    tabPanel("Simulator",
      fluidRow(
        column(4,
          h3("Input Features"),
          # Dynamically create inputs for top features
          uiOutput("feature_inputs")
        ),
        column(8,
          h3("Prediction Result"),
          verbatimTextOutput("prediction_output"),
          plotlyOutput("prediction_bar")
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {

  # Overview: Metrics table
  output$metrics_table <- renderTable({
    tibble(
      Metric = c("Accuracy", "ROC AUC", "Precision", "Recall", "F1"),
      Value = c("{acc}", "{auc}", "{prec}", "{rec}", "{f1}")
    )
  })

  # Overview: Confusion matrix
  output$confusion_matrix_plot <- renderPlotly({
    # Create confusion matrix plot
    conf_mat <- test_predictions |>
      count(!!sym("{target_var}"), .pred_class)

    plot_ly(conf_mat,
            x = ~.pred_class,
            y = ~!!sym("{target_var}"),
            z = ~n,
            type = "heatmap",
            colorscale = "Blues") |>
      layout(title = "Confusion Matrix")
  })

  # Features: Importance plot
  output$importance_plot <- renderPlotly({
    plot_data <- variable_importance |>
      head(input$n_features) |>
      arrange(Importance)

    plot_ly(plot_data,
            x = ~Importance,
            y = ~reorder(Variable, Importance),
            type = "bar",
            orientation = "h") |>
      layout(
        title = "Feature Importance",
        yaxis = list(title = ""),
        xaxis = list(title = "Importance")
      )
  })

  # Features: Details table
  output$feature_table <- renderDT({
    variable_importance |>
      datatable(
        options = list(pageLength = 15),
        rownames = FALSE
      )
  })

  # Predictions: Filtered table
  predictions_filtered <- reactive({
    data <- test_predictions

    # Filter by correctness
    if (input$correct_filter == "Correct") {
      data <- data |> filter(!!sym("{target_var}") == .pred_class)
    } else if (input$correct_filter == "Incorrect") {
      data <- data |> filter(!!sym("{target_var}") != .pred_class)
    }

    # Filter by confidence
    data |>
      filter(
        .pred_{positive_class} >= input$confidence_range[1],
        .pred_{positive_class} <= input$confidence_range[2]
      )
  })

  output$predictions_table <- renderDT({
    predictions_filtered() |>
      select(!!sym("{target_var}"), .pred_class, .pred_{positive_class},
             everything()) |>
      datatable(
        options = list(pageLength = 20),
        rownames = FALSE
      ) |>
      formatRound(columns = starts_with(".pred_"), digits = 3)
  })

  # Simulator: Dynamic inputs
  output$feature_inputs <- renderUI({
    top_features <- variable_importance |> head(5) |> pull(Variable)

    lapply(top_features, function(feature) {
      # Determine input type based on feature
      if (is.numeric(test_predictions[[feature]])) {
        sliderInput(
          paste0("input_", feature),
          feature,
          min = min(test_predictions[[feature]], na.rm = TRUE),
          max = max(test_predictions[[feature]], na.rm = TRUE),
          value = median(test_predictions[[feature]], na.rm = TRUE)
        )
      } else {
        selectInput(
          paste0("input_", feature),
          feature,
          choices = unique(test_predictions[[feature]])
        )
      }
    })
  })

  # Simulator: Make prediction
  output$prediction_output <- renderPrint({
    # Collect inputs
    # Make prediction with final_model
    cat("Prediction: {class}\n")
    cat("Confidence: {prob}%\n")
  })
}

# Run app
shinyApp(ui = ui, server = server)
```

### 5. Create Technical Documentation

**Comprehensive model card:**

**`reports/model-documentation.md`:**

```markdown
# Model Documentation

**Project:** {Project Name}
**Model Version:** 1.0
**Last Updated:** {date}
**Owner:** Data Science Team

---

## Model Overview

### Purpose
{Detailed description of what the model does and why it was built}

### Model Type
- **Algorithm:** {model_name}
- **Framework:** tidymodels
- **Language:** R {version}

### Performance
- **Primary Metric:** {metric} = {value}
- **Test Set Size:** {n} observations
- **Cross-Validation:** 10-fold stratified CV

---

## Data

### Input Data
**Source:** {description}
**Update Frequency:** {daily/weekly/monthly}

**Features:** {n_features}
- {Feature 1}: {description, type, range}
- {Feature 2}: {description, type, range}
...

### Target Variable
- **Name:** {target_var}
- **Type:** {classification/regression}
- **Classes:** {if classification, list classes}
- **Distribution:** {describe}

### Data Preprocessing
1. Missing values: {strategy}
2. Outliers: {strategy}
3. Scaling: {method}
4. Encoding: {method for categorical}

---

## Model Architecture

### Hyperparameters
```r
{param1} = {value}
{param2} = {value}
{param3} = {value}
```

### Feature Engineering
1. **Transformations:**
   - {transformation 1}
   - {transformation 2}

2. **Interactions:**
   - {var1} × {var2}

3. **Derived Features:**
   - {feature}: {calculation}

### Training Process
- **Training Set:** {n} observations ({pct}%)
- **Validation:** 10-fold CV
- **Tuning Method:** Bayesian optimization
- **Training Time:** {duration}

---

## Performance Metrics

### Test Set Results
| Metric | Value | 95% CI |
|--------|-------|--------|
| {metric1} | {value} | [{lower}, {upper}] |
| {metric2} | {value} | [{lower}, {upper}] |

### Comparison to Baseline
- **Baseline:** {description}
- **Improvement:** +{pct}%

### Performance by Segment
| Segment | {Metric} | Sample Size |
|---------|----------|-------------|
| {segment1} | {value} | {n} |
| {segment2} | {value} | {n} |

---

## Model Interpretation

### Feature Importance
Top 10 features (see `final_variable_importance.csv`):
1. {Feature 1}: {importance value}
2. {Feature 2}: {importance value}
...

### Decision Logic
{High-level explanation of how the model makes decisions}

### Confidence Scores
- Confidence scores are {well-calibrated / require calibration}
- Threshold recommendation: {value} for {balance of precision/recall}

---

## Limitations & Considerations

### Known Limitations
1. {Limitation 1}
   - **Impact:** {description}
   - **Mitigation:** {strategy}

2. {Limitation 2}
   - **Impact:** {description}
   - **Mitigation:** {strategy}

### When NOT to Use
- {Scenario 1}
- {Scenario 2}

### Fairness & Bias
{Assessment of potential biases, fairness across groups}

---

## Deployment

### API Endpoint
**URL:** `{url}`
**Method:** POST
**Input Format:**
```json
{
  "feature1": value,
  "feature2": value,
  ...
}
```

**Output Format:**
```json
{
  "prediction": "class",
  "confidence": 0.85,
  "prediction_id": "uuid"
}
```

### Latency
- **Expected:** {ms} milliseconds
- **P95:** {ms} milliseconds

### Dependencies
```r
tidymodels = {version}
{package1} = {version}
{package2} = {version}
```

---

## Monitoring & Maintenance

### Monitoring Plan
**Key Metrics:**
- Prediction distribution
- Confidence scores
- Performance metrics (if ground truth available)

**Thresholds:**
- Retrain if {metric} < {threshold}
- Alert if prediction distribution shifts > {pct}%

### Retraining Schedule
- **Frequency:** {monthly/quarterly}
- **Trigger:** Performance degradation or data drift

### Update History
| Version | Date | Changes |
|---------|------|---------|
| 1.0 | {date} | Initial deployment |

---

## References

- **Code Repository:** {github_link}
- **Training Scripts:** `scripts/06-model.R`, `scripts/07-tune.R`
- **Evaluation Report:** `reports/model-report.html`
- **Model File:** `outputs/models/final_model.rds`

---

## Contact

**Questions?** Contact {name} at {email}

**Issue Tracking:** {link}
```

### 6. Create Data Storytelling Visualization

**Narrative-driven Quarto report for broader audience:**

**`reports/model-story.qmd`:**

```markdown
---
title: "How We Built a Model to {Achieve Goal}"
subtitle: "A Data Science Journey"
author: "Marie (Communicator)"
date: today
format:
  html:
    theme: cosmo
    toc: false
    smooth-scroll: true
---

## The Challenge

{Start with compelling business problem description}

## The Data

{Show interesting patterns in the raw data}

## Building the Solution

{Visual journey through EDA, feature engineering, modeling}

## The Results

{Impactful visualization of model performance}

## What This Means for {Business/Users}

{Concrete examples and use cases}

## Try It Yourself

{Link to dashboard or interactive demo}
```

### 7. Validation Checklist

Before proceeding to Phase 10:

- [ ] Executive summary created (1-pager)
- [ ] Stakeholder presentation rendered
- [ ] Interactive dashboard functional
- [ ] Technical documentation complete
- [ ] Model card filled out
- [ ] Data storytelling report created
- [ ] All materials reviewed for clarity
- [ ] Jargon minimized for non-technical audience
- [ ] Visualizations clear and impactful
- [ ] Ready to hand off to Phase 10 (Deployment)

---

## Outputs

**Created Files:**
- `reports/executive-summary.pdf`
- `reports/stakeholder-presentation.html`
- `reports/model-dashboard.R`
- `reports/model-documentation.md`
- `reports/model-story.html`
- `scripts/09-report.R`
- `checkpoints/09-communication.complete`

**Git Commit:**
```bash
git add reports/ scripts/09-report.R
git commit -m "feat: create stakeholder communication materials

- Executive summary (1-pager)
- Stakeholder presentation
- Interactive Shiny dashboard
- Technical documentation
- Model story for broad audience

Phase 9/10 complete

Co-Authored-By: Marie (Communicator) <noreply@bmad.com>"
```

---

## Troubleshooting

**Issue:** Presentation too technical
- **Solution**: Remove jargon, use analogies, focus on business impact over methodology

**Issue:** Dashboard slow to load
- **Solution**: Sample data, optimize plots, add loading indicators

**Issue:** Stakeholders want different format
- **Solution**: Quarto supports multiple output formats (PDF, Word, PowerPoint)

**Issue:** Need to translate materials
- **Solution**: Separate content from formatting, translate markdown text

---

## Next Phase

**Phase 10: Deploy**

With communication materials ready, Marie continues to:
1. Deploy model as Vetiver API
2. Setup monitoring dashboards
3. Create deployment documentation
4. Establish feedback loop
5. Plan model maintenance schedule

**Transition:** When ready, say "Continue to Phase 10" or "Deploy to production"

---

## Phase Completion

When this phase is complete:
1. Executive summary created
2. Stakeholder presentation ready
3. Interactive dashboard deployed
4. Technical documentation complete
5. Communication materials reviewed
6. Checkpoint file created
7. Git commit made
8. **Marie continues to Phase 10**

**Expected Duration:** 2-4 hours

---

_Phase 9 of 10 | Owner: Marie | RDS Module Full-Lifecycle Workflow_
