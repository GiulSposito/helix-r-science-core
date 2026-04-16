# ggplot2 Plot Templates

Reusable templates for common plot types. Copy, customize variables, and adapt to your data.

## How to Use These Templates

1. **Copy template** for desired plot type
2. **Replace placeholders**:
   - `DATA` → your data frame
   - `X_VAR`, `Y_VAR` → your column names
   - `GROUP_VAR`, `FACET_VAR` → grouping/faceting variables
   - Adjust parameters (colors, sizes, labels)
3. **Customize** theme, scales, and labels
4. **Test** and iterate

---

## Scatter Plot Template

```r
# Basic scatter with groups
ggplot(DATA, aes(X_VAR, Y_VAR, colour = GROUP_VAR, shape = GROUP_VAR)) +
  geom_point(size = 3, alpha = 0.7) +
  scale_colour_viridis_d(option = "plasma", end = 0.9, name = "GROUP_LABEL") +
  scale_shape_manual(values = c(16, 17, 15), name = "GROUP_LABEL") +
  labs(
    title = "MAIN_TITLE",
    subtitle = "SUBTITLE",
    x = "X_AXIS_LABEL",
    y = "Y_AXIS_LABEL",
    caption = "DATA_SOURCE"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "right"
  )
```

---

## Scatter with Regression Template

```r
# Scatter + linear model + confidence interval
ggplot(DATA, aes(X_VAR, Y_VAR)) +
  geom_point(size = 2.5, alpha = 0.6, colour = "steelblue") +
  geom_smooth(method = "lm", se = TRUE, colour = "red", fill = "red", alpha = 0.2) +
  labs(
    title = "RELATIONSHIP: Y vs X",
    subtitle = "Linear regression with 95% CI",
    x = "X_AXIS_LABEL",
    y = "Y_AXIS_LABEL"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )
```

---

## Time Series Template

```r
# Single time series with date axis
ggplot(DATA, aes(DATE_VAR, VALUE_VAR)) +
  geom_line(colour = "steelblue", linewidth = 1) +
  geom_point(colour = "steelblue", size = 1, alpha = 0.5) +
  scale_x_date(
    date_breaks = "1 year",     # Adjust: "1 month", "2 years", etc.
    date_labels = "%Y"          # Adjust: "%b %Y", "%Y-%m-%d", etc.
  ) +
  scale_y_continuous(labels = scales::comma_format()) +  # Or percent_format(), dollar_format()
  labs(
    title = "METRIC OVER TIME",
    x = NULL,
    y = "VALUE_LABEL"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )
```

---

## Multiple Time Series Template

```r
# Multiple series with legend
ggplot(DATA, aes(DATE_VAR, VALUE_VAR, colour = GROUP_VAR, linetype = GROUP_VAR)) +
  geom_line(linewidth = 1) +
  scale_colour_manual(
    values = c("GROUP1" = "#E41A1C", "GROUP2" = "#377EB8", "GROUP3" = "#4DAF4A"),
    name = "LEGEND_TITLE"
  ) +
  scale_linetype_manual(
    values = c("solid", "dashed", "dotted"),
    name = "LEGEND_TITLE"
  ) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  labs(
    title = "COMPARISON OVER TIME",
    x = NULL,
    y = "VALUE_LABEL"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    legend.direction = "vertical"
  )
```

---

## Bar Chart (Counts) Template

```r
# Automatic counting with single fill color
ggplot(DATA, aes(CATEGORY_VAR)) +
  geom_bar(fill = "steelblue", colour = "white", width = 0.7) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, NA)) +  # Start y at 0
  labs(
    title = "COUNT BY CATEGORY",
    x = "CATEGORY_LABEL",
    y = "Count"
  ) +
  theme_minimal() +
  theme(
    panel.grid.major.x = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )
```

---

## Bar Chart (Values) Template

```r
# Pre-calculated values with error bars
# Requires: MEAN_VAR and SE_VAR (or similar) columns
ggplot(DATA, aes(CATEGORY_VAR, MEAN_VAR)) +
  geom_col(fill = "steelblue", colour = "black", width = 0.7) +
  geom_errorbar(
    aes(ymin = MEAN_VAR - SE_VAR, ymax = MEAN_VAR + SE_VAR),
    width = 0.2,
    linewidth = 0.8
  ) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, NA)) +
  labs(
    title = "MEAN VALUE BY CATEGORY",
    subtitle = "Error bars show ±SE",
    x = "CATEGORY_LABEL",
    y = "VALUE_LABEL (mean ± SE)"
  ) +
  theme_minimal() +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  )
```

---

## Grouped Bar Chart Template

```r
# Side-by-side bars
ggplot(DATA, aes(CATEGORY_VAR, fill = GROUP_VAR)) +
  geom_bar(position = "dodge", colour = "white") +
  scale_fill_viridis_d(option = "cividis", name = "GROUP_LABEL") +
  labs(
    title = "COMPARISON BY CATEGORY AND GROUP",
    x = "CATEGORY_LABEL",
    y = "Count"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "top"
  )
```

---

## Stacked Bar Chart (Proportions) Template

```r
# 100% stacked bars
ggplot(DATA, aes(CATEGORY_VAR, fill = GROUP_VAR)) +
  geom_bar(position = "fill", colour = "white") +
  scale_y_continuous(labels = scales::percent_format(), expand = c(0, 0)) +
  scale_fill_brewer(palette = "Set2", name = "GROUP_LABEL") +
  labs(
    title = "PROPORTION BREAKDOWN",
    x = "CATEGORY_LABEL",
    y = "Percentage"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major.x = element_blank()
  )
```

---

## Histogram Template

```r
# Distribution with thoughtful binwidth
ggplot(DATA, aes(CONTINUOUS_VAR)) +
  geom_histogram(binwidth = BINWIDTH_VALUE, fill = "steelblue", colour = "white") +
  scale_y_continuous(labels = scales::comma_format()) +
  labs(
    title = "DISTRIBUTION OF VARIABLE",
    subtitle = "Binwidth = BINWIDTH_VALUE",
    x = "VARIABLE_LABEL",
    y = "Count"
  ) +
  theme_minimal() +
  theme(
    panel.grid.minor = element_blank()
  )
```

---

## Density Plot Template

```r
# Single density curve
ggplot(DATA, aes(CONTINUOUS_VAR)) +
  geom_density(fill = "steelblue", alpha = 0.5, colour = "black") +
  geom_rug(sides = "b", alpha = 0.1) +
  labs(
    title = "DISTRIBUTION OF VARIABLE",
    x = "VARIABLE_LABEL",
    y = "Density"
  ) +
  theme_minimal()
```

---

## Overlapping Densities Template

```r
# Multiple distributions
ggplot(DATA, aes(CONTINUOUS_VAR, fill = GROUP_VAR)) +
  geom_density(alpha = 0.5) +
  scale_fill_viridis_d(option = "plasma", end = 0.9, name = "GROUP_LABEL") +
  labs(
    title = "DISTRIBUTION COMPARISON",
    x = "VARIABLE_LABEL",
    y = "Density"
  ) +
  theme_minimal() +
  theme(legend.position = "top")
```

---

## Boxplot Template

```r
# Basic boxplot with outliers
ggplot(DATA, aes(CATEGORY_VAR, CONTINUOUS_VAR)) +
  geom_boxplot(fill = "steelblue", colour = "black", outlier.colour = "red") +
  labs(
    title = "DISTRIBUTION BY CATEGORY",
    x = "CATEGORY_LABEL",
    y = "VALUE_LABEL"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

---

## Boxplot with Points Template

```r
# Boxplot + all individual observations
ggplot(DATA, aes(CATEGORY_VAR, CONTINUOUS_VAR)) +
  geom_boxplot(fill = "steelblue", alpha = 0.5, outlier.shape = NA) +
  geom_jitter(width = 0.2, alpha = 0.3, size = 1.5) +
  labs(
    title = "DISTRIBUTION WITH INDIVIDUAL OBSERVATIONS",
    x = "CATEGORY_LABEL",
    y = "VALUE_LABEL"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

---

## Violin Plot Template

```r
# Distribution shape with quartiles
ggplot(DATA, aes(CATEGORY_VAR, CONTINUOUS_VAR, fill = CATEGORY_VAR)) +
  geom_violin(draw_quantiles = c(0.25, 0.5, 0.75), alpha = 0.7) +
  scale_fill_viridis_d(option = "rocket", end = 0.9) +
  labs(
    title = "DISTRIBUTION SHAPE BY CATEGORY",
    subtitle = "Quartile lines at 25%, 50%, 75%",
    x = "CATEGORY_LABEL",
    y = "VALUE_LABEL"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
```

---

## Facet Wrap Template

```r
# Multiple panels from one variable
ggplot(DATA, aes(X_VAR, Y_VAR)) +
  geom_point(alpha = 0.5, size = 2) +
  geom_smooth(method = "lm", se = FALSE, colour = "red") +
  facet_wrap(~ FACET_VAR, nrow = 2) +
  labs(
    title = "RELATIONSHIP ACROSS CATEGORIES",
    x = "X_AXIS_LABEL",
    y = "Y_AXIS_LABEL"
  ) +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold"),
    strip.background = element_rect(fill = "grey90", colour = "black")
  )
```

---

## Facet Grid Template

```r
# True 2D grid layout
ggplot(DATA, aes(X_VAR, Y_VAR)) +
  geom_point(alpha = 0.5, size = 2) +
  facet_grid(ROW_VAR ~ COL_VAR) +
  labs(
    title = "2D FACETED COMPARISON",
    subtitle = "Rows = ROW_VAR, Columns = COL_VAR",
    x = "X_AXIS_LABEL",
    y = "Y_AXIS_LABEL"
  ) +
  theme_bw()
```

---

## Heatmap Template

```r
# Correlation matrix or tile-based visualization
ggplot(DATA, aes(X_VAR, Y_VAR, fill = VALUE_VAR)) +
  geom_tile(colour = "white", linewidth = 1) +
  geom_text(aes(label = round(VALUE_VAR, 2)), size = 3.5) +  # Optional labels
  scale_fill_gradient2(
    low = "blue",
    mid = "white",
    high = "red",
    midpoint = MIDPOINT_VALUE,  # e.g., 0 for correlation
    name = "VALUE_LABEL"
  ) +
  labs(
    title = "HEATMAP TITLE",
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

## Annotated Plot Template

```r
# Plot with reference lines and text annotations
ggplot(DATA, aes(X_VAR, Y_VAR)) +
  # Reference lines
  geom_hline(yintercept = REF_VALUE, linetype = "dashed", colour = "grey50") +
  geom_vline(xintercept = REF_VALUE, linetype = "dashed", colour = "grey50") +

  # Data
  geom_point(size = 3, alpha = 0.7, colour = "steelblue") +

  # Text annotation
  annotate("text",
           x = X_POSITION, y = Y_POSITION,
           label = "ANNOTATION_TEXT",
           hjust = 0, size = 5, fontface = "bold") +

  labs(
    title = "ANNOTATED PLOT TITLE",
    x = "X_AXIS_LABEL",
    y = "Y_AXIS_LABEL"
  ) +
  theme_minimal()
```

---

## Publication-Ready Template

```r
# Complete publication-quality plot
ggplot(DATA, aes(X_VAR, Y_VAR, colour = GROUP_VAR, shape = GROUP_VAR)) +
  # Data layers
  geom_point(size = 3, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, alpha = 0.2, linewidth = 1) +

  # Colorblind-safe scales
  scale_colour_manual(
    values = c("GROUP1" = "#0072B2", "GROUP2" = "#D55E00"),
    labels = c("Label 1", "Label 2"),
    name = "GROUP_LABEL"
  ) +
  scale_shape_manual(
    values = c(16, 17),
    labels = c("Label 1", "Label 2"),
    name = "GROUP_LABEL"
  ) +

  # Labels
  labs(
    title = "PUBLICATION TITLE",
    subtitle = "SUBTITLE WITH METHOD DETAILS",
    x = "X_AXIS_LABEL",
    y = "Y_AXIS_LABEL",
    caption = "Data source: CITATION OR SOURCE"
  ) +

  # Publication theme
  theme_minimal(base_size = 12) +
  theme(
    # Titles
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

    # Panel
    panel.grid.minor = element_blank(),
    panel.border = element_rect(fill = NA, colour = "black", linewidth = 0.5),

    # Margins
    plot.margin = margin(10, 15, 10, 10)
  )

# Save
# ggsave("figure_name.pdf", width = 8, height = 6, device = cairo_pdf)
```

---

## Custom Function Template

```r
# Reusable plot function
plot_scatter <- function(data, x_var, y_var, color_var = NULL,
                         title = "Scatter Plot", ...) {
  ggplot(data, aes(x = {{ x_var }}, y = {{ y_var }}, colour = {{ color_var }})) +
    geom_point(size = 3, alpha = 0.7, ...) +  # ... passes additional args
    scale_colour_viridis_d(option = "plasma", end = 0.9) +
    labs(title = title) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold"),
      legend.position = "right"
    )
}

# Usage
# plot_scatter(mtcars, wt, mpg, color_var = factor(cyl), title = "Weight vs MPG")
```

---

## Quick Customization Guide

### Common Adjustments

**Colors**:
- Single color: `fill = "steelblue"`, `colour = "red"`
- Viridis: `scale_colour_viridis_d(option = "viridis/plasma/mako/rocket")`
- ColorBrewer: `scale_colour_brewer(palette = "Set1/Dark2/Blues")`
- Manual: `scale_colour_manual(values = c("A" = "#E41A1C", "B" = "#377EB8"))`

**Sizes**:
- Point size: `size = 3` (typical range: 1-5)
- Line width: `linewidth = 1` (typical range: 0.5-2)

**Transparency**:
- `alpha = 0.7` (0 = invisible, 1 = opaque)

**Text Size**:
- `base_size = 12` in theme functions
- Individual: `size = 14` in element_text()

**Axis Formatting**:
- Percentage: `scale_y_continuous(labels = scales::percent_format())`
- Currency: `scale_y_continuous(labels = scales::dollar_format(prefix = "$"))`
- Commas: `scale_y_continuous(labels = scales::comma_format())`

**Legend Position**:
- Outside: `"right"`, `"left"`, `"top"`, `"bottom"`
- Inside: `c(x, y)` where x, y ∈ [0, 1] (e.g., `c(0.95, 0.95)` = top-right)
- Remove: `"none"`

---

## Save Template

```r
# Standard save template
p <- ggplot(...)  # your plot

# Vector (scalable, for publication)
ggsave("figure.pdf", p, width = 8, height = 6, device = cairo_pdf)
ggsave("figure.svg", p, width = 8, height = 6)

# Raster (for presentations, high DPI)
ggsave("figure.png", p, width = 8, height = 6, dpi = 300)

# Specific dimensions
ggsave("figure.pdf", p, width = 180, height = 120, units = "mm")
```

---

**See [../examples/plot-examples.md](../examples/plot-examples.md) for complete working examples.**
**See [../references/](../references/) for detailed documentation of all components.**
