# Phase 1: Setup Project

**Owner:** Ada (Project Architect)
**Duration:** 30-60 minutes
**Status:** Active

---

## Phase Goal

Create a well-structured, reproducible R project with dependency management and version control.

---

## Prerequisites

- R and RStudio installed
- Git installed and configured
- Basic understanding of R projects

---

## Step-by-Step Instructions

### 1. Gather Project Information

**What I need from you:**

1. **Project Name**: What should we call this project?
   - Default: Current directory name
   - Recommendation: Use lowercase with hyphens (e.g., `customer-churn-model`)

2. **Project Description**: Brief description (1-2 sentences)
   - This will go into README.md and DESCRIPTION file

3. **Initial Data Source**: Where is your raw data?
   - File path (CSV, Excel, RDS, etc.)
   - Database connection
   - API endpoint
   - We'll note this but load in Phase 2

### 2. Create Project Structure

I'll create this directory structure:

```
{project-name}/
├── .Rproj.user/           # RStudio settings (gitignored)
├── .git/                  # Git repository
├── .gitignore             # Git ignore rules
├── {project-name}.Rproj   # R project file
├── README.md              # Project documentation
├── renv/                  # renv infrastructure
├── renv.lock              # Dependency lock file
├── .Rprofile              # renv activation
├── data/
│   ├── raw/              # Original, immutable data
│   └── processed/        # Cleaned data (phase 3 output)
├── scripts/
│   ├── 01-setup.R        # This phase
│   ├── 02-import.R       # Phase 2
│   ├── 03-clean.R        # Phase 3
│   ├── 04-eda.R          # Phase 4
│   ├── 05-features.R     # Phase 5
│   ├── 06-model.R        # Phase 6
│   ├── 07-tune.R         # Phase 7
│   ├── 08-evaluate.R     # Phase 8
│   ├── 09-report.R       # Phase 9
│   └── 10-deploy.R       # Phase 10
├── outputs/
│   ├── figures/          # EDA plots, diagnostics
│   ├── models/           # Trained model objects
│   └── tables/           # Summary tables
├── reports/
│   ├── eda-report.qmd    # Phase 4 Quarto report
│   ├── model-report.qmd  # Phase 8 evaluation report
│   └── final-report.qmd  # Phase 9 stakeholder report
├── checkpoints/          # Phase completion markers
└── logs/                 # Execution logs
```

### 3. Initialize R Project

**Actions:**
- Create `.Rproj` file with recommended settings
- Set project options: UTF-8 encoding, no workspace save, clean environment on start

### 4. Initialize renv

**Actions:**
```r
# Initialize renv for dependency management
renv::init()

# Install core tidyverse/tidymodels packages
install.packages(c(
  "tidyverse",      # Data manipulation
  "tidymodels",     # Modeling framework
  "skimr",          # Data inspection
  "janitor",        # Data cleaning
  "here",           # Path management
  "conflicted"      # Conflict resolution
))

# Snapshot environment
renv::snapshot()
```

### 5. Initialize Git Repository

**Actions:**
```bash
git init
git add .
git commit -m "feat: initialize project structure

Project: {project-name}
Created: {date}
Framework: RDS full-lifecycle workflow

Co-Authored-By: Ada (Project Architect) <noreply@bmad.com>"
```

### 6. Create Initial Documentation

**Files to create:**

**README.md**:
```markdown
# {Project Name}

{Project Description}

## Project Structure

Created using BMAD RDS full-lifecycle workflow.

- `data/raw/`: Original data (never modified)
- `data/processed/`: Cleaned data
- `scripts/`: Analysis scripts (01-10)
- `outputs/`: Figures, models, tables
- `reports/`: Quarto reports

## Setup

```r
# Restore package environment
renv::restore()
```

## Workflow Phases

- [ ] Phase 1: Setup (Complete)
- [ ] Phase 2: Import & Inspect
- [ ] Phase 3: Clean Data
- [ ] Phase 4: EDA
- [ ] Phase 5: Feature Engineering
- [ ] Phase 6: Modeling
- [ ] Phase 7: Tuning
- [ ] Phase 8: Evaluation
- [ ] Phase 9: Communication
- [ ] Phase 10: Deploy

## Created

{Date} via BMAD RDS Module
```

**scripts/01-setup.R**:
```r
# Phase 1: Setup Project
# Created: {date}
# Owner: Ada

# Load core packages
library(tidyverse)
library(here)
library(conflicted)

# Resolve common conflicts
conflict_prefer("filter", "dplyr")
conflict_prefer("select", "dplyr")

# Project info
project_name <- "{project-name}"
project_description <- "{description}"

# Verify structure
stopifnot(
  dir.exists(here("data", "raw")),
  dir.exists(here("data", "processed")),
  dir.exists(here("scripts")),
  dir.exists(here("outputs", "figures")),
  dir.exists(here("outputs", "models")),
  dir.exists(here("outputs", "tables")),
  dir.exists(here("reports")),
  dir.exists(here("checkpoints"))
)

cat("Project setup complete!\n")
cat("Next: Phase 2 - Import & Inspect\n")

# Mark phase complete
writeLines(Sys.time() |> as.character(), here("checkpoints", "01-setup.complete"))
```

### 7. Verify Setup

**Validation checklist:**
- [ ] `.Rproj` file exists and opens in RStudio
- [ ] `renv.lock` created with core packages
- [ ] Git repository initialized with initial commit
- [ ] All directories created
- [ ] README.md populated
- [ ] `scripts/01-setup.R` runs without errors
- [ ] Checkpoint marker created

---

## Outputs

**Created Files:**
- Project structure (all directories)
- `{project-name}.Rproj`
- `renv.lock`
- `.gitignore`
- `README.md`
- `scripts/01-setup.R`
- `checkpoints/01-setup.complete`

**Git Commit:**
- Initial commit with project structure

---

## Troubleshooting

**Issue:** renv::init() fails
- **Solution**: Check internet connection, ensure write permissions

**Issue:** Git commit fails
- **Solution**: Configure git user.name and user.email globally

**Issue:** RStudio doesn't recognize .Rproj
- **Solution**: Close RStudio, double-click .Rproj file to reopen

---

## Next Phase

**Phase 2: Import & Inspect**

Once setup is complete, we'll:
1. Load your raw data into `data/raw/`
2. Run initial inspection with `glimpse()` and `skimr::skim()`
3. Document data quality issues
4. Create data dictionary

**Transition:** When ready, say "Continue to Phase 2" or "Load my data"

---

## Phase Completion

When this phase is complete:
1. Checkpoint file `checkpoints/01-setup.complete` created
2. Git commit made
3. README.md updated with completion status
4. Ready to proceed to Phase 2

**Expected Duration:** 30-60 minutes

---

_Phase 1 of 10 | Owner: Ada | RDS Module Full-Lifecycle Workflow_
