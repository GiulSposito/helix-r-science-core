# Geoms Reference - Complete Guide

Comprehensive documentation of all major ggplot2 geometric objects (geoms) with aesthetics, parameters, and use cases.

## Table of Contents

- [Point Geoms](#point-geoms)
- [Line Geoms](#line-geoms)
- [Bar & Column Geoms](#bar--column-geoms)
- [Distribution Geoms](#distribution-geoms)
- [Statistical Summary Geoms](#statistical-summary-geoms)
- [Text & Label Geoms](#text--label-geoms)
- [Area & Ribbon Geoms](#area--ribbon-geoms)
- [Reference Line Geoms](#reference-line-geoms)

---

## Point Geoms

### geom_point() - Scatter Plots

**Purpose**: Display relationships between two continuous variables; can also compare continuous vs categorical.

**Required Aesthetics**:
- `x` - X position
- `y` - Y position

**Optional Aesthetics**:
- `alpha` - Transparency (0-1)
- `colour` - Point border/line color
- `fill` - Interior color (shapes 21-25 only)
- `group` - Grouping for collective geoms
- `shape` - Point shape (0-25, default: 19)
- `size` - Point size (default: 1.5)
- `stroke` - Border width (shapes 21-25)

**Key Parameters**:
- `na.rm` - Handle missing values (default: FALSE with warning)

**Shapes**:
- 0-20: Single color (use `colour`)
- 21-25: Two colors (use `colour` for border, `fill` for interior)
  - 21: Circle, 22: Square, 23: Diamond, 24: Up triangle, 25: Down triangle

**Common Patterns**:
```r
# Basic scatter
ggplot(data, aes(x, y)) +
  geom_point()

# With transparency for overplotting
ggplot(data, aes(x, y)) +
  geom_point(alpha = 0.3)

# Color by group with custom shape
ggplot(data, aes(x, y, colour = group, shape = group)) +
  geom_point(size = 3) +
  scale_shape_manual(values = c(16, 17, 18))

# Two-color points
ggplot(data, aes(x, y, fill = group)) +
  geom_point(shape = 21, size = 3, colour = "black")
```

**When to use alternatives**:
- Dense data (>10k points): Use `geom_hex()`, `geom_bin2d()`, or `stat_density_2d()`
- Overplotting: Use `geom_jitter()` or `alpha` parameter
- Discrete x-axis: Consider `geom_beeswarm()` (ggbeeswarm package)

---

### geom_jitter() - Jittered Points

**Purpose**: Add random noise to reduce overplotting in discrete/small datasets.

**Required Aesthetics**: Same as `geom_point()`

**Key Parameters**:
- `width` - Jitter width (default: 0.4 for discrete x)
- `height` - Jitter height (default: 0.4 for discrete y)
- `seed` - Set for reproducibility

**Usage**:
```r
# Jitter for categorical x
ggplot(data, aes(category, value)) +
  geom_jitter(width = 0.2, height = 0, alpha = 0.5)

# Reproducible jitter
set.seed(123)
ggplot(data, aes(category, value)) +
  geom_jitter(width = 0.1)
```

---

## Line Geoms

### geom_line() - Line Plots

**Purpose**: Connect observations with lines, ordered by x-axis value. Ideal for time series.

**Required Aesthetics**:
- `x` - X position (typically time/sequence)
- `y` - Y position

**Optional Aesthetics**:
- `alpha` - Transparency
- `colour` - Line color
- `group` - Define separate lines
- `linetype` - Line pattern (solid, dashed, dotted, etc.)
- `linewidth` - Line width (formerly size)

**Key Parameters**:
- `na.rm` - Remove missing values
- `orientation` - "x" (default) or "y"

**Linetypes**:
- 0: blank, 1: solid, 2: dashed, 3: dotted
- 4: dotdash, 5: longdash, 6: twodash
- Or strings: "solid", "dashed", "dotted", "dotdash", "longdash", "twodash"

**Common Patterns**:
```r
# Time series
ggplot(data, aes(date, value)) +
  geom_line()

# Multiple groups
ggplot(data, aes(date, value, colour = group)) +
  geom_line(linewidth = 1)

# With points
ggplot(data, aes(date, value)) +
  geom_line() +
  geom_point()

# Custom linetype
ggplot(data, aes(date, value, linetype = group)) +
  geom_line(linewidth = 0.8)
```

---

### geom_path() - Path Plots

**Purpose**: Connect observations in the order they appear in the data (not by x-value).

**Use cases**:
- Time series where observations aren't sorted by time
- Spatial trajectories
- Connection patterns

**Same aesthetics/parameters as geom_line()**

```r
# Ordered by data row
ggplot(data, aes(x, y)) +
  geom_path()

# With arrow
library(grid)
ggplot(data, aes(x, y)) +
  geom_path(arrow = arrow(length = unit(0.3, "cm")))
```

---

### geom_step() - Step Plots

**Purpose**: Create staircase lines, useful for discrete changes over time.

**Additional Parameters**:
- `direction` - "hv" (default, horizontal then vertical), "vh" (vertical then horizontal), or "mid" (steps midway)

```r
# Step plot for discrete changes
ggplot(data, aes(time, level)) +
  geom_step()

# Midpoint steps
ggplot(data, aes(time, level)) +
  geom_step(direction = "mid")
```

---

## Bar & Column Geoms

### geom_bar() - Bar Charts with Counting

**Purpose**: Display counts of categorical variable automatically.

**Required Aesthetics**:
- `x` - Categorical variable (or `y` for horizontal)

**Optional Aesthetics**:
- `alpha` - Transparency
- `colour` - Border color
- `fill` - Bar fill color
- `linetype` - Border line type
- `linewidth` - Border width
- `weight` - Weighting variable for counting

**Key Parameters**:
- `stat` - "count" (default) or "identity"
- `position` - "stack" (default), "dodge", "fill", "identity"
- `width` - Bar width (0-1, default: 0.9)
- `na.rm` - Remove NA values

**Position Types**:
- `"stack"` - Stack bars on top of each other
- `"dodge"` - Place bars side-by-side
- `"fill"` - Stack to 100% (proportions)
- `"identity"` - Overlap (use with alpha)

**Common Patterns**:
```r
# Simple count
ggplot(data, aes(category)) +
  geom_bar()

# Stacked by fill
ggplot(data, aes(category, fill = group)) +
  geom_bar()

# Side-by-side
ggplot(data, aes(category, fill = group)) +
  geom_bar(position = "dodge")

# Proportions (100% stacked)
ggplot(data, aes(category, fill = group)) +
  geom_bar(position = "fill")

# Horizontal bars
ggplot(data, aes(y = category)) +
  geom_bar() +
  coord_flip()  # Or use aes(y = category) in newer ggplot2
```

---

### geom_col() - Bar Charts with Values

**Purpose**: Use pre-calculated values (heights already in data).

**Required Aesthetics**:
- `x` - Categorical variable
- `y` - Height value

**Same optional aesthetics and parameters as geom_bar()**

**Key difference**: `stat = "identity"` by default (doesn't count).

```r
# Bar chart from summarized data
summary_data <- data |>
  group_by(category) |>
  summarise(mean_value = mean(value))

ggplot(summary_data, aes(category, mean_value)) +
  geom_col()

# With error bars
ggplot(summary_data, aes(category, mean_value)) +
  geom_col(fill = "steelblue") +
  geom_errorbar(aes(ymin = lower, ymax = upper), width = 0.2)
```

---

## Distribution Geoms

### geom_histogram() - Histograms

**Purpose**: Visualize distribution of continuous variable via binning.

**Required Aesthetics**:
- `x` - Continuous variable

**Optional Aesthetics**:
- `alpha`, `colour`, `fill`, `linetype`, `linewidth`, `weight`

**Key Parameters** (choose ONE):
- `bins` - Number of bins (default: 30)
- `binwidth` - Width of each bin (overrides bins)
- `breaks` - Exact bin boundaries (vector)

**Additional Parameters**:
- `boundary` - Bin boundary position
- `center` - Center of one bin
- `closed` - "right" (default) or "left" (which side is closed)
- `pad` - Add padding to edges

**Common Patterns**:
```r
# Basic histogram
ggplot(data, aes(x)) +
  geom_histogram(binwidth = 5, fill = "steelblue", colour = "white")

# Specify number of bins
ggplot(data, aes(x)) +
  geom_histogram(bins = 50)

# Density scale for comparison
ggplot(data, aes(x, after_stat(density), fill = group)) +
  geom_histogram(alpha = 0.5, position = "identity", binwidth = 2)

# With density overlay
ggplot(data, aes(x)) +
  geom_histogram(aes(y = after_stat(density)), binwidth = 1) +
  geom_density(colour = "red", linewidth = 1)
```

---

### geom_freqpoly() - Frequency Polygon

**Purpose**: Line version of histogram, better for comparing multiple distributions.

**Same aesthetics/parameters as geom_histogram()**

```r
# Compare distributions
ggplot(data, aes(x, colour = group)) +
  geom_freqpoly(binwidth = 2, linewidth = 1)

# Density scale
ggplot(data, aes(x, after_stat(density), colour = group)) +
  geom_freqpoly(binwidth = 2)
```

---

### geom_density() - Density Plots

**Purpose**: Smooth continuous approximation of distribution.

**Required Aesthetics**:
- `x` - Continuous variable

**Optional Aesthetics**:
- `alpha`, `colour`, `fill`, `group`, `linetype`, `linewidth`, `weight`

**Key Parameters**:
- `bw` - Bandwidth (smoothness): "nrd0" (default), "ucv", "bcv", "SJ", or numeric
- `adjust` - Bandwidth multiplier (default: 1; >1 smoother, <1 rougher)
- `kernel` - "gaussian" (default), "epanechnikov", "rectangular", etc.
- `n` - Number of points for density curve (default: 512)
- `trim` - Trim tails beyond data range
- `bounds` - Known bounds for density (c(lower, upper))

**Common Patterns**:
```r
# Basic density
ggplot(data, aes(x)) +
  geom_density(fill = "steelblue", alpha = 0.5)

# Multiple groups
ggplot(data, aes(x, fill = group)) +
  geom_density(alpha = 0.4)

# Adjust smoothness
ggplot(data, aes(x)) +
  geom_density(adjust = 0.5)  # Less smooth

# With rug plot
ggplot(data, aes(x)) +
  geom_density(fill = "steelblue", alpha = 0.5) +
  geom_rug(sides = "b")
```

---

## Statistical Summary Geoms

### geom_boxplot() - Box-and-Whisker Plots

**Purpose**: Compact display of distribution via five-number summary (min, Q1, median, Q3, max).

**Required Aesthetics**:
- `x` OR `y` - Discrete grouping variable
- `lower`, `upper`, `middle`, `ymin`, `ymax` - If computing manually

**Optional Aesthetics**:
- `alpha`, `colour`, `fill`, `group`, `linetype`, `linewidth`, `weight`
- `outlier.colour`, `outlier.fill`, `outlier.shape`, `outlier.size`, `outlier.stroke`, `outlier.alpha`

**Key Parameters**:
- `coef` - Whisker length as multiple of IQR (default: 1.5)
- `notch` - Show 95% CI for median (default: FALSE)
- `notchwidth` - Notch width relative to box (default: 0.5)
- `varwidth` - Width proportional to sqrt(n) (default: FALSE)
- `outlier.shape` - Outlier point shape (default: 19)
- `na.rm` - Remove missing values

**Interpretation**:
- **Box**: Interquartile range (IQR, 25th-75th percentiles)
- **Middle line**: Median (50th percentile)
- **Whiskers**: Extend to 1.5×IQR beyond box (or data max/min if closer)
- **Points**: Outliers beyond whiskers

**Common Patterns**:
```r
# Basic boxplot
ggplot(data, aes(group, value)) +
  geom_boxplot()

# With notches for median comparison
ggplot(data, aes(group, value)) +
  geom_boxplot(notch = TRUE)

# Variable width by sample size
ggplot(data, aes(group, value)) +
  geom_boxplot(varwidth = TRUE)

# Custom outliers
ggplot(data, aes(group, value)) +
  geom_boxplot(
    outlier.colour = "red",
    outlier.shape = 1,
    outlier.size = 3
  )

# Horizontal orientation
ggplot(data, aes(value, group)) +
  geom_boxplot() +
  coord_flip()

# With individual points
ggplot(data, aes(group, value)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.2, alpha = 0.3)
```

---

### geom_violin() - Violin Plots

**Purpose**: Mirrored density plot showing full distribution shape (skewness, multimodality).

**Required Aesthetics**:
- `x` - Categorical grouping variable
- `y` - Continuous variable

**Optional Aesthetics**:
- `alpha`, `colour`, `fill`, `group`, `linetype`, `linewidth`, `weight`

**Key Parameters**:
- `scale` - Scaling method:
  - "area" (default): All violins have same area
  - "count": Area proportional to sample size
  - "width": All violins have same maximum width
- `trim` - Trim tails to data range (default: TRUE)
- `adjust` - Bandwidth multiplier (default: 1)
- `bw` - Bandwidth method
- `draw_quantiles` - Draw horizontal lines at quantiles (e.g., c(0.25, 0.5, 0.75))

**Common Patterns**:
```r
# Basic violin
ggplot(data, aes(group, value)) +
  geom_violin()

# With quartiles marked
ggplot(data, aes(group, value)) +
  geom_violin(draw_quantiles = c(0.25, 0.5, 0.75))

# Area proportional to sample size
ggplot(data, aes(group, value)) +
  geom_violin(scale = "count")

# Combined with boxplot
ggplot(data, aes(group, value)) +
  geom_violin(fill = "lightblue") +
  geom_boxplot(width = 0.1, fill = "white")

# Trimmed violins
ggplot(data, aes(group, value)) +
  geom_violin(trim = FALSE, fill = "steelblue", alpha = 0.5)
```

---

### geom_smooth() - Smoothed Trend Lines

**Purpose**: Add smoothed conditional mean to aid pattern recognition.

**Required Aesthetics**:
- `x` - X position
- `y` - Y position

**Optional Aesthetics**:
- `alpha` - Ribbon transparency (default: 0.4)
- `colour` - Line color
- `fill` - Ribbon color
- `group` - Fit separate smooths per group
- `linetype`, `linewidth`

**Key Parameters**:
- `method` - Smoothing method:
  - NULL (auto): <1,000 obs uses "loess", ≥1,000 uses "gam"
  - "lm": Linear model
  - "glm": Generalized linear model
  - "gam": Generalized additive model
  - "loess": Local regression
- `formula` - Model formula (default: y ~ x)
  - Linear: `y ~ x`
  - Quadratic: `y ~ poly(x, 2)`
  - Cubic: `y ~ poly(x, 3)`
  - Spline: `y ~ s(x, bs = "cs")` (requires method = "gam")
- `se` - Show confidence interval (default: TRUE)
- `level` - Confidence level (default: 0.95)
- `span` - Loess smoothness (0-1, default: 0.75; higher = smoother)
- `method.args` - List of arguments passed to smoothing function

**Common Patterns**:
```r
# Auto smooth (loess or gam)
ggplot(data, aes(x, y)) +
  geom_point() +
  geom_smooth()

# Linear regression
ggplot(data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE)

# Polynomial fit
ggplot(data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm", formula = y ~ poly(x, 2))

# Separate smooths by group
ggplot(data, aes(x, y, colour = group)) +
  geom_point() +
  geom_smooth(method = "lm")

# Adjust loess span
ggplot(data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "loess", span = 0.3)

# No confidence interval
ggplot(data, aes(x, y)) +
  geom_point() +
  geom_smooth(se = FALSE)

# GAM with spline
ggplot(data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "gam", formula = y ~ s(x, bs = "cs"))
```

---

## Text & Label Geoms

### geom_text() - Text Annotations

**Purpose**: Add text directly on plot.

**Required Aesthetics**:
- `x` - X position
- `y` - Y position
- `label` - Text to display

**Optional Aesthetics**:
- `alpha` - Transparency
- `angle` - Rotation in degrees
- `colour` - Text color
- `family` - Font family
- `fontface` - "plain", "bold", "italic", "bold.italic"
- `hjust` - Horizontal justification (0-1 or "left"/"center"/"right"/"inward"/"outward")
- `vjust` - Vertical justification (0-1 or "bottom"/"center"/"top"/"inward"/"outward")
- `lineheight` - Line spacing
- `size` - Text size (in mm)

**Key Parameters**:
- `nudge_x`, `nudge_y` - Offset text from point
- `check_overlap` - Hide overlapping text (default: FALSE)
- `parse` - Interpret as R expressions (plotmath)
- `na.rm` - Remove NA labels

**Common Patterns**:
```r
# Basic text labels
ggplot(data, aes(x, y, label = name)) +
  geom_point() +
  geom_text(nudge_y = 0.5)

# Avoid overlaps
ggplot(data, aes(x, y, label = name)) +
  geom_point() +
  geom_text(check_overlap = TRUE, hjust = "inward", vjust = "inward")

# Rotated text
ggplot(data, aes(x, y, label = name)) +
  geom_text(angle = 45, hjust = 1)

# Mathematical expressions
df <- data.frame(x = 1, y = 1, label = "alpha == beta")
ggplot(df, aes(x, y, label = label)) +
  geom_text(parse = TRUE, size = 8)
```

---

### geom_label() - Labels with Background

**Purpose**: Text with background rectangle for better readability.

**Same aesthetics as geom_text(), plus:**
- `label.padding` - Padding around text (unit object)
- `label.r` - Corner radius (unit object)
- `label.size` - Border size

**Note**: Considerably slower than geom_text().

```r
# Basic labels
ggplot(data, aes(x, y, label = name)) +
  geom_point() +
  geom_label(nudge_y = 0.5)

# Custom styling
ggplot(data, aes(x, y, label = name)) +
  geom_label(
    fill = "white",
    colour = "black",
    label.padding = unit(0.5, "lines"),
    label.r = unit(0.15, "lines")
  )
```

---

## Area & Ribbon Geoms

### geom_area() - Filled Area Plot

**Purpose**: Line plot with area filled to y = 0.

**Required Aesthetics**:
- `x`, `y`

**Optional Aesthetics**:
- `alpha`, `colour`, `fill`, `group`, `linetype`, `linewidth`

**Key Parameters**:
- `position` - "stack" (default), "identity", "fill"
- `outline.type` - "both" (default), "upper", "lower", "full"

```r
# Basic area
ggplot(data, aes(x, y)) +
  geom_area(fill = "steelblue", alpha = 0.5)

# Stacked areas
ggplot(data, aes(x, y, fill = group)) +
  geom_area(position = "stack")

# 100% stacked
ggplot(data, aes(x, y, fill = group)) +
  geom_area(position = "fill")
```

---

### geom_ribbon() - Confidence Bands

**Purpose**: Display range (y_min to y_max) over continuous x.

**Required Aesthetics**:
- `x` - X position
- `ymin` - Lower bound
- `ymax` - Upper bound

**Optional Aesthetics**:
- `alpha`, `colour`, `fill`, `group`, `linetype`, `linewidth`

```r
# Confidence interval
ggplot(data, aes(x, y)) +
  geom_line() +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.3)

# Multiple ribbons
ggplot(data, aes(x, y, fill = group)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.4)
```

---

### geom_errorbar() - Error Bars

**Purpose**: Display vertical error bars (for discrete x).

**Required Aesthetics**:
- `x` - X position
- `ymin` - Lower bound
- `ymax` - Upper bound

**Key Parameters**:
- `width` - Cap width (default: 0.5)

```r
# Error bars on bar chart
ggplot(summary_data, aes(category, mean_value)) +
  geom_col(fill = "steelblue") +
  geom_errorbar(
    aes(ymin = mean_value - se, ymax = mean_value + se),
    width = 0.2
  )
```

---

### geom_linerange() / geom_pointrange()

**geom_linerange()**: Vertical line from ymin to ymax
**geom_pointrange()**: Line with point at y

```r
# Point with range
ggplot(data, aes(category, y)) +
  geom_pointrange(aes(ymin = lower, ymax = upper))
```

---

## Reference Line Geoms

### geom_hline() - Horizontal Reference Line

**Required Aesthetics**:
- `yintercept` - Y-axis value(s)

```r
ggplot(data, aes(x, y)) +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "red")
```

---

### geom_vline() - Vertical Reference Line

**Required Aesthetics**:
- `xintercept` - X-axis value(s)

```r
ggplot(data, aes(x, y)) +
  geom_point() +
  geom_vline(xintercept = mean(data$x), linetype = "dashed")
```

---

### geom_abline() - Diagonal Reference Line

**Required Aesthetics**:
- `slope` - Line slope
- `intercept` - Y-intercept

```r
# Identity line (y = x)
ggplot(data, aes(x, y)) +
  geom_point() +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed")
```

---

## Specialty Geoms

### geom_hex() - Hexagonal Binning

**Purpose**: 2D binning for dense scatter plots (requires hexbin package).

```r
ggplot(large_data, aes(x, y)) +
  geom_hex(bins = 30) +
  scale_fill_viridis_c()
```

---

### geom_bin2d() - 2D Rectangular Binning

**Purpose**: 2D histogram alternative to hex binning.

```r
ggplot(large_data, aes(x, y)) +
  geom_bin2d(bins = 30) +
  scale_fill_viridis_c()
```

---

### geom_contour() / geom_contour_filled()

**Purpose**: Contour lines/filled contours for 3D data.

```r
# Contour lines
ggplot(volcano_data, aes(x, y, z = elevation)) +
  geom_contour()

# Filled contours
ggplot(volcano_data, aes(x, y, z = elevation)) +
  geom_contour_filled()
```

---

### geom_tile() / geom_raster()

**Purpose**: Heatmaps with rectangular tiles.

**geom_raster()**: Faster for equal-sized tiles.

```r
# Heatmap
ggplot(data, aes(x, y, fill = value)) +
  geom_tile() +
  scale_fill_viridis_c()
```

---

### geom_polygon()

**Purpose**: Draw arbitrary filled polygons.

**Required Aesthetics**:
- `x`, `y` - Vertices (closed automatically)

```r
# Draw custom shapes
ggplot(polygon_data, aes(x, y, group = id, fill = group)) +
  geom_polygon()
```

---

## Quick Selection Guide

**Choose geom by purpose**:

| Purpose | Geom |
|---------|------|
| Scatter plot | geom_point() |
| Time series | geom_line() |
| Bar chart (counts) | geom_bar() |
| Bar chart (values) | geom_col() |
| Distribution (continuous) | geom_histogram(), geom_density() |
| Distribution comparison | geom_freqpoly(), geom_violin() |
| Distribution summary | geom_boxplot() |
| Trend line | geom_smooth() |
| Text labels | geom_text(), geom_label() |
| Error bars | geom_errorbar(), geom_pointrange() |
| Confidence bands | geom_ribbon() |
| Filled area | geom_area() |
| Reference lines | geom_hline(), geom_vline(), geom_abline() |
| Heatmap | geom_tile(), geom_raster() |
| Dense scatter | geom_hex(), geom_bin2d() |
| Contours | geom_contour(), geom_contour_filled() |

---

**See [../examples/plot-examples.md](../examples/plot-examples.md) for complete working examples of each geom.**
