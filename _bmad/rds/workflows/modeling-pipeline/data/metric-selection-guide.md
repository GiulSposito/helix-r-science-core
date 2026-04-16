# Metric Selection Guide

**Workflow:** modeling-pipeline
**Purpose:** Choose appropriate evaluation metrics for your modeling problem

---

## Quick Selection Table

| Problem Type | Primary Metric | Secondary Metrics |
|--------------|---------------|-------------------|
| **Regression (general)** | RMSE | MAE, R², MAPE |
| **Regression (outliers)** | MAE, Huber Loss | RMSE, R² |
| **Regression (relative errors)** | MAPE, sMAPE | RMSE, MAE |
| **Binary Classification (balanced)** | ROC-AUC, Accuracy | F1, Precision, Recall |
| **Binary Classification (imbalanced)** | PR-AUC | F1, F-beta, Precision@k |
| **Multi-Class (balanced)** | Macro-F1, Accuracy | Per-class metrics |
| **Multi-Class (imbalanced)** | Weighted-F1 | Macro-F1, Per-class metrics |
| **Ranking** | NDCG, MAP | MRR, Precision@k |
| **Probabilistic predictions** | Log Loss (Brier Score) | Calibration metrics |

---

## Regression Metrics

### 1. Root Mean Squared Error (RMSE)

**Formula:**
```
RMSE = sqrt(mean((y_true - y_pred)²))
```

**tidymodels:**
```r
metric_set(rmse)
```

**Interpretation:**
- Same units as target variable
- Lower is better
- Penalizes large errors heavily (squared term)

**Best for:**
- General-purpose regression
- When large errors are particularly costly
- Standard metric for comparisons

**Avoid when:**
- Severe outliers present (overemphasizes them)
- Errors should be treated equally (use MAE)

**Range:** [0, ∞)

**Example:**
- Target: House prices ($100K-$500K)
- RMSE: $25K means average prediction error of $25K (with more weight on large errors)

---

### 2. Mean Absolute Error (MAE)

**Formula:**
```
MAE = mean(|y_true - y_pred|)
```

**tidymodels:**
```r
metric_set(mae)
```

**Interpretation:**
- Same units as target variable
- Lower is better
- All errors weighted equally

**Best for:**
- Robust to outliers
- When all errors equally important
- More interpretable than RMSE

**Avoid when:**
- Large errors should be penalized more

**Range:** [0, ∞)

**Comparison to RMSE:**
- MAE ≤ RMSE always
- Larger gap = more outliers or large errors

---

### 3. R-Squared (R²)

**Formula:**
```
R² = 1 - (SS_residual / SS_total)
```

**tidymodels:**
```r
metric_set(rsq)
```

**Interpretation:**
- Proportion of variance explained
- Higher is better
- Scale-free (comparable across datasets)

**Best for:**
- Understanding model fit
- Comparing models on different datasets
- Scientific reporting

**Avoid when:**
- Using for model selection (can be misleading)
- Non-linear relationships without transformation

**Range:** (-∞, 1]
- 1.0: Perfect predictions
- 0.0: Model no better than mean
- <0: Model worse than predicting mean

**Caution:** Can be negative on test set (if worse than mean baseline).

---

### 4. Mean Absolute Percentage Error (MAPE)

**Formula:**
```
MAPE = mean(|y_true - y_pred| / |y_true|) × 100
```

**tidymodels:**
```r
metric_set(mape)
```

**Interpretation:**
- Percentage units (scale-free)
- Lower is better
- Easy to communicate to stakeholders

**Best for:**
- Relative error matters more than absolute
- Comparing across different scales
- Business reporting (e.g., "5% average error")

**Avoid when:**
- Target contains zeros (division by zero)
- Target has values near zero (explodes)
- Asymmetric penalties (penalizes under-predictions more)

**Range:** [0, ∞)

**Example:**
- MAPE = 10% means average error is 10% of actual value

---

### 5. Symmetric MAPE (sMAPE)

**Formula:**
```
sMAPE = mean(2 × |y_true - y_pred| / (|y_true| + |y_pred|)) × 100
```

**tidymodels:**
```r
metric_set(smape)
```

**Interpretation:**
- Symmetric version of MAPE
- Lower is better
- Bounded between 0-200%

**Best for:**
- Addressing MAPE asymmetry
- Time series forecasting

**Range:** [0, 200]

---

### 6. Huber Loss

**Formula:**
```
Huber = mean(
  if |y_true - y_pred| ≤ δ:
    0.5 × (y_true - y_pred)²
  else:
    δ × (|y_true - y_pred| - 0.5 × δ)
)
```

**tidymodels:**
```r
metric_set(huber_loss)
```

**Interpretation:**
- Hybrid of RMSE (small errors) and MAE (large errors)
- Lower is better
- Robust to outliers while still penalizing small errors

**Best for:**
- Data with outliers
- Balance between RMSE and MAE

**Parameter:**
- δ (delta): Threshold between quadratic and linear (default: 1)

---

### 7. Mean Absolute Scaled Error (MASE)

**Formula:**
```
MASE = MAE(model) / MAE(naive_forecast)
```

**Best for:**
- Time series forecasting
- Comparing across series with different scales

**Interpretation:**
- <1: Better than naive forecast
- =1: Same as naive forecast
- >1: Worse than naive forecast

---

## Classification Metrics

### 1. Accuracy

**Formula:**
```
Accuracy = (TP + TN) / (TP + TN + FP + FN)
```

**tidymodels:**
```r
metric_set(accuracy)
```

**Interpretation:**
- Proportion of correct predictions
- Higher is better
- Easy to understand

**Best for:**
- Balanced classes
- All errors equally costly
- Quick baseline

**Avoid when:**
- Imbalanced classes (misleading)
- Different costs for FP vs FN

**Range:** [0, 1]

**Example:**
- 95% accuracy with 95% negative class → model predicting all negatives!

---

### 2. ROC-AUC (Area Under ROC Curve)

**Interpretation:**
- Probability model ranks random positive higher than random negative
- Higher is better (0.5 = random, 1.0 = perfect)

**tidymodels:**
```r
metric_set(roc_auc)
```

**Best for:**
- Balanced or moderately imbalanced classes
- Comparing models without choosing threshold
- Medical diagnostics, fraud detection

**Avoid when:**
- Severely imbalanced classes (optimistic)
- Care about precision at specific recall levels

**Range:** [0, 1]
- 0.5: Random guessing
- 0.6-0.7: Poor
- 0.7-0.8: Fair
- 0.8-0.9: Good
- 0.9-1.0: Excellent

---

### 3. PR-AUC (Precision-Recall AUC)

**Interpretation:**
- Area under precision-recall curve
- Higher is better
- More informative than ROC-AUC for imbalanced data

**tidymodels:**
```r
metric_set(pr_auc)
```

**Best for:**
- Imbalanced classes (especially rare positive class)
- When false positives costly
- Information retrieval, medical screening

**Avoid when:**
- Balanced classes (ROC-AUC easier to interpret)

**Range:** [baseline, 1]
- Baseline = prevalence of positive class

---

### 4. F1-Score

**Formula:**
```
F1 = 2 × (Precision × Recall) / (Precision + Recall)
```

**tidymodels:**
```r
metric_set(f_meas)
```

**Interpretation:**
- Harmonic mean of precision and recall
- Higher is better
- Balanced measure

**Best for:**
- Imbalanced classes
- Balance between precision and recall
- Single metric for model selection

**Range:** [0, 1]

**Components:**
- **Precision:** TP / (TP + FP) — "How many selected are relevant?"
- **Recall:** TP / (TP + FN) — "How many relevant are selected?"

---

### 5. F-beta Score

**Formula:**
```
F_β = (1 + β²) × (Precision × Recall) / (β² × Precision + Recall)
```

**tidymodels:**
```r
metric_set(f_meas_beta)
```

**Interpretation:**
- Weighted harmonic mean
- β controls precision/recall trade-off

**Parameters:**
- **β < 1:** Emphasize precision (e.g., β=0.5)
- **β = 1:** F1-score (balanced)
- **β > 1:** Emphasize recall (e.g., β=2)

**Best for:**
- Custom precision/recall priorities
- Domain-specific cost trade-offs

**Example:**
- Medical screening: Use β=2 (prefer false alarms over missed cases)
- Spam detection: Use β=0.5 (prefer missing spam over false positives)

---

### 6. Sensitivity (Recall, True Positive Rate)

**Formula:**
```
Sensitivity = TP / (TP + FN)
```

**tidymodels:**
```r
metric_set(sens)
```

**Interpretation:**
- Proportion of actual positives correctly identified
- Higher is better

**Best for:**
- Medical diagnosis (find all cases)
- Fraud detection (catch all fraud)
- Minimizing false negatives

**Range:** [0, 1]

---

### 7. Specificity (True Negative Rate)

**Formula:**
```
Specificity = TN / (TN + FP)
```

**tidymodels:**
```r
metric_set(spec)
```

**Interpretation:**
- Proportion of actual negatives correctly identified
- Higher is better

**Best for:**
- Minimizing false alarms
- High cost of false positives

**Range:** [0, 1]

---

### 8. Precision (Positive Predictive Value)

**Formula:**
```
Precision = TP / (TP + FP)
```

**tidymodels:**
```r
metric_set(precision)
```

**Interpretation:**
- Among predicted positives, how many are correct?
- Higher is better

**Best for:**
- Cost of false positive high
- Limited resources for follow-up

**Example:**
- Marketing: High precision = don't waste money on wrong targets

**Range:** [0, 1]

---

### 9. Log Loss (Cross-Entropy)

**Formula:**
```
Log Loss = -mean(y_true × log(y_pred) + (1 - y_true) × log(1 - y_pred))
```

**tidymodels:**
```r
metric_set(mn_log_loss)  # Multi-class log loss
```

**Interpretation:**
- Penalizes confident wrong predictions heavily
- Lower is better

**Best for:**
- Probabilistic predictions important
- Need well-calibrated probabilities
- Multi-class problems

**Avoid when:**
- Only care about class labels (use accuracy/F1)

**Range:** [0, ∞)

---

### 10. Cohen's Kappa

**Formula:**
```
Kappa = (p_o - p_e) / (1 - p_e)
```

**tidymodels:**
```r
metric_set(kap)
```

**Interpretation:**
- Agreement beyond chance
- Accounts for imbalance

**Best for:**
- Imbalanced classes
- Inter-rater agreement
- Classification with chance component

**Range:** [-1, 1]
- <0: Worse than chance
- 0: Agreement by chance
- 0.4-0.6: Moderate
- 0.6-0.8: Substantial
- >0.8: Almost perfect

---

## Multi-Class Metrics

### Macro vs Micro vs Weighted Averaging

**Macro-average:**
- Calculate metric per class, then average
- Treats all classes equally
- Use when all classes equally important

**Micro-average:**
- Pool all predictions, calculate single metric
- Dominated by frequent classes
- Use when classes have natural frequency

**Weighted-average:**
- Weight each class by frequency
- Balance between macro and micro
- Use when class importance ∝ frequency

**tidymodels:**
```r
# Macro
f_meas(data, truth, estimate, estimator = "macro")

# Micro
f_meas(data, truth, estimate, estimator = "micro")

# Weighted (default for multi-class)
f_meas(data, truth, estimate)
```

---

## Metric Selection Decision Tree

```
Start
├─ Regression or Classification?
│
├─ REGRESSION
│  ├─ Outliers present?
│  │  ├─ Yes → MAE, Huber Loss
│  │  └─ No → RMSE
│  │
│  ├─ Need scale-free metric?
│  │  └─ Yes → MAPE, R²
│  │
│  └─ Time series?
│     └─ Yes → MASE, sMAPE
│
└─ CLASSIFICATION
   ├─ Balanced classes?
   │  ├─ Yes → ROC-AUC, Accuracy
   │  └─ No → PR-AUC, F1-Score
   │
   ├─ Need probabilities?
   │  └─ Yes → Log Loss, Brier Score
   │
   ├─ Custom cost trade-off?
   │  └─ Yes → F-beta, Custom metric
   │
   └─ Multi-class?
      └─ Macro-F1, Weighted-F1
```

---

## Custom Metrics

### Define Custom Metric

```r
library(yardstick)

# Example: Mean Absolute Scaled Error
mase_vec <- function(truth, estimate, ...) {
  mae_model <- mean(abs(truth - estimate))
  mae_naive <- mean(abs(diff(truth)))  # Naive forecast
  mae_model / mae_naive
}

# Create metric function
mase <- new_numeric_metric(mase_vec, direction = "minimize")

# Use in metric_set
custom_metrics <- metric_set(rmse, mae, mase)
```

---

### Cost-Sensitive Metric

```r
# Example: Custom cost matrix for classification
cost_sensitive_metric <- function(data, truth, estimate, cost_fp = 1, cost_fn = 10) {
  cm <- conf_mat(data, truth = {{ truth }}, estimate = {{ estimate }})
  fp <- cm$table[1, 2]
  fn <- cm$table[2, 1]
  total_cost <- cost_fp * fp + cost_fn * fn
  tibble(.metric = "cost", .estimator = "binary", .estimate = total_cost)
}
```

---

## Metric Combinations

### Typical Regression Combo

```r
regression_metrics <- metric_set(
  rmse,      # Primary (penalizes large errors)
  mae,       # Secondary (robust check)
  rsq,       # Variance explained
  mape       # Relative error (if no zeros)
)
```

---

### Typical Classification Combo (Balanced)

```r
balanced_classification <- metric_set(
  accuracy,   # Overall correctness
  roc_auc,    # Discrimination
  f_meas,     # Balance of precision/recall
  kap         # Agreement beyond chance
)
```

---

### Typical Classification Combo (Imbalanced)

```r
imbalanced_classification <- metric_set(
  pr_auc,     # Primary (handles imbalance)
  f_meas,     # F1-score
  sens,       # Catch positives
  spec,       # Avoid false alarms
  precision   # Precision of predictions
)
```

---

## Common Mistakes

**❌ Using only one metric**
**✅ Use 2-4 complementary metrics**

**❌ Using accuracy for imbalanced data**
**✅ Use PR-AUC or F1-score**

**❌ Using RMSE when outliers present**
**✅ Use MAE or Huber Loss**

**❌ Ignoring business context**
**✅ Choose metrics aligned with business goals**

**❌ Using MAPE with zeros in target**
**✅ Use sMAPE or different metric**

**❌ Comparing models with different metrics**
**✅ Use same metrics for all models**

---

## Business-Aligned Metrics

### Revenue-Based

For revenue prediction:
```r
# Revenue-weighted error
revenue_weighted_mae <- function(truth, estimate, revenue) {
  mean(abs(truth - estimate) * revenue) / mean(revenue)
}
```

---

### Threshold-Based

For classification with operating point:
```r
# Precision at fixed recall
precision_at_recall <- function(data, truth, prob, target_recall = 0.9) {
  # Find threshold that achieves target_recall
  # Calculate precision at that threshold
}
```

---

### Percentile-Based

For focusing on specific error ranges:
```r
# 95th percentile error (worst 5% of predictions)
p95_error <- function(truth, estimate) {
  errors <- abs(truth - estimate)
  quantile(errors, 0.95)
}
```

---

## Monitoring Metrics in Production

**Training metrics:** Track during model development
**Validation metrics:** Used for model selection (CV)
**Test metrics:** Final assessment before deployment
**Production metrics:** Monitor after deployment

**Production monitoring should include:**
1. Same metrics as test set
2. Data drift metrics (distribution shifts)
3. Prediction drift (prediction distribution)
4. Latency metrics (prediction speed)

```r
production_monitoring <- metric_set(
  rmse,           # Performance
  mae,            # Robust check
  mape,           # Relative error
  # Plus custom:
  # - prediction_latency
  # - data_drift_score
  # - prediction_drift_score
)
```

---

## Further Reading

- **Sklearn metrics documentation:** https://scikit-learn.org/stable/modules/model_evaluation.html
- **yardstick documentation:** https://yardstick.tidymodels.org/
- **"Evaluating Machine Learning Models" by Alice Zheng:** Comprehensive guide

---

**When in doubt:**
- **Regression:** Start with RMSE + MAE + R²
- **Classification (balanced):** ROC-AUC + Accuracy + F1
- **Classification (imbalanced):** PR-AUC + F1 + Sensitivity

Then add problem-specific metrics as needed.
