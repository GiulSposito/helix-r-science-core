# Step 2: Local Interpretation

## Step Overview

**Goal:** Explain individual predictions using local interpretation methods

**Duration:** 3-6 hours

**Focus:** Why did the model make THIS specific prediction? Which features contributed most to THIS decision?

---

## What is Local Interpretation?

Local interpretation methods explain **individual predictions**, not overall model behavior. They answer questions like:

- Why did the model predict this specific outcome for this customer?
- Which features pushed this prediction higher or lower?
- How would the prediction change if we modified one feature for this case?
- Can we trust this specific prediction?

**Key Methods:**
- **SHAP (SHapley Additive exPlanations)**: Game theory-based feature contributions
- **LIME (Local Interpretable Model-agnostic Explanations)**: Local linear approximations
- **Break Down**: Sequential feature contribution decomposition
- **Ceteris Paribus**: What-if analysis for individual observations

---

## Step 2 Tasks

### Task 2.1: SHAP Values for Individual Predictions

Calculate SHAP values to decompose predictions into feature contributions.

**Code Template (tidymodels-agnostic via treeshap/fastshap):**

```r
library(DALEX)
library(shapviz)

# Prepare data
X_test <- test_data %>% select(-outcome)
y_test <- test_data %>% pull(outcome)

# For tree-based models (xgboost, random forest, lightgbm)
library(treeshap)

# Extract underlying model
model_fit <- workflow_fit %>% extract_fit_parsnip()
underlying_model <- model_fit$fit

# Calculate SHAP (fast for tree models)
shap_values <- treeshap(
  unified_model = underlying_model,
  x = X_test,
  verbose = FALSE
)

# Convert to shapviz object for easy plotting
shap_viz <- shapviz(shap_values, X = X_test)
```

**For non-tree models (use kernelshap):**

```r
library(kernelshap)

# Create prediction function
predict_function <- function(model, newdata) {
  predict(model, newdata, type = "numeric") %>% pull(.pred)
}

# Calculate SHAP (slower but model-agnostic)
shap_values <- kernelshap(
  object = workflow_fit,
  X = X_test,
  bg_X = X_test[sample(1:nrow(X_test), 100), ],  # background sample
  pred_fun = predict_function
)

shap_viz <- shapviz(shap_values, X = X_test)
```

**Deliverables:**
- SHAP values calculated for test set
- `shap_values.rds` saved for later analysis

---

### Task 2.2: SHAP Waterfall Plots (Individual Cases)

Visualize how features contribute to specific predictions.

**Code Template:**

```r
# Select interesting cases to explain
cases_to_explain <- c(
  which.max(predict(workflow_fit, test_data)$.pred),  # highest prediction
  which.min(predict(workflow_fit, test_data)$.pred),  # lowest prediction
  sample(1:nrow(test_data), 3)  # 3 random cases
)

# Create waterfall plots
waterfall_plots <- map(cases_to_explain, function(case_idx) {
  sv_waterfall(shap_viz, row_id = case_idx, max_display = 10) +
    labs(
      title = glue("SHAP Waterfall: Case {case_idx}"),
      subtitle = glue("Predicted: {round(predict(workflow_fit, test_data[case_idx,])$.pred, 3)},
                      Actual: {round(y_test[case_idx], 3)}")
    ) +
    theme_minimal()
})

# Combine
waterfall_grid <- wrap_plots(waterfall_plots, ncol = 2)

ggsave("local_interpretation/shap_waterfalls.png", waterfall_grid, width = 14, height = 10)
```

**Deliverables:**
- Waterfall plots for 5-10 selected cases
- Interpretation notes for each case

**Key Questions:**
- Which features drive each prediction?
- Are contributions positive or negative?
- Do explanations match intuition?

---

### Task 2.3: SHAP Force Plots

Show feature contributions as forces pushing prediction from baseline.

**Code Template:**

```r
# Create force plots for selected cases
force_plots <- map(cases_to_explain[1:3], function(case_idx) {
  sv_force(shap_viz, row_id = case_idx) +
    labs(
      title = glue("SHAP Force Plot: Case {case_idx}"),
      subtitle = "Red = increases prediction, Blue = decreases prediction"
    )
})

force_grid <- wrap_plots(force_plots, ncol = 1)
```

**Deliverables:**
- Force plots for 3-5 key cases
- Comparison of force plot vs waterfall plot insights

---

### Task 2.4: SHAP Dependence Plots (Local Patterns)

Show how SHAP values for a feature vary with the feature value.

**Code Template:**

```r
# Get top features from global importance
top_features <- c("feature1", "feature2", "feature3", "feature4")

# Create dependence plots
dependence_plots <- map(top_features, function(var) {
  sv_dependence(shap_viz, v = var, color_var = "auto") +
    labs(
      title = glue("SHAP Dependence: {var}"),
      subtitle = "How SHAP values change with feature value"
    ) +
    theme_minimal()
})

dependence_grid <- wrap_plots(dependence_plots, ncol = 2)

ggsave("local_interpretation/shap_dependence.png", dependence_grid, width = 12, height = 8)
```

**Deliverables:**
- Dependence plots for top 4-6 features
- Identification of interactions (color patterns)

**Key Questions:**
- Are SHAP values consistent across feature range?
- Do interactions affect SHAP values?
- Are there outlier cases with extreme SHAP values?

---

### Task 2.5: LIME Explanations (Alternative Method)

Use LIME for model-agnostic local explanations.

**Code Template:**

```r
library(lime)

# Create LIME explainer
explainer_lime <- lime(
  x = train_data %>% select(-outcome),
  model = workflow_fit,
  bin_continuous = TRUE,
  n_bins = 5
)

# Explain specific cases
cases_df <- test_data[cases_to_explain[1:5], ]

explanations <- explain(
  x = cases_df %>% select(-outcome),
  explainer = explainer_lime,
  n_features = 10,
  n_labels = 1,
  n_permutations = 5000
)

# Plot explanations
lime_plots <- plot_features(explanations, ncol = 2) +
  labs(title = "LIME Explanations for Selected Cases") +
  theme_minimal()

ggsave("local_interpretation/lime_explanations.png", lime_plots, width = 12, height = 10)
```

**Deliverables:**
- LIME explanations for 5 cases
- Comparison of LIME vs SHAP explanations

**When to use LIME:**
- SHAP is too computationally expensive
- Need rule-based explanations
- Working with text or image data

---

### Task 2.6: Break Down Plots (DALEX)

Show sequential feature contribution decomposition.

**Code Template:**

```r
library(DALEX)

# Create DALEX explainer (if not already created in Step 1)
explainer <- explain_tidymodels(
  model = workflow_fit,
  data = test_data %>% select(-outcome),
  y = y_test,
  label = "Model"
)

# Break down for specific cases
breakdown_plots <- map(cases_to_explain[1:3], function(case_idx) {
  bd <- predict_parts(
    explainer,
    new_observation = test_data[case_idx, ] %>% select(-outcome),
    type = "break_down"
  )

  plot(bd) +
    labs(
      title = glue("Break Down: Case {case_idx}"),
      subtitle = glue("Shows sequential contribution of each feature")
    ) +
    theme_minimal()
})

breakdown_grid <- wrap_plots(breakdown_plots, ncol = 1)
```

**Deliverables:**
- Break down plots for 3-5 cases
- Notes on feature ordering importance

---

### Task 2.7: Ceteris Paribus Profiles (What-If Analysis)

Explore how prediction changes when varying one feature.

**Code Template:**

```r
# Select a case and feature to vary
case_idx <- cases_to_explain[1]
features_to_vary <- c("feature1", "feature2", "feature3")

# Create ceteris paribus profiles
cp_plots <- map(features_to_vary, function(var) {
  cp <- predict_profile(
    explainer,
    new_observation = test_data[case_idx, ] %>% select(-outcome),
    variables = var
  )

  plot(cp) +
    labs(
      title = glue("Ceteris Paribus: {var}"),
      subtitle = glue("What-if analysis for Case {case_idx}")
    ) +
    theme_minimal()
})

cp_grid <- wrap_plots(cp_plots, ncol = 3)
```

**Deliverables:**
- Ceteris paribus profiles for top 3 features
- What-if scenarios and interpretation

**Use Cases:**
- "What would happen if we increased this customer's income?"
- "How much would the risk score drop if credit utilization decreased?"

---

### Task 2.8: Create Case Study Deep Dives

Document detailed interpretations for interesting cases.

**Template:**

```markdown
# Case Study: Case {case_idx}

## Prediction Summary

- **Predicted Value:** {pred_value}
- **Actual Value:** {actual_value}
- **Prediction Error:** {error}
- **Confidence/Uncertainty:** {if available}

## Feature Values

| Feature | Value | Percentile | Notes |
|---------|-------|------------|-------|
| feature1 | 120.5 | 85th | High value |
| feature2 | 0.3 | 25th | Low value |
| ... | ... | ... | ... |

## SHAP Explanation

**Top 5 Contributing Features:**

1. **feature1 (+0.45)**: High value drives prediction up
2. **feature2 (-0.22)**: Low value reduces prediction
3. **feature3 (+0.18)**: ...
4. **feature4 (-0.12)**: ...
5. **feature5 (+0.08)**: ...

## Business Interpretation

[Plain language explanation of why this prediction was made]

## Recommendations

- If prediction seems wrong: [investigate these features]
- If prediction is correct: [what does this teach us?]
- Action items: [what should be done with this case?]
```

**Deliverables:**
- 3-5 detailed case study documents
- Patterns across multiple cases

---

## Step 2 Outputs

**Create this folder structure:**
```
local_interpretation/
├── shap_values.rds
├── shap_waterfalls.png
├── shap_force_plots.png
├── shap_dependence.png
├── lime_explanations.png
├── breakdown_plots.png
├── ceteris_paribus.png
├── case_studies/
│   ├── case_001.md
│   ├── case_002.md
│   └── case_003.md
└── local_interpretation_summary.md
```

**Summary Document Template:**

```markdown
# Local Interpretation Summary

## Cases Explained

Total cases analyzed: {n_cases}

### High-Confidence Predictions
- Cases where model explanation is clear and consistent
- [List cases]

### Low-Confidence or Surprising Predictions
- Cases where explanation reveals potential issues
- [List cases]

## Common Explanation Patterns

### Pattern 1: [Name]
- Features involved: [list]
- Frequency: [how often seen]
- Interpretation: [what it means]

### Pattern 2: [Name]
...

## Method Comparison

### SHAP vs LIME Agreement
- Cases where methods agree: {n}
- Cases where methods disagree: {n}
- Explanation for disagreements: [analysis]

## Insights for Model Improvement

1. [Feature that often contributes unexpectedly]
2. [Cases where model struggles]
3. [Potential data quality issues discovered]

## Recommendations

- [Actionable insights from local interpretation]
```

---

## Step 2 Checklist

- [ ] SHAP values calculated for test set
- [ ] Waterfall plots created for 5-10 key cases
- [ ] Force plots generated for visualization variety
- [ ] Dependence plots reveal local patterns and interactions
- [ ] LIME explanations as alternative verification
- [ ] Break down plots show sequential contributions
- [ ] Ceteris paribus what-if scenarios explored
- [ ] 3-5 detailed case studies documented
- [ ] Local interpretation summary written
- [ ] Comparison of SHAP/LIME agreement documented

---

## Troubleshooting

**Problem:** SHAP computation too slow

**Solution:**
- Use `treeshap` for tree-based models (much faster)
- Reduce background sample size for `kernelshap`
- Calculate SHAP for subset of test cases only

---

**Problem:** SHAP and LIME give different explanations

**Solution:**
- SHAP is theoretically more rigorous (use as primary)
- LIME is an approximation (good for intuition checks)
- Disagreement may indicate model complexity or instability
- Document both and note differences

---

**Problem:** Explanations don't match domain knowledge

**Solution:**
- Investigate data quality for surprising features
- Check for confounding or correlated features
- Validate with domain experts
- May reveal genuine insights OR data issues

---

## Next Step

Once local interpretation is complete:

**Proceed to Step 3: Feature Importance Analysis**

Load: `exec="{installed_path}/steps/step-03-feature-importance.md"`

You now understand both global and local model behavior. Step 3 will provide robust importance measures combining multiple methods.

---

_Step 2 of 4 — Model Interpretation Workflow_
_Owner: Alan | RDS Module_
