# Step 2: Import Data

**Duration:** 15-30 minutes
**Goal:** Load data quickly with automatic type detection

---

## Overview

This step rapidly imports your dataset with intelligent automatic type detection. We prioritize speed and smart defaults over exhaustive validation, making this ideal for exploratory work.

---

## Step Instructions

### 1. Identify Data Source

**Gather:**

1. **Data Location**
   - Prompt: "What is your data source?"
   - Options:
     - Local file (CSV, Excel, RDS, TSV, etc.)
     - URL (direct download link)
     - Database connection (PostgreSQL, MySQL, SQLite)
     - API endpoint

2. **File Type Detection**
   - Auto-detect from extension
   - Supported formats:
     - `.csv`, `.tsv` — readr
     - `.xlsx`, `.xls` — readxl
     - `.rds`, `.rda` — base R
     - `.parquet` — arrow
     - `.feather` — arrow
     - `.sav` (SPSS), `.dta` (Stata), `.sas7bdat` — haven
     - `.json` — jsonlite

3. **Data Size Estimate**
   - Check file size
   - If > 100MB: Recommend vroom or data.table
   - If > 1GB: Recommend arrow/parquet format

---

### 2. Smart Import Strategy

**Decision Tree:**

```
Is file size < 100MB?
  ├─ YES → Use readr (read_csv, read_tsv, etc.)
  └─ NO  → Use vroom (vroom::vroom) or arrow (read_parquet)

Is file type Excel?
  ├─ YES → Use readxl (read_excel)
  └─ NO  → Continue

Is file type statistical software?
  ├─ YES → Use haven (read_spss, read_stata, read_sas)
  └─ NO  → Continue

Is data remote (URL)?
  ├─ YES → Download to data/raw/ first, then import
  └─ NO  → Import directly
```

---

### 3. Execute Import

**Code Template (CSV Example):**

```r
# Quick-EDA: Data Import
# Step 2 of quick-eda workflow

library(here)
library(readr)
library(dplyr)
library(fs)

# ══════════════════════════════════════════════════════════════
# Configuration
# ══════════════════════════════════════════════════════════════

data_source <- "{user-provided-path}"
data_file_name <- path_file(data_source)

# ══════════════════════════════════════════════════════════════
# Import with auto-detection
# ══════════════════════════════════════════════════════════════

message("📥 Importing data...")

# Import with readr (automatic type detection)
data_raw <- read_csv(
  data_source,
  show_col_types = FALSE,
  # Smart defaults
  na = c("", "NA", "N/A", "NULL", "null", "NaN", "#N/A"),
  trim_ws = TRUE,
  guess_max = 10000  # Scan more rows for better type detection
)

# Quick diagnostics
message("\n✓ Data imported successfully")
message(sprintf("  Rows: %s", nrow(data_raw)))
message(sprintf("  Columns: %s", ncol(data_raw)))
message(sprintf("  Size: %s", format(object.size(data_raw), units = "auto")))

# ══════════════════════════════════════════════════════════════
# Initial preview
# ══════════════════════════════════════════════════════════════

message("\n📊 Data preview:")
glimpse(data_raw)

# ══════════════════════════════════════════════════════════════
# Quick summary statistics
# ══════════════════════════════════════════════════════════════

message("\n📈 Quick summary:")
print(skimr::skim(data_raw))

# ══════════════════════════════════════════════════════════════
# Save to data/raw/
# ══════════════════════════════════════════════════════════════

# Copy original file if not already in data/raw/
if (!str_detect(data_source, "data/raw")) {
  file_copy(
    data_source,
    here("data/raw", data_file_name),
    overwrite = TRUE
  )
  message(sprintf("\n✓ Original file copied to data/raw/%s", data_file_name))
}

# Save as RDS for faster future loading
saveRDS(data_raw, here("data/raw/data_raw.rds"))
message("✓ Data saved as RDS (data/raw/data_raw.rds)")

# ══════════════════════════════════════════════════════════════
# Generate import report
# ══════════════════════════════════════════════════════════════

import_report <- list(
  file_name = data_file_name,
  source_path = data_source,
  import_date = Sys.time(),
  n_rows = nrow(data_raw),
  n_cols = ncol(data_raw),
  col_names = names(data_raw),
  col_types = sapply(data_raw, class),
  file_size = format(object.size(data_raw), units = "auto"),
  missing_values = sum(is.na(data_raw)),
  duplicate_rows = nrow(data_raw) - n_distinct(data_raw)
)

saveRDS(import_report, here("data/raw/import_report.rds"))
message("✓ Import report saved")
```

---

### 4. Import Variants

**For Excel Files:**

```r
library(readxl)

# List sheets
excel_sheets(data_source)

# Import specific sheet
data_raw <- read_excel(
  data_source,
  sheet = 1,  # Or sheet name
  na = c("", "NA", "N/A"),
  trim_ws = TRUE,
  guess_max = 10000
)
```

**For Large Files (> 100MB):**

```r
library(vroom)

# Fast import with vroom
data_raw <- vroom(
  data_source,
  delim = ",",
  na = c("", "NA", "N/A"),
  trim_ws = TRUE,
  guess_max = 10000,
  altrep = TRUE  # Lazy loading for memory efficiency
)
```

**For Statistical Software:**

```r
library(haven)

# SPSS
data_raw <- read_spss(data_source)

# Stata
data_raw <- read_stata(data_source)

# SAS
data_raw <- read_sas(data_source)

# Convert labels to factors
data_raw <- haven::as_factor(data_raw)
```

**For URLs:**

```r
library(here)
library(fs)

# Download file first
temp_file <- here("data/raw", path_file(url))
download.file(url, temp_file, mode = "wb")

# Then import normally
data_raw <- read_csv(temp_file)
```

**For JSON:**

```r
library(jsonlite)

# Read JSON
data_raw <- fromJSON(data_source, flatten = TRUE)

# Convert to tibble
data_raw <- as_tibble(data_raw)
```

---

### 5. Data Validation Checks

**Quick validation (automated):**

```r
# ══════════════════════════════════════════════════════════════
# Automated validation checks
# ══════════════════════════════════════════════════════════════

validation_results <- list()

# Check 1: Non-empty dataset
validation_results$non_empty <- nrow(data_raw) > 0 && ncol(data_raw) > 0

# Check 2: No entirely empty columns
empty_cols <- data_raw |>
  summarise(across(everything(), ~all(is.na(.)))) |>
  select(where(~.)) |>
  names()

validation_results$empty_columns <- empty_cols
validation_results$has_empty_columns <- length(empty_cols) > 0

# Check 3: Column name issues
validation_results$duplicate_names <- anyDuplicated(names(data_raw)) > 0
validation_results$missing_names <- any(names(data_raw) == "")

# Check 4: Reasonable dimensions
validation_results$reasonable_size <- nrow(data_raw) < 10e6  # Less than 10M rows

# Report issues
if (validation_results$has_empty_columns) {
  warning(sprintf("Found %d empty columns: %s",
                  length(empty_cols),
                  paste(empty_cols, collapse = ", ")))
}

if (validation_results$duplicate_names) {
  warning("Found duplicate column names")
}

if (validation_results$missing_names) {
  warning("Found columns with missing names")
}

if (!validation_results$reasonable_size) {
  message("⚠ Large dataset detected. Consider using data.table or arrow for better performance.")
}

# Save validation results
saveRDS(validation_results, here("data/raw/validation_results.rds"))
```

---

### 6. Generate Import Summary

**Create visual summary:**

```r
# ══════════════════════════════════════════════════════════════
# Generate import summary document
# ══════════════════════════════════════════════════════════════

library(naniar)

# Missing data visualization
missing_plot <- gg_miss_var(data_raw, show_pct = TRUE) +
  labs(title = "Missing Data by Variable") +
  theme_minimal()

ggsave(
  here("plots/01-import-missing.png"),
  missing_plot,
  width = 10,
  height = 6,
  dpi = 300
)

# Variable type summary
type_summary <- data_raw |>
  summarise(across(everything(), class)) |>
  pivot_longer(everything(), names_to = "variable", values_to = "type") |>
  count(type, sort = TRUE)

print(type_summary)

message("\n✓ Import summary generated")
```

---

## Step Completion

**Verify:**

1. ✓ Data file imported successfully
2. ✓ Data dimensions reasonable (rows × columns)
3. ✓ No critical import errors
4. ✓ RDS version saved to data/raw/
5. ✓ Import report generated
6. ✓ Missing data visualization created

**Output:**

```
╔══════════════════════════════════════════════════════════════╗
║                   STEP 2 COMPLETE                            ║
║                   Data Import Done                           ║
╚══════════════════════════════════════════════════════════════╝

✓ Imported: {file-name}
✓ Dimensions: {n_rows} rows × {n_cols} columns
✓ Size: {file_size}
✓ Missing values: {missing_pct}%

Files created:
  • data/raw/{file-name} — Original data
  • data/raw/data_raw.rds — RDS format
  • data/raw/import_report.rds — Import metadata
  • plots/01-import-missing.png — Missing data plot

Duration: ~{X} minutes

Ready for Step 3: Quick Clean
```

---

## Troubleshooting

**Issue:** Import fails with encoding errors
- **Solution:** Try `read_csv(file, locale = locale(encoding = "UTF-8"))` or "Latin1"

**Issue:** Incorrect type detection
- **Solution:** Increase `guess_max` parameter or specify `col_types` manually

**Issue:** Out of memory errors
- **Solution:** Use `vroom()` with `altrep = TRUE`, or switch to `arrow::read_csv_arrow()`

**Issue:** Excel file has multiple sheets
- **Solution:** Import each sheet separately, then choose relevant one or combine

**Issue:** Date/time columns imported as character
- **Solution:** Use `readr::parse_datetime()` or `lubridate::ymd_hms()` to convert

---

## Best Practices

1. **Always keep original file** — Save to data/raw/ as read-only
2. **Use RDS format** — Faster loading, preserves R types
3. **Document import** — Save import_report for reproducibility
4. **Check data immediately** — Use glimpse() and skim() to spot issues early
5. **Automate when possible** — Let readr guess types, but validate results

---

_Step created on 2026-03-17 for quick-eda workflow_
