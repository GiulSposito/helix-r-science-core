# Layout and Styling Reference for R Plotly

Complete guide to layout configuration, styling, theming, colors, fonts, and visual customization in plotly for R.

## Table of Contents

1. [Layout Structure](#layout-structure)
2. [Axes Configuration](#axes-configuration)
3. [Legends](#legends)
4. [Annotations](#annotations)
5. [Themes and Templates](#themes-and-templates)
6. [Colors and Palettes](#colors-and-palettes)
7. [Fonts and Typography](#fonts-and-typography)
8. [Advanced Layout](#advanced-layout)

---

## Layout Structure

The `layout()` function controls all non-data visual elements of a plotly figure. It accepts a list of parameters that define titles, axes, legends, margins, backgrounds, and more.

### Complete Function Signature

```r
plot |> layout(
  # Titles
  title = NULL,           # Main title (string or list)

  # Axes
  xaxis = list(),         # X-axis configuration
  yaxis = list(),         # Y-axis configuration

  # Legend
  legend = list(),        # Legend configuration
  showlegend = TRUE,      # Show/hide legend

  # Sizing and margins
  width = NULL,           # Plot width in pixels
  height = NULL,          # Plot height in pixels
  margin = list(),        # Margins (l, r, t, b, pad)
  autosize = TRUE,        # Auto-resize to container

  # Backgrounds
  paper_bgcolor = "white",  # Outer background
  plot_bgcolor = "white",   # Inner plot area background

  # Interactivity
  hovermode = "closest",    # Hover behavior
  dragmode = "zoom",        # Drag behavior

  # Annotations and shapes
  annotations = list(),     # Text annotations
  shapes = list(),          # Lines, rectangles, circles

  # Templates and themes
  template = NULL,          # Built-in theme name

  # Font defaults
  font = list()             # Default font settings
)
```

### Plot Title Configuration

Simple string title:

```r
plot_ly(mtcars, x = ~wt, y = ~mpg) |>
  layout(title = "Fuel Efficiency vs Weight")
```

Advanced title with styling:

```r
plot_ly(mtcars, x = ~wt, y = ~mpg) |>
  layout(
    title = list(
      text = "Fuel Efficiency vs Weight<br><sub>Data from 1974 Motor Trend</sub>",
      font = list(size = 20, color = "#333333", family = "Arial Black"),
      x = 0.5,              # Horizontal position (0-1, 0=left, 1=right)
      xanchor = "center",   # Anchor point: "left", "center", "right"
      y = 0.95,             # Vertical position (0-1)
      yanchor = "top",      # Anchor point: "top", "middle", "bottom"
      pad = list(t = 20, b = 10)  # Padding
    )
  )
```

Axis titles:

```r
plot_ly(mtcars, x = ~wt, y = ~mpg) |>
  layout(
    xaxis = list(title = "Weight (1000 lbs)"),
    yaxis = list(title = "Miles per Gallon")
  )
```

### Margin Control

Margins define the space between the plot area and the paper (outer container).

```r
plot_ly(mtcars, x = ~wt, y = ~mpg) |>
  layout(
    margin = list(
      l = 80,    # Left margin (pixels)
      r = 50,    # Right margin
      t = 100,   # Top margin
      b = 80,    # Bottom margin
      pad = 10   # Padding between plot area and axes
    )
  )
```

**Auto-margin** (automatically calculate margins to fit labels):

```r
layout(
  xaxis = list(automargin = TRUE),
  yaxis = list(automargin = TRUE)
)
```

### Paper vs Plot Sizing

- **paper**: The outer container (includes margins, title, legend)
- **plot**: The inner data visualization area

```r
plot_ly(mtcars, x = ~wt, y = ~mpg) |>
  layout(
    width = 800,           # Total paper width
    height = 600,          # Total paper height
    autosize = FALSE,      # Fixed size (don't auto-resize)

    # Control plot area size via margins
    margin = list(l = 100, r = 100, t = 100, b = 100)
  )
```

Responsive sizing (auto-fit to container):

```r
plot_ly(mtcars, x = ~wt, y = ~mpg) |>
  layout(autosize = TRUE) |>
  config(responsive = TRUE)
```

### Background Colors

```r
plot_ly(mtcars, x = ~wt, y = ~mpg) |>
  layout(
    paper_bgcolor = "#f5f5f5",     # Outer background (margins, title area)
    plot_bgcolor = "white"         # Inner plot area background
  )
```

**Transparent backgrounds** (for embedding in web pages):

```r
layout(
  paper_bgcolor = "rgba(0,0,0,0)",  # Fully transparent
  plot_bgcolor = "rgba(0,0,0,0)"
)
```

---

## Axes Configuration

Axes are configured via `xaxis`, `yaxis`, and `zaxis` (for 3D plots) parameters in `layout()`. Each accepts a list of properties.

### Basic Axis Structure

```r
layout(
  xaxis = list(
    title = "X Axis Label",
    range = c(0, 10),
    showgrid = TRUE,
    zeroline = TRUE
  ),
  yaxis = list(
    title = "Y Axis Label",
    range = c(0, 100),
    showgrid = TRUE,
    zeroline = TRUE
  )
)
```

### Range Control

**Fixed range:**

```r
layout(
  xaxis = list(range = c(0, 10)),
  yaxis = list(range = c(-5, 5))
)
```

**Auto-range with padding:**

```r
layout(
  xaxis = list(
    autorange = TRUE,      # Auto-calculate range from data
    rangemode = "tozero"   # Ensure range includes zero
  )
)
```

**Range modes:**
- `"normal"`: Fit to data (default)
- `"tozero"`: Extend range to include zero
- `"nonnegative"`: Range starts at zero

**Constrain range** (prevent zooming beyond limits):

```r
layout(
  xaxis = list(
    range = c(0, 100),
    fixedrange = TRUE    # Disable zoom/pan on this axis
  )
)
```

### Scale Types

**Linear scale** (default):

```r
layout(xaxis = list(type = "linear"))
```

**Logarithmic scale:**

```r
layout(
  yaxis = list(
    type = "log",
    dtick = 1            # Log10 spacing (1 = powers of 10)
  )
)
```

**Date/time scale:**

```r
plot_ly(data, x = ~date_column, y = ~value) |>
  layout(
    xaxis = list(
      type = "date",
      tickformat = "%b %Y",    # Format: Jan 2023
      dtick = "M3"             # Tick every 3 months
    )
  )
```

**Categorical scale:**

```r
layout(
  xaxis = list(
    type = "category",
    categoryorder = "total descending"  # Order by total values
  )
)
```

Category ordering options:
- `"trace"`: Order as they appear in data
- `"category ascending"`: Alphabetical
- `"category descending"`: Reverse alphabetical
- `"total ascending"`: By sum of values
- `"total descending"`: By sum descending
- `"array"`: Custom order via `categoryarray`

**Multi-category scale** (hierarchical categories):

```r
data <- data.frame(
  category1 = c("A", "A", "B", "B"),
  category2 = c("X", "Y", "X", "Y"),
  value = c(10, 20, 30, 40)
)

plot_ly(data, x = ~list(category1, category2), y = ~value, type = "bar") |>
  layout(xaxis = list(type = "multicategory"))
```

### Ticks Configuration

**Tick modes:**

```r
# Automatic ticks
layout(xaxis = list(tickmode = "auto"))

# Linear spacing
layout(xaxis = list(
  tickmode = "linear",
  tick0 = 0,        # Starting tick value
  dtick = 5         # Tick spacing
))

# Explicit tick positions
layout(xaxis = list(
  tickmode = "array",
  tickvals = c(0, 2, 5, 10, 20),           # Positions
  ticktext = c("Zero", "Two", "Five", "Ten", "Twenty")  # Labels
))
```

**Tick formatting:**

```r
# Number formatting
layout(
  yaxis = list(
    tickformat = ".2f",      # 2 decimal places
    tickprefix = "$",        # Prefix
    ticksuffix = " USD"      # Suffix
  )
)
```

Common tick formats:
- `".0f"`: Integer (no decimals)
- `".2f"`: 2 decimal places
- `".1%"`: Percentage with 1 decimal
- `".2e"`: Scientific notation
- `"%b %Y"`: Date format (Jan 2023)

**Tick angles and positioning:**

```r
layout(
  xaxis = list(
    tickangle = -45,           # Rotate labels
    tickfont = list(size = 10),
    side = "bottom",           # Position: "top" or "bottom"
    ticks = "outside",         # Tick marks: "outside", "inside", ""
    ticklen = 5,               # Tick length in pixels
    tickwidth = 2,             # Tick width
    tickcolor = "#333333"      # Tick color
  )
)
```

**Date axis special formatting:**

```r
plot_ly(data, x = ~date_var, y = ~value) |>
  layout(
    xaxis = list(
      type = "date",
      tickformat = "%Y-%m-%d",
      dtick = 86400000 * 7,     # 7 days in milliseconds
      tickangle = -45,
      tickmode = "auto",
      nticks = 10               # Target number of ticks
    )
  )
```

Date format codes:
- `%Y`: 4-digit year (2023)
- `%y`: 2-digit year (23)
- `%m`: Month number (01-12)
- `%b`: Month abbreviation (Jan)
- `%B`: Full month name (January)
- `%d`: Day of month (01-31)
- `%H`: Hour (00-23)
- `%M`: Minute (00-59)
- `%S`: Second (00-59)

### Grid Lines

```r
layout(
  xaxis = list(
    showgrid = TRUE,
    gridcolor = "lightgray",
    gridwidth = 1,
    griddash = "solid"      # Options: "solid", "dot", "dash", "longdash", "dashdot"
  ),
  yaxis = list(
    showgrid = TRUE,
    gridcolor = "#e0e0e0",
    gridwidth = 0.5,
    griddash = "dot"
  )
)
```

**Minor grid lines:**

```r
layout(
  xaxis = list(
    showgrid = TRUE,
    minor = list(
      showgrid = TRUE,
      gridcolor = "#f0f0f0",
      griddash = "dot"
    )
  )
)
```

### Zero Lines

Special styling for the zero line (if within range):

```r
layout(
  xaxis = list(
    zeroline = TRUE,
    zerolinecolor = "#666666",
    zerolinewidth = 2
  ),
  yaxis = list(
    zeroline = TRUE,
    zerolinecolor = "black",
    zerolinewidth = 1
  )
)
```

### Multiple Axes

**Secondary Y-axis:**

```r
plot_ly() |>
  add_trace(x = ~x, y = ~y1, name = "Series 1", yaxis = "y1") |>
  add_trace(x = ~x, y = ~y2, name = "Series 2", yaxis = "y2") |>
  layout(
    yaxis = list(title = "Primary Y-axis"),
    yaxis2 = list(
      title = "Secondary Y-axis",
      overlaying = "y",       # Overlay on top of y-axis
      side = "right"          # Position on right
    )
  )
```

**Secondary X-axis:**

```r
plot_ly() |>
  add_trace(x = ~x1, y = ~y, name = "Series 1", xaxis = "x1") |>
  add_trace(x = ~x2, y = ~y, name = "Series 2", xaxis = "x2") |>
  layout(
    xaxis = list(title = "Primary X-axis"),
    xaxis2 = list(
      title = "Secondary X-axis",
      overlaying = "x",
      side = "top",
      anchor = "free",         # Not anchored to y-axis
      position = 0.95          # Position (0-1)
    )
  )
```

**Multiple independent axes:**

```r
plot_ly() |>
  add_trace(x = ~x, y = ~y1, yaxis = "y1") |>
  add_trace(x = ~x, y = ~y2, yaxis = "y2") |>
  add_trace(x = ~x, y = ~y3, yaxis = "y3") |>
  layout(
    yaxis = list(domain = c(0, 0.3)),       # Bottom 30%
    yaxis2 = list(domain = c(0.35, 0.65)),  # Middle 30%
    yaxis3 = list(domain = c(0.7, 1))       # Top 30%
  )
```

### Complete Axis Example

```r
plot_ly(economics, x = ~date, y = ~unemploy / 1000) |>
  layout(
    xaxis = list(
      title = list(text = "Year", font = list(size = 14, color = "#333")),
      type = "date",
      tickformat = "%Y",
      dtick = "M24",          # Tick every 24 months
      showgrid = TRUE,
      gridcolor = "#e0e0e0",
      gridwidth = 0.5,
      zeroline = FALSE,
      tickangle = 0,
      automargin = TRUE
    ),
    yaxis = list(
      title = list(text = "Unemployment (thousands)", font = list(size = 14)),
      tickformat = ".0f",
      ticksuffix = "k",
      showgrid = TRUE,
      gridcolor = "#e0e0e0",
      zeroline = TRUE,
      zerolinecolor = "#999",
      zerolinewidth = 1
    )
  )
```

---

## Legends

Legends identify traces and enable interactive show/hide behavior.

### Position and Anchoring

```r
layout(
  legend = list(
    x = 1,              # Horizontal position (0-1, or >1 for outside plot)
    y = 1,              # Vertical position (0-1)
    xanchor = "right",  # Anchor point: "left", "center", "right", "auto"
    yanchor = "top"     # Anchor point: "top", "middle", "bottom", "auto"
  )
)
```

**Common legend positions:**

```r
# Top right (inside plot)
legend = list(x = 0.98, y = 0.98, xanchor = "right", yanchor = "top")

# Top left (inside plot)
legend = list(x = 0.02, y = 0.98, xanchor = "left", yanchor = "top")

# Bottom right
legend = list(x = 0.98, y = 0.02, xanchor = "right", yanchor = "bottom")

# Outside plot (right side)
legend = list(x = 1.05, y = 0.5, xanchor = "left", yanchor = "middle")

# Outside plot (below)
legend = list(x = 0.5, y = -0.2, xanchor = "center", yanchor = "top", orientation = "h")
```

### Orientation

```r
# Vertical legend (default)
layout(legend = list(orientation = "v"))

# Horizontal legend
layout(legend = list(orientation = "h"))
```

### Title and Styling

```r
layout(
  legend = list(
    title = list(
      text = "Legend Title",
      font = list(size = 14, color = "#333", family = "Arial")
    ),
    font = list(size = 12, color = "#666"),
    bgcolor = "rgba(255, 255, 255, 0.8)",   # Background color (with transparency)
    bordercolor = "#cccccc",                 # Border color
    borderwidth = 1,                         # Border width

    # Trace group spacing
    tracegroupgap = 10,                      # Space between groups (pixels)
    traceorder = "normal",                   # Order: "normal", "reversed", "grouped"

    # Item appearance
    itemsizing = "constant",                 # "trace" or "constant" (fixed size symbols)
    itemwidth = 30                           # Width of legend symbols
  )
)
```

### Grouping Traces

**Legend groups** allow multiple traces to be toggled together:

```r
plot_ly() |>
  add_trace(x = ~x, y = ~y1, name = "Group A - Line",
            legendgroup = "groupA", showlegend = TRUE) |>
  add_trace(x = ~x, y = ~y1_upper, name = "Group A - Upper",
            legendgroup = "groupA", showlegend = FALSE,  # Hide from legend
            line = list(dash = "dash")) |>
  add_trace(x = ~x, y = ~y2, name = "Group B",
            legendgroup = "groupB", showlegend = TRUE)
```

**Legend titles for groups:**

```r
plot_ly() |>
  add_trace(x = ~x, y = ~y1, name = "Series 1",
            legendgrouptitle = list(text = "Group A")) |>
  add_trace(x = ~x, y = ~y2, name = "Series 2",
            legendgrouptitle = list(text = "Group B"))
```

### Show/Hide Controls

```r
# Hide legend completely
layout(showlegend = FALSE)

# Hide specific trace from legend
add_trace(x = ~x, y = ~y, showlegend = FALSE)

# Control initial visibility
add_trace(x = ~x, y = ~y, visible = TRUE)   # or FALSE, or "legendonly"
```

### Interactive Legend Click Behavior

```r
# Default: Click to toggle trace visibility
# Double-click to isolate trace (hide all others)

# Disable legend interactions
layout(legend = list(itemclick = FALSE, itemdoubleclick = FALSE))

# Toggle only (disable double-click isolate)
layout(legend = list(itemdoubleclick = FALSE))
```

### Multiple Legends

For complex plots with multiple legend groups:

```r
plot_ly() |>
  add_trace(x = ~x, y = ~y1, name = "Series 1",
            legend = "legend1") |>
  add_trace(x = ~x, y = ~y2, name = "Series 2",
            legend = "legend2") |>
  layout(
    legend = list(x = 1.05, y = 1, title = list(text = "Legend 1")),
    legend2 = list(x = 1.05, y = 0.5, title = list(text = "Legend 2"))
  )
```

### Complete Legend Example

```r
plot_ly(iris) |>
  add_trace(x = ~Sepal.Length, y = ~Sepal.Width,
            color = ~Species, type = "scatter", mode = "markers") |>
  layout(
    legend = list(
      title = list(
        text = "Iris Species",
        font = list(size = 14, color = "#333", family = "Arial")
      ),
      x = 0.02,
      y = 0.98,
      xanchor = "left",
      yanchor = "top",
      orientation = "v",
      bgcolor = "rgba(255, 255, 255, 0.8)",
      bordercolor = "#cccccc",
      borderwidth = 1,
      font = list(size = 11),
      itemwidth = 30,
      itemsizing = "constant"
    )
  )
```

---

## Annotations

Annotations add text, arrows, and shapes to plots for highlighting and explanation.

### Text Annotations

**Basic text annotation:**

```r
layout(
  annotations = list(
    list(
      x = 5,                    # X coordinate (data coordinates)
      y = 10,                   # Y coordinate (data coordinates)
      text = "Important Point",
      showarrow = FALSE,
      font = list(size = 12, color = "red")
    )
  )
)
```

**Multiple annotations:**

```r
layout(
  annotations = list(
    list(x = 2, y = 5, text = "Point A", showarrow = FALSE),
    list(x = 8, y = 15, text = "Point B", showarrow = FALSE)
  )
)
```

### Arrow Annotations

**Annotation with arrow pointing to data:**

```r
layout(
  annotations = list(
    list(
      x = 5,                    # Arrow points to this data coordinate
      y = 10,
      text = "Peak Value",
      showarrow = TRUE,
      arrowhead = 2,            # Arrow style (0-8)
      arrowsize = 1,            # Arrow size multiplier
      arrowwidth = 2,           # Arrow line width
      arrowcolor = "#333333",
      ax = 40,                  # Horizontal offset from point (pixels)
      ay = -40,                 # Vertical offset from point (pixels, negative = up)
      bgcolor = "white",
      bordercolor = "#333",
      borderwidth = 1,
      borderpad = 4,
      font = list(size = 12)
    )
  )
)
```

Arrow head styles (0-8):
- `0`: No arrow head
- `1`: Open arrow
- `2`: Filled arrow (default)
- `3-8`: Various other styles

### Positioning Strategies

**Data coordinates** (default):

```r
list(
  x = 5, y = 10,          # Position in data coordinates
  xref = "x", yref = "y"  # Reference coordinate system (default)
)
```

**Paper coordinates** (relative to entire figure, 0-1):

```r
list(
  x = 0.5, y = 0.95,      # Center horizontally, near top
  xref = "paper", yref = "paper",
  text = "Figure Title",
  showarrow = FALSE,
  font = list(size = 16)
)
```

**Axis coordinates** (mix data and paper):

```r
list(
  x = 5, y = 1,           # Data x, paper y
  xref = "x", yref = "paper",
  text = "X = 5",
  showarrow = FALSE
)
```

**Anchoring:**

```r
list(
  x = 0.5, y = 0.95,
  xref = "paper", yref = "paper",
  xanchor = "center",     # Horizontal anchor: "left", "center", "right", "auto"
  yanchor = "top",        # Vertical anchor: "top", "middle", "bottom", "auto"
  text = "Centered Title"
)
```

### Shapes

Shapes add lines, rectangles, and circles to plots.

**Horizontal line (reference line):**

```r
layout(
  shapes = list(
    list(
      type = "line",
      x0 = 0, x1 = 1,         # Line from x0 to x1 (paper coordinates)
      y0 = 50, y1 = 50,       # Horizontal line at y = 50 (data coordinates)
      xref = "paper", yref = "y",
      line = list(color = "red", width = 2, dash = "dash")
    )
  )
)
```

**Vertical line:**

```r
shapes = list(
  list(
    type = "line",
    x0 = 5, x1 = 5,           # Vertical line at x = 5
    y0 = 0, y1 = 1,           # From bottom to top (paper coordinates)
    xref = "x", yref = "paper",
    line = list(color = "blue", width = 2)
  )
)
```

**Rectangle (highlighting region):**

```r
shapes = list(
  list(
    type = "rect",
    x0 = 3, x1 = 7,           # Rectangle from x=3 to x=7
    y0 = 10, y1 = 20,         # Rectangle from y=10 to y=20
    fillcolor = "rgba(255, 0, 0, 0.2)",  # Semi-transparent red
    line = list(color = "red", width = 1),
    layer = "below"           # Draw behind data ("below" or "above")
  )
)
```

**Circle:**

```r
shapes = list(
  list(
    type = "circle",
    xref = "x", yref = "y",
    x0 = 4, x1 = 6,           # Circle bounding box
    y0 = 14, y1 = 16,
    fillcolor = "rgba(0, 0, 255, 0.3)",
    line = list(color = "blue")
  )
)
```

**Abline (diagonal reference line):**

```r
# y = mx + b line
shapes = list(
  list(
    type = "line",
    x0 = 0, x1 = 10,
    y0 = 5, y1 = 15,          # Slope = 1, intercept = 5
    line = list(color = "green", width = 2, dash = "dot")
  )
)
```

### Complete Annotation Example

```r
plot_ly(mtcars, x = ~wt, y = ~mpg, type = "scatter", mode = "markers") |>
  layout(
    # Title annotation
    annotations = list(
      list(
        x = 0.5, y = 1.05,
        xref = "paper", yref = "paper",
        text = "Fuel Efficiency Analysis",
        showarrow = FALSE,
        font = list(size = 18, color = "#333"),
        xanchor = "center"
      ),
      # Point annotation with arrow
      list(
        x = 5.42, y = 10.4,   # Toyota Corolla
        text = "Most Efficient",
        showarrow = TRUE,
        arrowhead = 2,
        arrowcolor = "green",
        ax = 30, ay = -40,
        bgcolor = "rgba(255, 255, 255, 0.9)",
        bordercolor = "green",
        borderwidth = 2
      ),
      # Label without arrow
      list(
        x = 3, y = 20,
        text = "High Efficiency Zone",
        showarrow = FALSE,
        font = list(size = 12, color = "green")
      )
    ),
    # Reference lines and regions
    shapes = list(
      # Horizontal reference line at mpg = 20
      list(
        type = "line",
        x0 = 0, x1 = 1,
        y0 = 20, y1 = 20,
        xref = "paper", yref = "y",
        line = list(color = "red", width = 2, dash = "dash")
      ),
      # Highlight efficient cars region
      list(
        type = "rect",
        x0 = 0, x1 = 1,
        y0 = 20, y1 = 35,
        xref = "paper", yref = "y",
        fillcolor = "rgba(0, 255, 0, 0.1)",
        line = list(width = 0),
        layer = "below"
      )
    )
  )
```

---

## Themes and Templates

Templates provide consistent styling across plots with pre-configured layouts.

### Built-in Themes

Plotly includes several built-in themes:

**Plotly (default):**

```r
layout(template = "plotly")
```

**Plotly White:**

```r
layout(template = "plotly_white")
```

**Plotly Dark:**

```r
layout(template = "plotly_dark")
```

**ggplot2 style:**

```r
layout(template = "ggplot2")
```

**Seaborn style:**

```r
layout(template = "seaborn")
```

**Simple White:**

```r
layout(template = "simple_white")
```

**None (minimal styling):**

```r
layout(template = "none")
```

### Theme Comparison

```r
library(plotly)

data <- data.frame(x = 1:10, y = rnorm(10))

themes <- c("plotly", "plotly_white", "plotly_dark",
            "ggplot2", "seaborn", "simple_white")

lapply(themes, function(theme) {
  plot_ly(data, x = ~x, y = ~y, type = "scatter", mode = "lines+markers") |>
    layout(
      title = paste("Theme:", theme),
      template = theme
    )
})
```

### Custom Template Creation

**Define a custom template:**

```r
my_template <- list(
  layout = list(
    paper_bgcolor = "#f9f9f9",
    plot_bgcolor = "white",
    font = list(family = "Arial", size = 12, color = "#333333"),

    xaxis = list(
      showgrid = TRUE,
      gridcolor = "#e0e0e0",
      gridwidth = 0.5,
      zeroline = TRUE,
      zerolinecolor = "#999999",
      zerolinewidth = 1,
      showline = TRUE,
      linecolor = "#333333",
      linewidth = 1,
      ticks = "outside",
      tickcolor = "#333333"
    ),

    yaxis = list(
      showgrid = TRUE,
      gridcolor = "#e0e0e0",
      gridwidth = 0.5,
      zeroline = TRUE,
      zerolinecolor = "#999999",
      zerolinewidth = 1,
      showline = TRUE,
      linecolor = "#333333",
      linewidth = 1,
      ticks = "outside",
      tickcolor = "#333333"
    ),

    legend = list(
      bgcolor = "rgba(255, 255, 255, 0.8)",
      bordercolor = "#cccccc",
      borderwidth = 1
    ),

    colorway = c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd")
  )
)

# Apply custom template
plot_ly(data, x = ~x, y = ~y) |>
  layout(template = my_template)
```

### Applying Templates

**Per-plot application:**

```r
plot_ly(data, x = ~x, y = ~y) |>
  layout(template = "seaborn")
```

**Global default** (set for session):

```r
options(plotly.template = "seaborn")

# All subsequent plots use seaborn theme
plot_ly(data, x = ~x, y = ~y)
```

**Override template properties:**

```r
plot_ly(data, x = ~x, y = ~y) |>
  layout(
    template = "plotly_dark",
    # Override specific properties
    title = "Custom Title",
    xaxis = list(gridcolor = "yellow")
  )
```

### Template Structure Breakdown

A complete template can define:

```r
template <- list(
  layout = list(
    # Backgrounds
    paper_bgcolor = "#ffffff",
    plot_bgcolor = "#ffffff",

    # Fonts
    font = list(family = "Arial", size = 12, color = "#333"),

    # Axes (applied to all axes)
    xaxis = list(...),
    yaxis = list(...),

    # Legend
    legend = list(...),

    # Color sequence for traces
    colorway = c("#color1", "#color2", ...),

    # Color scales
    colorscale = list(
      sequential = "Viridis",
      diverging = "RdBu"
    ),

    # Hover label
    hoverlabel = list(
      bgcolor = "white",
      font = list(size = 12)
    )
  ),

  # Trace-specific defaults
  data = list(
    scatter = list(
      marker = list(size = 8)
    ),
    bar = list(
      marker = list(line = list(width = 0))
    )
  )
)
```

---

## Colors and Palettes

### Color Specification Methods

**Named colors:**

```r
marker = list(color = "red")
marker = list(color = "steelblue")
```

**Hex colors:**

```r
marker = list(color = "#1f77b4")
```

**RGB:**

```r
marker = list(color = "rgb(31, 119, 180)")
```

**RGBA (with transparency):**

```r
marker = list(color = "rgba(31, 119, 180, 0.5)")  # 50% opacity
```

### Discrete Color Sequences

**Default color sequence:**

```r
plot_ly(data, x = ~x, y = ~y, color = ~group)
```

**Named color scales:**

```r
plot_ly(data, x = ~x, y = ~y, color = ~group, colors = "Set1")
```

**ColorBrewer palettes:**
- Sequential: `"Blues"`, `"Greens"`, `"Greys"`, `"Oranges"`, `"Purples"`, `"Reds"`
- Diverging: `"BrBG"`, `"PiYG"`, `"PRGn"`, `"PuOr"`, `"RdBu"`, `"RdGy"`, `"RdYlBu"`, `"RdYlGn"`
- Qualitative: `"Accent"`, `"Dark2"`, `"Paired"`, `"Pastel1"`, `"Pastel2"`, `"Set1"`, `"Set2"`, `"Set3"`

**Custom color vector:**

```r
custom_colors <- c("#e41a1c", "#377eb8", "#4daf4a", "#984ea3")
plot_ly(data, x = ~x, y = ~y, color = ~group, colors = custom_colors)
```

### Continuous Color Scales (Colorscales)

**For continuous data mapping:**

```r
plot_ly(data, x = ~x, y = ~y, z = ~value,
        color = ~value, type = "scatter", mode = "markers",
        marker = list(
          colorscale = "Viridis",
          showscale = TRUE,        # Show colorbar
          colorbar = list(title = "Value")
        ))
```

**Built-in sequential colorscales:**
- `"Viridis"` (perceptually uniform, colorblind-friendly)
- `"Plasma"`
- `"Inferno"`
- `"Magma"`
- `"Cividis"` (colorblind-optimized)
- `"Blues"`, `"Greens"`, `"Greys"`, `"Reds"`, `"YlOrRd"`, `"YlGnBu"`
- `"Hot"`, `"Jet"`, `"Portland"`, `"Picnic"`, `"Rainbow"`

**Diverging colorscales:**
- `"RdBu"` (Red-Blue)
- `"RdYlBu"` (Red-Yellow-Blue)
- `"RdYlGn"` (Red-Yellow-Green)
- `"Spectral"`
- `"Portland"`

**Cyclical colorscales:**
- `"HSV"`
- `"Phase"`

### Reversing Colorscales

```r
marker = list(
  colorscale = "Viridis",
  reversescale = TRUE
)
```

### Custom Colorscale Definition

Define a custom gradient:

```r
custom_colorscale <- list(
  c(0, "rgb(255, 255, 255)"),     # White at minimum
  c(0.5, "rgb(255, 0, 0)"),       # Red at midpoint
  c(1, "rgb(0, 0, 0)")            # Black at maximum
)

plot_ly(data, x = ~x, y = ~y, z = ~value,
        color = ~value, type = "scatter", mode = "markers",
        marker = list(colorscale = custom_colorscale))
```

### Colorbar Customization

```r
marker = list(
  colorscale = "Viridis",
  showscale = TRUE,
  colorbar = list(
    title = list(
      text = "Value",
      side = "right"           # "top", "bottom", "right"
    ),
    thickness = 20,            # Width in pixels
    len = 0.7,                 # Length (0-1, fraction of plot height)
    x = 1.02,                  # Horizontal position
    y = 0.5,                   # Vertical position
    xanchor = "left",
    yanchor = "middle",
    tickmode = "auto",
    nticks = 5,
    tickformat = ".2f",
    tickprefix = "$",
    ticksuffix = " USD",
    outlinecolor = "#333",
    outlinewidth = 1,
    borderwidth = 0
  )
)
```

### Accessibility - Colorblind-Safe Palettes

**Recommended colorblind-friendly palettes:**

```r
# Viridis (excellent for sequential data)
colors = "Viridis"

# Cividis (optimized for colorblind vision)
marker = list(colorscale = "Cividis")

# ColorBrewer qualitative palettes (colorblind-safe)
colors = "Set2"      # Max 8 colors
colors = "Dark2"     # Max 8 colors

# Custom colorblind-safe palette (from Paul Tol)
cb_palette <- c("#332288", "#88CCEE", "#44AA99", "#117733",
                "#999933", "#DDCC77", "#CC6677", "#882255", "#AA4499")
colors = cb_palette
```

**Test with grayscale conversion:**

```r
# Simulate colorblind vision by converting to grayscale mentally
# Good contrast = distinguishable in grayscale
```

### Complete Color Reference Table

| Name | Type | Use Case | Colorblind Safe |
|------|------|----------|-----------------|
| Viridis | Sequential | Heatmaps, continuous data | ✅ Yes |
| Plasma | Sequential | Intensity maps | ✅ Yes |
| Cividis | Sequential | Scientific visualization | ✅ Yes (optimized) |
| Blues/Greens/Reds | Sequential | Single-hue gradients | ⚠️ Moderate |
| RdBu | Diverging | Positive/negative data | ✅ Yes |
| Set2 | Qualitative | Categorical (≤8 groups) | ✅ Yes |
| Dark2 | Qualitative | Categorical (≤8 groups) | ✅ Yes |
| Jet | Sequential | Legacy (avoid if possible) | ❌ No |
| Rainbow | Sequential | Legacy (avoid if possible) | ❌ No |

### Color Example Gallery

```r
# Sequential continuous data
plot_ly(volcano, type = "heatmap", colorscale = "Viridis") |>
  layout(title = "Volcano Elevation (Viridis)")

# Diverging continuous data
plot_ly(z = matrix(rnorm(100), 10, 10), type = "heatmap",
        colorscale = "RdBu", zmid = 0)

# Discrete categorical data
plot_ly(iris, x = ~Sepal.Length, y = ~Sepal.Width,
        color = ~Species, colors = "Set2")

# Custom colorblind-safe palette
custom_cb <- c("#0173B2", "#DE8F05", "#029E73")
plot_ly(iris, x = ~Sepal.Length, y = ~Sepal.Width,
        color = ~Species, colors = custom_cb)
```

---

## Fonts and Typography

### Font Specification

**Global font (applied to all text):**

```r
layout(
  font = list(
    family = "Arial",
    size = 12,
    color = "#333333"
  )
)
```

**Title font:**

```r
layout(
  title = list(
    text = "Plot Title",
    font = list(
      family = "Arial Black",
      size = 18,
      color = "#000000"
    )
  )
)
```

**Axis title fonts:**

```r
layout(
  xaxis = list(
    title = list(
      text = "X Axis",
      font = list(family = "Georgia", size = 14, color = "#333")
    ),
    tickfont = list(family = "Arial", size = 10, color = "#666")
  )
)
```

**Legend font:**

```r
layout(
  legend = list(
    title = list(
      text = "Legend",
      font = list(family = "Arial", size = 12)
    ),
    font = list(family = "Arial", size = 10)
  )
)
```

**Annotation fonts:**

```r
layout(
  annotations = list(
    list(
      x = 5, y = 10,
      text = "Important",
      font = list(family = "Courier New", size = 14, color = "red")
    )
  )
)
```

### Web-Safe Fonts

Fonts guaranteed to work across browsers:

- **Sans-serif**: `"Arial"`, `"Helvetica"`, `"Verdana"`, `"Tahoma"`, `"Trebuchet MS"`
- **Serif**: `"Times New Roman"`, `"Georgia"`, `"Palatino"`
- **Monospace**: `"Courier New"`, `"Courier"`, `"Monaco"`

**Font family fallbacks:**

```r
font = list(family = "Arial, Helvetica, sans-serif")
```

### Google Fonts Integration

Load Google Fonts in your HTML/Shiny app:

```html
<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
```

Then reference in plotly:

```r
layout(font = list(family = "Roboto"))
```

### Math Symbols and Special Characters

**HTML entities:**

```r
title = "Temperature (°C)"
title = "α = 0.05 significance level"
title = "X² test statistic"
```

**LaTeX-style math** (limited support):

```r
# Subscripts and superscripts
title = "R<sup>2</sup> = 0.95"
title = "H<sub>0</sub>: μ = 0"

# Greek letters (HTML entities)
title = "θ (theta) parameter"
```

**Common HTML entities:**
- Degrees: `&deg;` or `°`
- Plus-minus: `&plusmn;` or `±`
- Multiplication: `&times;` or `×`
- Division: `&divide;` or `÷`
- Alpha: `&alpha;` or `α`
- Beta: `&beta;` or `β`
- Theta: `&theta;` or `θ`
- Mu: `&mu;` or `μ`

### Complete Typography Example

```r
plot_ly(mtcars, x = ~wt, y = ~mpg, type = "scatter", mode = "markers") |>
  layout(
    # Global font
    font = list(family = "Arial, sans-serif", size = 11, color = "#333"),

    # Title with custom font
    title = list(
      text = "Fuel Efficiency Analysis<br><sub>1974 Motor Trend Data</sub>",
      font = list(
        family = "Georgia, serif",
        size = 18,
        color = "#000000"
      )
    ),

    # X-axis fonts
    xaxis = list(
      title = list(
        text = "Weight (1000 lbs)",
        font = list(family = "Arial", size = 13, color = "#333")
      ),
      tickfont = list(size = 10, color = "#666")
    ),

    # Y-axis fonts
    yaxis = list(
      title = list(
        text = "Miles per Gallon",
        font = list(family = "Arial", size = 13, color = "#333")
      ),
      tickfont = list(size = 10, color = "#666")
    ),

    # Legend font
    legend = list(
      title = list(
        text = "Cylinders",
        font = list(family = "Arial", size = 12, color = "#333")
      ),
      font = list(size = 10, color = "#666")
    ),

    # Annotation with monospace font
    annotations = list(
      list(
        x = 0.02, y = 0.98,
        xref = "paper", yref = "paper",
        text = "R<sup>2</sup> = 0.75",
        showarrow = FALSE,
        font = list(family = "Courier New, monospace", size = 11),
        xanchor = "left",
        yanchor = "top"
      )
    )
  )
```

---

## Advanced Layout

### Paper vs Plot Coordinate Systems

Understanding coordinate systems is crucial for precise positioning.

**Data coordinates** (default for traces):
- Maps to actual data values on x, y axes
- Example: `x = 5, y = 10` means data point at (5, 10)

**Paper coordinates** (0 to 1):
- Relative to entire figure (including margins)
- `(0, 0)` = bottom-left corner of figure
- `(1, 1)` = top-right corner of figure
- Example: `x = 0.5, y = 0.5` means center of figure

**Axis coordinates** (0 to 1):
- Relative to specific axis domain
- Example: `xref = "x domain"` means 0 = left edge of x-axis, 1 = right edge

**Mixing coordinate systems:**

```r
# Annotation at fixed paper position with arrow pointing to data
annotations = list(
  list(
    x = 5, y = 10,              # Arrow points to data coordinates
    xref = "x", yref = "y",
    ax = 0.1, ay = 0.9,         # Text at paper coordinates
    axref = "paper", ayref = "paper",
    text = "Important Point",
    showarrow = TRUE
  )
)
```

### Aspect Ratio Control

**Fixed aspect ratio:**

```r
layout(
  xaxis = list(
    scaleanchor = "y",    # Lock x-axis scale to y-axis
    scaleratio = 1        # 1:1 aspect ratio (square)
  )
)
```

**Square plots:**

```r
layout(
  xaxis = list(scaleanchor = "y"),
  yaxis = list(scaleanchor = "x")
)
```

**Geographic data (equal aspect):**

```r
plot_ly(data, x = ~longitude, y = ~latitude) |>
  layout(
    xaxis = list(scaleanchor = "y", scaleratio = 1),
    yaxis = list(constrain = "domain")
  )
```

### Responsive Sizing

**Auto-resize to container:**

```r
plot_ly(data, x = ~x, y = ~y) |>
  layout(autosize = TRUE) |>
  config(responsive = TRUE)
```

**Constrain plot to container:**

```r
layout(
  autosize = TRUE,
  xaxis = list(automargin = TRUE),
  yaxis = list(automargin = TRUE)
)
```

**Fixed aspect ratio with responsive width:**

```r
layout(
  autosize = TRUE,
  xaxis = list(
    scaleanchor = "y",
    scaleratio = 1,
    constrain = "domain"
  ),
  yaxis = list(constrain = "domain")
)
```

### Update Menus (Dropdowns and Buttons)

Interactive controls for switching between views:

**Dropdown menu:**

```r
plot_ly(data) |>
  add_trace(x = ~x, y = ~y1, name = "Series 1", visible = TRUE) |>
  add_trace(x = ~x, y = ~y2, name = "Series 2", visible = FALSE) |>
  layout(
    updatemenus = list(
      list(
        type = "dropdown",
        x = 0.1,
        y = 1.15,
        buttons = list(
          list(
            label = "Series 1",
            method = "update",
            args = list(list(visible = c(TRUE, FALSE)))
          ),
          list(
            label = "Series 2",
            method = "update",
            args = list(list(visible = c(FALSE, TRUE)))
          ),
          list(
            label = "Both",
            method = "update",
            args = list(list(visible = c(TRUE, TRUE)))
          )
        )
      )
    )
  )
```

**Button panel:**

```r
layout(
  updatemenus = list(
    list(
      type = "buttons",
      direction = "left",
      x = 0.5,
      y = 1.15,
      xanchor = "center",
      buttons = list(
        list(
          label = "Linear",
          method = "relayout",
          args = list(list(yaxis = list(type = "linear")))
        ),
        list(
          label = "Log",
          method = "relayout",
          args = list(list(yaxis = list(type = "log")))
        )
      )
    )
  )
)
```

**Update menu methods:**
- `"update"`: Update traces and layout
- `"restyle"`: Update traces only
- `"relayout"`: Update layout only
- `"animate"`: Trigger animation

### Complete Advanced Example

```r
library(plotly)

data <- data.frame(
  x = 1:100,
  y1 = cumsum(rnorm(100)),
  y2 = cumsum(rnorm(100, 0, 2))
)

plot_ly(data) |>
  add_trace(x = ~x, y = ~y1, type = "scatter", mode = "lines",
            name = "Series 1", visible = TRUE) |>
  add_trace(x = ~x, y = ~y2, type = "scatter", mode = "lines",
            name = "Series 2", visible = "legendonly") |>
  layout(
    # Responsive sizing
    autosize = TRUE,

    # Paper/plot configuration
    paper_bgcolor = "#f5f5f5",
    plot_bgcolor = "white",

    # Axes with proper scaling
    xaxis = list(
      title = "Time",
      automargin = TRUE,
      showgrid = TRUE,
      gridcolor = "#e0e0e0"
    ),
    yaxis = list(
      title = "Value",
      automargin = TRUE,
      showgrid = TRUE,
      gridcolor = "#e0e0e0"
    ),

    # Interactive dropdown menu
    updatemenus = list(
      list(
        type = "dropdown",
        x = 0.1, y = 1.1,
        buttons = list(
          list(
            label = "Series 1",
            method = "update",
            args = list(
              list(visible = c(TRUE, FALSE)),
              list(title = "Series 1 Only")
            )
          ),
          list(
            label = "Series 2",
            method = "update",
            args = list(
              list(visible = c(FALSE, TRUE)),
              list(title = "Series 2 Only")
            )
          ),
          list(
            label = "Both",
            method = "update",
            args = list(
              list(visible = c(TRUE, TRUE)),
              list(title = "Both Series")
            )
          )
        )
      )
    ),

    # Reference line
    shapes = list(
      list(
        type = "line",
        x0 = 0, x1 = 1,
        y0 = 0, y1 = 0,
        xref = "paper", yref = "y",
        line = list(color = "red", width = 1, dash = "dash")
      )
    ),

    # Annotation
    annotations = list(
      list(
        x = 0.98, y = 0.02,
        xref = "paper", yref = "paper",
        text = "Random Walk Data",
        showarrow = FALSE,
        font = list(size = 10, color = "#666"),
        xanchor = "right",
        yanchor = "bottom"
      )
    )
  ) |>
  config(
    responsive = TRUE,
    displaylogo = FALSE,
    modeBarButtonsToRemove = c("select2d", "lasso2d")
  )
```

---

## Parameter Quick Reference Tables

### Layout Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `title` | string/list | Main plot title | `"My Plot"` |
| `xaxis` | list | X-axis configuration | `list(title = "X")` |
| `yaxis` | list | Y-axis configuration | `list(title = "Y")` |
| `width` | number | Figure width (px) | `800` |
| `height` | number | Figure height (px) | `600` |
| `margin` | list | Margins | `list(l=50, r=50, t=50, b=50)` |
| `paper_bgcolor` | color | Outer background | `"#f5f5f5"` |
| `plot_bgcolor` | color | Plot area background | `"white"` |
| `font` | list | Global font | `list(family="Arial", size=12)` |
| `showlegend` | boolean | Show legend | `TRUE` |
| `legend` | list | Legend configuration | `list(x=1, y=1)` |
| `hovermode` | string | Hover behavior | `"closest"`, `"x"`, `"x unified"` |
| `template` | string | Theme name | `"plotly_white"` |

### Axis Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `title` | string/list | Axis label | `"X Axis"` |
| `type` | string | Scale type | `"linear"`, `"log"`, `"date"`, `"category"` |
| `range` | array | Fixed range | `c(0, 100)` |
| `autorange` | boolean/string | Auto-calculate range | `TRUE`, `"reversed"` |
| `tickmode` | string | Tick spacing | `"auto"`, `"linear"`, `"array"` |
| `tickvals` | array | Tick positions | `c(0, 5, 10)` |
| `ticktext` | array | Tick labels | `c("Low", "Mid", "High")` |
| `tickformat` | string | Number format | `".2f"`, `".1%"`, `"%b %Y"` |
| `showgrid` | boolean | Show grid lines | `TRUE` |
| `gridcolor` | color | Grid color | `"lightgray"` |
| `zeroline` | boolean | Show zero line | `TRUE` |

### Color Scale Names

| Name | Type | Description |
|------|------|-------------|
| `"Viridis"` | Sequential | Perceptually uniform, colorblind-safe |
| `"Plasma"` | Sequential | High contrast |
| `"Cividis"` | Sequential | Colorblind-optimized |
| `"Blues"` | Sequential | Single-hue blue gradient |
| `"RdBu"` | Diverging | Red to blue |
| `"RdYlGn"` | Diverging | Red-yellow-green |
| `"Set1"` | Qualitative | ColorBrewer categorical (max 9) |
| `"Set2"` | Qualitative | ColorBrewer categorical, colorblind-safe (max 8) |

---

**For additional examples and patterns, see:**
- [Chart Types Reference](chart-types-reference.md)
- [Interactivity Reference](interactivity-reference.md)
- [Basic Plots Gallery](../examples/basic-plots-gallery.md)
