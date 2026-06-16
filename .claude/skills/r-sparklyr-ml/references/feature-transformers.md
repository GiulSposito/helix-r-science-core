# Spark Feature Transformers (`ft_*`) for R

Complete reference for the `ft_*` family of feature transformers in sparklyr, with R examples, signatures, behavior details, and comparison to tidymodels `recipes`.

---

## 1. Overview

The `ft_*` functions expose Spark MLlib's Feature Transformers and Feature Estimators through R. They operate on Spark DataFrames and are designed to be composed inside `ml_pipeline()`.

### Two Categories

**Transformers** — apply a fixed rule; no training needed:
- `ft_binarizer`, `ft_tokenizer`, `ft_stop_words_remover`, `ft_bucketizer`, `ft_vector_slicer`, `ft_vector_assembler` (as a pure assembler), `ft_sql_transformer`, `ft_dct`

**Estimators** — learn parameters from data via `ml_fit()`; produce a fitted Transformer:
- `ft_imputer`, `ft_standard_scaler`, `ft_min_max_scaler`, `ft_max_abs_scaler`, `ft_normalizer`, `ft_string_indexer`, `ft_one_hot_encoder`, `ft_quantile_discretizer`, `ft_hashing_tf` + `ft_idf`, `ft_word2vec`

**Using in pipelines (recommended):** Add estimator stages to `ml_pipeline()`; they are automatically fit during `ml_fit()`:
```r
pipeline <- ml_pipeline(sc) |>
  ft_imputer(...) |>        # Estimator: fit on training data
  ft_vector_assembler(...) |> # Transformer: pure assembly
  ft_standard_scaler(...)    # Estimator: fit on training data
model <- ml_fit(pipeline, train_tbl)  # all estimators fit in one pass
```

**Using standalone (advanced/testing):**
```r
imputer <- ft_imputer(sc, ...)            # creates an Estimator object
fitted  <- ml_fit(imputer, train_tbl)     # fit → Transformer
output  <- ml_transform(fitted, test_tbl) # apply
```

---

## 2. Imputation — `ft_imputer`

### Signature

```r
ft_imputer(
  x,                   # spark_connection or ml_pipeline_stage or tbl_spark
  input_cols,          # character vector of input column names
  output_cols,         # character vector of output column names (same length as input_cols)
  strategy = "mean",   # "mean" or "median"
  missing_value = NaN, # value treated as missing (default NaN; use NULL for actual NULL)
  relative_error = 0.001,  # relative error for median approximation
  uid = random_string("imputer")
)
```

### Behavior

- **"mean"**: computes arithmetic mean on non-null, non-NaN values
- **"median"**: approximated median using Greenwald-Khanna algorithm; `relative_error` controls accuracy (smaller = more accurate but more memory)
- Input columns must be numeric (`DoubleType` or `FloatType`)
- Output columns are new columns; original columns are preserved unless input_cols == output_cols
- Nulls (SQL NULL) and NaN are both treated as missing by default

### Examples

```r
# Single column imputation
pipeline <- ml_pipeline(sc) |>
  ft_imputer("age", "age_imputed", strategy = "mean")

# Multiple columns, different strategies require separate ft_imputer calls
pipeline <- ml_pipeline(sc) |>
  ft_imputer(c("income", "credit_score"), c("income_imp", "credit_imp"), strategy = "median") |>
  ft_imputer("age", "age_imp", strategy = "mean")

# Inline use (not in pipeline) — useful for inspection
imp_estimator <- ft_imputer(sc, c("x", "y"), c("x_imp", "y_imp"), strategy = "median")
imp_model     <- ml_fit(imp_estimator, train_tbl)
result        <- ml_transform(imp_model, test_tbl)

# Check learned medians
imp_model$surrogate_df  # tibble with learned imputation values
```

### Common Pitfalls

- `ft_imputer` does NOT handle string/categorical columns — encode strings first, or use `dplyr` mutate for categorical imputation before entering the pipeline
- If ALL values in a column are NaN, the learned imputation value is NaN → those columns become all-NaN after transformation
- Specifying the same name for input and output overwrites the original column in the output DataFrame

---

## 3. String Indexing — `ft_string_indexer`

### Signature

```r
ft_string_indexer(
  x,
  input_col,
  output_col,
  handle_invalid = "error",  # "error", "skip", "keep"
  string_order_type = "frequencyDesc",  # "frequencyDesc", "frequencyAsc", "alphabetAsc", "alphabetDesc"
  uid = random_string("string_indexer")
)
```

### Behavior

- Learns a mapping from string labels to numeric indices based on `string_order_type`
- Default `"frequencyDesc"`: most frequent label gets index 0 (important for downstream one-hot encoding where index 0 is typically dropped)
- `handle_invalid = "keep"`: unseen labels in test data get an index at `numLabels` (last index) instead of erroring

### Examples

```r
pipeline <- ml_pipeline(sc) |>
  ft_string_indexer("occupation", "occupation_idx",
                    handle_invalid = "keep",
                    string_order_type = "frequencyDesc") |>
  ft_one_hot_encoder("occupation_idx", "occupation_vec")
```

---

## 4. One-Hot Encoding — `ft_one_hot_encoder`

### Signature

```r
ft_one_hot_encoder(
  x,
  input_cols,   # character vector (accepts one or more indexed columns)
  output_cols,  # character vector, same length
  drop_last = TRUE,   # drop last category to avoid multicollinearity (default TRUE)
  handle_invalid = "error",  # "error", "keep", "skip"
  uid = random_string("one_hot_encoder")
)
```

### Behavior

- Input must be numeric index columns (output of `ft_string_indexer`)
- Output is a **sparse vector column** of size `numLabels - 1` (when `drop_last = TRUE`)
- `drop_last = FALSE` produces a dense vector of size `numLabels`
- Accepts multiple columns in one call (more efficient than multiple calls)

### Examples

```r
# Encode multiple categorical columns in one call
pipeline <- ml_pipeline(sc) |>
  ft_string_indexer("education", "edu_idx") |>
  ft_string_indexer("region", "region_idx") |>
  ft_one_hot_encoder(c("edu_idx", "region_idx"), c("edu_vec", "region_vec"))
```

---

## 5. Vector Assembly — `ft_vector_assembler`

### Signature

```r
ft_vector_assembler(
  x,
  input_cols,   # character vector of numeric or vector columns to assemble
  output_col,   # name of the resulting feature vector column
  handle_invalid = "error",  # "error", "skip", "keep"
  uid = random_string("vector_assembler")
)
```

### Behavior

- Combines multiple numeric columns and/or sparse/dense vector columns into a single dense or sparse vector
- This is **always required** before most MLlib algorithms; they expect a single `features` column
- Input can mix scalar numerics and vector outputs from `ft_one_hot_encoder`, `ft_hashing_tf`, etc.

### Examples

```r
# Full preprocessing pipeline ending in vector assembly
pipeline <- ml_pipeline(sc) |>
  ft_imputer(c("age", "income"), c("age_imp", "income_imp")) |>
  ft_string_indexer("education", "edu_idx") |>
  ft_one_hot_encoder("edu_idx", "edu_vec") |>
  ft_vector_assembler(
    input_cols = c("age_imp", "income_imp", "edu_vec", "credit_score"),
    output_col = "features"
  )
```

---

## 6. Scaling — `ft_standard_scaler`, `ft_min_max_scaler`, `ft_max_abs_scaler`

### `ft_standard_scaler`

```r
ft_standard_scaler(
  x,
  input_col,          # name of input feature vector column
  output_col,         # name of scaled output column
  with_mean = FALSE,  # center (subtract mean) — set TRUE for zero-mean scaling
  with_std = TRUE,    # scale by standard deviation
  uid = random_string("standard_scaler")
)
```

- **Estimator**: learns mean and std from training data
- `with_mean = TRUE` produces dense vectors (may be memory-intensive for sparse data)
- Best for algorithms sensitive to feature magnitude (linear models, SVM, neural networks)

```r
pipeline <- ml_pipeline(sc) |>
  ft_vector_assembler(c("x1", "x2", "x3"), "features") |>
  ft_standard_scaler("features", "features_scaled", with_mean = TRUE, with_std = TRUE)
```

### `ft_min_max_scaler`

```r
ft_min_max_scaler(
  x,
  input_col,
  output_col,
  min = 0.0,   # lower bound of output range
  max = 1.0,   # upper bound of output range
  uid = random_string("min_max_scaler")
)
```

- Scales each feature to [min, max] based on min and max learned from training data
- Sensitive to outliers — prefer `ft_standard_scaler` or `ft_max_abs_scaler` when outliers present

### `ft_max_abs_scaler`

```r
ft_max_abs_scaler(x, input_col, output_col, uid = ...)
```

- Scales by dividing by max absolute value; output range is [-1, 1]
- Does not shift mean — preserves sparsity (safe for sparse vectors)
- Suitable when data has many zeros

---

## 7. Binning / Discretization

### `ft_binarizer`

```r
ft_binarizer(x, input_col, output_col, threshold = 0.5, uid = ...)
```

- Pure Transformer (no fitting)
- Values > threshold → 1.0; values ≤ threshold → 0.0

### `ft_bucketizer`

```r
ft_bucketizer(
  x,
  input_col,
  output_col,
  splits,              # numeric vector of split points, e.g. c(-Inf, 18, 35, 60, Inf)
  handle_invalid = "error",
  uid = ...
)
```

- Pure Transformer; requires manually specified bin boundaries
- `splits` must include `-Inf` and `Inf` as boundaries

### `ft_quantile_discretizer`

```r
ft_quantile_discretizer(
  x,
  input_col,
  output_col,
  num_buckets = 2,
  handle_invalid = "error",
  relative_error = 0.001,
  uid = ...
)
```

- **Estimator**: learns quantile boundaries from training data
- More data-driven than `ft_bucketizer`

---

## 8. Text Features

### `ft_tokenizer`

```r
ft_tokenizer(x, input_col, output_col, uid = ...)
```

- Pure Transformer: lowercases and splits on whitespace
- For more control, use `ft_regex_tokenizer()`

### `ft_hashing_tf` + `ft_idf`

```r
pipeline <- ml_pipeline(sc) |>
  ft_tokenizer("text", "words") |>
  ft_stop_words_remover("words", "filtered_words") |>
  ft_hashing_tf("filtered_words", "raw_features", num_features = 1000L) |>
  ft_idf("raw_features", "features", min_doc_freq = 5L)
```

- `ft_hashing_tf`: Transformer — maps term frequency to fixed-size vector via hashing
- `ft_idf`: Estimator — learns IDF weights from training corpus

---

## 9. `ft_*` vs `recipes` (tidymodels): When to Use What

| Consideration | Use `ft_*` (sparklyr) | Use `recipes` (tidymodels) |
|---|---|---|
| Data stays in Spark | ✅ Yes | ❌ No — steps run locally |
| Scale | Distributed, handles TB+ | Single machine, fits in RAM |
| Integration | Native MLlib pipeline | tidymodels workflow |
| Algorithm choice | MLlib or `set_engine("spark")` | Any parsnip engine |
| Step coverage | ft_* catalog (broad but fixed) | 100+ steps, extensible |
| Custom steps | `spark_apply()` | Custom `step_*` functions |

**Decision rule:**
1. If data lives in Spark and ML runs in Spark → use `ft_*` exclusively
2. If using `set_engine("spark")` with parsnip → use `recipes` for preprocessing that runs locally before copying to Spark, OR use `ft_*` pipeline steps that run inside Spark
3. Do **not** mix: applying `recipes` preprocessing and then passing the result to an `ft_*` pipeline creates confusion about what ran where and when

### Conceptual Mapping

| tidymodels recipe step | sparklyr ft_* equivalent |
|---|---|
| `step_impute_mean()` | `ft_imputer(strategy = "mean")` |
| `step_impute_median()` | `ft_imputer(strategy = "median")` |
| `step_string2factor()` + `step_dummy()` | `ft_string_indexer()` + `ft_one_hot_encoder()` |
| `step_normalize()` | `ft_standard_scaler(with_mean=TRUE, with_std=TRUE)` |
| `step_range()` | `ft_min_max_scaler()` |
| `step_tokenize()` | `ft_tokenizer()` |
| `step_tf()` / `step_tfidf()` | `ft_hashing_tf()` + `ft_idf()` |
| `step_cut()` | `ft_bucketizer()` |
| `step_discretize()` | `ft_quantile_discretizer()` |

---

## 10. Complete End-to-End Example

```r
library(sparklyr)
library(dplyr)

sc <- spark_connect(method = "databricks")

# Load data
raw_tbl <- spark_read_table(sc, "customer_churn")

# Split
splits <- sdf_random_split(raw_tbl, training = 0.8, test = 0.2, seed = 123)
train_tbl <- splits$training
test_tbl  <- splits$test

# Build full preprocessing + model pipeline
pipeline <- ml_pipeline(sc) |>
  # Impute numeric missings
  ft_imputer(
    input_cols  = c("tenure", "monthly_charges", "total_charges"),
    output_cols = c("tenure_imp", "monthly_imp", "total_imp"),
    strategy    = "median"
  ) |>
  # Index and encode categoricals
  ft_string_indexer("contract_type", "contract_idx", handle_invalid = "keep") |>
  ft_string_indexer("payment_method", "payment_idx", handle_invalid = "keep") |>
  ft_one_hot_encoder(
    input_cols  = c("contract_idx", "payment_idx"),
    output_cols = c("contract_vec", "payment_vec")
  ) |>
  # Assemble all features into one vector
  ft_vector_assembler(
    input_cols = c("tenure_imp", "monthly_imp", "total_imp",
                   "contract_vec", "payment_vec", "senior_citizen"),
    output_col = "features"
  ) |>
  # Scale
  ft_standard_scaler("features", "features_scaled", with_mean = TRUE, with_std = TRUE) |>
  # Model
  ml_logistic_regression(
    features_col = "features_scaled",
    label_col    = "churn",
    max_iter     = 100,
    reg_param    = 0.01
  )

# Fit (all estimators trained on train_tbl only)
model <- ml_fit(pipeline, train_tbl)

# Predict on test set
preds <- ml_predict(model, test_tbl)

# Evaluate in Spark
evaluator <- ml_binary_classification_evaluator(
  sc,
  label_col          = "churn",
  raw_prediction_col = "rawPrediction",
  metric_name        = "areaUnderROC"
)
auc <- ml_evaluate(evaluator, preds)
cat("AUC:", auc, "\n")

# Collect small summary locally
preds |>
  group_by(churn, prediction) |>
  summarise(n = n()) |>
  collect()

# Save pipeline for deployment
ml_save(model, "dbfs:/models/churn_pipeline_v1", overwrite = TRUE)
```

---

## 11. External Resources

- MLlib Feature Extraction guide: https://spark.posit.co/guides/mlib.html
- `ft_imputer` reference: https://spark.posit.co/packages/sparklyr/latest/reference/ft_imputer.html
- `recipes` for comparison: https://recipes.tidymodels.org/
- sparklyr API reference (all ft_* functions): https://spark.posit.co/packages/sparklyr/latest/reference/
