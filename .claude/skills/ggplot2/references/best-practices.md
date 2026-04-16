# ggplot2 Best Practices & Patterns

Expert guidance on creating effective, accessible, and publication-ready visualizations with ggplot2.

## Table of Contents

- [Visualization Principles](#visualization-principles)
- [Common Mistakes](#common-mistakes)
- [Aesthetic Mapping](#aesthetic-mapping)
- [Color Accessibility](#color-accessibility)
- [Faceting Strategy](#faceting-strategy)
- [Annotation Techniques](#annotation-techniques)
- [Programming Patterns](#programming-patterns)
- [Performance Optimization](#performance-optimization)
- [Publication Workflow](#publication-workflow)

---

## Visualization Principles

### Layer Purpose Framework

Every layer should serve one of three purposes:

1. **Display raw data** - Enable pattern detection and outlier identification
2. **Show statistical summaries** - Highlight trends, predictions, aggregations
3. **Add metadata/context** - Provide backgrounds, annotations, reference lines

**Anti-pattern**: Layers that don't clearly serve one of these purposes add clutter.

---

### Grammar of Graphics Philosophy

Build plots **incrementally by composing independent components**, not by selecting from fixed templates.

**Five independent components**:
1. **Layers** - Data + geoms + stats
2. **Scales** - Map data to aesthetics, generate guides
3. **Coordinate systems** - Transform positions
4. **Facets** - Create small multiples
5. **Themes** - Control non-data appearance

**Benefit**: This composability mirrors analytical thinking and enables infinite flexibility.

---

### Principle of Parsimony

**Maximize the data-to-ink ratio** (Edward Tufte): Every visual element should convey information.

```r
# BEFORE: Cluttered default
ggplot(data, aes(x, y)) +
  geom_point()

# AFTER: Focused and clean
ggplot(data, aes(x, y)) +
  geom_point(alpha = 0.6) +
  theme_minimal() +
  theme(panel.grid.minor = element_blank())
```

Remove:
- Unnecessary gridlines
- Redundant legends
- Excessive decoration
- Non-essential text

---

## Common Mistakes

### Mistake 1: Aesthetics vs Fixed Values

❌ **Wrong**: `aes(colour = "blue")` - Maps string "blue" as data
✅ **Right**: `colour = "blue"` (outside aes) - Sets fixed color

```r
# WRONG
ggplot(data, aes(x, y, colour = "blue")) +
  geom_point()  # Creates legend with "blue", uses default color

# RIGHT
ggplot(data, aes(x, y)) +
  geom_point(colour = "blue")  # All points are blue, no legend
```

**Rule**: Inside `aes()` = map variables. Outside `aes()` = set fixed values.

---

### Mistake 2: Breaking Self-Containment

❌ **Wrong**: `aes(x = df$variable)` - References external object
✅ **Right**: `aes(x = variable)` - Self-contained reference

```r
# WRONG - breaks if df renamed or modified
ggplot(df, aes(x = df$x, y = df$y)) +
  geom_point()

# RIGHT - self-contained
ggplot(df, aes(x = x, y = y)) +
  geom_point()
```

**Why it matters**: Plot objects can be saved, shared, and modified independently.

---

### Mistake 3: Complex Calculations in aes()

❌ **Wrong**: `aes(x = log(value + 1))` - Hard to read, hard to debug
✅ **Right**: Transform data first with `dplyr::mutate()`

```r
# WRONG
ggplot(data, aes(x = log(income + 1), y = sqrt(sales))) +
  geom_point()

# RIGHT
library(dplyr)
plot_data <- data |>
  mutate(
    log_income = log(income + 1),
    sqrt_sales = sqrt(sales)
  )

ggplot(plot_data, aes(log_income, sqrt_sales)) +
  geom_point() +
  labs(x = "Log(Income + 1)", y = "√Sales")
```

---

### Mistake 4: Default Bin Widths

❌ **Wrong**: Accept default `bins = 30`
✅ **Right**: Always experiment with `binwidth` or `bins`

```r
# BAD - arbitrary default
ggplot(data, aes(x)) +
  geom_histogram()  # "stat_bin() using bins = 30"

# GOOD - thoughtful binning
ggplot(data, aes(x)) +
  geom_histogram(binwidth = 5)  # Based on data range and sample size
```

**Rule**: Document your binning choice in figure captions.

---

### Mistake 5: Overloaded Aesthetics

❌ **Wrong**: Map too many aesthetics (x, y, color, size, shape, alpha)
✅ **Right**: Create series of simpler plots

```r
# OVERWHELMING
ggplot(data, aes(x, y, colour = var1, size = var2,
                 shape = var3, alpha = var4)) +
  geom_point()

# BETTER - focus on key relationships
ggplot(data, aes(x, y, colour = var1)) +
  geom_point(size = 3, alpha = 0.6) +
  facet_wrap(~ var3)
```

**Rule**: Limit to 3-4 aesthetics for clarity.

---

### Mistake 6: Scale Limits vs Coord Limits

❌ **Wrong**: `scale_x_continuous(limits = ...)` - Discards data before stats
✅ **Right**: `coord_cartesian(xlim = ...)` - Visual zoom, preserves data

```r
# WRONG - lm fitted on subset, then limited again
ggplot(data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm") +
  scale_x_continuous(limits = c(0, 100))

# RIGHT - lm fitted on all data, then zoomed
ggplot(data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm") +
  coord_cartesian(xlim = c(0, 100))
```

**When to use which**:
- **scale limits**: Remove outliers before fitting models
- **coord limits**: Zoom without affecting calculations

---

## Aesthetic Mapping

### Mapping Strategy

**Map variables that you want to vary**, set fixed values for constants.

```r
# All points same color/size
ggplot(data, aes(x, y)) +
  geom_point(colour = "steelblue", size = 3)

# Color by group, size by value
ggplot(data, aes(x, y, colour = group, size = value)) +
  geom_point(alpha = 0.6)
```

---

### Group Aesthetic

Controls how observations are grouped into geometric objects.

**Default**: Interaction of all discrete variables
**Explicit definition**: Often necessary for correct visualization

```r
# Implicit grouping by discrete variable
ggplot(longitudinal_data, aes(time, value, colour = individual)) +
  geom_line()  # Automatically groups by 'individual'

# Explicit grouping when aesthetic doesn't define groups
ggplot(longitudinal_data, aes(time, value)) +
  geom_line(aes(group = individual))  # Must specify group

# Multiple groups, one aesthetic
ggplot(data, aes(time, value, group = interaction(individual, treatment))) +
  geom_line(aes(colour = treatment))
```

**Common use cases**:
- Time series for multiple individuals
- Interaction plots
- Parallel coordinates

---

### Redundant Encoding

Improve accessibility by encoding the same information multiple ways.

```r
# Color + shape (colorblind-safe)
ggplot(data, aes(x, y, colour = group, shape = group)) +
  geom_point(size = 3) +
  scale_colour_brewer(palette = "Set1")

# Color + linetype
ggplot(data, aes(time, value, colour = group, linetype = group)) +
  geom_line(linewidth = 1)
```

---

## Color Accessibility

### Colorblind-Safe Palettes

**Always use perceptually uniform, colorblind-safe palettes:**

```r
# BEST: Viridis family (optimized for color vision deficiency)
scale_colour_viridis_d(option = "viridis")
scale_fill_viridis_c(option = "plasma")

# GOOD: ColorBrewer qualitative (test with simulators)
scale_colour_brewer(palette = "Set1")
scale_colour_brewer(palette = "Dark2")

# AVOID: Rainbow, red-green combinations
scale_colour_hue()  # Default hue-based (not colorblind-safe)
```

**Viridis options ranked by colorblind-safety**:
1. **cividis** (E) - Best for CVD
2. **viridis** (D) - Excellent all-around
3. **plasma** (C), **inferno** (B), **magma** (A) - Very good

---

### Color by Data Type

**Continuous data**:
- Sequential: Viridis, ColorBrewer sequential
- Diverging: `scale_*_gradient2()` or ColorBrewer diverging (with meaningful midpoint)

**Categorical data**:
- <6 categories: ColorBrewer qualitative (Set1, Dark2, Paired)
- >6 categories: Consider faceting instead

**Special cases**:
- Binary: Use contrasting colors with redundant encoding
- Ordered categories: Use sequential ColorBrewer

```r
# Continuous: Viridis
ggplot(data, aes(x, y, colour = temperature)) +
  geom_point() +
  scale_colour_viridis_c()

# Diverging: Gradient2 with midpoint
ggplot(data, aes(x, y, fill = correlation)) +
  geom_tile() +
  scale_fill_gradient2(
    low = "blue", mid = "white", high = "red",
    midpoint = 0, limits = c(-1, 1)
  )

# Categorical: ColorBrewer
ggplot(data, aes(x, y, colour = species)) +
  geom_point(size = 3) +
  scale_colour_brewer(palette = "Dark2")
```

---

### Testing for Accessibility

```r
# Install colorblindcheck
# install.packages("colorblindcheck")

library(colorblindcheck)

# Test palette
palette_check(palette_name = "Dark2", plot = TRUE)

# Simulate on plot
p <- ggplot(data, aes(x, y, colour = group)) +
  geom_point() +
  scale_colour_brewer(palette = "Set1")

# View with deuteranopia simulation
palette_plot(p, palette = cvd_grid)
```

---

## Faceting Strategy

### When to Facet vs Aesthetic

**Facet when**:
- Severe overlap makes comparison difficult
- Want to highlight within-panel patterns
- Need to see full distribution per group
- Comparing many groups (>7)

**Aesthetic when**:
- Comparing small differences across groups
- Overlap is minimal
- Direct visual comparison is priority
- Few groups (<7)

```r
# Facet for clarity with many groups
ggplot(data, aes(x, y)) +
  geom_point() +
  facet_wrap(~ country, scales = "free_y")

# Aesthetic for direct comparison
ggplot(data, aes(x, y, colour = treatment)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)
```

---

### Scales: Fixed vs Free

**`scales = "fixed"`** (default):
- Use for **cross-panel comparison**
- Same axis ranges across all panels
- Easy to compare absolute values

**`scales = "free"`** (or `"free_x"`, `"free_y"`):
- Use to highlight **within-panel patterns**
- Each panel optimized for its data
- Can obscure absolute differences

```r
# Fixed scales: Compare across countries
ggplot(data, aes(year, gdp)) +
  geom_line() +
  facet_wrap(~ country, scales = "fixed")

# Free scales: See trends within each country
ggplot(data, aes(year, gdp)) +
  geom_line() +
  facet_wrap(~ country, scales = "free_y")
```

**Rule**: Default to `"fixed"`. Use `"free"` only when within-panel variation is key insight.

---

### Facet Wrap vs Grid

**`facet_wrap()`**: One variable, wrapped into 2D
```r
facet_wrap(~ variable, nrow = 3, ncol = 4)
```

**`facet_grid()`**: True 2D matrix with rows and columns
```r
facet_grid(rows ~ cols)
facet_grid(treatment ~ time_point)
```

**Choose wrap when**: Single variable with many levels, want flexible layout
**Choose grid when**: Two variables, want complete cross-classification

---

## Annotation Techniques

### Direct Labeling > Legends

Reduce cognitive load by labeling directly on plot.

```r
# WITH legend (requires back-and-forth eye movement)
ggplot(data, aes(x, y, colour = country)) +
  geom_line(linewidth = 1)

# WITH direct labels (immediate understanding)
library(ggrepel)
last_points <- data |>
  group_by(country) |>
  slice_max(x, n = 1)

ggplot(data, aes(x, y, colour = country)) +
  geom_line(linewidth = 1, show.legend = FALSE) +
  geom_text_repel(
    data = last_points,
    aes(label = country),
    hjust = 0, nudge_x = 0.5
  ) +
  theme(legend.position = "none")
```

---

### Text Justification

Use **`"inward"`** for automatic smart alignment:

```r
# Auto-align toward plot center
ggplot(data, aes(x, y, label = name)) +
  geom_point() +
  geom_text(hjust = "inward", vjust = "inward", nudge_x = 0.1)
```

**Standard justification**:
- `hjust = 0`: Left-align
- `hjust = 0.5`: Center
- `hjust = 1`: Right-align
- `vjust`: Same logic for vertical

---

### Annotation Layers

**`annotate()`**: Quick single annotations without data frames
```r
ggplot(data, aes(x, y)) +
  geom_point() +
  annotate("text", x = 5, y = 10, label = "Peak", size = 5) +
  annotate("rect", xmin = 3, xmax = 7, ymin = 8, ymax = 12,
           alpha = 0.2, fill = "red")
```

**Geom layers**: Multiple annotations or data-driven placement
```r
annotations <- data.frame(
  x = c(2, 5, 8),
  y = c(10, 15, 12),
  label = c("Start", "Peak", "End")
)

ggplot(data, aes(x, y)) +
  geom_line() +
  geom_label(data = annotations, aes(label = label),
             inherit.aes = FALSE)
```

**Key**: Set `inherit.aes = FALSE` for self-contained annotations.

---

### Strategic Highlighting

```r
# Background thick white line for contrast
highlight_data <- data |> filter(country == "Brazil")

ggplot(data, aes(year, gdp, group = country)) +
  geom_line(colour = "grey80") +
  geom_line(data = highlight_data, colour = "white", linewidth = 3) +
  geom_line(data = highlight_data, colour = "red", linewidth = 1.5)
```

---

## Programming Patterns

### Tidy Evaluation (Embrace Operator)

Use `{{ var }}` to accept user-supplied variable names:

```r
# Function accepting variable names
histogram_plot <- function(data, var, bins = 30, fill = "steelblue") {
  ggplot(data, aes(x = {{ var }})) +
    geom_histogram(bins = bins, fill = fill, colour = "white") +
    theme_minimal()
}

# Usage
histogram_plot(mtcars, mpg, bins = 20)
histogram_plot(mtcars, hp, fill = "coral")
```

**Multiple variables**:
```r
scatter_plot <- function(data, x_var, y_var, color_var = NULL) {
  ggplot(data, aes(x = {{ x_var }}, y = {{ y_var }}, colour = {{ color_var }})) +
    geom_point(size = 3, alpha = 0.6) +
    theme_minimal()
}

scatter_plot(mtcars, wt, mpg, color_var = cyl)
```

---

### Reusable Components

Save theme customizations as objects:

```r
# Custom theme
publication_theme <- function() {
  theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 12, hjust = 0.5, colour = "grey50"),
      axis.title = element_text(size = 12, face = "bold"),
      axis.text = element_text(size = 10),
      panel.grid.minor = element_blank(),
      legend.position = "bottom"
    )
}

# Use across plots
ggplot(data, aes(x, y)) +
  geom_point() +
  publication_theme()
```

**Return lists for multiple components**:
```r
# Multiple layers as function
add_reference_lines <- function(h = 0, v = NULL) {
  list(
    if (!is.null(h)) geom_hline(yintercept = h, linetype = "dashed", colour = "grey50"),
    if (!is.null(v)) geom_vline(xintercept = v, linetype = "dashed", colour = "grey50")
  )
}

ggplot(data, aes(x, y)) +
  geom_point() +
  add_reference_lines(h = 0, v = 5)
```

---

### Always Include `...`

Pass additional arguments for flexibility:

```r
custom_scatter <- function(data, x, y, ...) {
  ggplot(data, aes(x = {{ x }}, y = {{ y }})) +
    geom_point(...) +  # Pass through size, colour, alpha, etc.
    theme_minimal()
}

# Users can customize
custom_scatter(mtcars, wt, mpg, size = 3, colour = "red", alpha = 0.5)
```

---

## Performance Optimization

### Overplotting Solutions

**For moderate data (<10k points)**:
```r
# Alpha transparency
ggplot(data, aes(x, y)) +
  geom_point(alpha = 0.1)

# Smaller points
ggplot(data, aes(x, y)) +
  geom_point(size = 0.5, alpha = 0.3)
```

**For dense data (>10k points)**:
```r
# Hexagonal binning
ggplot(large_data, aes(x, y)) +
  geom_hex(bins = 50) +
  scale_fill_viridis_c()

# 2D binning
ggplot(large_data, aes(x, y)) +
  geom_bin2d(bins = 50) +
  scale_fill_viridis_c()

# Density contours
ggplot(large_data, aes(x, y)) +
  stat_density_2d(aes(fill = after_stat(level)), geom = "polygon") +
  scale_fill_viridis_c()
```

---

### Aggregate Before Plotting

```r
# Instead of plotting all points and summarizing
ggplot(huge_data, aes(category, value)) +
  stat_summary(fun = mean, geom = "point")  # Slow with huge_data

# Better: Aggregate first
summary_data <- huge_data |>
  group_by(category) |>
  summarise(
    mean_value = mean(value),
    se = sd(value) / sqrt(n())
  )

ggplot(summary_data, aes(category, mean_value)) +
  geom_point() +
  geom_errorbar(aes(ymin = mean_value - se, ymax = mean_value + se), width = 0.2)
```

---

### Reproducibility

**Set seeds for jittering/sampling**:
```r
set.seed(123)
ggplot(data, aes(category, value)) +
  geom_jitter(width = 0.2)
```

**Document parameters**:
```r
# In figure caption:
# "Histogram with binwidth = 5 years"
# "Loess smooth with span = 0.3"
# "Points jittered (width = 0.2, seed = 123)"
```

---

## Publication Workflow

### Export High-Quality

```r
# Vector formats (scalable, best for publication)
ggsave("figure1.pdf", width = 8, height = 6, device = cairo_pdf)
ggsave("figure1.svg", width = 8, height = 6)

# Raster for presentations (high DPI)
ggsave("figure1.png", width = 8, height = 6, dpi = 300)
ggsave("figure1.tiff", width = 8, height = 6, dpi = 600)  # Journal requirements

# Control size precisely
ggsave("figure1.pdf", width = 180, height = 120, units = "mm")
```

---

### Font Management

```r
# Use cairo for better text rendering
ggsave("plot.pdf", device = cairo_pdf)

# Embed fonts
library(extrafont)
loadfonts()

ggplot(data, aes(x, y)) +
  geom_point() +
  theme_minimal(base_family = "Arial")

ggsave("plot.pdf", device = cairo_pdf, width = 8, height = 6)
embed_fonts("plot.pdf")
```

---

### Multi-Panel Figures (Patchwork)

```r
library(patchwork)

# Create individual plots
p1 <- ggplot(data, aes(x, y)) + geom_point() + labs(tag = "A")
p2 <- ggplot(data, aes(x, z)) + geom_point() + labs(tag = "B")
p3 <- ggplot(data, aes(y, z)) + geom_point() + labs(tag = "C")

# Compose
(p1 | p2) / p3 +
  plot_layout(guides = "collect") +
  plot_annotation(
    title = "Comprehensive Analysis",
    caption = "Data source: ...",
    theme = theme(plot.title = element_text(size = 16, face = "bold"))
  )

# Save
ggsave("figure_combined.pdf", width = 12, height = 8)
```

---

### Accessibility Checklist

✅ Colorblind-safe palette (Viridis or tested ColorBrewer)
✅ Redundant encoding (colour + shape, or colour + linetype)
✅ Sufficient contrast (test with grayscale conversion)
✅ Clear labels and titles (no abbreviations without explanation)
✅ Readable text size (base_size ≥ 11 for most outputs)
✅ Alternative text for web (use `labs(alt = "...")`)
✅ High resolution for print (dpi ≥ 300)

---

## Summary: Golden Rules

1. **Build incrementally** - Compose independent components
2. **Inside aes() = variable, outside = fixed** - Never confuse them
3. **coord_cartesian() for zoom** - Preserve data for calculations
4. **Always set binwidth** - Never rely on defaults
5. **Colorblind-safe palettes** - Viridis first choice
6. **Redundant encoding** - Color + shape/linetype
7. **Direct labeling > legends** - Reduce cognitive load
8. **Aggregate before plotting** - For large datasets
9. **Vector formats for publication** - PDF/SVG, not PNG
10. **Test accessibility** - Colorblind simulators, grayscale

---

**See [../examples/plot-examples.md](../examples/plot-examples.md) for implementations of these patterns.**
