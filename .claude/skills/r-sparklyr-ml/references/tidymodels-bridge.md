# tidymodels ↔ Spark Bridge

Reference for using the tidymodels/parsnip interface with Apache Spark as the compute backend. Covers `set_engine("spark")`, supported models, limitations, `sdf_random_split()`, `tune_grid_spark()`, and model persistence.

---

## 1. Why a Bridge?

tidymodels provides a unified interface for ML in R: one syntax for `linear_reg()`, `rand_forest()`, `logistic_reg()`, etc., regardless of the underlying implementation. The `parsnip` package abstracts the engine.

The Spark bridge lets you **swap** the engine from a local implementation to Spark's MLlib without changing the modeling code — only `set_engine("spark")` and the data source change.

```r
# Local training (small data)
rf_local <- rand_forest(trees = 100, mtry = 3) |>
  set_engine("ranger") |>
  set_mode("classification") |>
  fit(species ~ ., data = iris)

# Spark training (large data) — same model spec
rf_spark <- rand_forest(trees = 100, mtry = 3) |>
  set_engine("spark") |>
  set_mode("classification") |>
  fit(species ~ ., data = spark_iris_tbl)  # spark_iris_tbl = copy_to(sc, iris)
```

**This is the primary reason to use the bridge:** code written for prototyping locally can scale to Spark with minimal changes.

---

## 2. Supported Models with `set_engine("spark")`

### Regression

#### `linear_reg()`

```r
linear_reg(
  penalty = NULL,   # L2 regularization (reg_param in Spark)
  mixture = NULL    # L1 ratio (elastic_net_param); 0 = Ridge, 1 = Lasso
) |>
  set_engine("spark") |>
  set_mode("regression")
```

Maps to: `ml_linear_regression()`

Hyperparameters passed to Spark:
- `penalty` → `reg_param`
- `mixture` → `elastic_net_param`

---

### Classification

#### `logistic_reg()`

```r
logistic_reg(
  penalty = NULL,   # reg_param
  mixture = NULL    # elastic_net_param
) |>
  set_engine("spark") |>
  set_mode("classification")
```

Maps to: `ml_logistic_regression()`

---

#### `decision_tree()`

```r
decision_tree(
  tree_depth  = NULL,  # maxDepth
  min_n       = NULL,  # minInstancesPerNode
  cost_complexity = NULL  # not supported with Spark engine
) |>
  set_engine("spark") |>
  set_mode("classification")  # or "regression"
```

Maps to: `ml_decision_tree_classifier()` / `ml_decision_tree_regressor()`

**Spark-specific limitation:** `cost_complexity` is NOT available with the Spark engine (Spark does not implement cost-complexity pruning). Attempting to tune it with `tune()` will error.

---

#### `rand_forest()`

```r
rand_forest(
  trees = NULL,   # numTrees
  mtry  = NULL,   # featureSubsetStrategy (passed as integer or fraction)
  min_n = NULL    # minInstancesPerNode
) |>
  set_engine("spark") |>
  set_mode("classification")  # or "regression"
```

Maps to: `ml_random_forest_classifier()` / `ml_random_forest_regressor()`

**Limitations with Spark engine:**
- Only formula interface (`fit(formula, data)`) is supported — `fit_xy()` is NOT
- Predictions return as a Spark DataFrame (lazy), not a local tibble
- Factor columns are not handled automatically — must be pre-indexed with `ft_string_indexer`

---

#### `boost_tree()`

```r
boost_tree(
  trees         = NULL,  # maxIter
  tree_depth    = NULL,  # maxDepth
  learn_rate    = NULL,  # stepSize
  min_n         = NULL,  # minInstancesPerNode
  sample_size   = NULL,  # subsamplingRate
  loss_reduction = NULL  # not available in Spark engine
) |>
  set_engine("spark") |>
  set_mode("classification")  # or "regression"
```

Maps to: `ml_gradient_boosted_trees()`

**Limitations:**
- `loss_reduction` is NOT available with Spark engine
- Binary classification only for `set_mode("classification")` — Spark GBT does not support multiclass classification
- Formula interface only

---

## 3. Critical Limitations of `set_engine("spark")`

| Limitation | Detail |
|---|---|
| **Formula interface only** | `fit(formula, data)` only; `fit_xy(x, y)` throws an error |
| **Predictions as Spark DataFrame** | `predict()` returns a lazy Spark DataFrame; must `collect()` for local use |
| **No automatic factor handling** | Categorical columns must be pre-processed with `ft_string_indexer` + `ft_one_hot_encoder` |
| **No model persistence via `saveRDS()`** | Spark model objects cannot be serialized with R's native `saveRDS()`; use `ml_save()` |
| **No stacking or blending** | `stacks` package requires local tibbles; not compatible with Spark engine outputs |
| **No calibration** | `probably` package calibration requires local data |
| **Not all hyperparameters map** | `cost_complexity` (decision_tree), `loss_reduction` (boost_tree) unavailable in Spark |
| **Sparse categorical handling** | Large cardinality categoricals need explicit `ft_string_indexer`; parsnip doesn't do it automatically |
| **Bridge coverage is partial** | Parsnip documentation explicitly states: "this integration still doesn't apply to all functions" |

---

## 4. Data Splits: `sdf_random_split()`

### Signature

```r
sdf_random_split(
  x,          # tbl_spark
  ...,        # named weights, e.g., training = 0.8, test = 0.2
  seed = NULL # integer seed for reproducibility
)
```

### Returns

A **named list** of Spark DataFrames, one per named weight.

### Semantics of Weights

Weights define **per-row sampling probabilities**, NOT exact partition sizes. Each row is independently assigned to a partition with probability proportional to the weights. Actual sizes will vary around the expected proportions, especially for small datasets.

```r
splits <- sdf_random_split(tbl, training = 0.75, test = 0.25, seed = 42)
train_tbl <- splits$training
test_tbl  <- splits$test

# Verify (approximate — not exactly 75/25)
sdf_nrow(train_tbl)
sdf_nrow(test_tbl)
```

### Three-Way Split

```r
splits <- sdf_random_split(tbl,
  training   = 0.60,
  validation = 0.20,
  test       = 0.20,
  seed       = 2024
)
```

### parsnip Integration Pattern

When using `set_engine("spark")`, the typical pattern is:

```r
library(sparklyr)
library(tidymodels)

sc <- spark_connect(method = "databricks")

# Option A: Data already in Spark
raw_spark <- spark_read_table(sc, "my_table")
splits <- sdf_random_split(raw_spark, training = 0.8, test = 0.2, seed = 42)
train_spark <- splits$training
test_spark  <- splits$test

# Option B: Prototype with local data copied to Spark
train_spark <- copy_to(sc, train_df, "train", overwrite = TRUE)
test_spark  <- copy_to(sc, test_df,  "test",  overwrite = TRUE)

# Fit with Spark engine (formula interface)
rf_spec <- rand_forest(trees = 200, mtry = 4) |>
  set_engine("spark") |>
  set_mode("classification")

rf_fit <- rf_spec |> fit(label ~ ., data = train_spark)

# Predict (returns Spark DataFrame)
preds_spark <- predict(rf_fit, new_data = test_spark)

# Collect for local evaluation
preds_local <- preds_spark |> collect()
test_local  <- test_spark  |> collect()

# Evaluate locally with yardstick
bind_cols(test_local |> select(label), preds_local) |>
  accuracy(truth = label, estimate = .pred_class)
```

---

## 5. Distributed Hyperparameter Tuning: `tune_grid_spark()`

### What It Does

`tune_grid_spark()` extends tidymodels' `tune_grid()` to execute the grid search **on the Spark cluster**. Each combination of hyperparameters runs as a separate Spark task, enabling massive parallelization. Results are collected back to the local R session.

### Signature

```r
tune_grid_spark(
  object,           # workflow or model spec
  resamples,        # rsample object (see below for Spark-compatible options)
  grid,             # data.frame of hyperparameter combinations or dials grid
  metrics = NULL,   # yardstick metric_set
  control = control_grid()
)
```

### How Cluster Execution Works

1. The local R session serializes the workflow, grid, and resampling strategy
2. Spark distributes each grid combination to an executor node
3. Each executor runs R + the required packages + fits the model on its assigned fold/split
4. Metric results are returned to the local R session
5. `select_best()` operates locally on the collected results

### Resampling with Spark Data

`tune_grid_spark()` requires `resamples` in a format compatible with Spark DataFrames. The most straightforward approach is `manual_rset()`:

```r
library(rsample)

# Manual single split (train/test)
rset <- manual_rset(
  splits = list(make_splits(list(analysis = train_spark, assessment = test_spark),
                             data = train_spark)),
  ids = "train_test_split"
)
```

For multiple folds, pre-compute fold assignments in Spark and materialize:

```r
# V-fold cross-validation (pre-compute folds in Spark)
folds <- sdf_random_split(train_spark,
  fold1 = 0.2, fold2 = 0.2, fold3 = 0.2, fold4 = 0.2, fold5 = 0.2,
  seed = 42
)
# Construct rsample splits manually or use vfold_cv on a collected sample
```

### Complete Tuning Example

```r
library(tidymodels)
library(sparklyr)

sc <- spark_connect(method = "databricks")
data_spark <- spark_read_table(sc, "modeling_data")
splits <- sdf_random_split(data_spark, training = 0.8, test = 0.2, seed = 99)
train_spark <- splits$training
test_spark  <- splits$test

# Model spec with tunable hyperparameters
rf_spec <- rand_forest(trees = tune(), mtry = tune(), min_n = tune()) |>
  set_engine("spark") |>
  set_mode("classification")

wf <- workflow() |>
  add_formula(churn ~ .) |>
  add_model(rf_spec)

# Grid
grid <- grid_regular(
  trees(range = c(50, 300)),
  mtry(range  = c(2, 8)),
  min_n(range = c(5, 50)),
  levels = 3
)

# Resampling (single split for illustration)
rset <- manual_rset(
  splits = list(make_splits(list(analysis = train_spark, assessment = test_spark),
                             data = train_spark)),
  ids = "Fold1"
)

# Distributed tuning
tuning_results <- tune_grid_spark(
  wf,
  resamples = rset,
  grid      = grid,
  metrics   = metric_set(roc_auc, accuracy)
)

# Select best locally
best_params <- select_best(tuning_results, metric = "roc_auc")
final_wf    <- finalize_workflow(wf, best_params)
final_fit   <- fit(final_wf, data = train_spark)
```

### `tune_grid_spark` vs `tune_grid` (local)

| Aspect | `tune_grid_spark()` | `tune_grid()` (local) |
|---|---|---|
| Where combinations run | Spark executors | Local R session (optionally parallel with `doFuture`) |
| Data location | Spark DataFrames | Local R data frames / `rsample` splits |
| Parallelism | Cluster-scale | Single machine (`parallel::makePSOCKcluster()`) |
| Best for | Many grid combinations + large data | Moderate data + full tidymodels ecosystem |

---

## 6. Model Persistence

### Saving Spark Models

**Do NOT use `saveRDS()`** on Spark model objects — they contain JVM references that cannot be serialized by R.

```r
# WRONG — will error or produce unusable file
saveRDS(spark_model, "model.rds")

# CORRECT — saves to HDFS/DBFS/S3 as a Spark-native format
ml_save(spark_model, "dbfs:/models/churn_v1", overwrite = TRUE)
ml_save(spark_model, "s3a://my-bucket/models/churn_v1", overwrite = TRUE)
```

### Loading Saved Models

```r
# Must have an active spark connection
model <- ml_load(sc, "dbfs:/models/churn_v1")
predictions <- ml_predict(model, new_data_spark)
```

### Versioning Pattern

```r
model_path <- paste0("dbfs:/models/churn/v", format(Sys.Date(), "%Y%m%d"))
ml_save(fitted_pipeline, model_path, overwrite = TRUE)
```

### Saving parsnip Models with `set_engine("spark")`

For workflows using `fit(parsnip_spec, data = spark_tbl)`:

```r
# The fitted model object has a $fit slot with the underlying sparklyr model
ml_save(final_fit$fit,  # or final_fit$fit$fit for workflows
        "dbfs:/models/parsnip_spark_v1", overwrite = TRUE)
```

---

## 7. Per-Model Detail References

Parsnip provides engine-specific documentation pages. Key pages for Spark engine:

- `?details_linear_reg_spark` — available hyperparameters, mapping to Spark params
- `?details_logistic_reg_spark` — multiclass support status, limitations
- `?details_decision_tree_spark` — pruning limitations, formula-only constraint
- `?details_rand_forest_spark` — `mtry` as integer vs fraction, feature subset strategies
- `?details_boost_tree_spark` — binary classification only, unsupported params

External parsnip docs:
- https://parsnip.tidymodels.org/reference/details_decision_tree_spark.html
- https://parsnip.tidymodels.org/reference/details_rand_forest_spark.html
- https://parsnip.tidymodels.org/reference/details_boost_tree_spark.html

---

## 8. External Resources

- "tidymodels and Spark" guide: https://spark.posit.co/guides/tidymodels.html
- "Fitting and predicting with parsnip": https://www.tidymodels.org/learn/models/parsnip-predictions/
- `tune_grid_spark` reference: https://spark.posit.co/packages/sparklyr/latest/reference/tune_grid_spark.html
- `sdf_random_split` reference: https://rdrr.io/cran/sparklyr/man/sdf_random_split.html
- parsnip homepage: https://parsnip.tidymodels.org/
