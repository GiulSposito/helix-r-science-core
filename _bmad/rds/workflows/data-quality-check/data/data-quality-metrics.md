# Data Quality Metrics Reference

**Purpose:** Comprehensive reference for data quality assessment metrics used throughout the data-quality-check workflow.

**Version:** 1.0.0
**Last Updated:** 2026-03-17
**Module:** RDS (R Data Science)

---

## Overview

Data quality is **multidimensional**. A single metric like "percent complete" is insufficient. This reference provides metrics across six quality dimensions:

1. **Completeness** — Extent of missing data
2. **Validity** — Conformance to defined rules
3. **Accuracy** — Correctness of values
4. **Consistency** — Agreement across sources/time
5. **Uniqueness** — Absence of duplicates
6. **Timeliness** — Recency and currency

---

## 1. Completeness Metrics

### 1.1 Variable-Level Completeness

**Missing Rate (Variable)**

```r
missing_rate_var <- function(x) {
  mean(is.na(x)) * 100
}
```

- **Range:** 0-100%
- **Interpretation:** Lower is better
- **Threshold:** <5% excellent, 5-15% acceptable, >15% concern

**Complete Rate (Variable)**

```r
complete_rate_var <- function(x) {
  mean(!is.na(x)) * 100
}
```

- **Range:** 0-100%
- **Interpretation:** Higher is better
- **Threshold:** >95% excellent, 85-95% acceptable, <85% concern

---

### 1.2 Case-Level Completeness

**Missing Rate (Case)**

```r
missing_rate_case <- function(data) {
  rowMeans(is.na(data)) * 100
}
```

- **Range:** 0-100%
- **Interpretation:** % of variables missing per case
- **Threshold:** <10% per case acceptable

**Complete Case Rate**

```r
complete_case_rate <- function(data) {
  mean(complete.cases(data)) * 100
}
```

- **Range:** 0-100%
- **Interpretation:** % of cases with no missing values
- **Threshold:** >80% excellent, 60-80% acceptable, <60% poor

---

### 1.3 Pattern Metrics

**Missing Pattern Diversity**

```r
missing_pattern_diversity <- function(data) {
  patterns <- data %>%
    mutate(across(everything(), is.na)) %>%
    distinct()
  nrow(patterns)
}
```

- **Interpretation:** Number of unique missing patterns
- **High diversity:** Random/MCAR likely
- **Low diversity:** Systematic/MAR likely

**Missing Correlation Matrix**

```r
missing_correlation <- function(data) {
  missing_indicators <- data %>%
    mutate(across(everything(), ~as.integer(is.na(.))))
  cor(missing_indicators)
}
```

- **Range:** -1 to 1
- **High positive correlation:** Variables missing together (MAR)
- **Near zero:** Independent missing (MCAR)

---

## 2. Validity Metrics

### 2.1 Range Validity

**Range Violation Rate**

```r
range_violation_rate <- function(x, min_val, max_val) {
  violations <- sum(x < min_val | x > max_val, na.rm = TRUE)
  violations / length(x) * 100
}
```

- **Range:** 0-100%
- **Interpretation:** % of values outside valid range
- **Threshold:** 0% expected, >1% investigate

**Domain Compliance Rate**

```r
domain_compliance_rate <- function(x, valid_values) {
  compliant <- sum(x %in% valid_values, na.rm = TRUE)
  compliant / length(x) * 100
}
```

- **Range:** 0-100%
- **Interpretation:** % of values in allowed set
- **Threshold:** 100% expected for categorical

---

### 2.2 Format Validity

**Format Compliance Rate**

```r
format_compliance_rate <- function(x, pattern) {
  compliant <- sum(str_detect(x, pattern), na.rm = TRUE)
  compliant / length(x) * 100
}
```

- **Range:** 0-100%
- **Interpretation:** % matching expected format (e.g., ID, date, email)
- **Threshold:** 100% expected for structured fields

---

### 2.3 Type Validity

**Type Mismatch Rate**

```r
type_mismatch_rate <- function(x, expected_type) {
  actual_type <- class(x)[1]
  if (actual_type != expected_type) 100 else 0
}
```

- **Values:** 0% or 100%
- **Interpretation:** Binary check for correct data type
- **Threshold:** 0% (no mismatches)

---

## 3. Accuracy Metrics

### 3.1 Outlier Metrics

**IQR Outlier Rate**

```r
iqr_outlier_rate <- function(x, k = 1.5) {
  q1 <- quantile(x, 0.25, na.rm = TRUE)
  q3 <- quantile(x, 0.75, na.rm = TRUE)
  iqr <- q3 - q1
  outliers <- sum(x < q1 - k*iqr | x > q3 + k*iqr, na.rm = TRUE)
  outliers / length(x) * 100
}
```

- **Range:** 0-100%
- **Interpretation:** % of outliers by IQR method
- **Expected:** ~0.7% for normal distribution (k=1.5)

**Z-Score Outlier Rate**

```r
zscore_outlier_rate <- function(x, threshold = 3) {
  z <- abs(scale(x))
  outliers <- sum(z > threshold, na.rm = TRUE)
  outliers / length(x) * 100
}
```

- **Range:** 0-100%
- **Interpretation:** % of outliers by Z-score
- **Expected:** ~0.3% for normal distribution (threshold=3)

---

### 3.2 Distribution Metrics

**Skewness**

```r
skewness <- function(x) {
  moments::skewness(x, na.rm = TRUE)
}
```

- **Range:** -∞ to +∞
- **Interpretation:**
  - ≈ 0: Symmetric
  - > 0: Right-skewed
  - < 0: Left-skewed
- **Threshold:** |skew| < 1 acceptable, |skew| > 2 highly skewed

**Kurtosis**

```r
kurtosis <- function(x) {
  moments::kurtosis(x, na.rm = TRUE) - 3 # Excess kurtosis
}
```

- **Range:** -∞ to +∞
- **Interpretation:**
  - ≈ 0: Normal tails
  - > 0: Heavy tails (outliers)
  - < 0: Light tails
- **Threshold:** |kurtosis| < 3 acceptable

---

## 4. Consistency Metrics

### 4.1 Internal Consistency

**Cross-Variable Consistency Rate**

```r
consistency_rate <- function(data, rule_function) {
  consistent <- rule_function(data)
  sum(consistent, na.rm = TRUE) / nrow(data) * 100
}

# Example: end_date >= start_date
date_consistency <- consistency_rate(data, function(d) d$end_date >= d$start_date)
```

- **Range:** 0-100%
- **Interpretation:** % of cases satisfying business rule
- **Threshold:** 100% expected

**Part-Whole Consistency**

```r
partwhole_consistency <- function(total, parts, tolerance = 0.01) {
  sum_parts <- rowSums(parts, na.rm = TRUE)
  consistent <- abs(total - sum_parts) <= tolerance
  sum(consistent, na.rm = TRUE) / length(total) * 100
}
```

- **Range:** 0-100%
- **Interpretation:** % of cases where parts sum to whole
- **Threshold:** 100% expected (with tolerance for rounding)

---

### 4.2 Temporal Consistency

**Sequence Violation Rate**

```r
sequence_violation_rate <- function(timestamps) {
  violations <- sum(diff(timestamps) < 0, na.rm = TRUE)
  violations / (length(timestamps) - 1) * 100
}
```

- **Range:** 0-100%
- **Interpretation:** % of out-of-order sequences
- **Threshold:** 0% expected

---

### 4.3 Referential Integrity

**Orphan Record Rate**

```r
orphan_rate <- function(child_keys, parent_keys) {
  orphans <- sum(!child_keys %in% parent_keys)
  orphans / length(child_keys) * 100
}
```

- **Range:** 0-100%
- **Interpretation:** % of child records without parent
- **Threshold:** 0% expected

---

## 5. Uniqueness Metrics

### 5.1 Duplicate Detection

**Duplicate Rate**

```r
duplicate_rate <- function(x) {
  duplicates <- sum(duplicated(x))
  duplicates / length(x) * 100
}
```

- **Range:** 0-100%
- **Interpretation:** % of duplicate values
- **Threshold:** 0% for unique keys, variable for other fields

**Uniqueness Rate**

```r
uniqueness_rate <- function(x) {
  n_distinct(x) / length(x) * 100
}
```

- **Range:** 0-100%
- **Interpretation:** % unique values
- **Threshold:** 100% for unique identifiers

---

### 5.2 Record Duplication

**Exact Duplicate Record Rate**

```r
exact_duplicate_rate <- function(data) {
  duplicates <- sum(duplicated(data))
  duplicates / nrow(data) * 100
}
```

- **Range:** 0-100%
- **Interpretation:** % of completely identical rows
- **Threshold:** 0% expected

---

## 6. Timeliness Metrics

### 6.1 Currency

**Data Freshness (Days)**

```r
data_freshness <- function(timestamp_col) {
  as.numeric(difftime(Sys.Date(), max(timestamp_col), units = "days"))
}
```

- **Range:** 0 to ∞
- **Interpretation:** Days since most recent record
- **Threshold:** Domain-specific (daily = <1, weekly = <7, etc.)

**Stale Record Rate**

```r
stale_rate <- function(timestamps, threshold_days = 30) {
  stale <- sum(difftime(Sys.Date(), timestamps, units = "days") > threshold_days)
  stale / length(timestamps) * 100
}
```

- **Range:** 0-100%
- **Interpretation:** % of records older than threshold
- **Threshold:** Domain-specific

---

## Composite Quality Scores

### Overall Data Quality Score

**Weighted Average Method**

```r
data_quality_score <- function(metrics, weights = NULL) {
  if (is.null(weights)) {
    weights <- rep(1, length(metrics)) / length(metrics)
  }

  score <- sum(metrics * weights)
  return(score)
}

# Example
overall_score <- data_quality_score(
  metrics = c(
    complete_rate = 95,
    validity_rate = 98,
    consistency_rate = 92,
    uniqueness_rate = 100
  ),
  weights = c(0.3, 0.3, 0.3, 0.1)
)
```

- **Range:** 0-100
- **Interpretation:**
  - 90-100: Excellent
  - 80-89: Good
  - 70-79: Acceptable
  - 60-69: Poor
  - <60: Unacceptable

---

### Record-Level Quality Score

**Per-Record Consistency Score**

```r
record_quality_score <- function(data, checks) {
  # checks is list of functions that return TRUE/FALSE
  scores <- sapply(checks, function(check) check(data))
  rowMeans(scores) * 100
}

# Example
record_scores <- record_quality_score(
  data = data,
  checks = list(
    no_missing = function(d) complete.cases(d),
    valid_range = function(d) d$age >= 0 & d$age <= 120,
    date_logic = function(d) d$end_date >= d$start_date,
    valid_category = function(d) d$category %in% valid_categories
  )
)
```

- **Range:** 0-100 per record
- **Interpretation:** % of quality checks passed
- **Use:** Flag low-scoring records for review

---

## Benchmark Thresholds

### Industry Standards

| Dimension | Metric | Excellent | Good | Acceptable | Poor |
|-----------|--------|-----------|------|------------|------|
| Completeness | Complete rate | >95% | 90-95% | 80-90% | <80% |
| Validity | Domain compliance | 100% | 99-99.9% | 95-99% | <95% |
| Accuracy | Outlier rate | <1% | 1-3% | 3-5% | >5% |
| Consistency | Rule compliance | 100% | 99-99.9% | 95-99% | <95% |
| Uniqueness | Duplicate rate | 0% | <0.1% | 0.1-1% | >1% |
| Overall | Quality score | 90-100 | 80-89 | 70-79 | <70 |

---

### Context-Specific Thresholds

**Exploratory Analysis:**
- More lenient (70-80% acceptable)
- Focus on understanding, not perfection

**Confirmatory Analysis:**
- Stricter (90%+ required)
- Quality affects statistical validity

**Production Systems:**
- Strictest (95%+ required)
- Quality critical for decisions

**Regulatory Environments:**
- Near-perfect (99%+ required)
- Compliance and audit requirements

---

## Missing Data Mechanisms

### Test Statistics

**Little's MCAR Test**

```r
# Requires naniar or mcar package
mcar_test <- function(data) {
  naniar::mcar_test(data)
}
```

- **Null hypothesis:** Data is MCAR
- **Interpretation:**
  - p > 0.05: Cannot reject MCAR
  - p < 0.05: Data is NOT MCAR (likely MAR/MNAR)

---

## Outlier Detection Thresholds

### Statistical Methods

| Method | Threshold | Expected Rate (Normal) | Use Case |
|--------|-----------|----------------------|-----------|
| IQR (k=1.5) | Q1-1.5×IQR, Q3+1.5×IQR | 0.7% | General purpose |
| IQR (k=3) | Q1-3×IQR, Q3+3×IQR | 0.002% | Conservative |
| Z-score | |Z| > 3 | 0.3% | Normal distributions |
| Z-score | |Z| > 2.5 | 1.2% | Sensitive |
| Modified Z | |Mod Z| > 3.5 | Variable | Skewed data |

---

## Usage Examples

### Complete Quality Assessment

```r
# Calculate all metrics
quality_metrics <- list(
  completeness = list(
    complete_case_rate = mean(complete.cases(data)) * 100,
    avg_missing_per_var = mean(colMeans(is.na(data))) * 100
  ),

  validity = list(
    range_violations = sum(data$age < 0 | data$age > 120),
    format_violations = sum(!str_detect(data$id, "^\\d{8}$"))
  ),

  accuracy = list(
    iqr_outliers = mean(sapply(data %>% select(where(is.numeric)),
                                iqr_outlier_rate)),
    zscore_outliers = mean(sapply(data %>% select(where(is.numeric)),
                                   zscore_outlier_rate))
  ),

  consistency = list(
    date_consistency = consistency_rate(data,
                                        function(d) d$end >= d$start),
    sum_consistency = partwhole_consistency(data$total, data %>% select(starts_with("part")))
  ),

  uniqueness = list(
    id_uniqueness = uniqueness_rate(data$id),
    duplicate_records = exact_duplicate_rate(data)
  )
)

# Overall score
overall_quality <- data_quality_score(
  metrics = c(
    quality_metrics$completeness$complete_case_rate,
    100 - quality_metrics$validity$range_violations / nrow(data) * 100,
    100 - quality_metrics$accuracy$iqr_outliers,
    quality_metrics$consistency$date_consistency,
    quality_metrics$uniqueness$id_uniqueness
  )
)

cat(sprintf("Overall Data Quality Score: %.1f/100\n", overall_quality))
```

---

## References

### Academic

- Rubin, D. B. (1976). Inference and missing data. *Biometrika*, 63(3), 581-592.
- Tukey, J. W. (1977). *Exploratory data analysis*. Addison-Wesley.
- van Buuren, S. (2018). *Flexible Imputation of Missing Data* (2nd ed.). CRC Press.

### Packages

- **naniar:** Missing data visualization and analysis
- **visdat:** Quick visual data exploration
- **mice:** Multiple imputation
- **isotree:** Isolation forests for anomaly detection
- **assertr:** Data validation and testing

---

## Updates

**v1.0.0 (2026-03-17):**
- Initial reference created
- Six quality dimensions defined
- Benchmarks established
- Usage examples added

---

_Reference created on 2026-03-17 for data-quality-check workflow (RDS Module)_
