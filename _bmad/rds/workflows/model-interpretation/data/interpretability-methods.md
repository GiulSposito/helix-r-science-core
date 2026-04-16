# Interpretability Methods Reference Guide

## Overview

This guide provides a comprehensive reference for model interpretation methods used in the RDS model-interpretation workflow. Use this to select appropriate methods based on your model type, business requirements, and computational constraints.

---

## Method Selection Matrix

| Method | Type | Model-Agnostic | Speed | Best For | Limitations |
|--------|------|----------------|-------|----------|-------------|
| **VIP** | Global | Mostly | Fast | Quick importance ranking | Model-specific definitions |
| **Permutation Importance** | Global | Yes | Medium | Robust importance | Computationally expensive |
| **Partial Dependence** | Global | Yes | Medium | Average feature effects | Assumes independence |
| **ALE** | Global | Yes | Medium | Correlated features | Complex interpretation |
| **ICE** | Global | Yes | Slow | Heterogeneity detection | Hard to visualize many curves |
| **SHAP** | Local/Global | Yes | Slow-Medium | Individual predictions | Computationally expensive |
| **LIME** | Local | Yes | Fast | Quick local explanations | Less theoretically sound |
| **Break Down** | Local | Yes | Fast | Sequential contributions | Order-dependent |
| **Ceteris Paribus** | Local | Yes | Medium | What-if scenarios | One feature at a time |

---

## Global Interpretation Methods

### 1. Variable Importance Plots (VIP)

**What it does:** Ranks features by overall contribution to model predictions

**Packages:** `vip`, `tidymodels`

**When to use:**
- First step in any interpretation workflow
- Quick overview of feature relevance
- Communicating to non-technical audiences

**How it works:**
- **Tree models**: Uses split gain/Gini importance
- **Linear models**: Absolute coefficient values
- **Neural nets**: Weight-based importance
- **Model-agnostic**: Permutation importance

**Code Example:**
```r
library(vip)

workflow_fit %>%
  extract_fit_parsnip() %>%
  vip(num_features = 20)
```

**Pros:**
- Fast to compute
- Easy to interpret
- Good starting point

**Cons:**
- Model-specific (different definitions)
- Biased for correlated features
- Doesn't show direction of effect

**Interpretation Tips:**
- Use as initial screening tool
- Validate with permutation importance
- Don't rely solely on VIP for decisions

---

### 2. Permutation Importance

**What it does:** Measures feature importance by randomly shuffling each feature and measuring performance drop

**Packages:** `DALEX`, `vip`

**When to use:**
- Need model-agnostic importance
- Want to validate VIP results
- Regulatory requirements for explainability

**How it works:**
1. Calculate baseline model performance
2. For each feature:
   - Randomly permute that feature
   - Recalculate performance
   - Importance = performance drop
3. Repeat multiple times for stability

**Code Example:**
```r
library(DALEX)

explainer <- explain_tidymodels(
  model = workflow_fit,
  data = test_data %>% select(-outcome),
  y = test_data %>% pull(outcome)
)

perm_importance <- model_parts(
  explainer,
  loss_function = loss_root_mean_square,
  B = 50,  # number of permutations
  type = "difference"
)

plot(perm_importance)
```

**Pros:**
- Theoretically sound
- Model-agnostic
- Accounts for feature interactions

**Cons:**
- Computationally expensive (requires retraining/prediction many times)
- Sensitive to feature correlation
- Can be unstable with small samples

**Interpretation Tips:**
- Run multiple permutations (B=50+) for stability
- Use error bars to show uncertainty
- Compare with SHAP importance for validation

---

### 3. Partial Dependence Plots (PDP)

**What it does:** Shows average marginal effect of a feature on predictions

**Packages:** `DALEX`, `pdp`, `iml`

**When to use:**
- Understand feature-prediction relationship
- Check for non-linearity
- Validate domain knowledge

**How it works:**
1. Select a feature
2. Create grid of values for that feature
3. For each grid point:
   - Set feature to that value for all observations
   - Calculate average prediction
4. Plot average prediction vs feature value

**Code Example:**
```r
library(DALEX)

pdp <- model_profile(
  explainer,
  variables = "feature_name",
  type = "partial"
)

plot(pdp)
```

**Pros:**
- Easy to interpret
- Shows non-linear relationships
- Can do 2D PDPs for interactions

**Cons:**
- Assumes feature independence (unrealistic)
- Marginalizes over potentially impossible combinations
- Can be misleading with correlated features

**Interpretation Tips:**
- Use ALE instead if features are correlated
- Look for inflection points (thresholds)
- Compare with domain expectations
- Use 2D PDPs for important interactions

---

### 4. Accumulated Local Effects (ALE)

**What it does:** Shows feature effects while accounting for feature correlation

**Packages:** `iml`, `ALEPlot`

**When to use:**
- Features are highly correlated (r > 0.7)
- PDP gives unexpected results
- Need unbiased feature effects

**How it works:**
1. Divides feature range into intervals
2. For each interval, calculates local effect by:
   - Moving observations slightly within interval
   - Measuring prediction change
3. Accumulates local effects across intervals

**Code Example:**
```r
library(iml)

predictor <- Predictor$new(
  model = workflow_fit,
  data = test_data %>% select(-outcome),
  y = test_data %>% pull(outcome)
)

ale <- FeatureEffect$new(
  predictor,
  feature = "feature_name",
  method = "ale"
)

ale$plot()
```

**Pros:**
- Handles correlated features better than PDP
- Unbiased feature effects
- Computationally efficient

**Cons:**
- More complex to interpret than PDP
- Less intuitive for non-technical audiences
- Centered at zero (relative effects only)

**Interpretation Tips:**
- Use when correlation is high
- Compare with PDP to see if correlation affects interpretation
- Focus on shape/trend rather than absolute values

---

### 5. Individual Conditional Expectation (ICE)

**What it does:** Shows how predictions change for individual observations as a feature varies

**Packages:** `DALEX`, `iml`, `ICEbox`

**When to use:**
- Assess heterogeneity in feature effects
- Check if average PDP hides variation
- Detect subpopulations with different behavior

**How it works:**
1. Select a feature and observation
2. Vary feature across its range while keeping other features fixed
3. Plot prediction vs feature value
4. Repeat for many observations (creates many curves)
5. Overlay PDP as average

**Code Example:**
```r
library(DALEX)

ice <- model_profile(
  explainer,
  variables = "feature_name",
  N = 100,  # sample 100 observations
  type = "conditional"
)

plot(ice, geom = "profiles")
```

**Pros:**
- Reveals heterogeneity hidden by PDP
- Shows individual prediction paths
- Detects subgroups with different behavior

**Cons:**
- Visually cluttered with many curves
- Hard to extract specific insights
- Computationally expensive for large datasets

**Interpretation Tips:**
- Sample observations (N=100) for clarity
- Look for "fanning" (heterogeneous effects)
- Compare ICE spread to PDP line
- Use clustering to identify subgroups

---

## Local Interpretation Methods

### 6. SHAP (SHapley Additive exPlanations)

**What it does:** Decomposes each prediction into feature contributions based on game theory

**Packages:** `shapviz`, `treeshap`, `kernelshap`, `SHAPforxgboost`

**When to use:**
- Need to explain individual predictions
- Regulatory requirements
- High-stakes decisions (medical, financial)
- Want theoretically rigorous explanations

**How it works:**
1. Based on Shapley values from cooperative game theory
2. For each feature, calculates average contribution across all possible feature coalitions
3. SHAP value = how much feature contributed to moving prediction from baseline

**Mathematical properties:**
- **Additivity**: SHAP values sum to (prediction - baseline)
- **Consistency**: If model changes to rely more on feature, SHAP increases
- **Local accuracy**: Faithful to model locally

**Code Example (Tree models - fast):**
```r
library(treeshap)
library(shapviz)

# For xgboost/random forest
shap_values <- treeshap(
  unified_model = underlying_model,
  x = test_data
)

shap_viz <- shapviz(shap_values, X = test_data)

# Waterfall plot for case 1
sv_waterfall(shap_viz, row_id = 1)

# Dependence plot
sv_dependence(shap_viz, v = "feature_name")
```

**Code Example (Any model - slower):**
```r
library(kernelshap)

shap_values <- kernelshap(
  object = workflow_fit,
  X = test_data,
  bg_X = test_data[sample(1:nrow(test_data), 100), ]
)
```

**Pros:**
- Theoretically sound (Shapley values)
- Model-agnostic
- Provides both local and global insights
- Additive (contributions sum to prediction)

**Cons:**
- Computationally expensive
- Can be slow for large datasets/complex models
- Requires understanding of game theory for full appreciation

**Visualization Types:**

1. **Waterfall Plot**: Shows feature contributions for one prediction
2. **Force Plot**: Horizontal waterfall (features pushing/pulling)
3. **Dependence Plot**: SHAP value vs feature value (shows patterns)
4. **Beeswarm Plot**: All observations, all features (global overview)
5. **Bar Plot**: Mean |SHAP| for feature importance ranking

**Interpretation Tips:**
- Use waterfall plots for explaining individual cases
- Use dependence plots to understand feature effects
- Look for interactions (coloring by another feature)
- Compare SHAP importance with permutation importance

---

### 7. LIME (Local Interpretable Model-agnostic Explanations)

**What it does:** Fits local linear model around a prediction to explain it

**Packages:** `lime`

**When to use:**
- Need fast local explanations
- SHAP is too computationally expensive
- Want rule-based explanations
- Working with text or image data

**How it works:**
1. Select a prediction to explain
2. Generate perturbed samples around that observation
3. Get model predictions for perturbed samples
4. Fit simple linear model (or decision tree) to local data
5. Linear coefficients = feature contributions

**Code Example:**
```r
library(lime)

# Create explainer
explainer_lime <- lime(
  x = train_data %>% select(-outcome),
  model = workflow_fit,
  bin_continuous = TRUE
)

# Explain specific cases
explanations <- explain(
  x = test_data[1:5, ] %>% select(-outcome),
  explainer = explainer_lime,
  n_features = 10
)

plot_features(explanations)
```

**Pros:**
- Fast to compute
- Easy to understand (linear explanations)
- Works with any model type
- Good for text/image data

**Cons:**
- Less theoretically rigorous than SHAP
- Explanations are approximations
- Sensitive to kernel width and sampling
- May not agree with SHAP

**Interpretation Tips:**
- Use as quick sanity check
- Compare with SHAP for important cases
- If LIME and SHAP disagree significantly, investigate why
- Use SHAP for final explanations (more rigorous)

---

### 8. Break Down Plots

**What it does:** Sequentially adds features to show cumulative contribution to prediction

**Packages:** `DALEX`

**When to use:**
- Want to tell a "story" of a prediction
- Need to understand order of feature contributions
- Explaining to non-technical audiences

**How it works:**
1. Start with baseline (average prediction)
2. Add features one at a time in order of importance
3. Show cumulative change in prediction
4. Final prediction = baseline + all contributions

**Code Example:**
```r
library(DALEX)

bd <- predict_parts(
  explainer,
  new_observation = test_data[1, ] %>% select(-outcome),
  type = "break_down"
)

plot(bd)
```

**Pros:**
- Tells clear story of prediction
- Sequential narrative is intuitive
- Shows cumulative contributions

**Cons:**
- Order-dependent (different orders = different values)
- Not theoretically unique like SHAP
- Can be misleading for interacting features

**Interpretation Tips:**
- Use for communication, not rigorous analysis
- Order by feature importance for consistency
- Compare with SHAP waterfall for validation
- Good for executive presentations

---

### 9. Ceteris Paribus Profiles (What-If Analysis)

**What it does:** Shows how a prediction changes when varying one feature while keeping others fixed

**Packages:** `DALEX`

**When to use:**
- Answering "what if" questions
- Exploring sensitivity to specific features
- Understanding feature effects for one case
- Business scenario analysis

**How it works:**
1. Select an observation and feature
2. Vary that feature across its range
3. Keep all other features at their original values
4. Plot prediction vs feature value
5. Shows ICE curve for that specific observation

**Code Example:**
```r
library(DALEX)

cp <- predict_profile(
  explainer,
  new_observation = test_data[1, ] %>% select(-outcome),
  variables = "feature_name"
)

plot(cp)
```

**Pros:**
- Answers specific "what if" questions
- Shows prediction sensitivity
- Useful for business scenario planning

**Cons:**
- Only one observation at a time
- Doesn't show population-level effects
- Can be computationally expensive for many features

**Interpretation Tips:**
- Use for high-stakes decisions
- "If this customer's income increased by $10k, how would risk change?"
- Compare with PDP to see if this case is typical or unusual
- Great for interactive dashboards

---

## Method Combinations

### Recommended Workflows

**Workflow 1: Quick Interpretation (1-2 hours)**
1. VIP → Quick importance ranking
2. PDP → Feature effects for top 5 features
3. LIME → Explain 3-5 interesting cases

**Workflow 2: Comprehensive Interpretation (1-2 days)**
1. VIP + Permutation Importance → Robust importance ranking
2. PDP + ICE → Global patterns with heterogeneity
3. SHAP → Local and global insights
4. ALE → Validate PDP for correlated features

**Workflow 3: Regulatory/High-Stakes (2-3 days)**
1. Permutation Importance (50+ repetitions) → Robust importance
2. ALE → Unbiased feature effects
3. SHAP → Individual predictions with theoretical guarantees
4. Stability analysis → Bootstrap to assess consistency
5. Documentation → Model card + technical report

---

## Model-Specific Recommendations

### Tree-Based Models (xgboost, random forest, lightgbm)

**Best methods:**
- SHAP (use `treeshap` for speed)
- VIP (built-in importance)
- PDP (fast and interpretable)

**Why:**
- Tree models have fast exact SHAP algorithms
- Built-in feature importance is reliable
- Non-linear effects captured well by PDP

---

### Linear Models (lm, glm, glmnet)

**Best methods:**
- Coefficients (direct interpretation)
- Permutation importance (validation)
- PDP (usually linear, but check)

**Why:**
- Coefficients are already interpretable
- PDPs typically linear (sanity check)
- SHAP may be overkill (but useful for additive decomposition)

---

### Neural Networks (keras, torch)

**Best methods:**
- SHAP (kernelshap for deep nets)
- LIME (good for complex models)
- Permutation importance (robust)

**Why:**
- No built-in interpretability
- SHAP provides model-agnostic explanations
- Need robust methods for black-box models

---

### Ensemble Models (stacks, blends)

**Best methods:**
- SHAP (handles any model)
- Permutation importance (aggregated importance)
- ALE (less sensitive to model complexity)

**Why:**
- Model-agnostic methods essential
- SHAP works across all model types
- Need methods that handle complexity

---

## Common Pitfalls & Solutions

### Pitfall 1: Correlated Features

**Problem:** PDP gives strange results, VIP biased

**Solution:**
- Use ALE instead of PDP
- Calculate conditional importance
- Consider dropping redundant features

---

### Pitfall 2: SHAP Too Slow

**Problem:** `kernelshap` takes hours

**Solution:**
- Use `treeshap` for tree models (100x faster)
- Reduce sample size
- Use LIME as alternative
- Calculate SHAP for subset of important predictions only

---

### Pitfall 3: Inconsistent Explanations

**Problem:** SHAP and LIME give different explanations

**Solution:**
- SHAP is more rigorous → use as primary
- LIME is approximation → use as sanity check
- If major disagreement, investigate model stability
- Document both methods and differences

---

### Pitfall 4: Explanations Don't Match Intuition

**Problem:** Top features seem wrong

**Solution:**
- Check for data leakage
- Validate with permutation importance
- Review feature engineering
- Consult domain experts
- May be genuine insight OR data problem

---

### Pitfall 5: Too Many Features

**Problem:** Can't interpret 100+ features

**Solution:**
- Focus on top 10-20 features
- Use feature importance for filtering
- Consider dimensionality reduction
- Group features by domain/category

---

## Computational Considerations

### Memory Requirements

| Method | Memory | Notes |
|--------|--------|-------|
| VIP | Low | Single model evaluation |
| Permutation | Medium | B * n_features predictions |
| PDP | Medium | grid_size * n_obs predictions |
| SHAP (tree) | Medium | Efficient for trees |
| SHAP (kernel) | High | Requires many perturbations |
| LIME | Low | Local sampling only |

---

### Speed Comparison (typical)

```
VIP:              < 1 second
Permutation:      seconds to minutes (depends on B)
PDP:              seconds to minutes (depends on grid)
ALE:              seconds to minutes
ICE:              minutes (N * grid_size predictions)
SHAP (tree):      seconds to minutes
SHAP (kernel):    minutes to hours
LIME:             seconds per case
```

---

## Package Ecosystem

### Core Interpretation Packages

**DALEX**: Model-agnostic, comprehensive toolkit
- `explain()`: Create explainer
- `model_parts()`: Permutation importance
- `model_profile()`: PDP, ALE, ICE
- `predict_parts()`: Break down, SHAP
- `predict_profile()`: Ceteris paribus

**iml**: Interpretable machine learning
- `FeatureImp`: Permutation importance
- `FeatureEffect`: PDP, ALE, ICE
- `Shapley`: SHAP values (slow)
- `LocalModel`: LIME

**vip**: Variable importance plots
- `vi()`: Extract importance
- `vip()`: Plot importance
- Works with many model types

---

### SHAP-Specific Packages

**shapviz**: SHAP visualization
- `sv_waterfall()`: Waterfall plots
- `sv_force()`: Force plots
- `sv_dependence()`: Dependence plots
- `sv_importance()`: Importance ranking

**treeshap**: Fast SHAP for trees
- `treeshap()`: Exact SHAP for tree models
- 100x faster than kernel SHAP

**kernelshap**: SHAP for any model
- `kernelshap()`: Model-agnostic SHAP

**SHAPforxgboost**: XGBoost-specific
- `shap.values()`: Fast SHAP
- `shap.plot.summary()`: Beeswarm plots

---

### Tidymodels Integration

All methods work with tidymodels workflows:

```r
# Create workflow
workflow_fit <- final_workflow %>% fit(train_data)

# Extract for interpretation
model_fit <- workflow_fit %>% extract_fit_parsnip()
underlying_model <- model_fit$fit

# Use with interpretation packages
explainer <- explain_tidymodels(
  model = workflow_fit,
  data = test_data %>% select(-outcome),
  y = test_data %>% pull(outcome)
)
```

---

## References & Resources

### Academic Papers

- **SHAP**: Lundberg & Lee (2017), "A Unified Approach to Interpreting Model Predictions"
- **LIME**: Ribeiro et al. (2016), "Why Should I Trust You?"
- **ALE**: Apley & Zhu (2016), "Visualizing the Effects of Predictor Variables"
- **IML**: Molnar (2019), "Interpretable Machine Learning" (book)

### R Package Documentation

- DALEX: https://modeloriented.github.io/DALEX/
- iml: https://christophm.github.io/iml/
- vip: https://koalaverse.github.io/vip/
- shapviz: https://modeloriented.github.io/shapviz/

### Tutorials

- DALEX: https://ema.drwhy.ai/
- Tidy models + DALEX: https://www.tidymodels.org/learn/models/interpretability/

---

_Interpretability Methods Reference — RDS Module_
_Model Interpretation Workflow_
_Last Updated: 2026-03-17_
