# Phase 4: Exploratory Data Analysis (EDA)

**Owner:** Grace (Data Explorer)
**Duration:** 3-6 hours
**Status:** Active

---

## Phase Goal

Discover patterns, relationships, and insights in the cleaned data through systematic visualization and statistical exploration.

---

## Prerequisites

- Phase 3 complete (data cleaned and validated)
- Clean data available in `data/processed/clean_data.rds`
- `ggplot2`, `tidyverse`, and visualization packages installed

---

## Handoff from Ada

**Context from Ada:**
- Clean dataset ready: `{n_rows}` rows, `{n_cols}` columns
- Data quality issues resolved
- Ready for systematic exploration

**Grace's role:**
As the Data Explorer, I'll guide you through comprehensive EDA to uncover insights that will inform feature engineering and modeling.

---

## Step-by-Step Instructions

### 1. Setup EDA Environment

**Load packages and data:**
```r
library(tidyverse)
library(here)
library(skimr)
library(GGally)        # Pair plots
library(corrplot)      # Correlation plots
library(patchwork)     # Combine plots
library(scales)        # Formatting

# Load clean data
df <- read_rds(here("data", "processed", "clean_data.rds"))

# Create EDA script
# scripts/04-eda.R
```

### 2. Univariate Analysis

**Understand each variable individually:**

**Numeric Variables:**
```r
# Distribution plots for all numeric variables
numeric_vars <- df |> select(where(is.numeric)) |> names()

# Histograms
df |>
  select(all_of(numeric_vars)) |>
  pivot_longer(everything()) |>
  ggplot(aes(x = value)) +
  geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7) +
  facet_wrap(~name, scales = "free") +
  labs(title = "Distributions of Numeric Variables",
       caption = "Check for normality, skewness, multimodality") +
  theme_minimal()

ggsave(here("outputs", "figures", "eda_numeric_distributions.png"),
       width = 12, height = 10)

# Density plots with overlay
df |>
  select(all_of(numeric_vars)) |>
  pivot_longer(everything()) |>
  ggplot(aes(x = value, fill = name)) +
  geom_density(alpha = 0.5) +
  facet_wrap(~name, scales = "free") +
  labs(title = "Density Plots - Numeric Variables") +
  theme_minimal() +
  theme(legend.position = "none")

# Boxplots for outlier visualization
df |>
  select(all_of(numeric_vars)) |>
  pivot_longer(everything()) |>
  ggplot(aes(x = name, y = value)) +
  geom_boxplot(fill = "lightblue", outlier.color = "red") +
  facet_wrap(~name, scales = "free") +
  coord_flip() +
  labs(title = "Boxplots - Identify Remaining Outliers") +
  theme_minimal()

ggsave(here("outputs", "figures", "eda_numeric_boxplots.png"),
       width = 12, height = 10)

# Summary statistics table
numeric_summary <- df |>
  select(all_of(numeric_vars)) |>
  pivot_longer(everything()) |>
  group_by(name) |>
  summarise(
    mean = mean(value, na.rm = TRUE),
    median = median(value, na.rm = TRUE),
    sd = sd(value, na.rm = TRUE),
    min = min(value, na.rm = TRUE),
    max = max(value, na.rm = TRUE),
    q25 = quantile(value, 0.25, na.rm = TRUE),
    q75 = quantile(value, 0.75, na.rm = TRUE),
    skewness = e1071::skewness(value, na.rm = TRUE),
    kurtosis = e1071::kurtosis(value, na.rm = TRUE)
  )

write_csv(numeric_summary, here("outputs", "tables", "eda_numeric_summary.csv"))
```

**Categorical Variables:**
```r
categorical_vars <- df |> select(where(is.character) | where(is.factor)) |> names()

# Bar plots for categorical variables
df |>
  select(all_of(categorical_vars)) |>
  pivot_longer(everything()) |>
  count(name, value) |>
  group_by(name) |>
  mutate(prop = n / sum(n)) |>
  ggplot(aes(x = reorder(value, n), y = n)) +
  geom_col(fill = "coral") +
  geom_text(aes(label = scales::comma(n)), hjust = -0.2, size = 3) +
  coord_flip() +
  facet_wrap(~name, scales = "free") +
  labs(title = "Categorical Variable Frequencies",
       x = NULL, y = "Count") +
  theme_minimal()

ggsave(here("outputs", "figures", "eda_categorical_frequencies.png"),
       width = 12, height = 10)

# Frequency tables
categorical_summary <- df |>
  select(all_of(categorical_vars)) |>
  map_df(~ tibble(
    n_unique = n_distinct(.x),
    most_common = names(sort(table(.x), decreasing = TRUE))[1],
    most_common_freq = max(table(.x)),
    most_common_pct = round(max(table(.x)) / length(.x) * 100, 1)
  ), .id = "variable")

write_csv(categorical_summary, here("outputs", "tables", "eda_categorical_summary.csv"))
```

### 3. Bivariate Analysis

**Relationships between variables:**

**Target Variable Analysis** (if supervised learning):
```r
# Identify target variable
target_var <- "{your_target}"  # e.g., "churn", "price", "outcome"

# Numeric predictors vs target
if (is.numeric(df[[target_var]])) {
  # Continuous target: scatterplots
  df |>
    select(all_of(c(numeric_vars, target_var))) |>
    select(-any_of(target_var)) |>
    pivot_longer(-all_of(target_var), names_to = "predictor") |>
    ggplot(aes(x = value, y = .data[[target_var]])) +
    geom_point(alpha = 0.3) +
    geom_smooth(method = "loess", color = "red") +
    facet_wrap(~predictor, scales = "free_x") +
    labs(title = paste("Predictors vs", target_var)) +
    theme_minimal()
} else {
  # Categorical target: boxplots
  df |>
    select(all_of(c(numeric_vars, target_var))) |>
    pivot_longer(-all_of(target_var), names_to = "predictor") |>
    ggplot(aes(x = .data[[target_var]], y = value, fill = .data[[target_var]])) +
    geom_boxplot() +
    facet_wrap(~predictor, scales = "free_y") +
    labs(title = paste("Predictors by", target_var)) +
    theme_minimal() +
    theme(legend.position = "none")
}

ggsave(here("outputs", "figures", "eda_target_relationships.png"),
       width = 14, height = 10)

# Categorical predictors vs target
if (is.numeric(df[[target_var]])) {
  # Continuous target: bar plot with error bars
  df |>
    select(all_of(c(categorical_vars, target_var))) |>
    pivot_longer(-all_of(target_var), names_to = "predictor") |>
    group_by(predictor, value) |>
    summarise(
      mean_target = mean(.data[[target_var]], na.rm = TRUE),
      se = sd(.data[[target_var]], na.rm = TRUE) / sqrt(n())
    ) |>
    ggplot(aes(x = value, y = mean_target)) +
    geom_col(fill = "steelblue") +
    geom_errorbar(aes(ymin = mean_target - se, ymax = mean_target + se), width = 0.2) +
    facet_wrap(~predictor, scales = "free") +
    coord_flip() +
    labs(title = paste("Mean", target_var, "by Category")) +
    theme_minimal()
} else {
  # Categorical target: stacked bars
  df |>
    select(all_of(c(categorical_vars, target_var))) |>
    pivot_longer(-all_of(target_var), names_to = "predictor") |>
    count(predictor, value, .data[[target_var]]) |>
    group_by(predictor, value) |>
    mutate(prop = n / sum(n)) |>
    ggplot(aes(x = value, y = prop, fill = .data[[target_var]])) +
    geom_col() +
    facet_wrap(~predictor, scales = "free") +
    coord_flip() +
    labs(title = paste(target_var, "Distribution by Category")) +
    theme_minimal()
}

ggsave(here("outputs", "figures", "eda_categorical_target.png"),
       width = 14, height = 10)
```

**Correlation Analysis:**
```r
# Correlation matrix
cor_matrix <- df |>
  select(where(is.numeric)) |>
  cor(use = "pairwise.complete.obs")

# Visualize correlation
png(here("outputs", "figures", "eda_correlation_matrix.png"),
    width = 1200, height = 1000)
corrplot(cor_matrix,
         method = "color",
         type = "upper",
         tl.col = "black",
         tl.srt = 45,
         addCoef.col = "black",
         number.cex = 0.7)
dev.off()

# High correlations (multicollinearity check)
high_cor <- cor_matrix |>
  as.data.frame() |>
  rownames_to_column("var1") |>
  pivot_longer(-var1, names_to = "var2", values_to = "correlation") |>
  filter(var1 != var2) |>
  filter(abs(correlation) > 0.7) |>
  arrange(desc(abs(correlation))) |>
  distinct(correlation, .keep_all = TRUE)

write_csv(high_cor, here("outputs", "tables", "eda_high_correlations.csv"))
```

**Pairwise Plots** (for key variables):
```r
# Select top 5-8 most important variables for pair plot
key_vars <- c(target_var, "{var1}", "{var2}", "{var3}", "{var4}")

df |>
  select(all_of(key_vars)) |>
  GGally::ggpairs(
    aes(alpha = 0.3),
    lower = list(continuous = "smooth"),
    diag = list(continuous = "barDiag")
  ) +
  labs(title = "Pairwise Relationships - Key Variables") +
  theme_minimal()

ggsave(here("outputs", "figures", "eda_pairplot.png"),
       width = 14, height = 14)
```

### 4. Multivariate Analysis

**Interactions and patterns:**

```r
# Three-way relationships
# Example: numeric vs numeric, colored by categorical
df |>
  ggplot(aes(x = {var1}, y = {var2}, color = {cat_var})) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Interaction Effect: {var1} vs {var2} by {cat_var}") +
  theme_minimal()

ggsave(here("outputs", "figures", "eda_interaction_plot.png"),
       width = 10, height = 7)

# Faceted analysis
df |>
  ggplot(aes(x = {var1}, y = target_var)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "loess") +
  facet_grid({cat_var1} ~ {cat_var2}) +
  labs(title = "Faceted Relationships") +
  theme_minimal()

ggsave(here("outputs", "figures", "eda_faceted_analysis.png"),
       width = 12, height = 10)
```

### 5. Pattern Discovery

**Look for insights:**

```r
# Time-based patterns (if temporal data)
if (any(sapply(df, lubridate::is.Date))) {
  date_var <- names(df)[sapply(df, lubridate::is.Date)][1]

  df |>
    mutate(
      year = lubridate::year(.data[[date_var]]),
      month = lubridate::month(.data[[date_var]]),
      weekday = lubridate::wday(.data[[date_var]], label = TRUE)
    ) |>
    group_by(year, month) |>
    summarise(count = n(), .groups = "drop") |>
    ggplot(aes(x = month, y = count, group = year, color = factor(year))) +
    geom_line() +
    geom_point() +
    labs(title = "Temporal Patterns", color = "Year") +
    theme_minimal()

  ggsave(here("outputs", "figures", "eda_temporal_patterns.png"),
         width = 10, height = 6)
}

# Segmentation analysis (clustering visualization)
# Simple k-means on scaled numeric data
numeric_data <- df |>
  select(where(is.numeric)) |>
  scale() |>
  as_tibble()

set.seed(123)
kmeans_result <- kmeans(numeric_data, centers = 3)

df |>
  mutate(cluster = factor(kmeans_result$cluster)) |>
  ggplot(aes(x = {var1}, y = {var2}, color = cluster)) +
  geom_point(alpha = 0.6) +
  labs(title = "Exploratory Clustering (k=3)") +
  theme_minimal()

ggsave(here("outputs", "figures", "eda_clustering.png"),
       width = 10, height = 7)
```

### 6. Generate EDA Report

I'll create a comprehensive Quarto report:

**`reports/eda-report.qmd`:**
```markdown
---
title: "Exploratory Data Analysis Report"
subtitle: "{Project Name}"
author: "Grace (Data Explorer)"
date: today
format:
  html:
    code-fold: true
    toc: true
    toc-depth: 3
    theme: cosmo
execute:
  echo: true
  warning: false
  message: false
---

## Executive Summary

**Dataset:** {n_rows} observations, {n_cols} variables
**Analysis Date:** {date}
**Key Findings:**
- {finding 1}
- {finding 2}
- {finding 3}

## 1. Data Overview

```{r}
library(tidyverse)
library(here)
library(skimr)

df <- read_rds(here("data", "processed", "clean_data.rds"))
skim(df)
```

## 2. Univariate Analysis

### Numeric Variables
- Distribution shapes (normal, skewed, bimodal)
- Outliers and extreme values
- Central tendency and spread

### Categorical Variables
- Level frequencies
- Dominant categories
- Rare categories (consider grouping)

## 3. Bivariate Analysis

### Correlations
- Strong positive/negative correlations
- Multicollinearity concerns
- Target variable relationships

### Target Variable Insights
- Which predictors show strongest relationships?
- Non-linear patterns identified
- Interaction effects observed

## 4. Key Insights

### Patterns Discovered
1. {Pattern description}
2. {Pattern description}

### Anomalies Detected
1. {Anomaly description}
2. {Anomaly description}

### Recommendations for Feature Engineering
1. {Recommendation}
2. {Recommendation}

## 5. Next Steps

**Phase 5: Feature Engineering priorities:**
- Create interaction terms for: {variables}
- Transform skewed variables: {variables}
- Encode categorical variables: {method}
- Consider polynomial features for: {variables}

---

*Generated by Grace (Data Explorer) | Phase 4/10 | RDS Module*
```

Render report:
```r
quarto::quarto_render(here("reports", "eda-report.qmd"))
```

### 7. Document Insights

Create `outputs/tables/phase04-eda-insights.md`:

```markdown
# Phase 4: EDA Insights

**Analyst:** Grace (Data Explorer)
**Date:** {date}

## Key Findings

### 1. Data Characteristics
- {n_rows} observations across {n_cols} variables
- {n_numeric} numeric, {n_categorical} categorical
- Target variable: {name}, type: {type}

### 2. Distribution Insights
- Normal distributions: {list}
- Skewed distributions: {list} (consider log transform)
- Multimodal: {list} (potential sub-populations)

### 3. Relationship Strength
**Strong predictors** (|cor| > 0.5 with target):
- {var}: r = {value}
- {var}: r = {value}

**Weak predictors** (|cor| < 0.2):
- {list} (consider dropping)

### 4. Multicollinearity
Variables with high correlation (|r| > 0.7):
- {var1} ↔ {var2}: r = {value}
- Action: {keep one, create composite, use PCA}

### 5. Patterns & Anomalies
- **Pattern**: {description}
- **Anomaly**: {description}
- **Seasonality**: {if temporal data}

### 6. Data Quality Notes
- Remaining outliers: {list}
- Suspicious values: {list}
- Consider re-cleaning: {yes/no}

## Recommendations for Feature Engineering

### Priority 1: Transformations
- Log transform: {variables} (reduce skewness)
- Polynomial: {variables} (capture non-linearity)

### Priority 2: Interactions
- {var1} × {var2}: shows strong interaction in faceted plots
- {var1} × {var2}: different slopes per category

### Priority 3: Encodings
- One-hot encode: {variables with few levels}
- Target encode: {high-cardinality variables}
- Ordinal encode: {ordered categories}

### Priority 4: Feature Creation
- Ratios: {var1}/{var2}
- Aggregates: {describe}
- Domain-specific: {describe}

## Next Phase Preparation

**Handoff to Phase 5 (Feature Engineering):**
- EDA complete and insights documented
- Feature engineering priorities identified
- Ready for systematic feature creation
- Grace will continue to lead Phase 5

**Estimated Phase 5 duration:** 2-4 hours
```

### 8. Validation Checklist

Before proceeding to Phase 5:

- [ ] All numeric variables visualized and summarized
- [ ] All categorical variables analyzed
- [ ] Target variable relationships explored
- [ ] Correlation matrix created and reviewed
- [ ] High correlations flagged
- [ ] Pairwise plots generated for key variables
- [ ] Patterns and anomalies documented
- [ ] EDA report rendered successfully
- [ ] Insights and recommendations documented
- [ ] Feature engineering priorities identified

---

## Outputs

**Created Files:**
- `scripts/04-eda.R`
- `outputs/figures/eda_numeric_distributions.png`
- `outputs/figures/eda_numeric_boxplots.png`
- `outputs/figures/eda_categorical_frequencies.png`
- `outputs/figures/eda_target_relationships.png`
- `outputs/figures/eda_categorical_target.png`
- `outputs/figures/eda_correlation_matrix.png`
- `outputs/figures/eda_pairplot.png`
- `outputs/figures/eda_interaction_plot.png`
- `outputs/figures/eda_temporal_patterns.png` (if applicable)
- `outputs/figures/eda_clustering.png`
- `outputs/tables/eda_numeric_summary.csv`
- `outputs/tables/eda_categorical_summary.csv`
- `outputs/tables/eda_high_correlations.csv`
- `outputs/tables/phase04-eda-insights.md`
- `reports/eda-report.html`
- `checkpoints/04-eda.complete`

**Git Commit:**
```bash
git add scripts/04-eda.R outputs/ reports/
git commit -m "feat: complete exploratory data analysis

- Generate {n_plots} visualizations
- Identify {n_insights} key insights
- Create comprehensive EDA report
- Document feature engineering priorities

Phase 4/10 complete

Co-Authored-By: Grace (Data Explorer) <noreply@bmad.com>"
```

---

## Troubleshooting

**Issue:** Too many variables to visualize
- **Solution**: Focus on top 10-15 by correlation with target, create separate analysis for others

**Issue:** Pairplot takes too long
- **Solution**: Sample data or reduce to 5-6 key variables

**Issue:** Quarto report won't render
- **Solution**: Check package installations, render chunks individually to find error

**Issue:** Can't identify clear patterns
- **Solution**: Try different aggregations, consider domain expertise consultation

---

## Next Phase

**Phase 5: Feature Engineering**

With EDA insights, Grace will continue to:
1. Transform skewed variables
2. Create interaction terms
3. Encode categorical variables
4. Generate polynomial features
5. Build domain-specific features
6. Prepare final feature set for modeling

**Transition:** When ready, say "Continue to Phase 5" or "Start feature engineering"

---

## Phase Completion

When this phase is complete:
1. All visualizations created and saved
2. EDA report rendered
3. Insights and patterns documented
4. Feature engineering priorities identified
5. Checkpoint file created
6. Git commit made
7. **Grace continues to Phase 5**

**Expected Duration:** 3-6 hours

---

_Phase 4 of 10 | Owner: Grace | RDS Module Full-Lifecycle Workflow_
