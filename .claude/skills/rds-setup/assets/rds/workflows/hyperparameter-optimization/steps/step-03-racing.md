# Step 3: Racing Methods

## MANDATORY EXECUTION RULES

- 🛑 NEVER race without baseline results for comparison
- ✅ ALWAYS use early stopping to save computation
- 📊 TRACK eliminated configurations and reasons
- 💬 EXPLAIN racing decisions transparently
- ⚖️ COMPARE racing vs. Bayesian results objectively

---

## EXECUTION PROTOCOLS

- Load Bayesian results from Step 2
- Configure racing strategy (ANOVA or win/loss)
- Apply early stopping rules
- Track efficiency gains
- Validate robustness of top configurations
- Compare methods fairly

---

## CONTEXT BOUNDARIES

- Bayesian results from Step 2 at `{output_folder}/bayesian_results.rds`
- Best parameters from Step 2 at `{output_folder}/best_params_bayesian.rds`
- Search space and metadata from Step 1
- Variables from workflow.md available

---

## YOUR TASK

Apply racing methods with early stopping to efficiently validate configurations and potentially discover robust alternatives to the Bayesian best.

---

## EXECUTION SEQUENCE

### 1. Load Previous Results

"**Step 3: Racing Methods**

Racing uses early stopping to eliminate unpromising configurations quickly, saving computational resources while still identifying top performers.

Loading results from Steps 1-2..."

```r
# Load previous results
search_space <- readRDS("[output_folder]/search_space_config.rds")
metadata <- readRDS("[output_folder]/search_metadata.rds")
bayes_results <- readRDS("[output_folder]/bayesian_results.rds")
best_bayes <- readRDS("[output_folder]/best_params_bayesian.rds")

# Get Bayesian best performance for comparison
bayes_best_perf <- bayes_results %>%
  show_best(metric = metadata$target_metric, n = 1) %>%
  pull(mean)

cat("Baseline Performance (Bayesian):\n")
cat(toupper(metadata$target_metric), "=", round(bayes_best_perf, 4), "\n")
```

### 2. Explain Racing Methods

"**What is Racing?**

Racing is an efficient hyperparameter tuning method that:

1. **Tests many configurations in parallel**
2. **Eliminates poor performers early** (after few CV folds)
3. **Focuses resources on promising configurations**
4. **Saves 50-70% computation vs. full grid search**

**Two Racing Strategies:**

**1. ANOVA Racing (`tune_race_anova`)**
- Uses ANOVA to test if configurations are statistically different
- Eliminates configurations that are significantly worse
- More conservative (keeps more configurations longer)
- Best for: Noisy objectives, want robust configurations

**2. Win/Loss Racing (`tune_race_win_loss`)**
- Uses pairwise comparisons (wins vs. losses)
- More aggressive elimination
- Faster but potentially misses close alternatives
- Best for: Clear performance differences, time-constrained

**My Recommendation:**

For your [model_type] optimization:
[ANOVA if high variance or small differences expected]
[Win/Loss if clear performance gaps likely]

**Which racing strategy would you like to use?**
- [ANOVA] ANOVA Racing (recommended for most cases)
- [WINLOSS] Win/Loss Racing (faster, more aggressive)
- [BOTH] Run both and compare (most thorough)
- [SKIP] Skip racing, use Bayesian results only"

### 3. Handle User Selection

Based on user choice, configure racing:

```r
racing_method <- "[user_choice]"  # "anova", "winloss", or "both"
```

### 4. Configure Racing Parameters

"**Racing Configuration:**

Racing needs to know:
1. **How many configurations to test** (candidate pool size)
2. **Minimum fold before elimination** (burn_in)
3. **Significance threshold** (alpha for ANOVA)

**Recommended Settings:**

- **Grid Size:** 100-200 configurations (larger than Bayesian iterations)
- **Burn-in:** 3 folds (evaluate at least 3 folds before eliminating)
- **Alpha:** 0.05 (standard significance level)

This will test a large grid but eliminate poor performers early.

**Do you want to:**
- [DEFAULT] Use recommended settings (100 configs, burn-in=3, alpha=0.05)
- [CUSTOM] Customize parameters
- [LARGE] Larger grid (200 configs, more thorough but slower)"

### 5. Set Up Racing Grid

```r
library(finetune)

# Configuration
racing_config <- list(
  grid_size = [100 or user-specified],
  burn_in = [3 or user-specified],
  alpha = [0.05 or user-specified]
)

# Generate racing grid (Latin Hypercube for good coverage)
set.seed(2468)
racing_grid <- grid_latin_hypercube(
  search_space,
  size = racing_config$grid_size
)

cat("Racing grid generated:\n")
cat("- Configurations:", nrow(racing_grid), "\n")
cat("- Parameters:", ncol(racing_grid), "\n")
```

### 6. Execute ANOVA Racing (if selected)

"**Starting ANOVA Racing...**

This will test [grid_size] configurations with early stopping.

**Expected Behavior:**
- Start with all configurations
- Eliminate statistically inferior ones after burn-in
- Focus computation on top performers
- Typically keeps 10-20% of initial configurations

**Progress updates will show how many configurations remain...**"

```r
# Set up parallel processing
cores_available <- metadata$cores_available
if (cores_available > 1) {
  cl <- makeCluster(cores_available)
  registerDoParallel(cl)
}

# Run ANOVA racing
set.seed(3579)
anova_results <- [workflow_name] %>%
  tune_race_anova(
    resamples = [cv_folds],
    grid = racing_grid,
    metrics = metric_set([target_metric]),
    control = control_race(
      verbose = TRUE,
      burn_in = racing_config$burn_in,
      alpha = racing_config$alpha,
      save_pred = TRUE,
      save_workflow = TRUE,
      parallel_over = "resamples"
    )
  )

# Stop cluster
if (exists("cl")) stopCluster(cl)

# Save results
saveRDS(anova_results, "[output_folder]/racing_anova_results.rds")

cat("\n✓ ANOVA racing complete!\n")
```

### 7. Execute Win/Loss Racing (if selected)

"**Starting Win/Loss Racing...**

Similar setup to ANOVA, but using pairwise win/loss comparisons."

```r
# Set up parallel processing again
if (cores_available > 1) {
  cl <- makeCluster(cores_available)
  registerDoParallel(cl)
}

# Run Win/Loss racing
set.seed(4680)
winloss_results <- [workflow_name] %>%
  tune_race_win_loss(
    resamples = [cv_folds],
    grid = racing_grid,
    metrics = metric_set([target_metric]),
    control = control_race(
      verbose = TRUE,
      burn_in = racing_config$burn_in,
      save_pred = TRUE,
      save_workflow = TRUE,
      parallel_over = "resamples"
    )
  )

# Stop cluster
if (exists("cl")) stopCluster(cl)

# Save results
saveRDS(winloss_results, "[output_folder]/racing_winloss_results.rds")

cat("\n✓ Win/Loss racing complete!\n")
```

### 8. Analyze Racing Results

"**Analyzing racing results...**"

```r
# Function to analyze racing method
analyze_racing <- function(results, method_name) {
  # Best configurations
  best_configs <- results %>%
    show_best(metric = metadata$target_metric, n = 10)

  # Best single
  best_params <- select_best(results, metric = metadata$target_metric)
  best_perf <- best_configs$mean[1]

  # Efficiency metrics
  all_results <- collect_metrics(results)
  n_tested <- length(unique(all_results$.config))
  n_survived <- results %>%
    show_best(metric = metadata$target_metric, n = Inf) %>%
    nrow()

  elimination_rate <- (n_tested - n_survived) / n_tested * 100

  # Return summary
  list(
    method = method_name,
    best_params = best_params,
    best_performance = best_perf,
    configurations_tested = n_tested,
    configurations_survived = n_survived,
    elimination_rate = elimination_rate,
    top_10 = best_configs
  )
}

# Analyze each method
if (racing_method %in% c("anova", "both")) {
  anova_summary <- analyze_racing(anova_results, "ANOVA Racing")
}

if (racing_method %in% c("winloss", "both")) {
  winloss_summary <- analyze_racing(winloss_results, "Win/Loss Racing")
}
```

**Present results:**

"**Racing Results Summary:**

[IF ANOVA:]
**ANOVA Racing:**
- Configurations tested: [n_tested]
- Survived to end: [n_survived]
- Elimination rate: [elimination_rate]%
- Best [metric]: [best_perf] ± [std_err]

**Top 5 Configurations:**
[top 5 from anova_summary$top_10]

[IF WINLOSS:]
**Win/Loss Racing:**
- Configurations tested: [n_tested]
- Survived to end: [n_survived]
- Elimination rate: [elimination_rate]%
- Best [metric]: [best_perf] ± [std_err]

**Top 5 Configurations:**
[top 5 from winloss_summary$top_10]

**Comparison to Bayesian:**
- Bayesian best: [bayes_best_perf]
- Racing best: [racing_best_perf]
- Difference: [difference] ([better/worse/same])"

### 9. Visualize Racing Convergence

"**Generating racing visualizations...**"

```r
# Function to create convergence plot
plot_racing_convergence <- function(results, method_name) {
  metrics_over_resamples <- collect_metrics(results, summarize = FALSE)

  p <- metrics_over_resamples %>%
    group_by(.config) %>%
    mutate(
      config_alive = max(id) == max([cv_folds]$id),  # Did it survive?
      cum_mean = cummean(.estimate)
    ) %>%
    ggplot(aes(x = id, y = cum_mean, group = .config, color = config_alive)) +
    geom_line(alpha = 0.3) +
    scale_color_manual(
      values = c("TRUE" = "green", "FALSE" = "red"),
      labels = c("TRUE" = "Survived", "FALSE" = "Eliminated"),
      name = "Status"
    ) +
    labs(
      title = paste(method_name, "Convergence"),
      subtitle = "Each line = one configuration",
      x = "CV Fold",
      y = paste("Cumulative Mean", toupper(metadata$target_metric))
    ) +
    theme_minimal() +
    theme(legend.position = "top")

  return(p)
}

# Create plots
if (racing_method %in% c("anova", "both")) {
  anova_plot <- plot_racing_convergence(anova_results, "ANOVA Racing")
  ggsave(
    "[output_folder]/racing_anova_convergence.png",
    anova_plot,
    width = 10,
    height = 6,
    dpi = 300
  )
}

if (racing_method %in% c("winloss", "both")) {
  winloss_plot <- plot_racing_convergence(winloss_results, "Win/Loss Racing")
  ggsave(
    "[output_folder]/racing_winloss_convergence.png",
    winloss_plot,
    width = 10,
    height = 6,
    dpi = 300
  )
}

# Comparison plot (if both methods)
if (racing_method == "both") {
  comparison <- tibble(
    Method = c("Bayesian", "ANOVA Racing", "Win/Loss Racing"),
    Performance = c(bayes_best_perf, anova_summary$best_performance, winloss_summary$best_performance),
    Configs_Tested = c(nrow(collect_metrics(bayes_results)), anova_summary$configurations_tested, winloss_summary$configurations_tested)
  )

  comp_plot <- comparison %>%
    ggplot(aes(x = Method, y = Performance, fill = Method)) +
    geom_col() +
    geom_text(aes(label = round(Performance, 4)), vjust = -0.5) +
    labs(
      title = "Method Comparison",
      subtitle = paste("Target Metric:", toupper(metadata$target_metric)),
      y = toupper(metadata$target_metric)
    ) +
    theme_minimal() +
    theme(legend.position = "none")

  ggsave(
    "[output_folder]/method_comparison.png",
    comp_plot,
    width = 8,
    height = 6,
    dpi = 300
  )
}

cat("\n✓ Plots saved\n")
```

**Show plots to user:**

"**Racing Visualizations:**

1. **Convergence Plots:**
   - Green lines: Configurations that survived to the end
   - Red lines: Eliminated configurations
   - Shows how racing eliminates poor performers early

[Display plots]

2. **Method Comparison** (if both methods run):
   - Direct performance comparison across methods

[Display comparison plot if available]"

### 10. Select Final Method and Parameters

"**Decision Time: Which approach performed best?**

Let's objectively compare:

| Method | Best [Metric] | Std Error | Configs Tested | Time Efficient |
|--------|---------------|-----------|----------------|----------------|
| Bayesian | [bayes_perf] | [bayes_se] | [bayes_n] | ⭐⭐⭐ |
| [Racing methods...] | [...] | [...] | [...] | ⭐⭐⭐⭐⭐ |

**My Recommendation:**

[Analyze and provide recommendation based on:]
- Performance (which achieved best metric?)
- Robustness (which has lowest std error?)
- Efficiency (which tested most configs per unit time?)
- Convergence (which showed clear winner?)

**Select final parameters:**
- [BAYESIAN] Use Bayesian optimization best (conservative, proven)
- [ANOVA] Use ANOVA racing best (efficient, validated)
- [WINLOSS] Use Win/Loss racing best (aggressive, fast)
- [ENSEMBLE] Proceed to Step 4 and ensemble top performers

Which would you like to proceed with?"

### 11. Save Final Selection

Based on user choice:

```r
# Save selected approach
final_selection <- list(
  method = "[user_choice]",
  parameters = [selected_params],
  performance = [selected_performance],
  std_error = [selected_std_err],
  rationale = "[reason for selection]",
  date_selected = Sys.time()
)

saveRDS(final_selection, "[output_folder]/final_selection.rds")

# Save comprehensive comparison
comparison_table <- tibble(
  Method = c("Bayesian", "ANOVA", "WinLoss"),
  Best_Performance = c([...]),
  Std_Error = c([...]),
  Configs_Tested = c([...]),
  Winner = c([...])  # Mark winner with TRUE
)

write_csv(comparison_table, "[output_folder]/method_comparison.csv")

cat("\n✓ Final selection saved\n")
```

### 12. Generate Step Summary

"**Step 3 Complete: Racing Methods Finished**

**Summary:**

**Methods Compared:**
- Bayesian Optimization: [performance]
- [Racing methods]: [performance]

**Winner:** [selected_method]

**Final Parameters:**
[display selected parameters]

**Performance:**
- [metric]: [value] ± [std_err]
- Improvement over baseline: [if applicable]

**Efficiency Gains:**
- Racing eliminated [%] of configurations early
- Computational savings: [estimate]

**Files Saved:**
- `racing_[method]_results.rds` — Racing results
- `racing_[method]_convergence.png` — Convergence plots
- `method_comparison.png` — Performance comparison
- `final_selection.rds` — Selected parameters and rationale
- `method_comparison.csv` — Detailed comparison table

**Key Insights:**
[2-3 bullet points about what racing revealed]

---

**Next Steps:**

You have two options:

1. **[FINALIZE]** — Use selected parameters as final configuration
   - Fit final model with these parameters
   - Proceed to evaluation

2. **[ENSEMBLE]** — Proceed to Step 4: Ensemble Methods
   - Combine multiple top configurations
   - May improve performance and robustness
   - Adds complexity but can be worth it for critical applications

Which would you like to do?"

### 13. Handle User Decision

**IF FINALIZE:**
- Generate final workflow with selected parameters
- Provide code for final fit
- Recommend next steps (test set evaluation)
- End workflow

**IF ENSEMBLE:**
- Load `./step-04-ensemble.md`

---

## SUCCESS METRICS

✅ Racing method(s) executed successfully
✅ Early stopping worked (configurations eliminated)
✅ Efficiency gains documented
✅ Results compared to Bayesian baseline
✅ Convergence visualized
✅ Final parameters selected with clear rationale
✅ All results saved and documented

---

## FAILURE MODES TO AVOID

❌ Not comparing to Bayesian baseline
❌ Racing grid too small (no efficiency gain)
❌ Burn-in too high (no early stopping)
❌ Alpha too permissive (keeps too many configs)
❌ Not tracking which configs were eliminated
❌ Selecting method without justification

---

## RACING EFFICIENCY INSIGHTS

**Why Racing Works:**

Traditional tuning evaluates ALL configurations on ALL folds.
- 100 configs × 10 folds = 1000 model fits

Racing with early stopping:
- 100 configs start
- After 3 folds, eliminate 50% (50 configs remain)
- After 6 folds, eliminate another 50% (25 configs remain)
- Only 25 complete all 10 folds
- Total fits: (100×3) + (50×3) + (25×4) = 550 fits
- **45% savings!**

**When Racing Helps Most:**

- Large parameter grids (100+ configurations)
- Clear performance differences between configs
- Multiple CV folds (10+)
- Expensive model fitting (deep learning, large datasets)

**When Racing Helps Less:**

- Small grids (< 20 configurations)
- Noisy objectives (high variance between folds)
- Few CV folds (< 5)
- Fast model fitting (linear models, small data)

---

## NEXT STEP

If user selected ensemble, load `./step-04-ensemble.md` to build ensemble models from top configurations.

Otherwise, workflow is complete with final parameters selected.
