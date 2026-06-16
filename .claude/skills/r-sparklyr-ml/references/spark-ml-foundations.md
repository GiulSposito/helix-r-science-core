# Spark ML Foundations for R

Conceptual and architectural reference for machine learning with Apache Spark using R and sparklyr. Covers the MLlib abstraction model, Spark's execution model, and how these map to R workflows.

---

## 1. Apache Spark ML Architecture

### Spark's Role in ML

Apache Spark provides a unified engine for large-scale data processing and machine learning. For R users, sparklyr exposes Spark's ML capabilities through idiomatic R APIs while keeping data in the distributed cluster.

Spark ML operates on **DataFrames** — distributed, schema-aware tabular datasets stored across cluster nodes. Unlike R data frames (in-memory, single-machine), Spark DataFrames are:
- **Lazy**: operations build a logical plan; execution happens only when an action is triggered (e.g., `collect()`, `sdf_nrow()`, `ml_fit()`)
- **Distributed**: partitioned across executors in the cluster
- **Immutable**: transformations return new DataFrames; originals are never modified
- **Typed**: schema is declared; Spark enforces column types

### Spark ML vs MLlib

Apache Spark has two ML APIs:
- **MLlib (RDD-based)**: legacy API operating on Resilient Distributed Datasets. Deprecated for most use cases.
- **Spark ML (DataFrame-based)**: current API, operates on DataFrames. This is what sparklyr uses via `ml_*` and `ft_*` functions.

All sparklyr ML functions (`ml_*`, `ft_*`, `ml_pipeline()`) use the DataFrame-based API.

---

## 2. Core Abstraction: Estimator / Transformer / Pipeline

This is the central design pattern of Spark ML, directly equivalent to what `recipes` + `parsnip` provide in tidymodels, but executed inside Spark.

### Transformer

A Transformer applies a fixed transformation to a DataFrame, producing a new DataFrame with additional columns. It has a `transform()` method (exposed in R as `ml_transform()`).

**Examples:**
- `ft_binarizer()` — converts numeric to binary based on threshold (no fitting needed)
- `ft_tokenizer()` — splits strings into tokens
- `ft_vector_assembler()` — assembles multiple columns into a feature vector column
- A fitted `ml_logistic_regression` model (after fitting, it becomes a transformer that adds prediction columns)

```r
# ft_vector_assembler is a Transformer — no fitting needed
assembler <- ft_vector_assembler(sc, c("x1", "x2", "x3"), "features")
transformed <- ml_transform(assembler, my_tbl)
```

### Estimator

An Estimator learns parameters from data via a `fit()` method (exposed as `ml_fit()`). After fitting, it produces a **Transformer** (the fitted model/transformer).

**Examples:**
- `ft_standard_scaler()` — learns mean and std from training data, then scales
- `ft_imputer()` — learns mean/median from training data, then imputes
- `ft_string_indexer()` — learns label→index mapping from training data
- `ml_logistic_regression()` — learns coefficients from training data

```r
# ft_standard_scaler is an Estimator — must be fit first
scaler_estimator <- ft_standard_scaler(sc, "features", "features_scaled")
scaler_model <- ml_fit(scaler_estimator, train_tbl)  # now a Transformer
scaled_tbl <- ml_transform(scaler_model, test_tbl)
```

### Pipeline

A Pipeline chains multiple Stages (Estimators and Transformers) in order. When `ml_fit()` is called on a Pipeline:
1. Each **Estimator** stage is fit on the training data, producing a Transformer
2. The training data is passed through each stage in sequence
3. The result is a **PipelineModel** — a sequence of pure Transformers

```r
# Pipeline with both Estimators (imputer, scaler, model) and Transformers (assembler)
pipeline <- ml_pipeline(sc) |>
  ft_imputer(c("age", "income"), c("age_imp", "income_imp"), strategy = "median") |>
  ft_string_indexer("education", "education_idx") |>
  ft_one_hot_encoder("education_idx", "education_vec") |>
  ft_vector_assembler(c("age_imp", "income_imp", "education_vec"), "features") |>
  ft_standard_scaler("features", "features_scaled") |>
  ml_random_forest_classifier(features_col = "features_scaled", label_col = "churn")

# ml_fit trains all Estimator stages in sequence
pipeline_model <- ml_fit(pipeline, train_tbl)

# pipeline_model is now a PipelineModel (all Transformers)
predictions <- ml_transform(pipeline_model, test_tbl)
```

**Why pipelines matter:**
- Prevents data leakage: `ft_imputer` and `ft_standard_scaler` learn statistics ONLY from `train_tbl`, then apply those learned parameters when transforming `test_tbl`
- Reproducibility: the entire preprocessing + modeling chain is one serializable object
- Deployment: `ml_save(pipeline_model, path)` serializes the full fitted pipeline for reuse

---

## 3. Spark Execution Model Relevant to ML

### Lazy Evaluation

Spark operations build a **Directed Acyclic Graph (DAG)** of transformations. Nothing executes until an **action** is triggered:

| Operation | Type | Triggers execution? |
|---|---|---|
| `filter()`, `select()`, `mutate()` (dplyr) | Transformation | No |
| `ft_vector_assembler()`, `ft_imputer()` (unfitted) | Transformation spec | No |
| `ml_fit()` | Action | **Yes** |
| `ml_transform()` | Action | **Yes** |
| `collect()` | Action | **Yes** |
| `sdf_nrow()` | Action | **Yes** |

**Implication:** building a long pipeline with `ml_pipeline()` and multiple `ft_*` calls has zero compute cost until `ml_fit()` is called.

### Partitioning and Data Distribution

Spark DataFrames are split into **partitions** distributed across executor nodes. For ML:
- `sdf_random_split()` operates at the partition level — weights are probabilistic, not exact
- Default partitioning is inherited from the source (e.g., number of Parquet files)
- Over-partitioned data → excessive overhead per task; under-partitioned → underutilized cluster
- `sdf_repartition(tbl, n)` before a pipeline fit can improve performance

### Caching for ML Workflows

When a DataFrame is used multiple times (e.g., during cross-validation), caching avoids recomputing it from the source:

```r
train_tbl <- sdf_register(train_tbl, "train_cached")
tbl_cache(sc, "train_cached")

# Now ml_fit() and subsequent operations reuse cached data
model <- ml_fit(pipeline, tbl(sc, "train_cached"))
```

Use `tbl_uncache(sc, "train_cached")` after the model is trained to free cluster memory.

---

## 4. Connecting the Dots: sparklyr + Spark ML in R

### Package Architecture

```
sparklyr
├── spark_connect() / spark_disconnect()     — connection management
├── spark_read_*() / spark_write_*()         — I/O (Parquet, Delta, CSV, JDBC)
├── dplyr interface → dbplyr → Spark SQL     — data manipulation
├── ft_*() functions                         — Feature Transformers / Estimators
├── ml_*() functions                         — ML algorithms + pipeline API
└── spark_apply()                            — arbitrary R on Spark partitions
```

### Spark ML in R vs Python

| Concept | Python (PySpark) | R (sparklyr) |
|---|---|---|
| Pipeline | `Pipeline([stage1, stage2])` | `ml_pipeline(sc) \|> ft_... \|> ml_...` |
| Fit | `model = pipeline.fit(train)` | `model <- ml_fit(pipeline, train_tbl)` |
| Transform | `pipeline.transform(test)` | `ml_transform(model, test_tbl)` |
| Predict | `model.transform(test)` | `ml_predict(model, test_tbl)` |
| Save | `model.save(path)` | `ml_save(model, path)` |
| Load | `PipelineModel.load(path)` | `ml_load(sc, path)` |

### SparkR vs sparklyr

**SparkR** is the official Apache Spark R binding. **Do not use it for new projects:**
- Deprecated since Spark 4.0.0
- Removed from Databricks Runtime 16.0+
- Databricks recommends sparklyr for all R workloads

**sparklyr** is maintained by Posit (RStudio) and is the standard:
- Native dplyr integration
- Supports Spark Connect (Databricks serverless)
- Active development and community

---

## 5. Key sparklyr ML Functions Reference

### Pipeline Construction

```r
ml_pipeline(sc)                    # Create empty pipeline
ml_pipeline(stage1, stage2, ...)   # Create pipeline from existing stages
```

### Fitting and Prediction

```r
ml_fit(pipeline, data)             # Fit pipeline or estimator; returns PipelineModel or fitted transformer
ml_transform(model, data)          # Apply transformer/pipeline to data; returns Spark DataFrame
ml_predict(model, data)            # Like ml_transform but adds user-friendly prediction columns
```

**`ml_predict` vs `ml_transform`:**
- `ml_transform` returns raw output columns as defined by each stage
- `ml_predict` adds additional columns: `prediction`, `probability` (for classifiers), `rawPrediction`
- For regression, both are equivalent

### Persistence

```r
ml_save(model, path, overwrite = FALSE)   # Save fitted pipeline/model to HDFS or cloud storage
ml_load(sc, path)                          # Reload saved model into current Spark session
```

### Model Metadata

```r
ml_stages(pipeline_model)         # List all stages in a fitted pipeline
ml_feature_importances(model, train_tbl)  # Feature importance for tree models
ml_summary(fitted_model)          # Training summary (coefficients, residuals, etc.)
```

### Evaluation

```r
# Binary classification
evaluator <- ml_binary_classification_evaluator(sc, label_col = "label",
                                                 raw_prediction_col = "rawPrediction",
                                                 metric_name = "areaUnderROC")
auc <- ml_evaluate(evaluator, predictions)

# Multiclass
evaluator <- ml_multiclass_classification_evaluator(sc, metric_name = "accuracy")
acc <- ml_evaluate(evaluator, predictions)

# Regression
evaluator <- ml_regression_evaluator(sc, label_col = "y",
                                      prediction_col = "prediction",
                                      metric_name = "rmse")
rmse <- ml_evaluate(evaluator, predictions)
```

---

## 6. When to Use Spark ML vs Local tidymodels

| Scenario | Use Spark ML | Use local tidymodels |
|---|---|---|
| Data size | > 10GB, won't fit in RAM | Fits comfortably in RAM |
| Training data | Lives in Delta Lake / S3 / HDFS | Already collected locally |
| Cluster available | Yes (Databricks, YARN, Kubernetes) | Not needed |
| Feature engineering | Needs distributed joins, aggregations | Pure local transformations |
| Model type | Needs MLlib (tree ensembles at scale) | Full tidymodels ecosystem (stacking, calibration) |
| Iteration speed | Slower (Spark startup overhead) | Faster for small/medium data |

**Hybrid pattern** (common in practice):
```r
# 1. Feature engineering and model training in Spark
pipeline_model <- ml_fit(pipeline, spark_train_tbl)

# 2. Collect small evaluation results locally
eval_results <- ml_predict(pipeline_model, spark_test_tbl) |>
  select(label, prediction, probability) |>
  collect()

# 3. Local analysis with tidymodels/yardstick
library(yardstick)
eval_results |> roc_auc(truth = label, prediction)
```

---

## 7. External Resources

- **sparklyr official site:** https://spark.posit.co/
- **MLlib guide (sparklyr):** https://spark.posit.co/guides/mlib.html
- **"Mastering Spark with R":** https://therinspark.com/
- **Apache Spark ML Pipelines:** https://spark.apache.org/docs/latest/ml-pipeline.html
- **sparklyr CRAN README:** https://cran.r-project.org/web/packages/sparklyr/readme/README.html
- **sparklyr cheatsheet:** https://rstudio.github.io/cheatsheets/html/sparklyr.html
