# Phase 2: Import & Inspect

**Owner:** Ada (Project Architect)
**Duration:** 1-2 hours
**Status:** Active

---

## Phase Goal

Load raw data, perform initial inspection, identify data quality issues, and create a data dictionary.

---

## Prerequisites

- Phase 1 complete (project structure created)
- Data source identified and accessible
- `tidyverse` and `skimr` installed

---

## Step-by-Step Instructions

### 1. Import Raw Data

**What I need from you:**

1. **Data Location**: Where is your data?
   - Local file (CSV, Excel, RDS, Parquet, etc.)
   - Database (connection string)
   - API endpoint
   - Multiple files to combine

2. **Data Context**: Tell me about your data
   - What does each row represent? (e.g., customer, transaction, observation)
   - Expected number of rows/columns
   - Any known issues or quirks

### 2. Load Data into R

I'll create `scripts/02-import.R` with appropriate reading function:

**For CSV files:**
```r
library(tidyverse)
library(here)

# Import raw data
raw_data <- read_csv(
  here("data", "raw", "{filename}.csv"),
  col_types = cols(),  # Let readr guess initially
  na = c("", "NA", "NULL", "N/A")
)

# Save as RDS for faster loading
write_rds(raw_data, here("data", "raw", "raw_data.rds"))
```

**For Excel files:**
```r
library(readxl)

raw_data <- read_excel(
  here("data", "raw", "{filename}.xlsx"),
  sheet = "{sheet_name}",  # Specify if needed
  na = c("", "NA", "N/A")
)
```

**For databases:**
```r
library(DBI)
library(RPostgres)  # or RSQLite, RMySQL, etc.

con <- dbConnect(
  Postgres(),
  host = "{host}",
  dbname = "{database}",
  user = "{user}",
  password = rstudioapi::askForPassword("Database password")
)

raw_data <- dbGetQuery(con, "SELECT * FROM {table}")
dbDisconnect(con)
```

**For multiple files:**
```r
# Read and combine multiple CSV files
raw_data <- list.files(
  here("data", "raw"),
  pattern = "*.csv",
  full.names = TRUE
) |>
  map_df(read_csv, .id = "file_id")
```

### 3. Initial Inspection

**Basic overview:**
```r
# Dimensions
cat("Rows:", nrow(raw_data), "\n")
cat("Columns:", ncol(raw_data), "\n\n")

# Structure
glimpse(raw_data)

# First few rows
head(raw_data, 10)

# Column names
names(raw_data)
```

### 4. Comprehensive Data Profiling

**Use skimr for detailed summary:**
```r
library(skimr)

# Full data summary
skim_summary <- skim(raw_data)
print(skim_summary)

# Save summary to file
skim_summary |>
  yank("character") |>  # Extract character variables
  write_csv(here("outputs", "tables", "character_summary.csv"))

skim_summary |>
  yank("numeric") |>    # Extract numeric variables
  write_csv(here("outputs", "tables", "numeric_summary.csv"))
```

**Key inspection points:**
- Missing values (% complete)
- Numeric ranges (min, max, mean, sd)
- Character unique values
- Date ranges
- Data types (correct?)

### 5. Identify Data Quality Issues

I'll create a data quality report documenting:

**Common issues to check:**
```r
# 1. Missing data patterns
library(naniar)

miss_var_summary(raw_data)
vis_miss(raw_data)  # Visualize missing patterns

# 2. Duplicate rows
raw_data |>
  janitor::get_dupes()  # Find exact duplicates

# 3. Outliers (numeric variables)
raw_data |>
  select(where(is.numeric)) |>
  pivot_longer(everything()) |>
  ggplot(aes(x = name, y = value)) +
  geom_boxplot() +
  facet_wrap(~name, scales = "free") +
  labs(title = "Numeric Variable Distributions (Check Outliers)")

# 4. Unexpected values
raw_data |>
  select(where(is.character)) |>
  map(~ unique(.x) |> head(20))  # Show unique values

# 5. Inconsistent formats
# Check date formats, case inconsistencies, whitespace
raw_data |>
  select(where(is.character)) |>
  map(~ tibble(
    has_leading_space = any(str_detect(.x, "^\\s")),
    has_trailing_space = any(str_detect(.x, "\\s$")),
    mixed_case = length(unique(.x)) != length(unique(str_to_lower(.x)))
  ))
```

### 6. Create Data Dictionary

I'll generate a data dictionary documenting each variable:

```r
# Create data dictionary
data_dict <- tibble(
  variable = names(raw_data),
  type = map_chr(raw_data, ~ class(.x)[1]),
  n_missing = map_int(raw_data, ~ sum(is.na(.x))),
  pct_missing = round(n_missing / nrow(raw_data) * 100, 1),
  n_unique = map_int(raw_data, ~ n_distinct(.x)),
  example_values = map_chr(raw_data, ~ {
    vals <- na.omit(.x) |> head(3)
    paste(vals, collapse = ", ")
  })
)

# Add manual descriptions (we'll fill these together)
data_dict <- data_dict |>
  mutate(
    description = "",  # We'll populate this
    role = "",         # predictor, outcome, id, metadata
    keep = TRUE        # FALSE for variables to drop
  )

# Save for manual editing
write_csv(data_dict, here("outputs", "tables", "data_dictionary.csv"))
```

**We'll review this together and add:**
- Variable descriptions (business meaning)
- Variable roles (predictor, outcome, ID, metadata)
- Whether to keep each variable

### 7. Document Findings

I'll create `outputs/tables/phase02-inspection-notes.md`:

```markdown
# Phase 2: Data Inspection Notes

**Date:** {date}
**Dataset:** {name}
**Rows:** {n_rows}
**Columns:** {n_cols}

## Data Quality Issues Found

### Missing Data
- {variable}: {pct}% missing
- Pattern: {describe pattern}

### Outliers
- {variable}: {describe outliers}
- Action needed: {investigate/transform/cap}

### Duplicates
- {n} duplicate rows found
- Action: {remove/keep with flag}

### Data Type Issues
- {variable}: stored as {type}, should be {correct_type}

### Inconsistent Values
- {variable}: {describe inconsistency}

## Variables to Drop
- {variable}: {reason}

## Variables to Transform
- {variable}: {transformation needed}

## Next Steps (Phase 3)
1. {action}
2. {action}
```

### 8. Validation Checklist

Before proceeding to Phase 3:

- [ ] Data loaded successfully into R
- [ ] Dimensions match expectations (row count, column count)
- [ ] `skimr::skim()` summary reviewed
- [ ] Missing data patterns identified
- [ ] Outliers flagged for review
- [ ] Duplicate rows checked
- [ ] Data dictionary created and populated
- [ ] Data quality issues documented
- [ ] Raw data saved in `data/raw/`
- [ ] Inspection outputs saved in `outputs/tables/`

---

## Outputs

**Created Files:**
- `data/raw/raw_data.rds` (or appropriate format)
- `scripts/02-import.R`
- `outputs/tables/character_summary.csv`
- `outputs/tables/numeric_summary.csv`
- `outputs/tables/data_dictionary.csv`
- `outputs/tables/phase02-inspection-notes.md`
- `outputs/figures/missing_patterns.png`
- `outputs/figures/numeric_distributions.png`
- `checkpoints/02-import-inspect.complete`

**Git Commit:**
```bash
git add data/raw/ scripts/02-import.R outputs/
git commit -m "feat: import raw data and complete initial inspection

- Load {n_rows} rows, {n_cols} columns
- Identify {n_issues} data quality issues
- Create data dictionary

Phase 2/10 complete

Co-Authored-By: Ada (Project Architect) <noreply@bmad.com>"
```

---

## Troubleshooting

**Issue:** Data fails to load
- **Solution**: Check file path with `here()`, verify file permissions, check encoding

**Issue:** Column types wrong
- **Solution**: Specify `col_types` explicitly in `read_csv()`

**Issue:** Skimr output too large
- **Solution**: Run `skim()` on subsets, save to file instead of printing

**Issue:** Out of memory
- **Solution**: Use `vroom` or `arrow` for large files, sample data for initial inspection

---

## Next Phase

**Phase 3: Clean Data**

With inspection complete, we'll:
1. Clean variable names
2. Handle missing data (impute or remove)
3. Address outliers
4. Fix data types
5. Remove/combine problematic variables
6. Save cleaned data to `data/processed/`

**Transition:** When ready, say "Continue to Phase 3" or "Start cleaning"

---

## Phase Completion

When this phase is complete:
1. Raw data loaded and saved
2. Data quality issues documented
3. Data dictionary created
4. Checkpoint file created
5. Git commit made
6. Ready to proceed to Phase 3

**Expected Duration:** 1-2 hours

---

_Phase 2 of 10 | Owner: Ada | RDS Module Full-Lifecycle Workflow_
