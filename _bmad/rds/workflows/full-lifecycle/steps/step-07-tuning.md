# Phase 7: Hyperparameter Tuning

**Owner:** Alan (Model Master)
**Duration:** 2-4 hours
**Status:** Active

---

## Phase Goal

Perform intensive hyperparameter optimization to maximize model performance and prepare final production-ready model.

---

## Prerequisites

- Phase 6 complete (best model architecture selected)
- Best model saved in `outputs/models/best_model_fit.rds`
- Initial hyperparameters in `outputs/models/best_model_params.rds`
- Computational resources available for intensive search

---

## Continuation from Phase 6

**Alan continues:**
We've identified {best_model_name} as the best architecture. Now I'll perform comprehensive hyperparameter tuning to squeeze out maximum performance.

---

## Step-by-Step Instructions

### 1. Review Initial Tuning Results

```r
library(tidyverse)
library(tidymodels)
library(here)

# Load previous results
best_model_fit <- read_rds(here("outputs", "models", "best_model_fit.rds"))
best_params <- read_rds(here("outputs", "models", "best_model_params.rds"))

# Load data
train_data <- read_rds(here("data", "processed", "train_processed.rds"))
test_data <- read_rds(here("data", "processed", "test_processed.rds"))

# Target variable
target_var <- "{your_target}"

# Create CV folds
set.seed(123)
cv_folds <- vfold_cv(train_data, v = 10, strata = target_var)

cat("=== CURRENT BEST PARAMETERS ===\n")
print(best_params)
cat("\nPhase 7: Will refine these parameters\n")
```

### 2. Define Comprehensive Tuning Strategy

**Based on model type, create focused parameter grid:**

**For Random Forest:**
```r
# Refined parameter ranges based on Phase 6 results
rf_params <- parameters(
  mtry = mtry(range = c({min}, {max})),  # From Phase 6 ± 20%
  min_n = min_n(range = c({min}, {max})),
  # Could also tune:
  # sample_prop = sample_prop(range = c(0.5, 1.0))
)

# Create regular grid for thorough search
rf_grid <- grid_regular(
  rf_params,
  levels = 5  # 5×5 = 25 combinations
)

# Or use space-filling design
rf_grid_lhs <- grid_latin_hypercube(
  rf_params,
  size = 50  # 50 combinations
)
```

**For XGBoost:**
```r
# XGBoost has many parameters - focus on most important
xgb_params <- parameters(
  tree_depth = tree_depth(range = c({min}, {max})),
  learn_rate = learn_rate(range = c({min}, {max})),
  mtry = mtry(range = c({min}, {max})),
  min_n = min_n(range = c({min}, {max})),
  loss_reduction = loss_reduction(range = c({min}, {max})),
  sample_size = sample_prop(range = c(0.5, 1.0))
)

# Large grid for thorough search
xgb_grid <- grid_latin_hypercube(
  xgb_params,
  size = 100  # 100 combinations
)
```

**For Elastic Net (glmnet):**
```r
glmnet_params <- parameters(
  penalty = penalty(range = c({min}, {max})),
  mixture = mixture(range = c({min}, {max}))  # 0=ridge, 1=lasso
)

# Regular grid works well for glmnet
glmnet_grid <- grid_regular(
  glmnet_params,
  levels = c(penalty = 20, mixture = 10)  # 200 combinations
)
```

### 3. Setup Parallel Processing

```r
# Use all available cores
library(doParallel)
all_cores <- parallel::detectCores(logical = FALSE)
cl <- makeCluster(all_cores - 1)  # Leave one core free
registerDoParallel(cl)

cat("Using", all_cores - 1, "cores for tuning\n")
```

### 4. Intensive Grid Search

**Method 1: Exhaustive Grid Search**

```r
# Define metrics
metrics <- metric_set(
  # Classification:
  accuracy, roc_auc, precision, recall, f_meas
  # Regression:
  # rmse, mae, rsq
)

# Get model specification
model_spec <- {model_specification_from_phase6}

# Create workflow
tune_workflow <- workflow() |>
  add_recipe(read_rds(here("outputs", "models", "feature_recipe.rds"))) |>
  add_model(model_spec)

# Exhaustive grid search
cat("\nStarting exhaustive grid search...\n")
cat("Grid size:", nrow({grid_name}), "combinations\n")
cat("Estimated time:", round(nrow({grid_name}) * 10 * 2 / 60, 1), "minutes\n\n")

grid_results <- tune_workflow |>
  tune_grid(
    resamples = cv_folds,
    grid = {grid_name},
    metrics = metrics,
    control = control_grid(
      save_pred = TRUE,
      verbose = TRUE,
      allow_par = TRUE
    )
  )

# Show top results
grid_results |>
  show_best(metric = "{primary_metric}", n = 10)

# Visualize tuning results
autoplot(grid_results, metric = "{primary_metric}") +
  labs(title = "Hyperparameter Tuning Results") +
  theme_minimal()

ggsave(here("outputs", "figures", "tuning_grid_results.png"),
       width = 12, height = 8)
```

**Method 2: Bayesian Optimization (Adaptive)**

```r
# Start with best parameters from Phase 6 as initial point
cat("\nStarting Bayesian optimization...\n")

bayes_results <- tune_workflow |>
  tune_bayes(
    resamples = cv_folds,
    initial = grid_results,  # Start from grid search results
    iter = 50,               # Additional iterations
    param_info = {params},
    metrics = metrics,
    control = control_bayes(
      no_improve = 15,       # Stop if no improvement for 15 iterations
      verbose = TRUE,
      uncertain = 5,         # Exploitation vs exploration
      save_pred = TRUE
    )
  )

# Show improvement over iterations
bayes_results |>
  autoplot(type = "performance") +
  labs(title = "Bayesian Optimization Progress") +
  theme_minimal()

ggsave(here("outputs", "figures", "tuning_bayes_progress.png"),
       width = 10, height = 6)
```

### 5. Analyze Tuning Results

**Parameter importance and interactions:**

```r
# Extract all results
all_results <- bind_rows(
  grid_results |> collect_metrics() |> mutate(method = "grid"),
  bayes_results |> collect_metrics() |> mutate(method = "bayes")
)

# Find best overall
best_overall <- all_results |>
  filter(.metric == "{primary_metric}") |>
  arrange(desc(mean)) |>
  slice(1)

cat("\n=== BEST PARAMETERS FOUND ===\n")
print(best_overall)

# Parameter importance (for visualization)
# Which parameters have biggest impact on performance?
all_results |>
  filter(.metric == "{primary_metric}") |>
  select(mean, matches("^(mtry|min_n|tree_depth|learn_rate)")) |>
  pivot_longer(-mean, names_to = "parameter", values_to = "value") |>
  ggplot(aes(x = value, y = mean)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "loess", color = "red") +
  facet_wrap(~parameter, scales = "free_x") +
  labs(
    title = "Parameter Impact on Performance",
    y = "{Primary Metric}"
  ) +
  theme_minimal()

ggsave(here("outputs", "figures", "parameter_importance.png"),
       width = 12, height = 8)

# Parameter interactions (for 2D grid search)
if ("mtry" %in% names(best_overall) && "min_n" %in% names(best_overall)) {
  all_results |>
    filter(.metric == "{primary_metric}") |>
    ggplot(aes(x = mtry, y = min_n, fill = mean)) +
    geom_tile() +
    scale_fill_viridis_c() +
    labs(
      title = "Parameter Interaction: mtry vs min_n",
      fill = "{Primary Metric}"
    ) +
    theme_minimal()

  ggsave(here("outputs", "figures", "parameter_interactions.png"),
         width = 10, height = 8)
}
```

### 6. Finalize Best Model

**Select and fit final model:**

```r
# Extract best parameters
final_params <- select_best(bayes_results, metric = "{primary_metric}")

# Finalize workflow
final_workflow <- tune_workflow |>
  finalize_workflow(final_params)

# Fit on full training data
cat("\nFitting final model on full training data...\n")
final_fit <- final_workflow |>
  fit(data = train_data)

# Save final model
write_rds(final_fit, here("outputs", "models", "final_model.rds"))
write_rds(final_params, here("outputs", "models", "final_model_params.rds"))

cat("\nFinal model saved!\n")
```

### 7. Compare to Phase 6 Model

```r
# Get Phase 6 performance
phase6_params <- read_rds(here("outputs", "models", "best_model_params.rds"))

# Refit Phase 6 model for fair comparison
phase6_workflow <- tune_workflow |>
  finalize_workflow(phase6_params)

phase6_cv <- phase6_workflow |>
  fit_resamples(
    resamples = cv_folds,
    metrics = metrics
  )

# Compare performance
comparison <- bind_rows(
  phase6_cv |> collect_metrics() |> mutate(version = "Phase 6"),
  bayes_results |>
    select_best(metric = "{primary_metric}") |>
    inner_join(
      bayes_results |> collect_metrics(),
      by = names(final_params)
    ) |>
    mutate(version = "Phase 7 (Final)")
)

comparison |>
  filter(.metric == "{primary_metric}") |>
  ggplot(aes(x = version, y = mean, fill = version)) +
  geom_col() +
  geom_errorbar(aes(ymin = mean - std_err, ymax = mean + std_err),
                width = 0.2) +
  geom_text(aes(label = round(mean, 4)), vjust = -1) +
  labs(
    title = "Model Performance: Phase 6 vs Phase 7",
    subtitle = "After intensive hyperparameter tuning",
    y = "{Primary Metric}",
    x = NULL
  ) +
  theme_minimal() +
  theme(legend.position = "none")

ggsave(here("outputs", "figures", "phase6_vs_phase7.png"),
       width = 10, height = 6)

# Calculate improvement
improvement <- ((comparison |>
  filter(.metric == "{primary_metric}", version == "Phase 7 (Final)") |>
  pull(mean)) -
  (comparison |>
  filter(.metric == "{primary_metric}", version == "Phase 6") |>
  pull(mean))) /
  (comparison |>
  filter(.metric == "{primary_metric}", version == "Phase 6") |>
  pull(mean)) * 100

cat("\nPerformance improvement:", round(improvement, 2), "%\n")
```

### 8. Model Diagnostics

**Check for overfitting and model quality:**

```r
# Learning curves (more data points)
sample_sizes <- seq(0.1, 1.0, by = 0.1)

learning_curve <- map_df(sample_sizes, function(prop) {
  set.seed(123)
  sample_data <- train_data |> slice_sample(prop = prop)

  # Fit final model on subset
  fit_result <- final_workflow |>
    fit_resamples(
      resamples = vfold_cv(sample_data, v = 5, strata = target_var),
      metrics = metrics
    )

  fit_result |>
    collect_metrics() |>
    filter(.metric == "{primary_metric}") |>
    mutate(n_obs = nrow(sample_data), prop = prop)
})

learning_curve |>
  ggplot(aes(x = n_obs, y = mean)) +
  geom_line(size = 1.5, color = "steelblue") +
  geom_point(size = 3) +
  geom_ribbon(aes(ymin = mean - std_err, ymax = mean + std_err),
              alpha = 0.2, fill = "steelblue") +
  labs(
    title = "Final Model: Learning Curve",
    subtitle = "Performance stabilizes, suggesting good model capacity",
    x = "Training Set Size",
    y = "{Primary Metric}"
  ) +
  theme_minimal()

ggsave(here("outputs", "figures", "final_learning_curve.png"),
       width = 10, height = 6)

# CV fold variability (check consistency)
bayes_results |>
  select_best(metric = "{primary_metric}") |>
  inner_join(
    bayes_results |> collect_metrics(summarize = FALSE),
    by = names(final_params)
  ) |>
  filter(.metric == "{primary_metric}") |>
  ggplot(aes(x = factor(id), y = .estimate)) +
  geom_boxplot() +
  geom_point(alpha = 0.5) +
  labs(
    title = "Cross-Validation Fold Performance",
    subtitle = "Check for consistency across folds",
    x = "CV Fold",
    y = "{Primary Metric}"
  ) +
  theme_minimal()

ggsave(here("outputs", "figures", "cv_fold_variability.png"),
       width = 10, height = 6)
```

### 9. Variable Importance (Final Model)

```r
# Extract final variable importance
if ({model_type} %in% c("rf", "xgb", "tree")) {
  final_importance <- final_fit |>
    extract_fit_parsnip() |>
    vip::vi()

  # Compare to Phase 6 importance
  phase6_fit <- read_rds(here("outputs", "models", "best_model_fit.rds"))
  phase6_importance <- phase6_fit |>
    extract_fit_parsnip() |>
    vip::vi()

  # Visualize top 20
  bind_rows(
    final_importance |> mutate(version = "Phase 7"),
    phase6_importance |> mutate(version = "Phase 6")
  ) |>
    filter(Variable %in% head(final_importance$Variable, 20)) |>
    ggplot(aes(x = reorder(Variable, Importance), y = Importance, fill = version)) +
    geom_col(position = "dodge") +
    coord_flip() +
    labs(
      title = "Variable Importance: Phase 6 vs Phase 7",
      subtitle = "Top 20 features",
      x = NULL,
      fill = "Model Version"
    ) +
    theme_minimal()

  ggsave(here("outputs", "figures", "final_variable_importance.png"),
         width = 12, height = 10)

  write_csv(final_importance, here("outputs", "tables", "final_variable_importance.csv"))
}
```

### 10. Document Tuning Process

Create `outputs/tables/phase07-tuning-summary.md`:

```markdown
# Phase 7: Hyperparameter Tuning Summary

**Model Master:** Alan
**Date:** {date}
**Model Type:** {model_name}
**Tuning Method:** Grid Search + Bayesian Optimization

## Tuning Strategy

### Search Space
- **Total combinations evaluated**: {n_grid + n_bayes}
- **Grid search**: {n_grid} combinations
- **Bayesian optimization**: {n_bayes} iterations
- **Computational time**: {duration} minutes

### Parameters Tuned
| Parameter | Range | Best Value |
|-----------|-------|------------|
| {param1} | [{min}, {max}] | {best_value} |
| {param2} | [{min}, {max}] | {best_value} |
| {param3} | [{min}, {max}] | {best_value} |

## Performance Improvement

### Phase 6 vs Phase 7
| Metric | Phase 6 | Phase 7 | Improvement |
|--------|---------|---------|-------------|
| {metric} | {value} ± {se} | {value} ± {se} | +{pct}% |

**Absolute improvement**: +{abs_value}
**Statistical significance**: {p_value or assessment}

## Best Configuration

```r
# Final hyperparameters
{param1} = {value}
{param2} = {value}
{param3} = {value}
```

**Why these parameters:**
- {param1}: {explanation of why this value makes sense}
- {param2}: {explanation}
- {param3}: {explanation}

## Tuning Insights

### Parameter Sensitivity
- **Most sensitive**: {param} (large impact on performance)
- **Least sensitive**: {param} (minimal impact)
- **Interaction detected**: {param1} × {param2}

### Convergence
- Bayesian optimization converged after {n} iterations
- No improvement after iteration {n}
- Optimal region well-explored

### Model Diagnostics
- **Overfitting**: {low/moderate/high} - {assessment}
- **CV stability**: {stable/variable} - {assessment}
- **Learning curve**: {converged/needs more data}

## Computational Resources

- **CPU cores used**: {n}
- **Training time per model**: {seconds}
- **Total tuning time**: {duration}
- **Memory usage**: {peak_memory}

## Next Steps (Phase 8: Evaluation)

**Model ready for evaluation:**
- ✓ Optimal hyperparameters found
- ✓ Final model trained on full training data
- ✓ Model diagnostics completed
- ✓ Variable importance updated
- ✓ Ready for test set evaluation

**Phase 8 priorities:**
1. Evaluate on held-out test set
2. Generate comprehensive diagnostics
3. Check calibration (for classification)
4. Interpret predictions
5. Create model evaluation report

**Expected Phase 8 duration:** 2-3 hours
```

### 11. Validation Checklist

Before proceeding to Phase 8:

- [ ] Comprehensive parameter grid defined
- [ ] Grid search completed
- [ ] Bayesian optimization completed
- [ ] Best parameters identified and validated
- [ ] Final model fitted on full training data
- [ ] Performance compared to Phase 6
- [ ] Learning curves analyzed
- [ ] CV fold consistency checked
- [ ] Variable importance updated
- [ ] Tuning summary documented
- [ ] Final model saved
- [ ] Ready for test set evaluation

---

## Outputs

**Created Files:**
- `scripts/07-tune.R`
- `outputs/models/final_model.rds`
- `outputs/models/final_model_params.rds`
- `outputs/figures/tuning_grid_results.png`
- `outputs/figures/tuning_bayes_progress.png`
- `outputs/figures/parameter_importance.png`
- `outputs/figures/parameter_interactions.png`
- `outputs/figures/phase6_vs_phase7.png`
- `outputs/figures/final_learning_curve.png`
- `outputs/figures/cv_fold_variability.png`
- `outputs/figures/final_variable_importance.png`
- `outputs/tables/final_variable_importance.csv`
- `outputs/tables/phase07-tuning-summary.md`
- `checkpoints/07-tuning.complete`

**Git Commit:**
```bash
git add scripts/07-tune.R outputs/
git commit -m "feat: complete intensive hyperparameter tuning

- Evaluate {n_total} parameter combinations
- Improve {metric} by +{pct}%
- Finalize model with optimal parameters
- Model: {model_name}
- CV {metric}: {value} ± {se}

Phase 7/10 complete

Co-Authored-By: Alan (Model Master) <noreply@bmad.com>"
```

---

## Troubleshooting

**Issue:** Tuning takes too long
- **Solution**: Reduce grid size, use fewer CV folds (5 instead of 10), enable parallelization

**Issue:** Bayesian optimization not converging
- **Solution**: Increase `no_improve` parameter, expand parameter ranges, try different acquisition function

**Issue:** Performance not improving from Phase 6
- **Solution**: Check if already at optimum, try different parameter ranges, consider ensemble methods

**Issue:** High variance across CV folds
- **Solution**: More data needed, or problem is inherently noisy - document uncertainty

---

## Next Phase

**Phase 8: Evaluation**

With final model tuned, Alan continues to:
1. Evaluate on test set (never seen before)
2. Generate comprehensive diagnostics
3. Analyze errors and misclassifications
4. Check calibration and reliability
5. Interpret model predictions
6. Create evaluation report

**Transition:** When ready, say "Continue to Phase 8" or "Evaluate on test set"

---

## Phase Completion

When this phase is complete:
1. Intensive hyperparameter search completed
2. Optimal parameters identified
3. Final model trained and saved
4. Performance improvement documented
5. Model diagnostics completed
6. Tuning summary documented
7. Checkpoint file created
8. Git commit made
9. **Alan continues to Phase 8**

**Expected Duration:** 2-4 hours

---

_Phase 7 of 10 | Owner: Alan | RDS Module Full-Lifecycle Workflow_
