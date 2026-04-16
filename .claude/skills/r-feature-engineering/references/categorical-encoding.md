# Categorical Encoding Reference

Comprehensive guide to encoding categorical predictors in R, covering methods, trade-offs, and strategic decisions.

## Encoding Method Selection Guide

### Quick Decision Tree

```r
select_encoding <- function(n_levels, n_obs, ordinal, has_outcome, interpretability) {
  # Ordinal categories have natural ordering
  if (ordinal) {
    return(list(
      method = "step_ordinalscore()",
      package = "recipes",
      rationale = "Preserves meaningful order"
    ))
  }

  # Low cardinality: standard approach
  if (n_levels < 10) {
    return(list(
      method = "step_dummy(one_hot = FALSE)",
      package = "recipes",
      rationale = "Simple, interpretable, works with all models"
    ))
  }

  # Medium cardinality: consider sample size and outcome availability
  if (n_levels >= 10 && n_levels <= 50) {
    if (n_obs < 1000 && has_outcome) {
      return(list(
        method = "embed::step_lencode_mixed()",
        package = "embed",
        rationale = "Supervised encoding captures outcome relationship"
      ))
    } else if (n_obs >= 1000) {
      return(list(
        method = "step_other(threshold=0.05) |> step_dummy()",
        package = "recipes",
        rationale = "Pool rare categories then dummy encode"
      ))
    }
  }

  # High cardinality: advanced methods needed
  if (n_levels > 50) {
    if (n_obs < 5000 && has_outcome) {
      return(list(
        method = "embed::step_embed()",
        package = "embed",
        rationale = "Entity embeddings learn relationships"
      ))
    } else if (!interpretability) {
      return(list(
        method = "textrecipes::step_texthash()",
        package = "textrecipes",
        rationale = "Fixed-size hashing for very high cardinality"
      ))
    } else {
      return(list(
        method = "embed::step_lencode_bayes()",
        package = "embed",
        rationale = "Bayesian shrinkage for stability"
      ))
    }
  }
}
```

## Method 1: Dummy / One-Hot Encoding

### Concept

Convert categorical variable into binary indicator variables. **Reference cell encoding** creates C-1 dummy variables for C categories (drops one as reference). **One-hot encoding** creates C variables (keeps all categories).

### When to Use

✅ **Good for:**
- Low to moderate cardinality (2-20 categories)
- When interpretability of individual categories matters
- Most standard statistical models (linear regression, logistic regression)
- Tree-based models (though ordinal also works)

❌ **Avoid when:**
- Very high cardinality (100s of categories)
- Memory-constrained environments
- Many rare categories present

### Implementation

```r
library(recipes)
library(tidymodels)

# Reference cell encoding (default) - drops one level
recipe(outcome ~ ., data = train) |>
  step_dummy(all_nominal_predictors(), one_hot = FALSE)

# One-hot encoding - keeps all levels
recipe(outcome ~ ., data = train) |>
  step_dummy(all_nominal_predictors(), one_hot = TRUE)

# Control reference level manually
recipe(outcome ~ ., data = train) |>
  step_relevel(day_of_week, ref_level = "Monday") |>
  step_dummy(day_of_week)
```

### Handling Rare and Novel Categories

```r
# Pool rare categories before dummy encoding
recipe(outcome ~ ., data = train) |>
  step_novel(all_nominal_predictors()) |>        # Handle novel levels in test
  step_other(all_nominal_predictors(),
             threshold = 0.05,                    # Categories < 5% → "other"
             other = "rare") |>
  step_dummy(all_nominal_predictors())
```

**Rule of thumb**: A frequency ratio of 19:1 (most common vs second most common) indicates a category is "too rare" and should be pooled.

### Zero-Variance Predictors

During resampling, some dummy variables may have all zeros (category never appears in a fold). Always remove these:

```r
recipe(outcome ~ ., data = train) |>
  step_dummy(all_nominal_predictors()) |>
  step_zv(all_predictors())  # Remove zero-variance AFTER dummy encoding
```

### Advantages

- ✅ Simple and widely understood
- ✅ Direct interpretation: coefficient = effect of that category
- ✅ Compatible with nearly all modeling algorithms
- ✅ No assumptions about category relationships

### Disadvantages

- ❌ Creates many predictors with high cardinality
- ❌ Sparse matrices (mostly zeros) with many categories
- ❌ Doesn't capture similarity between categories
- ❌ Novel categories in test set cause errors (need `step_novel()`)

---

## Method 2: Ordinal Encoding

### Concept

For ordered categories, encode as numeric scores reflecting the natural progression (e.g., "Bad"=1, "Good"=2, "Better"=3).

### When to Use

✅ **Good for:**
- Clear meaningful ordering exists (education levels, ratings, severity)
- Want to preserve ordinality in a single numeric variable
- Tree-based models (splits respect ordering)

❌ **Avoid when:**
- No natural ordering
- Spacing between levels not equal
- Non-linear effects between adjacent categories

### Implementation

```r
# For ordered factors in R
recipe(outcome ~ ., data = train) |>
  step_ordinalscore(education_level)  # Converts ordered factor to integer

# For unordered factors, manually specify order
recipe(outcome ~ ., data = train) |>
  step_mutate(
    education_ord = factor(education,
                          levels = c("HS", "Bachelor", "Master", "PhD"),
                          ordered = TRUE)
  ) |>
  step_ordinalscore(education_ord)
```

### Advantages

- ✅ Preserves ordinality
- ✅ Single numeric variable (no expansion)
- ✅ Works well with tree-based models
- ✅ Interpretable as "more" or "less"

### Disadvantages

- ❌ Assumes equal spacing between levels (may not be true)
- ❌ Linear assumption (effect of jump from 1→2 same as 2→3)
- ❌ Doesn't work for nominal categories

---

## Method 3: Likelihood / Target Encoding

### Concept

Replace each category with a statistic calculated from the outcome:
- **Classification**: Log-odds from logistic regression
- **Regression**: Mean or median outcome value

This creates a supervised encoding that captures the category-outcome relationship.

### When to Use

✅ **Good for:**
- Medium to high cardinality (10-100 categories)
- Strong outcome relationship expected
- Need single numeric value per category
- Interpretability as "effect size" desired

❌ **Avoid when:**
- Small sample sizes per category (high overfitting risk)
- No access to outcome (unsupervised tasks)
- When avoiding target leakage is difficult

### Implementation

```r
library(embed)

# Likelihood encoding for classification
recipe(churn ~ ., data = train) |>
  embed::step_lencode_glm(
    neighborhood,
    outcome = vars(churn)
  )

# With Bayesian shrinkage (recommended)
recipe(churn ~ ., data = train) |>
  embed::step_lencode_bayes(
    neighborhood,
    outcome = vars(churn)
  )

# Mixed effects encoding (best for small groups)
recipe(churn ~ ., data = train) |>
  embed::step_lencode_mixed(
    neighborhood,
    outcome = vars(churn)
  )
```

### Preventing Data Leakage

**Critical**: Never fit encoding on the same data used for modeling!

```r
# ❌ WRONG: Encoding sees test data
rec <- recipe(outcome ~ ., data = all_data) |>
  embed::step_lencode_mixed(category, outcome = vars(outcome)) |>
  prep()

# ✅ CORRECT: Encoding derived inside resampling
workflow() |>
  add_recipe(
    recipe(outcome ~ ., data = train) |>
      embed::step_lencode_mixed(category, outcome = vars(outcome))
  ) |>
  add_model(model_spec) |>
  fit_resamples(vfold_cv(train, v = 10))  # Encoding fitted per fold
```

### Handling Novel Categories

```r
# Novel categories get posterior mean (Bayesian) or overall effect
recipe(outcome ~ ., data = train) |>
  embed::step_lencode_bayes(
    location,
    outcome = vars(outcome)
  )
# New location in test → assigned overall posterior mean from training
```

### Bayesian Shrinkage

For categories with small sample sizes, shrinkage pulls extreme estimates toward the overall mean:

```r
# Example: Category with 2 observations and 100% churn rate
# Without shrinkage: Encoding = log(∞) (unstable!)
# With shrinkage: Encoding ≈ 1.5 (blend of category + prior)

# Formula: Shrunk estimate = (n_cat × cat_mean + n_prior × prior_mean) / (n_cat + n_prior)
```

**Why shrinkage helps**: "If the quality of the data within a factor level is poor, then this level's effect estimate can be biased towards an overall estimate."

### Advantages

- ✅ Highly predictive (captures outcome relationship)
- ✅ Single numeric value per category (no explosion)
- ✅ Handles novel categories naturally
- ✅ Interpretable as effect size
- ✅ Bayesian version stabilizes rare categories

### Disadvantages

- ❌ High overfitting risk if not properly isolated in CV
- ❌ Requires outcome variable (supervised only)
- ❌ Summary statistics underestimate within-category variation
- ❌ Can create self-fulfilling prophecy without proper validation

---

## Method 4: Entity Embeddings

### Concept

Use a neural network to learn low-dimensional numeric representations of categories. The network optimizes both the category→embedding mapping and the embeddings→outcome relationship jointly.

### When to Use

✅ **Good for:**
- High cardinality categorical predictors
- Complex non-linear relationships
- Multiple correlated categorical variables
- Sufficient computational resources available

❌ **Avoid when:**
- Small datasets (risk of overfitting)
- Interpretability is critical
- Limited computational budget
- Simple linear relationships suffice

### Implementation

```r
library(embed)

# Entity embeddings
recipe(price ~ ., data = train) |>
  step_dummy(low_cardinality_vars) |>  # Dummy encode simple ones
  embed::step_embed(
    neighborhood,                       # High-cardinality variable
    outcome = vars(price),
    num_terms = 3,                      # Number of embedding dimensions
    hidden_units = 10,                  # Hidden layer size
    options = embed_control(
      epochs = 30,
      validation_split = 0.2
    )
  )
```

### Choosing Number of Embedding Dimensions

Common heuristics:
- `num_terms = ceiling(n_categories^0.25)` (rule of thumb)
- `num_terms = min(50, (n_categories + 1) / 2)` (fastai default)
- Try 2-10 dimensions for most applications

### Advantages

- ✅ Automatically discovers semantic relationships
- ✅ Substantial dimensionality reduction (50 categories → 3-5 features)
- ✅ Can learn interactions with other predictors
- ✅ Handles novel categories via placeholder node
- ✅ Often more predictive than manual encodings

### Disadvantages

- ❌ Computationally expensive (requires neural network training)
- ❌ Black box (hard to interpret learned embeddings)
- ❌ Requires careful hyperparameter tuning
- ❌ Needs sufficient data to learn meaningful representations
- ❌ More complex implementation

### Interpreting Embeddings

```r
# Extract learned embeddings after training
trained_rec <- prep(recipe_with_embeddings, training = train)
embedding_values <- tidy(trained_rec, number = N)  # N = step number

# Visualize in 2D
embedding_values |>
  ggplot(aes(value1, value2, label = level)) +
  geom_text() +
  labs(title = "Learned Category Embeddings")
```

Categories that are "similar" (in terms of outcome relationship) will be close together in embedding space.

---

## Method 5: Feature Hashing

### Concept

Map potentially unlimited categories to a fixed-size set of hash features using deterministic hash functions:
```
hash_value = (hash_function(category) mod n_features) + 1
```

Multiple categories may "collide" (map to same hash value), but this is acceptable for high-cardinality scenarios.

### When to Use

✅ **Good for:**
- Very high cardinality (1000s of categories)
- Text data / natural language (unknown vocabulary size)
- Memory-constrained applications
- Online learning (new categories arrive continuously)

❌ **Avoid when:**
- Low cardinality (dummy encoding better)
- Interpretability required
- Collisions would be problematic

### Implementation

```r
library(textrecipes)

# Binary hashing (produces 0 or 1)
recipe(outcome ~ ., data = train) |>
  textrecipes::step_texthash(
    high_card_category,
    signed = FALSE,
    num_terms = 64  # Number of hash features (use powers of 2)
  )

# Signed hashing (produces -1, 0, or 1) - reduces collisions
recipe(outcome ~ ., data = train) |>
  textrecipes::step_texthash(
    high_card_category,
    signed = TRUE,
    num_terms = 128
  )
```

### Choosing Number of Hash Features

- **Rule of thumb**: `num_terms = 2^k` where `2^k ≈ sqrt(n_categories)`
- Example: 10,000 ZIP codes → try 128 or 256 hash features
- Trade-off: More features = fewer collisions but larger data

### Advantages

- ✅ Fixed memory footprint regardless of cardinality
- ✅ Handles unlimited novel categories automatically
- ✅ Deterministic and reproducible
- ✅ Very fast (O(1) lookup)
- ✅ No vocabulary storage needed

### Disadvantages

- ❌ Collisions unavoidable (multiple categories → same hash)
- ❌ Zero interpretability (can't reverse hash to category)
- ❌ Uniform distribution may not be ideal for modeling
- ❌ Rare and frequent categories may collide

### Collision Analysis

```r
# Estimate collision rate
n_categories <- 1000
n_hash_features <- 64
expected_collisions <- n_categories - n_hash_features *
  (1 - (1 - 1/n_hash_features)^n_categories)

# For 1000 categories → 64 features: ~46% will collide
```

**Mitigation**: Use signed hashing (produces -1, 0, +1) to reduce collision impact.

---

## Comparison Table

| Method | Cardinality | Output Size | Supervised | Interpretable | Handles Novel | Overfitting Risk |
|--------|-------------|-------------|------------|---------------|---------------|------------------|
| **Dummy** | Low (<20) | C-1 or C | No | ⭐⭐⭐⭐⭐ | Via `step_novel()` | Low |
| **Ordinal** | Low (<10) | 1 | No | ⭐⭐⭐⭐ | Same scale | Low |
| **Likelihood** | Med (10-100) | 1 | Yes | ⭐⭐⭐ | Via prior | Medium |
| **Embeddings** | High (>50) | k (e.g., 3-10) | Yes | ⭐ | Via placeholder | Medium |
| **Hashing** | Very High (>100) | Fixed (e.g., 64) | No | None | Automatic | Low |

---

## Best Practices

### 1. Always Handle Novel Categories

```r
# Before any encoding, add novel level handling
recipe(outcome ~ ., data = train) |>
  step_novel(all_nominal_predictors(), new_level = "unseen") |>
  step_other(all_nominal_predictors(), threshold = 0.05) |>
  [encoding step here]
```

### 2. Validate Encodings Inside Resampling

```r
# ✅ CORRECT: Recipe fitted separately per fold
workflow() |>
  add_recipe(recipe_with_encoding) |>
  fit_resamples(vfold_cv(train))

# ❌ WRONG: Recipe prepped before CV
prepped_recipe <- prep(recipe_with_encoding, train)
# Now validation folds see training data!
```

### 3. Pool Rare Categories

```r
# Categories appearing < 5% of the time → "other"
recipe(outcome ~ ., data = train) |>
  step_other(neighborhood, threshold = 0.05, other = "rare")
```

### 4. Remove Zero-Variance After Encoding

```r
recipe(outcome ~ ., data = train) |>
  step_dummy(all_nominal_predictors()) |>
  step_zv(all_predictors())  # Must come AFTER dummy encoding
```

### 5. Match Encoding to Model Type

```r
# Tree-based models: simple encoding sufficient
if (model_type == "random_forest") {
  recipe(...) |> step_dummy()  # or step_ordinalscore()
}

# Linear/distance-based: consider sophisticated encoding
if (model_type %in% c("glmnet", "svm")) {
  recipe(...) |> embed::step_lencode_mixed()
}
```

---

## Common Pitfalls

### ❌ Pitfall 1: Data Leakage via Encoding

```r
# WRONG: Encoding sees test outcome
all_data_encoded <- all_data |>
  group_by(category) |>
  mutate(category_mean = mean(outcome))  # Leakage!

train <- all_data_encoded[train_idx, ]
test <- all_data_encoded[test_idx, ]  # Test "knows" its own outcome
```

### ❌ Pitfall 2: Forgetting Novel Categories

```r
# WRONG: Test category not in training → ERROR
recipe(outcome ~ ., data = train) |>
  step_dummy(city) |>
  prep() |>
  bake(test)  # Error if test has new city!

# CORRECT: Add novel handling
recipe(outcome ~ ., data = train) |>
  step_novel(city) |>
  step_dummy(city)
```

### ❌ Pitfall 3: Wrong Encoding for Ordinal Data

```r
# WRONG: Dummy encoding loses ordering
recipe(outcome ~ ., data = train) |>
  step_dummy(education_level)  # "HS", "Bachelor", "Master" → independent

# CORRECT: Preserve ordering
recipe(outcome ~ ., data = train) |>
  step_ordinalscore(education_level)  # 1, 2, 3 preserves order
```

---

## Case Study: OkCupid Dataset

**Problem**: Predict STEM vs non-STEM profiles based on location (52 categories, sample sizes 1-6000 per location).

**Encoding Comparison**:

| Method | Test Accuracy | Interpretability | Notes |
|--------|---------------|------------------|-------|
| Dummy | 71.2% | High | Baseline; many predictors |
| Likelihood (GLM) | 74.8% | Medium | Simple supervised encoding |
| Likelihood (Bayes) | 75.1% | Medium | Shrinkage helps rare locations |
| Entity Embeddings | 75.9% | Low | 3 learned dimensions; best accuracy |
| Feature Hashing | 73.5% | None | 32 hash features; collisions hurt |

**Takeaway**: Supervised encodings (likelihood, embeddings) outperformed unsupervised (dummy, hashing) by capturing location-STEM relationship.

---

## Resources

- **Book**: "Feature Engineering and Selection" - Chapter 5: https://feat.engineering/05-Encoding_Categorical_Predictors.html
- **embed package**: https://embed.tidymodels.org/
- **textrecipes package**: https://textrecipes.tidymodels.org/
- **recipes package**: https://recipes.tidymodels.org/
