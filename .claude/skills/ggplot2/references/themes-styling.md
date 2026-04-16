# Themes & Styling Reference

Complete guide to ggplot2 themes, color scales, and visual styling for publication-ready plots.

## Table of Contents

- [Complete Themes](#complete-themes)
- [Theme Customization](#theme-customization)
- [Color Scales](#color-scales)
- [Scale Customization](#scale-customization)
- [Best Practices](#best-practices)

---

## Complete Themes

### Built-in Themes

All complete themes replace the entire theme system. Apply before custom theme() modifications.

#### theme_grey() (Default)

Grey background with white gridlines. Data-forward design that ensures nothing interferes with perception.

```r
ggplot(data, aes(x, y)) +
  geom_point() +
  theme_grey(base_size = 11, base_family = "")
```

**When to use**: Default choice for exploratory analysis and general use.

---

#### theme_bw()

Classic dark-on-light ggplot2 theme. Popular for publications.

```r
ggplot(data, aes(x, y)) +
  geom_point() +
  theme_bw()
```

**When to use**: Projectors, publications, classic aesthetic.

---

#### theme_minimal()

Minimalist theme with no background annotations. Clean and modern.

```r
ggplot(data, aes(x, y)) +
  geom_point() +
  theme_minimal()
```

**When to use**: Modern presentations, dashboards, when you want focus on data.

---

#### theme_classic()

Theme with x and y axis lines and no gridlines. Traditional appearance.

```r
ggplot(data, aes(x, y)) +
  geom_point() +
  theme_classic()
```

**When to use**: Academic publications with traditional formatting requirements.

---

#### theme_light()

Light grey lines and axes. Directs more attention towards data by making axes less prominent.

```r
ggplot(data, aes(x, y)) +
  geom_point() +
  theme_light()
```

**When to use**: When you want subtle axis presence.

---

#### theme_dark()

Dark background. Makes colored lines and points pop.

```r
ggplot(data, aes(x, y)) +
  geom_point() +
  theme_dark()
```

**When to use**: Presentations on dark backgrounds, dashboards with dark themes.

---

#### theme_linedraw()

Black lines of various widths on white backgrounds. Line-drawing aesthetic.

```r
ggplot(data, aes(x, y)) +
  geom_point() +
  theme_linedraw()
```

**When to use**: When emphasizing structure and boundaries.

---

#### theme_void()

Completely empty theme. No axes, gridlines, or background.

```r
ggplot(data, aes(x, y)) +
  geom_point() +
  theme_void()
```

**When to use**: Maps, diagram-style plots, highly customized visualizations.

---

### Theme Parameters

All complete themes accept these parameters:

```r
theme_*(
  base_size = 11,           # Base font size in points
  base_family = "",         # Base font family
  base_line_size = 0.5,     # Base line thickness
  base_rect_size = 0.5      # Base border thickness
)
```

---

## Theme Customization

### Element Functions

Four element functions control all theme components:

#### element_text()

Customize text elements (titles, labels, axis text).

```r
element_text(
  family = NULL,         # Font family ("sans", "serif", "mono")
  face = NULL,          # "plain", "bold", "italic", "bold.italic"
  colour = NULL,        # Text color
  size = NULL,          # Font size in points
  hjust = NULL,         # Horizontal justification (0-1)
  vjust = NULL,         # Vertical justification (0-1)
  angle = NULL,         # Rotation in degrees
  lineheight = NULL,    # Line spacing
  margin = NULL,        # Margin around text (margin())
  debug = FALSE         # Show bounding box
)
```

---

#### element_line()

Customize line elements (gridlines, axes, ticks).

```r
element_line(
  colour = NULL,        # Line color
  linewidth = NULL,     # Line width (formerly size)
  linetype = NULL,      # Line type (1-6 or named)
  lineend = NULL,       # Line end: "round", "butt", "square"
  arrow = NULL          # Arrow specification (arrow())
)
```

---

#### element_rect()

Customize rectangle elements (backgrounds, borders).

```r
element_rect(
  fill = NULL,          # Fill color
  colour = NULL,        # Border color
  linewidth = NULL,     # Border width
  linetype = NULL,      # Border line type
  inherit.blank = FALSE # Inherit blank elements?
)
```

---

#### element_blank()

Remove elements entirely.

```r
theme(
  panel.grid.minor = element_blank(),  # Remove minor gridlines
  axis.ticks = element_blank()         # Remove axis ticks
)
```

---

### Theme Components

#### Plot-Level Elements

```r
theme(
  # Main title
  plot.title = element_text(
    size = 14,
    face = "bold",
    hjust = 0,           # Left-aligned
    margin = margin(b = 10)
  ),

  # Subtitle
  plot.subtitle = element_text(
    size = 12,
    colour = "grey50",
    margin = margin(b = 10)
  ),

  # Caption (bottom-right)
  plot.caption = element_text(
    size = 9,
    colour = "grey50",
    hjust = 1            # Right-aligned
  ),

  # Tag (top-left label, e.g., "A")
  plot.tag = element_text(
    size = 12,
    face = "bold"
  ),

  # Plot background
  plot.background = element_rect(
    fill = "white",
    colour = NA
  ),

  # Margin around entire plot
  plot.margin = margin(10, 10, 10, 10)  # top, right, bottom, left
)
```

---

#### Panel Elements

```r
theme(
  # Panel background (plot area)
  panel.background = element_rect(
    fill = "white",
    colour = NA
  ),

  # Panel border
  panel.border = element_rect(
    fill = NA,
    colour = "black",
    linewidth = 0.5
  ),

  # Major gridlines
  panel.grid.major = element_line(
    colour = "grey90",
    linewidth = 0.5
  ),

  # Minor gridlines
  panel.grid.minor = element_line(
    colour = "grey95",
    linewidth = 0.25
  ),

  # Specific axis gridlines
  panel.grid.major.x = element_line(colour = "grey90"),
  panel.grid.major.y = element_line(colour = "grey90"),
  panel.grid.minor.x = element_blank(),
  panel.grid.minor.y = element_blank(),

  # Spacing between facet panels
  panel.spacing = unit(0.5, "lines"),  # or panel.spacing.x, panel.spacing.y
  panel.spacing.x = unit(1, "cm"),
  panel.spacing.y = unit(0.5, "cm")
)
```

---

#### Axis Elements

```r
theme(
  # Axis titles
  axis.title = element_text(size = 12, face = "bold"),
  axis.title.x = element_text(margin = margin(t = 10)),
  axis.title.y = element_text(margin = margin(r = 10), angle = 90),

  # Axis text (tick labels)
  axis.text = element_text(size = 10, colour = "black"),
  axis.text.x = element_text(angle = 45, hjust = 1),
  axis.text.y = element_text(),

  # Axis ticks
  axis.ticks = element_line(colour = "black", linewidth = 0.5),
  axis.ticks.x = element_line(),
  axis.ticks.y = element_line(),

  # Axis tick length
  axis.ticks.length = unit(0.25, "cm"),

  # Axis lines
  axis.line = element_line(colour = "black", linewidth = 0.5),
  axis.line.x = element_line(),
  axis.line.y = element_line()
)
```

---

#### Legend Elements

```r
theme(
  # Legend position: "right", "left", "top", "bottom", "none", or c(x, y)
  legend.position = "right",

  # Legend justification when using c(x, y) position
  legend.justification = c(1, 1),  # Anchor point

  # Legend direction: "horizontal" or "vertical"
  legend.direction = "vertical",

  # Legend box arrangement: "horizontal" or "vertical"
  legend.box = "vertical",

  # Spacing between multiple legends
  legend.box.spacing = unit(0.5, "cm"),

  # Legend title
  legend.title = element_text(size = 11, face = "bold"),

  # Legend text
  legend.text = element_text(size = 10),

  # Legend background
  legend.background = element_rect(
    fill = "white",
    colour = "black",
    linewidth = 0.5
  ),

  # Legend key (individual legend items)
  legend.key = element_rect(fill = "white", colour = NA),
  legend.key.size = unit(1, "lines"),
  legend.key.height = unit(1, "lines"),
  legend.key.width = unit(1, "lines"),

  # Spacing between legend items
  legend.spacing = unit(0.5, "lines"),
  legend.spacing.x = unit(0.5, "lines"),
  legend.spacing.y = unit(0.5, "lines"),

  # Legend margins
  legend.margin = margin(5, 5, 5, 5),

  # Legend box margin
  legend.box.margin = margin(0, 0, 0, 0)
)
```

---

#### Facet (Strip) Elements

```r
theme(
  # Strip text (facet labels)
  strip.text = element_text(size = 11, face = "bold", colour = "black"),
  strip.text.x = element_text(margin = margin(5, 0, 5, 0)),
  strip.text.y = element_text(margin = margin(0, 5, 0, 5), angle = -90),

  # Strip background
  strip.background = element_rect(
    fill = "grey80",
    colour = "black",
    linewidth = 0.5
  ),

  # Individual axis strip backgrounds
  strip.background.x = element_rect(fill = "grey80"),
  strip.background.y = element_rect(fill = "grey90"),

  # Strip placement: "inside" or "outside"
  strip.placement = "inside",

  # Switch strip position
  strip.switch.pad.grid = unit(0.5, "cm"),
  strip.switch.pad.wrap = unit(0.5, "cm")
)
```

---

### Theme Inheritance

Theme elements cascade hierarchically:

```
text
├── plot.title
├── plot.subtitle
├── plot.caption
├── axis.title
│   ├── axis.title.x
│   └── axis.title.y
├── axis.text
│   ├── axis.text.x
│   └── axis.text.y
├── legend.title
├── legend.text
├── strip.text
│   ├── strip.text.x
│   └── strip.text.y
```

**Example**: Setting `text = element_text(family = "serif")` affects all text elements.

---

### Complete Theme Customization Example

```r
ggplot(data, aes(x, y, colour = group)) +
  geom_point(size = 3) +
  theme_minimal() +
  theme(
    # Plot titles
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, colour = "grey50"),
    plot.caption = element_text(size = 9, hjust = 1, colour = "grey50"),

    # Panel
    panel.grid.minor = element_blank(),
    panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.5),

    # Axes
    axis.title = element_text(size = 12, face = "bold"),
    axis.text = element_text(size = 10),

    # Legend
    legend.position = c(0.95, 0.95),
    legend.justification = c(1, 1),
    legend.background = element_rect(fill = "white", colour = "black"),
    legend.title = element_text(face = "bold"),

    # Margins
    plot.margin = margin(20, 20, 20, 20)
  )
```

---

## Color Scales

### Viridis Scales (Recommended)

Perceptually uniform, colorblind-safe, prints well in greyscale.

#### Continuous

```r
scale_colour_viridis_c(
  option = "viridis",  # or "A" through "H", see below
  begin = 0,           # Start of color range (0-1)
  end = 1,             # End of color range (0-1)
  direction = 1,       # 1 (default) or -1 (reverse)
  alpha = 1,           # Transparency
  guide = "colourbar"  # Legend type
)

scale_fill_viridis_c(...)  # Same parameters for fill
```

**Options**:
- **"viridis"** (D): Purple to yellow (default, general purpose)
- **"magma"** (A): Black to white through purple/red
- **"inferno"** (B): Black to yellow through dark red
- **"plasma"** (C): Purple to yellow through pink
- **"cividis"** (E): Blue to yellow, optimized for color vision deficiency
- **"rocket"** (F): Black to red to cream
- **"mako"** (G): Black to teal to cream
- **"turbo"** (H): Rainbow alternative (use sparingly)

#### Discrete

```r
scale_colour_viridis_d(option = "viridis", begin = 0, end = 0.9, direction = 1)
scale_fill_viridis_d(...)
```

#### Binned

```r
scale_colour_viridis_b(option = "viridis", bins = 6)
scale_fill_viridis_b(...)
```

**Examples**:
```r
# Continuous with plasma palette
ggplot(data, aes(x, y, colour = value)) +
  geom_point() +
  scale_colour_viridis_c(option = "plasma")

# Discrete with reversed direction
ggplot(data, aes(x, y, fill = category)) +
  geom_col() +
  scale_fill_viridis_d(option = "mako", direction = -1)

# Subset of color range
ggplot(data, aes(x, y, colour = value)) +
  geom_point() +
  scale_colour_viridis_c(begin = 0.2, end = 0.8)
```

---

### ColorBrewer Scales

Designed by Cynthia Brewer for maps. Organized by data type.

#### Sequential (Ordered Data)

Single-hue progressions for ordered data.

**Palettes**: Blues, BuGn, BuPu, GnBu, Greens, Greys, Oranges, OrRd, PuBu, PuBuGn, PuRd, Purples, RdPu, Reds, YlGn, YlGnBu, YlOrBr, YlOrRd

```r
# Discrete
scale_colour_brewer(palette = "Blues", type = "seq", direction = 1)
scale_fill_brewer(palette = "Blues")

# Continuous
scale_colour_distiller(palette = "Blues", direction = 1)
scale_fill_distiller(palette = "Blues")

# Binned
scale_colour_fermenter(palette = "Blues", direction = 1)
scale_fill_fermenter(palette = "Blues")
```

#### Diverging (Data with Meaningful Midpoint)

Two-hue divergence for data with neutral midpoint (e.g., correlation, change).

**Palettes**: BrBG, PiYG, PRGn, PuOr, RdBu, RdGy, RdYlBu, RdYlGn, Spectral

```r
scale_colour_brewer(palette = "RdBu", type = "div")
scale_fill_distiller(palette = "RdYlBu", type = "div")
```

#### Qualitative (Categorical Data)

Distinct colors for unordered categories.

**Palettes**: Accent, Dark2, Paired, Pastel1, Pastel2, Set1, Set2, Set3

```r
scale_colour_brewer(palette = "Set1", type = "qual")
scale_fill_brewer(palette = "Dark2")
```

**Examples**:
```r
# Sequential for ordered categories
ggplot(data, aes(x, y, fill = income_bracket)) +
  geom_col() +
  scale_fill_brewer(palette = "YlOrRd", type = "seq")

# Diverging for correlation heatmap
ggplot(corr_data, aes(var1, var2, fill = correlation)) +
  geom_tile() +
  scale_fill_distiller(palette = "RdBu", type = "div", limits = c(-1, 1))

# Qualitative for categories
ggplot(data, aes(x, y, colour = species)) +
  geom_point() +
  scale_colour_brewer(palette = "Set1")
```

---

### Gradient Scales

#### Two-Color Gradient

```r
scale_colour_gradient(
  low = "#132B43",      # Color for low values
  high = "#56B1F7",     # Color for high values
  space = "Lab",        # Color space: "Lab" (default) or "rgb"
  na.value = "grey50",  # Color for NA values
  guide = "colourbar",  # Legend type
  limits = NULL,        # Data range
  breaks = waiver(),    # Legend breaks
  labels = waiver()     # Legend labels
)

scale_fill_gradient(...)
```

#### Three-Color Diverging

```r
scale_colour_gradient2(
  low = "blue",         # Color for low values
  mid = "white",        # Color for midpoint
  high = "red",         # Color for high values
  midpoint = 0,         # Data value for midpoint color
  space = "Lab",
  na.value = "grey50",
  guide = "colourbar"
)

scale_fill_gradient2(...)
```

#### N-Color Custom

```r
scale_colour_gradientn(
  colours = c("blue", "cyan", "yellow", "red"),  # Color vector
  values = NULL,        # Optional rescaled positions (0-1)
  space = "Lab",
  na.value = "grey50",
  guide = "colourbar"
)

scale_fill_gradientn(...)
```

**Examples**:
```r
# Two-color gradient
ggplot(data, aes(x, y, colour = temperature)) +
  geom_point() +
  scale_colour_gradient(low = "white", high = "red")

# Diverging around zero
ggplot(data, aes(x, y, fill = change)) +
  geom_tile() +
  scale_fill_gradient2(
    low = "blue",
    mid = "white",
    high = "red",
    midpoint = 0
  )

# Custom multi-color
ggplot(data, aes(x, y, colour = elevation)) +
  geom_point() +
  scale_colour_gradientn(
    colours = c("darkblue", "cyan", "yellow", "red"),
    values = c(0, 0.3, 0.7, 1)
  )
```

---

### Manual Scales

Specify exact colors for each level.

```r
scale_colour_manual(
  values = c(
    "Group A" = "#E41A1C",
    "Group B" = "#377EB8",
    "Group C" = "#4DAF4A"
  ),
  breaks = c("Group A", "Group B", "Group C"),  # Legend order
  labels = c("Group A", "Group B", "Group C"),  # Legend labels
  na.value = "grey50"                            # Color for NA
)

scale_fill_manual(values = ...)
```

**Example**:
```r
# Named colors
ggplot(data, aes(x, y, colour = status)) +
  geom_point(size = 3) +
  scale_colour_manual(
    values = c(
      "Active" = "green",
      "Inactive" = "red",
      "Pending" = "orange"
    )
  )

# Hex colors
ggplot(data, aes(category, value, fill = category)) +
  geom_col() +
  scale_fill_manual(
    values = c("#1B9E77", "#D95F02", "#7570B3", "#E7298A")
  )
```

---

### Other Scales

#### Greyscale

```r
scale_colour_grey(start = 0.2, end = 0.8)
scale_fill_grey(start = 0, end = 0.7)
```

#### Hue-based (Default)

```r
scale_colour_hue(h = c(0, 360), c = 100, l = 65)
scale_fill_hue(...)
```

#### Identity (Use Data Values as Colors)

```r
scale_colour_identity(guide = "legend")  # Include legend
scale_fill_identity()
```

---

## Scale Customization

### Common Scale Parameters

All scales accept these parameters:

```r
scale_*_*(
  name = waiver(),       # Legend/axis title (or use labs())
  breaks = waiver(),     # Tick/legend positions
  labels = waiver(),     # Tick/legend labels
  limits = NULL,         # Data range (discards out-of-range data!)
  expand = waiver(),     # Padding around data
  na.value = "grey50",   # How to display NA values
  guide = "legend"       # Legend type: "legend", "colourbar", "none"
)
```

### Custom Breaks and Labels

```r
# Manual breaks
scale_x_continuous(breaks = c(0, 25, 50, 75, 100))

# Custom labels
scale_x_continuous(
  breaks = c(0, 25, 50, 75, 100),
  labels = c("None", "Low", "Med", "High", "Max")
)

# Function for labels
scale_y_continuous(labels = scales::percent_format())
scale_y_continuous(labels = scales::dollar_format())
scale_y_continuous(labels = scales::comma_format())

# Remove labels (keep breaks)
scale_x_continuous(labels = NULL)
```

### Limits

**Warning**: Setting limits **removes data** outside range before calculations!

```r
# Remove data outside range
scale_x_continuous(limits = c(0, 100))

# Better: Use coord_cartesian for visual zoom (preserves data)
coord_cartesian(xlim = c(0, 100))
```

### Transformations

```r
# Log scale
scale_x_log10()
scale_y_log10(breaks = c(1, 10, 100, 1000))

# Square root
scale_x_sqrt()

# Reverse
scale_x_reverse()
scale_y_reverse()

# Custom transformation
scale_x_continuous(trans = "log10")
scale_x_continuous(trans = scales::boxcox_trans(0.5))
```

### Expansion

Control padding around data:

```r
# Default: add 5% on continuous scales
scale_x_continuous(expand = expansion(mult = 0.05))

# No expansion
scale_x_continuous(expand = c(0, 0))

# Different expansion for each side
scale_x_continuous(expand = expansion(mult = c(0, 0.1)))  # None at low, 10% at high

# Additive expansion (fixed units)
scale_y_continuous(expand = expansion(add = c(0, 2)))
```

---

## Best Practices

### Color Selection

**Accessibility First**:
1. Use colorblind-safe palettes (Viridis, specific ColorBrewer)
2. Provide redundant encodings (shape + color, or size + color)
3. Test with color blindness simulators
4. Ensure sufficient contrast

**By Data Type**:
- **Continuous**: Viridis, sequential ColorBrewer
- **Diverging**: Gradient2 or diverging ColorBrewer (with meaningful midpoint)
- **Categorical (<6)**: Set1, Dark2, or manual
- **Categorical (>6)**: Consider faceting instead

**Avoid**:
- Rainbow palette (not perceptually uniform)
- Red-green combinations (colorblind issues)
- Too many colors (>7-8 becomes indistinguishable)

### Theme Strategy

```r
# 1. Start with complete theme
theme_minimal() +

# 2. Layer customizations
theme(
  # Customize only what you need
  plot.title = element_text(size = 14, face = "bold"),
  panel.grid.minor = element_blank()
)
```

### Global Theme Settings

```r
# Set default theme for session
theme_set(theme_minimal())

# Update current theme
theme_update(
  plot.title = element_text(size = 14, face = "bold")
)

# Save custom theme
my_theme <- function() {
  theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      panel.grid.minor = element_blank()
    )
}

# Use across plots
ggplot(data, aes(x, y)) +
  geom_point() +
  my_theme()
```

### Export Settings

```r
# Vector formats for publications (scalable)
ggsave("plot.pdf", width = 8, height = 6)
ggsave("plot.svg", width = 8, height = 6)

# Raster for presentations (set high DPI)
ggsave("plot.png", width = 8, height = 6, dpi = 300)

# Control text sizing
ggsave("plot.pdf", width = 8, height = 6, device = cairo_pdf)  # Better text rendering
```

---

**See [../examples/plot-examples.md](../examples/plot-examples.md) for complete themed plot examples.**
