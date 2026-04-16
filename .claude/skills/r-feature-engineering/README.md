# R Feature Engineering - Strategic Decisions and Selection

Expert guidance for making strategic decisions about feature engineering and selection in R.

## What This Skill Does

This skill helps you make **strategic decisions** about feature engineering - understanding **when and why** to use specific techniques, not just how to implement them.

### Key Capabilities

- **Encoding Strategy**: Choose the right categorical encoding method
- **Transformation Decisions**: Select appropriate numeric transformations
- **Interaction Detection**: Systematically find interaction effects
- **Feature Selection**: Compare filter, wrapper, and embedded methods
- **Missing Data**: Choose imputation approaches strategically

## When to Use This Skill

✅ **Use this skill when you need to:**
- Compare different encoding approaches
- Decide between transformation methods
- Systematically detect interactions
- Choose feature selection strategies
- Understand trade-offs between methods

❌ **Don't use this skill for:**
- Basic recipe implementation → Use `r-tidymodels`
- Data wrangling → Use `r-datascience` or `tidyverse-expert`
- General ML workflow → Use `r-tidymodels`

## Quick Reference

### Categorical Encoding Decision

```r
# Low cardinality (<10 levels)
step_dummy()

# Medium cardinality (10-50)
embed::step_lencode_mixed()  # Supervised encoding

# High cardinality (>50)
embed::step_embed()  # Entity embeddings
# OR
textrecipes::step_texthash()  # Feature hashing
```

### Numeric Transformation Decision

```r
# Tree-based models
# No transformation needed!

# Linear/SVM/KNN models
step_normalize()  # Always needed

# Skewed positive data
step_BoxCox()  # or step_log()

# Skewed data with zeros/negatives
step_YeoJohnson()
```

### Feature Selection Decision

```r
# Fast preprocessing (1000s of features)
step_corr() |> step_zv()  # Filter methods

# Best performance (<50 features)
caret::rfe()  # Recursive Feature Elimination

# Automatic (50-500 features)
glmnet  # Lasso/elastic net
```

## Primary Source

Based on **"Feature Engineering and Selection: A Practical Approach for Predictive Models"** by Max Kuhn and Kjell Johnson.

- **Website**: https://feat.engineering/
- **GitHub**: https://github.com/topepo/FES
- **License**: Creative Commons (freely available)

## Skill Structure

```
r-feature-engineering/
├── SKILL.md                              # Main instructions
├── README.md                             # This file
├── references/
│   ├── categorical-encoding.md           # Complete encoding guide
│   ├── numeric-transformations.md        # Transformation strategies
│   ├── interaction-detection.md          # Finding interactions
│   ├── missing-data-strategies.md        # Missing data approaches
│   └── feature-selection.md              # Selection methods
├── examples/
│   ├── encoding-comparison.md            # Real-world encoding comparison
│   ├── interaction-workflow.md           # Systematic interaction detection
│   └── selection-pipeline.md             # Feature selection pipeline
└── templates/
    └── feature-engineering-checklist.md  # Decision checklist
```

## Core Philosophy

1. **Re-representation First** - Better features often beat better models
2. **Domain Knowledge Matters** - Statistical methods guide, but domain expertise decides
3. **Validate Everything** - All feature engineering must happen inside resampling
4. **Interpretability vs Performance** - Understand the trade-off for your use case
5. **Prevent Data Leakage** - Derive all parameters from training data only

## Common Questions

### "Should I use dummy encoding or target encoding?"

It depends on cardinality and sample size:
- **Low cardinality (<10)**: Dummy encoding
- **Medium (10-50) + small data**: Target/likelihood encoding
- **High (>50)**: Entity embeddings or feature hashing

See [references/categorical-encoding.md](references/categorical-encoding.md)

### "When do I need to transform numeric predictors?"

Depends on your model:
- **Tree-based** (RF, XGBoost): No transformation needed
- **Linear models, SVM, KNN**: Standardization required
- **Skewed data + linear model**: Box-Cox or Yeo-Johnson

See [references/numeric-transformations.md](references/numeric-transformations.md)

### "How do I systematically find interactions?"

Four approaches based on problem size:
1. **Small (<20 predictors)**: Exhaustive nested model testing
2. **Medium (20-50)**: Random forest importance → test top predictors
3. **Large (>50)**: Two-stage (main effects → interactions in residuals)
4. **Very large**: Feasible Solution Algorithm (FSA)

See [references/interaction-detection.md](references/interaction-detection.md)

### "What's the best feature selection method?"

Depends on your priorities:
- **Speed** → Filter methods (`step_corr()`, `step_zv()`)
- **Balance** → Lasso/elastic net (embedded)
- **Performance** → RFE or genetic algorithms (wrapper)
- **Very high-dimensional** → Hybrid (filter → lasso → RFE)

See [references/feature-selection.md](references/feature-selection.md)

## Relationship to Other Skills

| Skill | Focus | When to Use |
|-------|-------|-------------|
| **r-feature-engineering** | Strategic decisions about feature engineering | Choosing methods, understanding trade-offs |
| **r-tidymodels** | ML workflow execution | Implementing recipes, tuning, deployment |
| **r-datascience** | Data science overview | EDA, wrangling, general analysis |
| **tidyverse-expert** | Data manipulation | dplyr, tidyr, data transformation |

## Resources

### Official Documentation
- [tidymodels.org](https://www.tidymodels.org/)
- [recipes package](https://recipes.tidymodels.org/)
- [embed package](https://embed.tidymodels.org/)
- [textrecipes package](https://textrecipes.tidymodels.org/)

### Books
- ["Feature Engineering and Selection"](https://feat.engineering/) - Max Kuhn & Kjell Johnson
- ["Tidy Modeling with R"](https://www.tmwr.org/) - Max Kuhn & Julia Silge

## Quick Start Examples

### Example 1: Encoding High-Cardinality Categorical

```r
library(tidymodels)
library(embed)

# Problem: 50+ neighborhoods, want single numeric feature
recipe(price ~ neighborhood + bedrooms, data = train) |>
  embed::step_lencode_mixed(
    neighborhood,
    outcome = vars(price)
  ) |>
  step_normalize(all_numeric_predictors())
```

### Example 2: Systematic Interaction Detection

```r
library(vip)

# Step 1: Find important predictors with random forest
rf <- rand_forest(trees = 1000) |>
  set_engine("ranger", importance = "permutation") |>
  fit(outcome ~ ., data = train)

top_vars <- vip(rf, num_features = 10)$data$Variable

# Step 2: Test interactions among top predictors
interactions <- combn(top_vars, 2, simplify = FALSE)

# Step 3: Evaluate each interaction with CV
results <- map_dfr(interactions, function(pair) {
  formula <- as.formula(paste("outcome ~", paste(pair, collapse = " * ")))

  fit_resamples(
    workflow() |>
      add_formula(formula) |>
      add_model(linear_reg()),
    resamples = vfold_cv(train, v = 10)
  ) |>
  collect_metrics() |>
  mutate(interaction = paste(pair, collapse = " * "))
})
```

### Example 3: Feature Selection Pipeline

```r
# Hybrid approach: filter → lasso → validate
library(tidymodels)

# Stage 1: Filter (remove obvious non-predictors)
filtered_recipe <- recipe(outcome ~ ., data = train) |>
  step_zv(all_predictors()) |>
  step_corr(all_numeric_predictors(), threshold = 0.95)

# Stage 2: Lasso for automatic selection
lasso_spec <- linear_reg(penalty = tune(), mixture = 1) |>
  set_engine("glmnet")

lasso_wf <- workflow() |>
  add_recipe(filtered_recipe) |>
  add_model(lasso_spec)

# Tune to find optimal penalty
lasso_tune <- tune_grid(
  lasso_wf,
  resamples = vfold_cv(train, v = 10),
  grid = 20
)

# Stage 3: Finalize and evaluate
best_lasso <- select_best(lasso_tune, metric = "rmse")
final_wf <- finalize_workflow(lasso_wf, best_lasso)
final_fit <- last_fit(final_wf, initial_split(train))
```

## Tips and Best Practices

### ✅ DO

- Fit all feature engineering inside cross-validation
- Use `step_novel()` before encoding to handle new categories
- Remove zero-variance predictors after dummy encoding
- Match encoding complexity to cardinality
- Consider interpretability vs performance trade-off

### ❌ DON'T

- Fit recipes on all data before splitting
- Forget to handle novel categories
- Use binning/discretization as first resort
- Apply transformations to tree-based models unnecessarily
- Use target encoding without proper CV isolation

## Version

- **Version**: 1.0.0
- **Last Updated**: 2026-03-11
- **Based on**: Feature Engineering and Selection (feat.engineering)
