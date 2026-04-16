# Feature Selection Reference

Comprehensive guide to feature selection methods in R for reducing dimensionality and improving model performance.

## Overview

Feature selection reduces the number of predictors by identifying and removing non-informative or redundant variables, improving:
- Model interpretability
- Training speed
- Generalization performance
- Computational efficiency

**Three Main Approaches**:
1. **Filter Methods** - Fast, model-agnostic univariate screening
2. **Wrapper Methods** - Model-based iterative search
3. **Embedded Methods** - Selection during model training

---

## Filter Methods

### Concept

Evaluate each predictor independently using statistical measures, **before** model training. Fast but may miss useful interactions.

### Common Filter Techniques

#### 1. Correlation-Based Filtering

Remove predictors highly correlated with outcome (for relevance) or with each other (for redundancy).

**Implementation**:
```r
library(tidymodels)
library(corrr)

# Remove highly correlated predictors
filter_recipe <- recipe(outcome ~ ., data = train) |>
  step_corr(all_numeric_predictors(), threshold = 0.90)

# Correlation with outcome
train_cors <- train |>
  select(where(is.numeric)) |>
  correlate() |>
  focus(outcome) |>
  arrange(desc(abs(outcome)))

# Keep top N by correlation
top_predictors <- train_cors |>
  slice_max(abs(outcome), n = 50) |>
  pull(term)
```

**When to Use**:
- Quick initial screening
- Remove redundant predictors
- Reduce multicollinearity

**Limitations**:
- Only captures linear relationships
- Ignores interactions
- May remove useful correlated predictors

---

#### 2. Variance-Based Filtering

Remove near-zero variance predictors that provide little information.

**Implementation**:
```r
# Remove near-zero variance predictors
nzv_recipe <- recipe(outcome ~ ., data = train) |>
  step_nzv(all_predictors(), freq_cut = 95/5, unique_cut = 10)

# Manual calculation
low_variance_vars <- train |>
  summarise(across(where(is.numeric), var)) |>
  pivot_longer(everything()) |>
  filter(value < 0.01) |>
  pull(name)
```

**When to Use**:
- Remove constant or nearly constant predictors
- Clean data before modeling
- Essential first step

---

#### 3. Statistical Tests

Use hypothesis tests to identify predictors associated with outcome.

**For Numeric Outcome**:
```r
library(broom)

# Correlation test for each predictor
cor_tests <- train |>
  select(where(is.numeric), -outcome) |>
  names() |>
  map_dfr(~{
    test <- cor.test(train[[.x]], train$outcome)
    tidy(test) |> mutate(predictor = .x)
  }) |>
  arrange(p.value)

# Keep significant predictors (p < 0.05)
significant_vars <- cor_tests |>
  filter(p.value < 0.05) |>
  pull(predictor)
```

**For Categorical Outcome**:
```r
# ANOVA F-test for numeric predictors
anova_results <- train |>
  select(where(is.numeric)) |>
  pivot_longer(-outcome, names_to = "predictor", values_to = "value") |>
  nest(data = -predictor) |>
  mutate(
    anova = map(data, ~aov(value ~ outcome, data = .x)),
    tidy = map(anova, tidy)
  ) |>
  unnest(tidy) |>
  filter(term == "outcome") |>
  arrange(p.value)

# Chi-square test for categorical predictors
chisq_results <- train |>
  select(where(is.factor), -outcome) |>
  names() |>
  map_dfr(~{
    test <- chisq.test(table(train[[.x]], train$outcome))
    tidy(test) |> mutate(predictor = .x)
  }) |>
  arrange(p.value)
```

**Multiple Comparison Adjustment**:
```r
# Apply FDR correction
anova_results <- anova_results |>
  mutate(p.adjusted = p.adjust(p.value, method = "fdr"))

# Keep FDR < 0.05
selected_vars <- anova_results |>
  filter(p.adjusted < 0.05) |>
  pull(predictor)
```

---

#### 4. Information-Based Filters

Use information gain, mutual information, or ReliefF algorithm.

**Mutual Information**:
```r
library(infotheo)

# Calculate mutual information
mi_scores <- train |>
  select(where(is.numeric), -outcome) |>
  names() |>
  map_dbl(~{
    mutinformation(
      discretize(train[[.x]], nbins = 10),
      train$outcome
    )
  }) |>
  tibble(predictor = names(.), mi = .)  |>
  arrange(desc(mi))

# Keep top N by mutual information
top_mi_vars <- mi_scores |>
  slice_max(mi, n = 30) |>
  pull(predictor)
```

---

### Filter Method Advantages/Disadvantages

**Advantages**:
- ✅ Very fast (no model fitting required)
- ✅ Model-agnostic
- ✅ Good for initial screening with many predictors
- ✅ Easy to interpret (statistical tests)

**Disadvantages**:
- ❌ Ignores predictor interactions
- ❌ Doesn't consider model performance
- ❌ May select redundant features
- ❌ Univariate approach misses multivariate patterns

---

## Wrapper Methods

### Concept

Use predictive model to evaluate subsets of features. Computationally expensive but finds optimal subset for specific model.

### Recursive Feature Elimination (RFE)

**Greedy Backward Selection**: Start with all features, iteratively remove least important.

**Algorithm**:
1. Train model on all predictors
2. Rank predictors by importance
3. Remove least important predictor(s)
4. Repeat until desired number reached
5. Select subset with best performance

**Implementation**:
```r
library(caret)

# Prepare data
x_train <- train |> select(-outcome) |> as.matrix()
y_train <- train$outcome

# RFE control
rfe_ctrl <- rfeControl(
  functions = rfFuncs,  # Use random forest
  method = "cv",
  number = 10,
  verbose = FALSE
)

# Run RFE testing different subset sizes
rfe_results <- rfe(
  x = x_train,
  y = y_train,
  sizes = c(5, 10, 15, 20, 25, 30),
  rfeControl = rfe_ctrl
)

# Optimal number and variables
rfe_results$optsize
rfe_results$optVariables

# Plot performance vs. number of predictors
plot(rfe_results, type = c("g", "o"))
```

**Model-Specific Functions**:
```r
# Linear regression
rfeControl(functions = lmFuncs, ...)

# Logistic regression
rfeControl(functions = lrFuncs, ...)

# Random forest
rfeControl(functions = rfFuncs, ...)

# Naive Bayes
rfeControl(functions = nbFuncs, ...)
```

---

### Forward Selection

**Greedy Forward Search**: Start with empty set, iteratively add most important.

**Implementation with stepwise**:
```r
library(MASS)

# Start with null model
null_model <- lm(outcome ~ 1, data = train)

# Full model scope
full_model <- lm(outcome ~ ., data = train)

# Forward selection by AIC
forward_model <- step(
  null_model,
  scope = list(lower = null_model, upper = full_model),
  direction = "forward",
  trace = 0
)

# Selected variables
selected_vars <- names(coef(forward_model))[-1]  # Remove intercept
```

---

### Backward Elimination

**Greedy Backward Search**: Start with all predictors, remove least significant.

**Implementation**:
```r
# Start with full model
full_model <- lm(outcome ~ ., data = train)

# Backward elimination by AIC
backward_model <- step(
  full_model,
  direction = "backward",
  trace = 0
)

# Selected variables
selected_vars <- names(coef(backward_model))[-1]
```

---

### Bidirectional Stepwise Selection

**Hybrid Approach**: Combine forward and backward at each step.

**Implementation**:
```r
# Both directions
stepwise_model <- step(
  null_model,
  scope = list(lower = null_model, upper = full_model),
  direction = "both",
  trace = 0
)

# Selected variables
selected_vars <- names(coef(stepwise_model))[-1]
```

---

### Genetic Algorithms (Global Search)

**Evolutionary Optimization**: Use genetic operators for global feature subset search.

**Implementation**:
```r
library(GA)

# Fitness function: cross-validated performance
fitness_function <- function(chromosome) {
  selected_idx <- which(chromosome == 1)

  if (length(selected_idx) == 0) return(-Inf)
  if (length(selected_idx) > 50) return(-Inf)  # Penalty for too many

  selected_vars <- predictor_names[selected_idx]

  # Create recipe with selected features only
  ga_recipe <- recipe(outcome ~ ., data = train) |>
    step_select(all_of(selected_vars)) |>
    step_normalize(all_predictors())

  ga_wf <- workflow() |>
    add_recipe(ga_recipe) |>
    add_model(linear_reg())

  # Cross-validation
  cv_results <- fit_resamples(
    ga_wf,
    resamples = vfold_cv(train, v = 5),
    metrics = metric_set(rmse)
  )

  # Return negative RMSE (GA maximizes fitness)
  -mean(collect_metrics(cv_results)$mean)
}

# Run genetic algorithm
ga_results <- ga(
  type = "binary",
  fitness = fitness_function,
  nBits = length(predictor_names),
  popSize = 50,
  maxiter = 100,
  run = 20,  # Stop after 20 iterations without improvement
  pmutation = 0.1,
  pcrossover = 0.8,
  monitor = FALSE
)

# Extract best solution
best_idx <- which(ga_results@solution[1, ] == 1)
selected_vars <- predictor_names[best_idx]
```

---

### Simulated Annealing

**Stochastic Optimization**: Probabilistic technique for global optimization.

**Implementation**:
```r
library(caret)

# SA control
sa_ctrl <- safsControl(
  functions = caretSA,
  method = "cv",
  number = 10
)

# Run simulated annealing
sa_results <- safs(
  x = x_train,
  y = y_train,
  safsControl = sa_ctrl,
  method = "lm"
)

# Selected variables
selected_vars <- sa_results$optVariables
```

---

### Wrapper Method Advantages/Disadvantages

**Advantages**:
- ✅ Finds optimal subset for specific model
- ✅ Considers interactions and dependencies
- ✅ Directly optimizes model performance
- ✅ Global search methods avoid local optima

**Disadvantages**:
- ❌ Computationally expensive
- ❌ Risk of overfitting (especially with small datasets)
- ❌ Requires many model fits
- ❌ Results specific to chosen model type

---

## Embedded Methods

### Concept

Feature selection occurs **during** model training as part of the learning algorithm. Efficient middle ground between filters and wrappers.

### L1 Regularization (LASSO)

**Automatic Selection**: Penalty forces coefficients to exactly zero.

**Implementation**:
```r
# Lasso model
lasso_recipe <- recipe(outcome ~ ., data = train) |>
  step_normalize(all_predictors())

lasso_spec <- linear_reg(penalty = tune(), mixture = 1) |>
  set_engine("glmnet")

lasso_wf <- workflow() |>
  add_recipe(lasso_recipe) |>
  add_model(lasso_spec)

# Tune penalty parameter
lasso_tune <- tune_grid(
  lasso_wf,
  resamples = vfold_cv(train, v = 10),
  grid = 50,
  metrics = metric_set(rmse, rsq)
)

# Best model
best_lasso <- select_best(lasso_tune, metric = "rmse")
final_lasso <- finalize_workflow(lasso_wf, best_lasso)

lasso_fit <- fit(final_lasso, data = train)

# Extract non-zero coefficients (selected features)
lasso_coefs <- extract_fit_engine(lasso_fit) |>
  tidy() |>
  filter(estimate != 0, term != "(Intercept)")

selected_vars <- lasso_coefs$term
length(selected_vars)  # Number of selected features
```

**Visualize Regularization Path**:
```r
library(glmnet)

# Fit glmnet directly for visualization
x_matrix <- model.matrix(outcome ~ . - 1, data = train)
y_vector <- train$outcome

lasso_fit <- glmnet(x_matrix, y_vector, alpha = 1)

# Plot coefficient paths
plot(lasso_fit, xvar = "lambda", label = TRUE)

# Show cross-validated lambda selection
lasso_cv <- cv.glmnet(x_matrix, y_vector, alpha = 1)
plot(lasso_cv)
```

---

### Elastic Net

**Combination**: Blends L1 (LASSO) and L2 (Ridge) penalties.

**Implementation**:
```r
# Elastic net
enet_spec <- linear_reg(
  penalty = tune(),
  mixture = tune()  # 0 = ridge, 1 = lasso
) |>
  set_engine("glmnet")

enet_wf <- workflow() |>
  add_recipe(lasso_recipe) |>
  add_model(enet_spec)

# Tune both parameters
enet_tune <- tune_grid(
  enet_wf,
  resamples = vfold_cv(train, v = 10),
  grid = 20
)

# Best combination
autoplot(enet_tune)
best_enet <- select_best(enet_tune, metric = "rmse")
```

---

### Tree-Based Feature Importance

**Random Forest Variable Importance**: Permutation or impurity-based.

**Implementation**:
```r
library(ranger)
library(vip)

# Random forest with importance
rf_spec <- rand_forest(trees = 1000) |>
  set_engine("ranger", importance = "permutation") |>
  set_mode("regression")

rf_fit <- fit(rf_spec, outcome ~ ., data = train)

# Extract and visualize importance
rf_importance <- vip(rf_fit, num_features = 30)

# Select top N features
top_n_vars <- rf_importance$data |>
  slice_max(Importance, n = 20) |>
  pull(Variable)
```

**XGBoost Feature Importance**:
```r
library(xgboost)

# XGBoost model
xgb_spec <- boost_tree(trees = 500) |>
  set_engine("xgboost") |>
  set_mode("regression")

xgb_fit <- fit(xgb_spec, outcome ~ ., data = train)

# Extract importance
xgb_importance <- vip(xgb_fit, num_features = 30)
```

---

### Embedded Method Advantages/Disadvantages

**Advantages**:
- ✅ Efficient (selection during training)
- ✅ Less prone to overfitting than wrappers
- ✅ Fast relative to wrappers
- ✅ Considers interactions

**Disadvantages**:
- ❌ Model-specific (different models select different features)
- ❌ Limited to models supporting built-in selection
- ❌ Less exhaustive than wrappers

---

## Hybrid Approaches

### Three-Stage Pipeline

Combine multiple methods for optimal results.

**Stage 1: Filter** (Fast screening)
```r
# Remove low variance and highly correlated
filter_recipe <- recipe(outcome ~ ., data = train) |>
  step_nzv(all_predictors()) |>
  step_corr(all_numeric_predictors(), threshold = 0.95)

filter_prepped <- prep(filter_recipe)
train_filtered <- bake(filter_prepped, new_data = NULL)
# 500 → 250 predictors
```

**Stage 2: Embedded** (Model-based reduction)
```r
# Lasso on filtered features
lasso_fit <- fit(lasso_wf, data = train_filtered)

lasso_selected <- extract_fit_engine(lasso_fit) |>
  tidy() |>
  filter(estimate != 0, term != "(Intercept)") |>
  pull(term)
# 250 → 50 predictors
```

**Stage 3: Wrapper** (Fine-tuning)
```r
# RFE on lasso-selected features
train_embedded <- train |> select(outcome, all_of(lasso_selected))

rfe_results <- rfe(
  x = train_embedded |> select(-outcome),
  y = train_embedded$outcome,
  sizes = c(10, 20, 30, 40),
  rfeControl = rfe_ctrl
)

final_vars <- rfe_results$optVariables
# 50 → 25 predictors
```

---

## Method Selection Guide

### Based on Problem Size

| Scenario | Method | Rationale |
|----------|--------|-----------|
| p < 50 | Wrapper methods (RFE) | Exhaustive search feasible |
| 50 < p < 200 | Embedded (Lasso) | Good balance |
| 200 < p < 1000 | Filter → Embedded | Two-stage efficient |
| p > 1000 | Filter → Embedded → Wrapper | Three-stage necessary |
| p >> n | Lasso or Elastic Net | Handles high-dimensionality |

### Based on Goal

| Goal | Method | Rationale |
|------|--------|-----------|
| Maximum performance | Wrapper (GA or RFE) | Exhaustive search |
| Speed | Filter methods | No model fitting |
| Interpretability | Filter + manual review | Statistical tests explainable |
| Stability | Embedded (Lasso) | Regularization stable |
| Model-specific | Wrapper with target model | Optimized for deployment |

---

## Best Practices

### ✅ DO

1. **Use resampling**: Always evaluate within CV to prevent overfitting
2. **Multiple methods**: Cross-validate selections across methods
3. **Domain knowledge**: Incorporate expert input
4. **Stability analysis**: Check if features selected consistently across folds
5. **Test set validation**: Confirm selected features generalize
6. **Document process**: Record all methods and decisions

### ❌ DON'T

1. **Select on all data**: Use training data only
2. **Rely on single method**: Different methods may identify different features
3. **Ignore correlation**: Check selected features for redundancy
4. **Skip validation**: Must confirm on held-out data
5. **Over-select**: More features ≠ better model
6. **Forget computational cost**: Wrappers expensive for large p

---

## Practical Workflow

```r
library(tidymodels)

# 1. Initial data split
set.seed(123)
data_split <- initial_split(data, prop = 0.75, strata = outcome)
train <- training(data_split)
test <- testing(data_split)

# 2. Stage 1: Filter methods
filter_recipe <- recipe(outcome ~ ., data = train) |>
  step_nzv(all_predictors()) |>
  step_corr(all_numeric_predictors(), threshold = 0.90)

train_filtered <- prep(filter_recipe) |> bake(new_data = NULL)

# 3. Stage 2: Embedded method (Lasso)
lasso_wf <- workflow() |>
  add_recipe(recipe(outcome ~ ., data = train_filtered) |>
    step_normalize(all_predictors())) |>
  add_model(linear_reg(penalty = tune(), mixture = 1) |>
    set_engine("glmnet"))

lasso_tune <- tune_grid(lasso_wf, resamples = vfold_cv(train_filtered, v = 10))
best_lasso <- select_best(lasso_tune, metric = "rmse")
final_lasso <- finalize_workflow(lasso_wf, best_lasso) |> fit(train_filtered)

selected_vars <- extract_fit_engine(final_lasso) |>
  tidy() |>
  filter(estimate != 0, term != "(Intercept)") |>
  pull(term)

# 4. Stage 3: Wrapper method (RFE) - optional
train_embedded <- train |> select(outcome, all_of(selected_vars))

# 5. Final model with selected features
final_recipe <- recipe(outcome ~ ., data = train) |>
  step_select(all_of(selected_vars)) |>
  step_normalize(all_predictors())

final_wf <- workflow() |>
  add_recipe(final_recipe) |>
  add_model(linear_reg())

# 6. Evaluate on test set
final_fit <- last_fit(final_wf, data_split)
collect_metrics(final_fit)

# 7. Compare to baseline (all features)
baseline_wf <- workflow() |>
  add_recipe(recipe(outcome ~ ., data = train) |>
    step_normalize(all_predictors())) |>
  add_model(linear_reg())

baseline_fit <- last_fit(baseline_wf, data_split)
collect_metrics(baseline_fit)
```

---

## Resources

- **Book**: "Feature Engineering and Selection" - Chapters 10-12: https://feat.engineering/
- **caret RFE**: https://topepo.github.io/caret/recursive-feature-elimination.html
- **glmnet**: https://cran.r-project.org/package=glmnet
- **vip package**: https://cran.r-project.org/package=vip
- **GA package**: https://cran.r-project.org/package=GA
