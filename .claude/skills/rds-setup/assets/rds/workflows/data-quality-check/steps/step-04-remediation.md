# Step 4: Remediation

**Goal:** Fix issues systematically and document all decisions

**Duration:** 1-2 hours

---

## Overview

Remediation is about **principled correction**, not just making problems disappear. Every decision must be:

- **Justified:** Clear reasoning for action taken
- **Documented:** Traceable record of all changes
- **Reproducible:** Can be applied to new data
- **Validated:** Confirm fix improves quality

**Critical Rule:** NEVER overwrite original data. Always create new cleaned versions.

---

## Remediation Strategy Framework

### Decision Tree

```
For each quality issue:
  │
  ├─> Is it definitely an error? (impossible value, business rule violation)
  │   ├─> YES: Can it be corrected?
  │   │   ├─> YES: AUTO-CORRECT (with logging)
  │   │   └─> NO: REMOVE or FLAG
  │   └─> NO: Is it an extreme value?
  │       ├─> YES: FLAG for sensitivity analysis
  │       └─> NO: KEEP with documentation
  │
  └─> Impact of keeping vs removing?
      ├─> High impact: MANUAL REVIEW required
      └─> Low impact: Apply standard strategy
```

---

## Remediation Actions

### 1. Missing Data Remediation

Based on Step 1 (Missing Analysis) findings:

```r
library(dplyr)
library(mice)

# Load missing analysis results
missing_summary <- readRDS("missing_summary.rds")

# Strategy 1: Listwise deletion (MCAR, <5% missing)
if (missing_summary$mechanism_hypothesis == "MCAR" &&
    missing_summary$complete_case_rate > 0.95) {

  data_cleaned <- data %>%
    filter(complete.cases(.))

  cat(sprintf("Listwise deletion: removed %d cases (%.1f%%)\n",
              nrow(data) - nrow(data_cleaned),
              (nrow(data) - nrow(data_cleaned)) / nrow(data) * 100))
}

# Strategy 2: Simple imputation (MCAR/MAR, numeric, 5-15% missing)
data_cleaned <- data %>%
  mutate(
    across(
      where(is.numeric) & where(~mean(is.na(.)) < 0.15),
      ~replace_na(.x, median(.x, na.rm = TRUE)),
      .names = "{.col}"
    )
  )

# Strategy 3: Multiple imputation (MAR, >15% missing)
if (missing_summary$mechanism_hypothesis == "MAR") {

  # Specify imputation model
  imp <- mice(data, m = 5, method = "pmm", seed = 123, print = FALSE)

  # Get completed dataset (using first imputation for now)
  data_cleaned <- complete(imp, 1)

  # For analysis, pool results across all 5 imputations
  # (This requires running your analysis on each imputed dataset)
}

# Strategy 4: Create missingness indicator (MNAR or informative)
data_cleaned <- data %>%
  mutate(
    across(
      everything(),
      ~if_else(is.na(.x), 1, 0),
      .names = "missing_{.col}"
    )
  )

# Strategy 5: Drop variable (>40% missing, not critical)
high_missing_vars <- missing_summary$high_missing_vars %>%
  filter(pct_miss > 40) %>%
  pull(variable)

data_cleaned <- data %>%
  select(-all_of(high_missing_vars))

cat(sprintf("Dropped %d variables with >40%% missing\n", length(high_missing_vars)))
```

**Document your strategy:**

```r
missing_remediation_log <- tibble(
  variable = names(data),
  pct_missing = colMeans(is.na(data)) * 100,
  mechanism = missing_summary$mechanism_hypothesis,
  strategy = case_when(
    pct_missing < 5 ~ "Listwise deletion",
    pct_missing < 15 ~ "Median imputation",
    pct_missing < 40 ~ "Multiple imputation",
    TRUE ~ "Variable dropped"
  ),
  justification = "Based on missing analysis Step 1"
)
```

---

### 2. Outlier Remediation

Based on Step 2 (Outlier Detection) findings:

```r
# Load outlier analysis results
outlier_summary <- readRDS("outlier_summary.rds")
data_with_flags <- readRDS("data_with_outlier_flags.rds")

# Strategy 1: Remove confirmed errors (domain violations)
errors_to_remove <- data_with_flags %>%
  filter(outlier_method == "domain_rule")

data_cleaned <- data_with_flags %>%
  anti_join(errors_to_remove, by = "id")

cat(sprintf("Removed %d confirmed errors\n", nrow(errors_to_remove)))

# Strategy 2: Winsorize extreme values (cap at percentiles)
data_cleaned <- data_cleaned %>%
  mutate(
    across(
      where(is.numeric),
      ~pmin(pmax(.x, quantile(.x, 0.01, na.rm = TRUE)),
            quantile(.x, 0.99, na.rm = TRUE)),
      .names = "{.col}"
    )
  )

# Strategy 3: Transform skewed distributions
data_cleaned <- data_cleaned %>%
  mutate(
    income_log = log1p(income), # log transform for right skew
    response_time_sqrt = sqrt(response_time) # sqrt for moderate skew
  )

# Strategy 4: Flag but keep (for sensitivity analysis)
data_cleaned <- data_cleaned %>%
  mutate(
    extreme_value_flag = outlier_flag & outlier_method != "domain_rule"
  )

# Strategy 5: Create separate analysis for outliers
outlier_subset <- data_with_flags %>%
  filter(outlier_flag)

# Analyze with and without outliers
saveRDS(outlier_subset, "outlier_subset_for_sensitivity.rds")
```

**Document your strategy:**

```r
outlier_remediation_log <- outlier_summary$consensus %>%
  left_join(data_with_flags %>% select(row_id, outlier_method), by = "row_id") %>%
  mutate(
    action = case_when(
      domain_flag ~ "Removed (domain violation)",
      consensus_score >= 3 ~ "Winsorized (multiple methods)",
      multivariate_flag ~ "Flagged (sensitivity analysis)",
      TRUE ~ "Kept"
    )
  )
```

---

### 3. Consistency Remediation

Based on Step 3 (Consistency Checks) findings:

```r
# Load consistency analysis results
all_violations <- readRDS("consistency_violations.rds")
data_for_remediation <- readRDS("data_for_remediation.rds")

# Strategy 1: Auto-correct derivable values
data_cleaned <- data_for_remediation %>%
  mutate(
    # Swap dates if end < start
    correct_start = pmin(start_date, end_date, na.rm = TRUE),
    correct_end = pmax(start_date, end_date, na.rm = TRUE),
    start_date = correct_start,
    end_date = correct_end,

    # Calculate totals from parts
    total_calculated = rowSums(across(starts_with("part_")), na.rm = TRUE),
    total = if_else(is.na(total) | abs(total - total_calculated) > 0.01,
                    total_calculated, total),

    # Derive age from birth_date
    age_derived = as.numeric(difftime(Sys.Date(), birth_date, units = "days")) / 365.25,
    age = if_else(is.na(age) | abs(age - age_derived) > 1,
                  round(age_derived), age)
  ) %>%
  select(-correct_start, -correct_end, -total_calculated, -age_derived)

# Strategy 2: Standardize formats
data_cleaned <- data_cleaned %>%
  mutate(
    # Standardize ID formats
    id = str_pad(id, width = 8, pad = "0"),
    product_id = paste0("PRD-", product_id),

    # Standardize text fields
    category = str_to_title(category),
    country_code = str_to_upper(country_code)
  )

# Strategy 3: Remove records with critical violations
critical_violations <- data_for_remediation %>%
  filter(consistency_score < 50)

data_cleaned <- data_cleaned %>%
  anti_join(critical_violations, by = "id")

cat(sprintf("Removed %d records with critical violations\n",
            nrow(critical_violations)))

# Strategy 4: Flag medium violations
data_cleaned <- data_cleaned %>%
  mutate(
    quality_flag = consistency_score < 80,
    quality_level = case_when(
      consistency_score >= 95 ~ "High",
      consistency_score >= 80 ~ "Medium",
      consistency_score >= 50 ~ "Low",
      TRUE ~ "Critical"
    )
  )
```

**Document your strategy:**

```r
consistency_remediation_log <- data_for_remediation %>%
  mutate(
    action_taken = case_when(
      id %in% critical_violations$id ~ "Removed (consistency <50%)",
      consistency_score < 80 ~ "Flagged (consistency <80%)",
      action == "Auto-correct" ~ "Auto-corrected",
      TRUE ~ "No action"
    )
  ) %>%
  select(id, consistency_score, action_taken)
```

---

## Validation

Verify remediation improved quality:

```r
# Quality metrics before and after
quality_comparison <- tibble(
  metric = c(
    "Complete cases",
    "Missing values",
    "Outliers (domain)",
    "Outliers (statistical)",
    "Consistency violations",
    "High quality records (>95%)"
  ),
  before = c(
    mean(complete.cases(data)) * 100,
    mean(is.na(data)) * 100,
    sum(data_with_flags$outlier_method == "domain_rule", na.rm = TRUE),
    sum(data_with_flags$outlier_flag, na.rm = TRUE),
    sum(data_for_remediation$consistency_score < 100, na.rm = TRUE),
    sum(data_for_remediation$consistency_score >= 95, na.rm = TRUE)
  ),
  after = c(
    mean(complete.cases(data_cleaned)) * 100,
    mean(is.na(data_cleaned)) * 100,
    0, # Domain violations removed
    sum(data_cleaned$extreme_value_flag, na.rm = TRUE),
    sum(data_cleaned$quality_flag, na.rm = TRUE),
    sum(data_cleaned$quality_level == "High", na.rm = TRUE)
  ),
  improvement = after - before
)

print(quality_comparison)
```

---

## Documentation

### Comprehensive Remediation Log

Create `remediation_log.md`:

```r
# Consolidate all logs
remediation_log <- list(
  summary = list(
    original_rows = nrow(data),
    cleaned_rows = nrow(data_cleaned),
    rows_removed = nrow(data) - nrow(data_cleaned),
    pct_removed = (nrow(data) - nrow(data_cleaned)) / nrow(data) * 100,
    original_cols = ncol(data),
    cleaned_cols = ncol(data_cleaned),
    timestamp = Sys.time()
  ),
  missing_remediation = missing_remediation_log,
  outlier_remediation = outlier_remediation_log,
  consistency_remediation = consistency_remediation_log,
  quality_comparison = quality_comparison,
  removed_ids = list(
    errors = errors_to_remove$id,
    low_consistency = critical_violations$id
  )
)

saveRDS(remediation_log, "remediation_log.rds")

# Generate markdown report
remediation_md <- glue::glue("
# Data Quality Remediation Log

**Date:** {Sys.Date()}
**Analyst:** {user_name}
**Project:** {project_name}

---

## Summary

- **Original dataset:** {remediation_log$summary$original_rows} rows × {remediation_log$summary$original_cols} columns
- **Cleaned dataset:** {remediation_log$summary$cleaned_rows} rows × {remediation_log$summary$cleaned_cols} columns
- **Rows removed:** {remediation_log$summary$rows_removed} ({round(remediation_log$summary$pct_removed, 2)}%)

---

## Actions Taken

### Missing Data
{nrow(missing_remediation_log)} variables processed
- Listwise deletion: {sum(missing_remediation_log$strategy == 'Listwise deletion')} variables
- Imputation: {sum(grepl('imputation', missing_remediation_log$strategy))} variables
- Dropped: {sum(missing_remediation_log$strategy == 'Variable dropped')} variables

### Outliers
{nrow(outlier_remediation_log)} cases evaluated
- Removed (errors): {sum(grepl('Removed', outlier_remediation_log$action))}
- Winsorized: {sum(grepl('Winsorized', outlier_remediation_log$action))}
- Flagged: {sum(grepl('Flagged', outlier_remediation_log$action))}

### Consistency
{nrow(consistency_remediation_log)} records checked
- Auto-corrected: {sum(grepl('Auto-corrected', consistency_remediation_log$action_taken))}
- Removed: {sum(grepl('Removed', consistency_remediation_log$action_taken))}
- Flagged: {sum(grepl('Flagged', consistency_remediation_log$action_taken))}

---

## Quality Improvement

```
{paste(capture.output(print(quality_comparison)), collapse = '\n')}
```

---

## Files Generated

- `data_cleaned.rds` — Cleaned dataset
- `remediation_log.rds` — Detailed remediation log
- `removed_cases.csv` — Cases removed with reasons
- `flagged_cases.csv` — Cases flagged for monitoring

---

## Recommendations

1. Use `data_cleaned.rds` for all downstream analysis
2. Monitor flagged cases for data quality trends
3. Investigate root causes of removed errors
4. Update data collection process to prevent recurrence

---

_Generated by Ada (RDS Module) on {Sys.time()}_
")

writeLines(remediation_md, "remediation_log.md")
```

---

### Case-Level Documentation

Export detailed case information:

```r
# Cases removed
removed_cases <- bind_rows(
  errors_to_remove %>%
    mutate(removal_reason = "Domain rule violation (outlier)"),
  critical_violations %>%
    mutate(removal_reason = "Consistency score < 50%")
)

write_csv(removed_cases, "removed_cases.csv")

# Cases flagged
flagged_cases <- data_cleaned %>%
  filter(quality_flag | extreme_value_flag) %>%
  mutate(
    flag_reason = case_when(
      extreme_value_flag & quality_flag ~ "Outlier + Low consistency",
      extreme_value_flag ~ "Statistical outlier (not error)",
      quality_flag ~ "Consistency score < 80%"
    )
  )

write_csv(flagged_cases, "flagged_cases.csv")
```

---

## Final Quality Report

Generate comprehensive `data_quality_report.html`:

```r
library(rmarkdown)

# Prepare report data
report_data <- list(
  data_original = data,
  data_cleaned = data_cleaned,
  missing_summary = missing_summary,
  outlier_summary = outlier_summary,
  consistency_violations = all_violations,
  remediation_log = remediation_log,
  quality_comparison = quality_comparison
)

# Generate report
render(
  input = system.file("templates", "quality_report.Rmd", package = "rds"),
  output_file = "data_quality_report.html",
  params = list(data = report_data)
)
```

**Report Sections:**

1. **Executive Summary**
   - Overall quality score
   - Key findings
   - Remediation summary

2. **Missing Data Analysis**
   - Missing patterns (from Step 1)
   - Mechanism assessment
   - Remediation strategy

3. **Outlier Analysis**
   - Detection results (from Step 2)
   - Outlier visualizations
   - Remediation actions

4. **Consistency Analysis**
   - Violation summary (from Step 3)
   - Consistency scores
   - Auto-corrections applied

5. **Remediation Summary**
   - Actions taken
   - Quality improvement metrics
   - Flagged cases for monitoring

6. **Recommendations**
   - Data collection improvements
   - Validation rules to add
   - Monitoring strategy

---

## Save Cleaned Data

```r
# Save cleaned dataset
saveRDS(data_cleaned, "data_cleaned.rds")
write_csv(data_cleaned, "data_cleaned.csv")

# Save quality metrics
data_quality_metrics <- list(
  missing_rate = mean(is.na(data_cleaned)),
  complete_case_rate = mean(complete.cases(data_cleaned)),
  outlier_rate = mean(data_cleaned$extreme_value_flag, na.rm = TRUE),
  low_quality_rate = mean(data_cleaned$quality_flag, na.rm = TRUE),
  high_quality_rate = mean(data_cleaned$quality_level == "High", na.rm = TRUE)
)

saveRDS(data_quality_metrics, "data_quality_metrics.rds")
```

---

## Ada's Final Checklist

{user_name}, before finishing:

- ✅ All quality issues addressed (removed, corrected, or flagged)
- ✅ Every decision documented with justification
- ✅ Original data preserved (never overwritten)
- ✅ Cleaned data validated (quality improved)
- ✅ Comprehensive report generated
- ✅ Removed/flagged cases exported
- ✅ Quality metrics computed
- ✅ Reproducible script created

---

## Red Flags

**STOP if:**
- ❌ Removed >20% of data (too aggressive, investigate root causes)
- ❌ Quality didn't improve (remediation ineffective)
- ✅ Critical business rules still violated
- ❌ Flagged cases not documented
- ❌ Cannot explain remediation decisions

---

## Next Steps

After completing remediation:

1. **Proceed to analysis** using `data_cleaned.rds`
2. **Run sensitivity analysis** on flagged cases
3. **Monitor data quality** in production
4. **Fix upstream issues** to prevent recurrence
5. **Update validation rules** based on findings

---

## Integration with RDS Workflow

Return to main RDS workflow at:
- **Phase 4: EDA** — Explore cleaned data
- **Phase 5: Feature Engineering** — Transform quality data
- **Phase 6: Modeling** — Build on solid foundation

Quality data = quality insights. You've invested 4-8 hours ensuring your analysis rests on reliable data.

---

**Ada's Final Word:** Data quality work is often invisible—until it's not. The downstream analyses, models, and decisions all depend on the foundation you've built here. Well done, {user_name}.

---

_Step created on 2026-03-17 for data-quality-check workflow_
