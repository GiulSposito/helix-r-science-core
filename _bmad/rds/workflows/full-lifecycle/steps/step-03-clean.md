# Phase 3: Clean Data

**Owner:** Ada (Project Architect)
**Duration:** 2-4 hours
**Status:** Active

---

## Phase Goal

Transform raw data into clean, analysis-ready format by handling missing data, fixing data types, addressing outliers, and standardizing variables.

---

## Prerequisites

- Phase 2 complete (data imported and inspected)
- Data dictionary reviewed and populated
- Data quality issues documented
- Cleaning strategy agreed upon

---

## Step-by-Step Instructions

### 1. Review Cleaning Strategy

Based on Phase 2 inspection, we identified these issues:

**We'll address:**
- Missing data (imputation strategy)
- Outliers (cap, transform, or remove)
- Data type corrections
- Variable name standardization
- Duplicate rows
- Invalid/inconsistent values

**What I need from you:**

1. **Missing Data Strategy**: For variables with missings:
   - Remove rows? (if <5% missing)
   - Impute with mean/median/mode?
   - Keep as missing with indicator variable?
   - Drop variable entirely? (if >50% missing)

2. **Outlier Strategy**: For flagged outliers:
   - Keep as-is? (legitimate extreme values)
   - Cap at percentile? (winsorize)
   - Log transform?
   - Remove rows?

### 2. Create Cleaning Script

I'll build `scripts/03-clean.R` with these steps:

**Step 3.1: Load and Setup**
```r
library(tidyverse)
library(janitor)
library(here)

# Load raw data
raw_data <- read_rds(here("data", "raw", "raw_data.rds"))

# Start cleaning pipeline
clean_data <- raw_data
```

**Step 3.2: Clean Variable Names**
```r
# Standardize to snake_case, remove special characters
clean_data <- clean_data |>
  janitor::clean_names()

# Manual renames if needed
clean_data <- clean_data |>
  rename(
    # old_name = new_name
  )
```

**Step 3.3: Fix Data Types**
```r
# Convert to appropriate types
clean_data <- clean_data |>
  mutate(
    # Factors (categorical with known levels)
    # {var} = factor({var}, levels = c("A", "B", "C")),

    # Dates
    # {date_var} = lubridate::ymd({date_var}),

    # Numeric (currently character)
    # {num_var} = parse_number({num_var}),

    # Logical
    # {bool_var} = as.logical({bool_var})
  )
```

**Step 3.4: Handle Missing Data**
```r
# Document missing patterns before imputation
missing_before <- clean_data |>
  summarise(across(everything(), ~ sum(is.na(.x)))) |>
  pivot_longer(everything(), names_to = "variable", values_to = "n_missing_before")

# Strategy 1: Remove rows with ANY missing (if very few)
# clean_data <- clean_data |> drop_na()

# Strategy 2: Remove rows with missing in SPECIFIC columns
# clean_data <- clean_data |> drop_na(important_var1, important_var2)

# Strategy 3: Impute numeric with median/mean
clean_data <- clean_data |>
  mutate(
    # {numeric_var} = if_else(is.na({numeric_var}), median({numeric_var}, na.rm = TRUE), {numeric_var})
  )

# Strategy 4: Impute categorical with mode
get_mode <- function(x) {
  ux <- unique(na.omit(x))
  ux[which.max(tabulate(match(x, ux)))]
}

clean_data <- clean_data |>
  mutate(
    # {cat_var} = if_else(is.na({cat_var}), get_mode({cat_var}), {cat_var})
  )

# Strategy 5: Create missing indicator and impute
clean_data <- clean_data |>
  mutate(
    # {var}_missing = is.na({var}),
    # {var} = if_else(is.na({var}), median({var}, na.rm = TRUE), {var})
  )

# Document missing after imputation
missing_after <- clean_data |>
  summarise(across(everything(), ~ sum(is.na(.x)))) |>
  pivot_longer(everything(), names_to = "variable", values_to = "n_missing_after")

missing_summary <- missing_before |>
  left_join(missing_after, by = "variable") |>
  mutate(
    n_imputed = n_missing_before - n_missing_after
  ) |>
  filter(n_missing_before > 0)

write_csv(missing_summary, here("outputs", "tables", "missing_data_handling.csv"))
```

**Step 3.5: Handle Outliers**
```r
# Define outlier detection function
detect_outliers <- function(x, method = "iqr", k = 1.5) {
  if (method == "iqr") {
    q1 <- quantile(x, 0.25, na.rm = TRUE)
    q3 <- quantile(x, 0.75, na.rm = TRUE)
    iqr <- q3 - q1
    lower <- q1 - k * iqr
    upper <- q3 + k * iqr
    x < lower | x > upper
  } else if (method == "zscore") {
    abs(scale(x)) > 3
  }
}

# Flag outliers before handling
outlier_summary <- clean_data |>
  select(where(is.numeric)) |>
  summarise(
    across(
      everything(),
      ~ sum(detect_outliers(.x, method = "iqr"), na.rm = TRUE),
      .names = "{.col}_outliers"
    )
  ) |>
  pivot_longer(everything(), names_to = "variable", values_to = "n_outliers")

# Strategy 1: Cap at percentiles (winsorize)
winsorize <- function(x, probs = c(0.01, 0.99)) {
  limits <- quantile(x, probs, na.rm = TRUE)
  x[x < limits[1]] <- limits[1]
  x[x > limits[2]] <- limits[2]
  x
}

clean_data <- clean_data |>
  mutate(
    # {var} = winsorize({var}, probs = c(0.01, 0.99))
  )

# Strategy 2: Log transform (for right-skewed)
clean_data <- clean_data |>
  mutate(
    # {var}_log = log1p({var})  # log(1 + x) to handle zeros
  )

# Strategy 3: Remove outlier rows (last resort)
# clean_data <- clean_data |>
#   filter(!detect_outliers({var}))

write_csv(outlier_summary, here("outputs", "tables", "outlier_summary.csv"))
```

**Step 3.6: Remove Duplicates**
```r
# Check for duplicates
dupes <- clean_data |>
  janitor::get_dupes()

if (nrow(dupes) > 0) {
  cat("Found", nrow(dupes), "duplicate rows\n")
  write_csv(dupes, here("outputs", "tables", "duplicate_rows.csv"))

  # Remove duplicates (keep first occurrence)
  clean_data <- clean_data |>
    distinct()
}
```

**Step 3.7: Fix Inconsistent Values**
```r
# Standardize character variables
clean_data <- clean_data |>
  mutate(
    across(
      where(is.character),
      ~ str_trim(.x) |>           # Remove whitespace
        str_to_lower() |>         # Lowercase (if appropriate)
        str_squish()              # Reduce multiple spaces
    )
  )

# Fix specific inconsistencies
clean_data <- clean_data |>
  mutate(
    # {var} = case_when(
    #   {var} %in% c("Yes", "Y", "yes", "1") ~ "yes",
    #   {var} %in% c("No", "N", "no", "0") ~ "no",
    #   TRUE ~ {var}
    # )
  )
```

**Step 3.8: Drop Unnecessary Variables**
```r
# Remove variables marked as keep=FALSE in data dictionary
clean_data <- clean_data |>
  select(
    # -c(var_to_drop1, var_to_drop2)
  )
```

### 3. Validation and Quality Checks

**Post-cleaning validation:**
```r
# 1. Check dimensions
cat("Original rows:", nrow(raw_data), "\n")
cat("Clean rows:", nrow(clean_data), "\n")
cat("Rows removed:", nrow(raw_data) - nrow(clean_data), "\n\n")

# 2. Check missing data
clean_data |>
  summarise(across(everything(), ~ sum(is.na(.x)))) |>
  pivot_longer(everything()) |>
  filter(value > 0) |>
  arrange(desc(value))

# 3. Check data types
clean_data |>
  map_chr(~ class(.x)[1]) |>
  enframe(name = "variable", value = "type") |>
  print(n = Inf)

# 4. Summary statistics
library(skimr)
skim(clean_data)

# 5. Visual checks
clean_data |>
  select(where(is.numeric)) |>
  pivot_longer(everything()) |>
  ggplot(aes(x = value)) +
  geom_histogram(bins = 30) +
  facet_wrap(~name, scales = "free") +
  labs(title = "Cleaned Data Distributions")

ggsave(here("outputs", "figures", "cleaned_distributions.png"), width = 12, height = 8)
```

### 4. Save Cleaned Data

```r
# Save cleaned dataset
write_rds(clean_data, here("data", "processed", "clean_data.rds"))
write_csv(clean_data, here("data", "processed", "clean_data.csv"))

cat("Clean data saved to data/processed/\n")
```

### 5. Document Cleaning Process

I'll create `outputs/tables/phase03-cleaning-log.md`:

```markdown
# Phase 3: Data Cleaning Log

**Date:** {date}
**Original rows:** {n_raw}
**Clean rows:** {n_clean}
**Variables:** {n_vars}

## Cleaning Steps Performed

### 1. Variable Names
- Standardized to snake_case
- Renamed: {list renames}

### 2. Data Types
- Converted to factor: {vars}
- Converted to date: {vars}
- Converted to numeric: {vars}

### 3. Missing Data
- Total missing values: {n_before} → {n_after}
- Imputation strategy: {describe}
- Variables with missings: {list}

### 4. Outliers
- Variables with outliers: {list}
- Treatment: {cap/transform/remove}
- Rows affected: {n}

### 5. Duplicates
- Duplicate rows found: {n}
- Action: {removed/kept with flag}

### 6. Inconsistent Values
- Fixed in: {variables}
- Changes: {describe}

### 7. Variables Dropped
- {var}: {reason}

## Data Quality Before/After

| Metric | Before | After |
|--------|--------|-------|
| Rows | {n} | {n} |
| Columns | {n} | {n} |
| Missing cells | {n} | {n} |
| Duplicate rows | {n} | 0 |

## Validation Results
- [ ] No unexpected missing values
- [ ] Data types correct
- [ ] Outliers addressed
- [ ] No duplicates
- [ ] Character values standardized
- [ ] Clean data saved

## Next Steps (Phase 4: EDA)
Ready for exploratory data analysis with {n_clean} clean observations.
```

### 6. Validation Checklist

Before proceeding to Phase 4:

- [ ] All cleaning steps completed
- [ ] Missing data addressed (no unexpected NAs)
- [ ] Data types correct for all variables
- [ ] Outliers handled appropriately
- [ ] Duplicates removed
- [ ] Inconsistent values fixed
- [ ] Unnecessary variables dropped
- [ ] Clean data saved to `data/processed/`
- [ ] Cleaning log documented
- [ ] Visual validation checks reviewed
- [ ] No data integrity issues

---

## Outputs

**Created Files:**
- `data/processed/clean_data.rds`
- `data/processed/clean_data.csv`
- `scripts/03-clean.R`
- `outputs/tables/missing_data_handling.csv`
- `outputs/tables/outlier_summary.csv`
- `outputs/tables/duplicate_rows.csv` (if any found)
- `outputs/tables/phase03-cleaning-log.md`
- `outputs/figures/cleaned_distributions.png`
- `checkpoints/03-clean.complete`

**Git Commit:**
```bash
git add data/processed/ scripts/03-clean.R outputs/
git commit -m "feat: clean data and prepare for analysis

- Handle {n_missing} missing values
- Address outliers in {n_vars} variables
- Remove {n_dupes} duplicates
- Standardize {n_char} character variables
- Final dataset: {n_clean} rows, {n_cols} columns

Phase 3/10 complete

Co-Authored-By: Ada (Project Architect) <noreply@bmad.com>"
```

---

## Troubleshooting

**Issue:** Too many missing values after cleaning
- **Solution**: Review imputation strategy, consider multiple imputation methods

**Issue:** Outliers create skewed distributions
- **Solution**: Try log/sqrt transformations, use robust scaling in modeling

**Issue:** Data types keep reverting
- **Solution**: Check for leading/trailing spaces, ensure factor levels are valid

**Issue:** Cleaning script too slow
- **Solution**: Use `data.table` or `dtplyr` for large datasets

---

## Next Phase

**Phase 4: Exploratory Data Analysis (EDA)**

With clean data ready, we'll:
1. Visualize distributions and relationships
2. Identify patterns and anomalies
3. Generate correlation analysis
4. Create EDA report with insights
5. **Handoff to Grace** (Data Explorer)

**Transition:** When ready, say "Continue to Phase 4" or "Start EDA"

---

## Phase Completion

When this phase is complete:
1. Clean data saved and validated
2. All data quality issues resolved
3. Cleaning log documented
4. Checkpoint file created
5. Git commit made
6. **Ready to handoff to Grace for EDA**

**Expected Duration:** 2-4 hours

---

_Phase 3 of 10 | Owner: Ada | RDS Module Full-Lifecycle Workflow_
