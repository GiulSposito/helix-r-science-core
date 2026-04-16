# Scales Reference - Detailed Guide

Comprehensive guide to ggplot2 scales: the functions that control how data values map to visual properties and generate axes/legends.

## Core Concept

**Every aesthetic needs exactly one scale.** Scales perform two key functions:
1. **Transform** data values to visual properties (colors, sizes, positions)
2. **Generate** guides (axes and legends) so humans can read the plot

**Naming pattern**: `scale_[aesthetic]_[type]`
- aesthetic: x, y, colour, fill, size, shape, alpha, linetype
- type: continuous, discrete, binned, manual, identity, date, datetime

---

## Position Scales

### Continuous Position Scales

#### scale_x_continuous() / scale_y_continuous()

**Purpose**: Map continuous numeric data to position.

```r
scale_x_continuous(
  name = waiver(),          # Axis title
  breaks = waiver(),        # Tick positions (NULL = none, waiver() = auto)
  minor_breaks = waiver(),  # Minor tick positions
  labels = waiver(),        # Tick labels (NULL = none, function allowed)
  limits = NULL,            # Data range (NA to compute from data)
  expand = waiver(),        # Padding (expansion())
  oob = censor,             # Out-of-bounds handler
  na.value = NA_real_,      # Replacement for NA
  trans = "identity",       # Transformation ("log10", "sqrt", "reverse", etc.)
  guide = waiver(),         # Axis type
  position = "bottom"       # "bottom", "top", "left", "right"
)
```

**Common Patterns**:

```r
# Custom breaks and labels
ggplot(data, aes(x, y)) +
  geom_point() +
  scale_x_continuous(
    breaks = c(0, 25, 50, 75, 100),
    labels = c("None", "Low", "Med", "High", "Max")
  )

# Remove padding
ggplot(data, aes(x, y)) +
  geom_col() +
  scale_y_continuous(expand = c(0, 0))

# Percentage labels
ggplot(data, aes(x, y)) +
  geom_line() +
  scale_y_continuous(labels = scales::percent_format())

# Dollar labels
ggplot(data, aes(x, sales)) +
  geom_col() +
  scale_y_continuous(labels = scales::dollar_format(prefix = "$"))

# Comma formatting
ggplot(data, aes(x, population)) +
  geom_point() +
  scale_y_continuous(labels = scales::comma_format())
```

**Important**: Setting `limits` **discards data** outside range. Use `coord_cartesian(xlim, ylim)` to zoom without removing data.

---

#### Transformed Scales

Convenience functions for common transformations:

```r
# Log scale
scale_x_log10(breaks = c(1, 10, 100, 1000))
scale_y_log10()

# Square root
scale_x_sqrt()

# Reverse
scale_x_reverse()
scale_y_reverse()

# Custom transformation
scale_x_continuous(trans = "log10")
scale_x_continuous(trans = scales::pseudo_log_trans())
scale_x_continuous(trans = scales::boxcox_trans(0.5))
```

**Examples**:

```r
# Log-scale for skewed data
ggplot(data, aes(population, gdp)) +
  geom_point() +
  scale_x_log10(
    breaks = c(1e6, 1e7, 1e8),
    labels = scales::label_number(scale = 1e-6, suffix = "M")
  ) +
  scale_y_log10()

# Reverse axis
ggplot(data, aes(depth, temperature)) +
  geom_line() +
  scale_y_reverse()  # Depth increases downward
```

---

### Discrete Position Scales

#### scale_x_discrete() / scale_y_discrete()

**Purpose**: Map categorical/factor data to position.

```r
scale_x_discrete(
  name = waiver(),
  breaks = waiver(),    # Which levels to show
  labels = waiver(),    # Custom labels for levels
  limits = NULL,        # Reorder or subset levels
  expand = waiver(),
  guide = waiver(),
  position = "bottom"
)
```

**Common Patterns**:

```r
# Reorder levels
ggplot(data, aes(category, value)) +
  geom_col() +
  scale_x_discrete(limits = c("Low", "Medium", "High"))

# Subset levels
ggplot(data, aes(category, value)) +
  geom_boxplot() +
  scale_x_discrete(limits = c("A", "C", "E"))  # Show only A, C, E

# Custom labels
ggplot(data, aes(category, value)) +
  geom_col() +
  scale_x_discrete(
    labels = c("A" = "Group Alpha", "B" = "Group Beta")
  )

# Wrap long labels
ggplot(data, aes(long_category, value)) +
  geom_col() +
  scale_x_discrete(labels = scales::label_wrap(10))
```

---

### Date/Time Scales

#### scale_x_date() / scale_x_datetime()

**Purpose**: Map dates or date-times to position with date-aware formatting.

```r
scale_x_date(
  name = waiver(),
  breaks = waiver(),           # Date positions
  date_breaks = waiver(),      # Auto breaks: "1 month", "2 years", etc.
  date_labels = waiver(),      # Date format: "%Y", "%b %d", etc.
  date_minor_breaks = waiver(),
  limits = NULL,
  expand = waiver()
)

scale_x_datetime(...)  # Same parameters
```

**Date Format Codes** (strptime):
- `%Y` - 4-digit year (2024)
- `%y` - 2-digit year (24)
- `%m` - Month number (01-12)
- `%b` - Abbreviated month (Jan)
- `%B` - Full month (January)
- `%d` - Day of month (01-31)
- `%H` - Hour (00-23)
- `%M` - Minute (00-59)
- `%S` - Second (00-59)

**Common Patterns**:

```r
# Monthly breaks
ggplot(data, aes(date, value)) +
  geom_line() +
  scale_x_date(
    date_breaks = "1 month",
    date_labels = "%b %Y"
  )

# Yearly breaks
ggplot(data, aes(date, value)) +
  geom_line() +
  scale_x_date(
    date_breaks = "2 years",
    date_labels = "%Y"
  )

# Custom date range
ggplot(data, aes(date, value)) +
  geom_line() +
  scale_x_date(
    limits = as.Date(c("2020-01-01", "2024-12-31")),
    date_breaks = "6 months",
    date_labels = "%b\n%Y"  # \n creates line break
  )

# Week-based breaks
ggplot(data, aes(date, value)) +
  geom_line() +
  scale_x_date(
    date_breaks = "1 week",
    date_labels = "%W",     # Week number
    date_minor_breaks = "1 day"
  )

# Time series with datetime
ggplot(data, aes(timestamp, value)) +
  geom_line() +
  scale_x_datetime(
    date_breaks = "6 hours",
    date_labels = "%H:%M"
  )
```

---

## Color and Fill Scales

### Continuous Color Scales

See [themes-styling.md](themes-styling.md) for complete color scale documentation. Quick reference:

```r
# Viridis (recommended)
scale_colour_viridis_c(option = "viridis", direction = 1)
scale_fill_viridis_c(option = "plasma")

# Gradient (2-color)
scale_colour_gradient(low = "white", high = "red")
scale_fill_gradient(low = "blue", high = "yellow")

# Gradient2 (3-color diverging)
scale_colour_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0)
scale_fill_gradient2(...)

# Gradientn (n-color custom)
scale_colour_gradientn(colours = c("blue", "cyan", "yellow", "red"))
scale_fill_gradientn(colours = c("#1B9E77", "#D95F02", "#7570B3"))

# ColorBrewer continuous
scale_colour_distiller(palette = "Blues", direction = 1)
scale_fill_distiller(palette = "RdYlBu", type = "div")
```

---

### Discrete Color Scales

```r
# Viridis
scale_colour_viridis_d(option = "mako", begin = 0.2, end = 0.8)
scale_fill_viridis_d(option = "rocket")

# ColorBrewer
scale_colour_brewer(palette = "Set1", type = "qual")    # Qualitative
scale_fill_brewer(palette = "YlOrRd", type = "seq")     # Sequential
scale_colour_brewer(palette = "RdBu", type = "div")     # Diverging

# Manual
scale_colour_manual(
  values = c("A" = "red", "B" = "blue", "C" = "green")
)
scale_fill_manual(values = c("#E41A1C", "#377EB8", "#4DAF4A"))

# Hue (default)
scale_colour_hue(h = c(0, 360), l = 65, c = 100)
scale_fill_hue()

# Greyscale
scale_colour_grey(start = 0.2, end = 0.8)
scale_fill_grey()
```

---

## Size, Shape, Alpha, Linetype Scales

### Size Scales

```r
# Continuous size
scale_size_continuous(range = c(1, 10))  # Min and max sizes
scale_size(range = c(0.5, 5))            # Alias

# Area-based sizing (better for perception)
scale_size_area(max_size = 10)

# Binned size
scale_size_binned(range = c(1, 10), n.breaks = 5)

# Discrete size
scale_size_discrete(range = c(2, 6))

# Manual size
scale_size_manual(values = c("Small" = 2, "Medium" = 4, "Large" = 6))
```

**Example**:
```r
# Bubble chart with area-based sizing
ggplot(data, aes(x, y, size = population)) +
  geom_point(alpha = 0.6) +
  scale_size_area(max_size = 20) +  # Area proportional to value
  labs(size = "Population")
```

---

### Shape Scales

```r
# Discrete shapes (automatic)
scale_shape(solid = TRUE)  # Use filled shapes only

# Manual shapes
scale_shape_manual(
  values = c("A" = 16, "B" = 17, "C" = 15)  # Shape codes 0-25
)

# Specific shape palette
scale_shape_manual(values = c(21, 22, 23, 24, 25))  # Two-color shapes
```

**Shape Codes**:
- 0-20: Single color (use `colour`)
- 21-25: Two colors (use `colour` for border, `fill` for interior)
  - 21: circle, 22: square, 23: diamond, 24: triangle up, 25: triangle down

---

### Alpha (Transparency) Scales

```r
# Continuous alpha
scale_alpha_continuous(range = c(0.1, 1))
scale_alpha(range = c(0.2, 0.8))  # Alias

# Discrete alpha
scale_alpha_discrete(range = c(0.3, 1))

# Manual alpha
scale_alpha_manual(values = c("Low" = 0.3, "Medium" = 0.6, "High" = 1))
```

---

### Linetype Scales

```r
# Discrete linetypes (automatic)
scale_linetype()

# Manual linetypes
scale_linetype_manual(
  values = c(
    "Solid" = "solid",
    "Dashed" = "dashed",
    "Dotted" = "dotted"
  )
)

# Numeric codes
scale_linetype_manual(values = c(1, 2, 3))  # 1=solid, 2=dashed, 3=dotted
```

**Linetype Values**:
- 0 = blank, 1 = solid, 2 = dashed
- 3 = dotted, 4 = dotdash, 5 = longdash, 6 = twodash
- Or strings: "solid", "dashed", "dotted", "dotdash", "longdash", "twodash"

---

## Guide Customization

Scales automatically generate guides (axes and legends). Customize with `guide` parameter or `guides()` function.

### Legend Guides

```r
# Customize in scale
scale_colour_viridis_d(
  guide = guide_legend(
    title = "Category",
    nrow = 2,                    # Arrange in rows
    ncol = NULL,                 # Or columns
    reverse = FALSE,             # Reverse order
    override.aes = list(size = 5), # Override aesthetics in legend
    title.position = "top",      # "top", "bottom", "left", "right"
    label.position = "right",    # Label placement relative to key
    keywidth = unit(1, "cm"),
    keyheight = unit(1, "cm")
  )
)

# Or use guides()
ggplot(data, aes(x, y, colour = group)) +
  geom_point() +
  guides(colour = guide_legend(nrow = 2, title = "Group"))
```

---

### Colorbar Guides (Continuous)

```r
scale_fill_viridis_c(
  guide = guide_colourbar(
    title = "Value",
    title.position = "top",
    barwidth = unit(15, "cm"),
    barheight = unit(0.5, "cm"),
    direction = "horizontal",     # or "vertical"
    reverse = FALSE,
    label = TRUE,
    ticks = TRUE,
    draw.ulim = TRUE,            # Draw upper/lower limits
    draw.llim = TRUE
  )
)
```

---

### Axis Guides

```r
scale_x_continuous(
  guide = guide_axis(
    title = "X Variable",
    n.dodge = 2,              # Stagger labels in 2 rows
    angle = 45,               # Rotate labels
    check.overlap = TRUE      # Hide overlapping labels
  )
)
```

---

### Remove Legends/Axes

```r
# Remove legend for specific aesthetic
scale_colour_discrete(guide = "none")

# Or use guides()
guides(colour = "none", size = "none")

# Remove all legends
theme(legend.position = "none")

# Remove axis text/title
scale_x_continuous(labels = NULL)  # Remove labels, keep ticks
theme(axis.text.x = element_blank())  # Remove labels and ticks
```

---

## Special Scale Functions

### limits()

Shorthand for setting scale limits:

```r
# Instead of scale_x_continuous(limits = c(0, 100))
ggplot(data, aes(x, y)) +
  geom_point() +
  lims(x = c(0, 100), y = c(0, 50))

# Or
xlim(0, 100)
ylim(0, 50)
```

**Warning**: These **discard data** outside limits. Use `coord_cartesian()` for visual zoom.

---

### expansion()

Control padding around data:

```r
# Multiplicative expansion (percentage)
expansion(mult = 0.05)           # 5% on both sides
expansion(mult = c(0, 0.1))      # 0% low end, 10% high end

# Additive expansion (fixed units)
expansion(add = 2)               # 2 units on both sides
expansion(add = c(0, 5))         # 0 low end, 5 high end

# Combine
expansion(mult = 0.05, add = 1)
```

**Example**:
```r
# No padding for bar charts
ggplot(data, aes(category, value)) +
  geom_col() +
  scale_y_continuous(expand = c(0, 0))

# Asymmetric padding
ggplot(data, aes(x, y)) +
  geom_point() +
  scale_y_continuous(expand = expansion(mult = c(0.05, 0.15)))
```

---

### Out-of-Bounds Handling

```r
# Default: convert to NA
scale_colour_gradient(limits = c(0, 100), oob = scales::censor)

# Squish to range (no NAs)
scale_colour_gradient(limits = c(0, 100), oob = scales::squish)

# Squish infinite values only
scale_colour_gradient(oob = scales::oob_squish_infinite)
```

---

## Secondary Axes

Create secondary axes that are transformations of the primary axis:

```r
# Simple transformation
ggplot(data, aes(temp_celsius, value)) +
  geom_line() +
  scale_x_continuous(
    name = "Temperature (°C)",
    sec.axis = sec_axis(~ . * 9/5 + 32, name = "Temperature (°F)")
  )

# With custom breaks
ggplot(data, aes(x, y)) +
  geom_line() +
  scale_y_continuous(
    sec.axis = sec_axis(
      trans = ~ . / 1000,
      name = "Value (thousands)",
      breaks = c(0, 50, 100)
    )
  )

# Duplicate axis
scale_x_continuous(sec.axis = dup_axis())
```

**Important**: Secondary axes must be monotonic transformations of primary axis. They cannot show unrelated data.

---

## Best Practices

### Choosing Scales

**Position**:
- Continuous numeric → `scale_*_continuous()`
- Categorical → `scale_*_discrete()`
- Dates → `scale_*_date()` or `scale_*_datetime()`
- Need log/sqrt → Use transformed scales

**Color**:
- Continuous → Viridis (`scale_colour_viridis_c()`)
- Diverging → Gradient2 or ColorBrewer diverging
- Categorical (<7) → ColorBrewer qualitative or manual
- Categorical (>7) → Consider faceting

### Limits vs Coord

```r
# WRONG: Discards data, affects stats
ggplot(data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm") +
  scale_x_continuous(limits = c(0, 100))  # lm computed on full data, then subset

# RIGHT: Visual zoom, preserves data
ggplot(data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm") +
  coord_cartesian(xlim = c(0, 100))  # lm computed on limited data
```

### Label Formatting

Use `scales` package for professional formatting:

```r
library(scales)

# Percentages
scale_y_continuous(labels = percent_format())
scale_y_continuous(labels = percent_format(accuracy = 0.1))

# Currency
scale_y_continuous(labels = dollar_format(prefix = "$", big.mark = ","))
scale_y_continuous(labels = dollar_format(prefix = "€"))

# Numbers
scale_y_continuous(labels = comma_format())
scale_y_continuous(labels = number_format(scale = 1e-6, suffix = "M"))
scale_y_continuous(labels = scientific_format())

# Dates
scale_x_date(labels = date_format("%b %Y"))
```

### Legend Positioning

```r
# Inside plot area
theme(
  legend.position = c(0.95, 0.95),  # x, y in 0-1 scale
  legend.justification = c(1, 1),   # Anchor at top-right
  legend.background = element_rect(fill = "white", colour = "black")
)

# Outside plot
theme(legend.position = "right")   # "top", "bottom", "left", "right"

# Remove
theme(legend.position = "none")
```

---

**See [themes-styling.md](themes-styling.md) for detailed color scale documentation.**
**See [../examples/plot-examples.md](../examples/plot-examples.md) for scale usage examples.**
