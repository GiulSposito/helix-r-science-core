---
name: ggplot2
description: Expert ggplot2 data visualization in R - grammar of graphics, geoms, themes, scales, faceting, and styling. Use when user works with ggplot2, mentions "ggplot", "geom_", creates visualizations in R, asks about plot customization, "customizar theme", "customize theme", "customizar plot", themes, "facet_wrap", "facet_grid", "faceting", "facetas", "anotações", "annotations", "annotate", "adicionar anotações", "color scale", "scales", "escala de cores", "gráfico", "plot", "visualização", or data visualization best practices.
version: 1.1.0
allowed-tools: Read, Write, Edit, Grep, Glob
user-invocable: false
---

# ggplot2 Expert - Comprehensive Data Visualization Skill

Master data visualization in R using ggplot2's layered grammar of graphics. This skill provides expert guidance on creating effective, publication-ready visualizations with complete control over all visual elements.

## The Layered Grammar of Graphics

Every ggplot2 visualization is built from **five independent components**:

1. **Layers** - Data + geometric objects (geoms) + statistical transformations (stats)
2. **Scales** - Map data values to aesthetics (color, size, position) and generate legends/axes
3. **Coordinate Systems** - Transform data coordinates to plot positions
4. **Facets** - Create small multiples for comparing subsets
5. **Themes** - Control all non-data display elements

**Philosophy**: Build plots incrementally by composing independent components, not by selecting from fixed templates. This enables infinite flexibility while mirroring analytical thinking.

## Core Workflow

### 1. Basic Plot Structure

```r
ggplot(data = <DATA>, mapping = aes(<MAPPINGS>)) +
  <GEOM_FUNCTION>() +
  <SCALE_FUNCTIONS>() +
  <COORDINATE_FUNCTION>() +
  <FACET_FUNCTION>() +
  <THEME_FUNCTION>()
```

**Key Principles**:
- `aes()` maps **variables** to visual properties (inside geom or ggplot)
- Fixed values go **outside** `aes()` (e.g., `colour = "blue"`)
- Build incrementally with `+` operator
- Each layer is independent and composable

### 2. Layer Purpose Framework

Every layer should serve one of three purposes:
1. **Display raw data** - Pattern detection, outlier identification
2. **Show statistical summaries** - Model predictions, trends, aggregations
3. **Add metadata/context** - Backgrounds, annotations, reference lines

### 3. Common Mistakes to Avoid

❌ **Wrong**: `aes(colour = "blue")` - Maps string "blue" as data
✅ **Right**: `colour = "blue"` outside aes() - Sets fixed color

❌ **Wrong**: `ggplot(df, aes(x = df$variable))` - Breaks plot self-containment
✅ **Right**: `ggplot(df, aes(x = variable))` - Self-contained reference

❌ **Wrong**: `aes(x = log(variable))` - Complex calculation in aes
✅ **Right**: Use `dplyr::mutate()` first, then map the result

❌ **Wrong**: Accepting default bin widths
✅ **Right**: Always experiment with `binwidth` or `bins`

❌ **Wrong**: Mapping too many aesthetics simultaneously
✅ **Right**: Create series of simpler plots for clarity

## Geom Selection Guide

See [references/geoms-reference.md](references/geoms-reference.md) for complete documentation.

### Quick Reference

**Continuous Relationships**:
- `geom_point()` - Scatter plots (x-y relationships)
- `geom_line()` - Time series (connects in x-order)
- `geom_path()` - Connections in data order
- `geom_smooth()` - Add trend lines with confidence bands

**Distributions**:
- `geom_histogram()` - Continuous distribution via binning
- `geom_freqpoly()` - Frequency polygon (better for comparisons)
- `geom_density()` - Smooth density estimate
- `geom_boxplot()` - Five-number summary with outliers
- `geom_violin()` - Distribution shape (mirrored density)

**Categorical Data**:
- `geom_bar()` - Count occurrences (`stat = "count"`)
- `geom_col()` - Use pre-calculated values (`stat = "identity"`)
- Position: "stack" (default), "dodge" (side-by-side), "fill" (proportions)

**Text & Annotations**:
- `geom_text()` - Add text labels
- `geom_label()` - Text with background rectangle
- `annotate()` - Quick single annotations without data frames

**See [examples/plot-examples.md](examples/plot-examples.md) for complete working examples.**

## Aesthetics Mapping

**Universal Aesthetics** (work with most geoms):
- `x`, `y` - Position
- `colour` - Border/line color
- `fill` - Interior color (shapes 21-25, bars, areas)
- `alpha` - Transparency (0-1)
- `size` - Size of points/lines
- `shape` - Point shape (0-25)
- `linetype` - Line pattern ("solid", "dashed", "dotted", etc.)
- `group` - Define grouping for collective geoms

**Geom-Specific Aesthetics**:
- Labels: `label`, `hjust`, `vjust`, `angle`, `family`, `fontface`
- Boxplots: `lower`, `upper`, `middle`, `ymin`, `ymax`
- Errorbar/ribbon: `ymin`, `ymax` (or xmin/xmax)

## Scales & Legends

See [references/scales-reference.md](references/scales-reference.md) for complete documentation.

### Naming Pattern

`scale_[aesthetic]_[type]` - e.g., `scale_colour_viridis_c()`

- **aesthetic**: x, y, colour, fill, size, shape, alpha, linetype
- **type**: continuous, discrete, binned, manual, identity

### Common Scale Functions

**Position Scales**:
```r
scale_x_continuous(limits, breaks, labels, trans, expand)
scale_x_discrete(limits, labels, expand)
scale_x_log10()  # Log transformation
scale_x_date(date_breaks = "1 month", date_labels = "%b %Y")
```

**Color Scales** (accessibility-first):
```r
# Viridis (perceptually uniform, colorblind-safe)
scale_colour_viridis_c(option = "viridis")  # continuous
scale_colour_viridis_d()                    # discrete

# ColorBrewer
scale_colour_brewer(palette = "Set1", type = "qual")  # categorical
scale_fill_distiller(palette = "Blues")               # continuous

# Custom gradients
scale_colour_gradient(low = "white", high = "red")
scale_colour_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0)
scale_colour_gradientn(colours = c("red", "yellow", "green", "blue"))

# Manual
scale_colour_manual(values = c("A" = "#E41A1C", "B" = "#377EB8"))
```

**Important**: Setting scale `limits` **discards data** outside range. Use `coord_cartesian(xlim, ylim)` to zoom without losing data (preserves stat calculations).

## Themes & Styling

See [references/themes-styling.md](references/themes-styling.md) for complete documentation.

### Built-in Themes

```r
theme_grey()      # Default: grey background, white gridlines
theme_bw()        # Classic dark-on-light, good for projectors
theme_minimal()   # No background annotations, minimalist
theme_classic()   # X/Y axis lines, no gridlines
theme_light()     # Light grey lines, focuses on data
theme_dark()      # Dark background, makes colors pop
theme_void()      # Completely empty
```

All themes accept: `base_size`, `base_family`, `base_line_size`, `base_rect_size`

### Theme Customization

```r
theme(
  # Plot-level
  plot.title = element_text(size = 14, face = "bold"),
  plot.subtitle = element_text(size = 12, colour = "grey50"),
  plot.background = element_rect(fill = "white"),
  plot.margin = margin(10, 10, 10, 10),

  # Panels
  panel.background = element_rect(fill = "white"),
  panel.grid.major = element_line(colour = "grey90"),
  panel.grid.minor = element_blank(),

  # Axes
  axis.title = element_text(size = 12),
  axis.text = element_text(size = 10),
  axis.ticks = element_line(colour = "black"),

  # Legends
  legend.position = "right",  # or "top", "bottom", "left", "none"
  legend.title = element_text(face = "bold"),
  legend.background = element_rect(fill = "white", colour = "black"),

  # Facets
  strip.text = element_text(size = 11, face = "bold"),
  strip.background = element_rect(fill = "grey80")
)
```

**Element Functions**:
- `element_text()` - Customize text
- `element_rect()` - Customize backgrounds/borders
- `element_line()` - Customize lines
- `element_blank()` - Remove elements entirely

## Faceting

### facet_wrap() - Single Variable

Use for one variable with many levels, wrapped into 2D:

```r
facet_wrap(
  ~ variable,           # or vars(variable)
  nrow = 2, ncol = 3,  # grid dimensions
  scales = "fixed",     # or "free", "free_x", "free_y"
  dir = "h",           # "h" (horizontal) or "v" (vertical)
  labeller = label_value
)
```

### facet_grid() - Two Variables

Use for true 2D grid with all combinations:

```r
facet_grid(
  rows ~ cols,          # or rows = vars(...), cols = vars(...)
  scales = "fixed",     # or "free_x", "free_y", "free"
  space = "fixed",      # or "free_x", "free_y", "free" (panel sizing)
  margins = FALSE,      # add summary facets
  labeller = label_value
)
```

**When to use which**:
- `scales = "fixed"` - For cross-panel comparison (consistent axes)
- `scales = "free"` - To highlight within-panel patterns
- Faceting > aesthetic grouping when overlap is severe
- Aesthetic grouping > faceting when comparing small differences

## Coordinate Systems

```r
coord_cartesian(xlim, ylim, expand = TRUE)  # Visual zoom (preserves data)
coord_fixed(ratio = 1)                       # Fixed aspect ratio
coord_flip()                                  # Swap x and y axes
coord_polar()                                 # Polar coordinates
coord_map()                                   # Map projections
```

**Critical difference**: `coord_cartesian()` zooms **visually** while `scale_*_continuous(limits = ...)` **discards data** before calculations.

## Position Adjustments

```r
position_dodge(width = 0.9)      # Side-by-side (bars, boxplots)
position_stack()                  # Stack vertically
position_fill()                   # Stack and normalize to 100%
position_jitter(width, height)    # Add random noise (overplotting)
position_nudge(x, y)             # Fixed-distance offset
```

## Labels & Annotations

```r
labs(
  title = "Main Title",
  subtitle = "Subtitle text",
  caption = "Data source",
  x = "X-axis label",
  y = "Y-axis label",
  colour = "Legend title",
  fill = "Fill legend title"
)
```

**Text Annotations**:
```r
# Quick annotation without data frame
annotate("text", x = 5, y = 10, label = "Important point",
         hjust = "inward", vjust = "inward")

# Data-driven annotations
geom_text(aes(label = label_var), hjust = "inward", check_overlap = TRUE)
geom_label(aes(label = label_var), nudge_y = 0.5)
```

**Reference Lines**:
```r
geom_hline(yintercept = 0, linetype = "dashed", colour = "red")
geom_vline(xintercept = 5, linetype = "dashed")
geom_abline(intercept = 0, slope = 1)
```

## Programming with ggplot2

### Tidy Evaluation (Embrace Operator)

Use `{{ var }}` to accept user-supplied variable names:

```r
my_histogram <- function(data, var, bins = 30) {
  ggplot(data, aes(x = {{ var }})) +
    geom_histogram(bins = bins) +
    theme_minimal()
}

# Usage
my_histogram(mtcars, mpg, bins = 20)
```

### Reusable Components

```r
# Save components as objects
my_theme <- theme_minimal() +
  theme(
    plot.title = element_text(face = "bold"),
    axis.text = element_text(size = 11)
  )

# Use across plots
ggplot(data, aes(x, y)) + geom_point() + my_theme
```

### Plot Functions

```r
scatter_with_smooth <- function(data, x_var, y_var, ...) {
  ggplot(data, aes(x = {{ x_var }}, y = {{ y_var }})) +
    geom_point(alpha = 0.5) +
    geom_smooth(method = "lm", ...) +
    theme_bw()
}
```

## Combining Plots (patchwork)

```r
library(patchwork)

# Basic composition
p1 + p2           # Auto-arrange
p1 | p2           # Single row
p1 / p2           # Single column
(p1 | p2) / p3    # Complex layouts

# Advanced control
p1 + p2 +
  plot_layout(ncol = 2, guides = "collect") +
  plot_annotation(title = "Combined Analysis", tag_levels = "A")
```

## Best Practices

See [references/best-practices.md](references/best-practices.md) for comprehensive guidance.

### Quick Tips

**Aesthetics**:
- Use colorblind-safe palettes (Viridis, ColorBrewer)
- Provide redundant encodings (size + color, or shape + color)
- Limit aesthetics per plot (3-4 max for clarity)

**Annotations**:
- Direct labeling > legends (reduces cognitive load)
- Use `hjust/vjust = "inward"` for automatic alignment
- Set `inherit.aes = FALSE` for self-contained annotations

**Performance**:
- Use `alpha` for overplotting instead of `geom_jitter()`
- Consider `geom_hex()` or `geom_bin2d()` for dense data (>10k points)
- Use `stat_summary()` to aggregate before plotting

**Reproducibility**:
- Set explicit `binwidth`/`bins` (never rely on defaults)
- Document all scale transformations
- Use `set.seed()` before jittering
- Export with `ggsave()` using vector formats (PDF/SVG) for publication

## Quick Start Examples

```r
# Basic scatter with smooth
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(colour = class)) +
  geom_smooth(method = "lm", se = TRUE) +
  scale_colour_viridis_d() +
  labs(title = "Engine Size vs Highway MPG",
       x = "Displacement (L)", y = "Highway MPG") +
  theme_minimal()

# Histogram with facets
ggplot(mpg, aes(hwy)) +
  geom_histogram(binwidth = 2, fill = "steelblue", colour = "white") +
  facet_wrap(~ class, scales = "free_y") +
  theme_bw()

# Boxplot with custom theme
ggplot(mpg, aes(class, hwy, fill = class)) +
  geom_boxplot(show.legend = FALSE) +
  scale_fill_brewer(palette = "Set2") +
  coord_flip() +
  theme_minimal() +
  theme(panel.grid.major.y = element_blank())
```

**See [examples/plot-examples.md](examples/plot-examples.md) for comprehensive working examples.**

**See [templates/plot-templates.md](templates/plot-templates.md) for reusable templates.**

## Workflow Guidance

When user asks about ggplot2 visualizations:

1. **Understand the goal**: What pattern/comparison/relationship to show?
2. **Select appropriate geom**: Match data type and purpose
3. **Map aesthetics**: Which variables map to which visual properties?
4. **Choose scales**: Appropriate for data type (continuous/discrete/date)
5. **Apply theme**: Publication-ready styling
6. **Add context**: Labels, annotations, reference lines
7. **Optimize**: Adjust transparency, position, faceting for clarity

Always provide complete, runnable code examples with proper formatting and best practices applied.

## Additional Resources

### Core References
- **Geoms**: [references/geoms-reference.md](references/geoms-reference.md)
- **Themes & Styling**: [references/themes-styling.md](references/themes-styling.md)
- **Scales**: [references/scales-reference.md](references/scales-reference.md)
- **Best Practices**: [references/best-practices.md](references/best-practices.md)
- **Advanced Customization**: [references/advanced-customization.md](references/advanced-customization.md)

### Examples & Gallery
- **Basic Examples**: [examples/plot-examples.md](examples/plot-examples.md)
- **Templates**: [templates/plot-templates.md](templates/plot-templates.md)
- **Gallery - Distribution & Correlation**: [examples/gallery-distribution-correlation.md](examples/gallery-distribution-correlation.md)
- **Gallery - Evolution & Ranking**: [examples/gallery-evolution-ranking.md](examples/gallery-evolution-ranking.md)
- **Gallery - Best Practices**: [examples/gallery-best-practices.md](examples/gallery-best-practices.md)
