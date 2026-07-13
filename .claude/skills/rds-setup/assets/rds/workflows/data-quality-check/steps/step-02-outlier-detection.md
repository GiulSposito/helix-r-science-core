# Step 2: Outlier Detection

**Goal:** Systematically identify outliers using multiple methods

**Duration:** 1-2 hours

---

## Overview

Not all outliers are errors. Some are legitimate extreme values that contain valuable information. This step uses multiple detection methods to identify potential outliers, then helps you distinguish between:

- **Errors:** Data entry mistakes, measurement failures (should be removed)
- **Legitimate extremes:** Rare but valid observations (should be kept)
- **Influential points:** Values that strongly affect analysis (flag for sensitivity)

---

## Detection Methods

### Method 1: IQR (Interquartile Range)

**Best for:** Univariate outliers, robust to skewness

```r
library(dplyr)
library(ggplot2)

# Function to detect IQR outliers
detect_iqr_outliers <- function(x, k = 1.5) {
  q1 <- quantile(x, 0.25, na.rm = TRUE)
  q3 <- quantile(x, 0.75, na.rm = TRUE)
  iqr <- q3 - q1

  lower_bound <- q1 - k * iqr
  upper_bound <- q3 + k * iqr

  outliers <- x < lower_bound | x > upper_bound

  list(
    outliers = outliers,
    lower_bound = lower_bound,
    upper_bound = upper_bound,
    n_outliers = sum(outliers, na.rm = TRUE)
  )
}

# Apply to all numeric variables
numeric_vars <- data %>% select(where(is.numeric)) %>% names()

iqr_results <- map(numeric_vars, function(var) {
  result <- detect_iqr_outliers(data[[var]])
  tibble(
    variable = var,
    n_outliers = result$n_outliers,
    pct_outliers = result$n_outliers / nrow(data) * 100,
    lower_bound = result$lower_bound,
    upper_bound = result$upper_bound
  )
}) %>%
  bind_rows() %>%
  arrange(desc(pct_outliers))

print(iqr_results)
```

**Tuning k:**
- k = 1.5: Standard (Tukey's fences)
- k = 3.0: More conservative (extreme outliers only)

---

### Method 2: Z-Score

**Best for:** Normally distributed data, easy interpretation

```r
# Function to detect Z-score outliers
detect_zscore_outliers <- function(x, threshold = 3) {
  z_scores <- abs(scale(x))
  outliers <- z_scores > threshold

  list(
    outliers = outliers,
    z_scores = z_scores,
    n_outliers = sum(outliers, na.rm = TRUE)
  )
}

# Apply to numeric variables
zscore_results <- map(numeric_vars, function(var) {
  result <- detect_zscore_outliers(data[[var]])
  tibble(
    variable = var,
    n_outliers = result$n_outliers,
    pct_outliers = result$n_outliers / nrow(data) * 100,
    max_zscore = max(result$z_scores, na.rm = TRUE)
  )
}) %>%
  bind_rows() %>%
  arrange(desc(pct_outliers))

print(zscore_results)
```

**Threshold Guidelines:**
- |Z| > 3: Standard (99.7% of normal data within)
- |Z| > 2.5: More sensitive
- |Z| > 4: Very conservative

**Warning:** Z-score assumes normality. Check distributions first.

---

### Method 3: Modified Z-Score (Robust)

**Best for:** Skewed distributions, presence of outliers

```r
# Modified Z-score using median and MAD
detect_modified_zscore <- function(x, threshold = 3.5) {
  med <- median(x, na.rm = TRUE)
  mad <- mad(x, na.rm = TRUE, constant = 1.4826) # constant makes MAD consistent with SD

  modified_z <- 0.6745 * (x - med) / mad
  outliers <- abs(modified_z) > threshold

  list(
    outliers = outliers,
    modified_z = modified_z,
    n_outliers = sum(outliers, na.rm = TRUE)
  )
}

# Apply to numeric variables
modified_z_results <- map(numeric_vars, function(var) {
  result <- detect_modified_zscore(data[[var]])
  tibble(
    variable = var,
    n_outliers = result$n_outliers,
    pct_outliers = result$n_outliers / nrow(data) * 100
  )
}) %>%
  bind_rows() %>%
  arrange(desc(pct_outliers))
```

---

### Method 4: Isolation Forest (Multivariate)

**Best for:** High-dimensional data, detecting multivariate anomalies

```r
library(isotree)

# Select numeric variables for isolation forest
numeric_data <- data %>%
  select(where(is.numeric)) %>%
  drop_na()

# Fit isolation forest
iso_model <- isolation.forest(
  numeric_data,
  ntrees = 100,
  sample_size = min(256, nrow(numeric_data)),
  ndim = 2
)

# Predict anomaly scores
anomaly_scores <- predict(iso_model, numeric_data)

# Flag outliers (higher score = more anomalous)
threshold <- quantile(anomaly_scores, 0.95) # Top 5% as outliers
multivariate_outliers <- anomaly_scores > threshold

cat(sprintf("Multivariate outliers detected: %d (%.1f%%)\n",
            sum(multivariate_outliers),
            mean(multivariate_outliers) * 100))
```

---

### Method 5: Domain-Specific Rules

**Best for:** Business logic, known physical constraints

```r
# Define domain rules
domain_outliers <- data %>%
  mutate(
    # Age rules
    age_invalid = age < 0 | age > 120,

    # Price rules
    price_invalid = price < 0,

    # Date rules
    date_invalid = date > Sys.Date() | date < as.Date("1900-01-01"),

    # Percentage rules
    pct_invalid = percentage < 0 | percentage > 100,

    # Business logic
    logic_invalid = end_date < start_date,

    # Flag any domain violation
    domain_flag = age_invalid | price_invalid | date_invalid |
                  pct_invalid | logic_invalid
  )

# Summary of domain violations
domain_summary <- domain_outliers %>%
  summarise(
    age_violations = sum(age_invalid, na.rm = TRUE),
    price_violations = sum(price_invalid, na.rm = TRUE),
    date_violations = sum(date_invalid, na.rm = TRUE),
    pct_violations = sum(pct_invalid, na.rm = TRUE),
    logic_violations = sum(logic_invalid, na.rm = TRUE),
    total_violations = sum(domain_flag, na.rm = TRUE)
  )

print(domain_summary)
```

**{user_name}, define your domain rules:**
- What are the valid ranges for each variable?
- Are there physical/business constraints?
- Are there impossible combinations?

---

## Visualization

### Univariate Outliers

```r
# Boxplots for all numeric variables
data %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  ggplot(aes(x = variable, y = value)) +
  geom_boxplot(outlier.color = "red", outlier.alpha = 0.5) +
  facet_wrap(~variable, scales = "free") +
  theme_minimal() +
  labs(title = "Outlier Detection: Boxplots",
       subtitle = "Red points indicate potential outliers")

# Histograms with flagged outliers
for (var in numeric_vars) {
  outliers <- detect_iqr_outliers(data[[var]])$outliers

  p <- data %>%
    mutate(outlier_flag = outliers) %>%
    ggplot(aes(x = .data[[var]], fill = outlier_flag)) +
    geom_histogram(bins = 30, alpha = 0.7) +
    scale_fill_manual(values = c("grey70", "red")) +
    labs(title = paste("Distribution of", var),
         subtitle = paste(sum(outliers, na.rm = TRUE), "outliers detected")) +
    theme_minimal()

  print(p)
}
```

### Multivariate Outliers

```r
# Anomaly score distribution
tibble(anomaly_score = anomaly_scores) %>%
  ggplot(aes(x = anomaly_score)) +
  geom_histogram(bins = 50, fill = "steelblue", alpha = 0.7) +
  geom_vline(xintercept = threshold, color = "red", linetype = "dashed") +
  labs(title = "Isolation Forest Anomaly Scores",
       subtitle = paste("Threshold:", round(threshold, 3))) +
  theme_minimal()

# Bivariate plot with multivariate outliers highlighted
data %>%
  mutate(multivariate_outlier = multivariate_outliers) %>%
  ggplot(aes(x = var1, y = var2, color = multivariate_outlier)) +
  geom_point(alpha = 0.6) +
  scale_color_manual(values = c("grey70", "red")) +
  labs(title = "Multivariate Outliers") +
  theme_minimal()
```

---

## Consensus Analysis

Combine results from multiple methods:

```r
# Create outlier flags dataset
outlier_flags <- tibble(
  row_id = 1:nrow(data),
  iqr_flag = rowSums(sapply(numeric_vars, function(v) detect_iqr_outliers(data[[v]])$outliers)) > 0,
  zscore_flag = rowSums(sapply(numeric_vars, function(v) detect_zscore_outliers(data[[v]])$outliers)) > 0,
  modified_z_flag = rowSums(sapply(numeric_vars, function(v) detect_modified_zscore(data[[v]])$outliers)) > 0,
  multivariate_flag = multivariate_outliers,
  domain_flag = domain_outliers$domain_flag,

  # Consensus: flagged by multiple methods
  consensus_score = iqr_flag + zscore_flag + modified_z_flag + multivariate_flag + domain_flag
)

# Cases flagged by multiple methods
high_confidence_outliers <- outlier_flags %>%
  filter(consensus_score >= 3)

cat(sprintf("High-confidence outliers (3+ methods): %d cases\n",
            nrow(high_confidence_outliers)))
```

---

## Distinguish Errors from Extremes

For each flagged case, investigate:

```r
# Examine flagged cases
flagged_data <- data %>%
  mutate(row_id = 1:nrow(data)) %>%
  inner_join(outlier_flags, by = "row_id") %>%
  filter(consensus_score >= 2) %>%
  arrange(desc(consensus_score))

# Show top outliers for review
flagged_data %>%
  select(row_id, consensus_score, all_of(numeric_vars)) %>%
  head(20)
```

**Decision Framework:**

| Evidence | Classification | Action |
|----------|---------------|---------|
| Impossible value (age=200) | Error | Remove or correct |
| Violates business logic | Error | Remove or correct |
| Extreme but plausible | Legitimate | Keep, document |
| Inconsistent with pattern | Possible error | Flag for manual review |
| Influential in models | Legitimate extreme | Keep, sensitivity analysis |

---

## Ada's Guidance

{user_name}, let's review your outliers systematically:

### Questions to Ask

1. **What's the data collection process?**
   - Manual entry? (higher error rate)
   - Automated sensors? (check calibration)
   - Survey responses? (check attention checks)

2. **Are outliers clustered?**
   - Same time period? (batch processing error)
   - Same location? (regional difference or error)
   - Same data source? (systematic bias)

3. **Do outliers make domain sense?**
   - Income of $1,000,000: Possible (rare but real)
   - Age of 200: Impossible (definitely error)
   - Temperature of 150°F: Depends on context

4. **What's the impact of removal?**
   - <1% of data: Usually safe to remove errors
   - 5-10% of data: Investigate carefully
   - >10% of data: May indicate data quality issues, not outliers

---

## Red Flags

**STOP and investigate if:**
- ❌ >10% of observations flagged as outliers (too many = problem with data or detection)
- ❌ Outliers clustered in time/space (systematic error)
- ❌ Domain rule violations (fundamental data quality issue)
- ❌ All outliers in one direction (skewness, not outliers)

---

## Deliverables

### Outlier Report

Create `outlier_report.html`:

```r
# Save outlier analysis
outlier_summary <- list(
  iqr_results = iqr_results,
  zscore_results = zscore_results,
  modified_z_results = modified_z_results,
  multivariate_results = tibble(
    n_outliers = sum(multivariate_outliers),
    threshold = threshold
  ),
  domain_results = domain_summary,
  consensus = outlier_flags,
  flagged_cases = flagged_data
)

saveRDS(outlier_summary, "outlier_summary.rds")

# Generate report
render("outlier_report.Rmd", output_file = "outlier_report.html")
```

**Report Contents:**
1. Detection results from all methods
2. Consensus analysis
3. Visualizations (boxplots, anomaly scores)
4. Flagged cases for review
5. Recommended actions

---

## Output for Next Step

```r
# Create flagged dataset for consistency checks
data_with_flags <- data %>%
  mutate(
    outlier_flag = outlier_flags$consensus_score >= 2,
    outlier_method = case_when(
      outlier_flags$domain_flag ~ "domain_rule",
      outlier_flags$consensus_score >= 3 ~ "multiple_methods",
      outlier_flags$multivariate_flag ~ "multivariate",
      TRUE ~ "univariate"
    )
  )

saveRDS(data_with_flags, "data_with_outlier_flags.rds")
```

---

## Next Step

Proceed to **Step 3: Consistency Checks** when:
- You've identified and classified outliers
- You've documented findings in outlier_report.html
- You understand which outliers are errors vs. extremes
- You know your remediation strategy for Step 4

---

**Ada's Tip:** Don't automatically remove all outliers. Extreme values often contain the most interesting information. Remove only those you're confident are errors, and document your reasoning.

---

_Step created on 2026-03-17 for data-quality-check workflow_
