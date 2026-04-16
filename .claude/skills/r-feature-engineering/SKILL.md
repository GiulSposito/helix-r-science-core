---
name: r-feature-engineering
description: Advanced feature engineering and selection strategies in R. Use when mentions "feature engineering strategies", "feature selection", "categorical encoding methods", "likelihood encoding", "target encoding", "entity embeddings", "feature hashing", "interaction detection", "systematic feature selection", "wrapper methods", "filter methods", "greedy search", "global search", "genetic algorithms", "Box-Cox transformation", "quando usar cada encoding", "when to use each encoding", "escolher método de encoding", "choose encoding method", "detectar interações", "detect interactions", "selecionar features", "select features", "feature selection methods", "escolher entre encodings", "compare encoding methods", "which encoding to use", "qual encoding usar", or discusses strategic decisions about preprocessing beyond basic recipe implementation.
version: 1.0.0
user-invocable: false
allowed-tools: Read, Write, Edit, Bash(Rscript *), Bash(R *), WebFetch
---

# R Feature Engineering - Strategic Decisions and Selection

Expert guidance for making strategic decisions about feature engineering and selection in R, based on "Feature Engineering and Selection: A Practical Approach for Predictive Models" by Max Kuhn and Kjell Johnson.

## Overview

This skill provides **strategic guidance** for feature engineering decisions - helping you understand **when and why** to use specific techniques, not just how to implement them. While `r-tidymodels` focuses on workflow execution, this skill helps you make informed decisions about:

- **Encoding strategies** - Choosing the right categorical encoding method
- **Transformation approaches** - Selecting appropriate numeric transformations
- **Interaction detection** - Systematically finding interaction effects
- **Feature selection** - Comparing filter, wrapper, and embedded methods
- **Missing data strategies** - Choosing imputation approaches

## When This Skill Activates

Use this skill when you need to:
- **Compare approaches**: "Should I use dummy encoding or likelihood encoding?"
- **Make strategic decisions**: "What's the best feature selection method for my problem?"
- **Understand trade-offs**: "When should I use Box-Cox vs Yeo-Johnson?"
- **Detect patterns**: "How do I systematically find interactions?"
- **Handle complexity**: "How to deal with high-cardinality categorical variables?"

**NOT for**:
- Basic recipe implementation → Use `r-tidymodels`
- Data wrangling → Use `r-datascience` or `tidyverse-expert`
- General ML workflow → Use `r-tidymodels`

## Core Philosophy

1. **Re-representation First** - Better features often beat better models
2. **Domain Knowledge Matters** - Statistical methods guide, but domain expertise decides
3. **Validate Everything** - All feature engineering must happen inside resampling
4. **Interpretability vs Performance** - Understand the trade-off for your use case
5. **Prevent Data Leakage** - Derive all parameters from training data only

## Categorical Encoding Strategies

### Decision Framework: Which Encoding to Use?

```r
# Decision tree for categorical encoding
choose_encoding <- function(n_levels, n_obs, has_outcome, ordinal) {
  if (ordinal) return("step_ordinalscore()")

  if (n_levels < 10) {
    return("step_dummy() # Simple and interpretable")
  }

  if (n_levels <= 50) {
    if (n_obs < 1000 && has_outcome) {
      return("embed::step_lencode_mixed() # Supervised encoding")
    } else {
      return("step_dummy() or step_other() |> step_dummy()")
    }
  }

  if (n_levels > 50) {
    if (n_obs < 1000 && has_outcome) {
      return("embed::step_embed() # Entity embeddings")
    } else {
      return("textrecipes::step_texthash() # Feature hashing")
    }
  }
}
```

### Method Comparison

| Method | Best For | Pros | Cons | Package |
|--------|----------|------|------|---------|
| **Dummy/One-hot** | Low cardinality (<10 levels) | Simple, interpretable | Many features, loses rare levels | `recipes` |
| **Ordinal** | Ordered categories | Preserves order, compact | Assumes equal spacing | `recipes` |
| **Target/Likelihood** | Medium cardinality (10-50) | Captures outcome relationship | Overfitting risk, needs CV | `embed` |
| **Entity Embeddings** | High cardinality + small data | Learns relationships, compact | Complex, black box | `embed` |
| **Feature Hashing** | Very high cardinality (>100) | Fixed dimensions, handles novel | Collisions, not interpretable | `textrecipes` |

### Detailed Encoding Approaches

See [references/categorical-encoding.md](references/categorical-encoding.md) for:
- Step-by-step implementation of each method
- When to use supervised vs unsupervised encoding
- Handling novel categories in production
- Preventing data leakage with proper CV
- Case studies and comparisons

## Numeric Transformation Strategies

### Transformation Decision Tree

```r
# When to transform numeric predictors
needs_transformation <- function(predictor, model_type) {
  # Tree-based models don't need transformations
  if (model_type %in% c("random_forest", "xgboost", "decision_tree")) {
    return("No transformation needed - tree models are scale-invariant")
  }

  # Distance-based and linear models benefit
  skewness <- e1071::skewness(predictor)

  if (abs(skewness) < 0.5) {
    return("step_normalize() # Mild skewness, just standardize")
  }

  if (all(predictor > 0) && skewness > 1) {
    return("step_log() or step_BoxCox() # Right-skewed, positive values")
  }

  if (any(predictor <= 0) && abs(skewness) > 1) {
    return("step_YeoJohnson() # Skewed with zero/negative values")
  }

  return("step_normalize() # Default standardization")
}
```

### Transformation Catalog

| Transformation | When to Use | Model Sensitivity | Key Considerations |
|----------------|-------------|-------------------|-------------------|
| **Box-Cox** | Right-skewed, positive only | Linear, SVM, KNN | Estimates λ parameter automatically |
| **Yeo-Johnson** | Any skewness, any values | Linear, SVM, KNN | Box-Cox extension for ≤0 values |
| **Log** | Multiplicative relationships | Linear, SVM, KNN | Add offset for zeros: `step_log(x, offset=1)` |
| **Sqrt** | Count data, moderate skew | Linear regression | Milder than log |
| **Standardize** | Different scales | SVM, KNN, penalized | Essential for distance-based models |
| **Splines** | Non-linear relationships | Linear models | Adds flexibility: `step_ns(x, deg_free=4)` |
| **Polynomials** | Smooth curves | Linear models | Risk of overfitting: use sparingly |

### When NOT to Transform

```r
# Models that DON'T benefit from transformations
no_transform_needed <- c(
  "random_forest",    # Split-based, scale-invariant
  "xgboost",          # Handles skewness naturally
  "decision_tree",    # Works on order only
  "naive_bayes"       # Uses distributions directly
)

# Models that REQUIRE transformations
transform_required <- c(
  "linear_reg",       # Assumes normality
  "logistic_reg",     # Benefits from standardization
  "svm_*",            # Distance-based, scale-sensitive
  "nearest_neighbor", # Euclidean distance
  "glmnet"            # Penalization scale-dependent
)
```

See [references/numeric-transformations.md](references/numeric-transformations.md) for:
- Detailed transformation techniques (1:1, 1:many, many:many)
- Basis expansions and splines
- Discretization strategies (use as last resort!)
- PCA and dimensionality reduction trade-offs

## Detecting Interaction Effects

### Why Interactions Matter

Interactions occur when the effect of one predictor depends on the value of another. Example:
- Effect of fertilizer depends on water availability
- Impact of age depends on education level
- Drug effectiveness depends on patient genetics

### Systematic Detection Methods

```r
# Method selection based on problem size
select_interaction_method <- function(n_predictors, n_obs) {
  if (n_predictors < 20) {
    return("Simple screening with nested models (exhaustive)")
  }

  if (n_predictors <= 50 && n_obs > 1000) {
    return("Random forest importance + interaction screening")
  }

  if (n_predictors > 50) {
    return("Two-stage: Lasso main effects → FSA for interactions")
  }

  if (n_obs / n_predictors < 10) {
    return("Penalized regression (glmnet) with all interactions")
  }
}
```

### Four Detection Approaches

**1. Simple Screening (Small p)**
```r
# Exhaustive search with proper CV
library(tidymodels)

# Test all pairwise interactions
interactions <- combn(predictors, 2, simplify = FALSE)

results <- map_dfr(interactions, function(pair) {
  formula <- as.formula(paste("outcome ~", paste(pair, collapse = " * ")))

  # Use resampling to avoid overfitting
  cv_results <- fit_resamples(
    workflow() |>
      add_formula(formula) |>
      add_model(linear_reg()),
    resamples = vfold_cv(train, v = 10)
  )

  collect_metrics(cv_results)
})
```

**2. Random Forest Importance**
```r
# Use RF to identify important main effects, then test interactions
library(vip)

rf_fit <- rand_forest(trees = 1000) |>
  set_engine("ranger", importance = "permutation") |>
  fit(outcome ~ ., data = train)

# Get top predictors
top_vars <- vip(rf_fit, num_features = 10)$data$Variable

# Test interactions among top predictors only
interactions_to_test <- combn(top_vars, 2, simplify = FALSE)
```

**3. Two-Stage Modeling**
```r
# Stage 1: Fit main effects model
main_effects <- linear_reg(penalty = 0.01, mixture = 1) |>
  set_engine("glmnet") |>
  fit(outcome ~ ., data = train)

# Stage 2: Look for interactions in residuals
train_with_resid <- train |>
  mutate(residual = outcome - predict(main_effects, train)$.pred)

# Now search for interactions that explain residuals
interaction_model <- fit(
  outcome ~ . + (age * income) + (education * experience),
  data = train_with_resid
)
```

**4. Feasible Solution Algorithm (FSA)**
```r
# For very high-dimensional problems
# Iteratively substitute predictor combinations
# See references/interaction-detection.md for implementation
```

See [references/interaction-detection.md](references/interaction-detection.md) for:
- Detailed implementation of each method
- When to use each approach
- Preventing overfitting in interaction search
- Real-world case studies

## Feature Selection Strategies

### Selection Method Taxonomy

```
Feature Selection
├── Filter Methods (Univariate)
│   ├── Correlation with outcome
│   ├── Statistical tests (t-test, chi-square)
│   └── Information gain / mutual information
├── Wrapper Methods (Model-based)
│   ├── Greedy Search
│   │   ├── Forward selection
│   │   ├── Backward elimination
│   │   └── Recursive Feature Elimination (RFE)
│   └── Global Search
│       ├── Genetic algorithms
│       ├── Simulated annealing
│       └── Particle swarm
└── Embedded Methods (During training)
    ├── Lasso (L1 penalty)
    ├── Elastic net
    └── Tree-based importance
```

### Decision Framework

```r
select_feature_method <- function(n_features, n_obs, need_optimal, compute_budget) {
  # Filter methods: Fast preprocessing
  if (n_features > 1000) {
    return("Filter methods first to reduce to <100 features")
  }

  # Embedded methods: Fast and effective
  if (compute_budget == "low" || n_features > 50) {
    return("Lasso or elastic net (embedded)")
  }

  # Wrapper methods: Best performance
  if (need_optimal && compute_budget == "high" && n_features < 50) {
    if (n_features < 20) {
      return("Recursive Feature Elimination (RFE)")
    } else {
      return("Genetic algorithm for global optimum")
    }
  }

  return("Hybrid: Filter → Lasso → RFE")
}
```

### Method Comparison

| Method | Speed | Quality | Best For | Implementation |
|--------|-------|---------|----------|----------------|
| **Filter** | ⚡⚡⚡ | ⭐⭐ | Initial screening (1000s of features) | `step_corr()`, `step_zv()` |
| **Lasso** | ⚡⚡ | ⭐⭐⭐ | 50-500 features, automatic | `glmnet`, `step_lasso()` |
| **RFE** | ⚡ | ⭐⭐⭐⭐ | <50 features, interpretability | `caret::rfe()` |
| **Genetic** | 🐌 | ⭐⭐⭐⭐⭐ | <30 features, optimal subset | `GA::ga()` |

### Greedy Search Methods

```r
# Forward Selection
library(caret)

ctrl <- rfeControl(
  functions = lmFuncs,  # or rfFuncs, nbFuncs
  method = "cv",
  number = 10
)

# Recursive Feature Elimination
rfe_results <- rfe(
  x = train[, predictors],
  y = train$outcome,
  sizes = c(5, 10, 15, 20, 25),
  rfeControl = ctrl
)

# Best subset
predictors(rfe_results)  # Selected features
```

### Global Search Methods

```r
# Genetic Algorithm for feature selection
library(GA)

# Fitness function: CV performance with selected features
fitness <- function(chromosome) {
  selected <- which(chromosome == 1)
  if (length(selected) == 0) return(0)

  # Fit model with selected features
  cv_results <- vfold_cv(train, v = 5) |>
    mutate(
      model = map(splits, ~{
        fit(linear_reg(), outcome ~ .,
            data = analysis(.x)[, c(selected, "outcome")])
      }),
      pred = map2(model, splits, ~predict(.x, assessment(.y))),
      truth = map(splits, ~assessment(.x)$outcome)
    )

  # Return negative RMSE (GA maximizes)
  -mean(map2_dbl(cv_results$pred, cv_results$truth,
                 ~sqrt(mean((.x$.pred - .y)^2))))
}

# Run GA
ga_result <- ga(
  type = "binary",
  fitness = fitness,
  nBits = ncol(train) - 1,  # One bit per predictor
  maxiter = 50,
  popSize = 20
)
```

See [references/feature-selection.md](references/feature-selection.md) for:
- Complete greedy search implementations
- Global search algorithms (SA, PSO)
- Hybrid strategies
- Computational considerations
- Case studies with performance comparisons

## Missing Data Strategies

### Is Missingness Informative?

```r
# Test if missingness predicts outcome
library(naniar)

# Create missingness indicators
data_with_miss <- train |>
  bind_shadow() |>  # Adds *_NA columns
  mutate(across(ends_with("_NA"), ~if_else(.x == "!NA", 1, 0)))

# Test association
miss_importance <- rand_forest() |>
  fit(outcome ~ ., data = select(data_with_miss, outcome, ends_with("_NA"))) |>
  vip::vip()

# If missingness indicators are important → keep them!
```

### Strategy Selection

```r
# Decision tree for missing data
handle_missing <- function(var, mechanism, importance) {
  if (mechanism == "MCAR" && importance == "low") {
    return("step_impute_median() # Simple imputation")
  }

  if (mechanism == "MAR") {
    return("step_impute_knn() or step_impute_bag() # Model-based")
  }

  if (importance == "high" || mechanism == "MNAR") {
    return("step_indicate_na() + imputation # Preserve signal")
  }
}
```

### Missing Data Mechanisms

| Mechanism | Definition | Example | Strategy |
|-----------|------------|---------|----------|
| **MCAR** | Missing Completely At Random | Random sensor failures | Simple imputation OK |
| **MAR** | Missing At Random (given observed) | Income missing for unemployed | Model-based imputation |
| **MNAR** | Missing Not At Random | High earners hide income | Indicator + imputation |

### Imputation Methods

```r
# 1. Simple imputation (MCAR)
recipe(outcome ~ ., data = train) |>
  step_impute_median(all_numeric_predictors()) |>
  step_impute_mode(all_nominal_predictors())

# 2. Model-based imputation (MAR)
recipe(outcome ~ ., data = train) |>
  step_impute_knn(all_predictors(), neighbors = 5) |>
  # or
  step_impute_bag(all_predictors(), trees = 25)

# 3. Preserve missingness signal (MNAR)
recipe(outcome ~ ., data = train) |>
  step_indicate_na(all_predictors(), prefix = "missing_") |>
  step_impute_median(all_numeric_predictors())
```

See [references/missing-data-strategies.md](references/missing-data-strategies.md) for:
- Diagnosing missing data mechanisms
- Advanced imputation techniques
- Multiple imputation
- Validation strategies

## Complete Feature Engineering Workflow

### Recommended Order

```r
# Comprehensive feature engineering recipe
fe_recipe <- recipe(outcome ~ ., data = train) |>

  # 0. ROLE ASSIGNMENT
  update_role(id, new_role = "ID") |>

  # 1. MISSING DATA (if informative)
  step_indicate_na(all_predictors(), prefix = "missing_") |>
  step_impute_knn(all_numeric_predictors(), neighbors = 5) |>
  step_impute_mode(all_nominal_predictors()) |>

  # 2. FEATURE CREATION (before transformations)
  step_mutate(
    age_squared = age^2,
    income_per_person = income / household_size
  ) |>

  # 3. INTERACTION DETECTION (from previous analysis)
  step_interact(~ age:education + income:experience) |>

  # 4. NUMERIC TRANSFORMATIONS
  step_YeoJohnson(all_numeric_predictors()) |>

  # 5. CATEGORICAL ENCODING (choose method strategically)
  step_novel(all_nominal_predictors()) |>
  step_other(all_nominal_predictors(), threshold = 0.05) |>
  embed::step_lencode_mixed(high_cardinality_var, outcome = vars(outcome)) |>
  step_dummy(remaining_nominal_predictors()) |>

  # 6. STANDARDIZATION (after encoding)
  step_normalize(all_numeric_predictors()) |>

  # 7. FEATURE SELECTION
  step_zv(all_predictors()) |>
  step_corr(all_numeric_predictors(), threshold = 0.9) |>

  # 8. DIMENSIONALITY REDUCTION (if needed)
  step_pca(all_numeric_predictors(), threshold = 0.95)
```

## Quick Reference: When to Use What

### By Problem Type

**High-dimensional (p > n)**
- Filter methods → Lasso → validate

**Small sample (n < 500)**
- Be conservative with interactions
- Use penalized methods
- Validate rigorously

**High-cardinality categoricals**
- Target encoding or embeddings
- Feature hashing for very high

**Imbalanced classes**
- Consider interaction with class
- SMOTE before encoding

**Time series / sequential**
- Lag features
- Rolling statistics
- Seasonality indicators

### By Model Type

**Linear models**
- Transform skewed predictors
- Standardize all numerics
- Consider splines for non-linearity

**Tree-based**
- Skip transformations
- Keep original scale
- Ordinal encoding OK

**Neural networks**
- Normalize to [0,1] or [-1,1]
- Consider embeddings for categoricals
- Interaction layers in architecture

**SVM / KNN**
- Standardization REQUIRED
- Remove correlations
- Consider PCA

## Validation Best Practices

### Preventing Data Leakage

```r
# ❌ WRONG: Fit recipe on all data
rec_wrong <- recipe(outcome ~ ., data = all_data) |>
  step_normalize(all_numeric()) |>
  prep()

split <- initial_split(all_data)
train <- bake(rec_wrong, training(split))  # LEAKAGE!
test <- bake(rec_wrong, testing(split))

# ✅ CORRECT: Fit recipe only on training
split <- initial_split(all_data)

rec_correct <- recipe(outcome ~ ., data = training(split)) |>
  step_normalize(all_numeric()) |>
  prep(training = training(split))

train <- bake(rec_correct, new_data = NULL)  # Training data
test <- bake(rec_correct, new_data = testing(split))  # Test data
```

### Cross-Validation for Feature Engineering

```r
# All feature engineering inside CV
library(tidymodels)

# Recipe is NOT prepped outside CV
fe_recipe <- recipe(outcome ~ ., data = train) |>
  step_impute_knn(all_predictors()) |>
  step_normalize(all_numeric_predictors())

# Workflow bundles recipe + model
wf <- workflow() |>
  add_recipe(fe_recipe) |>  # Unprepped recipe
  add_model(linear_reg())

# CV fits recipe on each analysis set separately
cv_results <- fit_resamples(
  wf,
  resamples = vfold_cv(train, v = 10),
  metrics = metric_set(rmse, rsq)
)

# Collect honest performance estimates
collect_metrics(cv_results)
```

## Supporting Files

### Detailed References
- **Categorical encoding**: [references/categorical-encoding.md](references/categorical-encoding.md)
- **Numeric transformations**: [references/numeric-transformations.md](references/numeric-transformations.md)
- **Interaction detection**: [references/interaction-detection.md](references/interaction-detection.md)
- **Missing data strategies**: [references/missing-data-strategies.md](references/missing-data-strategies.md)
- **Feature selection methods**: [references/feature-selection.md](references/feature-selection.md)

### Examples
- **Encoding comparison**: [examples/encoding-comparison.md](examples/encoding-comparison.md)
- **Interaction workflow**: [examples/interaction-workflow.md](examples/interaction-workflow.md)
- **Selection pipeline**: [examples/selection-pipeline.md](examples/selection-pipeline.md)

### Templates
- **Feature engineering checklist**: [templates/feature-engineering-checklist.md](templates/feature-engineering-checklist.md)

## Resources

### Primary Source
**"Feature Engineering and Selection: A Practical Approach for Predictive Models"**
- Authors: Max Kuhn & Kjell Johnson
- Website: https://feat.engineering/
- GitHub: https://github.com/topepo/FES
- License: Creative Commons (freely available)

### Related Documentation
- [tidymodels.org](https://www.tidymodels.org/) - Official tidymodels documentation
- [recipes package](https://recipes.tidymodels.org/) - Feature engineering reference
- [embed package](https://embed.tidymodels.org/) - Advanced encoding methods

## Relationship to Other Skills

**Use this skill (`r-feature-engineering`) for**:
- Strategic decisions about encoding methods
- Choosing transformation approaches
- Systematic interaction detection
- Feature selection strategy

**Use `r-tidymodels` for**:
- Implementing recipes and workflows
- Hyperparameter tuning
- Model comparison and selection
- Production deployment

**Use `r-datascience` for**:
- Exploratory data analysis
- Data wrangling and cleaning
- General ML workflow overview

**Use `tidyverse-expert` for**:
- dplyr data manipulation
- tidyr reshaping
- General data transformation
