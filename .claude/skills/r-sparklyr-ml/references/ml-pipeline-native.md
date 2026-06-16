# Native MLlib Pipelines in sparklyr

Reference for building, fitting, transforming, evaluating, and deploying machine learning pipelines using sparklyr's native MLlib interface (`ml_*` functions) and `spark_apply()`.

---

## 1. Pipeline API Overview

### Core Functions

| Function | Purpose |
|---|---|
| `ml_pipeline(sc)` | Create an empty pipeline (or compose from stages) |
| `ml_fit(pipeline, data)` | Fit all Estimator stages; returns `PipelineModel` |
| `ml_transform(model, data)` | Apply fitted pipeline/transformer to data |
| `ml_predict(model, data)` | Like `ml_transform` but adds user-friendly prediction columns |
| `ml_evaluate(evaluator, data)` | Compute metrics using a Spark evaluator |
| `ml_save(model, path)` | Persist fitted model to HDFS/cloud |
| `ml_load(sc, path)` | Reload saved model |

### Estimator vs Transformer (recap)

- **Estimator**: has `ml_fit()` — learns from data (imputer, scaler, indexer, all `ml_*` algorithms)
- **Transformer**: has `ml_transform()` — applies fixed rules (assembler, binarizer, tokenizer, and all fitted models)
- `ml_fit(pipeline, data)` converts all Estimator stages to Transformers, producing a `PipelineModel`

---

## 2. Pipeline Construction

### `ml_pipeline()`

```r
# Create an empty pipeline and add stages via pipe
pipeline <- ml_pipeline(sc) |>
  stage1() |>
  stage2() |>
  ml_some_algorithm(...)

# Alternatively, compose from existing stage objects
s1 <- ft_imputer(sc, ...)
s2 <- ft_vector_assembler(sc, ...)
s3 <- ml_linear_regression(sc, ...)
pipeline <- ml_pipeline(s1, s2, s3)
```

### Stage Ordering Rules

1. All feature preparation stages before the ML algorithm
2. `ft_vector_assembler` must come after all column-level transformers and before the algorithm
3. Scaling stages (`ft_standard_scaler`, etc.) go after `ft_vector_assembler`
4. The ML algorithm is always last

```r
# Correct order
ml_pipeline(sc) |>
  ft_imputer(...)           # 1. Impute nulls
  ft_string_indexer(...)    # 2. Index categoricals
  ft_one_hot_encoder(...)   # 3. Encode
  ft_vector_assembler(...)  # 4. Assemble feature vector
  ft_standard_scaler(...)   # 5. Scale
  ml_logistic_regression()  # 6. Model (always last)
```

---

## 3. ML Algorithm Catalog

### Supervised — Classification

#### `ml_logistic_regression()`

```r
ml_logistic_regression(
  x,
  formula              = NULL,
  fit_intercept        = TRUE,
  max_iter             = 100L,
  reg_param            = 0.0,      # L2 regularization
  elastic_net_param    = 0.0,      # 0 = Ridge, 1 = Lasso
  family               = "auto",   # "auto", "binomial", "multinomial"
  threshold            = 0.5,      # for binary classification
  thresholds           = NULL,     # per-class thresholds for multiclass
  features_col         = "features",
  label_col            = "label",
  prediction_col       = "prediction",
  probability_col      = "probability",
  raw_prediction_col   = "rawPrediction",
  uid                  = random_string("logistic_regression")
)
```

#### `ml_decision_tree_classifier()`

```r
ml_decision_tree_classifier(
  x,
  formula              = NULL,
  max_depth            = 5L,
  max_bins             = 32L,
  min_instances_per_node = 1L,
  min_info_gain        = 0.0,
  impurity             = "gini",   # "gini" or "entropy"
  seed                 = NULL,
  features_col         = "features",
  label_col            = "label",
  uid                  = random_string("decision_tree_classifier")
)
```

#### `ml_random_forest_classifier()`

```r
ml_random_forest_classifier(
  x,
  formula              = NULL,
  num_trees            = 20L,
  subsampling_rate     = 1.0,
  max_depth            = 5L,
  max_bins             = 32L,
  min_instances_per_node = 1L,
  feature_subset_strategy = "auto",  # "auto", "all", "sqrt", "log2", integer or fraction
  impurity             = "gini",
  seed                 = NULL,
  features_col         = "features",
  label_col            = "label",
  uid                  = random_string("random_forest_classifier")
)
```

`feature_subset_strategy = "auto"` → uses `sqrt(numFeatures)` for classification, `numFeatures/3` for regression.

#### `ml_gradient_boosted_trees()`

```r
ml_gradient_boosted_trees(
  x,
  formula              = NULL,
  max_iter             = 20L,       # number of trees
  step_size            = 0.1,       # learning rate
  max_depth            = 5L,
  max_bins             = 32L,
  subsampling_rate     = 1.0,
  loss_type            = "logistic", # for classification; "squared" or "absolute" for regression
  seed                 = NULL,
  features_col         = "features",
  label_col            = "label",
  uid                  = random_string("gbt")
)
```

**Note:** Spark GBT supports **binary classification only** — not multiclass. For multiclass, use `ml_random_forest_classifier()`.

#### `ml_linear_svc()`

```r
ml_linear_svc(
  x,
  formula      = NULL,
  max_iter     = 100L,
  reg_param    = 0.0,
  tol          = 1e-6,
  features_col = "features",
  label_col    = "label",
  uid          = random_string("linear_svc")
)
```

#### `ml_naive_bayes()`

```r
ml_naive_bayes(
  x,
  formula       = NULL,
  model_type    = "multinomial",  # "multinomial", "bernoulli", "complement"
  smoothing     = 1.0,
  features_col  = "features",
  label_col     = "label",
  uid           = random_string("naive_bayes")
)
```

---

### Supervised — Regression

#### `ml_linear_regression()`

```r
ml_linear_regression(
  x,
  formula           = NULL,
  fit_intercept     = TRUE,
  max_iter          = 100L,
  reg_param         = 0.0,
  elastic_net_param = 0.0,
  loss              = "squaredError",  # "squaredError", "huber"
  solver            = "auto",
  features_col      = "features",
  label_col         = "label",
  uid               = random_string("linear_regression")
)
```

#### `ml_decision_tree_regressor()`

Same parameters as `ml_decision_tree_classifier()` but without `impurity`.

#### `ml_random_forest_regressor()`

Same parameters as `ml_random_forest_classifier()` without `impurity`; `impurity` = "variance".

#### `ml_aft_survival_regression()`

```r
ml_aft_survival_regression(
  x,
  formula          = NULL,
  censor_col       = "censor",
  quantile_probabilities = c(0.01, 0.05, 0.25, 0.5, 0.75, 0.95, 0.99),
  features_col     = "features",
  label_col        = "label",
  uid              = random_string("aft_survival_regression")
)
```

---

### Unsupervised

#### `ml_kmeans()`

```r
ml_kmeans(
  x,
  formula    = NULL,
  k          = 2L,
  max_iter   = 20L,
  tol        = 1e-4,
  init_mode  = "k-means||",  # "random" or "k-means||"
  seed       = NULL,
  features_col = "features",
  uid        = random_string("kmeans")
)
```

```r
# Fit and get cluster assignments
model  <- ml_fit(ml_kmeans(sc, k = 5L), feature_tbl)
result <- ml_transform(model, feature_tbl)
result |> select(features, prediction) |> collect()

# Cluster centers
model$centers
```

#### `ml_bisecting_kmeans()`

Hierarchical variant: divides clusters by bisection. Same interface as `ml_kmeans()`.

#### `ml_gaussian_mixture()`

```r
ml_gaussian_mixture(
  x,
  formula = NULL,
  k       = 2L,
  max_iter = 100L,
  tol     = 0.01,
  seed    = NULL,
  features_col = "features",
  uid     = random_string("gaussian_mixture")
)
```

#### `ml_pca()`

```r
ml_pca(
  x,
  formula    = NULL,
  k          = NULL,   # number of principal components
  features_col = "features",
  uid        = random_string("pca")
)
```

```r
# Dimensionality reduction
pca <- ml_pca(sc, k = 10L)
model <- ml_fit(pca, feature_tbl)
reduced_tbl <- ml_transform(model, feature_tbl)

# Explained variance
model$explained_variance
```

#### `ml_lda()` (Latent Dirichlet Allocation)

```r
ml_lda(
  x,
  k           = NULL,  # number of topics
  max_iter    = 20L,
  doc_concentration = NULL,
  topic_concentration = NULL,
  features_col = "features",
  uid         = random_string("lda")
)
```

---

### Recommendation

#### `ml_als()` (Alternating Least Squares)

```r
ml_als(
  x,
  rating_col  = "rating",
  user_col    = "user",
  item_col    = "item",
  rank        = 10L,
  max_iter    = 10L,
  reg_param   = 0.1,
  nonnegative = FALSE,
  seed        = NULL,
  uid         = random_string("als")
)
```

```r
# Fit and recommend
model <- ml_fit(ml_als(sc, user_col = "user_id", item_col = "product_id",
                        rating_col = "rating", rank = 20L), ratings_tbl)

# Top N recommendations per user
ml_recommend(model, type = "items", n = 10)
```

---

## 4. Fit, Transform, Predict

### `ml_fit()`

```r
ml_fit(x, dataset, ...)
```

- `x`: a Pipeline, Estimator, or already-fitted model
- `dataset`: Spark DataFrame used for training
- Returns a `PipelineModel` (if `x` is a Pipeline) or a fitted Transformer (if `x` is a single Estimator)
- **Triggers Spark execution** — this is where actual computation happens

### `ml_transform()`

```r
ml_transform(x, dataset, ...)
```

- Applies a fitted Transformer or PipelineModel to `dataset`
- Returns a new Spark DataFrame with added columns
- **Does NOT add convenience prediction columns** (use `ml_predict()` for those)

### `ml_predict()`

```r
ml_predict(x, dataset, ...)
```

- Like `ml_transform()` but adds standardized columns:
  - `prediction`: class label or regression value
  - `probability`: class probabilities vector (classification)
  - `rawPrediction`: log-odds or raw scores

```r
# With ml_transform (raw)
raw_output <- ml_transform(fitted_model, test_tbl)
# Columns: features, label, rawPrediction, probability, prediction (+ all original columns)

# With ml_predict (convenience)
pred_output <- ml_predict(fitted_model, test_tbl)
# Same columns, but more user-friendly column selection
```

For most use cases, `ml_predict()` is preferred; use `ml_transform()` when you need raw stage outputs or are applying intermediate stages.

---

## 5. Model Evaluation

### Evaluators

Evaluators compute a single scalar metric from a predictions DataFrame:

```r
# Binary Classification
evaluator <- ml_binary_classification_evaluator(
  sc,
  label_col          = "label",
  raw_prediction_col = "rawPrediction",
  metric_name        = "areaUnderROC"  # or "areaUnderPR"
)

# Multiclass Classification
evaluator <- ml_multiclass_classification_evaluator(
  sc,
  label_col      = "label",
  prediction_col = "prediction",
  metric_name    = "accuracy"   # "accuracy", "weightedPrecision", "weightedRecall", "f1"
)

# Regression
evaluator <- ml_regression_evaluator(
  sc,
  label_col      = "label",
  prediction_col = "prediction",
  metric_name    = "rmse"       # "rmse", "mse", "r2", "mae"
)

# Compute metric
metric_value <- ml_evaluate(evaluator, predictions_tbl)
cat("AUC:", metric_value, "\n")
```

### Confusion Matrix (local)

```r
preds_local <- ml_predict(model, test_tbl) |>
  select(label, prediction) |>
  collect()

table(preds_local$label, preds_local$prediction)
```

### Residuals (regression)

```r
ml_summary(fitted_model)$residuals  # for linear models
```

---

## 6. Model Metadata and Inspection

### Feature Importance (Tree Models)

```r
# For decision tree, random forest, GBT
ml_feature_importances(fitted_model, train_tbl)
# Returns: tibble with feature names and importance scores
```

### Linear Model Coefficients

```r
ml_summary(fitted_linear_model)$coefficients
ml_summary(fitted_linear_model)$r_squared
ml_summary(fitted_linear_model)$root_mean_squared_error
```

### Pipeline Stages

```r
ml_stages(pipeline_model)
# Returns: named list of all stages in fitted PipelineModel
```

---

## 7. `spark_apply()` — Custom R on Spark

### When to Use

Use `spark_apply()` when:
- The transformation cannot be expressed as a `dplyr` verb or `ft_*` function
- You need to call a specialized R package on each partition
- You need multi-output transformations or complex statistical functions
- You're applying a model trained with a non-Spark R package to Spark data

**Do NOT use** when a native `ft_*` or dplyr/SQL equivalent exists — `spark_apply()` has significant overhead (serialization, R process startup per partition).

### Signature

```r
spark_apply(
  x,                   # tbl_spark
  f,                   # function(partition, ...) → data.frame
  columns  = NULL,     # output schema: list(col1 = "type") or character vector
  memory   = TRUE,     # cache result in memory
  group_by = NULL,     # character vector of column names to group by before applying
  packages = NULL,     # TRUE to ship all attached packages; character vector for specific packages
  context  = list(),   # additional data passed as second arg to f()
  name     = random_string("sparklyr_tmp"),  # temp table name
  ...
)
```

### Basic Examples

```r
# Simple transformation
result <- spark_apply(
  tbl,
  function(partition) {
    partition$log_income <- log1p(partition$income)
    partition
  },
  columns = list(id = "integer", income = "double", log_income = "double")
)

# Using an R package
result <- spark_apply(
  text_tbl,
  function(partition) {
    library(stringr)
    partition$cleaned <- str_trim(str_to_lower(partition$text))
    partition
  },
  packages = TRUE  # ships all attached packages to executors
)

# Passing external data via context
lookup_table <- data.frame(code = 1:3, label = c("A", "B", "C"))

result <- spark_apply(
  tbl,
  function(partition, lookup) {
    merge(partition, lookup, by = "code", all.x = TRUE)
  },
  context  = lookup_table,
  packages = FALSE
)
```

### Group-By Pattern

```r
# Apply function separately within each group
result <- spark_apply(
  sales_tbl,
  function(partition) {
    # partition is one store's data
    partition$rank <- rank(-partition$sales)
    partition
  },
  group_by = "store_id"
)
```

### Applying Non-Spark R Models

```r
# Distribute prediction using a locally-trained model
local_model <- readRDS("local_xgboost_model.rds")

result <- spark_apply(
  feature_tbl,
  function(partition, model) {
    library(xgboost)
    mat  <- as.matrix(partition[, -1])
    preds <- predict(model, mat)
    data.frame(id = partition$id, prediction = preds)
  },
  context  = local_model,
  packages = TRUE,
  columns  = list(id = "integer", prediction = "double")
)
```

### Performance Considerations

- Each partition starts a new R process on the executor — high overhead for small partitions
- Optimize partition count before calling: `sdf_repartition(tbl, n = 100)` for ~100 partitions
- Use `packages = FALSE` if the function uses only base R or pre-installed packages
- `group_by` can create many small partitions — avoid on high-cardinality columns
- For scoring models at scale, prefer native MLlib via `ml_predict()` when possible

---

## 8. Complete End-to-End: Native MLlib Pipeline

```r
library(sparklyr)
library(dplyr)

sc <- spark_connect(method = "databricks")

# Data
raw <- spark_read_table(sc, "telco_churn")

# Split
splits <- sdf_random_split(raw, training = 0.8, test = 0.2, seed = 1234)
train_tbl <- splits$training
test_tbl  <- splits$test

# Cache training set (used in fit)
sdf_register(train_tbl, "train_cache")
tbl_cache(sc, "train_cache")
train_tbl <- tbl(sc, "train_cache")

# Full pipeline
pipeline <- ml_pipeline(sc) |>
  # Numeric imputation
  ft_imputer(
    c("tenure", "monthly_charges", "total_charges"),
    c("tenure_imp", "monthly_imp", "total_imp"),
    strategy = "median"
  ) |>
  # Categorical encoding
  ft_string_indexer("contract",        "contract_idx",  handle_invalid = "keep") |>
  ft_string_indexer("internet_service","internet_idx",  handle_invalid = "keep") |>
  ft_string_indexer("payment_method",  "payment_idx",   handle_invalid = "keep") |>
  ft_one_hot_encoder(
    c("contract_idx",  "internet_idx",  "payment_idx"),
    c("contract_vec",  "internet_vec",  "payment_vec")
  ) |>
  # Target encoding (label → numeric)
  ft_string_indexer("churn", "churn_label") |>
  # Feature vector assembly
  ft_vector_assembler(
    c("tenure_imp", "monthly_imp", "total_imp",
      "contract_vec", "internet_vec", "payment_vec",
      "senior_citizen", "partner", "dependents"),
    "features"
  ) |>
  # Scaling
  ft_standard_scaler("features", "features_scaled", with_mean = TRUE) |>
  # Model
  ml_random_forest_classifier(
    features_col = "features_scaled",
    label_col    = "churn_label",
    num_trees    = 100L,
    max_depth    = 8L,
    seed         = 42L
  )

# Fit
model <- ml_fit(pipeline, train_tbl)

# Evaluate on test
preds <- ml_predict(model, test_tbl)

auc <- ml_binary_classification_evaluator(
  sc, metric_name = "areaUnderROC"
) |> ml_evaluate(preds)

acc <- ml_multiclass_classification_evaluator(
  sc, metric_name = "accuracy"
) |> ml_evaluate(preds)

cat(sprintf("AUC: %.4f | Accuracy: %.4f\n", auc, acc))

# Feature importance
ml_feature_importances(model |> ml_stages() |> tail(1) |> _[[1]], train_tbl) |>
  arrange(desc(importance)) |>
  head(10)

# Persist
ml_save(model, "dbfs:/models/telco_churn_rf_v1", overwrite = TRUE)

# Uncache
tbl_uncache(sc, "train_cache")
```

---

## 9. External Resources

- ml_pipeline reference: https://spark.posit.co/packages/sparklyr/latest/reference/ml_pipeline.html
- ml transform/fit/predict: https://spark.posit.co/packages/sparklyr/latest/reference/ml-transform-methods.html
- spark_apply guide: https://spark.posit.co/guides/distributed-r.html
- Databricks R DataFrames: https://docs.databricks.com/aws/en/sparkr/dataframes-tables
- Apache Spark ML Pipelines: https://spark.apache.org/docs/latest/ml-pipeline.html
- sparklyr cheatsheet: https://rstudio.github.io/cheatsheets/html/sparklyr.html
