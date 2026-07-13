# Phase 5: Feature Engineering

**Owner:** Grace (Data Explorer)
**Duration:** 2-4 hours
**Status:** Active

---

## Phase Goal

Transform and create features based on EDA insights to maximize model performance and interpretability.

---

## Prerequisites

- Phase 4 complete (EDA conducted, insights documented)
- Feature engineering priorities identified
- Clean data available in `data/processed/clean_data.rds`
- `tidymodels`, `recipes` packages installed

---

## Continuation from Phase 4

**Grace continues:**
With EDA insights in hand, I'll systematically engineer features following the priorities we identified. We'll use the `recipes` package from tidymodels for reproducible feature engineering.

---

## Step-by-Step Instructions

### 1. Review Feature Engineering Plan

**Based on Phase 4, our priorities are:**

1. **Transformations**: {list variables needing transformation}
2. **Interactions**: {list interaction terms to create}
3. **Encodings**: {list categorical encoding strategies}
4. **New Features**: {list domain-specific features}
5. **Dimensionality Reduction**: {if needed, list variables for PCA/combinations}

**What I need from you:**
- Confirm these priorities
- Add any domain-specific features I should create
- Target variable and modeling goal confirmation

### 2. Setup Feature Engineering Environment

```r
library(tidyverse)
library(tidymodels)
library(recipes)
library(here)

# Load clean data
df <- read_rds(here("data", "processed", "clean_data.rds"))

# Identify target variable
target_var <- "{your_target}"

# Create train/test split (preserve for consistency)
set.seed(123)
data_split <- initial_split(df, prop = 0.75, strata = target_var)
train_data <- training(data_split)
test_data <- testing(data_split)

cat("Training set:", nrow(train_data), "rows\n")
cat("Test set:", nrow(test_data), "rows\n")
```

### 3. Build Feature Engineering Recipe

**Create a `recipe` object with all transformations:**

```r
# Create base recipe
feature_recipe <- recipe(as.formula(paste(target_var, "~ .")), data = train_data) |>

  # Step 1: Handle ID variables (remove from modeling)
  step_rm(matches("^id$|^ID$|_id$")) |>

  # Step 2: Numeric transformations
  # Log transform (for right-skewed variables)
  step_log({skewed_var1}, {skewed_var2}, offset = 1) |>

  # Square root (alternative for skewed data)
  # step_sqrt({var}) |>

  # Box-Cox transformation (automated power transform)
  # step_BoxCox(all_numeric_predictors()) |>

  # Normalize (center and scale)
  step_normalize(all_numeric_predictors()) |>

  # Step 3: Handle zero/near-zero variance predictors
  step_zv(all_predictors()) |>
  step_nzv(all_predictors(), freq_cut = 95/5) |>

  # Step 4: Create polynomial features
  step_poly({var_with_nonlinear}, degree = 2) |>

  # Step 5: Create interaction terms
  step_interact(terms = ~ {var1}:{var2}) |>
  step_interact(terms = ~ {var3}:{var4}) |>

  # Step 6: Encode categorical variables
  # One-hot encoding (for low cardinality)
  step_dummy(
    {cat_var1}, {cat_var2},
    one_hot = TRUE,
    naming = label_binarizer_names
  ) |>

  # Target encoding (for high cardinality - use with caution)
  # step_lencode_mixed({high_card_var}, outcome = vars(!!target_var)) |>

  # Ordinal encoding (for ordered categories)
  # step_ordinalscore({ordered_var}, convert = \(x) as.numeric(x)) |>

  # Step 7: Create date/time features (if applicable)
  # step_date({date_var}, features = c("dow", "month", "year")) |>
  # step_holiday({date_var}, holidays = timeDate::listHolidays("US")) |>

  # Step 8: Create domain-specific features
  # Example: BMI from height and weight
  # step_mutate(
  #   bmi = weight_kg / (height_m^2),
  #   age_group = cut(age, breaks = c(0, 18, 35, 50, 65, 100))
  # ) |>

  # Step 9: Handle multicollinearity (if severe)
  # step_corr(all_numeric_predictors(), threshold = 0.9) |>

  # Step 10: Dimensionality reduction (if many features)
  # step_pca(all_numeric_predictors(), threshold = 0.95) |>

  # Final: Ensure no missing values
  step_impute_median(all_numeric_predictors()) |>
  step_impute_mode(all_nominal_predictors())

# Prepare recipe on training data
feature_recipe_prep <- prep(feature_recipe, training = train_data)

# Apply to both train and test
train_processed <- bake(feature_recipe_prep, new_data = NULL)  # NULL = training data
test_processed <- bake(feature_recipe_prep, new_data = test_data)

cat("Original features:", ncol(df) - 1, "\n")
cat("Engineered features:", ncol(train_processed) - 1, "\n")
```

### 4. Manual Feature Creation

**For complex domain-specific features not in `recipes`:**

```r
# Add to data before recipe
df <- df |>
  mutate(
    # Ratios
    # {new_feature} = {var1} / {var2},

    # Aggregations (if grouped data)
    # {new_feature} = {var} / mean({var}, na.rm = TRUE),

    # Binning
    # {var}_binned = cut({var}, breaks = c(-Inf, 0, 50, 100, Inf),
    #                    labels = c("low", "medium", "high", "very_high")),

    # Text features (if text variables)
    # {var}_length = str_length({text_var}),
    # {var}_word_count = str_count({text_var}, "\\w+"),

    # Flag variables
    # is_{condition} = ifelse({var} > threshold, 1, 0),

    # Combinations
    # {var}_combined = paste({var1}, {var2}, sep = "_")
  )
```

### 5. Feature Importance Analysis

**Assess which features are most predictive:**

```r
# Quick random forest to evaluate feature importance
library(ranger)

# For classification
if (!is.numeric(train_processed[[target_var]])) {
  rf_model <- ranger(
    as.formula(paste(target_var, "~ .")),
    data = train_processed,
    importance = "impurity",
    num.trees = 100
  )
} else {
  # For regression
  rf_model <- ranger(
    as.formula(paste(target_var, "~ .")),
    data = train_processed,
    importance = "impurity",
    num.trees = 100
  )
}

# Extract importance
importance_df <- tibble(
  feature = names(rf_model$variable.importance),
  importance = rf_model$variable.importance
) |>
  arrange(desc(importance)) |>
  mutate(
    rank = row_number(),
    cumulative_importance = cumsum(importance) / sum(importance)
  )

# Visualize
importance_df |>
  head(20) |>
  ggplot(aes(x = reorder(feature, importance), y = importance)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Top 20 Features by Importance",
    subtitle = "Based on Random Forest feature importance",
    x = NULL,
    y = "Importance"
  ) +
  theme_minimal()

ggsave(here("outputs", "figures", "feature_importance.png"),
       width = 10, height = 8)

# Save importance scores
write_csv(importance_df, here("outputs", "tables", "feature_importance.csv"))

# Identify top features (capturing 90% of importance)
top_features <- importance_df |>
  filter(cumulative_importance <= 0.90) |>
  pull(feature)

cat("Top features (90% importance):", length(top_features), "\n")
```

### 6. Feature Selection

**Optionally reduce to most important features:**

```r
# Create reduced feature set
train_selected <- train_processed |>
  select(all_of(c(target_var, top_features)))

test_selected <- test_processed |>
  select(all_of(c(target_var, top_features)))

# Alternative: Use recipe step
feature_recipe_selected <- feature_recipe |>
  step_select(all_of(top_features))
```

### 7. Validate Engineered Features

**Quality checks on new features:**

```r
# 1. Check for NAs introduced
missing_check <- train_processed |>
  summarise(across(everything(), ~ sum(is.na(.x)))) |>
  pivot_longer(everything(), names_to = "variable", values_to = "n_missing") |>
  filter(n_missing > 0)

if (nrow(missing_check) > 0) {
  cat("WARNING: Missing values in engineered features:\n")
  print(missing_check)
  write_csv(missing_check, here("outputs", "tables", "feature_missing_check.csv"))
}

# 2. Check for infinite values
inf_check <- train_processed |>
  select(where(is.numeric)) |>
  summarise(across(everything(), ~ sum(is.infinite(.x)))) |>
  pivot_longer(everything(), names_to = "variable", values_to = "n_infinite") |>
  filter(n_infinite > 0)

if (nrow(inf_check) > 0) {
  cat("WARNING: Infinite values in features:\n")
  print(inf_check)
}

# 3. Distribution check (ensure transformations worked)
train_processed |>
  select(where(is.numeric)) |>
  select(1:6) |>  # First 6 for visualization
  pivot_longer(everything()) |>
  ggplot(aes(x = value)) +
  geom_histogram(bins = 30, fill = "coral", alpha = 0.7) +
  facet_wrap(~name, scales = "free") +
  labs(title = "Engineered Feature Distributions") +
  theme_minimal()

ggsave(here("outputs", "figures", "engineered_feature_distributions.png"),
       width = 12, height = 8)

# 4. Correlation with target
target_correlations <- train_processed |>
  select(where(is.numeric)) |>
  correlate() |>
  focus(!!sym(target_var)) |>
  arrange(desc(abs(!!sym(target_var)))) |>
  drop_na()

write_csv(target_correlations, here("outputs", "tables", "target_correlations.csv"))

# Visualize
target_correlations |>
  head(20) |>
  ggplot(aes(x = reorder(term, abs(!!sym(target_var))),
             y = !!sym(target_var))) +
  geom_col(aes(fill = !!sym(target_var) > 0)) +
  coord_flip() +
  scale_fill_manual(values = c("coral", "steelblue")) +
  labs(
    title = "Top 20 Feature Correlations with Target",
    x = NULL,
    y = paste("Correlation with", target_var)
  ) +
  theme_minimal() +
  theme(legend.position = "none")

ggsave(here("outputs", "figures", "target_correlations.png"),
       width = 10, height = 8)
```

### 8. Save Processed Data and Recipe

```r
# Save processed datasets
write_rds(train_processed, here("data", "processed", "train_processed.rds"))
write_rds(test_processed, here("data", "processed", "test_processed.rds"))

# Save recipe object (for deployment)
write_rds(feature_recipe_prep, here("outputs", "models", "feature_recipe.rds"))

# Save as CSV for inspection
write_csv(train_processed, here("data", "processed", "train_processed.csv"))
write_csv(test_processed, here("data", "processed", "test_processed.csv"))

cat("Processed data saved to data/processed/\n")
cat("Recipe saved to outputs/models/feature_recipe.rds\n")
```

### 9. Document Feature Engineering

Create `outputs/tables/phase05-feature-engineering-log.md`:

```markdown
# Phase 5: Feature Engineering Log

**Engineer:** Grace (Data Explorer)
**Date:** {date}
**Original Features:** {n_original}
**Engineered Features:** {n_engineered}

## Feature Engineering Steps

### 1. Transformations Applied
- **Log transform**: {variables} (reduce skewness)
- **Normalization**: All numeric predictors (mean=0, sd=1)
- **Polynomial**: {variables} (degree 2) - capture non-linearity

### 2. Interaction Terms Created
- {var1} × {var2}: Captures {domain insight}
- {var3} × {var4}: Captures {domain insight}
- Total interactions: {n}

### 3. Categorical Encodings
- **One-hot**: {variables} → {n_dummies} dummy variables
- **Target encoding**: {variables} (high cardinality)
- **Ordinal**: {variables} (ordered categories)

### 4. Domain-Specific Features
- {feature_name}: {calculation} → {business meaning}
- {feature_name}: {calculation} → {business meaning}
- Total custom features: {n}

### 5. Feature Selection
- Initial engineered features: {n_initial}
- Features removed (zero/near-zero variance): {n_removed}
- Features removed (high correlation): {n_removed}
- Final feature set: {n_final}
- Top 20 features by importance (see feature_importance.csv)

## Feature Quality Validation

### Missing Values
- {status}: No missing values introduced / {n} features with missings

### Infinite Values
- {status}: No infinite values / {n} features with inf values

### Target Correlation
- Strongest positive: {feature} (r = {value})
- Strongest negative: {feature} (r = {value})
- Weak features (|r| < 0.05): {n} features

## Data Split

| Set | Rows | Features | Target Mean/Mode |
|-----|------|----------|------------------|
| Train | {n} | {n} | {value} |
| Test | {n} | {n} | {value} |

Split ratio: 75/25, stratified by {target_var}

## Recipe Summary

The feature engineering recipe includes:
1. Remove ID variables
2. Log transformations
3. Normalization
4. Zero/near-zero variance removal
5. Polynomial features (degree 2)
6. Interaction terms
7. Categorical encoding (one-hot/target)
8. Date/time features (if applicable)
9. Domain features
10. Missing value imputation

**Recipe saved**: `outputs/models/feature_recipe.rds`

## Next Steps (Phase 6: Modeling)

**Handoff to Alan (Model Master):**
- Feature engineering complete
- Train/test sets prepared and saved
- {n_final} features ready for modeling
- Feature importance baseline established
- Recipe object ready for deployment pipeline

Alan will use this prepared data to build and compare multiple models.

**Estimated Phase 6 duration:** 3-5 hours
```

### 10. Validation Checklist

Before proceeding to Phase 6:

- [ ] Feature engineering recipe created and tested
- [ ] All transformations applied successfully
- [ ] Interaction terms created based on EDA insights
- [ ] Categorical variables encoded appropriately
- [ ] Domain-specific features created
- [ ] Feature importance analysis completed
- [ ] No missing or infinite values in final dataset
- [ ] Train/test split maintained
- [ ] Processed data saved (RDS and CSV)
- [ ] Recipe object saved for deployment
- [ ] Feature engineering log documented
- [ ] Ready to hand off to Alan for modeling

---

## Outputs

**Created Files:**
- `scripts/05-features.R`
- `data/processed/train_processed.rds`
- `data/processed/test_processed.rds`
- `data/processed/train_processed.csv`
- `data/processed/test_processed.csv`
- `outputs/models/feature_recipe.rds`
- `outputs/figures/feature_importance.png`
- `outputs/figures/engineered_feature_distributions.png`
- `outputs/figures/target_correlations.png`
- `outputs/tables/feature_importance.csv`
- `outputs/tables/target_correlations.csv`
- `outputs/tables/phase05-feature-engineering-log.md`
- `checkpoints/05-feature-engineering.complete`

**Git Commit:**
```bash
git add data/processed/ scripts/05-features.R outputs/
git commit -m "feat: engineer features for modeling

- Create {n_engineered} features from {n_original} original
- Apply transformations: log, normalize, polynomial
- Generate {n_interactions} interaction terms
- Encode categorical variables
- Identify top {n_top} features by importance
- Train/test split: {n_train}/{n_test} observations

Phase 5/10 complete

Co-Authored-By: Grace (Data Explorer) <noreply@bmad.com>"
```

---

## Troubleshooting

**Issue:** Recipe fails to prep
- **Solution**: Check for character variables that should be factors, ensure no NAs in target

**Issue:** Too many dummy variables from encoding
- **Solution**: Use target encoding for high-cardinality variables, or group rare levels

**Issue:** Transformed features have inf values
- **Solution**: Add offset to log transform, check for zero values before division

**Issue:** Feature importance shows unexpected results
- **Solution**: Check for data leakage, ensure proper train/test split, verify transformations

---

## Next Phase

**Phase 6: Modeling**

With engineered features ready, we'll hand off to Alan (Model Master):
1. Build baseline model
2. Train multiple candidate models
3. Compare performance
4. Select best model architecture
5. Prepare for hyperparameter tuning

**Transition:** When ready, say "Continue to Phase 6" or "Start modeling"

**Handoff to Alan:**
- ✓ Clean, engineered features
- ✓ Train/test split preserved
- ✓ Feature importance baseline
- ✓ Recipe for reproducibility

---

## Phase Completion

When this phase is complete:
1. Feature engineering recipe created and validated
2. Train/test datasets processed and saved
3. Feature importance analysis completed
4. Recipe object saved for deployment
5. Feature engineering log documented
6. Checkpoint file created
7. Git commit made
8. **Ready to hand off to Alan for Phase 6**

**Expected Duration:** 2-4 hours

---

_Phase 5 of 10 | Owner: Grace | RDS Module Full-Lifecycle Workflow_
