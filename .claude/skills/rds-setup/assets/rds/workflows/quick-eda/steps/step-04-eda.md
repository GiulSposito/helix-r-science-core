# Step 4: EDA

**Duration:** 2-4 hours
**Goal:** Generate comprehensive exploratory data analysis with visualizations

---

## Overview

This step creates a rich, interactive EDA report using automated visualization and summary statistics. The output is a standalone HTML document that provides deep insights into your data's structure, distributions, relationships, and quality.

---

## Step Instructions

### 1. Load Cleaned Data

**Setup EDA environment:**

```r
# Quick-EDA: Exploratory Data Analysis
# Step 4 of quick-eda workflow

library(here)
library(dplyr)
library(tidyr)
library(ggplot2)
library(patchwork)
library(skimr)
library(naniar)
library(corrplot)
library(scales)

# Load cleaned data
data_clean <- readRDS(here("data/processed/data_clean.rds"))
cleaning_report <- readRDS(here("data/processed/cleaning_report.rds"))

message("📊 Starting exploratory data analysis...")
message(sprintf("  Data: %d rows × %d cols", nrow(data_clean), ncol(data_clean)))
```

---

### 2. Comprehensive Data Summary

**Generate detailed statistics:**

```r
# ══════════════════════════════════════════════════════════════
# Section 1: Comprehensive Data Summary
# ══════════════════════════════════════════════════════════════

# Skim summary (comprehensive)
data_summary <- skim(data_clean)
print(data_summary)

# Save summary for report
saveRDS(data_summary, here("data/processed/eda_summary.rds"))

# Key metrics
eda_metrics <- list(
  n_rows = nrow(data_clean),
  n_cols = ncol(data_clean),
  n_numeric = sum(sapply(data_clean, is.numeric)),
  n_factor = sum(sapply(data_clean, is.factor)),
  n_character = sum(sapply(data_clean, is.character)),
  n_logical = sum(sapply(data_clean, is.logical)),
  n_date = sum(sapply(data_clean, lubridate::is.Date)),
  memory_size = format(object.size(data_clean), units = "auto"),
  complete_rows = sum(complete.cases(data_clean)),
  complete_pct = mean(complete.cases(data_clean))
)

print(eda_metrics)
```

---

### 3. Univariate Analysis

**Analyze each variable individually:**

```r
# ══════════════════════════════════════════════════════════════
# Section 2: Univariate Analysis
# ══════════════════════════════════════════════════════════════

# Numeric variables: distributions
numeric_vars <- data_clean |>
  select(where(is.numeric)) |>
  names()

if (length(numeric_vars) > 0) {
  message(sprintf("\n📈 Analyzing %d numeric variables...", length(numeric_vars)))

  # Create histogram for each numeric variable
  numeric_plots <- list()

  for (var in numeric_vars) {
    p <- data_clean |>
      ggplot(aes(x = .data[[var]])) +
      geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7) +
      geom_density(aes(y = after_stat(count)), color = "darkred", linewidth = 1) +
      labs(
        title = paste("Distribution:", var),
        x = var,
        y = "Count"
      ) +
      theme_minimal()

    numeric_plots[[var]] <- p

    # Save individual plot
    ggsave(
      here(sprintf("plots/04-eda-dist-%s.png", var)),
      p,
      width = 8,
      height = 6,
      dpi = 300
    )
  }

  # Combined plot (up to 12 variables)
  if (length(numeric_vars) <= 12) {
    combined_numeric <- wrap_plots(numeric_plots, ncol = 3)

    ggsave(
      here("plots/04-eda-numeric-distributions.png"),
      combined_numeric,
      width = 15,
      height = 12,
      dpi = 300
    )

    message("  ✓ Numeric distribution plots created")
  }
}

# Categorical variables: bar charts
factor_vars <- data_clean |>
  select(where(is.factor)) |>
  names()

if (length(factor_vars) > 0) {
  message(sprintf("\n📊 Analyzing %d categorical variables...", length(factor_vars)))

  factor_plots <- list()

  for (var in factor_vars) {
    p <- data_clean |>
      count(.data[[var]], sort = TRUE) |>
      slice_max(n, n = 20) |>  # Top 20 levels only
      ggplot(aes(x = reorder(.data[[var]], n), y = n)) +
      geom_col(fill = "darkgreen", alpha = 0.7) +
      coord_flip() +
      labs(
        title = paste("Frequency:", var),
        x = var,
        y = "Count"
      ) +
      theme_minimal()

    factor_plots[[var]] <- p

    ggsave(
      here(sprintf("plots/04-eda-bar-%s.png", var)),
      p,
      width = 8,
      height = 6,
      dpi = 300
    )
  }

  # Combined plot (up to 12 variables)
  if (length(factor_vars) <= 12) {
    combined_factors <- wrap_plots(factor_plots, ncol = 3)

    ggsave(
      here("plots/04-eda-categorical-frequencies.png"),
      combined_factors,
      width = 15,
      height = 12,
      dpi = 300
    )

    message("  ✓ Categorical frequency plots created")
  }
}
```

---

### 4. Bivariate Analysis

**Explore relationships between variables:**

```r
# ══════════════════════════════════════════════════════════════
# Section 3: Bivariate Analysis
# ══════════════════════════════════════════════════════════════

# Correlation matrix for numeric variables
if (length(numeric_vars) > 1) {
  message("\n🔗 Computing correlations...")

  cor_matrix <- data_clean |>
    select(all_of(numeric_vars)) |>
    cor(use = "complete.obs")

  # Correlation heatmap
  png(here("plots/04-eda-correlation-heatmap.png"), width = 10, height = 10, units = "in", res = 300)
  corrplot(
    cor_matrix,
    method = "color",
    type = "upper",
    order = "hclust",
    tl.col = "black",
    tl.srt = 45,
    addCoef.col = "black",
    number.cex = 0.7
  )
  dev.off()

  # Find high correlations (|r| > 0.7)
  high_cor <- cor_matrix |>
    as.data.frame() |>
    tibble::rownames_to_column("var1") |>
    pivot_longer(-var1, names_to = "var2", values_to = "correlation") |>
    filter(var1 != var2, abs(correlation) > 0.7) |>
    arrange(desc(abs(correlation))) |>
    distinct(correlation, .keep_all = TRUE)

  if (nrow(high_cor) > 0) {
    message("\n⚠ High correlations detected:")
    print(high_cor)
  }

  saveRDS(cor_matrix, here("data/processed/correlation_matrix.rds"))
  message("  ✓ Correlation analysis complete")
}

# Scatterplot matrix (for up to 6 numeric variables)
if (length(numeric_vars) >= 2 && length(numeric_vars) <= 6) {
  message("\n🔍 Creating scatterplot matrix...")

  pairs_plot <- GGally::ggpairs(
    data_clean |> select(all_of(numeric_vars)),
    upper = list(continuous = GGally::wrap("cor", size = 3)),
    lower = list(continuous = GGally::wrap("points", alpha = 0.3)),
    diag = list(continuous = GGally::wrap("densityDiag"))
  ) +
    theme_minimal()

  ggsave(
    here("plots/04-eda-scatterplot-matrix.png"),
    pairs_plot,
    width = 12,
    height = 12,
    dpi = 300
  )

  message("  ✓ Scatterplot matrix created")
}

# Categorical vs numeric relationships
if (length(factor_vars) > 0 && length(numeric_vars) > 0) {
  message("\n📦 Creating boxplots for categorical vs numeric...")

  # Create boxplots for first factor vs all numeric
  main_factor <- factor_vars[1]

  boxplot_list <- list()

  for (num_var in numeric_vars[1:min(6, length(numeric_vars))]) {
    p <- data_clean |>
      ggplot(aes(x = .data[[main_factor]], y = .data[[num_var]])) +
      geom_boxplot(fill = "lightblue", alpha = 0.7) +
      coord_flip() +
      labs(
        title = paste(num_var, "by", main_factor),
        x = main_factor,
        y = num_var
      ) +
      theme_minimal()

    boxplot_list[[num_var]] <- p
  }

  combined_boxplots <- wrap_plots(boxplot_list, ncol = 2)

  ggsave(
    here("plots/04-eda-boxplots.png"),
    combined_boxplots,
    width = 12,
    height = 10,
    dpi = 300
  )

  message("  ✓ Boxplots created")
}
```

---

### 5. Missing Data Patterns

**Visualize missingness:**

```r
# ══════════════════════════════════════════════════════════════
# Section 4: Missing Data Patterns
# ══════════════════════════════════════════════════════════════

message("\n❓ Analyzing missing data patterns...")

# Missing data summary
miss_summary <- miss_var_summary(data_clean)
print(miss_summary)

# Visualizations
miss_var_plot <- gg_miss_var(data_clean, show_pct = TRUE) +
  labs(title = "Missing Data by Variable") +
  theme_minimal()

ggsave(
  here("plots/04-eda-missing-by-variable.png"),
  miss_var_plot,
  width = 10,
  height = 8,
  dpi = 300
)

# Missing pattern plot
miss_pattern <- gg_miss_upset(data_clean) +
  labs(title = "Missing Data Patterns")

ggsave(
  here("plots/04-eda-missing-patterns.png"),
  miss_pattern,
  width = 12,
  height = 8,
  dpi = 300
)

message("  ✓ Missing data analysis complete")
```

---

### 6. Outlier Analysis

**Visual outlier detection:**

```r
# ══════════════════════════════════════════════════════════════
# Section 5: Outlier Analysis
# ══════════════════════════════════════════════════════════════

message("\n🎯 Analyzing outliers...")

# Boxplots for all numeric variables
if (length(numeric_vars) > 0) {
  outlier_plots <- list()

  for (var in numeric_vars) {
    p <- data_clean |>
      ggplot(aes(y = .data[[var]])) +
      geom_boxplot(fill = "coral", alpha = 0.7) +
      labs(
        title = paste("Outliers:", var),
        y = var
      ) +
      theme_minimal() +
      theme(axis.text.x = element_blank())

    outlier_plots[[var]] <- p
  }

  # Combined outlier plot
  if (length(numeric_vars) <= 12) {
    combined_outliers <- wrap_plots(outlier_plots, ncol = 4)

    ggsave(
      here("plots/04-eda-outliers.png"),
      combined_outliers,
      width = 15,
      height = 10,
      dpi = 300
    )
  }

  # Outlier counts
  outlier_flags <- data_clean |>
    select(ends_with("_outlier"))

  if (ncol(outlier_flags) > 0) {
    outlier_summary <- outlier_flags |>
      summarise(across(everything(), sum, na.rm = TRUE)) |>
      pivot_longer(everything(), names_to = "variable", values_to = "outlier_count") |>
      filter(outlier_count > 0) |>
      arrange(desc(outlier_count))

    print(outlier_summary)
  }

  message("  ✓ Outlier analysis complete")
}
```

---

### 7. Time Series Analysis (if applicable)

**Temporal patterns:**

```r
# ══════════════════════════════════════════════════════════════
# Section 6: Time Series Analysis (if date columns exist)
# ══════════════════════════════════════════════════════════════

date_cols <- data_clean |>
  select(where(lubridate::is.Date) | where(lubridate::is.POSIXct)) |>
  names()

if (length(date_cols) > 0) {
  message(sprintf("\n📅 Analyzing %d date columns...", length(date_cols)))

  main_date <- date_cols[1]

  # Time series of row counts
  ts_plot <- data_clean |>
    count(.data[[main_date]]) |>
    ggplot(aes(x = .data[[main_date]], y = n)) +
    geom_line(color = "steelblue", linewidth = 1) +
    geom_smooth(method = "loess", se = TRUE, color = "darkred") +
    labs(
      title = paste("Time Series: Record Count by", main_date),
      x = main_date,
      y = "Count"
    ) +
    theme_minimal()

  ggsave(
    here("plots/04-eda-timeseries.png"),
    ts_plot,
    width = 12,
    height = 6,
    dpi = 300
  )

  # If numeric variables exist, plot trends
  if (length(numeric_vars) > 0) {
    trend_plots <- list()

    for (var in numeric_vars[1:min(4, length(numeric_vars))]) {
      p <- data_clean |>
        ggplot(aes(x = .data[[main_date]], y = .data[[var]])) +
        geom_line(alpha = 0.5, color = "gray") +
        geom_smooth(method = "loess", color = "darkblue") +
        labs(
          title = paste(var, "over time"),
          x = main_date,
          y = var
        ) +
        theme_minimal()

      trend_plots[[var]] <- p
    }

    combined_trends <- wrap_plots(trend_plots, ncol = 2)

    ggsave(
      here("plots/04-eda-trends.png"),
      combined_trends,
      width = 12,
      height = 10,
      dpi = 300
    )
  }

  message("  ✓ Time series analysis complete")
}
```

---

### 8. Generate EDA Report (Quarto)

**Create comprehensive HTML report:**

```r
# ══════════════════════════════════════════════════════════════
# Section 7: Generate Comprehensive EDA Report
# ══════════════════════════════════════════════════════════════

message("\n📝 Generating EDA report...")

# Create Quarto report template
report_template <- here("reports/eda-report.qmd")

# Generate report content
report_content <- sprintf('---
title: "Quick-EDA Report"
subtitle: "Exploratory Data Analysis"
author: "Generated by BMAD Quick-EDA Workflow"
date: "%s"
format:
  html:
    toc: true
    toc-depth: 3
    toc-location: left
    code-fold: true
    theme: cosmo
    embed-resources: true
execute:
  echo: false
  warning: false
  message: false
---

```{r setup}
library(here)
library(dplyr)
library(knitr)
library(DT)

data_clean <- readRDS(here("data/processed/data_clean.rds"))
cleaning_report <- readRDS(here("data/processed/cleaning_report.rds"))
eda_summary <- readRDS(here("data/processed/eda_summary.rds"))
```

# Executive Summary

## Dataset Overview

- **Rows:** %d
- **Columns:** %d
- **Numeric Variables:** %d
- **Categorical Variables:** %d
- **Memory Size:** %s
- **Complete Cases:** %d (%.1f%%)

## Data Quality

- **Input Dimensions:** %d rows × %d columns
- **Output Dimensions:** %d rows × %d columns
- **Rows Removed:** %d (%.1f%%)
- **Columns Dropped:** %d
- **Missing Values Handled:** %d

---

# Data Summary

## Comprehensive Statistics

```{r}
as.data.frame(eda_summary) |>
  DT::datatable(
    options = list(pageLength = 20, scrollX = TRUE),
    filter = "top"
  )
```

---

# Univariate Analysis

## Numeric Variables

```{r}
knitr::include_graphics(here("plots/04-eda-numeric-distributions.png"))
```

## Categorical Variables

```{r}
if (file.exists(here("plots/04-eda-categorical-frequencies.png"))) {
  knitr::include_graphics(here("plots/04-eda-categorical-frequencies.png"))
}
```

---

# Bivariate Analysis

## Correlation Matrix

```{r}
if (file.exists(here("plots/04-eda-correlation-heatmap.png"))) {
  knitr::include_graphics(here("plots/04-eda-correlation-heatmap.png"))
}
```

## Scatterplot Matrix

```{r}
if (file.exists(here("plots/04-eda-scatterplot-matrix.png"))) {
  knitr::include_graphics(here("plots/04-eda-scatterplot-matrix.png"))
}
```

## Categorical vs Numeric

```{r}
if (file.exists(here("plots/04-eda-boxplots.png"))) {
  knitr::include_graphics(here("plots/04-eda-boxplots.png"))
}
```

---

# Missing Data

## Missing by Variable

```{r}
knitr::include_graphics(here("plots/04-eda-missing-by-variable.png"))
```

## Missing Patterns

```{r}
knitr::include_graphics(here("plots/04-eda-missing-patterns.png"))
```

---

# Outlier Analysis

```{r}
if (file.exists(here("plots/04-eda-outliers.png"))) {
  knitr::include_graphics(here("plots/04-eda-outliers.png"))
}
```

---

# Time Series Analysis

```{r}
if (file.exists(here("plots/04-eda-timeseries.png"))) {
  knitr::include_graphics(here("plots/04-eda-timeseries.png"))
}
```

```{r}
if (file.exists(here("plots/04-eda-trends.png"))) {
  knitr::include_graphics(here("plots/04-eda-trends.png"))
}
```

---

# Data Sample

```{r}
data_clean |>
  head(100) |>
  DT::datatable(
    options = list(pageLength = 10, scrollX = TRUE),
    filter = "top"
  )
```

---

# Recommendations

Based on this exploratory analysis:

1. **Data Quality:** Review variables with high missing rates
2. **Correlations:** Investigate high correlations (potential multicollinearity)
3. **Outliers:** Examine flagged outliers for validity
4. **Next Steps:** Consider modeling approaches based on variable distributions

---

*Report generated on %s by BMAD Quick-EDA Workflow (v6.0.0-alpha.23)*
',
Sys.Date(),
eda_metrics$n_rows,
eda_metrics$n_cols,
eda_metrics$n_numeric,
eda_metrics$n_factor + eda_metrics$n_character,
eda_metrics$memory_size,
eda_metrics$complete_rows,
eda_metrics$complete_pct * 100,
cleaning_report$input_dims["rows"],
cleaning_report$input_dims["cols"],
cleaning_report$output_dims["rows"],
cleaning_report$output_dims["cols"],
cleaning_report$rows_removed,
cleaning_report$rows_removed / cleaning_report$input_dims["rows"] * 100,
length(cleaning_report$columns_dropped),
cleaning_report$missing_handled,
Sys.time()
)

# Write report template
writeLines(report_content, report_template)

# Render report
quarto::quarto_render(report_template)

message("  ✓ EDA report generated: reports/eda-report.html")
```

---

## Step Completion

**Verify:**

1. ✓ Comprehensive data summary generated
2. ✓ Univariate analysis complete (distributions, frequencies)
3. ✓ Bivariate analysis complete (correlations, relationships)
4. ✓ Missing data patterns visualized
5. ✓ Outliers analyzed and visualized
6. ✓ Time series analysis (if applicable)
7. ✓ All plots saved to plots/ directory
8. ✓ Quarto report rendered as HTML

**Output:**

```
╔══════════════════════════════════════════════════════════════╗
║                   STEP 4 COMPLETE                            ║
║                   EDA Complete!                              ║
╚══════════════════════════════════════════════════════════════╝

✓ Exploratory data analysis complete
✓ Generated {N} visualizations
✓ HTML report: reports/eda-report.html

Key Findings:
  • Dataset: {n_rows} rows × {n_cols} cols
  • Numeric variables: {n_numeric}
  • Categorical variables: {n_categorical}
  • Complete cases: {complete_pct}%
  • High correlations: {n_high_cor} pairs

Files created:
  • reports/eda-report.html — Comprehensive EDA report
  • plots/04-eda-*.png — {N} visualization files
  • data/processed/eda_summary.rds — Summary statistics
  • data/processed/correlation_matrix.rds — Correlation data

Duration: ~{X} hours

═══════════════════════════════════════════════════════════════

🎉 Quick-EDA Workflow Complete!

Your data is ready for analysis. Next steps:
  1. Review the EDA report (reports/eda-report.html)
  2. Investigate interesting patterns or anomalies
  3. Consult Grace agent for deeper analysis (/bmad:rds:agents:grace)
  4. Consider full-eda workflow for production pipelines

Happy analyzing! 📊
```

---

## EDA Report Structure

The generated HTML report includes:

1. **Executive Summary**
   - Dataset dimensions
   - Data quality metrics
   - Cleaning summary

2. **Data Summary**
   - Interactive table with comprehensive statistics
   - Filterable and sortable

3. **Univariate Analysis**
   - Distribution plots for numeric variables
   - Frequency charts for categorical variables

4. **Bivariate Analysis**
   - Correlation heatmap
   - Scatterplot matrix
   - Categorical vs numeric boxplots

5. **Missing Data**
   - Missing data by variable
   - Missing data patterns

6. **Outlier Analysis**
   - Boxplots highlighting outliers
   - Outlier counts and flags

7. **Time Series** (if applicable)
   - Temporal trends
   - Time-based patterns

8. **Data Sample**
   - Interactive preview of first 100 rows

9. **Recommendations**
   - Automated insights based on analysis

---

## Best Practices

1. **Review report systematically** — Don't skip sections
2. **Investigate anomalies** — High correlations, outliers, missing patterns
3. **Document insights** — Add notes to your project README
4. **Share with stakeholders** — Report is self-contained HTML
5. **Iterate if needed** — Re-run specific visualizations as needed

---

## Troubleshooting

**Issue:** Quarto rendering fails
- **Solution:** Check that quarto is installed (`quarto --version`), install if needed

**Issue:** Too many variables for combined plots
- **Solution:** Individual plots still generated, review them separately

**Issue:** Memory issues with large datasets
- **Solution:** Sample data for visualization: `data_clean |> slice_sample(n = 10000)`

**Issue:** Report takes too long to render
- **Solution:** Reduce image resolution (dpi = 150 instead of 300)

---

_Step created on 2026-03-17 for quick-eda workflow_
