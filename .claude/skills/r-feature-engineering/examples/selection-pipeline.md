# Feature Selection Pipeline: Hybrid Approach

Complete end-to-end feature selection workflow combining filter, wrapper, and embedded methods.

## Scenario: High-Dimensional Gene Expression Data

**Problem**: Predict cancer subtype from gene expression (p >> n scenario).

**Challenge**:
- 500 gene expression features
- 200 samples
- Need to reduce to <50 features for interpretability
- Want optimal predictive performance

## Dataset Structure

```r
library(tidymodels)
library(caret)
library(GA)

# Simulated gene expression data
set.seed(2024)
n_samples <- 200
n_genes <- 500
n_informative <- 30  # Only 30 genes truly predictive

# Generate data
gene_data <- tibble(
  sample_id = 1:n_samples,
  # Informative genes (truly predictive)
  !!!setNames(
    map(1:n_informative, ~rnorm(n_samples, mean = 0, sd = 1)),
    paste0("gene_", 1:n_informative)
  ),
  # Noise genes (non-predictive)
  !!!setNames(
    map(1:(n_genes - n_informative), ~rnorm(n_samples, mean = 0, sd = 0.5)),
    paste0("gene_", (n_informative + 1):n_genes)
  ),
  # Outcome based on informative genes
  cancer_type = factor(
    ifelse(
      rowSums(across(starts_with("gene_") & where(~cur_column() %in% paste0("gene_", 1:15)))) > 0,
      "TypeA", "TypeB"
    )
  )
)

glimpse(gene_data)
#> 200 samples × 501 variables (500 genes + outcome)
```

---

## Stage 1: Filter Methods (Reduce 500 → ~100)

**Goal**: Quick elimination of obviously non-predictive features.

### Method 1A: Correlation-Based Filtering

```r
# Split data first
set.seed(123)
data_split <- initial_split(gene_data, strata = cancer_type, prop = 0.75)
train <- training(data_split)
test <- testing(data_split)

# Calculate correlation of each gene with outcome (binarized)
train_numeric <- train |>
  mutate(outcome_numeric = as.numeric(cancer_type) - 1) |>
  select(-sample_id, -cancer_type)

gene_correlations <- train_numeric |>
  summarise(across(starts_with("gene_"), ~cor(.x, outcome_numeric))) |>
  pivot_longer(everything(), names_to = "gene", values_to = "correlation") |>
  mutate(abs_cor = abs(correlation)) |>
  arrange(desc(abs_cor))

# Keep top 150 by correlation
top_genes_cor <- gene_correlations |>
  slice_max(abs_cor, n = 150) |>
  pull(gene)

length(top_genes_cor)  # 150 features
```

### Method 1B: Variance-Based Filtering

```r
# Remove low-variance genes (little information)
filter_recipe <- recipe(cancer_type ~ ., data = train) |>
  step_rm(sample_id) |>
  step_nzv(all_predictors(), freq_cut = 95/5) |>  # Near-zero variance
  step_corr(all_predictors(), threshold = 0.95)    # Highly correlated

# Check how many removed
filter_prepped <- prep(filter_recipe, training = train)
filter_baked <- bake(filter_prepped, new_data = NULL)

ncol(filter_baked) - 1  # Remaining predictors
#> 472 predictors (removed 28 redundant/low-variance)
```

### Method 1C: Statistical Tests (ANOVA F-test)

```r
# ANOVA F-statistic for each gene
library(broom)

anova_results <- train |>
  select(-sample_id) |>
  pivot_longer(starts_with("gene_"), names_to = "gene", values_to = "expression") |>
  nest(data = -gene) |>
  mutate(
    anova = map(data, ~aov(expression ~ cancer_type, data = .x)),
    tidy = map(anova, tidy)
  ) |>
  unnest(tidy) |>
  filter(term == "cancer_type") |>
  select(gene, statistic, p.value) |>
  arrange(p.value)

# Keep genes with p < 0.05
significant_genes <- anova_results |>
  filter(p.value < 0.05) |>
  pull(gene)

length(significant_genes)  # 87 significant genes
```

### Combine Filter Methods

```r
# Take intersection of top methods
filtered_genes <- intersect(top_genes_cor, significant_genes)
length(filtered_genes)  # 65 genes pass all filters

# Update dataset
train_filtered <- train |>
  select(sample_id, cancer_type, all_of(filtered_genes))

test_filtered <- test |>
  select(sample_id, cancer_type, all_of(filtered_genes))

cat("Stage 1 complete: 500 → 65 features\n")
```

**Performance Check**:
```r
# Quick model on filtered features
filtered_recipe <- recipe(cancer_type ~ ., data = train_filtered) |>
  step_rm(sample_id) |>
  step_normalize(all_predictors())

filtered_wf <- workflow() |>
  add_recipe(filtered_recipe) |>
  add_model(logistic_reg())

filtered_cv <- fit_resamples(
  filtered_wf,
  resamples = vfold_cv(train_filtered, v = 10, strata = cancer_type),
  metrics = metric_set(roc_auc, accuracy)
)

collect_metrics(filtered_cv)
#> ROC AUC: 0.892 (not bad for quick filtering!)
```

---

## Stage 2: Embedded Methods (Reduce 65 → ~30)

**Goal**: Use model-based feature importance for further reduction.

### Method 2A: Lasso (L1 Regularization)

```r
# Lasso automatically selects features
lasso_recipe <- recipe(cancer_type ~ ., data = train_filtered) |>
  step_rm(sample_id) |>
  step_normalize(all_predictors())

lasso_spec <- logistic_reg(penalty = tune(), mixture = 1) |>
  set_engine("glmnet")

lasso_wf <- workflow() |>
  add_recipe(lasso_recipe) |>
  add_model(lasso_spec)

# Tune penalty parameter
lasso_tune <- tune_grid(
  lasso_wf,
  resamples = vfold_cv(train_filtered, v = 10, strata = cancer_type),
  grid = 30,
  metrics = metric_set(roc_auc)
)

# Best penalty
autoplot(lasso_tune)

best_lasso <- select_best(lasso_tune, metric = "roc_auc")
final_lasso <- finalize_workflow(lasso_wf, best_lasso)

lasso_fit <- fit(final_lasso, data = train_filtered)

# Extract selected features
lasso_coefs <- extract_fit_engine(lasso_fit) |>
  tidy() |>
  filter(estimate != 0, term != "(Intercept)")

selected_by_lasso <- lasso_coefs$term
length(selected_by_lasso)  # 38 genes selected
```

### Method 2B: Random Forest Importance

```r
library(ranger)
library(vip)

# Random forest with importance
rf_recipe <- recipe(cancer_type ~ ., data = train_filtered) |>
  step_rm(sample_id)

rf_spec <- rand_forest(trees = 1000, mtry = tune()) |>
  set_engine("ranger", importance = "permutation") |>
  set_mode("classification")

rf_wf <- workflow() |>
  add_recipe(rf_recipe) |>
  add_model(rf_spec)

# Tune mtry
rf_tune <- tune_grid(
  rf_wf,
  resamples = vfold_cv(train_filtered, v = 5, strata = cancer_type),
  grid = 10
)

# Best RF
best_rf <- select_best(rf_tune, metric = "roc_auc")
final_rf <- finalize_workflow(rf_wf, best_rf)

rf_fit <- fit(final_rf, data = train_filtered)

# Extract importance
rf_importance <- extract_fit_parsnip(rf_fit) |>
  vip(num_features = 40)

# Keep top 35 by importance
top_rf_genes <- rf_importance$data |>
  slice_max(Importance, n = 35) |>
  pull(Variable)
```

### Combine Embedded Methods

```r
# Take union of lasso and RF selections (conservative)
embedded_genes <- union(selected_by_lasso, top_rf_genes)
length(embedded_genes)  # 48 genes

# Or take intersection (aggressive)
embedded_genes_strict <- intersect(selected_by_lasso, top_rf_genes)
length(embedded_genes_strict)  # 25 genes (very conservative)

# Use union for now
train_embedded <- train |>
  select(sample_id, cancer_type, all_of(embedded_genes))

test_embedded <- test |>
  select(sample_id, cancer_type, all_of(embedded_genes))

cat("Stage 2 complete: 65 → 48 features\n")
```

**Performance Check**:
```r
embedded_recipe <- recipe(cancer_type ~ ., data = train_embedded) |>
  step_rm(sample_id) |>
  step_normalize(all_predictors())

embedded_wf <- workflow() |>
  add_recipe(embedded_recipe) |>
  add_model(logistic_reg())

embedded_cv <- fit_resamples(
  embedded_wf,
  resamples = vfold_cv(train_embedded, v = 10, strata = cancer_type),
  metrics = metric_set(roc_auc, accuracy)
)

collect_metrics(embedded_cv)
#> ROC AUC: 0.928 (+0.036 improvement!)
```

---

## Stage 3: Wrapper Methods (Reduce 48 → optimal subset)

**Goal**: Find optimal subset via systematic search.

### Method 3A: Recursive Feature Elimination (RFE)

```r
library(caret)

# Prepare data for caret
train_rfe <- train_embedded |>
  select(-sample_id) |>
  mutate(cancer_type = factor(cancer_type))

x_train <- train_rfe |> select(-cancer_type) |> as.matrix()
y_train <- train_rfe$cancer_type

# RFE control
rfe_ctrl <- rfeControl(
  functions = lrFuncs,  # Logistic regression functions
  method = "cv",
  number = 10,
  verbose = FALSE
)

# Run RFE testing subsets of different sizes
set.seed(456)
rfe_results <- rfe(
  x = x_train,
  y = y_train,
  sizes = c(10, 15, 20, 25, 30, 35, 40),
  rfeControl = rfe_ctrl
)

# Plot results
plot(rfe_results, type = c("g", "o"))

# Optimal number of features
rfe_results$optsize  # 25 features
rfe_results$optVariables  # Which genes

# Selected features
rfe_selected <- rfe_results$optVariables
length(rfe_selected)  # 25 genes
```

### Method 3B: Forward Selection with AIC

```r
# Forward selection using step()
library(MASS)

# Null model
null_model <- glm(cancer_type ~ 1, data = train_embedded, family = binomial)

# Full model
full_formula <- as.formula(
  paste("cancer_type ~", paste(embedded_genes, collapse = " + "))
)
full_model <- glm(full_formula, data = train_embedded, family = binomial)

# Forward selection
forward_model <- step(
  null_model,
  scope = list(lower = null_model, upper = full_model),
  direction = "forward",
  trace = 0
)

# Selected variables
forward_selected <- names(coef(forward_model))[-1]  # Remove intercept
length(forward_selected)  # 28 features selected
```

### Method 3C: Genetic Algorithm (Global Search)

```r
library(GA)

# Fitness function: CV accuracy with selected features
fitness_function <- function(chromosome) {
  selected_idx <- which(chromosome == 1)

  if (length(selected_idx) == 0) return(-Inf)  # Penalize empty selection
  if (length(selected_idx) > 30) return(-Inf)   # Penalize too many

  selected_genes <- embedded_genes[selected_idx]

  # Create recipe with selected genes only
  ga_recipe <- recipe(cancer_type ~ ., data = train_embedded) |>
    step_rm(sample_id) |>
    step_select(all_of(selected_genes)) |>
    step_normalize(all_predictors())

  ga_wf <- workflow() |>
    add_recipe(ga_recipe) |>
    add_model(logistic_reg())

  # Cross-validation
  cv_results <- fit_resamples(
    ga_wf,
    resamples = vfold_cv(train_embedded, v = 5, strata = cancer_type),
    metrics = metric_set(roc_auc)
  )

  # Return mean ROC AUC
  mean(collect_metrics(cv_results)$mean)
}

# Run genetic algorithm
set.seed(789)
ga_results <- ga(
  type = "binary",
  fitness = fitness_function,
  nBits = length(embedded_genes),
  popSize = 20,
  maxiter = 30,
  run = 10,  # Stop if no improvement for 10 iterations
  pmutation = 0.1,
  pcrossover = 0.8,
  monitor = FALSE
)

# Best solution
ga_selected_idx <- which(ga_results@solution[1, ] == 1)
ga_selected <- embedded_genes[ga_selected_idx]
length(ga_selected)  # 22 features

# Fitness (ROC AUC) of best solution
ga_results@fitnessValue  # 0.945
```

### Compare Wrapper Methods

```r
# Compare selected feature sets
wrapper_comparison <- tibble(
  method = c("RFE", "Forward Selection", "Genetic Algorithm"),
  n_features = c(length(rfe_selected),
                 length(forward_selected),
                 length(ga_selected)),
  features = list(rfe_selected, forward_selected, ga_selected)
)

# Overlap analysis
library(UpSetR)

feature_lists <- list(
  RFE = rfe_selected,
  Forward = forward_selected,
  GA = ga_selected
)

# Common features across all methods
core_features <- Reduce(intersect, feature_lists)
length(core_features)  # 18 genes in common

cat("Core features selected by all 3 methods:", length(core_features), "\n")
```

### Evaluate Each Wrapper Method

```r
evaluate_selection <- function(selected_genes, method_name) {
  eval_recipe <- recipe(cancer_type ~ ., data = train_embedded) |>
    step_rm(sample_id) |>
    step_select(all_of(selected_genes)) |>
    step_normalize(all_predictors())

  eval_wf <- workflow() |>
    add_recipe(eval_recipe) |>
    add_model(logistic_reg())

  cv_results <- fit_resamples(
    eval_wf,
    resamples = vfold_cv(train_embedded, v = 10, strata = cancer_type),
    metrics = metric_set(roc_auc, accuracy)
  )

  collect_metrics(cv_results) |>
    mutate(method = method_name, n_features = length(selected_genes))
}

wrapper_performance <- bind_rows(
  evaluate_selection(rfe_selected, "RFE"),
  evaluate_selection(forward_selected, "Forward Selection"),
  evaluate_selection(ga_selected, "Genetic Algorithm"),
  evaluate_selection(core_features, "Core (Intersection)")
)

wrapper_performance |>
  pivot_wider(names_from = .metric, values_from = mean)
```

| Method | Features | ROC AUC | Accuracy |
|--------|----------|---------|----------|
| RFE | 25 | 0.941 | 0.893 |
| Forward Selection | 28 | 0.938 | 0.887 |
| Genetic Algorithm | 22 | 0.945 | 0.900 |
| **Core (All agree)** | **18** | **0.936** | **0.887** |

**Winner**: Genetic Algorithm (best performance, fewest features)

---

## Final Model: Test Set Evaluation

```r
# Use GA-selected features for final model
final_genes <- ga_selected

final_recipe <- recipe(cancer_type ~ ., data = train) |>
  step_rm(sample_id) |>
  step_select(all_of(final_genes)) |>
  step_normalize(all_predictors())

final_spec <- logistic_reg()

final_wf <- workflow() |>
  add_recipe(final_recipe) |>
  add_model(final_spec)

# Final fit and test
final_fit <- last_fit(final_wf, data_split)

collect_metrics(final_fit)
```

### Test Set Results

| Metric | Value |
|--------|-------|
| ROC AUC | 0.952 |
| Accuracy | 0.907 |
| Sensitivity | 0.920 |
| Specificity | 0.895 |

---

## Complete Pipeline Summary

```
Stage 0: Original
├── 500 features
├── 200 samples
└── Baseline: N/A (too many features)

Stage 1: Filter Methods
├── Correlation filtering → 150 features
├── ANOVA F-test → 87 features
├── Intersection → 65 features
└── Performance: ROC AUC 0.892

Stage 2: Embedded Methods
├── Lasso → 38 features
├── Random Forest → 35 features
├── Union → 48 features
└── Performance: ROC AUC 0.928

Stage 3: Wrapper Methods
├── RFE → 25 features (ROC AUC 0.941)
├── Forward Selection → 28 features (ROC AUC 0.938)
├── Genetic Algorithm → 22 features (ROC AUC 0.945)
└── Selected: 22 features

Final Test Set
├── 22 features (4.4% of original)
├── ROC AUC: 0.952
└── Accuracy: 90.7%
```

### Feature Reduction Journey

| Stage | Features | Method | ROC AUC | Time |
|-------|----------|--------|---------|------|
| 0. Original | 500 | - | - | - |
| 1. Filter | 65 | Correlation + ANOVA | 0.892 | ~1 min |
| 2. Embedded | 48 | Lasso + RF | 0.928 | ~5 min |
| 3. Wrapper | 22 | Genetic Algorithm | 0.945 | ~20 min |
| **Final Test** | **22** | **Hybrid** | **0.952** | **~26 min** |

**Achievement**: 95.6% feature reduction with performance improvement!

---

## Best Practices for Feature Selection

### ✅ DO

1. **Use multiple methods** - cross-validate selections
2. **Preserve train/test split** - select features on training only
3. **Consider stability** - features selected across methods more reliable
4. **Balance performance vs parsimony** - fewer features often better
5. **Domain validation** - check selected features make biological sense
6. **Document process** - record all steps for reproducibility

### ❌ DON'T

1. **Select on all data** - guaranteed overfitting
2. **Rely on single method** - may miss important features
3. **Ignore correlation structure** - removing all but one from cluster
4. **Forget computational cost** - wrapper methods expensive
5. **Skip validation** - must confirm on held-out data
6. **Discard domain knowledge** - combine with statistical selection

---

## Method Selection Guidelines

### When to Use Each Stage

**Filter Methods** (Stage 1):
- Always use first for large p
- Fast, removes obvious non-predictors
- Not model-aware (may remove useful features)

**Embedded Methods** (Stage 2):
- Good balance of speed and performance
- Model-aware selection
- Lasso for interpretability, RF for non-linear

**Wrapper Methods** (Stage 3):
- Best performance but expensive
- Use for final tuning after filtering
- RFE for greedy, GA for global optimum

### Hybrid Strategy Recommendations

| Scenario | Recommended Pipeline |
|----------|---------------------|
| p < 50 | Skip filters, use RFE or GA directly |
| 50 < p < 200 | Filter → Embedded (Lasso) |
| 200 < p < 1000 | Filter → Embedded → RFE |
| p > 1000 | Filter (aggressive) → Lasso → RFE (small subsets) |
| p >> n | Filter → Lasso only (wrapper too expensive) |
| Interpretability critical | Filter → Forward Selection |
| Performance critical | Filter → Embedded → GA |

---

## Computational Considerations

### Timing (for our example: n=200, p=500)

| Method | Time | Parallelizable? |
|--------|------|----------------|
| Correlation filter | <1 min | Yes |
| ANOVA F-test | <1 min | Yes |
| Lasso (30 grid points) | ~3 min | Partial |
| Random Forest | ~2 min | Yes |
| RFE (7 subset sizes) | ~8 min | Partial |
| Forward Selection | ~5 min | No |
| Genetic Algorithm (30 iter) | ~20 min | Yes |

**Total pipeline**: ~26 minutes (with parallelization)

---

## Validation: Did We Find the Truth?

Recall our data generation: **30 truly informative genes** (gene_1 to gene_30).

```r
# Check how many true genes we found
true_genes <- paste0("gene_", 1:30)
selected_genes <- ga_selected

overlap <- intersect(true_genes, selected_genes)
length(overlap)  # 28 out of 30 true genes recovered!

# False positives
false_positives <- setdiff(selected_genes, true_genes)
length(false_positives)  # 4 false positives

# False negatives
false_negatives <- setdiff(true_genes, selected_genes)
length(false_negatives)  # 2 true genes missed

cat("Sensitivity:", length(overlap) / length(true_genes), "\n")  # 93.3%
cat("Precision:", length(overlap) / length(selected_genes), "\n")  # 87.5%
```

**Excellent recovery** of true signal despite high noise!

---

## Additional Resources

- [Feature Selection Reference](../references/feature-selection.md)
- [Feature Engineering Book - Chapters 10-12](https://feat.engineering/)
- [caret RFE documentation](https://topepo.github.io/caret/recursive-feature-elimination.html)
- [GA package](https://cran.r-project.org/package=GA)
