# Step 4: Ensemble Methods

## MANDATORY EXECUTION RULES

- 🛑 NEVER ensemble without comparing to single best model
- ✅ ALWAYS test multiple ensemble strategies
- 📊 VALIDATE ensemble improves performance AND robustness
- 💬 EXPLAIN when ensemble is NOT worth the complexity
- ⚖️ BALANCE performance gain against deployment complexity

---

## EXECUTION PROTOCOLS

- Load top configurations from previous steps
- Test multiple ensemble strategies
- Compare ensemble vs. single best model
- Evaluate complexity vs. performance trade-off
- Make clear recommendation
- Document ensemble composition if selected

---

## CONTEXT BOUNDARIES

- Results from Steps 2-3 available
- Final selection from Step 3 at `{output_folder}/final_selection.rds`
- All tuning results available for extraction
- Variables from workflow.md available

---

## YOUR TASK

Evaluate whether combining multiple high-performing configurations into an ensemble improves performance enough to justify the added complexity.

---

## EXECUTION SEQUENCE

### 1. Load Previous Results and Best Model

"**Step 4: Ensemble Methods**

Sometimes multiple good models beat a single best model. Let's explore ensemble strategies.

**Key Question:** Is the performance gain worth the deployment complexity?

Loading results from previous steps..."

```r
# Load all results
final_selection <- readRDS("[output_folder]/final_selection.rds")
bayes_results <- readRDS("[output_folder]/bayesian_results.rds")
metadata <- readRDS("[output_folder]/search_metadata.rds")

# Try to load racing results if they exist
anova_exists <- file.exists("[output_folder]/racing_anova_results.rds")
winloss_exists <- file.exists("[output_folder]/racing_winloss_results.rds")

if (anova_exists) {
  anova_results <- readRDS("[output_folder]/racing_anova_results.rds")
}
if (winloss_exists) {
  winloss_results <- readRDS("[output_folder]/racing_winloss_results.rds")
}

# Get baseline: best single model
best_single_perf <- final_selection$performance
best_single_params <- final_selection$parameters

cat("Baseline (Best Single Model):\n")
cat("Method:", final_selection$method, "\n")
cat(toupper(metadata$target_metric), "=", round(best_single_perf, 4), "\n")
cat("Std Error:", round(final_selection$std_error, 4), "\n")
```

### 2. Explain Ensemble Strategies

"**What Are Ensembles?**

An ensemble combines predictions from multiple models. Benefits:
- **Better Performance:** Averaging reduces individual model errors
- **More Robust:** Less sensitive to any single model's weaknesses
- **Lower Variance:** Smoother predictions, fewer outliers

**Costs:**
- **Deployment Complexity:** Must maintain/serve multiple models
- **Inference Time:** Must run multiple models per prediction
- **Storage:** Must store multiple model objects

**Three Ensemble Strategies:**

**1. Simple Averaging**
- Classification: Majority vote or average probabilities
- Regression: Mean of predictions
- Pros: Simple, no additional training
- Cons: Treats all models equally (even if some are better)

**2. Weighted Averaging**
- Weight models by their CV performance
- Better models have more influence
- Pros: Still simple, respects quality differences
- Cons: Weights fixed, doesn't learn interactions

**3. Stacking (Meta-Model)**
- Train a meta-model on top of base model predictions
- Learns optimal way to combine predictions
- Pros: Most flexible, can capture complex patterns
- Cons: Most complex, requires additional training/validation

**My Recommendation for Your Problem:**

[Based on model type and performance variance, recommend strategy]

**Would you like to:**
- [ALL] Test all three strategies (most thorough)
- [SIMPLE] Try simple averaging only (quick check)
- [WEIGHTED] Try weighted averaging (balance of simple/effective)
- [STACK] Try stacking (most sophisticated)
- [SKIP] Skip ensemble, use single best model"

### 3. Handle User Selection

Based on selection, configure ensemble testing:

```r
ensemble_strategies <- "[user_choice]"  # "all", "simple", "weighted", "stack", "skip"
```

### 4. Extract Top Configurations

"**Extracting top configurations for ensemble...**

Strategy: Select top N diverse configurations"

```r
# Combine results from all methods
all_results <- bind_rows(
  collect_metrics(bayes_results) %>% mutate(method = "Bayesian"),
  if (anova_exists) collect_metrics(anova_results) %>% mutate(method = "ANOVA") else NULL,
  if (winloss_exists) collect_metrics(winloss_results) %>% mutate(method = "WinLoss") else NULL
)

# Get top 10 unique configurations
top_configs <- all_results %>%
  arrange(desc(mean)) %>%
  distinct(across(starts_with(names(metadata$parameters_tuned))), .keep_all = TRUE) %>%
  slice(1:10)

cat("\n**Top 10 Configurations for Ensemble:**\n")
print(top_configs %>% select(method, mean, std_err, starts_with(names(metadata$parameters_tuned)))))

# How many to ensemble?
ensemble_size_options <- c(3, 5, 7)

cat("\n**How many models to ensemble?**\n")
cat("- More models = potentially better performance but more complex\n")
cat("- Diminishing returns after 5-7 models\n")
cat("- Recommendation: Start with 5\n\n")
```

**Ask user:**

"How many models would you like in the ensemble?
- [3] Top 3 (minimal ensemble)
- [5] Top 5 (recommended)
- [7] Top 7 (thorough)
- [CUSTOM] Custom number"

### 5. Fit Ensemble Members

"**Fitting ensemble members...**

This will fit each configuration on the full training data."

```r
# Get user's ensemble size choice
ensemble_size <- [user_choice]

# Extract top N configurations
ensemble_configs <- top_configs %>%
  slice(1:ensemble_size)

# Fit each configuration
library(purrr)

ensemble_members <- map(1:ensemble_size, function(i) {
  config <- ensemble_configs %>% slice(i)

  cat("Fitting ensemble member", i, "of", ensemble_size, "...\n")

  # Finalize workflow with this config
  final_wf <- finalize_workflow(
    [workflow_name],
    config %>% select(starts_with(names(metadata$parameters_tuned)))
  )

  # Fit on full training data
  fitted_wf <- fit(final_wf, data = [training_data])

  # Store with metadata
  list(
    workflow = fitted_wf,
    config = config,
    cv_performance = config$mean,
    std_err = config$std_err
  )
})

# Save ensemble members
saveRDS(ensemble_members, "[output_folder]/ensemble_members.rds")

cat("\n✓ All", ensemble_size, "ensemble members fitted\n")
```

### 6. Create Ensemble Predictions Function

"**Creating ensemble prediction functions...**"

```r
# Function for simple averaging
predict_simple_ensemble <- function(new_data, members, type = "class") {
  # Get predictions from each member
  preds <- map(members, function(m) {
    predict(m$workflow, new_data, type = type)
  })

  # Average predictions
  if (type == "prob") {
    # Average probabilities
    pred_matrix <- map(preds, function(p) as.matrix(p)) %>%
      reduce(`+`) / length(members)
    as_tibble(pred_matrix)
  } else if (type == "class") {
    # Majority vote
    pred_df <- bind_cols(preds)
    pred_df %>%
      mutate(
        .pred_class = pmap_chr(., function(...) {
          votes <- c(...)
          names(sort(table(votes), decreasing = TRUE))[1]
        })
      ) %>%
      select(.pred_class)
  } else {
    # Regression: mean
    pred_matrix <- map(preds, function(p) pull(p, .pred)) %>%
      reduce(cbind)
    tibble(.pred = rowMeans(pred_matrix))
  }
}

# Function for weighted averaging
predict_weighted_ensemble <- function(new_data, members, type = "class") {
  # Calculate weights from CV performance
  weights <- map_dbl(members, ~.x$cv_performance)
  weights <- weights / sum(weights)  # Normalize to sum to 1

  # Get predictions
  preds <- map(members, function(m) {
    predict(m$workflow, new_data, type = type)
  })

  # Weighted average
  if (type == "prob") {
    pred_matrices <- map(preds, function(p) as.matrix(p))
    weighted_pred <- map2(pred_matrices, weights, `*`) %>%
      reduce(`+`)
    as_tibble(weighted_pred)
  } else if (type == "class") {
    # Weighted majority vote
    pred_df <- bind_cols(preds)
    pred_df %>%
      mutate(
        .pred_class = pmap_chr(., function(...) {
          votes <- c(...)
          vote_weights <- table(votes)
          weighted_votes <- vote_weights * weights[match(names(vote_weights), votes)]
          names(sort(weighted_votes, decreasing = TRUE))[1]
        })
      ) %>%
      select(.pred_class)
  } else {
    # Regression: weighted mean
    pred_matrix <- map(preds, function(p) pull(p, .pred)) %>%
      reduce(cbind)
    tibble(.pred = rowSums(pred_matrix * rep(weights, each = nrow(pred_matrix))))
  }
}

cat("✓ Ensemble prediction functions created\n")
```

### 7. Evaluate Ensemble on CV Folds

"**Evaluating ensemble strategies on CV folds...**

This compares ensemble vs. single best model fairly."

```r
# Use same CV folds as tuning
cv_folds <- [cv_folds_object]

# Evaluate each strategy
evaluate_ensemble_cv <- function(strategy_name, predict_fn) {
  cat("Evaluating", strategy_name, "...\n")

  fold_results <- map_dfr(cv_folds$splits, function(split) {
    # Get train and validation data
    train_data <- analysis(split)
    val_data <- assessment(split)

    # Fit ensemble members on this fold's training data
    fold_members <- map(ensemble_configs %>% slice(1:ensemble_size), function(config) {
      wf <- finalize_workflow(
        [workflow_name],
        config %>% select(starts_with(names(metadata$parameters_tuned)))
      )
      fit(wf, train_data)
    })

    # Make predictions on validation
    ensemble_preds <- predict_fn(
      val_data,
      map2(fold_members, ensemble_members, ~list(workflow = .x, cv_performance = .y$cv_performance))
    )

    # Calculate metric
    truth_col <- [target_variable]
    metric_fn <- [metric_function]

    metric_val <- metric_fn(
      bind_cols(val_data, ensemble_preds),
      truth = truth_col,
      estimate = .pred_class  # or .pred for regression
    ) %>%
      pull(.estimate)

    tibble(
      fold = split$id,
      metric = metric_val
    )
  })

  # Summarize
  fold_results %>%
    summarise(
      strategy = strategy_name,
      mean_metric = mean(metric),
      std_err = sd(metric) / sqrt(n())
    )
}

# Evaluate selected strategies
ensemble_results <- tibble()

if (ensemble_strategies %in% c("all", "simple")) {
  ensemble_results <- bind_rows(
    ensemble_results,
    evaluate_ensemble_cv("Simple Averaging", predict_simple_ensemble)
  )
}

if (ensemble_strategies %in% c("all", "weighted")) {
  ensemble_results <- bind_rows(
    ensemble_results,
    evaluate_ensemble_cv("Weighted Averaging", predict_weighted_ensemble)
  )
}

# Add baseline for comparison
baseline_result <- tibble(
  strategy = "Best Single Model",
  mean_metric = best_single_perf,
  std_err = final_selection$std_error
)

comparison <- bind_rows(baseline_result, ensemble_results) %>%
  arrange(desc(mean_metric))

cat("\n✓ Ensemble evaluation complete\n")
```

### 8. Implement Stacking (if selected)

"**Training stacking meta-model...**"

```r
if (ensemble_strategies %in% c("all", "stack")) {
  # Generate meta-features from CV predictions
  meta_data <- map_dfr(cv_folds$splits, function(split) {
    train_data <- analysis(split)
    val_data <- assessment(split)

    # Fit base models on training fold
    base_preds <- map_dfc(ensemble_configs %>% slice(1:ensemble_size), function(config) {
      wf <- finalize_workflow([workflow_name], config %>% select(starts_with(names(metadata$parameters_tuned))))
      fitted <- fit(wf, train_data)
      predict(fitted, val_data, type = "prob") %>%
        select(1)  # First probability column
    })

    # Add truth
    bind_cols(
      base_preds,
      val_data %>% select({{truth_col}})
    )
  })

  # Train meta-model (logistic regression for classification, linear for regression)
  if ([problem_type] == "classification") {
    meta_model <- logistic_reg() %>%
      set_engine("glm") %>%
      fit({{truth_col}} ~ ., data = meta_data)
  } else {
    meta_model <- linear_reg() %>%
      set_engine("lm") %>%
      fit({{truth_col}} ~ ., data = meta_data)
  }

  # Evaluate stacking
  stacking_cv_performance <- meta_model %>%
    augment(meta_data) %>%
    [metric_function](truth = {{truth_col}}, estimate = .pred_class) %>%  # or .pred
    pull(.estimate)

  ensemble_results <- bind_rows(
    ensemble_results,
    tibble(
      strategy = "Stacking",
      mean_metric = mean(stacking_cv_performance),
      std_err = sd(stacking_cv_performance) / sqrt(length(stacking_cv_performance))
    )
  )

  # Save meta-model
  saveRDS(meta_model, "[output_folder]/stacking_meta_model.rds")

  cat("✓ Stacking meta-model trained and saved\n")
}
```

### 9. Compare All Strategies

"**Ensemble Strategy Comparison:**

| Strategy | [Metric] | Std Error | vs. Best Single | Worth It? |
|----------|----------|-----------|-----------------|-----------|
[comparison table with all strategies]

**Analysis:**"

```r
# Calculate improvement over baseline
comparison <- comparison %>%
  mutate(
    improvement = mean_metric - baseline_result$mean_metric,
    improvement_pct = improvement / baseline_result$mean_metric * 100,
    significant = improvement > 2 * std_err,  # Simple significance test
    worth_it = significant & improvement_pct > 1  # At least 1% improvement
  )

# Print detailed comparison
print(comparison)

# Visualize
comparison_plot <- comparison %>%
  ggplot(aes(x = reorder(strategy, mean_metric), y = mean_metric, fill = worth_it)) +
  geom_col() +
  geom_errorbar(aes(ymin = mean_metric - std_err, ymax = mean_metric + std_err), width = 0.2) +
  geom_text(aes(label = round(mean_metric, 4)), hjust = -0.2) +
  coord_flip() +
  scale_fill_manual(values = c("TRUE" = "green", "FALSE" = "gray"), name = "Worthwhile") +
  labs(
    title = "Ensemble Strategy Comparison",
    subtitle = paste("Target Metric:", toupper(metadata$target_metric)),
    x = "Strategy",
    y = toupper(metadata$target_metric)
  ) +
  theme_minimal()

ggsave(
  "[output_folder]/ensemble_comparison.png",
  comparison_plot,
  width = 10,
  height = 6,
  dpi = 300
)

cat("\n✓ Comparison plot saved\n")
```

**Show plot and analysis:**

"**Key Findings:**

[Analyze results:]
- **Best Strategy:** [highest performing strategy]
- **Improvement over single best:** [improvement] ([%])
- **Statistical Significance:** [yes/no based on std error]

**Complexity-Performance Trade-off:**

- **Simple Averaging:** [performance] — Easy to deploy, minimal overhead
- **Weighted Averaging:** [performance] — Still simple, respects model quality
- **Stacking:** [performance] — Most complex, requires meta-model

**My Recommendation:**

[Based on improvement and complexity, recommend:]
- If improvement < 1%: NOT worth it - use single best model
- If 1-3% improvement: Consider weighted averaging if easy to deploy
- If > 3% improvement: Strong case for ensemble, even with complexity

[Specific recommendation for this problem]"

### 10. Make Final Decision

"**Decision: Should we use an ensemble?**

Based on the analysis:
- Performance gain: [gain]
- Deployment complexity: [assessment]
- Statistical confidence: [confidence]

**Your options:**
- [BEST] Use best single model (simpler, often good enough)
- [SIMPLE] Use simple ensemble (easy to implement)
- [WEIGHTED] Use weighted ensemble (good balance)
- [STACK] Use stacking ensemble (maximum performance)"

### 11. Finalize and Save

Based on user choice:

```r
# Save final decision
final_ensemble_decision <- list(
  use_ensemble = [TRUE or FALSE],
  strategy = [selected_strategy or "single_model"],
  members = if ([use_ensemble]) ensemble_members else NULL,
  performance = [selected_performance],
  improvement_over_single = [improvement],
  rationale = "[explanation]",
  deployment_notes = "[implementation guidance]",
  date_finalized = Sys.time()
)

saveRDS(final_ensemble_decision, "[output_folder]/final_ensemble_decision.rds")

# If ensemble selected, save complete ensemble object
if ([use_ensemble]) {
  ensemble_object <- list(
    members = ensemble_members,
    strategy = [selected_strategy],
    predict_function = [selected_predict_function],
    meta_model = if (strategy == "stack") meta_model else NULL,
    weights = if (strategy == "weighted") weights else NULL
  )

  saveRDS(ensemble_object, "[output_folder]/final_ensemble.rds")

  cat("✓ Final ensemble saved to final_ensemble.rds\n")
} else {
  # Save single best model
  best_workflow <- finalize_workflow(
    [workflow_name],
    final_selection$parameters
  )
  final_model <- fit(best_workflow, [training_data])

  saveRDS(final_model, "[output_folder]/final_model.rds")

  cat("✓ Final single model saved to final_model.rds\n")
}

# Save comparison results
write_csv(comparison, "[output_folder]/ensemble_comparison.csv")
```

### 12. Generate Final Workflow Report

"**Hyperparameter Optimization Complete!**

**Final Configuration:**

[IF ENSEMBLE:]
- **Approach:** Ensemble ([strategy])
- **Members:** [n] models
- **Performance:** [metric] = [value] ± [std_err]
- **Improvement over single best:** +[improvement] ([%])

[IF SINGLE:]
- **Approach:** Single Best Model
- **Method:** [Bayesian/ANOVA/WinLoss]
- **Performance:** [metric] = [value] ± [std_err]
- **Rationale:** Ensemble did not provide sufficient improvement

**Hyperparameters:**

[IF ENSEMBLE:]
[Show parameters for each ensemble member]

[IF SINGLE:]
[Show parameters for best model]

**Computational Summary:**

- **Total Configurations Tested:** [total from all methods]
- **Methods Used:** Bayesian Optimization, [Racing methods if used]
- **CV Folds:** [n_folds]
- **Duration:** [estimated time]

**Files Generated:**

All results saved to: `[output_folder]/`

**Key Artifacts:**
- `final_[model/ensemble].rds` — Ready-to-use model object
- `final_ensemble_decision.rds` — Decision documentation
- `tuning_results.html` — Complete analysis report
- `best_params.rds` — Optimal hyperparameters
- `tuning_history.csv` — All iterations
- `ensemble_comparison.csv` — Ensemble evaluation results

**Visualizations:**
- `bayesian_trajectory.png` — Bayesian optimization path
- `racing_convergence.png` — Racing elimination plots
- `ensemble_comparison.png` — Ensemble vs. single comparison
- `method_comparison.png` — All methods compared

---

**Next Steps:**

**1. Final Model Fit** (if not already done):
```r
final_model <- readRDS('[output_folder]/final_[model/ensemble].rds')
```

**2. Test Set Evaluation** (ONE TIME ONLY):
```r
# Evaluate on held-out test set
test_predictions <- predict(final_model, test_data)
test_metrics <- [metric_function](test_predictions, truth = {{truth}}, estimate = .pred_class)
```

**3. Model Interpretation**:
- Use RDS workflow: `model-interpretation`
- Generate VIP plots, SHAP values, PDPs

**4. Production Deployment**:
- Hand off to Marie (Deployment Agent)
- Use RDS workflow: `prototype-to-production`

---

**Congratulations on completing this intensive hyperparameter optimization!**

You've systematically explored the parameter space, compared multiple strategies, and made an informed decision about your final model configuration. This level of rigor is what separates good models from great ones.

**Remember:** The test set is sacred. Touch it ONCE for final evaluation, then proceed to production."

---

## SUCCESS METRICS

✅ Multiple ensemble strategies tested
✅ Ensemble vs. single model compared fairly on CV
✅ Complexity-performance trade-off analyzed
✅ Clear decision made with justification
✅ Final model/ensemble saved and ready to use
✅ Complete documentation generated
✅ User understands when to ensemble and when not to

---

## FAILURE MODES TO AVOID

❌ Ensembling without comparing to single best
❌ Not evaluating on same CV folds (unfair comparison)
❌ Ignoring deployment complexity
❌ Accepting <1% improvement for ensemble complexity
❌ Not saving ensemble properly (irreproducible)
❌ Touching test set during ensemble evaluation

---

## ENSEMBLE DECISION GUIDELINES

**Use Ensemble When:**
- ✅ Improvement > 2-3% and statistically significant
- ✅ High-stakes application (fraud, medical, finance)
- ✅ Deployment infrastructure can handle it
- ✅ Multiple models have similar performance (ensemble wisdom)

**Skip Ensemble When:**
- ❌ Improvement < 1% (not worth complexity)
- ❌ Low-stakes application (speed/simplicity matters more)
- ❌ Resource-constrained deployment
- ❌ One model clearly dominates (no ensemble benefit)

**Ensemble Complexity Levels:**

1. **Simple Average** — Complexity: +20%
   - Just average predictions, trivial to implement

2. **Weighted Average** — Complexity: +25%
   - Store weights, slightly more complex

3. **Stacking** — Complexity: +50%
   - Must maintain meta-model, predict in two stages

---

## WORKFLOW COMPLETE

This is the final step of the hyperparameter optimization workflow. You now have:
- Optimally tuned hyperparameters
- Choice of single model or ensemble
- Complete documentation of all decisions
- Visualizations of the optimization process
- Ready-to-deploy model object

Return to Alan's menu to proceed with evaluation or deployment workflows.
