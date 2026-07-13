# Step 1: Global Interpretation

## Step Overview

**Goal:** Understand overall model behavior through global interpretation methods

**Duration:** 3-6 hours

**Focus:** How does the model behave across the entire dataset? Which features matter most? What are the general patterns?

---

## What is Global Interpretation?

Global interpretation methods explain **overall model behavior** across all predictions, not individual predictions. They answer questions like:

- Which features are most important overall?
- How does changing feature X affect predictions on average?
- Are there non-linear relationships the model captured?
- How do features interact with each other?

**Key Methods:**
- **Variable Importance (VIP)**: Ranks features by overall contribution
- **Partial Dependence Plots (PDP)**: Shows average effect of a feature
- **Individual Conditional Expectation (ICE)**: Shows per-observation feature effects
- **Accumulated Local Effects (ALE)**: Handles correlated features better than PDP

---

## Step 1 Tasks

### Task 1.1: Variable Importance Analysis

Generate overall feature importance rankings.

**Code Template:**

```r
library(vip)
library(tidymodels)

# For tidymodels workflow
workflow_fit <- final_workflow %>% fit(train_data)

# Method 1: Model-specific importance (fast, if available)
vip_plot <- workflow_fit %>%
  extract_fit_parsnip() %>%
  vip(num_features = 20, aesthetics = list(fill = "steelblue")) +
  labs(
    title = "Top 20 Most Important Features",
    subtitle = "Model-specific variable importance"
  )

# Method 2: Permutation importance (model-agnostic, more robust)
library(DALEX)

# Create explainer
explainer <- explain_tidymodels(
  model = workflow_fit,
  data = test_data %>% select(-outcome),
  y = test_data %>% pull(outcome),
  label = "Model"
)

# Calculate permutation importance
perm_importance <- model_parts(
  explainer,
  loss_function = loss_root_mean_square,  # or loss_one_minus_auc for classification
  B = 10,  # number of permutations
  type = "difference"
)

plot(perm_importance, max_vars = 20) +
  labs(title = "Permutation-based Variable Importance")
```

**Deliverables:**
- VIP plot (top 20 features)
- Permutation importance plot
- Importance values saved to CSV

**Key Questions:**
- Do the top features make business sense?
- Are there unexpected important features?
- How stable is importance across methods?

---

### Task 1.2: Partial Dependence Plots

Show how predictions change as each important feature varies.

**Code Template:**

```r
library(DALEX)
library(patchwork)

# Get top 6 features from VIP
top_features <- c("feature1", "feature2", "feature3", "feature4", "feature5", "feature6")

# Create PDP for each feature
pdp_list <- map(top_features, function(var) {
  pdp <- model_profile(
    explainer,
    variables = var,
    N = NULL,  # use all observations
    type = "partial"
  )

  plot(pdp) +
    labs(
      title = glue("PDP: {var}"),
      y = "Predicted Value"
    ) +
    theme_minimal()
})

# Combine into grid
pdp_grid <- wrap_plots(pdp_list, ncol = 2)

# Save
ggsave("global_interpretation/pdp_grid.png", pdp_grid, width = 12, height = 10)
```

**Deliverables:**
- PDP for top 6-8 features
- Combined PDP grid visualization
- Interpretation notes for each PDP

**Key Questions:**
- Are relationships linear or non-linear?
- Where are the inflection points?
- Do PDPs match domain knowledge?

---

### Task 1.3: ICE Curves with PDP Overlay

Show individual variation around average PDP trends.

**Code Template:**

```r
# Create ICE curves (shows individual prediction paths)
ice_plots <- map(top_features[1:4], function(var) {
  ice <- model_profile(
    explainer,
    variables = var,
    N = 100,  # sample 100 observations for clarity
    type = "conditional"
  )

  pdp <- model_profile(
    explainer,
    variables = var,
    N = NULL,
    type = "partial"
  )

  # Plot ICE + PDP overlay
  plot(ice, geom = "profiles") +
    geom_line(
      data = pdp$agr_profiles,
      aes(x = `_x_`, y = `_yhat_`),
      color = "red",
      size = 2
    ) +
    labs(
      title = glue("ICE Curves: {var}"),
      subtitle = "Red line = Average (PDP), Gray lines = Individual observations",
      y = "Predicted Value"
    ) +
    theme_minimal()
})

# Combine
ice_grid <- wrap_plots(ice_plots, ncol = 2)
```

**Deliverables:**
- ICE plots for top 4 features
- Comparison of PDP vs ICE patterns

**Key Questions:**
- Is there high heterogeneity (spread in ICE curves)?
- Are some observations behaving very differently?
- Does the average PDP hide important variation?

---

### Task 1.4: Two-Way Interactions (Optional but Recommended)

Explore how pairs of features interact.

**Code Template:**

```r
# Identify potential interactions from domain knowledge or correlation
interaction_pairs <- list(
  c("feature1", "feature2"),
  c("feature3", "feature4")
)

# Create 2D partial dependence plots
interaction_plots <- map(interaction_pairs, function(pair) {
  pdp_2d <- model_profile(
    explainer,
    variables = pair,
    N = 50,  # grid resolution
    type = "partial"
  )

  plot(pdp_2d, geom = "contours") +
    labs(
      title = glue("Interaction: {pair[1]} × {pair[2]}"),
      subtitle = "2D Partial Dependence"
    ) +
    theme_minimal()
})
```

**Deliverables:**
- 2D PDP contour plots for key interactions
- Interaction interpretation notes

**Key Questions:**
- Do features interact (non-parallel contours)?
- Are there synergistic or antagonistic effects?
- Do interactions match expectations?

---

### Task 1.5: Accumulated Local Effects (ALE) Plots

Use ALE for correlated features (more reliable than PDP).

**Code Template:**

```r
library(iml)

# Create iml predictor object
predictor <- Predictor$new(
  model = workflow_fit,
  data = test_data %>% select(-outcome),
  y = test_data %>% pull(outcome),
  type = "response"
)

# Calculate ALE for correlated features
ale_plots <- map(top_features[1:4], function(var) {
  ale <- FeatureEffect$new(
    predictor,
    feature = var,
    method = "ale"
  )

  ale$plot() +
    labs(
      title = glue("ALE Plot: {var}"),
      subtitle = "Accumulated Local Effects (robust to correlation)"
    ) +
    theme_minimal()
})

ale_grid <- wrap_plots(ale_plots, ncol = 2)
```

**Deliverables:**
- ALE plots for top features
- Comparison of ALE vs PDP (if different)

**When to use ALE:**
- Features are correlated (r > 0.7)
- PDP shows unexpected patterns
- Need unbiased feature effects

---

## Step 1 Outputs

**Create this folder structure:**
```
global_interpretation/
├── vip_plot.png
├── permutation_importance.png
├── importance_values.csv
├── pdp_grid.png
├── ice_grid.png
├── interaction_plots.png
├── ale_grid.png
└── global_interpretation_summary.md
```

**Summary Document Template:**

```markdown
# Global Interpretation Summary

## Top 10 Features

| Rank | Feature | Importance | Business Interpretation |
|------|---------|------------|------------------------|
| 1 | feature1 | 0.85 | Strongest driver of predictions |
| 2 | feature2 | 0.72 | Second most important |
| ... | ... | ... | ... |

## Key Patterns

### Feature 1: [Name]
- **Relationship:** [Linear/Non-linear/Threshold]
- **Direction:** [Positive/Negative/Complex]
- **Interpretation:** [What it means]

### Feature 2: [Name]
...

## Important Interactions

- **feature1 × feature2:** [Describe interaction]
- **feature3 × feature4:** [Describe interaction]

## Unexpected Findings

1. [Surprising pattern 1]
2. [Surprising pattern 2]

## Recommendations for Local Interpretation

Based on global patterns, focus local interpretation on:
- Cases where feature1 is extreme
- Interactions between feature2 and feature3
- [Other focus areas]
```

---

## Step 1 Checklist

- [ ] Variable importance calculated (model-specific + permutation)
- [ ] Top features identified and validated for business sense
- [ ] PDPs created for top 6-8 features
- [ ] ICE curves generated to assess heterogeneity
- [ ] Key interactions explored (if relevant)
- [ ] ALE plots for correlated features
- [ ] Global interpretation summary document written
- [ ] Plots saved to `global_interpretation/` folder
- [ ] Identified focus areas for local interpretation (Step 2)

---

## Troubleshooting

**Problem:** VIP shows unexpected features as important

**Solution:**
- Check for data leakage (features that shouldn't be available at prediction time)
- Verify permutation importance for confirmation
- Review feature engineering steps

---

**Problem:** PDPs show counterintuitive relationships

**Solution:**
- Check for correlated features (use ALE instead)
- Verify data quality for that feature
- Consider interactions masking the relationship

---

**Problem:** High computation time for ICE/ALE

**Solution:**
- Sample observations (N = 100 for ICE)
- Use grid_size parameter to control resolution
- Focus on top 4-6 features only

---

## Next Step

Once global interpretation is complete:

**Proceed to Step 2: Local Interpretation**

Load: `exec="{installed_path}/steps/step-02-local-interpretation.md"`

You now understand overall model behavior. Step 2 will explain individual predictions using SHAP and LIME.

---

_Step 1 of 4 — Model Interpretation Workflow_
_Owner: Alan | RDS Module_
