# Model Selection Guide

**Workflow:** modeling-pipeline
**Purpose:** Help choose appropriate machine learning algorithms for your problem

---

## Quick Selection Matrix

| Data Characteristics | Recommended Models | Avoid |
|---------------------|-------------------|-------|
| **Small data (<1K rows)** | Linear/Logistic, Ridge/Lasso, KNN | Deep learning, XGBoost |
| **Medium data (1K-100K)** | Random Forest, XGBoost, SVM, Neural nets | - |
| **Large data (>100K)** | XGBoost, LightGBM, Neural nets | KNN, SVM (without approximations) |
| **High-dimensional (p > n)** | Ridge/Lasso, Elastic Net | Unregularized linear models |
| **Mixed types (num + cat)** | Tree-based (RF, XGBoost) | KNN, SVM (without careful encoding) |
| **Only numeric** | Any model | - |
| **Only categorical** | Naive Bayes, Tree-based | Linear (without careful encoding) |
| **Requires interpretability** | Linear/Logistic, GAM, Tree (single), Rule-based | Deep learning, ensemble methods |
| **Speed critical** | Linear/Logistic, Naive Bayes | SVM, Deep learning |
| **Accuracy critical** | XGBoost, Neural nets, Stacking | Simple baselines only |

---

## Model Families

### 1. Linear Models

#### Linear Regression / Logistic Regression

**tidymodels spec:**
```r
linear_reg() %>% set_engine("lm")
logistic_reg() %>% set_engine("glm")
```

**Strengths:**
- Fast training and prediction
- Highly interpretable (coefficients = effects)
- Works well with many features
- Statistical inference available (p-values, confidence intervals)

**Weaknesses:**
- Assumes linear relationships
- Sensitive to outliers
- Cannot capture interactions (without manual specification)
- Multicollinearity issues

**Best for:**
- Small to medium datasets
- Linear relationships
- Interpretability required
- Baseline comparisons

**Typical performance:** Good baseline, often 70-80% of best possible.

---

#### Ridge / Lasso / Elastic Net

**tidymodels spec:**
```r
linear_reg(penalty = tune(), mixture = tune()) %>%
  set_engine("glmnet")
```

**Strengths:**
- Handles multicollinearity
- Automatic feature selection (Lasso)
- Works well with high-dimensional data (p > n)
- Prevents overfitting

**Weaknesses:**
- Still assumes linearity
- Requires scaling
- Penalty parameter tuning needed

**Best for:**
- High-dimensional data
- Correlated features
- Feature selection needed
- Regularization required

**mixture parameter:**
- `0` = Ridge (keeps all features, shrinks coefficients)
- `1` = Lasso (eliminates features, sparse solution)
- `0.5` = Elastic Net (balance of both)

---

### 2. Tree-Based Models

#### Decision Tree (Single)

**tidymodels spec:**
```r
decision_tree(tree_depth = tune(), min_n = tune()) %>%
  set_engine("rpart")
```

**Strengths:**
- Highly interpretable (visualization)
- Handles non-linearity
- No scaling required
- Handles mixed data types
- Automatic interaction detection

**Weaknesses:**
- High variance (overfitting)
- Poor extrapolation
- Unstable (small changes → different tree)

**Best for:**
- Exploratory analysis
- Understanding decision rules
- Visualization for stakeholders

**Typical performance:** Baseline only, usually outperformed by ensembles.

---

#### Random Forest

**tidymodels spec:**
```r
rand_forest(mtry = tune(), min_n = tune(), trees = 1000) %>%
  set_engine("ranger", importance = "impurity")
```

**Strengths:**
- Excellent out-of-box performance
- Handles non-linearity and interactions
- Robust to outliers
- No scaling required
- Feature importance available
- Low risk of overfitting (with enough trees)

**Weaknesses:**
- Less interpretable than single tree
- Slower prediction than linear models
- Memory intensive
- Can overfit small data

**Best for:**
- General-purpose modeling
- Mixed data types
- Feature importance needed
- Good default choice

**Typical performance:** Often 85-95% of best possible, excellent baseline.

**Key parameters:**
- `trees`: Number of trees (500-2000, more is better)
- `mtry`: Features per split (sqrt(p) for classification, p/3 for regression)
- `min_n`: Minimum node size (2-40)

---

#### Gradient Boosted Trees (XGBoost)

**tidymodels spec:**
```r
boost_tree(
  trees = 1000,
  tree_depth = tune(),
  min_n = tune(),
  loss_reduction = tune(),
  sample_size = tune(),
  mtry = tune(),
  learn_rate = tune()
) %>%
  set_engine("xgboost")
```

**Strengths:**
- Often best performer (Kaggle winner)
- Handles missing values
- Built-in regularization
- Efficient implementation
- Feature importance available

**Weaknesses:**
- Many hyperparameters to tune
- Easier to overfit than RF
- Less interpretable
- Slower training than RF

**Best for:**
- Maximizing accuracy
- Structured data
- Competitions
- When compute available for tuning

**Typical performance:** Often best or near-best, 90-99% of theoretical maximum.

**Key parameters:**
- `trees`: Number of boosting rounds (500-5000, use early stopping)
- `learn_rate`: Shrinkage (0.001-0.1, smaller = more trees needed)
- `tree_depth`: Tree complexity (3-10)
- `min_n`: Minimum node size (2-40)
- `sample_size`: Row sampling (0.5-1.0)
- `mtry`: Column sampling (0.3-1.0)

---

### 3. Support Vector Machines

#### SVM with RBF Kernel

**tidymodels spec:**
```r
svm_rbf(cost = tune(), rbf_sigma = tune()) %>%
  set_engine("kernlab")
```

**Strengths:**
- Excellent for non-linear boundaries
- Works well in high dimensions
- Robust to outliers (in feature space)
- Good theoretical foundations

**Weaknesses:**
- Slow on large datasets (O(n²) or worse)
- Requires careful scaling
- Many hyperparameters
- Difficult to interpret
- Memory intensive

**Best for:**
- Small to medium datasets (<50K rows)
- Non-linear patterns
- High-dimensional spaces
- When XGBoost/RF fail

**Typical performance:** Similar to RF, but more sensitive to tuning.

**Key parameters:**
- `cost`: Penalty for violations (2^-5 to 2^15, log scale)
- `rbf_sigma`: Kernel width (2^-15 to 2^3, log scale)

---

### 4. K-Nearest Neighbors

**tidymodels spec:**
```r
nearest_neighbor(neighbors = tune(), weight_func = tune()) %>%
  set_engine("kknn")
```

**Strengths:**
- Simple, intuitive
- No training time (lazy learning)
- Naturally handles multi-class
- Good for local patterns

**Weaknesses:**
- Slow prediction (searches entire dataset)
- Requires scaling
- Curse of dimensionality (poor in high dimensions)
- Memory intensive
- Sensitive to irrelevant features

**Best for:**
- Small datasets
- Local patterns
- Recommendation systems
- Anomaly detection

**Typical performance:** Good for specific cases, usually outperformed by tree methods.

**Key parameters:**
- `neighbors`: Number of neighbors (3-50)
- `weight_func`: Weighting scheme (uniform, distance-weighted)

---

### 5. Naive Bayes

**tidymodels spec:**
```r
naive_Bayes(smoothness = tune(), Laplace = tune()) %>%
  set_engine("naivebayes")
```

**Strengths:**
- Very fast training and prediction
- Works well with small data
- Handles high-dimensional data
- Good for text classification
- Probabilistic predictions

**Weaknesses:**
- Assumes feature independence (rarely true)
- Poor with correlated features
- Can be outperformed by other methods

**Best for:**
- Text classification
- Small datasets
- Need for speed
- Baseline comparisons

**Typical performance:** Good baseline, 70-85% of best possible for text, lower for tabular.

---

### 6. Neural Networks

#### Shallow Neural Network

**tidymodels spec:**
```r
mlp(hidden_units = tune(), penalty = tune(), epochs = tune()) %>%
  set_engine("nnet")
```

**Strengths:**
- Can approximate any function
- Handles non-linearity
- Flexible architecture

**Weaknesses:**
- Requires large data
- Many hyperparameters
- Difficult to train (local minima)
- Requires scaling
- Overfitting risk
- Black box

**Best for:**
- Large datasets (>10K rows)
- Complex non-linear patterns
- When tree methods plateau

**Typical performance:** Good with tuning, but often beaten by XGBoost on tabular data.

---

#### Deep Learning (torch/keras)

**For:** Image, text, time series, very large datasets

**Not covered in baseline comparisons** — use specialized workflows.

---

## Model Selection by Problem Type

### Regression Problems

**Recommended baseline suite:**
1. Linear Regression (baseline)
2. Ridge/Lasso (regularized baseline)
3. Random Forest (non-linear baseline)
4. XGBoost (strong performer)
5. SVM (if dataset <50K rows)

**Evaluation metrics:**
- Primary: RMSE or MAE
- Secondary: R², MAPE

---

### Binary Classification

**Recommended baseline suite:**
1. Logistic Regression (baseline)
2. Ridge/Lasso Logistic (regularized baseline)
3. Random Forest (non-linear baseline)
4. XGBoost (strong performer)
5. Naive Bayes (if text or small data)

**Evaluation metrics:**
- Balanced classes: Accuracy, ROC-AUC
- Imbalanced classes: PR-AUC, F1-score

---

### Multi-Class Classification

**Recommended baseline suite:**
1. Multinomial Logistic (baseline)
2. Random Forest (strong performer)
3. XGBoost (often best)
4. Naive Bayes (if text)

**Evaluation metrics:**
- Macro-averaged F1 (treats all classes equally)
- Weighted-averaged F1 (accounts for class imbalance)
- Confusion matrix

---

### Time Series Forecasting

**Recommended baseline suite:**
1. ARIMA (statistical baseline)
2. ETS (exponential smoothing)
3. Prophet (trend + seasonality)
4. XGBoost with time features (ML approach)

**Evaluation metrics:**
- RMSE, MAE on test period
- MASE (Mean Absolute Scaled Error)

---

## Special Considerations

### Imbalanced Classes

**Strategies:**
1. **Resampling:**
   - `step_downsample()` (reduce majority)
   - `step_upsample()` (increase minority)
   - `step_smote()` (synthetic minority)

2. **Cost-sensitive learning:**
   - Weighted models (e.g., `class.weights` in RF)
   - Focal loss (neural networks)

3. **Metrics:**
   - Use PR-AUC instead of ROC-AUC
   - F1-score, precision, recall

**Best models for imbalanced data:**
- XGBoost with `scale_pos_weight`
- Random Forest with class weights
- Cost-sensitive SVM

---

### High-Dimensional Data (p > n)

**Recommended models:**
1. Ridge/Lasso/Elastic Net (best starting point)
2. Random Forest with `mtry` tuning
3. XGBoost with strong regularization

**Avoid:**
- Unregularized linear models (will fail)
- KNN (curse of dimensionality)

**Preprocessing:**
- Feature selection (Lasso)
- Dimensionality reduction (PCA)
- Domain-driven feature reduction

---

### Mixed Data Types

**Best models:**
- Tree-based models (RF, XGBoost) — handle naturally
- Naive Bayes — works well with mixed types

**For other models:**
- Dummy encoding for categories
- Target encoding for high-cardinality
- Careful recipe design

---

### Interpretability Requirements

**Most to Least Interpretable:**
1. Linear/Logistic Regression — Coefficients directly interpretable
2. GAMs (Generalized Additive Models) — Non-linear but interpretable
3. Single Decision Tree — Visualization of rules
4. Rule-based models (Cubist, RuleFit) — Explicit rules
5. Random Forest — Feature importance, partial dependence
6. XGBoost — Feature importance, SHAP values
7. Neural Networks — SHAP, LIME (post-hoc)

**For regulated industries:** Prefer linear models or GAMs with post-hoc interpretation.

---

## Computational Considerations

### Training Time (1M rows, 20 features, 10-fold CV)

| Model | Training Time | Tuning Feasibility |
|-------|---------------|-------------------|
| Linear/Logistic | Seconds | Very easy |
| Ridge/Lasso | Seconds-Minutes | Easy |
| Naive Bayes | Seconds | Easy |
| KNN | Seconds (lazy) | Easy |
| Random Forest | Minutes-Hours | Moderate |
| XGBoost | Minutes-Hours | Moderate |
| SVM | Hours-Days | Hard |
| Neural Network | Hours-Days | Hard |

---

### Prediction Time (Single observation)

| Model | Prediction Time |
|-------|-----------------|
| Linear/Logistic | <1ms |
| Ridge/Lasso | <1ms |
| Naive Bayes | <1ms |
| Random Forest | 1-10ms |
| XGBoost | 1-10ms |
| KNN | 10-100ms |
| SVM | 10-100ms |
| Neural Network | 1-10ms |

**For real-time applications:** Prefer linear models or shallow trees.

---

## Ensemble Methods

### Stacking

Combine multiple models:
```r
library(stacks)

stack <- stacks() %>%
  add_candidates(xgb_results) %>%
  add_candidates(rf_results) %>%
  add_candidates(glmnet_results) %>%
  blend_predictions() %>%
  fit_members()
```

**Pros:** Often best performance
**Cons:** Complex, slow, less interpretable

---

### Voting / Averaging

Simple average of predictions:
- Classification: Majority vote
- Regression: Mean/median of predictions

**Pros:** Simple, robust
**Cons:** Assumes models are diverse

---

## Algorithm Decision Tree

```
Start
├─ Need interpretability?
│  ├─ Yes → Linear/Logistic, GAM, Single Tree
│  └─ No ↓
│
├─ Large dataset (>100K)?
│  ├─ Yes → XGBoost, Neural Networks
│  └─ No ↓
│
├─ High-dimensional (p > n)?
│  ├─ Yes → Ridge/Lasso, XGBoost with regularization
│  └─ No ↓
│
├─ Mixed data types?
│  ├─ Yes → Random Forest, XGBoost
│  └─ No ↓
│
├─ Need speed?
│  ├─ Yes → Linear models, Naive Bayes
│  └─ No ↓
│
└─ Maximize accuracy?
   └─ XGBoost, Stacking, Neural Networks
```

---

## Common Mistakes

**❌ Using only one model type**
**✅ Compare multiple families (linear, tree, ensemble)**

**❌ Starting with deep learning**
**✅ Start with baselines, escalate if needed**

**❌ Ignoring computational cost**
**✅ Consider production requirements from start**

**❌ Choosing model based on name recognition**
**✅ Choose based on problem characteristics**

**❌ Skipping interpretability assessment**
**✅ Consider stakeholder needs early**

---

## Further Resources

- **tidymodels model database:** https://www.tidymodels.org/find/parsnip/
- **Algorithm comparison papers:** Various Kaggle competition write-ups
- **Theory:** "The Elements of Statistical Learning" (Hastie, Tibshirani, Friedman)

---

**When in doubt:** Start with Linear + Random Forest + XGBoost baseline.

This covers 90% of use cases and gives excellent insight into your data.
