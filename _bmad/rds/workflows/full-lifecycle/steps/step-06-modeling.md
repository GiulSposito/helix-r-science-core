# Phase 6: Modeling

**Owner:** Alan (Model Master)
**Duration:** 3-5 hours
**Status:** Active

---

## Phase Goal

Build and compare multiple candidate models, establish baseline performance, and select best model architecture for tuning.

---

## Prerequisites

- Phase 5 complete (features engineered, train/test split ready)
- Processed data in `data/processed/train_processed.rds`
- `tidymodels` ecosystem installed
- Modeling goal clear (classification/regression, metric priority)

---

## Handoff from Grace

**Context from Grace:**
- {n_features} engineered features ready
- Train set: {n_train} observations
- Test set: {n_test} observations
- Feature importance baseline established
- Recipe object saved for deployment

**Alan's role:**
As the Model Master, I'll systematically build and evaluate multiple model types to find the best architecture for this problem.

---

## Step-by-Step Instructions

### 1. Define Modeling Strategy

**What I need from you:**

1. **Problem Type**:
   - Classification (binary/multiclass)?
   - Regression (continuous target)?

2. **Primary Metric**:
   - Classification: accuracy, ROC AUC, precision, recall, F1?
   - Regression: RMSE, MAE, R²?

3. **Model Priorities**:
   - Interpretability (linear models, decision trees)?
   - Performance (ensemble methods, boosting)?
   - Speed (simple models, deployment constraints)?

4. **Computational Budget**:
   - Time available for training?
   - Resource constraints?

### 2. Setup Modeling Environment

```r
library(tidyverse)
library(tidymodels)
library(here)

# Load processed data
train_data <- read_rds(here("data", "processed", "train_processed.rds"))
test_data <- read_rds(here("data", "processed", "test_processed.rds"))

# Set target variable
target_var <- "{your_target}"

# Create resampling folds for cross-validation
set.seed(123)
cv_folds <- vfold_cv(train_data, v = 10, strata = target_var)

cat("Cross-validation: 10-fold CV\n")
cat("Training data:", nrow(train_data), "observations\n")
```

### 3. Define Model Specifications

**Build multiple model types for comparison:**

```r
# 1. Baseline Model: Null model (for comparison)
null_spec <- null_model() |>
  set_engine("parsnip") |>
  set_mode("{classification/regression}")

# 2. Logistic/Linear Regression (interpretable baseline)
glm_spec <- logistic_reg() |>  # or linear_reg() for regression
  set_engine("glm") |>
  set_mode("{classification/regression}")

# 3. Penalized Regression (Elastic Net)
glmnet_spec <- logistic_reg(penalty = tune(), mixture = tune()) |>
  set_engine("glmnet") |>
  set_mode("{classification/regression}")

# 4. Decision Tree (interpretable)
tree_spec <- decision_tree(
  cost_complexity = tune(),
  tree_depth = tune(),
  min_n = tune()
) |>
  set_engine("rpart") |>
  set_mode("{classification/regression}")

# 5. Random Forest (strong baseline)
rf_spec <- rand_forest(
  mtry = tune(),
  trees = 1000,
  min_n = tune()
) |>
  set_engine("ranger", importance = "impurity") |>
  set_mode("{classification/regression}")

# 6. XGBoost (often best performance)
xgb_spec <- boost_tree(
  trees = 1000,
  tree_depth = tune(),
  min_n = tune(),
  loss_reduction = tune(),
  sample_size = tune(),
  mtry = tune(),
  learn_rate = tune()
) |>
  set_engine("xgboost") |>
  set_mode("{classification/regression}")

# 7. K-Nearest Neighbors (non-parametric)
knn_spec <- nearest_neighbor(
  neighbors = tune(),
  weight_func = tune()
) |>
  set_engine("kknn") |>
  set_mode("{classification/regression}")

# 8. Support Vector Machine
svm_spec <- svm_rbf(
  cost = tune(),
  rbf_sigma = tune()
) |>
  set_engine("kernlab") |>
  set_mode("{classification/regression}")
```

### 4. Create Workflows

**Combine models with preprocessing:**

```r
# Load feature recipe
feature_recipe <- read_rds(here("outputs", "models", "feature_recipe.rds"))

# Create workflows for each model
workflows <- list(
  null = workflow() |>
    add_recipe(feature_recipe) |>
    add_model(null_spec),

  glm = workflow() |>
    add_recipe(feature_recipe) |>
    add_model(glm_spec),

  glmnet = workflow() |>
    add_recipe(feature_recipe) |>
    add_model(glmnet_spec),

  tree = workflow() |>
    add_recipe(feature_recipe) |>
    add_model(tree_spec),

  rf = workflow() |>
    add_recipe(feature_recipe) |>
    add_model(rf_spec),

  xgb = workflow() |>
    add_recipe(feature_recipe) |>
    add_model(xgb_spec),

  knn = workflow() |>
    add_recipe(feature_recipe) |>
    add_model(knn_spec),

  svm = workflow() |>
    add_recipe(feature_recipe) |>
    add_model(svm_spec)
)
```

### 5. Train Baseline Models (No Tuning)

**First, train simple models without hyperparameter tuning:**

```r
# Define metrics
metrics <- metric_set(
  # For classification:
  accuracy, roc_auc, precision, recall, f_meas
  # For regression:
  # rmse, mae, rsq
)

# Train baseline models (no tuning needed)
baseline_results <- list()

# GLM (no tuning)
cat("Training GLM...\n")
baseline_results$glm <- workflows$glm |>
  fit_resamples(
    resamples = cv_folds,
    metrics = metrics,
    control = control_resamples(save_pred = TRUE)
  )

# Random Forest (default params)
cat("Training Random Forest...\n")
rf_default <- rand_forest(trees = 1000) |>
  set_engine("ranger") |>
  set_mode("{classification/regression}")

baseline_results$rf_default <- workflow() |>
  add_recipe(feature_recipe) |>
  add_model(rf_default) |>
  fit_resamples(
    resamples = cv_folds,
    metrics = metrics,
    control = control_resamples(save_pred = TRUE)
  )

# XGBoost (default params)
cat("Training XGBoost...\n")
xgb_default <- boost_tree(trees = 500) |>
  set_engine("xgboost") |>
  set_mode("{classification/regression}")

baseline_results$xgb_default <- workflow() |>
  add_recipe(feature_recipe) |>
  add_model(xgb_default) |>
  fit_resamples(
    resamples = cv_folds,
    metrics = metrics,
    control = control_resamples(save_pred = TRUE)
  )

# Collect baseline metrics
baseline_metrics <- map_df(
  names(baseline_results),
  ~ baseline_results[[.x]] |>
    collect_metrics() |>
    mutate(model = .x),
  .id = "model_id"
)

# Visualize baseline performance
baseline_metrics |>
  filter(.metric == "{primary_metric}") |>
  ggplot(aes(x = reorder(model, mean), y = mean)) +
  geom_col(fill = "steelblue") +
  geom_errorbar(aes(ymin = mean - std_err, ymax = mean + std_err),
                width = 0.2) +
  coord_flip() +
  labs(
    title = "Baseline Model Comparison",
    subtitle = paste("{Primary Metric}:", "10-fold CV"),
    x = "Model",
    y = "{Primary Metric}"
  ) +
  theme_minimal()

ggsave(here("outputs", "figures", "baseline_model_comparison.png"),
       width = 10, height = 6)
```

### 6. Hyperparameter Tuning (Top Models)

**Tune the 2-3 best performing baseline models:**

```r
# Select top models for tuning
top_models <- baseline_metrics |>
  filter(.metric == "{primary_metric}") |>
  arrange(desc(mean)) |>
  head(3) |>
  pull(model)

cat("Top models for tuning:", paste(top_models, collapse = ", "), "\n")

# Setup parallel processing
library(doParallel)
cl <- makeCluster(parallel::detectCores() - 1)
registerDoParallel(cl)

# Tune each top model
tuned_results <- list()

for (model_name in top_models) {
  cat("\nTuning", model_name, "...\n")

  # Get appropriate workflow
  wf <- workflows[[model_name]]

  # Define tuning grid (adaptive for speed)
  tune_results <- wf |>
    tune_bayes(
      resamples = cv_folds,
      initial = 5,      # Initial random grid
      iter = 25,        # Bayesian optimization iterations
      metrics = metrics,
      control = control_bayes(
        no_improve = 10,
        verbose = TRUE,
        save_pred = TRUE
      )
    )

  tuned_results[[model_name]] <- tune_results

  # Show best parameters
  best_params <- select_best(tune_results, metric = "{primary_metric}")
  cat("\nBest parameters for", model_name, ":\n")
  print(best_params)
}

# Stop parallel processing
stopCluster(cl)

# Collect tuned metrics
tuned_metrics <- map_df(
  names(tuned_results),
  ~ tuned_results[[.x]] |>
    show_best(metric = "{primary_metric}", n = 1) |>
    mutate(model = .x)
)

# Compare baseline vs tuned
comparison <- bind_rows(
  baseline_metrics |>
    filter(.metric == "{primary_metric}", model %in% top_models) |>
    mutate(version = "baseline"),
  tuned_metrics |>
    filter(.metric == "{primary_metric}") |>
    mutate(version = "tuned")
)

comparison |>
  ggplot(aes(x = model, y = mean, fill = version)) +
  geom_col(position = "dodge") +
  geom_errorbar(
    aes(ymin = mean - std_err, ymax = mean + std_err),
    position = position_dodge(width = 0.9),
    width = 0.2
  ) +
  labs(
    title = "Baseline vs Tuned Model Performance",
    x = "Model",
    y = "{Primary Metric}",
    fill = "Version"
  ) +
  theme_minimal()

ggsave(here("outputs", "figures", "baseline_vs_tuned.png"),
       width = 10, height = 6)
```

### 7. Select Best Model

**Choose final model for Phase 7 (further tuning) and Phase 8 (evaluation):**

```r
# Identify best overall model
best_model_name <- tuned_metrics |>
  arrange(desc(mean)) |>
  slice(1) |>
  pull(model)

best_model_results <- tuned_results[[best_model_name]]
best_params <- select_best(best_model_results, metric = "{primary_metric}")

cat("\n=== BEST MODEL SELECTED ===\n")
cat("Model:", best_model_name, "\n")
cat("CV Performance:", best_model_results |>
    show_best(metric = "{primary_metric}", n = 1) |>
    pull(mean) |> round(4), "\n")

# Finalize workflow with best parameters
final_workflow <- workflows[[best_model_name]] |>
  finalize_workflow(best_params)

# Fit on full training data
final_fit <- final_workflow |>
  fit(data = train_data)

# Save model
write_rds(final_fit, here("outputs", "models", "best_model_fit.rds"))
write_rds(best_params, here("outputs", "models", "best_model_params.rds"))

cat("\nBest model saved to outputs/models/best_model_fit.rds\n")
```

### 8. Analyze Model Results

**Extract insights from best model:**

```r
# Variable importance (if available)
if (best_model_name %in% c("rf", "xgb", "tree")) {
  importance <- final_fit |>
    extract_fit_parsnip() |>
    vip::vi()

  importance |>
    head(20) |>
    ggplot(aes(x = reorder(Variable, Importance), y = Importance)) +
    geom_col(fill = "steelblue") +
    coord_flip() +
    labs(
      title = paste(best_model_name, "- Variable Importance"),
      x = NULL
    ) +
    theme_minimal()

  ggsave(here("outputs", "figures", "model_variable_importance.png"),
         width = 10, height = 8)

  write_csv(importance, here("outputs", "tables", "model_variable_importance.csv"))
}

# Learning curves (for ensemble methods)
if (best_model_name %in% c("rf", "xgb")) {
  # Train models with increasing data sizes
  sample_sizes <- c(0.1, 0.25, 0.5, 0.75, 1.0)

  learning_curve <- map_df(sample_sizes, function(prop) {
    set.seed(123)
    sample_data <- train_data |> slice_sample(prop = prop)

    fit_result <- final_workflow |>
      fit_resamples(
        resamples = vfold_cv(sample_data, v = 5),
        metrics = metrics
      )

    fit_result |>
      collect_metrics() |>
      filter(.metric == "{primary_metric}") |>
      mutate(
        n_obs = nrow(sample_data),
        prop = prop
      )
  })

  learning_curve |>
    ggplot(aes(x = n_obs, y = mean)) +
    geom_line(size = 1, color = "steelblue") +
    geom_point(size = 3) +
    geom_ribbon(aes(ymin = mean - std_err, ymax = mean + std_err),
                alpha = 0.2, fill = "steelblue") +
    labs(
      title = "Learning Curve",
      subtitle = "Model performance vs training set size",
      x = "Training Set Size",
      y = "{Primary Metric}"
    ) +
    theme_minimal()

  ggsave(here("outputs", "figures", "learning_curve.png"),
         width = 10, height = 6)
}

# CV predictions (for error analysis)
cv_predictions <- best_model_results |>
  collect_predictions()

write_csv(cv_predictions, here("outputs", "tables", "cv_predictions.csv"))
```

### 9. Create Model Comparison Report

**Document all model results:**

```markdown
# Phase 6: Modeling Summary

**Model Master:** Alan
**Date:** {date}
**Problem Type:** {classification/regression}
**Primary Metric:** {metric}

## Models Evaluated

| Model | Type | CV {Metric} | Std Error | Rank |
|-------|------|-------------|-----------|------|
| {name} | {type} | {value} | {se} | 1 |
| {name} | {type} | {value} | {se} | 2 |
| {name} | {type} | {value} | {se} | 3 |

## Best Model Selected

**Model Type:** {best_model_name}
**CV Performance:** {metric} = {value} ± {se}

**Hyperparameters:**
- {param1}: {value}
- {param2}: {value}
- {param3}: {value}

**Why this model:**
- {reason 1: performance}
- {reason 2: interpretability/complexity trade-off}
- {reason 3: training time considerations}

## Model Insights

### Variable Importance
Top 10 most important features:
1. {feature}: importance = {value}
2. {feature}: importance = {value}
...

### Learning Characteristics
- Converged: {yes/no}
- Training time: {duration}
- Model complexity: {high/medium/low}
- Overfitting risk: {assessment}

## Comparison to Baseline

| Metric | Null Model | GLM | Best Model | Improvement |
|--------|-----------|-----|------------|-------------|
| {metric} | {value} | {value} | {value} | +{pct}% |

## Next Steps (Phase 7: Tuning)

**Further optimization needed:**
- Fine-tune hyperparameters with larger grid
- Explore {param} range more thoroughly
- Test ensemble combinations
- Consider feature selection

**Current status:**
- ✓ Best architecture identified: {model_name}
- ✓ Initial hyperparameters optimized
- ✓ Model saved for further refinement
- ✓ Ready for Phase 7 intensive tuning

**Expected Phase 7 duration:** 2-4 hours
```

### 10. Validation Checklist

Before proceeding to Phase 7:

- [ ] Multiple model types trained and compared
- [ ] Cross-validation performed (10-fold)
- [ ] Baseline models evaluated
- [ ] Top models tuned with Bayesian optimization
- [ ] Best model selected based on CV performance
- [ ] Best model fitted on full training data
- [ ] Variable importance extracted (if applicable)
- [ ] Learning curves analyzed
- [ ] Model comparison documented
- [ ] Best model and parameters saved
- [ ] Ready for Phase 7 (intensive tuning)

---

## Outputs

**Created Files:**
- `scripts/06-model.R`
- `outputs/models/best_model_fit.rds`
- `outputs/models/best_model_params.rds`
- `outputs/figures/baseline_model_comparison.png`
- `outputs/figures/baseline_vs_tuned.png`
- `outputs/figures/model_variable_importance.png`
- `outputs/figures/learning_curve.png`
- `outputs/tables/model_variable_importance.csv`
- `outputs/tables/cv_predictions.csv`
- `outputs/tables/phase06-modeling-summary.md`
- `checkpoints/06-modeling.complete`

**Git Commit:**
```bash
git add scripts/06-model.R outputs/
git commit -m "feat: train and compare multiple models

- Evaluate {n_models} model types
- Tune top {n_tuned} performers
- Select {best_model_name} as best architecture
- CV {metric}: {value} ± {se}
- Save best model for further tuning

Phase 6/10 complete

Co-Authored-By: Alan (Model Master) <noreply@bmad.com>"
```

---

## Troubleshooting

**Issue:** Models taking too long to train
- **Solution**: Reduce CV folds to 5, use smaller initial grid for tuning, enable parallel processing

**Issue:** Poor model performance across all models
- **Solution**: Review feature engineering, check for data leakage, verify target variable quality

**Issue:** High variance between folds
- **Solution**: Check class imbalance, increase training data, use stratified sampling

**Issue:** Out of memory errors
- **Solution**: Reduce model complexity, sample data, use sparse matrices for glmnet

---

## Next Phase

**Phase 7: Tuning**

With best model architecture identified, Alan continues to:
1. Perform intensive hyperparameter search
2. Optimize specific parameters more thoroughly
3. Test ensemble combinations
4. Validate on test set
5. Finalize production model

**Transition:** When ready, say "Continue to Phase 7" or "Start tuning"

---

## Phase Completion

When this phase is complete:
1. Multiple models trained and compared
2. Best architecture selected
3. Initial hyperparameter tuning completed
4. Model saved for further optimization
5. Modeling summary documented
6. Checkpoint file created
7. Git commit made
8. **Alan continues to Phase 7**

**Expected Duration:** 3-5 hours

---

_Phase 6 of 10 | Owner: Alan | RDS Module Full-Lifecycle Workflow_
