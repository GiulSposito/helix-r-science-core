# Feature Engineering Decision Checklist

Use this checklist to systematically make feature engineering decisions for your modeling project.

## Phase 1: Data Understanding

### Categorical Variables

For each categorical predictor, answer:

```
Variable: _______________

□ How many unique categories? _____
□ Distribution:
  □ Balanced (all categories >5% of data)
  □ Imbalanced (some categories <5%)
  □ Highly imbalanced (some categories <1%)

□ Cardinality classification:
  □ Low (<10 categories)
  □ Medium (10-50 categories)
  □ High (50-100 categories)
  □ Very high (>100 categories)

□ Is there natural ordering?
  □ Yes → Ordinal variable
  □ No → Nominal variable

□ Will novel categories appear in production?
  □ Yes → Need `step_novel()`
  □ No → Standard encoding OK

Recommended encoding: _______________
Rationale: _______________
```

### Numeric Variables

For each numeric predictor, answer:

```
Variable: _______________

□ Distribution shape:
  □ Normal/symmetric
  □ Right-skewed (tail to right)
  □ Left-skewed (tail to left)
  □ Bimodal or multimodal

□ Skewness value: _____
  □ |skewness| < 0.5 → Mild
  □ |skewness| 0.5-1.0 → Moderate
  □ |skewness| > 1.0 → Severe

□ Range:
  □ All positive → Box-Cox possible
  □ Contains zeros → Need offset or Yeo-Johnson
  □ Contains negatives → Yeo-Johnson only

□ Outliers present?
  □ Yes, many → Robust methods needed
  □ Yes, few → Consider removing or transforming
  □ No → Standard methods OK

□ Relationship with outcome:
  □ Linear
  □ Non-linear smooth (polynomial/spline candidate)
  □ Non-linear with breakpoints (hinge functions)
  □ Unclear → Explore with GAM

Recommended transformation: _______________
Rationale: _______________
```

---

## Phase 2: Model-Specific Considerations

### What model(s) will you use?

```
Primary model type:
□ Tree-based (Random Forest, XGBoost, decision tree)
  → Skip transformations
  → Simple encoding (dummy or ordinal)

□ Linear (linear/logistic regression, GLM)
  → Standardization recommended
  → Transform skewed predictors
  → Consider splines for non-linearity

□ Regularized (Lasso, ridge, elastic net)
  → Standardization REQUIRED
  → Transform skewed predictors
  → Feature selection built-in

□ Distance-based (KNN, SVM)
  → Standardization REQUIRED
  → Remove outliers or use robust scaling
  → Consider PCA if many correlated features

□ Neural network
  → Scaling to [0,1] or [-1,1]
  → Entity embeddings for high-cardinality categoricals
  → Interaction layers possible

□ Ensemble of multiple types
  → Apply preprocessing for most sensitive model
```

---

## Phase 3: Feature Engineering Strategy

### Categorical Encoding

```
For each categorical variable:

Variable: _______________ (_____ categories)

Decision flowchart:

1. Is it ordinal?
   YES → Use step_ordinalscore()
   NO → Continue

2. How many categories?
   <10 → Use step_dummy()
   10-50 → Continue to step 3
   >50 → Continue to step 4

3. Medium cardinality (10-50):
   Sample size per category:
   Most categories >100 obs → step_other() |> step_dummy()
   Many categories <100 obs → embed::step_lencode_bayes()

4. High cardinality (>50):
   Is performance critical?
   YES, and have compute budget → embed::step_embed()
   YES, but limited compute → embed::step_lencode_mixed()
   NO, just need it to work → textrecipes::step_texthash()

My choice: _______________
Implementation:
```r
recipe(outcome ~ ., data = train) |>
  step_novel(___) |>  # If novel categories possible
  _______________(___) # Chosen encoding
```
```

### Numeric Transformations

```
For each numeric variable:

Variable: _______________ (skewness = _____)

Decision flowchart:

1. What model type?
   Tree-based → No transformation needed, SKIP
   Other → Continue

2. Is standardization needed?
   Linear/SVM/KNN/Penalized → YES (step_normalize)
   Other → Maybe

3. Is distribution skewed?
   NO (|skew| < 0.5) → Just standardize
   YES → Continue to step 4

4. Choose transformation:
   All values > 0 + skew > 1 → step_BoxCox() or step_log()
   Contains zeros/negatives + skew > 1 → step_YeoJohnson()
   Moderate skew (0.5-1.0) → step_sqrt() or step_normalize()

5. Is relationship non-linear?
   Smooth curve → step_ns(deg_free = 3-5)
   With breakpoints → Consider GAM or hinge functions
   Linear → No basis expansion needed

My choice: _______________
Implementation:
```r
recipe(outcome ~ ., data = train) |>
  _______________(___) # Chosen transformation
```
```

### Interaction Detection

```
□ Number of predictors: _____

□ Do you expect interactions?
  □ Yes, domain knowledge suggests specific pairs
  □ Yes, but unsure which ones
  □ No strong expectation

Decision:

If <20 predictors AND have domain knowledge:
  → Manual specification: step_interact(~ var1:var2)

If 20-50 predictors:
  → Random forest importance → test top 10 pairs

If >50 predictors:
  → Two-stage: Lasso main effects → FSA interactions

If uncertain:
  → Start with RF importance screening

My approach: _______________
Expected interactions to test: _______________
```

### Feature Selection

```
□ Number of predictors initially: _____
□ Sample size: _____
□ Ratio (n/p): _____

Decision flowchart:

1. Is p > 1000?
   YES → Start with filter methods (step_corr, step_zv)
   NO → Continue

2. Is interpretability critical?
   YES → Use RFE or forward selection (if p < 50)
   NO → Continue to step 3

3. What's your computational budget?
   LOW → Embedded (Lasso/elastic net)
   MEDIUM → RFE with sensible subset sizes
   HIGH → Genetic algorithm for global optimum

4. Do you need the absolute best subset?
   YES + p < 30 → Genetic algorithm
   YES + p > 30 → Hybrid (filter → lasso → RFE)
   NO → Lasso/elastic net

My strategy: _______________
Target number of features: _____ (___% of original)

Implementation plan:
□ Step 1: _______________
□ Step 2: _______________
□ Step 3: _______________
```

### Missing Data

```
For variables with missing data:

Variable: _______________ (___% missing)

□ Missing data mechanism:
  □ MCAR (completely at random)
  □ MAR (depends on observed variables)
  □ MNAR (depends on unobserved)
  □ Unknown

□ Is missingness predictive of outcome?
  Test: Create `missing_indicator` and check association
  Result: _______________ (yes/no)

Decision:

If missingness is predictive:
  → step_indicate_na() + imputation

If MCAR + <5% missing:
  → Simple imputation (median/mode)

If MAR:
  → Model-based (step_impute_knn or step_impute_bag)

If MNAR or high % missing:
  → Domain expert consultation + step_indicate_na()

My choice: _______________
Implementation:
```r
recipe(outcome ~ ., data = train) |>
  step_indicate_na(___, prefix = "missing_") |>  # If needed
  step_impute_____(___)  # Chosen method
```
```

---

## Phase 4: Recipe Assembly

### Recommended Step Order

```r
feature_recipe <- recipe(outcome ~ ., data = train) |>

  # 1. ROLE ASSIGNMENT
  update_role(id, new_role = "ID") |>

  # 2. MISSING DATA HANDLING
  # Add if missingness is informative:
  # step_indicate_na(all_predictors(), prefix = "missing_") |>
  step_impute_____() |>  # Your imputation method

  # 3. FEATURE CREATION
  step_mutate(
    # Custom features based on domain knowledge
  ) |>

  # 4. INTERACTION TERMS (if applicable)
  # step_interact(~ var1:var2) |>

  # 5. NUMERIC TRANSFORMATIONS
  step_____() |>  # Box-Cox, Yeo-Johnson, log, etc.

  # 6. CATEGORICAL ENCODING PREP
  step_novel(all_nominal_predictors()) |>
  step_other(all_nominal_predictors(), threshold = 0.05) |>

  # 7. CATEGORICAL ENCODING
  step_____() |>  # Your chosen encoding method

  # 8. REMOVE ZERO-VARIANCE (after encoding!)
  step_zv(all_predictors()) |>

  # 9. STANDARDIZATION (if needed)
  step_normalize(all_numeric_predictors()) |>

  # 10. FEATURE SELECTION
  step_corr(all_numeric_predictors(), threshold = 0.9) |>

  # 11. DIMENSIONALITY REDUCTION (if needed)
  # step_pca(all_numeric_predictors(), threshold = 0.95) |>
```

---

## Phase 5: Validation Checklist

Before finalizing your feature engineering:

```
□ Recipe is NOT prepped outside of workflow
□ All preprocessing derived from training data only
□ Novel category handling included (step_novel)
□ Zero-variance removal AFTER dummy encoding
□ Validation uses fit_resamples() not manual prep/bake
□ Transformations match model requirements
□ Feature selection happens inside CV (if using wrapper methods)
□ No data leakage possible
□ Target encoding (if used) isolated per fold
□ Recipe steps in correct order

□ Tested recipe on small sample:
  □ prep() succeeds without errors
  □ bake() produces expected columns
  □ No NA values introduced unexpectedly
  □ Predictor count reasonable

□ Cross-validation performance:
  □ No warning messages about singular matrices
  □ No extreme variance in metrics across folds
  □ Performance better than unpreprocessed baseline

□ Recipe documented:
  □ Rationale for each major step recorded
  □ Hyperparameters justified
  □ Comparison to alternative approaches noted
```

---

## Common Pitfalls Checklist

Avoid these mistakes:

```
❌ WRONG:
□ Fitting recipe on all data before train/test split
□ Forgetting step_novel() before dummy encoding
□ Removing zero-variance before dummy encoding
□ Binning continuous variables without strong justification
□ Using target encoding without proper CV isolation
□ Applying Box-Cox to zero/negative values
□ Normalizing before transforming skewed data
□ Using sophisticated encoding for low-cardinality variables
□ Omitting standardization for distance-based models
□ Including ID variables in recipe without update_role()

✅ CORRECT:
□ Recipe fitted separately per CV fold
□ step_novel() included for all categoricals used in production
□ step_zv() placed AFTER step_dummy()
□ Transformations applied before normalization
□ Continuous variables kept continuous when possible
□ Target encoding derived inside fit_resamples()
□ Standardization included for SVM/KNN/penalized models
□ Simple encodings for simple problems
□ ID variables given "ID" role, not used as predictors
```

---

## Documentation Template

After completing feature engineering:

```markdown
# Feature Engineering Summary

**Date**: _____
**Project**: _____
**Analyst**: _____

## Categorical Encoding Decisions

| Variable | Categories | Method | Rationale |
|----------|-----------|--------|-----------|
| ___ | ___ | ___ | ___ |

## Numeric Transformation Decisions

| Variable | Skewness | Transformation | Rationale |
|----------|----------|----------------|-----------|
| ___ | ___ | ___ | ___ |

## Feature Selection

- **Method**: ___
- **Features before**: ___
- **Features after**: ___
- **Criteria**: ___

## Interactions Included

- ___ × ___ (rationale: ___)
- ___ × ___ (rationale: ___)

## Missing Data Handling

| Variable | % Missing | Method | Indicator? |
|----------|-----------|--------|-----------|
| ___ | ___ | ___ | ___ |

## Validation Results

- **Baseline (no preprocessing)**: ___
- **With feature engineering**: ___
- **Improvement**: ___

## Alternative Approaches Considered

1. ___ (not chosen because ___)
2. ___ (not chosen because ___)
```

---

## References

- [Categorical Encoding Reference](../references/categorical-encoding.md)
- [Numeric Transformations Reference](../references/numeric-transformations.md)
- [Interaction Detection Reference](../references/interaction-detection.md)
- [Feature Selection Reference](../references/feature-selection.md)
- [Missing Data Strategies Reference](../references/missing-data-strategies.md)
