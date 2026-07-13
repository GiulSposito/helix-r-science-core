# Step 1: Missing Analysis

**Goal:** Identify missing data patterns and mechanisms (MCAR, MAR, MNAR)

**Duration:** 1-2 hours

---

## Overview

Missing data is rarely random. Understanding **why** data is missing is crucial for choosing appropriate handling strategies. This step systematically analyzes missing patterns using visualization and statistical tests.

### Missing Data Mechanisms

1. **MCAR (Missing Completely At Random):** Missingness unrelated to any variable
   - *Example:* Lab equipment randomly fails
   - *Handling:* Safe to delete or use simple imputation

2. **MAR (Missing At Random):** Missingness related to observed variables
   - *Example:* Older patients less likely to report income
   - *Handling:* Multiple imputation conditioned on observed variables

3. **MNAR (Missing Not At Random):** Missingness related to unobserved values
   - *Example:* High earners refuse to report income
   - *Handling:* Requires domain knowledge, sensitivity analysis

---

## Analysis Steps

### 1. Compute Missing Proportions

```r
library(dplyr)
library(naniar)
library(visdat)

# Overall missing summary
miss_var_summary(data)

# Missing by variable
missing_props <- data %>%
  miss_var_summary() %>%
  arrange(desc(pct_miss))

# Variables with >5% missing
high_missing <- missing_props %>%
  filter(pct_miss > 5)

print(high_missing)
```

**Questions for {user_name}:**
- Are any variables above your acceptable missing threshold?
- Which variables are critical for your analysis?

---

### 2. Visualize Missing Patterns

```r
# Overview visualization
vis_miss(data, warn_large_data = FALSE)

# Missing pattern plot
gg_miss_upset(data, nsets = 10)

# Missing by groups (if applicable)
# Example: missing by category
gg_miss_fct(data, fct = your_grouping_variable)
```

**Interpretation Guide:**
- **Clusters:** Do certain combinations of variables have missing values together?
- **Patterns:** Are there systematic missing patterns (e.g., entire rows, blocks)?
- **Groups:** Does missingness differ by categories?

---

### 3. Test for MCAR

```r
# Little's MCAR test (requires complete subset)
# Note: Requires naniar or BaylorEdPsych package

# Simplified approach: compare characteristics of complete vs incomplete cases
complete_cases <- data %>% filter(complete.cases(.))
incomplete_cases <- data %>% filter(!complete.cases(.))

# Compare on key variables
# Example for numeric variable
t.test(complete_cases$age, incomplete_cases$age)

# Example for categorical variable
chisq.test(table(data$category, is.na(data$target_var)))
```

**Null Hypothesis:** Data is MCAR
**Interpretation:**
- p > 0.05: Cannot reject MCAR (proceed with caution)
- p < 0.05: Data is NOT MCAR (MAR or MNAR likely)

---

### 4. Identify MAR/MNAR Patterns

```r
# Create missingness indicators
data_with_flags <- data %>%
  mutate(
    across(
      everything(),
      ~as.integer(is.na(.)),
      .names = "missing_{.col}"
    )
  )

# Explore relationships between missingness and other variables
# Example: Is income more likely missing for certain age groups?
data %>%
  mutate(income_missing = is.na(income)) %>%
  group_by(age_group) %>%
  summarise(pct_missing = mean(income_missing) * 100)

# Correlation between missingness indicators
missing_flags <- data_with_flags %>%
  select(starts_with("missing_"))

cor(missing_flags) %>%
  corrplot::corrplot(method = "circle")
```

**Look For:**
- Do certain groups have systematically higher missing rates? (suggests MAR)
- Are missing patterns correlated with sensitive topics? (suggests MNAR)

---

### 5. Assess Impact

```r
# How much data would be lost with listwise deletion?
complete_rate <- mean(complete.cases(data))
cat(sprintf("Complete cases: %.1f%%\n", complete_rate * 100))

# Impact by outcome variable (if applicable)
data %>%
  mutate(has_outcome = !is.na(outcome_variable)) %>%
  group_by(has_outcome) %>%
  summarise(
    n = n(),
    across(where(is.numeric), ~mean(is.na(.)) * 100, .names = "pct_miss_{.col}")
  )
```

---

## Decision Framework

Based on your analysis, decide on handling strategies:

| Pattern | Mechanism | % Missing | Strategy |
|---------|-----------|-----------|----------|
| Random, no clusters | Likely MCAR | <5% | Listwise deletion acceptable |
| Random, no clusters | Likely MCAR | 5-10% | Simple imputation (mean/median) |
| Group differences | MAR | 10-20% | Multiple imputation |
| Sensitive variables | Possible MNAR | Any | Flag + sensitivity analysis |
| Entire variables | Unknown | >40% | Consider dropping variable |

---

## Deliverables

### Missing Analysis Report

Create `missing_analysis.html`:

```r
library(rmarkdown)

# Generate report
render("missing_analysis.Rmd", output_file = "missing_analysis.html")
```

**Report Contents:**
1. Missing proportions table
2. Missing pattern visualizations
3. MCAR test results
4. MAR/MNAR evidence
5. Impact assessment
6. Recommended strategies

---

## Ada's Guidance

{user_name}, I'll help you interpret the results:

### Critical Questions

1. **What's the acceptable missing rate for your project?**
   - Exploratory: 20-30% may be acceptable
   - Confirmatory: <10% preferred
   - Production: <5% strongly recommended

2. **Are complete cases representative?**
   - Compare demographics, key variables
   - If systematically different, deletion introduces bias

3. **Do you have auxiliary variables for imputation?**
   - MAR can be handled IF you have variables that predict missingness
   - More auxiliary variables = better imputation

4. **Can you collect more data?**
   - Sometimes the best solution is going back to the source
   - Especially if key variables have high missingness

---

## Red Flags

**STOP and investigate if:**
- ❌ Missingness >50% on critical variables
- ❌ Entire blocks of data missing (systematic collection failure)
- ❌ Missingness perfectly correlated with outcome (selection bias)
- ❌ Different missing patterns in train vs test data

---

## Output for Next Step

Document your findings:

```r
# Create summary object
missing_summary <- list(
  high_missing_vars = high_missing,
  mcar_test_result = mcar_test,
  complete_case_rate = complete_rate,
  mechanism_hypothesis = "MCAR/MAR/MNAR", # Your assessment
  recommended_strategy = "deletion/imputation/mixed"
)

# Save for remediation step
saveRDS(missing_summary, "missing_summary.rds")
```

---

## Next Step

Proceed to **Step 2: Outlier Detection** when:
- You understand the missing data mechanism
- You've documented findings in missing_analysis.html
- You know which strategy you'll apply in Step 4 (Remediation)

---

**Ada's Tip:** Missing data analysis is not optional. Ignoring the mechanism can lead to biased estimates, invalid confidence intervals, and wrong conclusions. Take the time to understand your missing data.

---

_Step created on 2026-03-17 for data-quality-check workflow_
