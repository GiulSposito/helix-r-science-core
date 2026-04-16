# Numeric Transformations Reference

Comprehensive guide to transforming numeric predictors in R for machine learning.

## Overview

Numeric transformations fall into three categories:
1. **1:1 Transformations** - Modify individual predictors
2. **1:Many Transformations** - Expand single predictor into multiple features
3. **Many:Many Transformations** - Combine multiple predictors into fewer features

## 1. One-to-One (1:1) Transformations

### Box-Cox Transformation

**Purpose**: Address skewed distributions using power transformations.

**Formula**:
```
x* = (x^λ - 1) / (λ * x̃^(λ-1))  when λ ≠ 0
x* = x̃ * log(x)                  when λ = 0
```
where x̃ is the geometric mean.

**Common λ values**:
- λ = 1: No transformation
- λ = 0: Log transformation
- λ = 0.5: Square root
- λ = -1: Inverse

**Implementation**:
```r
library(recipes)

# Box-Cox transformation
recipe(outcome ~ ., data = train) |>
  step_BoxCox(all_numeric_predictors())

# The λ parameter is automatically estimated via maximum likelihood
```

**When to Use**:
- ✅ Skewed positive-valued predictors
- ✅ Linear models, neural networks, SVMs
- ❌ NOT for tree-based models (unnecessary)
- ❌ NOT for zero or negative values (use Yeo-Johnson)

**Advantages**:
- Automatically finds optimal transformation
- Flexible family of transformations
- Reduces skewness effectively

**Disadvantages**:
- Strictly positive values required
- Can be unstable with extreme values

---

### Yeo-Johnson Transformation

**Purpose**: Like Box-Cox but handles zero and negative values.

**Implementation**:
```r
recipe(outcome ~ ., data = train) |>
  step_YeoJohnson(all_numeric_predictors())
```

**When to Use**:
- ✅ Skewed data with zeros or negatives
- ✅ More robust alternative to Box-Cox
- ✅ When unsure about data range

**Advantage over Box-Cox**: Works with any numeric values, not just positive.

---

### Log, Sqrt, Inverse Transformations

**Log Transformation**:
```r
recipe(outcome ~ ., data = train) |>
  step_log(income, base = 10, offset = 1)  # offset handles zeros
```

**When to Use**:
- Right-skewed data (long tail to right)
- Multiplicative relationships
- Common for: income, prices, counts

**Square Root**:
```r
recipe(outcome ~ ., data = train) |>
  step_sqrt(count_variable)
```

**When to Use**:
- Count data with moderate skewness
- Milder transformation than log
- Poisson-distributed variables

**Inverse Transformation**:
```r
recipe(outcome ~ ., data = train) |>
  step_inverse(rate)
```

**When to Use**:
- Rate/speed data
- Specific distributional requirements

---

### Standardization Techniques

**Centering** (subtract mean):
```r
recipe(outcome ~ ., data = train) |>
  step_center(all_numeric_predictors())
# Result: Variables have mean = 0
```

**Scaling** (divide by SD):
```r
recipe(outcome ~ ., data = train) |>
  step_scale(all_numeric_predictors())
# Result: Variables have SD = 1
```

**Normalization** (center + scale):
```r
recipe(outcome ~ ., data = train) |>
  step_normalize(all_numeric_predictors())
# Result: mean = 0, SD = 1 (z-scores)
```

**Range Scaling** (min-max):
```r
recipe(outcome ~ ., data = train) |>
  step_range(all_numeric_predictors(), min = 0, max = 1)
# Result: Values scaled to [0, 1]
```

**When to Use**:

| Transformation | Essential For | Optional For | Skip For |
|----------------|---------------|--------------|----------|
| **Normalize** | SVM, KNN, neural nets, penalized regression | Linear regression | Trees, random forests |
| **Range** | Neural networks | | Trees |
| **Center** | Interpretation, PCA | | |

**Critical Rule**: Always compute statistics from training data only, then apply to test/new data!

```r
# ✅ CORRECT: Stats from training only
rec <- recipe(outcome ~ ., data = training(split)) |>
  step_normalize(all_numeric_predictors()) |>
  prep(training = training(split))

test_normalized <- bake(rec, new_data = testing(split))

# ❌ WRONG: Stats from all data
rec <- recipe(outcome ~ ., data = all_data) |>  # LEAKAGE!
  step_normalize(all_numeric_predictors()) |>
  prep()
```

---

### Logit Transformation (for Proportions)

**Formula**:
```
logit(π) = log(π / (1-π))
```

**Implementation**:
```r
recipe(outcome ~ ., data = train) |>
  step_logit(proportion, offset = 0.001)  # Avoid division by zero
```

**When to Use**:
- Proportion/percentage data (between 0 and 1)
- Prevents predictions from violating boundaries
- Common in: survey responses, rates, probabilities

**Requirement**: Values must be strictly between 0 and 1 (use offset at extremes).

---

### Data Smoothing (Sequential Data)

**Running Median** (preferred for noisy data):
```r
# Using custom function or slider package
library(slider)

data |>
  mutate(smoothed = slide_dbl(value, median, .before = 1, .after = 1))
```

**Advantages**:
- Robust to outliers
- Preserves trends better than running mean
- ~40% of values typically unchanged (avoids over-smoothing)

**Running Mean**:
```r
data |>
  mutate(smoothed = slide_dbl(value, mean, .before = 2, .after = 2))
```

**Caution**: Window size matters - too large removes important trends.

**Critical**: Smooth training and test sets separately to prevent leakage!

---

## 2. One-to-Many (1:Many) Transformations

### Polynomial Basis Expansions

**Concept**: Create polynomial features from single predictor.

**Implementation**:
```r
recipe(outcome ~ ., data = train) |>
  step_poly(age, degree = 3)  # Creates age, age², age³
```

**When to Use**:
- Non-linear relationships
- Smooth curves
- Simple models (linear regression)

**Advantages**:
- Easy to implement
- Interpretable
- Works with linear models

**Disadvantages**:
- Assumes pattern uniform across range
- Creates correlated features
- Can overfit easily
- **Quote**: "global basis function can often be insufficient"

**Recommendation**: Use splines instead for spatially varying relationships.

---

### Natural Cubic Splines

**Concept**: Divide predictor space into regions, apply cubic polynomials within each.

**Implementation**:
```r
library(splines)

recipe(outcome ~ ., data = train) |>
  step_ns(age, deg_free = 4)  # 4 degrees of freedom
```

**Knot Placement**:
- Position at data percentiles (25th, 50th, 75th for 3 regions)
- Ensures equal data density per region
- More knots = more flexibility (but overfitting risk)

**Degrees of Freedom**:
- **Few (≤3)**: Simple trends
- **Many (>5)**: High adaptability, overfitting risk
- **Tuning**: Use cross-validation or GCV (generalized cross-validation)

**Advantages**:
- ✅ Superior to polynomials for varying relationships
- ✅ Smooth curves
- ✅ Flexible

**Disadvantages**:
- Requires choosing degrees of freedom
- Can overfit with too many knots

---

### Generalized Additive Models (GAM)

**Concept**: Extend linear models with nonlinear terms for individual predictors.

**Quote**: "Extend general linear models...to have nonlinear terms for individual predictors (and cannot model interactions)."

**Implementation**:
```r
library(mgcv)

gam_model <- gam(outcome ~ s(age) + s(income) + category, data = train)
```

**When to Use**:
- Want automatic complexity tuning per variable
- Need interpretable nonlinear effects
- Supervised approach (uses outcome)

**Advantages**:
- Adaptive per variable
- Interpretable smooth functions
- Prevents overfitting via smoothing penalty

**Disadvantages**:
- Cannot model interactions (use interaction syntax)
- More complex than simple transformations

---

### Hinge Functions & Segmented Regression

**Hinge Function Definition**:
```
h(x) = x · I(x > 0)
```
Returns x when x > 0, otherwise 0.

**Implementation** (via MARS or custom):
```r
# Using earth package (MARS)
library(earth)

mars_model <- earth(outcome ~ ., data = train, degree = 1)
```

**Application**:
- Create paired hinges at thresholds: h(x - c) and h(c - x)
- Enables distinct linear trends per segment
- Known as **ReLU** (Rectified Linear Unit) in neural networks

**When to Use**:
- Threshold effects (e.g., tax brackets, age cutoffs)
- Abrupt pattern changes
- Segmented relationships

**Advantages**:
- Captures discontinuities
- Interpretable breakpoints
- No polynomial assumptions

---

### Discretization / Binning (AVOID!)

**What It Does**: Converts continuous predictor to categorical buckets.

```r
# DON'T DO THIS routinely!
recipe(outcome ~ ., data = train) |>
  step_discretize(age, num_breaks = 5)
```

**Critical Research Finding**:
> **19% of simulations** with uninformative predictor showed **R² ≥ 20%** after binning, vs. rare high values with raw continuous data.

**Why It's Problematic**:
1. ❌ Loses nuance and precision
2. ❌ Creates artificial trends when none exist
3. ❌ Dramatically increases false positive rates
4. ❌ No objective rationale for cut-points
5. ❌ Removes information from data

**If You MUST Use Binning**:
1. ⚠️ Use as **absolute last resort**
2. ⚠️ **Include binning inside resampling** to detect overfitting
3. ⚠️ Never bin based on visual inspection
4. ⚠️ Document why continuous approach failed

```r
# IF you must bin, do it inside workflow
workflow() |>
  add_recipe(
    recipe(outcome ~ ., data = train) |>
      step_discretize(age, num_breaks = 5)  # Evaluated per fold
  ) |>
  fit_resamples(vfold_cv(train))  # Prevents overfitting detection
```

**Recommendation**: Use splines or GAM instead!

---

## 3. Many-to-Many (Many:Many) Transformations

### General Framework

**Linear Projection**: X* = XA

Where:
- X = original predictors (n × p matrix)
- A = projection matrix (p × k matrix)
- X* = new scores/components (n × k matrix)
- k < p (dimensionality reduction)

**Key Distinction**:
- **Unsupervised**: Ignores outcome (PCA, ICA)
- **Supervised**: Uses outcome to guide reduction (PLS)

---

### Principal Component Analysis (PCA)

**Objective**: Find linear combinations maximizing variance in predictor space.

**Properties**:
- First component captures maximum variance
- Subsequent components orthogonal (uncorrelated) to previous
- Total variance preserved across all components
- Each component uses ALL original predictors

**Implementation**:
```r
recipe(outcome ~ ., data = train) |>
  step_normalize(all_numeric_predictors()) |>  # REQUIRED first!
  step_pca(all_numeric_predictors(), threshold = 0.95)  # Keep 95% variance
```

**When to Use**:
- ✅ Many correlated predictors
- ✅ Want to reduce multicollinearity
- ✅ High-dimensional data
- ✅ Visualization (first 2-3 components)

**Case Study: Chicago Transit**:
- 125 stations with 94 having correlations > 0.9
- First component captured **60.4% of variance**
- Required 36 components for 95% variance

**Advantages**:
- Removes correlation between predictors
- Reduces dimensionality substantially
- Useful for models sensitive to multicollinearity

**Disadvantages**:
- **Critical limitation**: Unsupervised - "may or may not be related to the response"
- Loses interpretability
- No guarantee of improved prediction
- Must normalize predictors first

**Number of Components**:
```r
# Option 1: Variance threshold
step_pca(all_numeric_predictors(), threshold = 0.95)

# Option 2: Fixed number
step_pca(all_numeric_predictors(), num_comp = 10)
```

**Best Practice**: Use scree plot or cross-validation to choose.

---

### Partial Least Squares (PLS)

**Objective**: Find linear combinations associated with outcome (supervised).

**Key Advantage**: "Generally finds smaller and more efficient subspace" than PCA.

**Implementation**:
```r
library(mixOmics)  # or pls package

pls_recipe <- recipe(outcome ~ ., data = train) |>
  step_normalize(all_numeric_predictors()) |>
  step_pls(all_numeric_predictors(), outcome = vars(outcome), num_comp = 5)
```

**When to Use**:
- ✅ Want outcome-relevant dimensionality reduction
- ✅ Many correlated predictors
- ✅ Sufficient sample size for validation

**Tradeoff**: Requires larger datasets to reserve validation samples.

**Advantage over PCA**: Directly focused on prediction, not just variance.

---

### Alternative Projection Methods

**Independent Component Analysis (ICA)**:
```r
library(embed)

recipe(outcome ~ ., data = train) |>
  step_ica(all_numeric_predictors(), num_comp = 5)
```

**When to Use**:
- Non-Gaussian data
- Blind source separation
- When PCA insufficient

---

**Kernel PCA**:
```r
library(embed)

recipe(outcome ~ ., data = train) |>
  step_kpca(all_numeric_predictors(), num_comp = 5, kernel = "rbfdot")
```

**When to Use**:
- Nonlinear relationships
- Complex patterns PCA can't capture

---

**Non-Negative Matrix Factorization (NNMF)**:
```r
library(NMF)

# Constrains components to non-negative values
nmf_result <- nmf(as.matrix(train[predictors]), rank = 5)
```

**When to Use**:
- Interpretable parts-based representations
- Count data
- Image data

---

## 4. Model-Specific Guidance

### Transformation Requirements by Model Type

| Model Type | Sensitive to Skewness | Sensitive to Outliers | Needs Standardization | Sensitive to Multicollinearity |
|------------|:---------------------:|:---------------------:|:---------------------:|:------------------------------:|
| **Linear Regression** | ✅ Yes | ✅ Yes | For penalties | ✅ Yes |
| **Neural Networks** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **SVM** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **K-Nearest Neighbors** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **Penalized Regression** | ✅ Yes | ✅ Yes | ✅ Yes | No (handled) |
| **Decision Trees** | ❌ No | ❌ No | ❌ No | ❌ No |
| **Random Forests** | ❌ No | ❌ No | ❌ No | ❌ No |
| **XGBoost** | ❌ No | ❌ No | ❌ No | ❌ No |
| **Naive Bayes** | Depends | ❌ No | ❌ No | ❌ No |

### Decision Tree: Which Transformations for Which Models

```r
choose_transformations <- function(model_type, data_properties) {
  # Tree-based: minimal preprocessing
  if (model_type %in% c("random_forest", "xgboost", "decision_tree")) {
    return("No transformations needed - trees handle skewness/outliers")
  }

  # Distance-based: always standardize
  if (model_type %in% c("svm", "knn")) {
    transformations <- c("step_normalize()")

    if (data_properties$skewed) {
      transformations <- c("step_YeoJohnson()", transformations)
    }

    return(transformations)
  }

  # Linear/Neural: depends on data
  if (model_type %in% c("linear_reg", "neural_net")) {
    transformations <- c("step_normalize()")

    if (data_properties$skewed && data_properties$positive) {
      transformations <- c("step_BoxCox()", "step_normalize()")
    } else if (data_properties$skewed) {
      transformations <- c("step_YeoJohnson()", "step_normalize()")
    }

    return(transformations)
  }
}
```

---

## 5. Best Practices & Data Leakage Prevention

### Critical Rules

**Rule 1**: Estimate ALL parameters from training data only
```r
# ✅ CORRECT
split <- initial_split(data)
rec <- recipe(outcome ~ ., data = training(split)) |>
  step_BoxCox(all_numeric_predictors()) |>
  prep(training = training(split))  # Parameters from training only

test_transformed <- bake(rec, new_data = testing(split))
```

**Rule 2**: Apply saved parameters to test data
```r
# The prep() step estimates parameters
# The bake() step applies them to new data using saved parameters
```

**Rule 3**: Sequential smoothing must be separate
```r
# ✅ CORRECT: Smooth separately
train_smoothed <- train |>
  mutate(smooth_var = slide_dbl(var, median, .before = 1, .after = 1))

test_smoothed <- test |>
  mutate(smooth_var = slide_dbl(var, median, .before = 1, .after = 1))

# ❌ WRONG: Smoothing across train+test boundary creates leakage
```

**Rule 4**: Supervised methods inside resampling
```r
# PLS, GAM, binning must be done per fold
workflow() |>
  add_recipe(recipe_with_pls) |>  # PLS parameters estimated per fold
  fit_resamples(vfold_cv(train))
```

---

### Transformation Order in Recipes

**Recommended sequence**:
```r
recipe(outcome ~ ., data = train) |>
  # 1. Handle missing (if needed)
  step_impute_median(all_numeric_predictors()) |>

  # 2. Create features (before transformations!)
  step_mutate(age_squared = age^2) |>

  # 3. Transform distributions
  step_YeoJohnson(all_numeric_predictors()) |>

  # 4. Create splines/polynomials
  step_ns(age, deg_free = 4) |>

  # 5. Encode categoricals
  step_dummy(all_nominal_predictors()) |>

  # 6. Standardize (AFTER transformations, AFTER dummy encoding)
  step_normalize(all_numeric_predictors()) |>

  # 7. Dimensionality reduction (AFTER normalization)
  step_pca(all_numeric_predictors(), threshold = 0.95)
```

**Why this order**:
- Transform distributions before normalizing (normalization assumes distribution shape)
- Normalize before PCA (PCA is scale-dependent)
- Create features before transforming (interactions on original scale)

---

## Quick Reference

### Common Scenarios

**Scenario 1: Skewed income data, linear regression**
```r
recipe(salary ~ ., data = train) |>
  step_log(income, base = 10, offset = 1) |>
  step_normalize(all_numeric_predictors())
```

**Scenario 2: Mixed data, XGBoost**
```r
# No transformations needed!
recipe(outcome ~ ., data = train) |>
  step_dummy(all_nominal_predictors())  # That's it
```

**Scenario 3: Highly correlated genes, SVM**
```r
recipe(cancer ~ ., data = train) |>
  step_normalize(all_numeric_predictors()) |>
  step_pca(all_numeric_predictors(), threshold = 0.95)
```

**Scenario 4: Non-linear relationship, interpretability needed**
```r
recipe(outcome ~ ., data = train) |>
  step_ns(age, deg_free = 4) |>
  step_normalize(all_numeric_predictors())
```

---

## Resources

- **Book**: "Feature Engineering and Selection" - Chapter 6: https://feat.engineering/06-Engineering_Numeric_Predictors.html
- **recipes package**: https://recipes.tidymodels.org/
- **mgcv package** (GAM): https://cran.r-project.org/package=mgcv
- **earth package** (MARS): https://cran.r-project.org/package=earth
