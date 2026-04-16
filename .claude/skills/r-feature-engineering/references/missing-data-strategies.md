# Missing Data Strategies Reference

Comprehensive guide to understanding, diagnosing, and handling missing data in R for machine learning.

## Overview

Missing data is ubiquitous in real-world datasets and requires thoughtful handling to preserve statistical validity and model performance. Poor missing data strategies can lead to:
- Biased estimates
- Reduced statistical power
- Invalid inferences
- Poor generalization

**Key Principle**: The approach depends on the **missing data mechanism**.

---

## Missing Data Mechanisms

Understanding WHY data is missing is crucial for choosing appropriate handling methods.

### 1. Missing Completely At Random (MCAR)

**Definition**: Missingness is independent of both observed and unobserved data.

**Example**: A laboratory instrument randomly fails to record measurements.

**Characteristics**:
- No systematic pattern to missingness
- Missing cases are a random sample of all cases
- Complete case analysis is unbiased (but inefficient)

**Test for MCAR**:
```r
library(naniar)

# Visual test: missingness patterns
gg_miss_upset(data, nsets = 10)

# Little's MCAR test
library(missMethods)
mcar_test <- mcar_test(data)
mcar_test$p.value  # p > 0.05 suggests MCAR
```

**Impact**: Least problematic mechanism - complete case analysis valid but loses information.

---

### 2. Missing At Random (MAR)

**Definition**: Missingness depends on observed data, but not on the missing values themselves.

**Example**: Younger survey respondents less likely to report income, but among those who do report, values unrelated to reporting probability.

**Characteristics**:
- Missingness related to other observed variables
- Can be modeled and corrected using available information
- Most common assumption in practice

**Identification**:
```r
# Check if missingness correlates with other variables
miss_var_summary <- data |>
  mutate(income_missing = is.na(income)) |>
  group_by(income_missing) |>
  summarise(across(everything(), mean, na.rm = TRUE))

# Logistic regression to predict missingness
missing_model <- glm(
  is.na(income) ~ age + education + gender,
  data = data,
  family = binomial
)

summary(missing_model)  # Significant predictors indicate MAR
```

**Impact**: Moderate concern - requires modeling missingness mechanism for valid inference.

---

### 3. Missing Not At Random (MNAR)

**Definition**: Missingness depends on the unobserved values themselves.

**Example**: High-income individuals less likely to report income precisely because it's high.

**Characteristics**:
- Missingness related to the missing value
- Cannot be corrected using observed data alone
- Requires sensitivity analysis or domain knowledge

**Detection**:
```r
# MNAR is difficult to detect statistically
# Requires domain knowledge and sensitivity analysis

# Pattern analysis may provide clues
library(naniar)
gg_miss_fct(data, fct = income_category)

# Compare imputed values to observed in similar cases
# If systematic differences exist, suspect MNAR
```

**Impact**: Most problematic - standard approaches may produce biased results.

---

## Diagnostic Tools

### Visualizing Missing Data Patterns

```r
library(naniar)
library(ggplot2)

# Overall missingness summary
miss_var_summary(data)

# Visualize missingness patterns
vis_miss(data, cluster = TRUE)

# Missingness by variable
gg_miss_var(data, show_pct = TRUE)

# Upset plot: combinations of missingness
gg_miss_upset(data, nsets = 10)

# Missingness across categorical variable
gg_miss_fct(data, fct = category)

# Correlation of missingness between variables
gg_miss_which(data)
```

### Quantifying Missingness

```r
library(naniar)

# Summary statistics
miss_summary <- data |>
  summarise(
    n_miss = n_miss(),
    pct_miss = pct_miss(),
    n_complete = n_complete(),
    pct_complete = pct_complete()
  )

# By variable
miss_var_summary(data) |>
  arrange(desc(n_miss))

# By observation
miss_case_summary(data) |>
  arrange(desc(n_miss))

# Missingness table
miss_var_table(data)
```

---

## Handling Strategies

### 1. Complete Case Analysis (Listwise Deletion)

**Approach**: Remove any observation with one or more missing values.

**Implementation**:
```r
# Base R
complete_data <- na.omit(data)

# tidyverse
complete_data <- data |>
  drop_na()

# Specific columns
complete_data <- data |>
  drop_na(income, age, education)
```

**When to Use**:
- MCAR mechanism confirmed
- Small proportion of missingness (<5%)
- Large sample size remains after deletion

**Advantages**:
- ✅ Simple and fast
- ✅ No modeling assumptions
- ✅ Unbiased under MCAR

**Disadvantages**:
- ❌ Loses information
- ❌ Reduces statistical power
- ❌ Biased under MAR/MNAR
- ❌ Can't make predictions for new incomplete cases

---

### 2. Simple Imputation

Replace missing values with a single statistic.

#### Mean/Median/Mode Imputation

```r
library(recipes)

# Mean imputation for numeric
impute_recipe <- recipe(outcome ~ ., data = train) |>
  step_impute_mean(all_numeric_predictors())

# Median imputation (more robust to outliers)
impute_recipe <- recipe(outcome ~ ., data = train) |>
  step_impute_median(all_numeric_predictors())

# Mode imputation for categorical
impute_recipe <- recipe(outcome ~ ., data = train) |>
  step_impute_mode(all_nominal_predictors())
```

**When to Use**:
- MCAR mechanism
- Low missingness (<5%)
- Quick baseline needed

**Advantages**:
- ✅ Fast and simple
- ✅ Preserves sample size
- ✅ Can make predictions on new data

**Disadvantages**:
- ❌ Underestimates variance
- ❌ Distorts distributions
- ❌ Ignores relationships between variables
- ❌ Biased under MAR/MNAR

---

#### Linear Interpolation (for sequential data)

```r
# For time series or ordered data
impute_recipe <- recipe(outcome ~ ., data = train) |>
  step_impute_linear(temperature, humidity)

# Or using tidyverse
data_interpolated <- data |>
  arrange(timestamp) |>
  mutate(
    temperature = zoo::na.approx(temperature, na.rm = FALSE),
    humidity = zoo::na.approx(humidity, na.rm = FALSE)
  )
```

**When to Use**:
- Sequential/temporal data
- Smooth trends expected
- Short gaps in sequences

---

### 3. K-Nearest Neighbors Imputation

**Approach**: Impute using values from K similar observations.

**Implementation**:
```r
library(recipes)

# KNN imputation
impute_recipe <- recipe(outcome ~ ., data = train) |>
  step_impute_knn(
    all_predictors(),
    neighbors = 5,
    impute_with = imp_vars(all_predictors())
  )

# Or using VIM package
library(VIM)
data_imputed <- kNN(
  data,
  variable = c("income", "age"),
  k = 5
)
```

**When to Use**:
- MAR mechanism
- Moderate missingness (5-20%)
- Sufficient complete cases for matching
- Relationships between variables exist

**Advantages**:
- ✅ Uses multivariate information
- ✅ Preserves distributions better than mean
- ✅ Flexible and intuitive

**Disadvantages**:
- ❌ Computationally expensive for large datasets
- ❌ Sensitive to scale (requires normalization)
- ❌ Still underestimates variance
- ❌ May not work well with high-dimensional data

**Best Practice**:
```r
# Normalize before KNN imputation
impute_recipe <- recipe(outcome ~ ., data = train) |>
  step_normalize(all_numeric_predictors()) |>
  step_impute_knn(all_predictors(), neighbors = 5) |>
  # Continue with other preprocessing
  step_dummy(all_nominal_predictors())
```

---

### 4. Bagged Tree Imputation

**Approach**: Use bagged decision trees to predict missing values.

**Implementation**:
```r
library(recipes)

# Bagged tree imputation
impute_recipe <- recipe(outcome ~ ., data = train) |>
  step_impute_bag(
    all_predictors(),
    trees = 25,
    seed_val = 123
  )
```

**When to Use**:
- MAR mechanism
- Complex nonlinear relationships
- Mixed variable types
- Moderate to high missingness (5-30%)

**Advantages**:
- ✅ Handles nonlinear relationships
- ✅ Works with mixed data types
- ✅ No normalization needed
- ✅ Robust to outliers

**Disadvantages**:
- ❌ Computationally expensive
- ❌ Still single imputation (underestimates uncertainty)
- ❌ May overfit with small samples

---

### 5. Multiple Imputation

**Approach**: Create multiple complete datasets with different imputations, analyze each, pool results.

**Concept**: Properly accounts for uncertainty in imputed values.

**Implementation**:
```r
library(mice)

# Multiple imputation
mice_imputed <- mice(
  data,
  m = 5,              # Number of imputed datasets
  method = "pmm",     # Predictive mean matching
  maxit = 10,         # Iterations
  seed = 123
)

# Check convergence
plot(mice_imputed)

# Pooled analysis
# 1. Fit model to each imputed dataset
fit <- with(mice_imputed, lm(outcome ~ x1 + x2 + x3))

# 2. Pool results
pooled <- pool(fit)
summary(pooled)

# Extract completed dataset (for prediction)
completed_data <- complete(mice_imputed, action = 1)  # First imputation
```

**Imputation Methods in mice**:
```r
# PMM - Predictive mean matching (default, works well)
method = "pmm"

# Bayesian linear regression
method = "norm"

# Random forest
method = "rf"

# Logistic regression (binary)
method = "logreg"

# Polytomous regression (categorical)
method = "polyreg"
```

**When to Use**:
- MAR mechanism
- Moderate to high missingness (10-40%)
- Need valid statistical inference
- Sufficient computational resources

**Advantages**:
- ✅ Properly accounts for imputation uncertainty
- ✅ Valid statistical inference
- ✅ Flexible imputation models
- ✅ Best practice for research

**Disadvantages**:
- ❌ Computationally intensive
- ❌ Complex to implement
- ❌ Requires careful model specification
- ❌ Pooling not straightforward for all analyses

---

### 6. Model-Based Imputation

**Approach**: Use a predictive model for each variable with missing values.

**Linear Regression Imputation**:
```r
library(recipes)

# Linear model imputation
impute_recipe <- recipe(outcome ~ ., data = train) |>
  step_impute_linear(
    income,
    impute_with = imp_vars(age, education, experience)
  )
```

**When to Use**:
- Clear linear relationships
- Predictor variables mostly complete
- MAR mechanism

---

### 7. Indicator Method (Missing as Information)

**Approach**: Create indicator variable for missingness, impute with constant.

**Implementation**:
```r
library(recipes)

# Create missing indicators
impute_recipe <- recipe(outcome ~ ., data = train) |>
  step_indicate_na(all_predictors(), prefix = "missing_") |>
  step_impute_median(all_numeric_predictors()) |>
  step_impute_mode(all_nominal_predictors())

# Manual approach
data_with_indicators <- data |>
  mutate(
    income_missing = as.numeric(is.na(income)),
    income = replace_na(income, median(income, na.rm = TRUE))
  )
```

**When to Use**:
- Missingness itself is informative (MNAR suspected)
- Tree-based models (handle indicators well)
- Want to preserve missingness signal

**Advantages**:
- ✅ Retains information about missingness pattern
- ✅ Works well with tree-based models
- ✅ Simple to implement

**Disadvantages**:
- ❌ Increases dimensionality
- ❌ Imputed value still arbitrary
- ❌ Can cause multicollinearity

---

## Strategy Selection Guide

### Based on Missingness Mechanism

| Mechanism | Recommended Strategy |
|-----------|---------------------|
| **MCAR** | Complete case analysis or simple imputation |
| **MAR** | KNN, bagged trees, or multiple imputation |
| **MNAR** | Indicator method + domain expertise, sensitivity analysis |
| **Unknown** | Multiple imputation (conservative) |

### Based on Missingness Percentage

| Missingness | Strategy |
|-------------|----------|
| < 5% | Complete case analysis or simple imputation |
| 5-20% | KNN or bagged trees |
| 20-40% | Multiple imputation or bagged trees |
| > 40% | Reconsider data collection; if proceeding, multiple imputation with caution |

### Based on Data Type

| Scenario | Strategy |
|----------|----------|
| Numeric only | KNN, linear imputation, or mice with PMM |
| Categorical only | Mode or mice with logreg/polyreg |
| Mixed types | Bagged trees or mice with mixed methods |
| Time series | Linear interpolation or LOCF/NOCB |
| High-dimensional | Simple imputation or careful mice specification |

---

## Best Practices

### ✅ DO

1. **Understand the mechanism**: Investigate WHY data is missing
2. **Visualize patterns**: Use naniar to explore missingness
3. **Use training data only**: Compute imputation parameters from training set
4. **Preserve test set integrity**: Apply same imputation strategy with training parameters
5. **Document decisions**: Record imputation methods and rationale
6. **Compare methods**: Test multiple approaches and validate
7. **Consider indicator variables**: Especially for tree-based models
8. **Use multiple imputation**: For formal inference and publications

### ❌ DON'T

1. **Ignore missingness**: Understand patterns before handling
2. **Use test data for imputation**: Causes data leakage
3. **Assume MCAR**: Test this assumption
4. **Over-impute**: >40% missingness questionable regardless of method
5. **Forget about MNAR**: If suspected, use sensitivity analysis
6. **Use mean imputation routinely**: Underestimates variance
7. **Impute outcome variable**: Generally should remove these observations
8. **Skip validation**: Always check imputation quality

---

## Complete Workflow Example

```r
library(tidymodels)
library(naniar)
library(mice)
library(recipes)

# 1. Diagnose missingness
miss_summary <- data |>
  miss_var_summary()

vis_miss(data, cluster = TRUE)

# 2. Test for MCAR
library(missMethods)
mcar_result <- mcar_test(data)

# 3. Split data first (before any imputation!)
set.seed(123)
data_split <- initial_split(data, prop = 0.75, strata = outcome)
train <- training(data_split)
test <- testing(data_split)

# 4. Choose imputation strategy
# Option A: Simple KNN imputation
impute_recipe <- recipe(outcome ~ ., data = train) |>
  step_normalize(all_numeric_predictors()) |>
  step_impute_knn(all_predictors(), neighbors = 5) |>
  step_normalize(all_numeric_predictors()) |>  # Re-normalize after imputation
  step_dummy(all_nominal_predictors())

# Option B: Multiple imputation (for inference)
train_mice <- mice(train, m = 5, method = "pmm", seed = 123)

# Check imputation quality
densityplot(train_mice)  # Compare imputed vs observed distributions

# 5. Proceed with modeling
# For Option A (single imputation via recipes)
model_wf <- workflow() |>
  add_recipe(impute_recipe) |>
  add_model(linear_reg())

# Cross-validation
cv_results <- fit_resamples(
  model_wf,
  resamples = vfold_cv(train, v = 10),
  metrics = metric_set(rmse, rsq)
)

collect_metrics(cv_results)

# Final evaluation
final_fit <- last_fit(model_wf, data_split)
collect_metrics(final_fit)

# For Option B (multiple imputation)
# Fit model to each imputed dataset
fit <- with(train_mice, lm(outcome ~ x1 + x2 + x3))

# Pool results
pooled <- pool(fit)
summary(pooled)

# 6. Validate imputation quality
# Compare distributions
train_imputed <- prep(impute_recipe) |> bake(new_data = NULL)

# Visual check
library(ggplot2)

ggplot() +
  geom_density(data = train, aes(x = income, color = "Original"), na.rm = TRUE) +
  geom_density(data = train_imputed, aes(x = income, color = "Imputed")) +
  labs(title = "Distribution Comparison: Original vs Imputed")
```

---

## Imputation Quality Checks

### Distribution Comparison

```r
# For continuous variables
library(ggplot2)

# Overlay densities
ggplot() +
  geom_density(data = original, aes(x = var, color = "Observed")) +
  geom_density(data = imputed, aes(x = var, color = "Imputed")) +
  labs(title = "Observed vs Imputed Distribution")

# Q-Q plot
qqplot(original$var[!is.na(original$var)], imputed$var)
abline(0, 1, col = "red")
```

### Imputation Diagnostics (mice)

```r
# Convergence check
plot(mice_imputed)

# Density plots
densityplot(mice_imputed)

# Strip plots (observed in blue, imputed in red)
stripplot(mice_imputed, income ~ .imp, pch = 20)

# Scatter plots
xyplot(mice_imputed, income ~ age | .imp)
```

### Validation Strategy

```r
# 1. Artificially create missingness in complete cases
complete_cases <- data |> drop_na()

# Create MCAR missingness (10%)
set.seed(123)
test_data <- complete_cases |>
  mutate(
    income_true = income,
    income = ifelse(runif(n()) < 0.1, NA, income)
  )

# 2. Impute
imputed <- recipe(~ ., data = test_data) |>
  step_impute_knn(income, neighbors = 5) |>
  prep() |>
  bake(new_data = NULL)

# 3. Compare imputed to true values
library(yardstick)

comparison <- tibble(
  true = test_data$income_true[is.na(test_data$income)],
  imputed = imputed$income[is.na(test_data$income)]
)

# Calculate RMSE
rmse_vec(comparison$true, comparison$imputed)

# Scatter plot
ggplot(comparison, aes(x = true, y = imputed)) +
  geom_point() +
  geom_abline(intercept = 0, slope = 1, color = "red") +
  labs(title = "True vs Imputed Values")
```

---

## Advanced Topics

### Imputation for Predictions

When deploying models, new data may have missingness:

```r
# Save fitted recipe from training
trained_recipe <- prep(impute_recipe, training = train)

# Apply to new data with missingness
new_data_imputed <- bake(trained_recipe, new_data = new_data)

# Make predictions
predict(fitted_model, new_data_imputed)
```

### Sensitivity Analysis for MNAR

```r
# Test multiple scenarios
scenarios <- list(
  pessimistic = function(x) min(x, na.rm = TRUE),
  optimistic = function(x) max(x, na.rm = TRUE),
  neutral = function(x) median(x, na.rm = TRUE)
)

results <- map_dfr(scenarios, ~{
  imputed_data <- data |>
    mutate(income = replace_na(income, .x(income)))

  model_fit <- lm(outcome ~ income + age, data = imputed_data)

  tidy(model_fit) |> filter(term == "income")
}, .id = "scenario")

# Compare coefficient estimates across scenarios
ggplot(results, aes(x = scenario, y = estimate)) +
  geom_point() +
  geom_errorbar(aes(ymin = estimate - 2*std.error,
                    ymax = estimate + 2*std.error)) +
  labs(title = "Sensitivity Analysis: Impact of Imputation Assumptions")
```

---

## Resources

- **Book**: "Feature Engineering and Selection" - Chapter 8: https://feat.engineering/08-Handling_Missing_Data.html
- **mice package**: https://cran.r-project.org/package=mice
- **naniar package**: https://cran.r-project.org/package=naniar
- **VIM package**: https://cran.r-project.org/package=VIM
- **recipes imputation steps**: https://recipes.tidymodels.org/reference/index.html#step-functions-imputation
