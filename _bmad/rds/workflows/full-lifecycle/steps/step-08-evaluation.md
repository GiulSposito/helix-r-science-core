# Phase 8: Model Evaluation

**Owner:** Alan (Model Master)
**Duration:** 2-3 hours
**Status:** Active

---

## Phase Goal

Rigorously evaluate final model on held-out test set, generate comprehensive diagnostics, and create evaluation report for stakeholders.

---

## Prerequisites

- Phase 7 complete (final model tuned and saved)
- Test set never used for training or validation
- Final model in `outputs/models/final_model.rds`
- Clear understanding of business metrics and thresholds

---

## Continuation from Phase 7

**Alan continues:**
Our model is fully trained and tuned. Now for the moment of truth - evaluation on the held-out test set that the model has never seen.

---

## Step-by-Step Instructions

### 1. Load Final Model and Test Data

```r
library(tidyverse)
library(tidymodels)
library(here)

# Load final model
final_model <- read_rds(here("outputs", "models", "final_model.rds"))

# Load test data (NEVER used until now)
test_data <- read_rds(here("data", "processed", "test_processed.rds"))

# Target variable
target_var <- "{your_target}"

cat("=== TEST SET EVALUATION ===\n")
cat("Test set size:", nrow(test_data), "observations\n")
cat("Model type:", class(final_model)[1], "\n\n")
```

### 2. Generate Test Set Predictions

```r
# Make predictions
test_predictions <- final_model |>
  augment(new_data = test_data)

# Save predictions
write_csv(test_predictions, here("outputs", "tables", "test_predictions.csv"))
write_rds(test_predictions, here("outputs", "tables", "test_predictions.rds"))

cat("Test predictions generated and saved\n")
```

### 3. Calculate Test Set Metrics

**For Classification:**

```r
# Define comprehensive metrics
class_metrics <- metric_set(
  accuracy,
  roc_auc,
  precision,
  recall,
  f_meas,
  kap,           # Cohen's Kappa
  mcc,           # Matthews Correlation Coefficient
  bal_accuracy   # Balanced accuracy
)

# Calculate metrics
test_metrics <- test_predictions |>
  class_metrics(truth = !!sym(target_var), estimate = .pred_class, .pred_{positive_class})

# Display results
cat("\n=== TEST SET PERFORMANCE ===\n")
test_metrics |>
  arrange(desc(.estimate)) |>
  mutate(.estimate = round(.estimate, 4)) |>
  print()

# Visualize metrics
test_metrics |>
  ggplot(aes(x = reorder(.metric, .estimate), y = .estimate)) +
  geom_col(fill = "steelblue") +
  geom_text(aes(label = round(.estimate, 3)), hjust = -0.2) +
  coord_flip() +
  ylim(0, 1) +
  labs(
    title = "Test Set Performance Metrics",
    x = NULL,
    y = "Value"
  ) +
  theme_minimal()

ggsave(here("outputs", "figures", "test_metrics.png"),
       width = 10, height = 6)
```

**For Regression:**

```r
# Regression metrics
reg_metrics <- metric_set(
  rmse,
  mae,
  rsq,
  mape,          # Mean Absolute Percentage Error
  huber_loss,    # Robust to outliers
  ccc            # Concordance Correlation Coefficient
)

test_metrics <- test_predictions |>
  reg_metrics(truth = !!sym(target_var), estimate = .pred)

cat("\n=== TEST SET PERFORMANCE ===\n")
test_metrics |>
  mutate(.estimate = round(.estimate, 4)) |>
  print()
```

### 4. Confusion Matrix and Classification Report

**For Classification:**

```r
# Confusion matrix
conf_mat <- test_predictions |>
  conf_mat(truth = !!sym(target_var), estimate = .pred_class)

# Visualize
autoplot(conf_mat, type = "heatmap") +
  labs(title = "Confusion Matrix - Test Set") +
  theme_minimal()

ggsave(here("outputs", "figures", "confusion_matrix.png"),
       width = 8, height = 6)

# Detailed classification report
conf_mat_summary <- summary(conf_mat)
write_csv(conf_mat_summary, here("outputs", "tables", "confusion_matrix_summary.csv"))

# Per-class metrics
class_summary <- test_predictions |>
  group_by(!!sym(target_var)) |>
  summarise(
    n = n(),
    precision = precision_vec(!!sym(target_var), .pred_class),
    recall = recall_vec(!!sym(target_var), .pred_class),
    f1 = f_meas_vec(!!sym(target_var), .pred_class)
  )

write_csv(class_summary, here("outputs", "tables", "per_class_metrics.csv"))
```

### 5. ROC Curve and Threshold Analysis

**For Binary Classification:**

```r
# ROC curve
roc_curve_data <- test_predictions |>
  roc_curve(truth = !!sym(target_var), .pred_{positive_class})

# Plot ROC
roc_curve_data |>
  autoplot() +
  labs(
    title = "ROC Curve - Test Set",
    subtitle = paste("AUC =", round(test_metrics |>
      filter(.metric == "roc_auc") |>
      pull(.estimate), 4))
  ) +
  theme_minimal()

ggsave(here("outputs", "figures", "roc_curve.png"),
       width = 8, height = 6)

# Threshold analysis
threshold_data <- test_predictions |>
  threshold_perf(
    truth = !!sym(target_var),
    estimate = .pred_{positive_class},
    thresholds = seq(0.1, 0.9, by = 0.05)
  )

# Visualize precision-recall trade-off
threshold_data |>
  pivot_longer(c(.precision, .recall), names_to = "metric", values_to = "value") |>
  ggplot(aes(x = .threshold, y = value, color = metric)) +
  geom_line(size = 1.5) +
  geom_vline(xintercept = 0.5, linetype = "dashed", alpha = 0.5) +
  labs(
    title = "Precision-Recall vs Threshold",
    x = "Threshold",
    y = "Value",
    color = "Metric"
  ) +
  theme_minimal()

ggsave(here("outputs", "figures", "threshold_analysis.png"),
       width = 10, height = 6)

# Precision-Recall curve
pr_curve_data <- test_predictions |>
  pr_curve(truth = !!sym(target_var), .pred_{positive_class})

pr_curve_data |>
  autoplot() +
  labs(title = "Precision-Recall Curve") +
  theme_minimal()

ggsave(here("outputs", "figures", "pr_curve.png"),
       width = 8, height = 6)
```

### 6. Calibration Analysis

**Check if predicted probabilities match actual outcomes:**

```r
# For classification: calibration curve
test_predictions <- test_predictions |>
  mutate(
    prob_bin = cut(.pred_{positive_class},
                   breaks = seq(0, 1, by = 0.1),
                   include.lowest = TRUE)
  )

calibration_data <- test_predictions |>
  group_by(prob_bin) |>
  summarise(
    mean_predicted = mean(.pred_{positive_class}),
    mean_actual = mean(as.numeric(!!sym(target_var)) - 1),  # 0/1 encoding
    n = n()
  ) |>
  drop_na()

# Calibration plot
calibration_data |>
  ggplot(aes(x = mean_predicted, y = mean_actual)) +
  geom_point(aes(size = n), alpha = 0.6) +
  geom_abline(linetype = "dashed", color = "red") +
  labs(
    title = "Calibration Plot",
    subtitle = "Perfect calibration = diagonal line",
    x = "Mean Predicted Probability",
    y = "Observed Frequency",
    size = "Count"
  ) +
  coord_fixed() +
  theme_minimal()

ggsave(here("outputs", "figures", "calibration_plot.png"),
       width = 8, height = 6)
```

### 7. Error Analysis

**For Classification: Analyze misclassifications**

```r
# Identify errors
errors <- test_predictions |>
  mutate(
    correct = (!!sym(target_var) == .pred_class),
    error_type = case_when(
      correct ~ "Correct",
      !correct & !!sym(target_var) == "{positive_class}" ~ "False Negative",
      !correct & !!sym(target_var) == "{negative_class}" ~ "False Positive",
      TRUE ~ "Other"
    )
  )

# Error rate by predicted probability
errors |>
  ggplot(aes(x = .pred_{positive_class}, fill = correct)) +
  geom_histogram(bins = 30, position = "fill") +
  labs(
    title = "Correct vs Incorrect by Predicted Probability",
    x = "Predicted Probability",
    y = "Proportion",
    fill = "Correct"
  ) +
  theme_minimal()

ggsave(here("outputs", "figures", "errors_by_probability.png"),
       width = 10, height = 6)

# Worst predictions (highest confidence, wrong)
worst_predictions <- errors |>
  filter(!correct) |>
  mutate(confidence = pmax(.pred_{positive_class}, 1 - .pred_{positive_class})) |>
  arrange(desc(confidence)) |>
  head(20)

write_csv(worst_predictions, here("outputs", "tables", "worst_predictions.csv"))

cat("\nTop 5 most confident errors:\n")
worst_predictions |>
  select(!!sym(target_var), .pred_class, confidence, everything()) |>
  head(5) |>
  print()
```

**For Regression: Residual analysis**

```r
# Calculate residuals
test_predictions <- test_predictions |>
  mutate(
    residual = !!sym(target_var) - .pred,
    abs_residual = abs(residual),
    pct_error = abs(residual) / !!sym(target_var) * 100
  )

# Residual plot
test_predictions |>
  ggplot(aes(x = .pred, y = residual)) +
  geom_point(alpha = 0.5) +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  geom_smooth(method = "loess", color = "blue") +
  labs(
    title = "Residual Plot",
    subtitle = "Check for patterns (should be random)",
    x = "Predicted Value",
    y = "Residual"
  ) +
  theme_minimal()

ggsave(here("outputs", "figures", "residual_plot.png"),
       width = 10, height = 6)

# Actual vs Predicted
test_predictions |>
  ggplot(aes(x = !!sym(target_var), y = .pred)) +
  geom_point(alpha = 0.5) +
  geom_abline(color = "red", linetype = "dashed") +
  labs(
    title = "Actual vs Predicted",
    x = "Actual Value",
    y = "Predicted Value"
  ) +
  theme_minimal()

ggsave(here("outputs", "figures", "actual_vs_predicted.png"),
       width = 8, height = 8)

# Residual distribution
test_predictions |>
  ggplot(aes(x = residual)) +
  geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7) +
  geom_vline(xintercept = 0, color = "red", linetype = "dashed") +
  labs(
    title = "Residual Distribution",
    subtitle = "Should be approximately normal, centered at 0"
  ) +
  theme_minimal()

ggsave(here("outputs", "figures", "residual_distribution.png"),
       width = 10, height = 6)

# Worst predictions
worst_predictions <- test_predictions |>
  arrange(desc(abs_residual)) |>
  head(20)

write_csv(worst_predictions, here("outputs", "tables", "worst_predictions.csv"))
```

### 8. Model Interpretation

**Feature importance and SHAP values:**

```r
# Variable importance (already computed, reload)
variable_importance <- read_csv(here("outputs", "tables", "final_variable_importance.csv"))

# For tree-based models: SHAP values (if using {SHAPforxgboost} or {fastshap})
if ({model_type} %in% c("xgb", "rf")) {
  library(fastshap)

  # Create explainer (sample for speed)
  test_sample <- test_data |> slice_sample(n = min(500, nrow(test_data)))

  # Note: This can be slow, adjust nsim for speed/accuracy trade-off
  shap_values <- explain(
    final_model |> extract_fit_parsnip(),
    X = test_sample |> select(-!!sym(target_var)),
    nsim = 10,
    pred_wrapper = function(object, newdata) {
      predict(object, new_data = newdata)$.pred
    }
  )

  # SHAP summary plot (top 10 features)
  shap_summary <- shap_values |>
    as_tibble() |>
    mutate(row_id = row_number()) |>
    pivot_longer(-row_id, names_to = "feature", values_to = "shap_value") |>
    group_by(feature) |>
    summarise(
      mean_abs_shap = mean(abs(shap_value)),
      .groups = "drop"
    ) |>
    arrange(desc(mean_abs_shap)) |>
    head(10)

  shap_summary |>
    ggplot(aes(x = reorder(feature, mean_abs_shap), y = mean_abs_shap)) +
    geom_col(fill = "steelblue") +
    coord_flip() +
    labs(
      title = "SHAP Feature Importance",
      subtitle = "Mean absolute SHAP value",
      x = NULL,
      y = "Importance"
    ) +
    theme_minimal()

  ggsave(here("outputs", "figures", "shap_importance.png"),
         width = 10, height = 8)
}

# Partial dependence plots (top 3 features)
top_3_features <- variable_importance |> head(3) |> pull(Variable)

for (feature in top_3_features) {
  pdp_data <- partial(
    final_model |> extract_fit_parsnip(),
    pred.var = feature,
    train = test_data |> select(-!!sym(target_var)),
    prob = TRUE  # For classification
  )

  p <- pdp_data |>
    ggplot(aes(x = !!sym(feature), y = yhat)) +
    geom_line(size = 1.5, color = "steelblue") +
    labs(
      title = paste("Partial Dependence:", feature),
      y = "Predicted Probability/Value"
    ) +
    theme_minimal()

  ggsave(here("outputs", "figures", paste0("pdp_", feature, ".png")),
         plot = p, width = 10, height = 6)
}
```

### 9. Compare to Business Baseline

**How does this compare to current approach?**

```r
# Define business baseline (e.g., always predict majority class, current rule-based system)
baseline_metrics <- test_predictions |>
  mutate(
    baseline_pred = "{most_common_class}"  # Or current system prediction
  ) |>
  {metrics}(truth = !!sym(target_var), estimate = baseline_pred, ...)

# Compare to model
comparison <- bind_rows(
  baseline_metrics |> mutate(approach = "Business Baseline"),
  test_metrics |> mutate(approach = "ML Model")
)

comparison |>
  filter(.metric %in% c("accuracy", "roc_auc", "f_meas", "rmse")) |>
  ggplot(aes(x = .metric, y = .estimate, fill = approach)) +
  geom_col(position = "dodge") +
  labs(
    title = "ML Model vs Business Baseline",
    x = "Metric",
    y = "Value",
    fill = "Approach"
  ) +
  theme_minimal()

ggsave(here("outputs", "figures", "ml_vs_baseline.png"),
       width = 10, height = 6)
```

### 10. Create Evaluation Report

**Generate comprehensive Quarto report:**

**`reports/model-report.qmd`:**

```markdown
---
title: "Model Evaluation Report"
subtitle: "{Project Name}"
author: "Alan (Model Master)"
date: today
format:
  html:
    code-fold: true
    toc: true
    toc-depth: 3
    theme: cosmo
execute:
  echo: false
  warning: false
  message: false
---

## Executive Summary

**Model Type:** {model_name}
**Problem:** {classification/regression}
**Test Set Performance:** {primary_metric} = {value} ± {se}
**Business Impact:** {estimated impact}

### Key Findings
- Model achieves {metric} of {value}, exceeding baseline by {improvement}%
- Strongest predictors: {top_3_features}
- Well-calibrated with {assessment}
- Ready for deployment with {recommendations}

## 1. Model Overview

### Architecture
- **Model type**: {model_name}
- **Training samples**: {n_train}
- **Test samples**: {n_test}
- **Features**: {n_features}

### Hyperparameters
```{r}
# Display best parameters
read_rds(here("outputs", "models", "final_model_params.rds"))
```

## 2. Test Set Performance

### Overall Metrics
```{r}
# Metrics table
test_metrics |> arrange(desc(.estimate))
```

### Visualizations
![](../outputs/figures/test_metrics.png)

### Confusion Matrix
![](../outputs/figures/confusion_matrix.png)

## 3. Model Diagnostics

### ROC and Precision-Recall
![](../outputs/figures/roc_curve.png)
![](../outputs/figures/pr_curve.png)

### Calibration
![](../outputs/figures/calibration_plot.png)

**Interpretation:** {describe calibration quality}

## 4. Error Analysis

### Misclassification Patterns
![](../outputs/figures/errors_by_probability.png)

### Worst Predictions
```{r}
# Show top 10 worst predictions
read_csv(here("outputs", "tables", "worst_predictions.csv")) |> head(10)
```

**Common error patterns:**
- {pattern 1}
- {pattern 2}
- {recommendations}

## 5. Model Interpretation

### Feature Importance
![](../outputs/figures/final_variable_importance.png)

**Top 5 features:**
1. {feature}: {interpretation}
2. {feature}: {interpretation}
...

### Partial Dependence
![](../outputs/figures/pdp_{feature1}.png)

**Interpretation:** {describe relationship}

## 6. Comparison to Baseline

![](../outputs/figures/ml_vs_baseline.png)

**Performance lift:**
- {metric}: +{improvement}%
- Estimated business value: ${value} or {other_metric}

## 7. Model Limitations

### Known Issues
- {limitation 1}
- {limitation 2}

### When Model May Fail
- {scenario 1}
- {scenario 2}

### Recommended Monitoring
- {metric to monitor}
- {threshold for retraining}

## 8. Recommendations

### Deployment
- ✓ Model ready for production
- Confidence threshold: {recommended_threshold}
- Expected performance: {metric} ≈ {value}

### Future Improvements
1. {improvement opportunity}
2. {additional data needed}
3. {alternative approaches to explore}

## 9. Next Steps

**Phase 9: Communication**
- Create stakeholder presentation
- Build interactive dashboard
- Write model documentation

**Phase 10: Deployment**
- Deploy as Vetiver API
- Setup monitoring
- Create feedback loop

---

*Generated by Alan (Model Master) | Phase 8/10 | RDS Module*
```

Render report:
```r
quarto::quarto_render(here("reports", "model-report.qmd"))
```

### 11. Validation Checklist

Before proceeding to Phase 9:

- [ ] Test set predictions generated (never used before Phase 8)
- [ ] Comprehensive metrics calculated
- [ ] Confusion matrix / residual plots created
- [ ] ROC/PR curves analyzed (classification)
- [ ] Calibration checked
- [ ] Error analysis completed
- [ ] Variable importance documented
- [ ] Model interpretation performed
- [ ] Comparison to baseline documented
- [ ] Evaluation report rendered
- [ ] Model limitations identified
- [ ] Ready to hand off to Marie for communication

---

## Outputs

**Created Files:**
- `scripts/08-evaluate.R`
- `outputs/tables/test_predictions.csv`
- `outputs/tables/test_predictions.rds`
- `outputs/tables/confusion_matrix_summary.csv`
- `outputs/tables/per_class_metrics.csv`
- `outputs/tables/worst_predictions.csv`
- `outputs/figures/test_metrics.png`
- `outputs/figures/confusion_matrix.png`
- `outputs/figures/roc_curve.png`
- `outputs/figures/pr_curve.png`
- `outputs/figures/threshold_analysis.png`
- `outputs/figures/calibration_plot.png`
- `outputs/figures/errors_by_probability.png`
- `outputs/figures/residual_plot.png` (regression)
- `outputs/figures/actual_vs_predicted.png` (regression)
- `outputs/figures/shap_importance.png`
- `outputs/figures/pdp_{feature}.png` (multiple)
- `outputs/figures/ml_vs_baseline.png`
- `reports/model-report.html`
- `checkpoints/08-evaluation.complete`

**Git Commit:**
```bash
git add scripts/08-evaluate.R outputs/ reports/
git commit -m "feat: complete model evaluation on test set

- Test {metric}: {value} ± {se}
- Generate comprehensive diagnostics
- Create evaluation report
- Exceeds baseline by +{improvement}%
- Model ready for deployment

Phase 8/10 complete

Co-Authored-By: Alan (Model Master) <noreply@bmad.com>"
```

---

## Troubleshooting

**Issue:** Test performance much worse than CV
- **Solution**: Check for data leakage in training, verify test set representativeness, review feature engineering

**Issue:** Poor calibration
- **Solution**: Apply Platt scaling or isotonic regression, adjust decision threshold

**Issue:** SHAP computation too slow
- **Solution**: Sample fewer observations, reduce nsim, use approximate methods

**Issue:** Can't interpret black-box model
- **Solution**: Use LIME for local explanations, create simpler surrogate model

---

## Next Phase

**Phase 9: Communication**

With evaluation complete, we'll hand off to Marie (Communicator):
1. Create stakeholder-friendly presentation
2. Build interactive Shiny dashboard
3. Write comprehensive model documentation
4. Prepare deployment plan

**Transition:** When ready, say "Continue to Phase 9" or "Create stakeholder materials"

**Handoff to Marie:**
- ✓ Model fully evaluated
- ✓ Test performance documented
- ✓ Evaluation report complete
- ✓ Model ready for communication and deployment

---

## Phase Completion

When this phase is complete:
1. Test set evaluation completed
2. Comprehensive diagnostics generated
3. Error analysis documented
4. Model interpretation performed
5. Evaluation report rendered
6. Checkpoint file created
7. Git commit made
8. **Ready to hand off to Marie for Phase 9**

**Expected Duration:** 2-3 hours

---

_Phase 8 of 10 | Owner: Alan | RDS Module Full-Lifecycle Workflow_
