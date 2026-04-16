# ggplot2 Plot Examples

Complete, runnable examples for all major plot types with best practices applied.

## Table of Contents

- [Scatter Plots](#scatter-plots)
- [Line Plots](#line-plots)
- [Bar Charts](#bar-charts)
- [Distributions](#distributions)
- [Statistical Summaries](#statistical-summaries)
- [Faceted Plots](#faceted-plots)
- [Heatmaps & 2D Density](#heatmaps--2d-density)
- [Complex Multi-Layer](#complex-multi-layer)
- [Publication-Ready](#publication-ready)

---

## Scatter Plots

### Basic Scatter Plot

```r
library(ggplot2)

# Simple scatter
ggplot(mtcars, aes(wt, mpg)) +
  geom_point(size = 3, colour = "steelblue", alpha = 0.7) +
  labs(
    title = "Fuel Efficiency vs Weight",
    x = "Weight (1000 lbs)",
    y = "Miles per Gallon"
  ) +
  theme_minimal()
```

---

### Scatter with Groups

```r
# Color and shape by group
ggplot(iris, aes(Sepal.Length, Sepal.Width,
                 colour = Species, shape = Species)) +
  geom_point(size = 3, alpha = 0.7) +
  scale_colour_viridis_d(option = "plasma", end = 0.9) +
  labs(
    title = "Iris Measurements by Species",
    x = "Sepal Length (cm)",
    y = "Sepal Width (cm)"
  ) +
  theme_minimal() +
  theme(
    legend.position = c(0.95, 0.95),
    legend.justification = c(1, 1),
    legend.background = element_rect(fill = "white", colour = "black")
  )
```

---

### Scatter with Smooth

```r
# With linear regression
ggplot(mtcars, aes(wt, mpg)) +
  geom_point(size = 2.5, alpha = 0.6) +
  geom_smooth(method = "lm", se = TRUE, colour = "red", fill = "red", alpha = 0.2) +
  labs(
    title = "Fuel Efficiency vs Weight with Linear Fit",
    subtitle = "95% confidence interval shown in grey",
    x = "Weight (1000 lbs)",
    y = "Miles per Gallon"
  ) +
  theme_bw()
```

---

### Bubble Chart

```r
# Size represents third variable
ggplot(mtcars, aes(wt, mpg, size = hp, colour = factor(cyl))) +
  geom_point(alpha = 0.6) +
  scale_size_area(max_size = 15, name = "Horsepower") +
  scale_colour_viridis_d(name = "Cylinders", option = "mako") +
  labs(
    title = "Vehicle Performance Comparison",
    x = "Weight (1000 lbs)",
    y = "Miles per Gallon"
  ) +
  theme_minimal() +
  theme(legend.position = "right")
```

---

### Dense Scatter (Hexbin)

```r
# For datasets with >10k points
library(hexbin)

# Generate large dataset
set.seed(123)
large_data <- data.frame(
  x = rnorm(50000),
  y = rnorm(50000)
)

ggplot(large_data, aes(x, y)) +
  geom_hex(bins = 50) +
  scale_fill_viridis_c(option = "inferno", name = "Count") +
  labs(
    title = "Hexagonal Binning for Dense Data",
    subtitle = "50,000 observations"
  ) +
  theme_minimal() +
  theme(panel.grid = element_blank())
```

---

## Line Plots

### Time Series

```r
# Single time series
economics_recent <- subset(economics, date >= as.Date("2000-01-01"))

ggplot(economics_recent, aes(date, unemploy)) +
  geom_line(colour = "steelblue", linewidth = 1) +
  geom_point(colour = "steelblue", size = 0.5) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  scale_y_continuous(labels = scales::comma_format()) +
  labs(
    title = "US Unemployment (2000-2015)",
    x = NULL,
    y = "Number of Unemployed (thousands)"
  ) +
  theme_minimal() +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold")
  )
```

---

### Multiple Time Series

```r
# Reshape data for multiple series
library(tidyr)

economics_long <- economics |>
  select(date, psavert, uempmed) |>
  pivot_longer(cols = c(psavert, uempmed),
               names_to = "variable",
               values_to = "value")

# Plot with distinct colors and shapes
ggplot(economics_long, aes(date, value, colour = variable, linetype = variable)) +
  geom_line(linewidth = 1) +
  scale_colour_manual(
    values = c("psavert" = "#E41A1C", "uempmed" = "#377EB8"),
    labels = c("Personal Savings Rate (%)", "Median Unemployment Duration (weeks)"),
    name = NULL
  ) +
  scale_linetype_manual(
    values = c("psavert" = "solid", "uempmed" = "dashed"),
    labels = c("Personal Savings Rate (%)", "Median Unemployment Duration (weeks)"),
    name = NULL
  ) +
  scale_x_date(date_breaks = "10 years", date_labels = "%Y") +
  labs(
    title = "Economic Indicators Over Time",
    x = NULL,
    y = "Value (different units)"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    legend.direction = "vertical"
  )
```

---

### Line with Ribbon (Confidence Band)

```r
# Simulate data with confidence intervals
set.seed(123)
time_data <- data.frame(
  time = 1:100,
  value = cumsum(rnorm(100, 0.1, 1))
)
time_data$lower <- time_data$value - 2
time_data$upper <- time_data$value + 2

ggplot(time_data, aes(time, value)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "steelblue", alpha = 0.3) +
  geom_line(colour = "steelblue", linewidth = 1) +
  labs(
    title = "Time Series with Confidence Band",
    subtitle = "Shaded region shows 95% confidence interval",
    x = "Time",
    y = "Value"
  ) +
  theme_minimal()
```

---

## Bar Charts

### Simple Bar Chart (Counts)

```r
# Automatic counting
ggplot(mpg, aes(class)) +
  geom_bar(fill = "steelblue", colour = "white", width = 0.7) +
  labs(
    title = "Vehicle Count by Class",
    x = "Vehicle Class",
    y = "Count"
  ) +
  theme_minimal() +
  theme(
    panel.grid.major.x = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )
```

---

### Bar Chart with Values

```r
# Pre-calculated values
library(dplyr)

summary_data <- mtcars |>
  group_by(cyl) |>
  summarise(
    mean_mpg = mean(mpg),
    se = sd(mpg) / sqrt(n())
  )

ggplot(summary_data, aes(factor(cyl), mean_mpg)) +
  geom_col(fill = "steelblue", colour = "black", width = 0.7) +
  geom_errorbar(
    aes(ymin = mean_mpg - se, ymax = mean_mpg + se),
    width = 0.2,
    linewidth = 0.8
  ) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 30)) +
  labs(
    title = "Average Fuel Efficiency by Cylinder Count",
    subtitle = "Error bars show standard error",
    x = "Number of Cylinders",
    y = "Miles per Gallon (mean ± SE)"
  ) +
  theme_minimal() +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  )
```

---

### Grouped (Dodged) Bar Chart

```r
# Side-by-side bars
ggplot(mpg, aes(class, fill = factor(year))) +
  geom_bar(position = "dodge", colour = "white") +
  scale_fill_viridis_d(name = "Year", option = "cividis") +
  labs(
    title = "Vehicle Count by Class and Year",
    x = "Vehicle Class",
    y = "Count"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = c(0.95, 0.95),
    legend.justification = c(1, 1),
    legend.background = element_rect(fill = "white", colour = "black")
  )
```

---

### Stacked Bar Chart (Proportions)

```r
# 100% stacked
ggplot(mpg, aes(class, fill = drv)) +
  geom_bar(position = "fill", colour = "white") +
  scale_y_continuous(labels = scales::percent_format(), expand = c(0, 0)) +
  scale_fill_brewer(
    palette = "Set2",
    name = "Drive Type",
    labels = c("4-wheel", "Front-wheel", "Rear-wheel")
  ) +
  labs(
    title = "Drive Type Distribution by Vehicle Class",
    x = "Vehicle Class",
    y = "Percentage"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major.x = element_blank()
  )
```

---

### Horizontal Bar Chart

```r
# Sorted horizontal bars
class_counts <- mpg |>
  count(class) |>
  arrange(n)

ggplot(class_counts, aes(n, reorder(class, n))) +
  geom_col(fill = "steelblue") +
  geom_text(aes(label = n), hjust = -0.2, size = 4) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "Vehicle Count by Class (Sorted)",
    x = "Count",
    y = NULL
  ) +
  theme_minimal() +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank()
  )
```

---

## Distributions

### Histogram

```r
# With thoughtful binwidth
ggplot(diamonds, aes(price)) +
  geom_histogram(binwidth = 500, fill = "steelblue", colour = "white") +
  scale_x_continuous(labels = scales::dollar_format()) +
  scale_y_continuous(labels = scales::comma_format()) +
  labs(
    title = "Distribution of Diamond Prices",
    subtitle = "Binwidth = $500",
    x = "Price",
    y = "Count"
  ) +
  theme_minimal()
```

---

### Density Plot

```r
# Single variable
ggplot(diamonds, aes(carat)) +
  geom_density(fill = "steelblue", alpha = 0.5, colour = "black") +
  geom_rug(sides = "b", alpha = 0.1) +
  labs(
    title = "Distribution of Diamond Carat Weights",
    x = "Carat",
    y = "Density"
  ) +
  theme_minimal()
```

---

### Overlapping Density Plots

```r
# Multiple groups with transparency
ggplot(iris, aes(Sepal.Length, fill = Species)) +
  geom_density(alpha = 0.5) +
  scale_fill_viridis_d(option = "plasma", end = 0.9) +
  labs(
    title = "Sepal Length Distribution by Species",
    x = "Sepal Length (cm)",
    y = "Density"
  ) +
  theme_minimal() +
  theme(legend.position = "top")
```

---

### Frequency Polygon (Better for Comparisons)

```r
# Multiple distributions without overlap issues
ggplot(iris, aes(Sepal.Length, colour = Species)) +
  geom_freqpoly(binwidth = 0.2, linewidth = 1) +
  scale_colour_viridis_d(option = "mako", end = 0.9) +
  labs(
    title = "Sepal Length Distribution Comparison",
    x = "Sepal Length (cm)",
    y = "Count"
  ) +
  theme_minimal() +
  theme(legend.position = "top")
```

---

## Statistical Summaries

### Boxplot

```r
# Standard boxplot
ggplot(mpg, aes(class, hwy)) +
  geom_boxplot(fill = "steelblue", colour = "black", outlier.colour = "red") +
  labs(
    title = "Highway Fuel Efficiency by Vehicle Class",
    x = "Vehicle Class",
    y = "Highway MPG"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

---

### Boxplot with Individual Points

```r
# Show all data points with jitter
ggplot(mpg, aes(class, hwy)) +
  geom_boxplot(fill = "steelblue", alpha = 0.5, outlier.shape = NA) +
  geom_jitter(width = 0.2, alpha = 0.3, size = 1.5) +
  labs(
    title = "Highway Fuel Efficiency by Vehicle Class",
    subtitle = "Individual observations shown as points",
    x = "Vehicle Class",
    y = "Highway MPG"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

---

### Violin Plot

```r
# Distribution shape
ggplot(iris, aes(Species, Sepal.Length, fill = Species)) +
  geom_violin(draw_quantiles = c(0.25, 0.5, 0.75), alpha = 0.7) +
  scale_fill_viridis_d(option = "rocket", end = 0.9) +
  labs(
    title = "Sepal Length Distribution by Species",
    subtitle = "Quartile lines shown at 25%, 50%, 75%",
    x = "Species",
    y = "Sepal Length (cm)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
```

---

### Violin + Boxplot Combination

```r
# Best of both worlds
ggplot(iris, aes(Species, Sepal.Length, fill = Species)) +
  geom_violin(alpha = 0.5) +
  geom_boxplot(width = 0.1, fill = "white", outlier.shape = NA) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Sepal Length: Distribution Shape + Summary Statistics",
    x = "Species",
    y = "Sepal Length (cm)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
```

---

## Faceted Plots

### Facet Wrap (One Variable)

```r
# Multiple panels from one variable
ggplot(mpg, aes(displ, hwy)) +
  geom_point(alpha = 0.5, size = 2) +
  geom_smooth(method = "lm", se = FALSE, colour = "red") +
  facet_wrap(~ class, nrow = 2) +
  labs(
    title = "Engine Size vs Highway MPG by Vehicle Class",
    x = "Engine Displacement (L)",
    y = "Highway MPG"
  ) +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold"),
    strip.background = element_rect(fill = "grey90", colour = "black")
  )
```

---

### Facet Grid (Two Variables)

```r
# True 2D grid
ggplot(mpg, aes(displ, hwy)) +
  geom_point(alpha = 0.5, size = 2) +
  facet_grid(drv ~ cyl) +
  labs(
    title = "Engine Size vs Highway MPG",
    subtitle = "Rows = Drive type, Columns = Cylinders",
    x = "Engine Displacement (L)",
    y = "Highway MPG"
  ) +
  theme_bw()
```

---

### Free Scales Faceting

```r
# Each panel optimized for its data
ggplot(economics_long, aes(date, value)) +
  geom_line(colour = "steelblue", linewidth = 1) +
  facet_wrap(~ variable, scales = "free_y", nrow = 2) +
  scale_x_date(date_breaks = "10 years", date_labels = "%Y") +
  labs(
    title = "Economic Indicators Over Time",
    subtitle = "Each panel uses independent y-axis scale",
    x = NULL,
    y = "Value"
  ) +
  theme_minimal() +
  theme(strip.text = element_text(face = "bold"))
```

---

## Heatmaps & 2D Density

### Correlation Heatmap

```r
# Correlation matrix visualization
library(reshape2)

# Compute correlation
cor_matrix <- cor(mtcars[, c("mpg", "disp", "hp", "drat", "wt", "qsec")])
cor_data <- melt(cor_matrix)

ggplot(cor_data, aes(Var1, Var2, fill = value)) +
  geom_tile(colour = "white", linewidth = 1) +
  geom_text(aes(label = round(value, 2)), size = 3.5) +
  scale_fill_gradient2(
    low = "blue",
    mid = "white",
    high = "red",
    midpoint = 0,
    limits = c(-1, 1),
    name = "Correlation"
  ) +
  labs(
    title = "Variable Correlation Matrix",
    x = NULL,
    y = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid = element_blank()
  )
```

---

### 2D Density Contours

```r
# Density contours for scatter plot
ggplot(diamonds, aes(carat, price)) +
  stat_density_2d(aes(fill = after_stat(level)), geom = "polygon", alpha = 0.5) +
  scale_fill_viridis_c(option = "plasma", name = "Density") +
  scale_y_continuous(labels = scales::dollar_format()) +
  labs(
    title = "Diamond Price vs Carat (Density)",
    x = "Carat",
    y = "Price"
  ) +
  theme_minimal() +
  theme(panel.grid.minor = element_blank())
```

---

## Complex Multi-Layer

### Scatter + Smooth + Reference Lines

```r
# Multiple informative layers
ggplot(mtcars, aes(wt, mpg)) +
  # Reference grid
  geom_hline(yintercept = mean(mtcars$mpg), linetype = "dashed",
             colour = "grey50", linewidth = 0.8) +
  geom_vline(xintercept = mean(mtcars$wt), linetype = "dashed",
             colour = "grey50", linewidth = 0.8) +
  # Data and smooth
  geom_point(aes(colour = factor(cyl), size = hp), alpha = 0.6) +
  geom_smooth(method = "lm", se = TRUE, colour = "black", linewidth = 1.5) +
  # Scales
  scale_colour_viridis_d(name = "Cylinders", option = "mako") +
  scale_size_area(max_size = 10, name = "Horsepower") +
  # Labels
  labs(
    title = "Vehicle Weight vs Fuel Efficiency",
    subtitle = "Dashed lines show mean values",
    x = "Weight (1000 lbs)",
    y = "Miles per Gallon"
  ) +
  # Theme
  theme_minimal() +
  theme(legend.position = "right")
```

---

### Time Series with Events

```r
# Annotate important events
recession_start <- as.Date("2007-12-01")
recession_end <- as.Date("2009-06-01")

ggplot(economics, aes(date, unemploy)) +
  # Highlight recession period
  annotate("rect",
           xmin = recession_start, xmax = recession_end,
           ymin = -Inf, ymax = Inf,
           fill = "red", alpha = 0.2) +
  # Data
  geom_line(colour = "steelblue", linewidth = 1) +
  # Annotation
  annotate("text",
           x = as.Date("2008-06-01"), y = 15000,
           label = "Great Recession", fontface = "bold", size = 5) +
  # Scales
  scale_x_date(date_breaks = "5 years", date_labels = "%Y") +
  scale_y_continuous(labels = scales::comma_format()) +
  # Labels
  labs(
    title = "US Unemployment Over Time",
    subtitle = "Recession period highlighted in red",
    x = NULL,
    y = "Number of Unemployed (thousands)"
  ) +
  theme_minimal()
```

---

## Publication-Ready

### Complete Publication Plot

```r
# All best practices applied
library(dplyr)

# Prepare data
plot_data <- iris |>
  filter(Species %in% c("versicolor", "virginica"))

# Create plot
p <- ggplot(plot_data, aes(Sepal.Length, Sepal.Width,
                           colour = Species, shape = Species)) +
  # Data layers
  geom_point(size = 3, alpha = 0.7) +

  # Statistical layer
  geom_smooth(method = "lm", se = TRUE, alpha = 0.2, linewidth = 1) +

  # Scales (colorblind-safe)
  scale_colour_manual(
    values = c("versicolor" = "#0072B2", "virginica" = "#D55E00"),
    labels = c("I. versicolor", "I. virginica")
  ) +
  scale_shape_manual(
    values = c("versicolor" = 16, "virginica" = 17),
    labels = c("I. versicolor", "I. virginica")
  ) +

  # Labels
  labs(
    title = "Sepal Dimensions in Two Iris Species",
    subtitle = "Linear regression with 95% confidence interval",
    x = "Sepal Length (cm)",
    y = "Sepal Width (cm)",
    colour = "Species",
    shape = "Species",
    caption = "Data: Anderson (1935) via R datasets package"
  ) +

  # Theme
  theme_minimal(base_size = 12) +
  theme(
    # Plot titles
    plot.title = element_text(size = 14, face = "bold", hjust = 0),
    plot.subtitle = element_text(size = 11, colour = "grey30", hjust = 0),
    plot.caption = element_text(size = 9, colour = "grey50", hjust = 1),

    # Axes
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 10),

    # Legend
    legend.position = c(0.95, 0.05),
    legend.justification = c(1, 0),
    legend.background = element_rect(fill = "white", colour = "black", linewidth = 0.5),
    legend.title = element_text(face = "bold"),
    legend.key = element_blank(),

    # Panel
    panel.grid.minor = element_blank(),
    panel.border = element_rect(fill = NA, colour = "black", linewidth = 0.5),

    # Margins
    plot.margin = margin(10, 15, 10, 10)
  )

# Display
print(p)

# Save publication-quality
ggsave("iris_publication.pdf", p, width = 8, height = 6, device = cairo_pdf)
ggsave("iris_publication.png", p, width = 8, height = 6, dpi = 300)
```

---

### Multi-Panel Publication Figure

```r
library(patchwork)

# Create individual panels
p1 <- ggplot(iris, aes(Sepal.Length, Sepal.Width, colour = Species)) +
  geom_point(size = 2) +
  scale_colour_viridis_d(option = "plasma", end = 0.9) +
  labs(title = "A) Sepal dimensions", x = "Length (cm)", y = "Width (cm)") +
  theme_minimal() +
  theme(legend.position = "none", plot.title = element_text(face = "bold"))

p2 <- ggplot(iris, aes(Petal.Length, Petal.Width, colour = Species)) +
  geom_point(size = 2) +
  scale_colour_viridis_d(option = "plasma", end = 0.9) +
  labs(title = "B) Petal dimensions", x = "Length (cm)", y = "Width (cm)") +
  theme_minimal() +
  theme(legend.position = "none", plot.title = element_text(face = "bold"))

p3 <- ggplot(iris, aes(Species, Sepal.Length, fill = Species)) +
  geom_violin(alpha = 0.5) +
  geom_boxplot(width = 0.1, fill = "white", outlier.shape = NA) +
  scale_fill_viridis_d(option = "plasma", end = 0.9) +
  labs(title = "C) Sepal length distribution", x = NULL, y = "Length (cm)") +
  theme_minimal() +
  theme(legend.position = "none", plot.title = element_text(face = "bold"))

# Compose
combined <- (p1 | p2) / p3 +
  plot_layout(guides = "collect", heights = c(1, 1)) +
  plot_annotation(
    title = "Iris Flower Measurements Across Species",
    caption = "Data: Anderson (1935). All measurements in centimeters.",
    theme = theme(
      plot.title = element_text(size = 16, face = "bold"),
      plot.caption = element_text(size = 9, colour = "grey50", hjust = 0)
    )
  ) &
  theme(legend.position = "bottom")

# Save
ggsave("iris_multi_panel.pdf", combined, width = 12, height = 8, device = cairo_pdf)
```

---

## Usage Notes

All examples follow best practices:

✅ Colorblind-safe palettes
✅ Clear labels and titles
✅ Appropriate alpha for overplotting
✅ Thoughtful bin widths
✅ Removed unnecessary elements
✅ Publication-ready themes
✅ Proper scale formatting

Adapt these examples to your specific data and requirements!
