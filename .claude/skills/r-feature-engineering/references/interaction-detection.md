# Interaction Detection Reference

Comprehensive guide to detecting and modeling interaction effects in R for machine learning.

## Overview

An interaction occurs when **"two or more predictors working in conjunction with each other"** produce combined effects that differ from their individual additive contributions.

**Mathematical Representation**:
```
y = β₀ + β₁x₁ + β₂x₂ + β₃x₁x₂ + error
```

where β₃ captures the incremental rate of change beyond individual predictor effects.

## Why Interactions Matter

### Practical Example: Agriculture

Consider water and fertilizer for corn crops. While either alone provides some benefit, **"sufficient water and sufficient fertilizer together produce yield greater than what either would produce alone."** This demonstrates synergistic interaction—the combined effect exceeds expectations.

### Four Interaction Types

| Type | Description | β₃ Coefficient | Pattern |
|------|-------------|----------------|---------|
| **Additive (None)** | No interaction present | ≈ 0 (not significant) | Parallel lines |
| **Antagonistic** | Combined effect less than expected | Significantly negative | Converging lines |
| **Synergistic** | Combined effect greater than expected | Significantly positive | Diverging lines |
| **Atypical** | Interaction without main effects | Significant, but main effects not | Crossing lines |

---

## Detection Methods

### Method 1: Nested Model Comparison

**Traditional Approach**: Compare two models using statistical tests.

**Models**:
- **Main effects model**: y = β₀ + β₁x₁ + β₂x₂ + error
- **Full model**: y = β₀ + β₁x₁ + β₂x₂ + β₃x₁x₂ + error

**Statistical Test**: P-value indicates whether interaction term provides information beyond chance (typically p < 0.05).

#### Enhanced Resampling Method

**Key Differences**:
- Uses separate assessment sets to prevent overfitting
- Allows any performance metric (not just statistical likelihood)
- Computes p-values through resampling rather than traditional statistics

**Implementation**:
```r
library(tidymodels)

# Create folds
cv_folds <- vfold_cv(train, v = 10, strata = outcome)

# Main effects model
main_recipe <- recipe(outcome ~ x1 + x2, data = train) |>
  step_normalize(all_numeric_predictors())

main_wf <- workflow() |>
  add_recipe(main_recipe) |>
  add_model(linear_reg())

main_cv <- fit_resamples(main_wf, resamples = cv_folds)

# Model with interaction
int_recipe <- recipe(outcome ~ x1 + x2, data = train) |>
  step_interact(~ x1:x2) |>
  step_normalize(all_numeric_predictors())

int_wf <- workflow() |>
  add_recipe(int_recipe) |>
  add_model(linear_reg())

int_cv <- fit_resamples(int_wf, resamples = cv_folds)

# Compare performance
collect_metrics(main_cv)
collect_metrics(int_cv)
```

**False Positive Control**: Apply **False Discovery Rate (FDR)** adjustments or **Bonferroni corrections** when evaluating many interaction terms.

```r
library(broom)

# After testing many interactions
interaction_pvals <- c(0.003, 0.045, 0.089, 0.12, 0.34)

# Bonferroni correction
p_bonferroni <- p.adjust(interaction_pvals, method = "bonferroni")

# FDR correction (less conservative)
p_fdr <- p.adjust(interaction_pvals, method = "fdr")
```

---

### Method 2: Penalized Regression

**When to Use**: Complete enumeration is feasible but models have more predictors than samples (p > n).

#### Ridge Regression

**Objective**: Minimize SSE_L₂ = Σ(yᵢ - ŷᵢ)² + λᵣΣβⱼ²

- Shrinks coefficients toward zero
- Doesn't force coefficients to exactly zero
- Handles multicollinearity well

#### LASSO (Least Absolute Shrinkage and Selection Operator)

**Objective**: Minimize SSE_L₁ = Σ(yᵢ - ŷᵢ)² + λₗΣ|βⱼ|

- Forces coefficients to exactly zero
- Performs automatic feature selection
- **Advantage**: Automatically selects among all interaction terms simultaneously

#### Elastic Net

**Objective**: Combines both penalties with parameters α and λ

**Implementation**:
```r
library(glmnet)

# Create all pairwise interactions
int_recipe <- recipe(outcome ~ ., data = train) |>
  step_interact(~ all_numeric_predictors():all_numeric_predictors()) |>
  step_interact(~ all_numeric_predictors():all_nominal_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors())

# Elastic net model
enet_spec <- linear_reg(penalty = tune(), mixture = tune()) |>
  set_engine("glmnet")

enet_wf <- workflow() |>
  add_recipe(int_recipe) |>
  add_model(enet_spec)

# Tune parameters
enet_tune <- tune_grid(
  enet_wf,
  resamples = vfold_cv(train, v = 10),
  grid = 20
)

# Best model
best_enet <- select_best(enet_tune, metric = "rmse")
final_enet <- finalize_workflow(enet_wf, best_enet)

enet_fit <- fit(final_enet, data = train)

# Extract non-zero coefficients
enet_coefs <- extract_fit_engine(enet_fit) |>
  tidy() |>
  filter(estimate != 0) |>
  arrange(desc(abs(estimate)))

# Show interaction terms
enet_coefs |>
  filter(str_detect(term, "_x_"))  # Interaction indicator
```

---

### Method 3: Two-Stage Modeling

**Purpose**: Reduce computational burden by filtering predictors first.

**Reduces search space from**: (p)(p-1)/2 pairwise terms → manageable subset

#### Stage 1: Identify Important Main Effects

```r
# Fit base model
lasso_recipe <- recipe(outcome ~ ., data = train) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors())

lasso_spec <- linear_reg(penalty = tune(), mixture = 1) |>
  set_engine("glmnet")

lasso_wf <- workflow() |>
  add_recipe(lasso_recipe) |>
  add_model(lasso_spec)

# Tune and fit
lasso_tune <- tune_grid(lasso_wf, resamples = vfold_cv(train, v = 10))
best_lasso <- select_best(lasso_tune, metric = "rmse")
final_lasso <- finalize_workflow(lasso_wf, best_lasso)
lasso_fit <- fit(final_lasso, data = train)

# Extract important predictors
lasso_coefs <- extract_fit_engine(lasso_fit) |>
  tidy() |>
  filter(estimate != 0, term != "(Intercept)")

important_vars <- lasso_coefs$term
```

#### Stage 2: Search Interactions Among Selected Predictors

```r
# Calculate residuals
train_with_resid <- train |>
  mutate(
    .pred = predict(lasso_fit, train)$.pred,
    .resid = outcome - .pred
  )

# Test interactions on residuals
interaction_candidates <- combn(important_vars, 2, simplify = FALSE)

resid_results <- map_dfr(interaction_candidates, function(pair) {
  int_recipe <- recipe(.resid ~ ., data = train_with_resid) |>
    step_interact(as.formula(paste("~", paste(pair, collapse = " * ")))) |>
    step_dummy(all_nominal_predictors()) |>
    step_normalize(all_numeric_predictors())

  int_wf <- workflow() |>
    add_recipe(int_recipe) |>
    add_model(linear_reg())

  cv_results <- fit_resamples(
    int_wf,
    resamples = vfold_cv(train_with_resid, v = 10)
  )

  collect_metrics(cv_results) |>
    filter(.metric == "rsq") |>
    mutate(interaction = paste(pair, collapse = " × "))
})

# Keep interactions explaining >1% of residual variance
significant_interactions <- resid_results |>
  filter(mean > 0.01) |>
  arrange(desc(mean))
```

#### Heredity Principles

**Strong Heredity**: Consider x₁×x₂ only if **both** main effects significant
**Weak Heredity**: Consider any interaction involving **at least one** significant predictor

```r
# Apply strong heredity
strong_heredity_pairs <- expand_grid(
  var1 = important_vars,
  var2 = important_vars
) |>
  filter(var1 < var2)  # Avoid duplicates

# Apply weak heredity (more liberal)
weak_heredity_pairs <- expand_grid(
  var1 = c(important_vars, other_vars),
  var2 = important_vars
) |>
  filter(var1 < var2)
```

---

### Method 4: Tree-Based Methods

**Why Trees Detect Interactions**: Recursive partitioning creates splits requiring information from multiple predictors; subsequent splits at different nodes implicitly model interactions.

#### Random Forest for Interaction Screening

```r
library(ranger)
library(vip)

# Fit random forest with importance
rf_spec <- rand_forest(trees = 1000) |>
  set_engine("ranger", importance = "permutation") |>
  set_mode("regression")

rf_recipe <- recipe(outcome ~ ., data = train) |>
  step_dummy(all_nominal_predictors())

rf_wf <- workflow() |>
  add_recipe(rf_recipe) |>
  add_model(rf_spec)

rf_fit <- fit(rf_wf, data = train)

# Extract importance
rf_importance <- extract_fit_parsnip(rf_fit) |>
  vip(num_features = 20)

# Top predictors
top_vars <- rf_importance$data |>
  slice_max(Importance, n = 10) |>
  pull(Variable)

# Test interactions among top predictors
top_interactions <- combn(top_vars, 2, simplify = FALSE)
```

**Advantages**:
- Random forests identify co-occurring features frequently selected together
- Gradient boosting and ensemble methods smooth pixelated tree predictions
- Can handle hundreds of predictors computationally

**Limitations**:
- Trees require many rectangular regions to approximate smooth, global interactions
- Less efficient than linear models for smooth interactions

#### Friedman & Popescu H-Statistic

**Purpose**: Quantify interaction strength in tree-based models.

**Interpretation**:
- H ≈ 0 indicates no interaction
- Larger H values suggest interaction presence

```r
library(iml)

# Create predictor object
predictor <- Predictor$new(
  model = extract_fit_engine(rf_fit),
  data = train |> select(-outcome),
  y = train$outcome
)

# Calculate H-statistic for specific pair
h_stat <- Interaction$new(predictor, feature = c("x1", "x2"))
h_stat$results
```

---

### Method 5: Feasible Solution Algorithm (FSA)

**Purpose**: Iterative substitution algorithm for optimal predictor subset selection, extended to interactions.

**Search Space Efficiency**: O(q × m × p) vs O(p^m) for exhaustive search
- q = number of random starts
- m = subset size
- p = number of predictors

#### FSA Process

1. Randomly select candidate interaction pair
2. Fix first predictor, systematically replace second with remaining candidates
3. Calculate performance; keep best or exchange if improvement found
4. Fix second predictor, optimize first predictor
5. Iterate until convergence
6. Repeat from different random starts; tally converged solutions

**Implementation** (conceptual):
```r
library(GA)

# Fitness function for genetic algorithm
fitness_function <- function(chromosome) {
  selected_idx <- which(chromosome == 1)

  if (length(selected_idx) < 2) return(-Inf)

  # Create interactions for selected predictors
  selected_vars <- all_predictors[selected_idx]

  int_recipe <- recipe(outcome ~ ., data = train) |>
    step_select(all_of(selected_vars)) |>
    step_interact(~ all_predictors():all_predictors()) |>
    step_normalize(all_numeric_predictors())

  int_wf <- workflow() |>
    add_recipe(int_recipe) |>
    add_model(linear_reg())

  cv_results <- fit_resamples(
    int_wf,
    resamples = vfold_cv(train, v = 5)
  )

  mean(collect_metrics(cv_results)$mean)
}

# Run genetic algorithm
ga_results <- ga(
  type = "binary",
  fitness = fitness_function,
  nBits = length(all_predictors),
  popSize = 50,
  maxiter = 100,
  run = 20
)

# Extract best solution
best_predictors <- all_predictors[which(ga_results@solution[1, ] == 1)]
```

**Constraint Options**: Can prevent pairing dummy variables from same categorical predictor for interpretability.

---

## Critical Implementation Details

### Preprocessing Timing Issue

**⚠️ CRITICAL FINDING**: Create interaction terms **BEFORE** preprocessing individual predictors.

**Why**: When preprocessing occurs first (centering, scaling, transformation), the interactive signal becomes **"almost completely lost."** Preprocessing after interaction creation preserves the signal because **"interactions are most plausible on original scales of measurement."**

```r
# ✅ CORRECT ORDER
recipe(outcome ~ ., data = train) |>
  step_interact(~ x1:x2) |>              # Create interactions FIRST
  step_normalize(all_numeric_predictors()) |>  # Then preprocess
  step_dummy(all_nominal_predictors())

# ❌ WRONG ORDER
recipe(outcome ~ ., data = train) |>
  step_normalize(all_numeric_predictors()) |>  # Preprocessing first
  step_interact(~ x1:x2) |>              # Interaction signal lost!
  step_dummy(all_nominal_predictors())
```

### Resampling for Overfitting Prevention

Use cross-validation or bootstrap resampling to:
- Generate model pairs on different training sets
- Evaluate interaction contribution on held-out assessment sets
- Reduce false positive findings from overfitting

```r
# Always use resampling for interaction evaluation
cv_folds <- vfold_cv(train, v = 10, strata = outcome)

# NOT just training set performance
fit_resamples(workflow, resamples = cv_folds)
```

### Computational Feasibility

**Complete enumeration manageable when**: p ≤ 100 (yields ~4,950 pairwise terms)

**Complete enumeration impractical when**: p ≥ 500 (yields ~125,000 pairwise terms)

**Guiding Principles**:

1. **Hierarchy**: Screen pairwise before three-way interactions (higher-order terms explain less variation)
2. **Sparsity**: Only few interactions truly important; many are false positives
3. **Heredity (Strong)**: Consider x₁×x₂ only if both main effects significant
4. **Heredity (Weak)**: Consider any interaction involving significant predictors

---

## Best Practices

### Preventing Overfitting

✅ **DO**:
- Use multiple p-value adjustment methods (FDR, Bonferroni)
- Apply resampling/cross-validation rather than in-sample evaluation
- Evaluate interactions within full model containing all relevant main effects
- Require statistical significance **AND** practical meaningfulness
- Create interactions before preprocessing predictors
- Document all tested interactions for transparency

❌ **DON'T**:
- Test interactions on training data without resampling
- Ignore main effects when including interactions
- Add too many interactions without validation
- Skip preprocessing timing consideration
- Cherry-pick interactions based on in-sample performance

### Method Selection Framework

| Scenario | Recommended Method | Rationale |
|----------|-------------------|-----------|
| Small p, expert knowledge available | Expert-guided nested models | Leverage domain expertise |
| Small p, exploratory mode | Simple screening with FDR | Systematic, interpretable |
| Small p, max interpretability | Penalized regression (LASSO) | Automatic selection |
| Medium p (100s) | Two-stage: filter + screening | Computational efficiency |
| Large p (1000s+) | Tree-based importance + top interactions | Handles scale |
| Need global/local interactions | Cubist rule-based models | Embedded linear terms |
| p > n scenario | Elastic net with all interactions | Regularization handles dimensionality |

### Domain Knowledge Integration

**Always begin by identifying** "interactions that are most likely to influence the response variable in important ways" through expert consultation.

Algorithmic approaches should **complement, not replace**, domain expertise.

**Workflow**:
1. List hypothesized interactions from domain experts
2. Test hypothesized interactions first
3. Use algorithmic search for exploratory discovery
4. Validate discovered interactions with experts
5. Combine confirmed interactions in final model

### Post-Detection Validation

After identifying candidate interactions:

**Visual Exploration**:
```r
# Scatter plot by groups
ggplot(data, aes(x = x1, y = outcome, color = x2_group)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Interaction: x1 × x2")

# Contour plot for numeric × numeric
ggplot(data, aes(x = x1, y = x2, z = outcome)) +
  stat_contour() +
  labs(title = "Interaction Surface")
```

**Practical Significance Assessment**:
- Beyond statistical significance (p < 0.05)
- Assess effect size and business impact
- Consider interpretability vs complexity tradeoff

**Effect Heterogeneity Examination**:
```r
# Different slopes across groups
lm(outcome ~ x1 * group, data = data) |>
  tidy() |>
  filter(str_detect(term, ":"))
```

### Model Comparison Metrics

Different objective functions answer different questions:

| Metric Type | Optimizes | Use When |
|-------------|-----------|----------|
| Likelihood-based (AIC, BIC) | Model calibration | Probability estimates matter |
| Accuracy-based (RMSE, MAE) | Prediction error | Point predictions matter |
| Domain-specific (Sensitivity, Specificity) | Business objectives | Specific costs/benefits |

**Important**: Different metrics may yield different interaction selections; choose based on application requirements.

---

## Complete Workflow Example

```r
library(tidymodels)

# Step 1: Hypothesize interactions from domain knowledge
hypothesized_ints <- list(
  c("price", "location"),
  c("size", "location"),
  c("age", "condition")
)

# Step 2: Test hypothesized interactions
test_interaction <- function(pair) {
  int_recipe <- recipe(value ~ ., data = train) |>
    step_interact(as.formula(paste("~", paste(pair, collapse = ":")) )) |>
    step_normalize(all_numeric_predictors()) |>
    step_dummy(all_nominal_predictors())

  int_wf <- workflow() |>
    add_recipe(int_recipe) |>
    add_model(linear_reg())

  fit_resamples(int_wf, resamples = vfold_cv(train, v = 10))
}

hypothesis_results <- map_dfr(hypothesized_ints, ~{
  collect_metrics(test_interaction(.x)) |>
    mutate(interaction = paste(.x, collapse = " × "))
})

# Step 3: Use RF to screen for additional interactions
rf_spec <- rand_forest(trees = 1000) |>
  set_engine("ranger", importance = "permutation") |>
  set_mode("regression")

rf_fit <- fit(rf_spec, value ~ ., data = train)

top_vars <- vip(rf_fit, num_features = 8)$data |>
  pull(Variable)

# Step 4: Test interactions among top predictors
exploratory_ints <- combn(top_vars, 2, simplify = FALSE)

exploratory_results <- map_dfr(exploratory_ints, ~{
  collect_metrics(test_interaction(.x)) |>
    mutate(interaction = paste(.x, collapse = " × "))
})

# Step 5: Select best interactions with FDR correction
all_results <- bind_rows(
  hypothesis_results |> mutate(source = "hypothesis"),
  exploratory_results |> mutate(source = "exploratory")
)

# Step 6: Build final model with validated interactions
final_recipe <- recipe(value ~ ., data = train) |>
  step_interact(~ price:location) |>
  step_interact(~ size:location) |>
  step_normalize(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors())

final_wf <- workflow() |>
  add_recipe(final_recipe) |>
  add_model(linear_reg())

# Step 7: Evaluate on test set
final_fit <- last_fit(final_wf, split)
collect_metrics(final_fit)
```

---

## Resources

- **Book**: "Feature Engineering and Selection" - Chapter 7: https://feat.engineering/07-Detecting_Interaction_Effects.html
- **tidymodels**: https://www.tidymodels.org/
- **step_interact()**: https://recipes.tidymodels.org/reference/step_interact.html
- **glmnet package**: https://cran.r-project.org/package=glmnet
- **iml package** (H-statistic): https://cran.r-project.org/package=iml
