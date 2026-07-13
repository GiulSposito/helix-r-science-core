# Step 4: Evaluation

**Workflow:** modeling-pipeline
**Owner:** Alan (ML Engineer)
**Duration:** 1-2 days

---

## Step Overview

**Goal:** Test set evaluation, diagnostics, and model interpretation

**Inputs:**
- Final model from Step 3 (`final_model.rds`)
- Test set (held out since beginning)
- Evaluation metrics
- Production requirements

**Outputs:**
- `evaluation_report.html` — Complete test set results
- `interpretation/` — VIP plots, SHAP values, PDPs
- `diagnostics/` — Residual plots, calibration curves
- `production_artifacts/` — Deployment-ready files
- `model_card.md` — Model documentation

---

## Activation

Olá! Este é o **Step 4: Evaluation**.

Este é o momento da verdade: vamos avaliar o modelo final no test set (tocado pela primeira vez).

**Avaliações incluídas:**
1. **Performance:** Métricas no test set
2. **Diagnostics:** Residuais, calibração, distribuições
3. **Interpretation:** Feature importance, SHAP, PDPs
4. **Production Readiness:** Artifacts e documentação

**Princípio fundamental:** Test set foi tocado apenas AGORA. Esta é a estimação honesta de performance em produção.

---

## Load Model and Data

```r
library(tidymodels)
library(vip)
library(DALEX)

# Load final model from Step 3
final_fit <- readRDS("{output_folder}/final_model.rds")

# Load test data (held out since beginning)
data_split <- readRDS("{output_folder}/data_split.rds")
test_data <- testing(data_split)

print(paste("Test set size:", nrow(test_data), "observations"))
```

**Critical:** Verify this is the first time test set is being used.

---

## Performance Evaluation

### Generate Predictions

```r
# Predict on test set
test_predictions <- final_fit %>%
  augment(new_data = test_data)

head(test_predictions)
```

---

### Calculate Metrics

#### Regression Metrics

```r
library(yardstick)

# Define comprehensive metrics
regression_metrics <- metric_set(
  rmse,           # Root Mean Squared Error
  mae,            # Mean Absolute Error
  rsq,            # R-squared
  mape,           # Mean Absolute Percentage Error
  huber_loss,     # Robust to outliers
  ccc             # Concordance correlation coefficient
)

# Calculate all metrics
test_performance <- test_predictions %>%
  regression_metrics(truth = {{ target }}, estimate = .pred)

print(test_performance)

# Compare to CV performance
cv_performance <- readRDS("{output_folder}/best_cv_metrics.rds")

comparison <- tibble(
  metric = test_performance$.metric,
  test_set = test_performance$.estimate,
  cv_mean = cv_performance$mean,
  difference = test_set - cv_mean,
  pct_difference = (difference / cv_mean) * 100
)

print(comparison)
```

**Decision Point:** Is test performance similar to CV?
- **Yes:** Model generalizes well
- **No (worse):** Possible overfitting to CV folds
- **No (better):** Lucky test set or data leakage (investigate!)

---

#### Classification Metrics

```r
# Define comprehensive metrics
classification_metrics <- metric_set(
  accuracy,       # Overall correctness
  roc_auc,        # Discrimination (ROC curve)
  pr_auc,         # Precision-Recall (for imbalanced)
  f_meas,         # F1 score
  sens,           # Sensitivity (recall)
  spec,           # Specificity
  ppv,            # Precision
  npv,            # Negative predictive value
  kap             # Kappa (agreement beyond chance)
)

# Calculate all metrics
test_performance <- test_predictions %>%
  classification_metrics(truth = {{ target }}, estimate = .pred_class, .pred_yes)

print(test_performance)

# Confusion matrix
conf_mat(test_predictions, truth = {{ target }}, estimate = .pred_class) %>%
  autoplot(type = "heatmap")
```

---

### Visualize Performance

#### Regression: Predicted vs Actual

```r
# Scatter plot
p1 <- test_predictions %>%
  ggplot(aes(x = .pred, y = {{ target }})) +
  geom_point(alpha = 0.5, size = 2) +
  geom_abline(color = "red", linetype = "dashed", size = 1) +
  geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(
    title = "Test Set: Predicted vs Actual",
    subtitle = paste("RMSE:", round(test_performance$.estimate[1], 3)),
    x = "Predicted",
    y = "Actual"
  ) +
  theme_minimal()

# Residual plot
p2 <- test_predictions %>%
  mutate(residual = {{ target }} - .pred) %>%
  ggplot(aes(x = .pred, y = residual)) +
  geom_point(alpha = 0.5) +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  geom_smooth(se = TRUE) +
  labs(
    title = "Residual Plot",
    x = "Predicted",
    y = "Residual"
  ) +
  theme_minimal()

library(patchwork)
p1 + p2
```

---

#### Classification: ROC and PR Curves

```r
# ROC curve
roc_curve(test_predictions, truth = {{ target }}, .pred_yes) %>%
  autoplot() +
  labs(title = paste("ROC Curve (AUC =", round(test_performance$.estimate[2], 3), ")"))

# Precision-Recall curve
pr_curve(test_predictions, truth = {{ target }}, .pred_yes) %>%
  autoplot() +
  labs(title = paste("PR Curve (AUC =", round(test_performance$.estimate[3], 3), ")"))

# Calibration plot
test_predictions %>%
  mutate(pred_bin = cut(.pred_yes, breaks = seq(0, 1, 0.1))) %>%
  group_by(pred_bin) %>%
  summarise(
    mean_pred = mean(.pred_yes),
    mean_actual = mean(as.numeric({{ target }}) - 1),
    n = n()
  ) %>%
  ggplot(aes(x = mean_pred, y = mean_actual)) +
  geom_point(aes(size = n)) +
  geom_abline(color = "red", linetype = "dashed") +
  labs(
    title = "Calibration Plot",
    subtitle = "Perfect calibration = points on diagonal",
    x = "Mean Predicted Probability",
    y = "Observed Frequency"
  ) +
  theme_minimal()
```

---

## Diagnostics

### Residual Analysis (Regression)

```r
# Calculate residuals
test_predictions <- test_predictions %>%
  mutate(
    residual = {{ target }} - .pred,
    std_residual = residual / sd(residual)
  )

# 1. Distribution of residuals
p1 <- test_predictions %>%
  ggplot(aes(x = residual)) +
  geom_histogram(bins = 50, fill = "steelblue", alpha = 0.7) +
  geom_vline(xintercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Residual Distribution", x = "Residual", y = "Count") +
  theme_minimal()

# 2. Q-Q plot (normality check)
p2 <- test_predictions %>%
  ggplot(aes(sample = std_residual)) +
  stat_qq() +
  stat_qq_line(color = "red") +
  labs(title = "Q-Q Plot", x = "Theoretical", y = "Sample") +
  theme_minimal()

# 3. Scale-location plot (homoscedasticity check)
p3 <- test_predictions %>%
  ggplot(aes(x = .pred, y = sqrt(abs(std_residual)))) +
  geom_point(alpha = 0.5) +
  geom_smooth(se = TRUE) +
  labs(title = "Scale-Location Plot", x = "Predicted", y = "√|Standardized Residual|") +
  theme_minimal()

# 4. Residuals vs leverage (influential points)
p4 <- test_predictions %>%
  mutate(row_num = row_number()) %>%
  ggplot(aes(x = row_num, y = std_residual)) +
  geom_point(alpha = 0.5) +
  geom_hline(yintercept = c(-3, 3), color = "red", linetype = "dashed") +
  labs(title = "Standardized Residuals", x = "Observation", y = "Standardized Residual") +
  theme_minimal()

(p1 + p2) / (p3 + p4)
```

**Interpretation:**
- **Distribution:** Should be roughly normal, centered at 0
- **Q-Q plot:** Points on line = normality
- **Scale-location:** Flat line = constant variance (homoscedasticity)
- **Residuals:** Most within ±3 std deviations

---

### Error Analysis

```r
# Identify worst predictions
worst_predictions <- test_predictions %>%
  mutate(
    abs_error = abs(residual),
    pct_error = abs_error / {{ target }} * 100
  ) %>%
  arrange(desc(abs_error)) %>%
  slice_head(n = 20)

# Analyze patterns in errors
error_summary <- worst_predictions %>%
  select(-starts_with(".")) %>%
  summary()

print("Worst 20 Predictions:")
print(worst_predictions)

# Check for systematic errors by segments
test_predictions %>%
  mutate(pred_quartile = ntile(.pred, 4)) %>%
  group_by(pred_quartile) %>%
  summarise(
    n = n(),
    mean_error = mean(residual),
    rmse = sqrt(mean(residual^2)),
    mae = mean(abs(residual))
  )
```

**Decision Point:** Are errors random or systematic?
- **Random:** Good, no pattern in residuals
- **Systematic:** Bad, model missing important patterns (consider returning to feature engineering)

---

### Classification Diagnostics

```r
# Threshold analysis
threshold_metrics <- test_predictions %>%
  threshold_perf(truth = {{ target }}, estimate = .pred_yes, thresholds = seq(0, 1, 0.01))

# Plot metrics vs threshold
threshold_metrics %>%
  pivot_longer(cols = c(sens, spec, ppv, npv), names_to = "metric", values_to = "value") %>%
  ggplot(aes(x = .threshold, y = value, color = metric)) +
  geom_line(size = 1) +
  labs(
    title = "Metrics vs Classification Threshold",
    x = "Threshold",
    y = "Metric Value"
  ) +
  theme_minimal()

# Find optimal threshold (maximize F1)
optimal_threshold <- threshold_metrics %>%
  mutate(f1 = 2 * (ppv * sens) / (ppv + sens)) %>%
  slice_max(f1, n = 1) %>%
  pull(.threshold)

print(paste("Optimal threshold:", optimal_threshold))
```

---

## Model Interpretation

### Feature Importance (VIP)

```r
library(vip)

# Extract fitted workflow
model_fit <- extract_fit_parsnip(final_fit)

# Generate VIP plot
vip_plot <- vip(model_fit, num_features = 20) +
  labs(title = "Feature Importance (Top 20)") +
  theme_minimal()

print(vip_plot)

# Save plot
ggsave("{output_folder}/interpretation/vip_plot.png", vip_plot, width = 10, height = 6)
```

**Interpretation:**
- **Top features:** Most important for predictions
- **Compare to domain knowledge:** Do important features make sense?

---

### SHAP Values

```r
library(fastshap)
library(shapviz)

# Prepare data for SHAP
X_test <- test_data %>%
  select(-{{ target }}) %>%
  bake(rec, new_data = .)

# Calculate SHAP values
shap_values <- explain(
  model_fit,
  X = X_test,
  nsim = 50,
  pred_wrapper = predict,
  newdata = X_test
)

# Summary plot
shap_summary <- shapviz(shap_values)
sv_importance(shap_summary, kind = "beeswarm") +
  labs(title = "SHAP Summary Plot")

# Save
ggsave("{output_folder}/interpretation/shap_summary.png", width = 10, height = 8)
```

**Interpretation:**
- **Color:** Feature value (red = high, blue = low)
- **Position:** SHAP value (right = increases prediction, left = decreases)
- **Spread:** Interaction effects and variability

---

### Partial Dependence Plots

```r
library(pdp)

# Select top 5 features from VIP
top_features <- vip_plot$data %>%
  slice_max(Importance, n = 5) %>%
  pull(Variable)

# Generate PDPs
pdp_plots <- map(
  .x = top_features,
  .f = ~ {
    partial(model_fit, pred.var = .x, train = X_test, plot = TRUE) +
      labs(title = paste("PDP:", .x)) +
      theme_minimal()
  }
)

# Combine plots
library(patchwork)
wrap_plots(pdp_plots, ncol = 2)
```

**Interpretation:**
- **Slope:** How prediction changes with feature value
- **Shape:** Linear, non-linear, threshold effects

---

### Individual Predictions (LIME)

```r
library(lime)

# Create explainer
explainer <- lime(
  x = X_test,
  model = model_fit,
  n_bins = 5
)

# Explain specific predictions
interesting_cases <- test_predictions %>%
  arrange(desc(abs(residual))) %>%
  slice_head(n = 4) %>%
  pull(.row)

explanations <- explain(
  x = X_test[interesting_cases, ],
  explainer = explainer,
  n_features = 10
)

# Plot explanations
plot_features(explanations) +
  labs(title = "LIME Explanations: Worst Predictions") +
  theme_minimal()
```

**Use Case:** Explain specific predictions to stakeholders.

---

## Production Artifacts

### Save Production-Ready Files

```r
dir.create("{output_folder}/production_artifacts", recursive = TRUE)

# 1. Final model object
saveRDS(final_fit, "{output_folder}/production_artifacts/final_model.rds")

# 2. Recipe (for preprocessing new data)
saveRDS(extract_recipe(final_fit), "{output_folder}/production_artifacts/recipe.rds")

# 3. Model specification
saveRDS(extract_spec_parsnip(final_fit), "{output_folder}/production_artifacts/model_spec.rds")

# 4. Test performance metrics
write_csv(test_performance, "{output_folder}/production_artifacts/test_performance.csv")

# 5. Feature names and types
feature_info <- tibble(
  feature = names(X_test),
  type = map_chr(X_test, class)
)
write_csv(feature_info, "{output_folder}/production_artifacts/feature_info.csv")
```

---

### Deployment Guide

```r
# Create deployment guide
deployment_guide <- glue::glue("
# Model Deployment Guide

## Model Information
- **Model Type:** {model_fit$spec$engine}
- **Problem Type:** {model_fit$spec$mode}
- **Training Date:** {Sys.Date()}
- **Test RMSE:** {round(test_performance$.estimate[1], 4)}
- **Test R²:** {round(test_performance$.estimate[3], 4)}

## Required Inputs
{paste(feature_info$feature, collapse = '\n- ')}

## Prediction Function

```r
# Load model and recipe
model <- readRDS('final_model.rds')

# Prepare new data
new_data <- tibble(
  feature1 = value1,
  feature2 = value2,
  ...
)

# Generate predictions
predictions <- predict(model, new_data)
```

## Performance Monitoring

Monitor these metrics in production:
- RMSE: {round(test_performance$.estimate[1], 4)} (±10% alert threshold)
- MAE: {round(test_performance$.estimate[2], 4)} (±10% alert threshold)

Check for prediction drift:
- Feature distributions
- Prediction distributions
- Error patterns

## Model Updates

Retrain when:
- Performance degrades >10%
- New data patterns emerge
- Business requirements change

## Contact
- Owner: Alan (ML Engineer)
- Created: {Sys.Date()}
")

writeLines(deployment_guide, "{output_folder}/production_artifacts/deployment_guide.md")
```

---

### Model Card

```r
model_card <- glue::glue("
# Model Card: {model_fit$spec$engine} {Sys.Date()}

## Model Details
- **Model Type:** {model_fit$spec$engine}
- **Problem Type:** {model_fit$spec$mode}
- **Framework:** tidymodels
- **Owner:** Alan (ML Engineer)
- **Created:** {Sys.Date()}

## Intended Use
**Primary Use:** [Describe intended use case]
**Limitations:** [Describe known limitations]
**Out of Scope:** [What this model should NOT be used for]

## Training Data
- **Size:** {nrow(train_data)} observations
- **Features:** {ncol(train_data) - 1} features
- **Target:** {target}
- **Date Range:** [Specify]

## Performance
### Cross-Validation (10-fold)
- RMSE: {round(cv_performance$mean[1], 4)}
- R²: {round(cv_performance$mean[3], 4)}

### Test Set
- RMSE: {round(test_performance$.estimate[1], 4)}
- MAE: {round(test_performance$.estimate[2], 4)}
- R²: {round(test_performance$.estimate[3], 4)}

## Ethical Considerations
[Discuss fairness, bias, privacy]

## Caveats and Recommendations
[Known issues, recommended monitoring, update frequency]
")

writeLines(model_card, "{output_folder}/production_artifacts/model_card.md")
```

---

## Evaluation Report

### Generate Comprehensive Report

```r
render("templates/evaluation_report.Rmd",
       params = list(
         final_fit = final_fit,
         test_predictions = test_predictions,
         test_performance = test_performance,
         comparison = comparison,
         vip_plot = vip_plot,
         pdp_plots = pdp_plots
       ),
       output_file = "{output_folder}/evaluation_report.html")
```

**Report Contents:**
1. Executive summary
2. Model information
3. Test set performance
4. CV vs test comparison
5. Diagnostic plots
6. Residual analysis
7. Feature importance
8. SHAP analysis
9. Partial dependence plots
10. Example predictions
11. Production recommendations

---

## Go/No-Go Decision

### Decision Criteria Checklist

```r
decision_criteria <- tibble(
  criterion = c(
    "Test RMSE within 10% of CV RMSE",
    "No systematic patterns in residuals",
    "Top features align with domain knowledge",
    "Model interpretable for stakeholders",
    "Computational cost acceptable for production",
    "No ethical/fairness concerns",
    "Performance meets business requirements"
  ),
  status = c("✅", "✅", "⚠️", "✅", "✅", "✅", "✅"),
  notes = c(
    "Test RMSE 3% worse than CV",
    "Residuals appear random",
    "Feature X seems less important than expected",
    "VIP and PDPs clear",
    "Prediction time <100ms",
    "No protected attributes used",
    "Exceeds minimum RMSE threshold"
  )
)

print(decision_criteria)
```

---

### Recommendation

```r
recommendation <- if_else(
  test_performance$.estimate[1] < target_rmse_threshold,
  "✅ DEPLOY - Model meets all criteria",
  "⚠️ REVISIT - Consider additional tuning or feature engineering"
)

print(recommendation)
```

---

## Best Practices

### 1. Test Set Discipline

**✅ Do:**
- Use test set ONCE at the end
- Compare to CV performance
- Document any discrepancies

**❌ Don't:**
- Tune based on test set
- Peek at test set during development
- Use test set for model selection

---

### 2. Interpretation

**✅ Do:**
- Use multiple interpretation methods (VIP, SHAP, PDP)
- Validate with domain experts
- Document unexpected patterns

**❌ Don't:**
- Rely on single interpretation method
- Ignore contradictions with domain knowledge
- Skip interpretation for "black box" models

---

### 3. Production Readiness

**✅ Do:**
- Save all artifacts (model, recipe, specs)
- Document input requirements
- Set up monitoring thresholds
- Create deployment guide

**❌ Don't:**
- Save model without preprocessing
- Skip documentation
- Deploy without monitoring plan

---

## Troubleshooting

### Issue: Test performance worse than CV

**Possible causes:**
1. Overfitting to CV folds
2. Distribution shift between train and test
3. Data leakage during CV

**Diagnosis:**
```r
# Check CV vs test distributions
train_summary <- train_data %>% summary()
test_summary <- test_data %>% summary()

# Check prediction distributions
cv_preds <- readRDS("{output_folder}/cv_predictions.rds")
ggplot() +
  geom_density(data = cv_preds, aes(x = .pred, color = "CV")) +
  geom_density(data = test_predictions, aes(x = .pred, color = "Test"))
```

**Solutions:**
- If overfitting: Reduce model complexity, increase regularization
- If distribution shift: Investigate data collection differences
- If leakage: Review recipe and CV strategy

---

### Issue: Poor calibration (classification)

**Symptom:** Predicted probabilities don't match observed frequencies

**Solutions:**
```r
# Calibration methods
library(probably)

# Isotonic regression calibration
calibrated_model <- cal_estimate_isotonic(test_predictions, truth = {{ target }}, estimate = .pred_yes)

# Apply calibration
calibrated_preds <- cal_apply(test_predictions, calibrated_model)

# Recheck calibration
cal_plot_breaks(calibrated_preds, truth = {{ target }}, estimate = .pred_yes)
```

---

### Issue: Unexplainable predictions

**Symptom:** SHAP/LIME explanations don't make sense

**Possible causes:**
- Model capturing spurious correlations
- Data quality issues
- Incorrect feature engineering

**Investigation:**
```r
# Examine specific cases
test_predictions %>%
  filter(abs(residual) > quantile(abs(residual), 0.95)) %>%
  select(-starts_with(".")) %>%
  View()

# Check feature distributions
X_test %>%
  pivot_longer(everything()) %>%
  ggplot(aes(x = value)) +
  geom_histogram() +
  facet_wrap(~ name, scales = "free")
```

---

## Final Deliverables Checklist

- [ ] `evaluation_report.html` — Complete evaluation report
- [ ] `test_performance.csv` — Test set metrics
- [ ] `interpretation/vip_plot.png` — Feature importance
- [ ] `interpretation/shap_summary.png` — SHAP values
- [ ] `interpretation/pdp_plots.png` — Partial dependence plots
- [ ] `diagnostics/residual_plots.png` — Diagnostic plots
- [ ] `production_artifacts/final_model.rds` — Trained model
- [ ] `production_artifacts/recipe.rds` — Preprocessing pipeline
- [ ] `production_artifacts/deployment_guide.md` — Deployment instructions
- [ ] `production_artifacts/model_card.md` — Model documentation
- [ ] `production_artifacts/feature_info.csv` — Feature metadata

---

## Workflow Complete

**Congratulations!** 🎉

You have completed the **Modeling Pipeline Workflow**:

1. ✅ **Step 1:** Feature engineering with recipes
2. ✅ **Step 2:** Baseline model comparison
3. ✅ **Step 3:** Hyperparameter tuning
4. ✅ **Step 4:** Test set evaluation and interpretation

**Next Steps:**
- Deploy model to production
- Set up monitoring and alerting
- Schedule regular retraining
- Gather feedback from stakeholders

**Model is ready for production! 🚀**

---

**Step 4 complete. Modeling Pipeline Workflow finished.**
