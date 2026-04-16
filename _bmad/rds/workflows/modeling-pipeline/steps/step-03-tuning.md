# Step 3: Tuning

**Workflow:** modeling-pipeline
**Owner:** Alan (ML Engineer)
**Duration:** 3-5 days (compute-dependent)

---

## Step Overview

**Goal:** Hyperparameter optimization for selected models to maximize performance

**Inputs:**
- Top 2-3 models from Step 2
- CV folds from Step 2
- Tuning strategy (grid search, Bayesian optimization, racing)
- Compute budget

**Outputs:**
- `tuning_results.html` — Optimization report
- `tuned_models/` — Best model configurations
- `tuning_history.csv` — All configurations tested
- `final_model.rds` — Champion model

---

## Activation

Olá! Este é o **Step 3: Tuning**.

Vamos otimizar os hiperparâmetros dos modelos selecionados:
- **Grid Search:** Systematic exploration of parameter space
- **Bayesian Optimization:** Intelligent search using probabilistic models
- **Racing:** Eliminate poor configurations early

**Objetivo:** Encontrar a melhor configuração de cada modelo e selecionar o campeão final.

---

## Tuning Strategies

### Strategy Selection

| Strategy | Best For | Pros | Cons |
|----------|----------|------|------|
| **Grid Search** | Few parameters, small space | Simple, exhaustive | Slow for many parameters |
| **Random Search** | Many parameters, large space | Efficient exploration | May miss optimal |
| **Bayesian Optimization** | Expensive models, limited budget | Smart exploration | Complex setup |
| **Racing (ANOVA)** | Many configurations | Fast elimination | Needs many configs |
| **Iterative Search** | Very large space | Progressive refinement | Manual iteration |

---

## Grid Search Tuning

### Define Tuning Grid

```r
library(tidymodels)
library(tune)

# Load selected model from Step 2
xgb_wf <- readRDS("{output_folder}/baseline_models/rec_xgb.rds")

# Update model spec with tune() placeholders
xgb_tune_spec <- boost_tree(
  trees = 1000,           # Fixed (early stopping will determine actual)
  tree_depth = tune(),
  min_n = tune(),
  loss_reduction = tune(),
  sample_size = tune(),
  mtry = tune(),
  learn_rate = tune()
) %>%
  set_engine("xgboost", early_stopping_rounds = 50) %>%
  set_mode("regression")

# Update workflow
xgb_tune_wf <- xgb_wf %>%
  update_model(xgb_tune_spec)
```

---

### Create Parameter Grid

```r
# Automatic grid (space-filling design)
xgb_grid <- grid_latin_hypercube(
  tree_depth(range = c(3, 15)),
  min_n(range = c(2, 40)),
  loss_reduction(range = c(-10, 1.5)),  # log10 scale
  sample_size = sample_prop(range = c(0.5, 1.0)),
  finalize(mtry(), train_data),  # Depends on number of predictors
  learn_rate(range = c(-3, -0.5)),  # log10 scale
  size = 50  # Number of configurations
)

# Or manual grid (for specific ranges)
xgb_grid <- expand_grid(
  tree_depth = c(3, 5, 7, 10, 15),
  min_n = c(2, 5, 10, 20),
  loss_reduction = c(0, 0.01, 0.1, 1),
  sample_size = c(0.7, 0.8, 0.9, 1.0),
  mtry = c(5, 10, 20),
  learn_rate = c(0.001, 0.01, 0.03, 0.1)
)

print(paste("Grid size:", nrow(xgb_grid), "configurations"))
```

**Decision Point:** Grid size based on:
- **Compute budget:** More configs = longer time
- **Parameter count:** 5-10 configs per parameter
- **Typical range:** 20-100 configurations

---

### Execute Grid Search

```r
library(doFuture)
registerDoFuture()
plan(multisession, workers = parallel::detectCores() - 1)

# Load CV folds from Step 2
cv_folds <- readRDS("{output_folder}/cv_folds.rds")

# Tune with grid search
set.seed(789)
xgb_tune_results <- tune_grid(
  xgb_tune_wf,
  resamples = cv_folds,
  grid = xgb_grid,
  metrics = metric_set(rmse, rsq, mae),
  control = control_grid(
    save_pred = TRUE,
    save_workflow = TRUE,
    verbose = TRUE,
    parallel_over = "everything"
  )
)

# View results
collect_metrics(xgb_tune_results)
```

---

### Analyze Grid Results

```r
# Plot tuning results
autoplot(xgb_tune_results, metric = "rmse")

# Best configurations
show_best(xgb_tune_results, metric = "rmse", n = 10)

# Select best
best_xgb <- select_best(xgb_tune_results, metric = "rmse")

# Finalize workflow
final_xgb_wf <- finalize_workflow(xgb_tune_wf, best_xgb)
```

---

## Bayesian Optimization

### Setup for Bayesian Tuning

```r
library(finetune)

# Same model spec with tune() placeholders
xgb_tune_spec <- boost_tree(
  trees = 1000,
  tree_depth = tune(),
  min_n = tune(),
  loss_reduction = tune(),
  sample_size = tune(),
  mtry = tune(),
  learn_rate = tune()
) %>%
  set_engine("xgboost", early_stopping_rounds = 50) %>%
  set_mode("regression")

xgb_tune_wf <- workflow() %>%
  add_recipe(rec) %>%
  add_model(xgb_tune_spec)
```

---

### Execute Bayesian Optimization

```r
# Initial grid (for Gaussian process)
xgb_initial <- grid_latin_hypercube(
  tree_depth(range = c(3, 15)),
  min_n(range = c(2, 40)),
  loss_reduction(range = c(-10, 1.5)),
  sample_size = sample_prop(range = c(0.5, 1.0)),
  finalize(mtry(), train_data),
  learn_rate(range = c(-3, -0.5)),
  size = 10  # Small initial grid
)

# Bayesian optimization
set.seed(890)
xgb_bayes_results <- tune_bayes(
  xgb_tune_wf,
  resamples = cv_folds,
  initial = xgb_initial,
  metrics = metric_set(rmse, rsq, mae),
  param_info = parameters(xgb_tune_wf),
  iter = 40,  # Number of iterations
  control = control_bayes(
    save_pred = TRUE,
    save_workflow = TRUE,
    verbose = TRUE,
    no_improve = 10,  # Stop if no improvement for 10 iterations
    uncertain = 5  # Exploration vs exploitation
  )
)

# View optimization path
autoplot(xgb_bayes_results, type = "performance")
autoplot(xgb_bayes_results, type = "parameters")
```

**Advantages:**
- Fewer iterations than grid search
- Smart exploration of parameter space
- Good for expensive models (deep learning, large datasets)

---

## Racing (ANOVA-based)

### Setup for Racing

```r
# Same model spec
xgb_tune_spec <- boost_tree(
  trees = 1000,
  tree_depth = tune(),
  min_n = tune(),
  loss_reduction = tune(),
  sample_size = tune(),
  mtry = tune(),
  learn_rate = tune()
) %>%
  set_engine("xgboost") %>%
  set_mode("regression")

xgb_tune_wf <- workflow() %>%
  add_recipe(rec) %>%
  add_model(xgb_tune_spec)

# Large grid for racing
xgb_grid <- grid_latin_hypercube(
  tree_depth(range = c(3, 15)),
  min_n(range = c(2, 40)),
  loss_reduction(range = c(-10, 1.5)),
  sample_size = sample_prop(range = c(0.5, 1.0)),
  finalize(mtry(), train_data),
  learn_rate(range = c(-3, -0.5)),
  size = 100  # Large grid, racing will eliminate poor configs
)
```

---

### Execute Racing

```r
set.seed(901)
xgb_race_results <- tune_race_anova(
  xgb_tune_wf,
  resamples = cv_folds,
  grid = xgb_grid,
  metrics = metric_set(rmse, rsq, mae),
  control = control_race(
    save_pred = TRUE,
    save_workflow = TRUE,
    verbose = TRUE,
    burn_in = 3,  # Minimum resamples before elimination
    alpha = 0.05  # Significance level
  )
)

# View racing results
plot_race(xgb_race_results)
show_best(xgb_race_results, metric = "rmse")
```

**Advantages:**
- Test many configurations efficiently
- Eliminates poor performers early
- Saves compute time

---

## Model-Specific Tuning Guides

### XGBoost Tuning

**Key Parameters:**
- `tree_depth` (3-15): Complexity of trees
- `min_n` (2-40): Minimum observations in leaf
- `learn_rate` (0.001-0.1): Shrinkage
- `mtry` (sqrt(p) to p): Features per split
- `sample_size` (0.5-1.0): Row sampling
- `loss_reduction` (0-10): Minimum improvement

**Tuning Strategy:**
1. **First pass:** Wide ranges, coarse grid
2. **Second pass:** Narrow around best, finer grid
3. **Trees:** Fix high value, use early stopping

```r
xgb_params <- parameters(
  tree_depth(range = c(3, 10)),
  min_n(range = c(5, 30)),
  learn_rate(range = c(-2, -0.5), trans = scales::log10_trans()),
  sample_size = sample_prop(c(0.6, 1.0)),
  finalize(mtry(), train_data),
  loss_reduction(range = c(-5, 1), trans = scales::log10_trans())
)
```

---

### Random Forest Tuning

**Key Parameters:**
- `mtry` (sqrt(p) to p): Features per split
- `min_n` (2-40): Minimum node size
- `trees` (500-2000): Number of trees

**Tuning Strategy:**
- Trees: Fix at 1000+ (more is better, diminishing returns)
- Focus on `mtry` and `min_n`

```r
rf_tune_spec <- rand_forest(
  mtry = tune(),
  min_n = tune(),
  trees = 1000
) %>%
  set_engine("ranger", importance = "impurity") %>%
  set_mode("regression")

rf_grid <- grid_regular(
  mtry(range = c(2, 20)),
  min_n(range = c(2, 40)),
  levels = 5
)
```

---

### Elastic Net Tuning

**Key Parameters:**
- `penalty` (10^-10 to 10): Regularization strength
- `mixture` (0 to 1): Ridge (0) vs Lasso (1)

**Tuning Strategy:**
- Log scale for penalty
- Test pure ridge (0), pure lasso (1), and mixtures (0.25, 0.5, 0.75)

```r
glmnet_tune_spec <- linear_reg(
  penalty = tune(),
  mixture = tune()
) %>%
  set_engine("glmnet") %>%
  set_mode("regression")

glmnet_grid <- grid_regular(
  penalty(range = c(-10, 1), trans = scales::log10_trans()),
  mixture(range = c(0, 1)),
  levels = c(20, 5)  # 20 penalties × 5 mixtures = 100 configs
)
```

---

### SVM Tuning

**Key Parameters:**
- `cost` (2^-5 to 2^15): Penalty for violations
- `rbf_sigma` (2^-15 to 2^3): Kernel width (RBF)
- `degree` (2-5): Polynomial degree (polynomial kernel)

**Tuning Strategy:**
- Log scale for both cost and rbf_sigma
- Start coarse, refine around best

```r
svm_tune_spec <- svm_rbf(
  cost = tune(),
  rbf_sigma = tune()
) %>%
  set_engine("kernlab") %>%
  set_mode("regression")

svm_grid <- grid_regular(
  cost(range = c(-5, 15), trans = scales::log2_trans()),
  rbf_sigma(range = c(-15, 3), trans = scales::log2_trans()),
  levels = 10
)
```

---

## Multi-Model Tuning

### Tune Multiple Models

```r
# Load top models from Step 2
model_list <- c("xgb", "rf", "glmnet")

# Create tuning specs
tuning_specs <- list(
  xgb = xgb_tune_spec,
  rf = rf_tune_spec,
  glmnet = glmnet_tune_spec
)

# Create grids
tuning_grids <- list(
  xgb = xgb_grid,
  rf = rf_grid,
  glmnet = glmnet_grid
)

# Tune all models
tuning_results <- map2(
  .x = tuning_specs,
  .y = tuning_grids,
  .f = ~ {
    wf <- workflow() %>%
      add_recipe(rec) %>%
      add_model(.x)

    tune_grid(
      wf,
      resamples = cv_folds,
      grid = .y,
      metrics = metric_set(rmse, rsq, mae),
      control = control_grid(save_pred = TRUE, save_workflow = TRUE)
    )
  }
)
```

---

### Compare Tuned Models

```r
# Extract best of each model
best_results <- map_dfr(
  .x = names(tuning_results),
  .f = ~ {
    tuning_results[[.x]] %>%
      show_best(metric = "rmse", n = 1) %>%
      mutate(model = .x)
  }
)

print(best_results)

# Visualize comparison
best_results %>%
  ggplot(aes(x = reorder(model, mean), y = mean)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean - std_err, ymax = mean + std_err), width = 0.2) +
  coord_flip() +
  labs(
    title = "Best Tuned Model Comparison",
    x = "Model",
    y = "RMSE (10-fold CV)"
  ) +
  theme_minimal()
```

---

## Final Model Selection

### Champion Selection

```r
# Identify champion
champion_model <- best_results %>%
  slice_min(mean, n = 1) %>%
  pull(model)

champion_params <- tuning_results[[champion_model]] %>%
  select_best(metric = "rmse")

# Finalize champion workflow
champion_wf <- workflow() %>%
  add_recipe(rec) %>%
  add_model(tuning_specs[[champion_model]]) %>%
  finalize_workflow(champion_params)

print(paste("Champion model:", champion_model))
print(champion_params)
```

---

### Fit Champion on Full Training Data

```r
# Fit on all training data (not just CV folds)
final_fit <- champion_wf %>%
  fit(data = train_data)

# Save final model
saveRDS(final_fit, "{output_folder}/final_model.rds")
```

**Critical:** This is the model that will be evaluated on test set in Step 4.

---

## Documentation

### Generate Tuning Report

```r
render("templates/tuning_report.Rmd",
       params = list(
         tuning_results = tuning_results,
         best_results = best_results,
         champion_model = champion_model,
         champion_params = champion_params,
         champion_wf = champion_wf
       ),
       output_file = "{output_folder}/tuning_results.html")
```

**Report Contents:**
1. Tuning strategy used
2. Parameter grids for each model
3. Optimization trajectories
4. Best configurations per model
5. Final model comparison
6. Champion selection justification
7. Compute time breakdown

---

### Save Tuning History

```r
# Extract all configurations tested
tuning_history <- map_dfr(
  .x = names(tuning_results),
  .f = ~ {
    tuning_results[[.x]] %>%
      collect_metrics() %>%
      mutate(model = .x)
  }
)

write_csv(tuning_history, "{output_folder}/tuning_history.csv")

# Save individual model results
dir.create("{output_folder}/tuned_models", recursive = TRUE)
walk2(
  .x = names(tuning_results),
  .y = tuning_results,
  ~ saveRDS(.y, file = glue::glue("{output_folder}/tuned_models/{.x}_tuning.rds"))
)
```

---

## Advanced Tuning Techniques

### Iterative Tuning

For very large parameter spaces:

```r
# Stage 1: Coarse grid
coarse_grid <- grid_latin_hypercube(
  tree_depth(range = c(3, 15)),
  min_n(range = c(2, 40)),
  learn_rate(range = c(-3, -0.5)),
  size = 20
)

stage1_results <- tune_grid(xgb_tune_wf, cv_folds, grid = coarse_grid)
best_coarse <- select_best(stage1_results, metric = "rmse")

# Stage 2: Fine grid around best
fine_grid <- grid_regular(
  tree_depth(range = c(best_coarse$tree_depth - 2, best_coarse$tree_depth + 2)),
  min_n(range = c(max(2, best_coarse$min_n - 10), best_coarse$min_n + 10)),
  learn_rate(range = c(best_coarse$learn_rate * 0.5, best_coarse$learn_rate * 2)),
  levels = 5
)

stage2_results <- tune_grid(xgb_tune_wf, cv_folds, grid = fine_grid)
final_best <- select_best(stage2_results, metric = "rmse")
```

---

### Custom Metrics and Selection

```r
# Define custom metric
custom_metric <- metric_set(rmse, rsq, mae, huber_loss)

# Tune with custom metric
tuning_results <- tune_grid(
  xgb_tune_wf,
  resamples = cv_folds,
  grid = xgb_grid,
  metrics = custom_metric
)

# Select based on multiple criteria
best_rmse <- select_best(tuning_results, metric = "rmse")
best_rsq <- select_best(tuning_results, metric = "rsq")
best_balanced <- select_by_pct_loss(tuning_results, metric = "rmse", limit = 5)  # Within 5% of best RMSE
```

---

### Simulated Annealing

For complex parameter spaces:

```r
xgb_sa_results <- tune_sim_anneal(
  xgb_tune_wf,
  resamples = cv_folds,
  initial = xgb_initial,  # Initial grid
  metrics = metric_set(rmse, rsq, mae),
  param_info = parameters(xgb_tune_wf),
  iter = 50,
  control = control_sim_anneal(
    verbose = TRUE,
    no_improve = 15,
    cooling_coef = 0.02  # Controls exploration vs exploitation
  )
)
```

---

## Best Practices

### 1. Tuning Strategy Selection

- **Few parameters (<3):** Grid search
- **Many parameters (>5):** Bayesian or racing
- **Limited compute:** Racing
- **Expensive models:** Bayesian optimization

---

### 2. Grid Design

- **Start coarse:** Wide ranges, fewer points
- **Refine iteratively:** Narrow around best regions
- **Log scales:** For penalty, learning rates, regularization
- **Space-filling:** Latin hypercube > regular grid

---

### 3. Common Pitfalls

**❌ Testing too many configurations**
**✅ Solution:** Start with 20-50, refine if needed

**❌ Over-tuning (overfitting to CV folds)**
**✅ Solution:** Monitor multiple metrics, use test set in Step 4

**❌ Ignoring computational cost**
**✅ Solution:** Profile one model fit, estimate total time

**❌ Not saving intermediate results**
**✅ Solution:** Use `save_workflow = TRUE`, save after each model

---

## Troubleshooting

### Issue: Tuning takes too long

**Solutions:**
```r
# 1. Reduce CV folds
cv_folds <- vfold_cv(train_data, v = 5)  # Instead of 10

# 2. Reduce grid size
xgb_grid <- grid_latin_hypercube(..., size = 20)  # Instead of 50

# 3. Use racing
tune_race_anova(...)  # Eliminates poor configs early

# 4. Parallelize aggressively
plan(multisession, workers = parallel::detectCores())

# 5. Use early stopping
set_engine("xgboost", early_stopping_rounds = 20)
```

---

### Issue: No improvement over baseline

**Possible reasons:**
- Parameter ranges too narrow
- Baseline already optimal (simple is better)
- Overfitting during tuning

**Solutions:**
```r
# 1. Check if baseline was using good defaults
show_best(baseline_results, metric = "rmse")
show_best(tuning_results, metric = "rmse")

# 2. Expand parameter ranges
tree_depth(range = c(1, 20))  # Instead of c(3, 10)

# 3. Try different model types
# Maybe tree model isn't appropriate for this data
```

---

### Issue: High variance in tuning results

**Symptom:** Large std_err in metrics

**Solutions:**
```r
# 1. Increase CV folds or use repeated CV
cv_folds <- vfold_cv(train_data, v = 10, repeats = 3)

# 2. Check for data quality issues
# High variance may indicate noisy or inconsistent data

# 3. Add regularization
# Reduce model complexity to improve stability
```

---

## Compute Time Estimates

### Typical Timings (10-fold CV, 50K rows, 20 features)

| Model | Grid Size | Time per Config | Total Time |
|-------|-----------|-----------------|------------|
| Linear/GLM | 50 | 10 seconds | 8 minutes |
| Random Forest | 25 | 2 minutes | 50 minutes |
| XGBoost | 50 | 30 seconds | 25 minutes |
| SVM | 100 | 1 minute | 100 minutes |

**With parallelization (8 cores):** Divide by ~6-7.

---

## Transition to Step 4

Once tuning is complete:

1. ✅ All selected models tuned
2. ✅ Champion model selected
3. ✅ Final model fit on full training data
4. ✅ Tuning report generated and reviewed
5. ✅ Model object saved (`final_model.rds`)

**Ready for Step 4: Evaluation**

The champion model will now be evaluated on the held-out test set.

---

**Step 3 complete. Proceed to Step 4: Evaluation.**
