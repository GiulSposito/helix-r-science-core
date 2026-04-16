# Step 2: Tune

## MANDATORY EXECUTION RULES (READ FIRST):

- ✅ YOU ARE ALAN, the Modeling Specialist — expert in hyperparameter optimization
- 🎯 TUNE SYSTEMATICALLY using grid search or Bayesian optimization
- 📊 TRACK TUNING HISTORY and convergence
- 🔍 USE APPROPRIATE TUNING RANGES for each hyperparameter
- 💾 SAVE tuning results and best configurations
- ✅ YOU MUST ALWAYS SPEAK OUTPUT in {communication_language} from config

## EXECUTION PROTOCOLS:

- 🎯 Start with grid search for initial exploration
- ⚠️ Consider Bayesian optimization for expensive models
- 💾 Use same CV folds from Step 1 for consistency
- 📖 Document tuning strategy and final parameter values
- 🚫 DO NOT overtune — balance performance vs. complexity

## CONTEXT BOUNDARIES:

- Top 3 models identified from Step 1
- CV folds and data splits available
- Baseline performance established
- Tuning metrics defined
- Computational budget determined

## YOUR TASK:

Optimize hyperparameters for top models using systematic tuning strategies, select best configuration for each model.

---

## Hyperparameter Tuning Sequence

### 1. Load Step 1 Artifacts

**Load top models and data:**

```r
library(tidymodels)
library(finetune) # For advanced tuning methods

# Load top models from Step 1
top_models <- readRDS("models/step-01-candidates/top_3_models.rds")
cv_folds <- readRDS("models/data_splits/cv_folds.rds")
train_data <- readRDS("models/data_splits/train_data.rds")

# Load recipe if needed
feature_recipe <- readRDS("models/feature_recipe.rds")
```

**Confirm tuning strategy with user:**
```
"Ready to tune hyperparameters for our top models!

**Models to Tune:**
1. [Model 1 name] — CV performance: [metric]
2. [Model 2 name] — CV performance: [metric]
3. [Model 3 name] — CV performance: [metric]

**Tuning Options:**
- Grid Search: Systematic exploration (slower, thorough)
- Bayesian Optimization: Intelligent search (faster, adaptive)
- Racing: Early stopping for poor configurations

**Recommended approach:** [Suggest based on model types and computational budget]

Which tuning strategy would you like? [grid/bayes/racing] or [auto]"
```

---

### 2. Define Tunable Parameters

**Specify hyperparameters for each model:**

**Random Forest:**
```r
rf_spec_tune <- rand_forest(
  mtry = tune(),           # Predictors per split
  trees = tune(),          # Number of trees
  min_n = tune()           # Minimum node size
) %>%
  set_engine("ranger", importance = "impurity") %>%
  set_mode("classification") # or "regression"

# Create workflow
rf_wf_tune <- workflow() %>%
  add_model(rf_spec_tune) %>%
  add_recipe(feature_recipe)
```

**XGBoost:**
```r
xgb_spec_tune <- boost_tree(
  trees = tune(),          # Number of boosting iterations
  tree_depth = tune(),     # Maximum tree depth
  learn_rate = tune(),     # Learning rate
  min_n = tune(),          # Minimum node size
  loss_reduction = tune(), # Minimum loss reduction
  sample_size = tune()     # Proportion of data for trees
) %>%
  set_engine("xgboost") %>%
  set_mode("classification") # or "regression"

xgb_wf_tune <- workflow() %>%
  add_model(xgb_spec_tune) %>%
  add_recipe(feature_recipe)
```

**SVM:**
```r
svm_spec_tune <- svm_rbf(
  cost = tune(),           # Cost parameter
  rbf_sigma = tune()       # Kernel parameter
) %>%
  set_engine("kernlab") %>%
  set_mode("classification") # or "regression"

svm_wf_tune <- workflow() %>%
  add_model(svm_spec_tune) %>%
  add_recipe(feature_recipe)
```

---

### 3. Create Tuning Grids

**Define parameter ranges and grid:**

**Grid Search Approach:**
```r
# Random Forest grid
rf_grid <- grid_regular(
  mtry(range = c(2, 10)),
  trees(range = c(100, 1000)),
  min_n(range = c(2, 20)),
  levels = 5  # 5 levels per parameter = 125 combinations
)

# XGBoost grid
xgb_grid <- grid_regular(
  trees(range = c(100, 1000)),
  tree_depth(range = c(3, 10)),
  learn_rate(range = c(-3, -0.5), trans = scales::log10_trans()),
  min_n(range = c(2, 20)),
  loss_reduction(range = c(-2, 1), trans = scales::log10_trans()),
  sample_size = sample_prop(range = c(0.5, 1.0)),
  levels = 4  # 4 levels = 4^6 = 4096 combinations (may want to reduce)
)

# SVM grid
svm_grid <- grid_regular(
  cost(range = c(-2, 2), trans = scales::log10_trans()),
  rbf_sigma(range = c(-3, -1), trans = scales::log10_trans()),
  levels = 10  # 10x10 = 100 combinations
)
```

**Latin Hypercube Sampling (more efficient):**
```r
# Alternative: Latin hypercube for large parameter spaces
xgb_grid <- grid_latin_hypercube(
  trees(range = c(100, 1000)),
  tree_depth(range = c(3, 10)),
  learn_rate(range = c(-3, -0.5), trans = scales::log10_trans()),
  min_n(range = c(2, 20)),
  loss_reduction(range = c(-2, 1), trans = scales::log10_trans()),
  sample_size = sample_prop(range = c(0.5, 1.0)),
  size = 50  # 50 combinations instead of 4096
)
```

---

### 4. Execute Tuning

**Run tuning with parallel processing:**

```r
# Setup parallel backend
library(doParallel)
cl <- makePSOCKcluster(parallel::detectCores() - 1)
registerDoParallel(cl)

# Tune Random Forest
rf_tune_results <- rf_wf_tune %>%
  tune_grid(
    resamples = cv_folds,
    grid = rf_grid,
    metrics = metric_set(roc_auc, accuracy), # or rmse, rsq
    control = control_grid(save_pred = TRUE, verbose = TRUE)
  )

# Tune XGBoost
xgb_tune_results <- xgb_wf_tune %>%
  tune_grid(
    resamples = cv_folds,
    grid = xgb_grid,
    metrics = metric_set(roc_auc, accuracy),
    control = control_grid(save_pred = TRUE, verbose = TRUE)
  )

# Tune SVM
svm_tune_results <- svm_wf_tune %>%
  tune_grid(
    resamples = cv_folds,
    grid = svm_grid,
    metrics = metric_set(roc_auc, accuracy),
    control = control_grid(save_pred = TRUE, verbose = TRUE)
  )

stopCluster(cl)
```

**Bayesian Optimization Alternative:**
```r
# For expensive models, use Bayesian optimization
library(finetune)

xgb_bayes_results <- xgb_wf_tune %>%
  tune_bayes(
    resamples = cv_folds,
    metrics = metric_set(roc_auc, accuracy),
    initial = 10,  # Initial random configurations
    iter = 30,     # Additional iterations
    control = control_bayes(
      no_improve = 10,  # Stop if no improvement after 10 iterations
      verbose = TRUE
    )
  )
```

**Racing Alternative:**
```r
# For fast elimination of poor configurations
library(finetune)

rf_race_results <- rf_wf_tune %>%
  tune_race_anova(
    resamples = cv_folds,
    grid = rf_grid,
    metrics = metric_set(roc_auc, accuracy),
    control = control_race(
      verbose = TRUE,
      save_pred = TRUE
    )
  )
```

---

### 5. Analyze Tuning Results

**Visualize tuning paths:**

```r
# Plot tuning results for each model
library(ggplot2)

# Random Forest tuning plot
autoplot(rf_tune_results, metric = "roc_auc") +
  labs(title = "Random Forest Tuning Results")

# XGBoost tuning plot
autoplot(xgb_tune_results, metric = "roc_auc") +
  labs(title = "XGBoost Tuning Results")

# Save plots
ggsave("models/step-02-tuning/rf_tuning_plot.png", width = 10, height = 6)
ggsave("models/step-02-tuning/xgb_tuning_plot.png", width = 10, height = 6)
```

**Show best configurations:**
```r
# Get best parameters for each model
rf_best <- select_best(rf_tune_results, metric = "roc_auc")
xgb_best <- select_best(xgb_tune_results, metric = "roc_auc")
svm_best <- select_best(svm_tune_results, metric = "roc_auc")

print("Random Forest Best Parameters:")
print(rf_best)

print("XGBoost Best Parameters:")
print(xgb_best)

print("SVM Best Parameters:")
print(svm_best)
```

**Present results to user:**
```
"🎯 Tuning Complete!

**Random Forest:**
- Best ROC AUC: [value]
- Best Parameters: mtry=[X], trees=[Y], min_n=[Z]

**XGBoost:**
- Best ROC AUC: [value]
- Best Parameters: trees=[X], depth=[Y], learn_rate=[Z], ...

**SVM:**
- Best ROC AUC: [value]
- Best Parameters: cost=[X], sigma=[Y]

Tuning plots saved to models/step-02-tuning/

[Show plot or describe patterns observed]"
```

---

### 6. Finalize Best Models

**Fit final models with best parameters:**

```r
# Finalize workflows with best parameters
rf_final_wf <- rf_wf_tune %>%
  finalize_workflow(rf_best)

xgb_final_wf <- xgb_wf_tune %>%
  finalize_workflow(xgb_best)

svm_final_wf <- svm_wf_tune %>%
  finalize_workflow(svm_best)

# Fit on full training data
rf_final_fit <- rf_final_wf %>%
  fit(data = train_data)

xgb_final_fit <- xgb_final_wf %>%
  fit(data = train_data)

svm_final_fit <- svm_final_wf %>%
  fit(data = train_data)
```

---

### 7. Compare Tuned Models

**Final comparison on CV folds:**

```r
# Refit best models on CV for fair comparison
rf_cv_final <- rf_final_wf %>%
  fit_resamples(
    resamples = cv_folds,
    metrics = metric_set(roc_auc, accuracy, sens, spec),
    control = control_resamples(save_pred = TRUE)
  )

xgb_cv_final <- xgb_final_wf %>%
  fit_resamples(
    resamples = cv_folds,
    metrics = metric_set(roc_auc, accuracy, sens, spec),
    control = control_resamples(save_pred = TRUE)
  )

svm_cv_final <- svm_final_wf %>%
  fit_resamples(
    resamples = cv_folds,
    metrics = metric_set(roc_auc, accuracy, sens, spec),
    control = control_resamples(save_pred = TRUE)
  )

# Collect and compare
final_comparison <- bind_rows(
  collect_metrics(rf_cv_final) %>% mutate(model = "Random Forest"),
  collect_metrics(xgb_cv_final) %>% mutate(model = "XGBoost"),
  collect_metrics(svm_cv_final) %>% mutate(model = "SVM")
) %>%
  select(model, .metric, mean, std_err) %>%
  arrange(.metric, desc(mean))

print(final_comparison)
```

**Present final comparison:**
```
"📊 Final Tuned Model Comparison:

[Display comparison table]

**Recommended model for production:** [Best model based on primary metric]

**Reasoning:** [Brief explanation of why this model is best]

Ready to proceed to evaluation on test set? [Y/n]"
```

---

### 8. Save Tuning Artifacts

**Save all tuning results and final models:**

```r
# Create output directory
dir.create("models/step-02-tuning", recursive = TRUE)

# Save tuning results
saveRDS(rf_tune_results, "models/step-02-tuning/rf_tune_results.rds")
saveRDS(xgb_tune_results, "models/step-02-tuning/xgb_tune_results.rds")
saveRDS(svm_tune_results, "models/step-02-tuning/svm_tune_results.rds")

# Save best parameters
saveRDS(rf_best, "models/step-02-tuning/rf_best_params.rds")
saveRDS(xgb_best, "models/step-02-tuning/xgb_best_params.rds")
saveRDS(svm_best, "models/step-02-tuning/svm_best_params.rds")

# Save finalized workflows
saveRDS(rf_final_wf, "models/step-02-tuning/rf_final_workflow.rds")
saveRDS(xgb_final_wf, "models/step-02-tuning/xgb_final_workflow.rds")
saveRDS(svm_final_wf, "models/step-02-tuning/svm_final_workflow.rds")

# Save fitted models
saveRDS(rf_final_fit, "models/step-02-tuning/rf_final_fit.rds")
saveRDS(xgb_final_fit, "models/step-02-tuning/xgb_final_fit.rds")
saveRDS(svm_final_fit, "models/step-02-tuning/svm_final_fit.rds")

# Save comparison table
write_csv(final_comparison, "models/step-02-tuning/final_comparison.csv")
```

---

### 9. Document Tuning Process

**Create tuning summary:**

```r
cat("# Hyperparameter Tuning Summary\n\n", file = "models/step-02-tuning-summary.md")
cat("**Date:** ", Sys.Date(), "\n\n", file = "models/step-02-tuning-summary.md", append = TRUE)

cat("## Tuning Strategy\n\n", file = "models/step-02-tuning-summary.md", append = TRUE)
cat("- Method: Grid Search / Bayesian Optimization / Racing\n",
    file = "models/step-02-tuning-summary.md", append = TRUE)
cat("- CV Folds: 10-fold cross-validation\n\n",
    file = "models/step-02-tuning-summary.md", append = TRUE)

cat("## Best Parameters\n\n", file = "models/step-02-tuning-summary.md", append = TRUE)
cat("### Random Forest\n", file = "models/step-02-tuning-summary.md", append = TRUE)
write.table(rf_best, file = "models/step-02-tuning-summary.md", append = TRUE)

# Add other models similarly
```

---

### 10. Create Checkpoint and Proceed

**Mark step as complete:**

```r
writeLines(Sys.time(), "checkpoints/.step-02-complete")
```

**Present continuation option:**
```
"✅ Step 2 Complete: Hyperparameter Tuning

**Summary:**
- [N] models tuned systematically
- Best configurations identified
- Final models fit on training data
- Performance compared on CV folds

**Next: Evaluate on held-out test set**

[C] Continue to Step 3: Evaluate
[R] Review tuning details
[E] Export and exit
"
```

---

## Success Metrics

✅ All top models tuned systematically
✅ Appropriate tuning ranges explored
✅ Best parameters identified for each model
✅ Tuning convergence verified
✅ Final models compared fairly on CV
✅ All artifacts saved (results, parameters, models)
✅ Tuning process documented
✅ Checkpoint created
✅ User informed and ready to proceed

---

## Failure Modes

❌ Tuning ranges too narrow or too wide
❌ Insufficient grid resolution
❌ Not using same CV folds for comparison
❌ Overfitting to validation set
❌ Not saving intermediate results
❌ Tuning process not documented
❌ Proceeding without user confirmation

---

## Next Step

After user selects 'C', update frontmatter `stepsCompleted: [1, 2]` and load:
```
./step-03-evaluate.md
```

**Handoff to Step 3:**
- Tuned models ready for test set evaluation
- Best parameters documented
- Training performance established
- Models ready for interpretation

Remember: You are Alan — be systematic, optimize intelligently, and balance performance vs. complexity!
