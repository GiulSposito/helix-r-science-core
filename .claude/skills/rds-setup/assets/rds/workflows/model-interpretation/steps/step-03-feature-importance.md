# Step 3: Feature Importance Analysis

## Step Overview

**Goal:** Synthesize robust feature importance measures from multiple methods

**Duration:** 2-4 hours

**Focus:** Which features REALLY matter? How stable are importance measures? Which features are redundant?

---

## What is Feature Importance Analysis?

This step combines insights from:
- **Global interpretation** (Step 1): VIP, permutation importance
- **Local interpretation** (Step 2): SHAP values aggregated
- **Additional methods**: Correlation analysis, conditional importance

The goal is a **robust, multi-method ranking** of feature importance that:
1. Is consistent across methods
2. Accounts for feature correlations
3. Identifies redundant features
4. Provides confidence in rankings
5. Informs feature selection and engineering

---

## Step 3 Tasks

### Task 3.1: Aggregate SHAP-Based Importance

Use mean absolute SHAP values as primary importance measure.

**Code Template:**

```r
library(shapviz)
library(tidyverse)

# Load SHAP values from Step 2
shap_viz <- readRDS("local_interpretation/shap_values.rds")

# Calculate mean absolute SHAP values (primary importance)
shap_importance <- sv_importance(shap_viz, kind = "both")

# Create visualization
shap_imp_plot <- shap_importance %>%
  slice_max(importance, n = 20) %>%
  ggplot(aes(x = reorder(feature, importance), y = importance)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(
    title = "SHAP-Based Feature Importance",
    subtitle = "Mean absolute SHAP value (averaged over all predictions)",
    x = NULL,
    y = "Mean |SHAP|"
  ) +
  theme_minimal()

# Save
ggsave("feature_importance/shap_importance.png", shap_imp_plot, width = 10, height = 8)

# Export values
shap_importance %>%
  write_csv("feature_importance/shap_importance.csv")
```

**Deliverables:**
- SHAP importance plot
- SHAP importance CSV

---

### Task 3.2: Permutation Importance (Repeated)

Calculate permutation importance with multiple repetitions for stability.

**Code Template:**

```r
library(DALEX)

# Create explainer (if not from Step 1)
explainer <- explain_tidymodels(
  model = workflow_fit,
  data = test_data %>% select(-outcome),
  y = test_data %>% pull(outcome),
  label = "Model"
)

# Calculate permutation importance with more repetitions
perm_importance <- model_parts(
  explainer,
  loss_function = loss_root_mean_square,  # or loss_one_minus_auc
  B = 50,  # increase for stability
  type = "difference"
)

# Extract and visualize
perm_imp_df <- as.data.frame(perm_importance)

perm_imp_plot <- perm_imp_df %>%
  filter(variable != "_baseline_", variable != "_full_model_") %>%
  group_by(variable) %>%
  summarise(
    mean_dropout_loss = mean(dropout_loss),
    sd_dropout_loss = sd(dropout_loss)
  ) %>%
  slice_max(mean_dropout_loss, n = 20) %>%
  ggplot(aes(x = reorder(variable, mean_dropout_loss), y = mean_dropout_loss)) +
  geom_col(fill = "coral") +
  geom_errorbar(
    aes(ymin = mean_dropout_loss - sd_dropout_loss,
        ymax = mean_dropout_loss + sd_dropout_loss),
    width = 0.2
  ) +
  coord_flip() +
  labs(
    title = "Permutation Feature Importance",
    subtitle = "Mean dropout loss (50 permutations) with standard deviation",
    x = NULL,
    y = "Dropout Loss"
  ) +
  theme_minimal()

ggsave("feature_importance/permutation_importance.png", perm_imp_plot, width = 10, height = 8)

# Export
perm_imp_df %>%
  write_csv("feature_importance/permutation_importance.csv")
```

**Deliverables:**
- Permutation importance with error bars
- Importance CSV with stability measures

**Key Questions:**
- Which features have high variance in importance?
- Are there features with unstable importance (high SD)?

---

### Task 3.3: Conditional Variable Importance

Calculate importance conditioned on correlated features.

**Code Template:**

```r
library(iml)

# Identify correlated feature groups
cor_matrix <- test_data %>%
  select(-outcome) %>%
  cor(use = "complete.obs")

# Find high correlations (|r| > 0.7)
high_cor <- which(abs(cor_matrix) > 0.7 & cor_matrix != 1, arr.ind = TRUE)
cor_pairs <- tibble(
  feature1 = rownames(cor_matrix)[high_cor[, 1]],
  feature2 = colnames(cor_matrix)[high_cor[, 2]],
  correlation = cor_matrix[high_cor]
) %>%
  filter(feature1 < feature2)  # remove duplicates

# For correlated pairs, calculate conditional importance
# (importance of feature1 given feature2 is in the model)

# Use iml package for conditional importance
predictor <- Predictor$new(
  model = workflow_fit,
  data = test_data %>% select(-outcome),
  y = test_data %>% pull(outcome)
)

# Conditional importance for key correlated features
conditional_imp <- map_dfr(unique(cor_pairs$feature1), function(feat) {
  correlated_with <- cor_pairs %>%
    filter(feature1 == feat | feature2 == feat) %>%
    pull(if_else(feature1 == feat, feature2, feature1))

  # Calculate importance conditional on correlated features
  imp <- FeatureImp$new(
    predictor,
    loss = "mse",
    features = feat,
    n.repetitions = 20
  )

  tibble(
    feature = feat,
    conditional_importance = imp$results$importance[1],
    correlated_with = paste(correlated_with, collapse = ", ")
  )
})

# Export
conditional_imp %>%
  write_csv("feature_importance/conditional_importance.csv")
```

**Deliverables:**
- Conditional importance for correlated features
- Identification of redundant features

**Key Insight:**
- If feature A has low conditional importance given feature B, then A may be redundant

---

### Task 3.4: Compare Importance Across Methods

Create unified ranking comparing all importance methods.

**Code Template:**

```r
# Combine all importance measures
unified_importance <- shap_importance %>%
  select(feature, shap_importance = importance) %>%
  left_join(
    perm_imp_df %>%
      group_by(variable) %>%
      summarise(perm_importance = mean(dropout_loss)) %>%
      rename(feature = variable),
    by = "feature"
  )

# Add model-specific importance (if available)
model_vip <- workflow_fit %>%
  extract_fit_parsnip() %>%
  vi() %>%
  rename(feature = Variable, model_importance = Importance)

unified_importance <- unified_importance %>%
  left_join(model_vip, by = "feature")

# Normalize to 0-100 scale
unified_importance <- unified_importance %>%
  mutate(
    across(ends_with("_importance"),
           ~100 * (. - min(., na.rm = TRUE)) / (max(., na.rm = TRUE) - min(., na.rm = TRUE)),
           .names = "{.col}_scaled")
  ) %>%
  mutate(
    mean_importance = rowMeans(
      select(., ends_with("_scaled")),
      na.rm = TRUE
    )
  ) %>%
  arrange(desc(mean_importance))

# Visualize comparison
importance_comparison <- unified_importance %>%
  slice_max(mean_importance, n = 20) %>%
  pivot_longer(
    cols = ends_with("_scaled"),
    names_to = "method",
    values_to = "importance"
  ) %>%
  mutate(method = str_remove(method, "_importance_scaled")) %>%
  ggplot(aes(x = reorder(feature, mean_importance), y = importance, fill = method)) +
  geom_col(position = "dodge") +
  coord_flip() +
  labs(
    title = "Feature Importance: Multi-Method Comparison",
    subtitle = "All methods normalized to 0-100 scale",
    x = NULL,
    y = "Importance Score",
    fill = "Method"
  ) +
  theme_minimal() +
  scale_fill_brewer(palette = "Set2")

ggsave("feature_importance/importance_comparison.png", importance_comparison, width = 12, height = 10)

# Export unified ranking
unified_importance %>%
  write_csv("feature_importance/unified_importance.csv")
```

**Deliverables:**
- Multi-method importance comparison plot
- Unified importance ranking CSV

**Key Questions:**
- Which features are important across ALL methods (robust)?
- Which features have inconsistent importance (method-dependent)?
- Are there features important in SHAP but not permutation (or vice versa)?

---

### Task 3.5: Feature Importance Stability Analysis

Assess how stable importance rankings are.

**Code Template:**

```r
# Bootstrap permutation importance
n_bootstrap <- 30

bootstrap_importance <- map_dfr(1:n_bootstrap, function(i) {
  # Sample test data with replacement
  boot_sample <- test_data %>%
    sample_n(nrow(.), replace = TRUE)

  # Create explainer
  explainer_boot <- explain_tidymodels(
    model = workflow_fit,
    data = boot_sample %>% select(-outcome),
    y = boot_sample %>% pull(outcome),
    label = "Model",
    verbose = FALSE
  )

  # Calculate importance
  imp <- model_parts(
    explainer_boot,
    loss_function = loss_root_mean_square,
    B = 10,
    type = "difference",
    verbose = FALSE
  )

  as.data.frame(imp) %>%
    filter(variable != "_baseline_", variable != "_full_model_") %>%
    group_by(variable) %>%
    summarise(dropout_loss = mean(dropout_loss)) %>%
    mutate(bootstrap_iter = i)
})

# Calculate stability metrics
stability_metrics <- bootstrap_importance %>%
  group_by(variable) %>%
  summarise(
    mean_importance = mean(dropout_loss),
    sd_importance = sd(dropout_loss),
    cv_importance = sd_importance / mean_importance,  # coefficient of variation
    rank_stability = sd(rank(dropout_loss))
  ) %>%
  arrange(desc(mean_importance))

# Visualize stability
stability_plot <- stability_metrics %>%
  slice_max(mean_importance, n = 20) %>%
  ggplot(aes(x = reorder(variable, mean_importance), y = mean_importance)) +
  geom_point(size = 3, color = "steelblue") +
  geom_errorbar(
    aes(ymin = mean_importance - sd_importance,
        ymax = mean_importance + sd_importance),
    width = 0.3
  ) +
  geom_point(aes(color = cv_importance), size = 2) +
  coord_flip() +
  labs(
    title = "Feature Importance Stability",
    subtitle = glue("{n_bootstrap} bootstrap iterations - colored by coefficient of variation"),
    x = NULL,
    y = "Mean Importance (with SD error bars)",
    color = "CV"
  ) +
  scale_color_gradient(low = "green", high = "red") +
  theme_minimal()

ggsave("feature_importance/importance_stability.png", stability_plot, width = 10, height = 8)

# Export
stability_metrics %>%
  write_csv("feature_importance/importance_stability.csv")
```

**Deliverables:**
- Stability plot with error bars
- CV (coefficient of variation) for each feature
- Rank stability measures

**Key Questions:**
- Which features have stable importance (low CV)?
- Which features have unstable importance (high CV)?
- Are unstable features worth including?

---

### Task 3.6: Identify Redundant Features

Find features that can be dropped without losing information.

**Code Template:**

```r
# Method 1: Correlation-based redundancy
redundancy_analysis <- unified_importance %>%
  slice_max(mean_importance, n = 30) %>%  # top 30 features
  pull(feature)

# Calculate correlation among top features
top_features_cor <- test_data %>%
  select(all_of(redundancy_analysis)) %>%
  cor(use = "complete.obs")

# Find highly correlated pairs
redundant_pairs <- which(abs(top_features_cor) > 0.85 & top_features_cor != 1, arr.ind = TRUE) %>%
  as.data.frame() %>%
  filter(row < col) %>%
  mutate(
    feature1 = rownames(top_features_cor)[row],
    feature2 = colnames(top_features_cor)[col],
    correlation = top_features_cor[cbind(row, col)]
  ) %>%
  select(feature1, feature2, correlation)

# For each redundant pair, recommend which to keep (higher importance)
redundant_pairs <- redundant_pairs %>%
  left_join(
    unified_importance %>% select(feature, importance1 = mean_importance),
    by = c("feature1" = "feature")
  ) %>%
  left_join(
    unified_importance %>% select(feature, importance2 = mean_importance),
    by = c("feature2" = "feature")
  ) %>%
  mutate(
    recommendation = if_else(importance1 >= importance2,
                             glue("Keep {feature1}, consider dropping {feature2}"),
                             glue("Keep {feature2}, consider dropping {feature1}"))
  )

# Export
redundant_pairs %>%
  write_csv("feature_importance/redundant_features.csv")

# Visualize correlation heatmap
library(corrplot)

png("feature_importance/correlation_heatmap.png", width = 1000, height = 1000)
corrplot(
  top_features_cor,
  method = "color",
  type = "upper",
  order = "hclust",
  tl.cex = 0.8,
  tl.col = "black",
  title = "Top 30 Features - Correlation Heatmap"
)
dev.off()
```

**Deliverables:**
- List of redundant feature pairs
- Recommendations for which features to keep/drop
- Correlation heatmap

**Key Questions:**
- Can we simplify the model by dropping correlated features?
- Would dropping redundant features improve interpretability without hurting performance?

---

### Task 3.7: Feature Importance Report

Create comprehensive summary of all importance analyses.

**Template:**

```markdown
# Feature Importance Analysis Report

## Executive Summary

- **Total features analyzed:** {n_features}
- **Top 10 features account for:** {pct}% of total importance
- **Highly stable features:** {n_stable} (CV < 0.2)
- **Redundant features identified:** {n_redundant}

## Top 20 Features (Robust Ranking)

| Rank | Feature | SHAP | Permutation | Model-Specific | Mean | Stability (CV) | Recommendation |
|------|---------|------|-------------|----------------|------|----------------|----------------|
| 1 | feature1 | 95 | 92 | 98 | 95.0 | 0.08 | Keep (highly stable) |
| 2 | feature2 | 88 | 85 | 90 | 87.7 | 0.12 | Keep (stable) |
| ... | ... | ... | ... | ... | ... | ... | ... |

## Feature Categories

### Tier 1: Critical Features (Mean Importance > 80)
- **feature1**: [description and business meaning]
- **feature2**: [description and business meaning]

### Tier 2: Important Features (Mean Importance 50-80)
- **feature3**: [description]
- ...

### Tier 3: Moderate Features (Mean Importance 20-50)
- **feature10**: [description]
- ...

### Tier 4: Low Importance (Mean Importance < 20)
- Consider dropping: [list]

## Redundancy Analysis

### Highly Correlated Feature Pairs (|r| > 0.85)

1. **feature1 ↔ feature2** (r = 0.92)
   - Recommendation: Keep feature1 (higher importance)
   - Rationale: [business/statistical reason]

2. **feature3 ↔ feature4** (r = 0.88)
   - Recommendation: Keep both (measure different aspects despite correlation)
   - Rationale: [reason]

## Stability Findings

### Most Stable Features
- feature1 (CV = 0.05)
- feature2 (CV = 0.08)

### Unstable Features (CV > 0.3)
- feature20 (CV = 0.45) — Investigate data quality
- feature25 (CV = 0.38) — May be sensitive to sample

## Method Agreement

### High Agreement (all methods rank in top 20)
- feature1, feature2, feature3, ...

### Disagreement (high in one method, low in others)
- **feature15**: High SHAP, low permutation
  - Explanation: [why this might occur]

## Recommendations

### For Model Simplification
1. Drop these features without major performance loss: [list]
2. Combine these correlated features: [suggestions]

### For Feature Engineering
1. Investigate interaction between: [feature pairs]
2. Consider transforming: [features with non-linear effects]

### For Data Collection
1. Focus on maintaining quality of: [top 5 critical features]
2. Consider dropping collection of: [very low importance features]

## Next Steps

- Validate recommendations by retraining model without redundant features
- Communicate top features to stakeholders (Step 4)
- Use insights for next iteration of feature engineering
```

---

## Step 3 Outputs

**Create this folder structure:**
```
feature_importance/
├── shap_importance.png
├── shap_importance.csv
├── permutation_importance.png
├── permutation_importance.csv
├── conditional_importance.csv
├── importance_comparison.png
├── unified_importance.csv
├── importance_stability.png
├── importance_stability.csv
├── redundant_features.csv
├── correlation_heatmap.png
└── feature_importance_report.md
```

---

## Step 3 Checklist

- [ ] SHAP-based importance calculated and visualized
- [ ] Permutation importance with stability measures
- [ ] Conditional importance for correlated features
- [ ] Multi-method importance comparison created
- [ ] Stability analysis via bootstrapping completed
- [ ] Redundant features identified with recommendations
- [ ] Correlation heatmap generated
- [ ] Comprehensive feature importance report written
- [ ] Tier classification (critical/important/moderate/low) defined
- [ ] Recommendations for model simplification documented

---

## Troubleshooting

**Problem:** Different methods give very different rankings

**Solution:**
- SHAP and permutation usually agree for important features
- Disagreement may indicate:
  - Correlated features (SHAP handles better)
  - Non-linear effects (SHAP captures better)
  - Small sample sensitivity (permutation more affected)
- Use SHAP as primary, permutation as validation

---

**Problem:** Many features have unstable importance

**Solution:**
- Increase bootstrap iterations
- Check for data quality issues
- Consider if sample size is too small
- May need more robust feature selection

---

**Problem:** Too many redundant features

**Solution:**
- Good problem to have! Model is over-specified
- Use recommendations to simplify
- Retrain and check performance doesn't degrade
- Keep business context in mind (some redundancy okay for robustness)

---

## Next Step

Once feature importance analysis is complete:

**Proceed to Step 4: Documentation & Communication**

Load: `exec="{installed_path}/steps/step-04-documentation.md"`

You now have robust feature importance rankings and insights. Step 4 will synthesize everything into stakeholder-ready reports.

---

_Step 3 of 4 — Model Interpretation Workflow_
_Owner: Alan | RDS Module_
