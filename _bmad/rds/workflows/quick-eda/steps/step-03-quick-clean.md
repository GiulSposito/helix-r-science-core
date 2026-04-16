# Step 3: Quick Clean

**Duration:** 1-2 hours
**Goal:** Fast cleaning with automated decisions

---

## Overview

This step performs essential data cleaning with automated decision-making for speed. Unlike full validation workflows, we use sensible defaults for imputation and transformation, allowing you to reach analysis faster while maintaining data quality.

---

## Step Instructions

### 1. Load Data & Setup

**Initialize cleaning environment:**

```r
# Quick-EDA: Data Cleaning
# Step 3 of quick-eda workflow

library(here)
library(dplyr)
library(tidyr)
library(janitor)
library(naniar)
library(stringr)
library(forcats)

# Load raw data
data_raw <- readRDS(here("data/raw/data_raw.rds"))
import_report <- readRDS(here("data/raw/import_report.rds"))

message("📊 Starting quick cleaning...")
message(sprintf("  Input: %d rows × %d cols", nrow(data_raw), ncol(data_raw)))
```

---

### 2. Standardize Column Names

**Execute automatic name cleaning:**

```r
# ══════════════════════════════════════════════════════════════
# Step 3.1: Clean column names
# ══════════════════════════════════════════════════════════════

# Before
original_names <- names(data_raw)

# Clean names (snake_case, no special chars)
data_clean <- data_raw |>
  clean_names(case = "snake")

# After
message("\n✓ Column names standardized:")
name_changes <- tibble(
  original = original_names,
  cleaned = names(data_clean)
) |>
  filter(original != cleaned)

if (nrow(name_changes) > 0) {
  print(name_changes)
} else {
  message("  (no changes needed)")
}
```

---

### 3. Remove Empty/Duplicate Data

**Automated removal:**

```r
# ══════════════════════════════════════════════════════════════
# Step 3.2: Remove empty rows/columns and duplicates
# ══════════════════════════════════════════════════════════════

# Track dimensions
before_rows <- nrow(data_clean)
before_cols <- ncol(data_clean)

# Remove empty rows and columns
data_clean <- data_clean |>
  remove_empty(which = c("rows", "cols"))

# Remove duplicate rows
duplicates_removed <- nrow(data_clean) - n_distinct(data_clean)
data_clean <- data_clean |>
  distinct()

# Report
message("\n✓ Empty/duplicate removal:")
message(sprintf("  Empty columns removed: %d", before_cols - ncol(data_clean)))
message(sprintf("  Empty rows removed: %d", before_rows - nrow(data_clean)))
message(sprintf("  Duplicate rows removed: %d", duplicates_removed))
message(sprintf("  Final: %d rows × %d cols", nrow(data_clean), ncol(data_clean)))
```

---

### 4. Handle Missing Data (Automated)

**Strategy:**

```r
# ══════════════════════════════════════════════════════════════
# Step 3.3: Handle missing data with automated strategies
# ══════════════════════════════════════════════════════════════

# Analyze missing patterns
missing_summary <- miss_var_summary(data_clean)
print(missing_summary)

# Automated imputation strategy:
# - Numeric: median (robust to outliers)
# - Character: mode (most common value)
# - Logical: FALSE (conservative default)
# - Date: drop (too risky to impute)

# Columns with > 50% missing → drop
high_missing_cols <- missing_summary |>
  filter(pct_miss > 50) |>
  pull(variable)

if (length(high_missing_cols) > 0) {
  message(sprintf("\n⚠ Dropping %d columns with >50%% missing:", length(high_missing_cols)))
  message("  ", paste(high_missing_cols, collapse = ", "))

  data_clean <- data_clean |>
    select(-all_of(high_missing_cols))
}

# Impute remaining missing values
data_clean <- data_clean |>
  mutate(across(
    where(is.numeric),
    ~replace_na(., median(., na.rm = TRUE))
  )) |>
  mutate(across(
    where(is.character),
    ~replace_na(., get_mode(.))  # Helper function for mode
  )) |>
  mutate(across(
    where(is.logical),
    ~replace_na(., FALSE)
  ))

# Helper: calculate mode
get_mode <- function(x) {
  ux <- unique(na.omit(x))
  if (length(ux) == 0) return(NA)
  ux[which.max(tabulate(match(x, ux)))]
}

# Verify no missing values in key columns
remaining_missing <- sum(is.na(data_clean))
message(sprintf("\n✓ Missing data handled: %d values remain", remaining_missing))
```

---

### 5. Type Conversion & Standardization

**Automated type fixes:**

```r
# ══════════════════════════════════════════════════════════════
# Step 3.4: Fix data types and standardize formats
# ══════════════════════════════════════════════════════════════

# Detect and fix common type issues

# Character → Factor (if < 20 unique values and < 50% of rows)
character_cols <- data_clean |>
  select(where(is.character)) |>
  names()

for (col in character_cols) {
  n_unique <- n_distinct(data_clean[[col]])
  ratio <- n_unique / nrow(data_clean)

  if (n_unique < 20 && ratio < 0.5) {
    message(sprintf("  Converting '%s' to factor (%d levels)", col, n_unique))
    data_clean[[col]] <- as.factor(data_clean[[col]])
  }
}

# Numeric stored as character → numeric
numeric_as_char <- data_clean |>
  select(where(is.character)) |>
  select(where(~all(str_detect(na.omit(.), "^-?\\d+\\.?\\d*$")))) |>
  names()

if (length(numeric_as_char) > 0) {
  message(sprintf("\n  Converting %d character columns to numeric", length(numeric_as_char)))
  data_clean <- data_clean |>
    mutate(across(all_of(numeric_as_char), as.numeric))
}

# Standardize strings
data_clean <- data_clean |>
  mutate(across(
    where(is.character),
    ~str_trim(.) |>          # Remove whitespace
      str_squish() |>         # Collapse internal whitespace
      str_to_lower()          # Lowercase for consistency
  ))

message("\n✓ Data types standardized")
```

---

### 6. Basic Feature Engineering

**Automated derived features:**

```r
# ══════════════════════════════════════════════════════════════
# Step 3.5: Create useful derived features
# ══════════════════════════════════════════════════════════════

# Track new features
new_features <- c()

# Date features (if date columns exist)
date_cols <- data_clean |>
  select(where(lubridate::is.Date) | where(lubridate::is.POSIXct)) |>
  names()

if (length(date_cols) > 0) {
  for (col in date_cols) {
    base_name <- str_remove(col, "date$|_date$")

    data_clean <- data_clean |>
      mutate(
        "{base_name}_year" := lubridate::year(.data[[col]]),
        "{base_name}_month" := lubridate::month(.data[[col]], label = TRUE),
        "{base_name}_day_of_week" := lubridate::wday(.data[[col]], label = TRUE),
        "{base_name}_quarter" := lubridate::quarter(.data[[col]])
      )

    new_features <- c(new_features, paste0(base_name, c("_year", "_month", "_day_of_week", "_quarter")))
  }

  message(sprintf("\n  Created %d date-derived features", length(new_features)))
}

# Numeric features: create binned versions for high-cardinality numerics
numeric_cols <- data_clean |>
  select(where(is.numeric)) |>
  select(where(~n_distinct(.) > 20)) |>
  names()

for (col in numeric_cols) {
  bin_name <- paste0(col, "_bin")

  data_clean <- data_clean |>
    mutate(
      "{bin_name}" := cut(
        .data[[col]],
        breaks = 5,
        labels = c("very_low", "low", "medium", "high", "very_high"),
        include.lowest = TRUE
      )
    )

  new_features <- c(new_features, bin_name)
}

if (length(numeric_cols) > 0) {
  message(sprintf("  Created %d binned numeric features", length(numeric_cols)))
}

message(sprintf("\n✓ Feature engineering complete: %d new features", length(new_features)))
```

---

### 7. Outlier Detection (Flag Only)

**Non-destructive outlier flagging:**

```r
# ══════════════════════════════════════════════════════════════
# Step 3.6: Flag outliers (for awareness, don't remove)
# ══════════════════════════════════════════════════════════════

# Function: detect outliers using IQR method
flag_outliers <- function(x) {
  q1 <- quantile(x, 0.25, na.rm = TRUE)
  q3 <- quantile(x, 0.75, na.rm = TRUE)
  iqr <- q3 - q1

  lower_bound <- q1 - 1.5 * iqr
  upper_bound <- q3 + 1.5 * iqr

  x < lower_bound | x > upper_bound
}

# Add outlier flags for numeric columns
outlier_flags <- data_clean |>
  select(where(is.numeric)) |>
  mutate(across(everything(), flag_outliers, .names = "{.col}_outlier")) |>
  select(ends_with("_outlier"))

data_clean <- bind_cols(data_clean, outlier_flags)

# Report outlier counts
outlier_counts <- outlier_flags |>
  summarise(across(everything(), sum, na.rm = TRUE)) |>
  pivot_longer(everything(), names_to = "variable", values_to = "outlier_count") |>
  filter(outlier_count > 0) |>
  arrange(desc(outlier_count))

if (nrow(outlier_counts) > 0) {
  message("\n⚠ Outliers detected (flagged, not removed):")
  print(outlier_counts)
} else {
  message("\n✓ No significant outliers detected")
}
```

---

### 8. Save Cleaned Data

**Save multiple formats:**

```r
# ══════════════════════════════════════════════════════════════
# Step 3.7: Save cleaned data in multiple formats
# ══════════════════════════════════════════════════════════════

# RDS (primary format)
saveRDS(data_clean, here("data/processed/data_clean.rds"))
message("\n✓ Saved: data/processed/data_clean.rds")

# CSV (for portability)
write_csv(data_clean, here("data/processed/data_clean.csv"))
message("✓ Saved: data/processed/data_clean.csv")

# Cleaning report
cleaning_report <- list(
  input_dims = c(rows = nrow(data_raw), cols = ncol(data_raw)),
  output_dims = c(rows = nrow(data_clean), cols = ncol(data_clean)),
  cleaning_date = Sys.time(),
  columns_dropped = setdiff(names(data_raw), names(data_clean)),
  columns_added = setdiff(names(data_clean), names(data_raw)),
  rows_removed = nrow(data_raw) - nrow(data_clean),
  missing_handled = import_report$missing_values - sum(is.na(data_clean)),
  type_changes = tibble(
    column = names(data_clean),
    type = sapply(data_clean, class)
  )
)

saveRDS(cleaning_report, here("data/processed/cleaning_report.rds"))
message("✓ Saved: data/processed/cleaning_report.rds")
```

---

### 9. Generate Cleaning Visualizations

**Create diagnostic plots:**

```r
# ══════════════════════════════════════════════════════════════
# Step 3.8: Create cleaning diagnostic visualizations
# ══════════════════════════════════════════════════════════════

library(ggplot2)
library(patchwork)

# Plot 1: Data completeness comparison
completeness_plot <- bind_rows(
  data_raw |>
    summarise(across(everything(), ~mean(!is.na(.)))) |>
    pivot_longer(everything(), names_to = "variable", values_to = "completeness") |>
    mutate(dataset = "raw"),
  data_clean |>
    summarise(across(everything(), ~mean(!is.na(.)))) |>
    pivot_longer(everything(), names_to = "variable", values_to = "completeness") |>
    mutate(dataset = "clean")
) |>
  ggplot(aes(x = reorder(variable, completeness), y = completeness, fill = dataset)) +
  geom_col(position = "dodge") +
  coord_flip() +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Data Completeness: Before vs After Cleaning",
    x = NULL,
    y = "Completeness %",
    fill = "Dataset"
  ) +
  theme_minimal()

ggsave(
  here("plots/03-clean-completeness.png"),
  completeness_plot,
  width = 10,
  height = 8,
  dpi = 300
)

# Plot 2: Variable types distribution
type_plot <- data_clean |>
  summarise(across(everything(), class)) |>
  pivot_longer(everything(), names_to = "variable", values_to = "type") |>
  count(type) |>
  ggplot(aes(x = reorder(type, n), y = n, fill = type)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  labs(
    title = "Variable Types After Cleaning",
    x = "Type",
    y = "Count"
  ) +
  theme_minimal()

ggsave(
  here("plots/03-clean-types.png"),
  type_plot,
  width = 8,
  height = 6,
  dpi = 300
)

message("\n✓ Diagnostic plots saved")
```

---

## Step Completion

**Verify:**

1. ✓ Column names standardized (snake_case)
2. ✓ Empty rows/columns removed
3. ✓ Duplicate rows removed
4. ✓ Missing data handled (automated imputation)
5. ✓ Data types corrected and standardized
6. ✓ Basic features engineered
7. ✓ Outliers flagged (not removed)
8. ✓ Cleaned data saved (RDS + CSV)
9. ✓ Cleaning report generated
10. ✓ Diagnostic visualizations created

**Output:**

```
╔══════════════════════════════════════════════════════════════╗
║                   STEP 3 COMPLETE                            ║
║                   Quick Clean Done                           ║
╚══════════════════════════════════════════════════════════════╝

✓ Data cleaned successfully
✓ Input: {input_rows} rows × {input_cols} cols
✓ Output: {output_rows} rows × {output_cols} cols
✓ Rows removed: {removed_rows} ({pct}%)
✓ Missing values handled: {handled_missing}
✓ New features created: {new_features}

Files created:
  • data/processed/data_clean.rds — Cleaned data (RDS)
  • data/processed/data_clean.csv — Cleaned data (CSV)
  • data/processed/cleaning_report.rds — Cleaning metadata
  • plots/03-clean-completeness.png — Completeness comparison
  • plots/03-clean-types.png — Variable types

Duration: ~{X} hours

Ready for Step 4: EDA
```

---

## Automated Cleaning Decisions

**This workflow makes these automated choices:**

| Issue | Decision | Rationale |
|-------|----------|-----------|
| Missing > 50% | Drop column | Too little information to impute |
| Missing numeric | Median impute | Robust to outliers |
| Missing categorical | Mode impute | Most common value |
| Missing logical | FALSE | Conservative default |
| Empty rows/cols | Remove | No information value |
| Duplicates | Remove | Redundant |
| Outliers | Flag only | May be valid extreme values |
| Character with few levels | Convert to factor | More efficient, better for modeling |
| Whitespace | Trim & squish | Standardization |
| Case inconsistency | Lowercase | Consistency |

**When to use full-eda instead:**
- Need custom imputation strategies
- Domain expertise required for cleaning decisions
- High-stakes analysis requiring manual validation
- Complex missing data patterns needing investigation

---

## Troubleshooting

**Issue:** Too many columns dropped (> 50%)
- **Solution:** Review missing data patterns, consider full-eda workflow for custom imputation

**Issue:** Type conversions fail
- **Solution:** Check for mixed types in columns, may need manual specification

**Issue:** Memory issues with large datasets
- **Solution:** Process in chunks, or use data.table/dtplyr

**Issue:** Outliers flagged incorrectly
- **Solution:** Adjust IQR multiplier (1.5 is standard, try 2.0 or 3.0 for less sensitivity)

---

_Step created on 2026-03-17 for quick-eda workflow_
