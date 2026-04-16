# Hyperparameter Tuning Strategies Reference

**Purpose:** Comprehensive guide to hyperparameters for common tidymodels algorithms

**Last Updated:** 2026-03-17

---

## Random Forest (`rand_forest`)

**Package:** `ranger` (recommended) or `randomForest`

### Tunable Parameters

| Parameter | Description | Type | Default | Search Range | Transform | Importance |
|-----------|-------------|------|---------|--------------|-----------|------------|
| `mtry` | # predictors per split | Integer | sqrt(p) class, p/3 reg | 1 to p | Linear | HIGH |
| `trees` | # trees in forest | Integer | 500 | 100-2000 | Linear | MEDIUM |
| `min_n` | Minimum node size | Integer | 1 (class), 5 (reg) | 1-40 | Linear | MEDIUM |

### Tuning Strategy

**Quick:** Fix `trees=1000`, tune `mtry` and `min_n`
**Thorough:** Tune all three parameters
**Racing:** Start with 500 trees, increase if needed

**Parameter Interactions:**
- `mtry` and `min_n` interact: smaller `mtry` often needs smaller `min_n`
- `trees`: More is usually better but diminishing returns after 1000-1500

**Common Ranges:**
```r
rand_forest() %>%
  set_engine("ranger") %>%
  set_mode("classification") %>%
  set_args(
    mtry = tune(),
    trees = tune(),
    min_n = tune()
  )

# Search space
param_grid <- grid_latin_hypercube(
  mtry(range = c(1, [n_features])),
  trees(range = c(500, 2000)),
  min_n(range = c(2, 40)),
  size = 100
)
```

---

## Boosted Trees (`boost_tree`)

**Package:** `xgboost` (recommended), `lightgbm`, or `catboost`

### Tunable Parameters (XGBoost)

| Parameter | Description | Type | Default | Search Range | Transform | Importance |
|-----------|-------------|------|---------|--------------|-----------|------------|
| `trees` | # boosting iterations | Integer | 15 | 50-5000 | Linear | HIGH |
| `tree_depth` | Maximum tree depth | Integer | 6 | 1-15 | Linear | HIGH |
| `learn_rate` | Learning rate (eta) | Numeric | 0.3 | 0.001-0.3 | Log | HIGH |
| `mtry` | # predictors per tree | Integer | p | 1 to p | Linear | MEDIUM |
| `min_n` | Minimum observations per node | Integer | 1 | 1-40 | Linear | MEDIUM |
| `loss_reduction` | Minimum loss reduction (gamma) | Numeric | 0 | 0-10 | Linear | LOW |
| `sample_size` | Row sampling fraction | Numeric | 1 | 0.5-1.0 | Linear | LOW |

### Tuning Strategy

**Quick:** Fix `trees=1000`, tune `tree_depth` and `learn_rate`
**Standard:** Tune `trees`, `tree_depth`, `learn_rate`, `min_n`
**Thorough:** Tune all parameters

**Parameter Interactions:**
- `learn_rate` and `trees`: Inversely related (lower learn_rate needs more trees)
- `tree_depth` and `learn_rate`: Complex interaction, tune together
- Early stopping recommended: stop if no improvement for 50 rounds

**Common Ranges:**
```r
boost_tree() %>%
  set_engine("xgboost") %>%
  set_mode("classification") %>%
  set_args(
    trees = tune(),
    tree_depth = tune(),
    learn_rate = tune(),
    mtry = tune(),
    min_n = tune(),
    loss_reduction = tune(),
    sample_size = tune()
  )

# Search space
param_grid <- grid_latin_hypercube(
  trees(range = c(100, 2000)),
  tree_depth(range = c(3, 10)),
  learn_rate(range = c(0.001, 0.3), trans = log10_trans()),
  mtry(range = c(1, [n_features])),
  min_n(range = c(2, 40)),
  loss_reduction(range = c(0, 5)),
  sample_size(range = c(0.5, 1.0)),
  size = 100
)
```

**XGBoost Early Stopping:**
```r
set_engine(
  "xgboost",
  early_stopping_rounds = 50,
  validation = 0.2  # Use 20% for early stopping
)
```

---

## Neural Network (`mlp`)

**Package:** `nnet` (simple), `keras` (deep learning), `brulee` (torch)

### Tunable Parameters (nnet)

| Parameter | Description | Type | Default | Search Range | Transform | Importance |
|-----------|-------------|------|---------|--------------|-----------|------------|
| `hidden_units` | # neurons in hidden layer | Integer | 5 | 1-50 | Linear | HIGH |
| `penalty` | L2 regularization (weight decay) | Numeric | 0 | 0.0001-10 | Log | HIGH |
| `epochs` | # training iterations | Integer | 100 | 50-500 | Linear | MEDIUM |

### Tunable Parameters (keras/brulee - deep networks)

| Parameter | Description | Type | Default | Search Range | Transform | Importance |
|-----------|-------------|------|---------|--------------|-----------|------------|
| `hidden_units` | Neurons per layer | Integer | 100 | 16-512 | Log | HIGH |
| `num_layers` | # hidden layers | Integer | 1 | 1-5 | Linear | HIGH |
| `dropout` | Dropout rate | Numeric | 0 | 0-0.5 | Linear | HIGH |
| `learn_rate` | Learning rate | Numeric | 0.001 | 0.0001-0.1 | Log | HIGH |
| `activation` | Activation function | Categorical | relu | [relu, elu, tanh] | - | MEDIUM |
| `batch_size` | Mini-batch size | Integer | 32 | 16-256 | Log | LOW |
| `epochs` | # training epochs | Integer | 20 | 10-100 | Linear | MEDIUM |

### Tuning Strategy

**Quick:** Fix architecture, tune `penalty` or `dropout` and `learn_rate`
**Standard:** Tune `hidden_units`, `penalty`/`dropout`, `learn_rate`
**Thorough:** Tune architecture (`num_layers`, `hidden_units`) + regularization + learning

**Parameter Interactions:**
- `hidden_units` and `penalty`/`dropout`: Larger networks need more regularization
- `learn_rate` and `epochs`: Lower learn_rate needs more epochs
- `batch_size` and `learn_rate`: Larger batches can use higher learn rates

**Common Ranges (nnet):**
```r
mlp() %>%
  set_engine("nnet") %>%
  set_mode("classification") %>%
  set_args(
    hidden_units = tune(),
    penalty = tune(),
    epochs = tune()
  )

# Search space
param_grid <- grid_latin_hypercube(
  hidden_units(range = c(2, 30)),
  penalty(range = c(-5, 1), trans = log10_trans()),
  epochs(range = c(50, 300)),
  size = 50
)
```

**Common Ranges (keras/brulee):**
```r
mlp() %>%
  set_engine("brulee") %>%
  set_mode("classification") %>%
  set_args(
    hidden_units = tune(),
    num_layers = tune(),
    dropout = tune(),
    learn_rate = tune(),
    epochs = tune()
  )

# Search space
param_grid <- grid_latin_hypercube(
  hidden_units(range = c(16, 256), trans = log2_trans()),
  num_layers(range = c(1, 4)),
  dropout(range = c(0, 0.5)),
  learn_rate(range = c(0.0001, 0.1), trans = log10_trans()),
  epochs(range = c(20, 100)),
  size = 100
)
```

---

## Support Vector Machine (`svm_rbf`, `svm_poly`)

**Package:** `kernlab` or `LiblineaR`

### Tunable Parameters (RBF kernel)

| Parameter | Description | Type | Default | Search Range | Transform | Importance |
|-----------|-------------|------|---------|--------------|-----------|------------|
| `cost` | Cost parameter (C) | Numeric | 1 | 0.01-100 | Log | HIGH |
| `rbf_sigma` | RBF kernel width | Numeric | auto | 0.0001-1 | Log | HIGH |

### Tunable Parameters (Polynomial kernel)

| Parameter | Description | Type | Default | Search Range | Transform | Importance |
|-----------|-------------|------|---------|--------------|-----------|------------|
| `cost` | Cost parameter (C) | Numeric | 1 | 0.01-100 | Log | HIGH |
| `degree` | Polynomial degree | Integer | 3 | 1-5 | Linear | HIGH |
| `scale_factor` | Scaling parameter | Numeric | 1 | 0.1-2 | Linear | MEDIUM |

### Tuning Strategy

**Quick:** Tune `cost` only (fix kernel parameters)
**Standard:** Tune `cost` and kernel parameter (`rbf_sigma` or `degree`)
**Thorough:** Grid search over wide ranges

**Parameter Interactions:**
- `cost` and `rbf_sigma`: Trade-off between margin width and kernel complexity
- Higher `cost` = less regularization (more complex boundary)

**Common Ranges (RBF):**
```r
svm_rbf() %>%
  set_engine("kernlab") %>%
  set_mode("classification") %>%
  set_args(
    cost = tune(),
    rbf_sigma = tune()
  )

# Search space
param_grid <- grid_latin_hypercube(
  cost(range = c(-2, 2), trans = log10_trans()),  # 0.01 to 100
  rbf_sigma(range = c(-4, 0), trans = log10_trans()),  # 0.0001 to 1
  size = 50
)
```

---

## K-Nearest Neighbors (`nearest_neighbor`)

**Package:** `kknn`

### Tunable Parameters

| Parameter | Description | Type | Default | Search Range | Transform | Importance |
|-----------|-------------|------|---------|--------------|-----------|------------|
| `neighbors` | # neighbors (k) | Integer | 5 | 1-50 | Linear | HIGH |
| `weight_func` | Distance weighting | Categorical | optimal | [rectangular, triangular, cos, inv, gaussian, optimal] | - | MEDIUM |
| `dist_power` | Minkowski distance power | Numeric | 2 | 1-2 | Linear | LOW |

### Tuning Strategy

**Quick:** Tune `neighbors` only
**Standard:** Tune `neighbors` and `weight_func`
**Thorough:** Add `dist_power`

**Parameter Interactions:**
- Odd `neighbors` recommended for classification (breaks ties)
- `weight_func`: 'optimal' usually best but computationally expensive

**Common Ranges:**
```r
nearest_neighbor() %>%
  set_engine("kknn") %>%
  set_mode("classification") %>%
  set_args(
    neighbors = tune(),
    weight_func = tune()
  )

# Search space
param_grid <- grid_latin_hypercube(
  neighbors(range = c(1, 30)),
  weight_func(values = c("rectangular", "triangular", "optimal")),
  size = 30
)
```

---

## Regularized Regression (`linear_reg`, `logistic_reg`)

**Package:** `glmnet` (elastic net)

### Tunable Parameters

| Parameter | Description | Type | Default | Search Range | Transform | Importance |
|-----------|-------------|------|---------|--------------|-----------|------------|
| `penalty` | Lambda (regularization strength) | Numeric | 0 | 0.0001-10 | Log | HIGH |
| `mixture` | Alpha (elastic net mixing) | Numeric | 1 | 0-1 | Linear | HIGH |

### Parameter Interpretation

- `mixture = 0`: Ridge regression (L2 only)
- `mixture = 1`: Lasso regression (L1 only)
- `mixture = 0.5`: True elastic net (balance L1/L2)

### Tuning Strategy

**Quick:** Tune `penalty` only (fix `mixture=1` for Lasso)
**Standard:** Tune both `penalty` and `mixture`
**Grid:** Use log scale for `penalty`

**Common Ranges:**
```r
logistic_reg() %>%
  set_engine("glmnet") %>%
  set_args(
    penalty = tune(),
    mixture = tune()
  )

# Search space
param_grid <- grid_latin_hypercube(
  penalty(range = c(-4, 1), trans = log10_trans()),  # 0.0001 to 10
  mixture(range = c(0, 1)),
  size = 50
)
```

---

## Decision Tree (`decision_tree`)

**Package:** `rpart`

### Tunable Parameters

| Parameter | Description | Type | Default | Search Range | Transform | Importance |
|-----------|-------------|------|---------|--------------|-----------|------------|
| `tree_depth` | Maximum depth | Integer | 30 | 1-30 | Linear | HIGH |
| `min_n` | Minimum node size | Integer | 20 | 2-100 | Linear | HIGH |
| `cost_complexity` | Complexity parameter (cp) | Numeric | 0.01 | 0.0001-0.1 | Log | MEDIUM |

### Tuning Strategy

**Quick:** Tune `tree_depth` and `min_n`
**Standard:** Add `cost_complexity`
**Pruning:** Use `cost_complexity` for post-pruning

**Common Ranges:**
```r
decision_tree() %>%
  set_engine("rpart") %>%
  set_mode("classification") %>%
  set_args(
    tree_depth = tune(),
    min_n = tune(),
    cost_complexity = tune()
  )

# Search space
param_grid <- grid_latin_hypercube(
  tree_depth(range = c(1, 20)),
  min_n(range = c(2, 40)),
  cost_complexity(range = c(-5, -1), trans = log10_trans()),
  size = 50
)
```

---

## General Tuning Principles

### Search Space Design

**1. Parameter Transformations**
- **Log scale:** Learning rates, regularization, small numeric parameters
- **Linear scale:** Counts (trees, layers, neighbors), proportions
- **Categorical:** Activation functions, kernels, distance metrics

**2. Range Selection**
- Start WIDE (you can always narrow)
- Include default in the range
- Check literature for reasonable ranges
- Consider computational constraints

**3. Grid Strategies**

**Grid Search:**
- Exhaustive but expensive
- Good for 1-3 parameters
- Use `grid_regular()` for factorial grid

**Random Search:**
- Good baseline, cheap
- Use `grid_random()` with large size (100-300)

**Latin Hypercube:**
- Better coverage than random
- Use `grid_latin_hypercube()` (recommended for most cases)
- Size: 10x number of parameters as starting point

**Bayesian Optimization:**
- Best for expensive models
- Use `tune_bayes()` with 50-100 iterations
- Learns which regions are promising

**Racing:**
- Most efficient for large grids
- Use `tune_race_anova()` or `tune_race_win_loss()`
- Eliminates poor configs early

### Computational Budget

**Small Budget (< 1 hour):**
- Random search or small grid (20-50 configs)
- Tune 1-2 most important parameters

**Medium Budget (1-8 hours):**
- Latin Hypercube (50-100 configs)
- Tune 3-5 parameters
- Consider Bayesian optimization

**Large Budget (1-3 days):**
- Bayesian optimization (50+ iterations)
- Racing methods (100-200 configs)
- Ensemble strategies
- Full hyperparameter exploration

### Parallel Processing

**Recommendations:**
- Use all available cores
- Parallel over resamples (folds) first
- For large grids, parallel over everything
- Monitor memory usage (deep learning can OOM)

**Setup:**
```r
library(doParallel)
cl <- makeCluster(parallel::detectCores() - 1)  # Leave 1 core free
registerDoParallel(cl)

# After tuning
stopCluster(cl)
```

### Early Stopping

**XGBoost/LightGBM:**
```r
boost_tree() %>%
  set_engine("xgboost", early_stopping_rounds = 50)
```

**Neural Networks:**
```r
mlp() %>%
  set_engine("brulee", stop_iter = 10)  # Stop if no improvement
```

### Cross-Validation Strategy

**K-Fold CV:**
- Standard: 10-fold
- Small data: Leave-one-out (LOOCV)
- Large data: 5-fold (faster)

**Repeated CV:**
- More stable estimates
- Use 5-fold repeated 3-10 times
- Expensive but reduces variance

**Time Series:**
- Use `rolling_origin()` for time series
- Never shuffle time series data

### Metric Selection

**Classification:**
- Binary: `roc_auc`, `pr_auc`, `f_meas`
- Multiclass: `mn_log_loss`, `accuracy`, `kap`
- Imbalanced: `bal_accuracy`, `f_meas`, `pr_auc`

**Regression:**
- Default: `rmse`, `rsq`, `mae`
- Robust: `huber_loss`, `mape`
- Quantile: Custom metric for quantile regression

### Common Mistakes to Avoid

❌ **Search Space Too Narrow** — Parameters hit boundaries
❌ **Not Using Transformations** — Linear scale for learning rates (wrong!)
❌ **Ignoring Interactions** — Some parameters depend on others
❌ **Too Many Parameters** — Start with high-impact parameters
❌ **Single Fold Evaluation** — Use proper CV for honest estimates
❌ **Test Set Peeking** — Never touch test set during tuning
❌ **No Baseline** — Always compare to simple baseline
❌ **Premature Stopping** — Check convergence before stopping

---

## Model-Specific Tips

### Random Forest
- Usually robust to hyperparameters
- Focus on `mtry` (most important)
- More trees rarely hurts (diminishing returns after 1000)

### XGBoost
- Learning rate most important
- Start with `learn_rate=0.01`, `trees=1000`
- Use early stopping (saves time and prevents overfitting)
- Tune regularization if overfitting (`min_n`, `loss_reduction`)

### Neural Networks
- Most sensitive to hyperparameters
- Start small, gradually increase capacity
- Regularization (dropout, penalty) critical
- Learning rate most impactful
- Use learning rate schedules for long training

### SVM
- Scale features first (critical!)
- RBF kernel good default
- Tune `cost` first, then kernel parameters
- Sensitive to data scale

### KNN
- Simple but sensitive to `k`
- Always scale features
- Odd `k` for classification
- Distance-weighted usually better than uniform

---

## References

- [tidymodels documentation](https://www.tidymodels.org/)
- [parsnip parameter reference](https://parsnip.tidymodels.org/reference/index.html)
- [tune package](https://tune.tidymodels.org/)
- [finetune package](https://finetune.tidymodels.org/)

---

_Reference guide for RDS Hyperparameter Optimization Workflow_
