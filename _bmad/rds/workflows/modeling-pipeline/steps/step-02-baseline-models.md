# Step 2: Baseline Models

**Workflow:** modeling-pipeline
**Owner:** Alan (ML Engineer)
**Duration:** 2-3 days

---

## Step Overview

**Goal:** Build and compare multiple model types to identify top candidates for tuning

**Inputs:**
- Recipe from Step 1 (`recipe.rds`)
- Clean data with train/test split
- Problem type (classification/regression)
- Optional: Model preferences

**Outputs:**
- `baseline_comparison.html` — Model comparison report
- `baseline_models/` — Saved workflow objects
- `cv_results.csv` — Cross-validation metrics
- Top 2-3 model candidates for tuning

---

## Activation

Olá! Este é o **Step 2: Baseline Models**.

Vamos comparar múltiplos tipos de modelos para identificar os mais promissores:
- **Breadth before depth:** Testar vários modelos simples
- **Honest evaluation:** Todos usando a mesma estratégia de CV
- **Quick iteration:** Sem tuning ainda (apenas defaults razoáveis)

**Objetivo:** Selecionar 2-3 modelos para otimização no Step 3.

---

## Data Splitting Strategy

### Initial Split

```r
library(tidymodels)
library(rsample)

# Load data and recipe
data <- readRDS("path/to/clean_data.rds")
rec <- readRDS("{output_folder}/recipe.rds")

# Create train/test split
set.seed(123)
data_split <- initial_split(data, prop = 0.75, strata = {{ target }})
train_data <- training(data_split)
test_data <- testing(data_split)
```

**Critical:** Test set is set aside and NOT used until Step 4.

---

### Cross-Validation Folds

```r
# Create CV folds from training data only
set.seed(456)
cv_folds <- vfold_cv(train_data, v = 10, strata = {{ target }})

# For large data
cv_folds <- vfold_cv(train_data, v = 5)

# For time series
cv_folds <- rolling_origin(train_data,
                          initial = 365,
                          assess = 30,
                          cumulative = TRUE)
```

**Decision Point:** CV strategy based on:
- **Data size:** 10-fold for <50K rows, 5-fold for larger
- **Class imbalance:** Always use stratified sampling
- **Time series:** Use temporal validation (no shuffling)

---

## Model Specifications

### Load Model Selection Guide

Refer to: `{installed_path}/data/model-selection-guide.md`

Key considerations:
- Problem type (classification/regression)
- Data size and dimensionality
- Interpretability requirements
- Computational budget

---

## Baseline Model Suite

### For Regression Problems

#### 1. Linear Regression (Baseline)

```r
lm_spec <- linear_reg() %>%
  set_engine("lm") %>%
  set_mode("regression")

lm_wf <- workflow() %>%
  add_recipe(rec) %>%
  add_model(lm_spec)
```

**Why include:** Simple, interpretable baseline.

---

#### 2. Regularized Regression (Elastic Net)

```r
glmnet_spec <- linear_reg(penalty = 0.01, mixture = 0.5) %>%
  set_engine("glmnet") %>%
  set_mode("regression")

glmnet_wf <- workflow() %>%
  add_recipe(rec) %>%
  add_model(glmnet_spec)
```

**Why include:** Handles multicollinearity, feature selection.

---

#### 3. Random Forest

```r
rf_spec <- rand_forest(trees = 500) %>%
  set_engine("ranger", importance = "impurity") %>%
  set_mode("regression")

rf_wf <- workflow() %>%
  add_recipe(rec) %>%
  add_model(rf_spec)
```

**Why include:** Non-linear patterns, interaction detection.

---

#### 4. XGBoost

```r
xgb_spec <- boost_tree(trees = 500, learn_rate = 0.01) %>%
  set_engine("xgboost") %>%
  set_mode("regression")

xgb_wf <- workflow() %>%
  add_recipe(rec) %>%
  add_model(xgb_spec)
```

**Why include:** Often top performer, handles mixed data.

---

#### 5. Support Vector Machine

```r
svm_spec <- svm_rbf(cost = 1, rbf_sigma = 0.1) %>%
  set_engine("kernlab") %>%
  set_mode("regression")

svm_wf <- workflow() %>%
  add_recipe(rec) %>%
  add_model(svm_spec)
```

**Why include:** Good for small-medium datasets, non-linear.

---

#### 6. K-Nearest Neighbors

```r
knn_spec <- nearest_neighbor(neighbors = 5) %>%
  set_engine("kknn") %>%
  set_mode("regression")

knn_wf <- workflow() %>%
  add_recipe(rec) %>%
  add_model(knn_spec)
```

**Why include:** Simple, good for local patterns.

---

### For Classification Problems

#### 1. Logistic Regression (Baseline)

```r
logistic_spec <- logistic_reg() %>%
  set_engine("glm") %>%
  set_mode("classification")

logistic_wf <- workflow() %>%
  add_recipe(rec) %>%
  add_model(logistic_spec)
```

---

#### 2. Regularized Logistic Regression

```r
glmnet_spec <- logistic_reg(penalty = 0.01, mixture = 0.5) %>%
  set_engine("glmnet") %>%
  set_mode("classification")

glmnet_wf <- workflow() %>%
  add_recipe(rec) %>%
  add_model(glmnet_spec)
```

---

#### 3. Random Forest

```r
rf_spec <- rand_forest(trees = 500) %>%
  set_engine("ranger", importance = "impurity") %>%
  set_mode("classification")

rf_wf <- workflow() %>%
  add_recipe(rec) %>%
  add_model(rf_spec)
```

---

#### 4. XGBoost

```r
xgb_spec <- boost_tree(trees = 500, learn_rate = 0.01) %>%
  set_engine("xgboost") %>%
  set_mode("classification")

xgb_wf <- workflow() %>%
  add_recipe(rec) %>%
  add_model(xgb_spec)
```

---

#### 5. Naive Bayes

```r
nb_spec <- naive_Bayes() %>%
  set_engine("naivebayes") %>%
  set_mode("classification")

nb_wf <- workflow() %>%
  add_recipe(rec) %>%
  add_model(nb_spec)
```

---

#### 6. Neural Network (Simple)

```r
nnet_spec <- mlp(hidden_units = 5, epochs = 100) %>%
  set_engine("nnet") %>%
  set_mode("classification")

nnet_wf <- workflow() %>%
  add_recipe(rec) %>%
  add_model(nnet_spec)
```

---

## Model Evaluation

### Parallel Execution

```r
library(doFuture)
registerDoFuture()
plan(multisession, workers = parallel::detectCores() - 1)

# Create workflow set
baseline_set <- workflow_set(
  preproc = list(rec = rec),
  models = list(
    lm = lm_spec,
    glmnet = glmnet_spec,
    rf = rf_spec,
    xgb = xgb_spec,
    svm = svm_spec,
    knn = knn_spec
  )
)

# Fit all models with CV
baseline_results <- baseline_set %>%
  workflow_map(
    fn = "fit_resamples",
    resamples = cv_folds,
    metrics = metric_set(rmse, rsq, mae),  # For regression
    control = control_resamples(save_pred = TRUE, save_workflow = TRUE),
    verbose = TRUE
  )
```

---

### Metric Selection

Refer to: `{installed_path}/data/metric-selection-guide.md`

#### Regression Metrics

```r
regression_metrics <- metric_set(
  rmse,      # Root Mean Squared Error (penalizes large errors)
  mae,       # Mean Absolute Error (robust to outliers)
  rsq,       # R-squared (proportion variance explained)
  mape       # Mean Absolute Percentage Error (scale-free)
)
```

---

#### Classification Metrics

```r
classification_metrics <- metric_set(
  accuracy,    # Overall correctness
  roc_auc,     # Discrimination ability
  pr_auc,      # Precision-recall (for imbalanced)
  f_meas,      # F1 score
  sens,        # Sensitivity (recall)
  spec         # Specificity
)
```

**Decision Point:** Primary metric based on business objective:
- **Cost of errors:** RMSE (regression) or cost-sensitive metric (classification)
- **Class imbalance:** PR-AUC instead of ROC-AUC
- **Interpretability:** Accuracy for classification, R² for regression

---

## Results Analysis

### Extract and Compare Metrics

```r
# Collect metrics
baseline_metrics <- baseline_results %>%
  collect_metrics()

# Rank models
baseline_ranking <- baseline_metrics %>%
  filter(.metric == "rmse") %>%  # Primary metric
  arrange(mean) %>%
  select(wflow_id, mean, std_err, n)

print(baseline_ranking)
```

---

### Visualization

```r
library(ggplot2)

# Performance comparison
baseline_metrics %>%
  filter(.metric == "rmse") %>%
  ggplot(aes(x = reorder(wflow_id, mean), y = mean)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean - std_err, ymax = mean + std_err), width = 0.2) +
  coord_flip() +
  labs(
    title = "Baseline Model Comparison",
    subtitle = "10-fold CV RMSE (lower is better)",
    x = "Model",
    y = "RMSE"
  ) +
  theme_minimal()
```

---

### Prediction Analysis

```r
# Extract predictions
baseline_preds <- baseline_results %>%
  collect_predictions()

# Compare predictions across models
baseline_preds %>%
  ggplot(aes(x = .pred, y = {{ target }})) +
  geom_point(alpha = 0.3) +
  geom_abline(color = "red", linetype = "dashed") +
  facet_wrap(~ wflow_id) +
  labs(
    title = "Predicted vs Actual",
    x = "Predicted",
    y = "Actual"
  ) +
  theme_minimal()
```

---

## Model Selection

### Selection Criteria

Choose top 2-3 models based on:

1. **Performance:** Top performers on primary metric
2. **Diversity:** Different model families (e.g., linear + tree + ensemble)
3. **Computational cost:** Balance performance vs. training time
4. **Interpretability:** Consider stakeholder needs

---

### Example Selection Logic

```r
# Identify top 3 by performance
top_models <- baseline_ranking %>%
  slice_min(mean, n = 3) %>%
  pull(wflow_id)

# Add best interpretable model if not in top 3
interpretable_models <- c("rec_lm", "rec_glmnet")
best_interpretable <- baseline_ranking %>%
  filter(wflow_id %in% interpretable_models) %>%
  slice_min(mean, n = 1) %>%
  pull(wflow_id)

# Final selection
selected_models <- unique(c(top_models, best_interpretable))

print(paste("Selected for tuning:", paste(selected_models, collapse = ", ")))
```

---

## Documentation

### Generate Comparison Report

```r
library(rmarkdown)

render("templates/baseline_comparison_report.Rmd",
       params = list(
         results = baseline_results,
         metrics = baseline_metrics,
         predictions = baseline_preds,
         selected = selected_models,
         cv_folds = cv_folds
       ),
       output_file = "{output_folder}/baseline_comparison.html")
```

**Report Contents:**
1. Data split summary
2. CV strategy
3. Model specifications
4. Performance comparison (table + plots)
5. Prediction visualizations
6. Model selection justification
7. Recommendations for tuning

---

### Save Model Objects

```r
# Save all baseline workflows
dir.create("{output_folder}/baseline_models", recursive = TRUE)

baseline_results %>%
  extract_workflow_set_result() %>%
  walk2(.x = selected_models,
        .y = .,
        ~ saveRDS(.y, file = glue::glue("{output_folder}/baseline_models/{.x}.rds")))

# Save summary
baseline_summary <- tibble(
  model = selected_models,
  mean_rmse = baseline_ranking %>% filter(wflow_id %in% selected_models) %>% pull(mean),
  selected_for_tuning = TRUE,
  timestamp = Sys.time()
)

write_csv(baseline_summary, "{output_folder}/baseline_summary.csv")
```

---

## Common Model Configurations

### Quick Baseline (3 models)

For fast iteration:

```r
quick_baseline <- list(
  lm = linear_reg() %>% set_engine("lm"),
  rf = rand_forest() %>% set_engine("ranger"),
  xgb = boost_tree() %>% set_engine("xgboost")
)
```

---

### Comprehensive Baseline (8+ models)

For thorough exploration:

```r
comprehensive_baseline <- list(
  lm = linear_reg() %>% set_engine("lm"),
  glmnet = linear_reg(penalty = tune(), mixture = tune()) %>% set_engine("glmnet"),
  rf = rand_forest() %>% set_engine("ranger"),
  xgb = boost_tree() %>% set_engine("xgboost"),
  svm_rbf = svm_rbf() %>% set_engine("kernlab"),
  svm_poly = svm_poly() %>% set_engine("kernlab"),
  knn = nearest_neighbor() %>% set_engine("kknn"),
  nnet = mlp() %>% set_engine("nnet")
)
```

---

### Specialized Baseline

For specific problems:

```r
# Time series
timeseries_baseline <- list(
  arima = arima_reg() %>% set_engine("auto_arima"),
  prophet = prophet_reg() %>% set_engine("prophet"),
  xgb = boost_tree() %>% set_engine("xgboost")
)

# Imbalanced classification
imbalanced_baseline <- list(
  logistic = logistic_reg() %>% set_engine("glm"),
  rf_balanced = rand_forest() %>% set_engine("ranger", class.weights = "balanced"),
  xgb_weighted = boost_tree() %>% set_engine("xgboost", scale_pos_weight = 10)
)
```

---

## Best Practices

### 1. Model Comparison Principles

- **Same data:** All models use identical CV folds
- **Same recipe:** Bundled in workflow (preprocessing inside CV)
- **Same metrics:** Consistent evaluation criteria
- **No peeking:** Test set untouched

---

### 2. Performance Considerations

```r
# Parallel backends
library(doFuture)
plan(multisession)  # For Unix/Mac
plan(multisession, workers = 4)  # Limit workers

# For large data
options(future.globals.maxSize = 1024^3)  # 1 GB

# Progress tracking
options(tidymodels.dark = TRUE)  # Enable progress bars
```

---

### 3. Common Pitfalls

**❌ Tuning at baseline stage**
**✅ Solution:** Use reasonable defaults, tune in Step 3

**❌ Different preprocessing per model**
**✅ Solution:** Same recipe in all workflows

**❌ Overfitting to CV folds**
**✅ Solution:** Use multiple metrics, check prediction plots

**❌ Ignoring computational cost**
**✅ Solution:** Consider training time for production

---

## Troubleshooting

### Issue: Model fails to fit

**Symptom:** Error during `fit_resamples()`

**Common causes:**
- Recipe produces invalid data (NAs, Inf)
- Model specification incompatible with data
- Insufficient memory

**Solution:**
```r
# Test single model on single fold
test_fit <- lm_wf %>%
  fit(data = analysis(cv_folds$splits[[1]]))

# Check processed data
test_data <- rec %>%
  prep() %>%
  bake(new_data = NULL)

summary(test_data)
```

---

### Issue: Poor performance across all models

**Symptom:** All models have bad metrics

**Possible reasons:**
1. **Feature engineering issue:** Recipe not capturing signal
2. **Target leakage:** Training on test data accidentally
3. **Wrong problem type:** Classification vs regression mismatch
4. **Data quality:** Still have issues from Step 1

**Solution:**
```r
# Return to Step 1
# - Review recipe
# - Check distributions
# - Add domain-specific features

# Or return to Ada's data-pipeline
# - May need additional cleaning
# - Check for data quality issues
```

---

### Issue: High variance in CV results

**Symptom:** Large standard errors in metrics

**Possible reasons:**
- Small sample size
- High noise in data
- Model instability

**Solution:**
```r
# Increase CV folds
cv_folds <- vfold_cv(train_data, v = 10, repeats = 3)  # Repeated CV

# Or use bootstrap
cv_folds <- bootstraps(train_data, times = 25)

# Check fold-wise performance
baseline_results %>%
  collect_metrics(summarize = FALSE) %>%
  ggplot(aes(x = wflow_id, y = .estimate)) +
  geom_boxplot() +
  facet_wrap(~ .metric, scales = "free_y")
```

---

## Transition to Step 3

Once baseline comparison is complete:

1. ✅ All models evaluated with same CV strategy
2. ✅ Comparison report generated and reviewed
3. ✅ Top 2-3 models selected
4. ✅ Model objects saved

**Ready for Step 3: Tuning**

Selected models will undergo hyperparameter optimization to maximize performance.

---

**Step 2 complete. Proceed to Step 3: Tuning.**
