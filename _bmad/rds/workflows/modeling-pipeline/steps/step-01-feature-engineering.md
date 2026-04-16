# Step 1: Feature Engineering

**Workflow:** modeling-pipeline
**Owner:** Alan (ML Engineer)
**Duration:** 1-2 days

---

## Step Overview

**Goal:** Transform, encode, and create features using tidymodels recipes

**Inputs:**
- Clean data (data frame or file path)
- Target variable name
- Problem type (classification/regression)
- Optional: Domain knowledge for custom features

**Outputs:**
- `recipe.rds` — Preprocessing recipe object
- `feature_engineering_report.html` — Documentation
- `feature_summary.csv` — Feature importance metadata

---

## Activation

Olá! Este é o **Step 1: Feature Engineering**.

Vamos criar uma recipe de preprocessing robusta que:
- Transforma variáveis (log, Box-Cox, Yeo-Johnson)
- Codifica categorias (dummy, target encoding)
- Cria novas features (interações, polinomiais)
- Normaliza/padroniza conforme necessário

**Princípio fundamental:** Toda transformação deve estar DENTRO do recipe para garantir estimação honesta no CV.

---

## Data Input

### Option 1: Data Frame in Memory

```r
# User provides data frame
data <- readRDS("path/to/clean_data.rds")
target <- "price"
problem_type <- "regression"
```

### Option 2: File Path

```r
# User provides path
data_path <- "data/clean/housing.csv"
data <- readr::read_csv(data_path)
```

---

## Recipe Construction

### Phase 1: Initial Setup

```r
library(tidymodels)
library(recipes)

# Create initial recipe
rec <- recipe({{ target }} ~ ., data = data)
```

---

### Phase 2: Role Assignment

Identify feature roles:

```r
rec <- rec %>%
  # ID variables (don't use in modeling)
  update_role(id, new_role = "id") %>%

  # Date features (extract components)
  step_date(date_column, features = c("dow", "month", "year")) %>%
  update_role(date_column, new_role = "date_original")
```

---

### Phase 3: Missing Value Handling

**Critical:** Verify data is clean before this step.

```r
# If any missingness remains, handle explicitly
rec <- rec %>%
  # Numeric imputation
  step_impute_median(all_numeric_predictors()) %>%

  # Categorical imputation
  step_impute_mode(all_nominal_predictors())
```

**Note:** For clean data from Ada's pipeline, this should not be needed.

---

### Phase 4: Feature Engineering

#### Numeric Transformations

```r
rec <- rec %>%
  # Log transform right-skewed features
  step_log(sqft, lot_size, offset = 1) %>%

  # Box-Cox for normality
  step_BoxCox(all_numeric_predictors()) %>%

  # Or Yeo-Johnson (handles negatives)
  step_YeoJohnson(all_numeric_predictors())
```

**Decision Point:** Choose transformation based on:
- Distribution shape (skewness, kurtosis)
- Presence of zeros/negatives
- Model requirements (linear models benefit more)

---

#### Categorical Encoding

```r
rec <- rec %>%
  # Collapse rare levels
  step_other(all_nominal_predictors(), threshold = 0.05) %>%

  # Dummy encoding (for linear models, random forests)
  step_dummy(all_nominal_predictors(), one_hot = FALSE) %>%

  # Or target encoding (for tree models)
  step_lencode_mixed(all_nominal_predictors(), outcome = vars({{ target }}))
```

**Decision Point:** Encoding strategy depends on model type:
- **Linear models, SVM:** Dummy encoding
- **Tree models:** Can handle categories directly or use target encoding
- **Neural networks:** Embedding layers (outside recipe)

---

#### Interaction Terms

```r
rec <- rec %>%
  # Create interactions
  step_interact(~ bedrooms:bathrooms) %>%
  step_interact(~ sqft:neighborhood)
```

**Decision Point:** Based on domain knowledge:
- Size × quality interactions
- Location × amenities interactions
- Time × cyclical patterns

---

#### Polynomial Features

```r
rec <- rec %>%
  # Polynomial features
  step_poly(sqft, degree = 2) %>%
  step_poly(age, degree = 3)
```

**Caution:** Increases feature count rapidly. Use sparingly.

---

### Phase 5: Scaling and Normalization

```r
rec <- rec %>%
  # Center and scale (required for many models)
  step_normalize(all_numeric_predictors()) %>%

  # Or range scaling [0, 1]
  step_range(all_numeric_predictors(), min = 0, max = 1)
```

**Decision Point:** Scaling requirements:
- **Required:** Linear models, SVM, neural networks, KNN
- **Helpful:** Regularized models (lasso, ridge, elastic net)
- **Not needed:** Tree-based models (random forest, XGBoost)

---

### Phase 6: Dimensionality Reduction (Optional)

```r
rec <- rec %>%
  # PCA for high-dimensional data
  step_pca(all_numeric_predictors(), threshold = 0.95) %>%

  # Or feature selection
  step_filter_missing(threshold = 0.5) %>%
  step_corr(all_numeric_predictors(), threshold = 0.9)
```

**Decision Point:** Use when:
- Many correlated predictors
- Computational constraints
- Multicollinearity issues

---

### Phase 7: Zero Variance Removal

```r
rec <- rec %>%
  # Remove zero-variance features
  step_zv(all_predictors()) %>%

  # Remove near-zero variance
  step_nzv(all_predictors(), freq_cut = 95/5)
```

**Always include:** Prevents model fitting errors.

---

## Recipe Validation

### Prep and Bake

```r
# Prep recipe on training data
rec_prepped <- prep(rec, training = data)

# Inspect results
summary(rec_prepped)

# Apply to data
data_processed <- bake(rec_prepped, new_data = NULL)
```

---

### Quality Checks

```r
# 1. Check for infinite values
any(sapply(data_processed, function(x) any(is.infinite(x))))

# 2. Check for NAs introduced
colSums(is.na(data_processed))

# 3. Check feature counts
ncol(data_processed)

# 4. Check distributions
data_processed %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything()) %>%
  ggplot(aes(x = value)) +
  geom_histogram() +
  facet_wrap(~ name, scales = "free")
```

---

## Documentation

### Feature Engineering Report

Generate comprehensive report:

```r
library(rmarkdown)

render("templates/feature_engineering_report.Rmd",
       params = list(
         recipe = rec_prepped,
         data_before = data,
         data_after = data_processed,
         decisions = decisions_log
       ),
       output_file = "feature_engineering_report.html")
```

**Report Contents:**
1. Original data summary
2. Recipe steps with justification
3. Before/after distributions
4. Correlation changes
5. Feature count changes
6. Quality check results

---

### Decisions Log

Document all decisions:

```markdown
# Feature Engineering Decisions

## Transformations
- **Log transform:** Applied to sqft, lot_size (right-skewed)
- **Box-Cox:** Skipped (log sufficient)
- **Yeo-Johnson:** Not needed (no negatives)

## Encoding
- **Strategy:** Dummy encoding
- **Reason:** Linear models in baseline comparison
- **Rare levels:** Collapsed at 5% threshold

## Interactions
- bedrooms × bathrooms: Domain knowledge (total living capacity)
- sqft × neighborhood: Location-size premium

## Scaling
- **Method:** Standardization (mean=0, sd=1)
- **Reason:** Planning to compare multiple model types

## Feature Selection
- **Correlation filter:** threshold = 0.9
- **Zero variance:** Removed 3 features
```

---

## Output Artifacts

### Save Recipe

```r
# Save recipe object
saveRDS(rec_prepped, file = "{output_folder}/recipe.rds")
```

---

### Feature Summary

```r
# Create feature metadata
feature_summary <- tibble(
  feature = rec_prepped$var_info$variable,
  role = rec_prepped$var_info$role,
  type = rec_prepped$var_info$type,
  source = rec_prepped$var_info$source
)

write_csv(feature_summary, "{output_folder}/feature_summary.csv")
```

---

## Common Recipes by Problem Type

### Classification Recipe Template

```r
classification_rec <- recipe(outcome ~ ., data = data) %>%
  # Handle class imbalance
  step_downsample(outcome, under_ratio = 1.5) %>%  # Or step_smote()

  # Feature engineering
  step_other(all_nominal_predictors(), threshold = 0.05) %>%
  step_dummy(all_nominal_predictors()) %>%
  step_normalize(all_numeric_predictors()) %>%
  step_zv(all_predictors())
```

---

### Regression Recipe Template

```r
regression_rec <- recipe(outcome ~ ., data = data) %>%
  # Transform target if needed
  step_log(outcome, offset = 1) %>%

  # Feature engineering
  step_YeoJohnson(all_numeric_predictors()) %>%
  step_other(all_nominal_predictors(), threshold = 0.05) %>%
  step_dummy(all_nominal_predictors()) %>%
  step_normalize(all_numeric_predictors()) %>%
  step_corr(all_numeric_predictors(), threshold = 0.9) %>%
  step_zv(all_predictors())
```

---

### Time Series Recipe Template

```r
timeseries_rec <- recipe(outcome ~ ., data = data) %>%
  # Extract time features
  step_date(date, features = c("dow", "month", "year", "decimal")) %>%
  step_holiday(date, holidays = timeDate::listHolidays("US")) %>%

  # Create lags
  step_lag(outcome, lag = 1:7) %>%
  step_lag(outcome, lag = c(28, 56, 84)) %>%  # Monthly lags

  # Rolling statistics
  step_window(outcome, size = 7, statistic = "mean") %>%

  # Standard processing
  step_normalize(all_numeric_predictors()) %>%
  step_zv(all_predictors())
```

---

## Best Practices

### 1. Recipe Design Principles

- **Simplicity first:** Start with minimal transformations
- **Domain knowledge:** Let subject matter expertise guide feature creation
- **Iteration:** Recipe development is iterative
- **Documentation:** Explain every non-obvious step

---

### 2. Common Pitfalls

**❌ Data leakage:** Scaling before CV split
**✅ Solution:** All preprocessing in recipe

**❌ Over-engineering:** Too many polynomial/interaction terms
**✅ Solution:** Start simple, add complexity if needed

**❌ Ignoring distributions:** Assuming normality
**✅ Solution:** Always visualize before and after

**❌ Category explosion:** Too many dummy variables
**✅ Solution:** Use `step_other()` to collapse rare levels

---

### 3. Performance Tips

```r
# Parallel processing for expensive steps
rec <- rec %>%
  step_BoxCox(all_numeric_predictors(), num_comp = parallel::detectCores())

# Skip unnecessary transformations
rec <- rec %>%
  step_normalize(all_numeric_predictors(),
                 skip = TRUE)  # Skip for new data if already scaled
```

---

## Transition to Step 2

Once recipe is complete and validated:

1. ✅ Recipe saved to `recipe.rds`
2. ✅ Report generated and reviewed
3. ✅ Feature summary documented
4. ✅ Quality checks passed

**Ready for Step 2: Baseline Models**

The recipe will be bundled with model specifications to ensure all preprocessing happens inside CV folds.

---

## Troubleshooting

### Issue: Recipe fails to prep

**Symptom:** Error during `prep(rec)`

**Causes:**
- Step requires variables that don't exist
- Type mismatch (expecting numeric, got character)
- Insufficient data for estimation (e.g., Box-Cox needs positive values)

**Solution:**
```r
# Check recipe structure
rec$var_info
rec$steps

# Prep with verbose output
rec_prepped <- prep(rec, training = data, verbose = TRUE)
```

---

### Issue: Bake produces NAs

**Symptom:** `bake()` creates missing values

**Causes:**
- Transformation undefined (log of negative)
- Division by zero in normalization
- Encoding unknown categories

**Solution:**
```r
# Inspect step-by-step
juice(rec_prepped)  # Training data
bake(rec_prepped, new_data = data)  # Test data

# Add safety steps
rec <- rec %>%
  step_mutate(x = pmax(x, 0.001)) %>%  # Ensure positive before log
  step_unknown(all_nominal_predictors())  # Handle unknown categories
```

---

### Issue: Too many features

**Symptom:** Recipe creates thousands of features

**Causes:**
- Excessive polynomial terms
- Too many interaction terms
- One-hot encoding high-cardinality categories

**Solution:**
```r
# Check feature count
rec_prepped %>%
  bake(new_data = NULL) %>%
  ncol()

# Reduce complexity
rec <- rec %>%
  step_other(all_nominal_predictors(), threshold = 0.1) %>%  # More aggressive
  step_corr(all_numeric_predictors(), threshold = 0.8) %>%
  step_pca(all_numeric_predictors(), threshold = 0.95)
```

---

**Step 1 complete. Proceed to Step 2: Baseline Models.**
