# Step 1: Quick Setup

**Duration:** 30-60 minutes
**Goal:** Create minimal project structure with renv initialization

---

## Overview

This step creates a lightweight R project structure optimized for rapid exploration. Unlike the full-eda workflow, we use a minimal renv setup with only essential packages, allowing you to start analysis faster.

---

## Step Instructions

### 1. Project Information

**Gather:**

1. **Project Name**
   - Prompt: "What would you like to name this project?"
   - Default: `quick-eda-{timestamp}`
   - Format: lowercase-with-dashes

2. **Project Location**
   - Prompt: "Where should I create this project?"
   - Default: `~/Documents/r-projects/`
   - Validate: Directory exists and is writable

3. **Data Source Preview**
   - Prompt: "What data file will you be exploring?"
   - Purpose: Helps determine necessary packages
   - Note: Full import happens in Step 2

---

### 2. Create Project Structure

**Execute:**

Create minimal directory structure:

```
{project-name}/
├── .Rproj.user/           # RStudio metadata
├── {project-name}.Rproj   # RStudio project file
├── renv/                  # Package management
├── data/                  # Data storage
│   ├── raw/              # Original data (read-only)
│   └── processed/        # Cleaned data
├── scripts/              # R scripts
│   ├── 01-import.R       # Data import script
│   ├── 02-clean.R        # Cleaning script
│   └── 03-eda.R          # EDA script
├── plots/                # Output visualizations
├── reports/              # Generated reports
├── README.md             # Project documentation
└── .Rprofile             # R startup configuration
```

**Code Template:**

```r
# Create project structure
library(fs)
library(here)

project_path <- here::here()

# Create directories
dir_create(c(
  "data/raw",
  "data/processed",
  "scripts",
  "plots",
  "reports"
))

# Create .Rprofile
writeLines(
  c(
    "# Quick-EDA Project Configuration",
    "",
    "# Activate renv",
    "source('renv/activate.R')",
    "",
    "# Set options",
    "options(",
    "  tidyverse.quiet = TRUE,",
    "  pillar.print_max = 10,",
    "  pillar.print_min = 5",
    ")",
    "",
    "# Welcome message",
    "cat('\\n📊 Quick-EDA Project Loaded\\n\\n')"
  ),
  ".Rprofile"
)

message("✓ Project structure created")
```

---

### 3. Initialize renv (Minimal)

**Execute:**

Initialize renv with minimal package set:

```r
# Initialize renv
renv::init(bare = TRUE)

# Install core packages only
essential_packages <- c(
  # Core tidyverse
  "dplyr",
  "tidyr",
  "readr",
  "ggplot2",
  "purrr",
  "tibble",
  "stringr",
  "forcats",

  # Project utilities
  "here",
  "fs",

  # Quick EDA
  "skimr",
  "janitor",
  "naniar",

  # Visualization
  "patchwork",
  "scales",

  # Reporting
  "quarto"
)

# Install packages
renv::install(essential_packages)

# Take snapshot
renv::snapshot()

message("✓ renv initialized with essential packages")
```

**Key Difference from Full-EDA:**
- Installs only ~15 essential packages vs. comprehensive library
- Uses `bare = TRUE` for faster initialization
- Skips package version pinning (uses latest stable)
- No extensive dependency analysis

---

### 4. Create Starter Scripts

**Generate three starter R scripts:**

#### `scripts/01-import.R`

```r
# Quick-EDA: Data Import
# Created: {timestamp}

# Load packages
library(here)
library(readr)
library(dplyr)

# Import data
# TODO: Update path to your data file
data_raw <- read_csv(
  here("data/raw/YOUR_DATA_FILE.csv"),
  show_col_types = FALSE
)

# Quick preview
glimpse(data_raw)
skimr::skim(data_raw)

# Save as RDS for faster loading
saveRDS(data_raw, here("data/raw/data_raw.rds"))

message("✓ Data imported successfully")
```

#### `scripts/02-clean.R`

```r
# Quick-EDA: Data Cleaning
# Created: {timestamp}

# Load packages
library(here)
library(dplyr)
library(tidyr)
library(janitor)
library(naniar)

# Load raw data
data_raw <- readRDS(here("data/raw/data_raw.rds"))

# Quick cleaning pipeline
data_clean <- data_raw |>
  # Standardize names
  clean_names() |>

  # Remove empty rows/columns
  remove_empty(c("rows", "cols")) |>

  # Handle duplicates
  distinct()

# Check missing data
miss_var_summary(data_clean)

# Save cleaned data
saveRDS(data_clean, here("data/processed/data_clean.rds"))

message("✓ Basic cleaning complete")
```

#### `scripts/03-eda.R`

```r
# Quick-EDA: Exploratory Data Analysis
# Created: {timestamp}

# Load packages
library(here)
library(dplyr)
library(ggplot2)
library(patchwork)
library(skimr)

# Load cleaned data
data_clean <- readRDS(here("data/processed/data_clean.rds"))

# Comprehensive summary
skim(data_clean)

# TODO: Add exploratory visualizations
# Example:
# data_clean |>
#   ggplot(aes(x = variable1, y = variable2)) +
#   geom_point() +
#   theme_minimal()

message("✓ EDA script ready")
```

---

### 5. Create README

**Generate README.md:**

```markdown
# {project-name}

Quick-EDA exploratory data analysis project.

## Project Structure

- `data/raw/` — Original data files (read-only)
- `data/processed/` — Cleaned datasets
- `scripts/` — Analysis scripts (run in order)
- `plots/` — Generated visualizations
- `reports/` — EDA reports

## Workflow

Created using BMAD RDS Module quick-eda workflow.

**Steps:**
1. Import data (`scripts/01-import.R`)
2. Clean data (`scripts/02-clean.R`)
3. Explore data (`scripts/03-eda.R`)
4. Generate report (automated via Quarto)

## Requirements

- R 4.3+
- RStudio (recommended)
- renv (managed automatically)

## Getting Started

```r
# Open project in RStudio
# renv will activate automatically

# Run scripts in sequence
source("scripts/01-import.R")
source("scripts/02-clean.R")
source("scripts/03-eda.R")
```

## Created

- Date: {timestamp}
- BMAD Version: 6.0.0-alpha.23
- Workflow: quick-eda
```

---

## Step Completion

**Verify:**

1. ✓ Project directory structure created
2. ✓ renv initialized with essential packages
3. ✓ Starter scripts generated (01-import, 02-clean, 03-eda)
4. ✓ README documentation created
5. ✓ .Rprofile configured

**Output:**

```
╔══════════════════════════════════════════════════════════════╗
║                   STEP 1 COMPLETE                            ║
║                   Quick Setup Done                           ║
╚══════════════════════════════════════════════════════════════╝

✓ Project structure created at: {project-path}
✓ renv initialized with {N} essential packages
✓ Starter scripts ready in scripts/

Duration: ~{X} minutes

Ready for Step 2: Import Data
```

---

## Troubleshooting

**Issue:** renv initialization fails
- **Solution:** Check internet connection, try `renv::restore()`, or use `options(repos = "https://cran.r-project.org")`

**Issue:** Directory creation fails
- **Solution:** Verify write permissions, check disk space, ensure parent directory exists

**Issue:** Package installation slow
- **Solution:** This is normal for first-time setup. Consider using local CRAN mirror or binary packages.

---

_Step created on 2026-03-17 for quick-eda workflow_
