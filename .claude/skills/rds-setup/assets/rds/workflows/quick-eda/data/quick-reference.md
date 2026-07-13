# Quick-EDA Workflow: Quick Reference

**Version:** 1.0
**Created:** 2026-03-17
**Module:** RDS

---

## Workflow At-a-Glance

| Step | Name | Duration | Key Outputs |
|------|------|----------|-------------|
| 1 | Quick Setup | 30-60 min | Project structure, renv, starter scripts |
| 2 | Import Data | 15-30 min | data_raw.rds, import_report.rds |
| 3 | Quick Clean | 1-2 hours | data_clean.rds, cleaning_report.rds |
| 4 | EDA | 2-4 hours | eda-report.html, visualizations |

**Total Duration:** 4-8 hours

---

## Decision Trees

### When to Use Quick-EDA vs Full-EDA

**Use Quick-EDA when:**
- ✓ New dataset, first look
- ✓ Prototyping or proof-of-concept
- ✓ Time-sensitive analysis
- ✓ Low-stakes decision making
- ✓ Comfortable with automated decisions

**Use Full-EDA when:**
- ✓ Production pipeline development
- ✓ High-stakes decisions
- ✓ Complex data quality issues
- ✓ Need custom imputation strategies
- ✓ Domain expertise required for cleaning

---

## Automated Decisions Reference

### Step 3: Quick Clean

| Issue | Automated Decision | Override If... |
|-------|-------------------|----------------|
| Missing > 50% | Drop column | Domain knowledge suggests imputation |
| Missing numeric | Median impute | Distribution is highly skewed |
| Missing categorical | Mode impute | Need sophisticated imputation |
| Missing logical | FALSE | Different default makes sense |
| Outliers | Flag only | Known to be errors, not extremes |
| Duplicates | Remove | Duplicates are intentional |
| Empty rows/cols | Remove | They have metadata value |

---

## Package Requirements

### Essential (Step 1)
```r
c("dplyr", "tidyr", "readr", "ggplot2", "purrr",
  "tibble", "stringr", "forcats", "here", "fs",
  "skimr", "janitor", "naniar", "patchwork", "scales", "quarto")
```

### Import-Specific (Step 2)
```r
# Add as needed:
"readxl"      # Excel files
"haven"       # SPSS, Stata, SAS
"vroom"       # Large CSVs
"arrow"       # Parquet files
"jsonlite"    # JSON data
```

### EDA-Specific (Step 4)
```r
"corrplot"    # Correlation heatmaps
"GGally"      # Scatterplot matrices
```

---

## File Structure Reference

```
{project-name}/
├── .Rproj.user/
├── {project-name}.Rproj
├── renv/
│   ├── activate.R
│   └── library/
├── data/
│   ├── raw/
│   │   ├── {original-file}
│   │   ├── data_raw.rds
│   │   ├── import_report.rds
│   │   └── validation_results.rds
│   └── processed/
│       ├── data_clean.rds
│       ├── data_clean.csv
│       ├── cleaning_report.rds
│       ├── eda_summary.rds
│       └── correlation_matrix.rds
├── scripts/
│   ├── 01-import.R
│   ├── 02-clean.R
│   └── 03-eda.R
├── plots/
│   ├── 01-import-missing.png
│   ├── 03-clean-completeness.png
│   ├── 03-clean-types.png
│   ├── 04-eda-numeric-distributions.png
│   ├── 04-eda-categorical-frequencies.png
│   ├── 04-eda-correlation-heatmap.png
│   ├── 04-eda-scatterplot-matrix.png
│   ├── 04-eda-boxplots.png
│   ├── 04-eda-missing-by-variable.png
│   ├── 04-eda-missing-patterns.png
│   ├── 04-eda-outliers.png
│   ├── 04-eda-timeseries.png (if dates)
│   └── 04-eda-trends.png (if dates)
├── reports/
│   ├── eda-report.qmd
│   └── eda-report.html
├── README.md
└── .Rprofile
```

---

## Common Commands

### Setup
```r
# Initialize project
renv::init(bare = TRUE)
renv::install(c("tidyverse", "here", "skimr", "janitor"))
renv::snapshot()
```

### Import
```r
# Quick import
data_raw <- readr::read_csv("path/to/file.csv", guess_max = 10000)

# Save as RDS
saveRDS(data_raw, here::here("data/raw/data_raw.rds"))
```

### Clean
```r
# Quick clean pipeline
data_clean <- data_raw |>
  janitor::clean_names() |>
  janitor::remove_empty(c("rows", "cols")) |>
  dplyr::distinct()
```

### EDA
```r
# Quick summary
skimr::skim(data_clean)

# Quick viz
data_clean |>
  ggplot(aes(x = var1, y = var2)) +
  geom_point() +
  theme_minimal()
```

### Report
```r
# Render report
quarto::quarto_render(here::here("reports/eda-report.qmd"))
```

---

## Troubleshooting Quick Guide

| Problem | Quick Fix |
|---------|-----------|
| renv slow | Use binary packages: `options(pkgType = "binary")` |
| Import encoding errors | Try `locale = locale(encoding = "UTF-8")` |
| Memory issues | Use `vroom::vroom()` or sample data |
| Too many plots | Individual plots saved, review separately |
| Quarto fails | Check installation: `quarto --version` |
| Missing packages | Install: `renv::install("package_name")` |

---

## Grace Agent Integration

After completing quick-eda, consult Grace for:

1. **Deeper Analysis**
   - Statistical tests
   - Advanced modeling
   - Custom visualizations

2. **Next Steps**
   - Feature engineering strategies
   - Modeling approach recommendations
   - Full-EDA transition (if needed)

3. **Interpretation**
   - Pattern explanation
   - Anomaly investigation
   - Domain-specific insights

**Invoke:** `/bmad:rds:agents:grace`

---

## Quality Checks

### Before Moving to Analysis

- [ ] EDA report renders successfully
- [ ] All expected plots generated
- [ ] Correlation matrix makes sense
- [ ] Missing data patterns understood
- [ ] Outliers reviewed (not all are errors)
- [ ] Variable types appropriate
- [ ] No suspicious patterns in data

### Red Flags

- ⚠️ > 50% missing data in many columns
- ⚠️ All correlations near 0 or 1
- ⚠️ Bimodal distributions (may need stratification)
- ⚠️ Time series with sudden jumps (data quality issue?)
- ⚠️ Categorical variables with thousands of levels

---

## Extension Points

### Add Custom Steps

1. **Domain-Specific Cleaning**
   - Edit `scripts/02-clean.R`
   - Add business logic validation

2. **Custom Visualizations**
   - Edit `scripts/03-eda.R`
   - Create domain-specific plots

3. **Report Sections**
   - Edit `reports/eda-report.qmd`
   - Add custom analysis sections

### Save for Reuse

- Save custom scripts to templates
- Document domain-specific rules
- Create project-specific checklists

---

## Best Practices

1. **Document as you go** — Add comments to scripts
2. **Save intermediate results** — Use RDS for R objects
3. **Keep raw data untouched** — Never overwrite data/raw/
4. **Version control** — Use git for project tracking
5. **Share early** — Don't wait for perfection to share insights

---

_Quick reference created on 2026-03-17 for quick-eda workflow_
