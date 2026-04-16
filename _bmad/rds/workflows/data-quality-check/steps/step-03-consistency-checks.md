# Step 3: Consistency Checks

**Goal:** Validate cross-variable relationships and business logic

**Duration:** 1-2 hours

---

## Overview

Data can pass univariate checks (no missing values, no outliers) but still contain logical inconsistencies. This step validates:

- **Range constraints:** Variables within expected bounds
- **Cross-variable relationships:** Logical dependencies between variables
- **Business rules:** Domain-specific validation logic
- **Temporal consistency:** Time-related constraints
- **Referential integrity:** ID/key relationships

---

## Check Categories

### 1. Range Validation

Verify all variables are within acceptable ranges:

```r
library(dplyr)
library(assertr)

# Define range constraints
range_checks <- list(
  age = c(0, 120),
  price = c(0, Inf),
  temperature = c(-50, 150),
  percentage = c(0, 100),
  rating = c(1, 5)
)

# Check ranges
range_violations <- data %>%
  verify(age >= 0 & age <= 120) %>%
  verify(price >= 0) %>%
  verify(percentage >= 0 & percentage <= 100)
  # Add your specific checks

# Alternative: programmatic checking
check_ranges <- function(data, ranges) {
  results <- map_dfr(names(ranges), function(var) {
    if (var %in% names(data)) {
      min_val <- ranges[[var]][1]
      max_val <- ranges[[var]][2]

      below_min <- sum(data[[var]] < min_val, na.rm = TRUE)
      above_max <- sum(data[[var]] > max_val, na.rm = TRUE)

      tibble(
        variable = var,
        min_allowed = min_val,
        max_allowed = max_val,
        below_min = below_min,
        above_max = above_max,
        total_violations = below_min + above_max,
        pct_violations = total_violations / nrow(data) * 100
      )
    }
  })
  results
}

range_results <- check_ranges(data, range_checks)
print(range_results)
```

**{user_name}, define your acceptable ranges:**
- What are min/max values for each variable?
- Are there context-dependent ranges (e.g., adult vs child)?

---

### 2. Cross-Variable Consistency

Validate relationships between variables:

```r
# Date consistency
date_violations <- data %>%
  filter(
    !is.na(start_date) & !is.na(end_date),
    end_date < start_date
  )

cat(sprintf("Date logic violations: %d cases\n", nrow(date_violations)))

# Hierarchical consistency (child <= parent)
hierarchy_violations <- data %>%
  filter(
    !is.na(subcategory_sales) & !is.na(category_sales),
    subcategory_sales > category_sales
  )

# Part-whole consistency
partwhole_violations <- data %>%
  rowwise() %>%
  mutate(
    sum_parts = sum(c_across(starts_with("part_")), na.rm = TRUE),
    diff = abs(total - sum_parts)
  ) %>%
  filter(diff > 0.01) # Allow small rounding errors

# Conditional requirements
conditional_violations <- data %>%
  filter(
    # If married, must have spouse info
    (marital_status == "married" & is.na(spouse_name)) |
    # If employed, must have employer
    (employment_status == "employed" & is.na(employer)) |
    # If has children, age must be reasonable
    (has_children == TRUE & age < 18)
  )
```

**Common Cross-Variable Checks:**

| Check Type | Example | Validation |
|-----------|---------|------------|
| Temporal | birth_date < death_date | end >= start |
| Hierarchical | city in state | subcategory in category |
| Part-whole | sum(parts) == total | components <= whole |
| Conditional | if A then B | dependency satisfied |
| Mutual exclusion | not(A and B) | only one true |

---

### 3. Business Rule Validation

Apply domain-specific logic:

```r
# Define business rules
business_violations <- data %>%
  mutate(
    # Rule 1: Discounted price < original price
    rule1_violated = discount_price >= original_price,

    # Rule 2: Free shipping only for orders >$50
    rule2_violated = (free_shipping == TRUE & order_total < 50),

    # Rule 3: Premium members get priority
    rule3_violated = (membership == "basic" & priority_flag == TRUE),

    # Rule 4: Age-gated content
    rule4_violated = (content_rating == "18+" & user_age < 18),

    # Rule 5: Geographic restrictions
    rule5_violated = (product_category == "alcohol" & country %in% c("SA", "UAE")),

    # Any rule violated
    any_violation = rule1_violated | rule2_violated | rule3_violated |
                    rule4_violated | rule5_violated
  )

# Summary of business rule violations
business_summary <- business_violations %>%
  summarise(
    across(starts_with("rule"), ~sum(.x, na.rm = TRUE), .names = "{.col}_count")
  )

print(business_summary)
```

**{user_name}, define your business rules:**
- What are the business constraints?
- Are there regulatory requirements?
- What combinations are impossible/prohibited?

---

### 4. Temporal Consistency

Check time-related constraints:

```r
# Future dates
future_dates <- data %>%
  select(where(~inherits(.x, "Date") | inherits(.x, "POSIXct"))) %>%
  summarise(
    across(everything(), ~sum(.x > Sys.Date(), na.rm = TRUE), .names = "{.col}_future")
  )

# Sequence validation
sequence_violations <- data %>%
  arrange(id, timestamp) %>%
  group_by(id) %>%
  mutate(
    time_diff = as.numeric(difftime(timestamp, lag(timestamp), units = "hours"))
  ) %>%
  filter(
    # Negative time differences (out of order)
    time_diff < 0 |
    # Implausibly short intervals
    time_diff < 0.01
  )

# Age consistency
age_violations <- data %>%
  filter(
    !is.na(birth_date),
    as.numeric(difftime(Sys.Date(), birth_date, units = "days")) / 365.25 != age
  )
```

---

### 5. Referential Integrity

Validate ID/key relationships:

```r
# Check for orphaned records (foreign key without parent)
orphaned_records <- data %>%
  anti_join(parent_table, by = "parent_id")

cat(sprintf("Orphaned records: %d\n", nrow(orphaned_records)))

# Check for duplicate IDs
duplicate_ids <- data %>%
  group_by(id) %>%
  filter(n() > 1)

cat(sprintf("Duplicate IDs: %d\n", n_distinct(duplicate_ids$id)))

# Validate ID format
invalid_ids <- data %>%
  filter(
    # Check ID format (example: must be 8 digits)
    !str_detect(id, "^\\d{8}$") |
    # Check prefix requirements
    !str_starts(product_id, "PRD-")
  )
```

---

### 6. Statistical Consistency

Check for statistical anomalies:

```r
# Suspicious distributions
dist_checks <- data %>%
  summarise(
    across(where(is.numeric), list(
      mean = ~mean(.x, na.rm = TRUE),
      median = ~median(.x, na.rm = TRUE),
      sd = ~sd(.x, na.rm = TRUE),
      skew = ~moments::skewness(.x, na.rm = TRUE)
    ))
  )

# Benford's Law (first digit distribution)
# Useful for detecting fabricated data
benford_check <- data %>%
  filter(amount > 0) %>%
  mutate(first_digit = as.numeric(str_sub(as.character(floor(amount)), 1, 1))) %>%
  count(first_digit) %>%
  mutate(
    observed_pct = n / sum(n) * 100,
    benford_pct = log10(1 + 1/first_digit) * 100,
    diff = abs(observed_pct - benford_pct)
  )

# Chi-square test for Benford's Law
benford_test <- chisq.test(benford_check$n, p = log10(1 + 1/1:9))
print(benford_test)
```

---

## Visualization

### Consistency Violation Heatmap

```r
library(ggplot2)

# Create violation matrix
violation_matrix <- tibble(
  check_type = c("Range", "Cross-Variable", "Business Rules",
                 "Temporal", "Referential", "Statistical"),
  violations = c(
    sum(range_results$total_violations),
    nrow(date_violations) + nrow(hierarchy_violations),
    sum(business_summary),
    nrow(sequence_violations) + nrow(future_dates),
    nrow(orphaned_records) + nrow(duplicate_ids),
    ifelse(benford_test$p.value < 0.05, 1, 0)
  ),
  pct_records = violations / nrow(data) * 100
)

# Visualization
violation_matrix %>%
  ggplot(aes(x = check_type, y = pct_records, fill = pct_records)) +
  geom_col() +
  scale_fill_gradient(low = "green", high = "red") +
  labs(title = "Consistency Check Violations",
       x = "Check Type",
       y = "% of Records") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

### Detailed Violation Reports

```r
# Bivariate scatter with violations highlighted
data %>%
  left_join(business_violations %>% select(id, any_violation), by = "id") %>%
  ggplot(aes(x = var1, y = var2, color = any_violation)) +
  geom_point(alpha = 0.6) +
  scale_color_manual(values = c("grey70", "red"),
                     labels = c("Valid", "Violation")) +
  labs(title = "Business Rule Violations") +
  theme_minimal()
```

---

## Consistency Score

Create overall quality metric:

```r
# Calculate consistency score per record
consistency_scores <- data %>%
  mutate(
    range_ok = !id %in% range_violations$id,
    date_ok = !id %in% date_violations$id,
    business_ok = !business_violations$any_violation,
    temporal_ok = !id %in% sequence_violations$id,
    referential_ok = !id %in% c(orphaned_records$id, duplicate_ids$id),

    # Consistency score (0-100)
    consistency_score = (range_ok + date_ok + business_ok +
                         temporal_ok + referential_ok) / 5 * 100
  )

# Summary
summary(consistency_scores$consistency_score)

# Flag low-quality records
low_quality <- consistency_scores %>%
  filter(consistency_score < 80)

cat(sprintf("Low-quality records (<80%% consistency): %d (%.1f%%)\n",
            nrow(low_quality),
            nrow(low_quality) / nrow(data) * 100))
```

---

## Ada's Guidance

{user_name}, let's interpret your consistency results:

### Critical Questions

1. **What's acceptable inconsistency?**
   - Exploratory analysis: 5-10% violations may be acceptable
   - Production systems: <1% strongly recommended
   - Regulatory environments: 0% (must investigate all)

2. **Are violations clustered?**
   - Same data source? (systematic collection issue)
   - Same time period? (temporary process breakdown)
   - Same variables? (specific validation missing)

3. **Can violations be auto-corrected?**
   - Derive from other variables? (end_date = start_date + duration)
   - Standardize formats? (date parsing, ID formatting)
   - Apply business logic? (calculate totals from parts)

4. **What's the root cause?**
   - Data entry errors? (add validation at collection)
   - Integration issues? (fix data pipeline)
   - Business process changes? (update validation rules)

---

## Red Flags

**STOP and investigate if:**
- ❌ >5% of records have consistency violations (systematic issue)
- ❌ Critical business rules violated (compliance risk)
- ❌ Referential integrity broken (data corruption)
- ❌ Temporal sequences out of order (fundamental data problem)
- ❌ Benford's Law violations (possible data fabrication)

---

## Deliverables

### Consistency Report

Create detailed documentation:

```r
# Consolidate all violations
all_violations <- list(
  range = range_results,
  date_logic = date_violations,
  hierarchy = hierarchy_violations,
  business_rules = business_violations,
  temporal = sequence_violations,
  referential = list(
    orphaned = orphaned_records,
    duplicates = duplicate_ids
  ),
  statistical = benford_check,
  consistency_scores = consistency_scores
)

saveRDS(all_violations, "consistency_violations.rds")

# Generate report
render("consistency_report.Rmd", output_file = "consistency_report.html")
```

**Report Contents:**
1. Violation counts by check type
2. Detailed violation examples
3. Consistency score distribution
4. Visualizations (heatmaps, scatter plots)
5. Recommended remediation strategies

---

## Decision Matrix

For each violation, determine action:

```r
# Categorize violations by severity and fixability
violation_actions <- consistency_scores %>%
  filter(consistency_score < 100) %>%
  mutate(
    severity = case_when(
      consistency_score < 50 ~ "High",
      consistency_score < 80 ~ "Medium",
      TRUE ~ "Low"
    ),
    action = case_when(
      # Auto-fixable
      !range_ok & can_derive_correct_value ~ "Auto-correct",
      !date_ok & can_swap_dates ~ "Auto-correct",

      # Manual review needed
      !business_ok | !referential_ok ~ "Manual review",

      # Flag but keep
      consistency_score >= 80 ~ "Flag and monitor",

      # Remove
      consistency_score < 50 ~ "Exclude from analysis"
    )
  )

# Action summary
violation_actions %>%
  count(action, severity) %>%
  arrange(desc(n))
```

---

## Output for Next Step

```r
# Prepare data for remediation
data_for_remediation <- data %>%
  left_join(consistency_scores %>% select(id, consistency_score), by = "id") %>%
  left_join(violation_actions %>% select(id, action), by = "id") %>%
  mutate(
    action = replace_na(action, "No action")
  )

saveRDS(data_for_remediation, "data_for_remediation.rds")

# Summary for next step
remediation_summary <- violation_actions %>%
  count(action) %>%
  mutate(pct = n / sum(n) * 100)

print(remediation_summary)
```

---

## Next Step

Proceed to **Step 4: Remediation** when:
- All consistency checks are complete
- Violations are categorized by severity
- You have a remediation plan for each violation type
- Documentation is complete

---

**Ada's Tip:** Consistency checks often reveal systemic data quality issues. Don't just fix violations—understand root causes and prevent them upstream. The best remediation is prevention.

---

_Step created on 2026-03-17 for data-quality-check workflow_
