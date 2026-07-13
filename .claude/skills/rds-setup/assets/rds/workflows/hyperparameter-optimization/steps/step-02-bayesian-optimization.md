# Step 2: Bayesian Optimization

## MANDATORY EXECUTION RULES

- 🛑 NEVER run optimization without loading search space from Step 1
- ✅ ALWAYS set seed for reproducibility
- 📊 TRACK optimization trajectory with plots
- 💬 SHOW intermediate results during tuning
- ⚠️ WARN if optimization hasn't converged

---

## EXECUTION PROTOCOLS

- Load search space configuration from Step 1
- Set up parallel processing if available
- Configure Bayesian optimization parameters
- Monitor performance trajectory
- Check for convergence
- Save all results and visualizations

---

## CONTEXT BOUNDARIES

- Search space from Step 1 at `{output_folder}/search_space_config.rds`
- Metadata from Step 1 at `{output_folder}/search_metadata.rds`
- User's workflow object and data available in session
- Variables from workflow.md available

---

## YOUR TASK

Execute Bayesian optimization to intelligently explore the hyperparameter space and find high-performing configurations.

---

## EXECUTION SEQUENCE

### 1. Load Previous Results

"**Step 2: Bayesian Optimization**

Loading search space configuration from Step 1..."

```r
# Load search space
search_space <- readRDS("[output_folder]/search_space_config.rds")
metadata <- readRDS("[output_folder]/search_metadata.rds")

# Display configuration
cat("Search Space Loaded:\n")
cat("- Model:", metadata$model_type, "\n")
cat("- Parameters:", length(metadata$parameters_tuned), "tunable parameters\n")
cat("- Metric:", metadata$target_metric, "\n")
cat("- CV Folds:", metadata$cv_folds, "\n")
```

### 2. Configure Bayesian Optimization

"**Bayesian Optimization Configuration:**

Bayesian optimization uses Gaussian Process models to learn which parameter regions are most promising. It balances:
- **Exploitation:** Testing parameter values near known good configurations
- **Exploration:** Testing unexplored regions that might be better

**Configuration Options:**

1. **Number of Iterations**
   - Default: 50 iterations (good for most problems)
   - More iterations = more thorough but slower
   - Suggest: Start with 50, can extend if not converged

2. **Initial Design**
   - Default: 10 space-filling initial points
   - Provides diverse starting locations for optimization

3. **Acquisition Function**
   - Default: Expected Improvement (good general choice)
   - Alternatives: Confidence Bound, Probability of Improvement

**Do you want to:**
- [DEFAULT] Use default configuration (50 iterations, EI acquisition)
- [CUSTOM] Customize parameters (iterations, acquisition function)
- [QUICK] Faster run (25 iterations, good for testing)"

### 3. Handle User Selection

Based on choice, set optimization parameters:

```r
# Bayesian optimization configuration
bayes_config <- list(
  iter = [50 or user-specified],
  initial = [10 or user-specified],
  objective = [acquisition_function],
  no_improve = 10  # Stop if no improvement after 10 iterations
)
```

### 4. Set Up Parallel Processing

"**Setting up parallel processing...**"

```r
library(tidymodels)
library(finetune)
library(doParallel)

# Configure parallel backend
cores_available <- metadata$cores_available
if (cores_available > 1) {
  cl <- makeCluster(cores_available)
  registerDoParallel(cl)
  cat("Parallel processing enabled:", cores_available, "cores\n")
} else {
  cat("Sequential processing (single core)\n")
}
```

### 5. Execute Bayesian Optimization

"**Starting Bayesian Optimization...**

This will take time. I'll show progress updates as we go.

**Estimated time:** [calculation based on model type and cores]

**What to expect:**
- Initial random sampling: [initial] iterations
- Bayesian optimization: [iter] iterations
- Progress updates every 5 iterations
- Best parameters tracked continuously"

```r
# Set seed for reproducibility
set.seed(1234)

# Run Bayesian optimization
bayes_results <- [workflow_name] %>%
  tune_bayes(
    resamples = [cv_folds],
    param_info = search_space,
    metrics = metric_set([target_metric]),
    initial = bayes_config$initial,
    iter = bayes_config$iter,
    objective = bayes_config$objective,
    control = control_bayes(
      no_improve = bayes_config$no_improve,
      verbose = TRUE,
      save_pred = TRUE,
      save_workflow = TRUE,
      parallel_over = "resamples"
    )
  )

# Stop cluster if parallel
if (exists("cl")) {
  stopCluster(cl)
}

# Save results immediately
saveRDS(bayes_results, "[output_folder]/bayesian_results.rds")
cat("\n✓ Bayesian optimization complete!\n")
```

### 6. Analyze Results

"**Analyzing optimization results...**"

```r
# Extract performance metrics
bayes_metrics <- collect_metrics(bayes_results)

# Best configurations
best_configs <- bayes_results %>%
  show_best(metric = "[target_metric]", n = 10)

# Display top 10
cat("\n**Top 10 Configurations:**\n")
print(best_configs, n = 10)

# Best single configuration
best_params <- select_best(bayes_results, metric = "[target_metric]")

cat("\n**Best Parameters Found:**\n")
print(best_params)

# Performance statistics
best_performance <- best_configs %>%
  slice(1) %>%
  pull(mean)

cat("\n**Best Performance:**\n")
cat(toupper("[target_metric]"), "=", round(best_performance, 4), "\n")
```

**Present results to user:**

"**Bayesian Optimization Results:**

**Top 10 Configurations:**

[table of best_configs]

**Best Configuration:**

[best_params with performance]

**Performance Summary:**
- Best [metric]: [value]
- Standard Error: [std_err]
- Improvement over baseline: [if baseline available]"

### 7. Visualize Optimization Trajectory

"**Generating optimization visualizations...**"

```r
library(ggplot2)

# 1. Optimization trajectory
trajectory_plot <- bayes_results %>%
  collect_metrics() %>%
  ggplot(aes(x = .iter, y = mean)) +
  geom_line(alpha = 0.5) +
  geom_point(aes(color = .iter <= bayes_config$initial), size = 2) +
  geom_smooth(se = TRUE, method = "loess", span = 0.5) +
  scale_color_manual(
    values = c("TRUE" = "red", "FALSE" = "blue"),
    labels = c("TRUE" = "Initial Design", "FALSE" = "Bayesian Optimization"),
    name = "Phase"
  ) +
  labs(
    title = "Bayesian Optimization Trajectory",
    subtitle = paste("Best", toupper("[metric]"), "=", round(best_performance, 4)),
    x = "Iteration",
    y = toupper("[metric]")
  ) +
  theme_minimal()

ggsave(
  "[output_folder]/bayesian_trajectory.png",
  trajectory_plot,
  width = 10,
  height = 6,
  dpi = 300
)

# 2. Parameter exploration (for top 2 most important parameters)
if (length(metadata$parameters_tuned) >= 2) {
  param1 <- metadata$parameters_tuned[1]
  param2 <- metadata$parameters_tuned[2]

  param_explore <- bayes_results %>%
    collect_metrics() %>%
    ggplot(aes_string(x = param1, y = param2, color = "mean", size = "mean")) +
    geom_point(alpha = 0.6) +
    scale_color_viridis_c() +
    labs(
      title = "Parameter Space Exploration",
      subtitle = paste("Color/size =", toupper("[metric]")),
      color = toupper("[metric]"),
      size = toupper("[metric]")
    ) +
    theme_minimal()

  ggsave(
    "[output_folder]/parameter_exploration.png",
    param_explore,
    width = 10,
    height = 6,
    dpi = 300
  )
}

# 3. Performance distribution
perf_dist <- bayes_results %>%
  collect_metrics() %>%
  ggplot(aes(x = mean)) +
  geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7) +
  geom_vline(xintercept = best_performance, color = "red", linetype = "dashed", size = 1) +
  labs(
    title = "Performance Distribution",
    subtitle = paste("Red line = best", toupper("[metric]")),
    x = toupper("[metric]"),
    y = "Count"
  ) +
  theme_minimal()

ggsave(
  "[output_folder]/performance_distribution.png",
  perf_dist,
  width = 8,
  height = 6,
  dpi = 300
)

cat("\n✓ Plots saved to", "[output_folder]\n")
```

**Show plots to user:**

"**Optimization Visualizations Generated:**

1. **Bayesian Trajectory** — Shows improvement over iterations
   - Red points: Initial random design
   - Blue points: Bayesian optimization
   - Smooth line: Overall trend

2. **Parameter Exploration** — Shows which parameter regions were tested
   - Color/size indicate performance

3. **Performance Distribution** — Histogram of all configurations tested
   - Red line: Best configuration

[Display plots]"

### 8. Check Convergence

"**Checking optimization convergence...**"

```r
# Calculate convergence metrics
last_10_iters <- bayes_metrics %>%
  arrange(desc(.iter)) %>%
  slice(1:10)

improvement_last_10 <- max(last_10_iters$mean) - min(last_10_iters$mean)

converged <- improvement_last_10 < 0.001  # Threshold depends on metric

cat("**Convergence Analysis:**\n")
cat("- Last 10 iterations improvement:", round(improvement_last_10, 6), "\n")
cat("- Converged:", ifelse(converged, "YES ✓", "NO - consider more iterations"), "\n")
```

**Present convergence analysis:**

"**Convergence Status:**

- **Improvement in last 10 iterations:** [improvement_last_10]
- **Assessment:** [converged or not converged with explanation]

**Recommendations:**

[IF CONVERGED:]
✓ Optimization has converged - we've likely found optimal region
✓ Confident in best parameters found
✓ Ready to proceed to racing methods

[IF NOT CONVERGED:]
⚠️ Optimization still improving - more iterations might help
⚠️ Options:
  - Extend optimization (add 25-50 more iterations)
  - Proceed anyway (current best is still good)
  - Narrow search space around best region

**What would you like to do?**
- [NEXT] Proceed to Step 3 (Racing Methods)
- [EXTEND] Run more Bayesian iterations
- [ANALYZE] Deeper analysis of current results"

### 9. Save Complete Results

```r
# Save best parameters
saveRDS(best_params, "[output_folder]/best_params_bayesian.rds")

# Save performance summary
perf_summary <- tibble(
  method = "Bayesian Optimization",
  iterations = bayes_config$iter + bayes_config$initial,
  best_metric = best_performance,
  best_std_err = best_configs$std_err[1],
  converged = converged,
  date_completed = Sys.time()
)
write_csv(perf_summary, "[output_folder]/bayesian_summary.csv")

# Save full tuning history
tuning_history <- bayes_results %>%
  collect_metrics() %>%
  arrange(desc(mean))

write_csv(tuning_history, "[output_folder]/bayesian_history.csv")

cat("\n✓ All results saved to", "[output_folder]\n")
```

### 10. Generate Step Summary

"**Step 2 Complete: Bayesian Optimization Finished**

**Summary:**
- **Iterations Completed:** [total_iters]
- **Best [metric]:** [best_performance] ± [std_err]
- **Convergence:** [status]
- **Time Elapsed:** [time]

**Best Parameters:**
[best_params formatted]

**Files Saved:**
- `bayesian_results.rds` — Complete tuning results
- `best_params_bayesian.rds` — Best parameters object
- `bayesian_trajectory.png` — Optimization plot
- `parameter_exploration.png` — Parameter space visualization
- `performance_distribution.png` — Performance histogram
- `bayesian_summary.csv` — Performance metrics
- `bayesian_history.csv` — All iterations

**Key Insights:**
[1-3 bullet points about what was learned]

---

**Ready for Step 3: Racing Methods?**

Racing will test the top configurations with early stopping for efficiency. This can validate our best parameters and potentially find alternatives that are nearly as good but more robust.

Type **NEXT** to continue, **EXTEND** for more Bayesian iterations, or **ANALYZE** for deeper exploration."

### 11. Handle User Decision

**IF NEXT:**
- Load `./step-03-racing.md`

**IF EXTEND:**
- Add 25-50 more iterations
- Rerun from step 5
- Append results to existing

**IF ANALYZE:**
- Provide deeper parameter importance analysis
- Show interaction plots
- Generate additional diagnostics

---

## SUCCESS METRICS

✅ Search space loaded from Step 1
✅ Bayesian optimization executed successfully
✅ All iterations completed without errors
✅ Best parameters identified and saved
✅ Optimization trajectory visualized
✅ Convergence assessed
✅ Results documented and saved
✅ User understands performance improvements

---

## FAILURE MODES TO AVOID

❌ Running without loading Step 1 configuration
❌ Not setting seed (irreproducible)
❌ Ignoring convergence (premature stopping)
❌ Overfitting to CV folds (unrealistic performance)
❌ Not saving intermediate results (lost work if crash)
❌ Missing visualization (no insights from trajectory)

---

## BAYESIAN OPTIMIZATION TIPS

**How It Works:**

Bayesian optimization builds a probabilistic model (Gaussian Process) of the objective function (your metric). It uses this model to decide which parameters to try next by balancing:

- **Exploitation:** Try parameters near known good configurations
- **Exploration:** Try unexplored regions that might be better

**Acquisition Functions:**

- **Expected Improvement (EI):** Best general choice, balances exploration/exploitation
- **Confidence Bound (CB):** More exploratory, good for noisy objectives
- **Probability of Improvement (PI):** More conservative, focuses on guaranteed gains

**When to Extend:**

Extend if:
- Performance still improving in last 10 iterations
- Best parameters are at search space boundaries (need wider range)
- High variance in top configurations (need more data)

**When to Stop:**

Stop if:
- No improvement in last 10-15 iterations
- Performance plateau reached
- Computational budget exhausted
- Good enough performance achieved

---

## NEXT STEP

Once satisfied with Bayesian optimization results, load `./step-03-racing.md` to apply efficient racing methods for validation and robustness testing.
