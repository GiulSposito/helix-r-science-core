# Plotly Best Practices Reference

Comprehensive best practices for creating performant, accessible, and production-ready interactive visualizations with plotly in R.

## Table of Contents

1. [Design Principles](#design-principles)
2. [Data Preparation](#data-preparation)
3. [Performance Optimization](#performance-optimization)
4. [Styling Best Practices](#styling-best-practices)
5. [Shiny Performance](#shiny-performance)
6. [Export and Sharing](#export-and-sharing)
7. [Common Pitfalls](#common-pitfalls)

---

## Design Principles

Strategic guidance on when and how to use interactivity effectively.

### When to Use Interactivity

**Use interactive plots when:**

- **Exploring data dynamically**: Users need to zoom, filter, or drill down into details
- **Large information density**: Too much information to show at once, but valuable when accessed on-demand via hover
- **Multiple dimensions**: Showing 3+ variables simultaneously (color, size, shape, hover text)
- **Temporal narratives**: Animations tell a story over time
- **Dashboards and reports**: Web-based presentations where users interact with data
- **Shiny applications**: Real-time reactive visualizations

**Avoid interactivity when:**

- **Print media**: PDFs, academic papers, reports that will be printed
- **Presentation slides**: Can be distracting; consider static images or controlled animations
- **Simple comparisons**: Basic bar charts or line plots where data is already clear
- **Performance constraints**: Very large datasets without proper optimization

**Example - Good use case:**

```r
# Good: Hover reveals detailed information without cluttering the plot
plot_ly(data, x = ~gdp_per_capita, y = ~life_expectancy,
        color = ~continent, size = ~population,
        text = ~paste0(country, "<br>Population: ",
                       format(population, big.mark = ","),
                       "<br>Year: ", year),
        type = "scatter", mode = "markers") |>
  layout(title = "Global Health vs Wealth (Hover for details)")
```

**Example - Overuse:**

```r
# Avoid: Simple comparison doesn't benefit from interactivity
# Better as static ggplot2 bar chart
plot_ly(data.frame(x = c("A", "B", "C"), y = c(10, 20, 15)),
        x = ~x, y = ~y, type = "bar")
```

### Accessibility Best Practices

Make visualizations accessible to all users, including those with visual impairments or using assistive technologies.

**Color contrast and readability:**

```r
# Good: High contrast, multiple encoding channels
plot_ly(data, x = ~x, y = ~y, color = ~group, symbol = ~group,
        type = "scatter", mode = "markers",
        marker = list(size = 10, line = list(width = 1, color = "white"))) |>
  layout(
    plot_bgcolor = "white",
    font = list(size = 14, color = "#333333"),
    title = list(
      text = "<b>Main Title</b>",
      font = list(size = 18)
    )
  )
```

**Screen reader support:**

```r
# Add descriptive text for accessibility
plot_ly(data, x = ~x, y = ~y) |>
  layout(
    title = list(text = "Sales Trends 2020-2025"),
    xaxis = list(title = "Year"),
    yaxis = list(title = "Revenue in millions USD")
  ) |>
  config(
    # Ensure modebar has clear labels
    modeBarButtonsToRemove = c("toggleSpikelines"),
    displaylogo = FALSE
  )
```

**Keyboard navigation:**

Plotly supports keyboard navigation by default:
- Tab: Move between interactive elements
- Arrow keys: Pan when in pan mode
- +/-: Zoom in/out

Ensure you don't disable these features unnecessarily.

### Colorblind-Safe Palettes

**Use colorblind-friendly palettes:**

```r
# Good: Viridis palette (perceptually uniform, colorblind-safe)
plot_ly(data, x = ~x, y = ~y, z = ~value, color = ~value,
        type = "scatter", mode = "markers",
        marker = list(
          colorscale = "Viridis",
          showscale = TRUE,
          colorbar = list(title = "Value")
        ))

# Good: Categorical - use shapes + colors for redundancy
colorblind_colors <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442",
                       "#0072B2", "#D55E00", "#CC79A7")

plot_ly(data, x = ~x, y = ~y, color = ~group, symbol = ~group,
        colors = colorblind_colors,
        type = "scatter", mode = "markers")
```

**Test your visualizations:**

```r
# Simulate colorblindness with {colorBlindness} package
library(colorBlindness)

p <- plot_ly(data, x = ~x, y = ~y, color = ~group)

# Convert to ggplot to test with colorBlindness
# (plotly doesn't have direct CVD simulation)
# Alternative: Export to image and use external tools
```

**Avoid red-green combinations:**

```r
# Bad: Red-green is problematic for most common CVD
colors_bad <- c("red", "green")

# Good: Use blue-orange or purple-orange
colors_good <- c("#0072B2", "#D55E00")

plot_ly(data, x = ~x, y = ~y, color = ~category,
        colors = colors_good)
```

### Mobile Responsiveness

Design plots that work across device sizes.

**Enable responsive mode:**

```r
plot_ly(data, x = ~x, y = ~y) |>
  config(
    responsive = TRUE,  # Auto-resize to container
    displayModeBar = "hover"  # Hide modebar until hover (saves space)
  )
```

**Adjust layout for mobile:**

```r
# Use relative sizing and margins
plot_ly(data, x = ~x, y = ~y) |>
  layout(
    margin = list(l = 50, r = 20, t = 50, b = 50),
    font = list(size = 12),  # Larger fonts for mobile
    legend = list(
      orientation = "h",  # Horizontal legend saves vertical space
      x = 0, y = -0.2
    )
  )
```

**Modebar considerations:**

```r
# Simplify modebar for mobile
plot_ly(data, x = ~x, y = ~y) |>
  config(
    modeBarButtonsToRemove = c(
      "pan2d", "select2d", "lasso2d",  # Complex gestures
      "zoomIn2d", "zoomOut2d",  # Use pinch zoom instead
      "toggleSpikelines", "hoverClosestCartesian", "hoverCompareCartesian"
    ),
    displaylogo = FALSE
  )
```

**Test on multiple viewports:**

```r
# Use Shiny to test responsive behavior
library(shiny)
library(plotly)

ui <- fluidPage(
  plotlyOutput("plot", height = "400px")
)

server <- function(input, output) {
  output$plot <- renderPlotly({
    plot_ly(mtcars, x = ~wt, y = ~mpg) |>
      config(responsive = TRUE)
  })
}

shinyApp(ui, server)
# Test by resizing browser window
```

---

## Data Preparation

Proper data preparation is critical for plotly visualizations.

### Long vs Wide Format

**Understand when to use each format:**

**Wide format** - Each column is a variable:
```
  time  series_A  series_B  series_C
1 2020        10        20        30
2 2021        15        25        35
```

**Long format** - One column for category, one for value:
```
  time  series  value
1 2020 series_A     10
2 2020 series_B     20
3 2020 series_C     30
4 2021 series_A     15
```

**Rule: Use long format for grouped/colored plots:**

```r
library(tidyr)
library(dplyr)

# Wrong: Wide format for grouped plot
wide_data <- data.frame(
  year = 2020:2022,
  product_A = c(100, 120, 150),
  product_B = c(80, 95, 110),
  product_C = c(50, 60, 75)
)

# This requires manual trace addition (verbose)
plot_ly(wide_data, x = ~year) |>
  add_trace(y = ~product_A, name = "Product A", type = "scatter", mode = "lines") |>
  add_trace(y = ~product_B, name = "Product B", type = "scatter", mode = "lines") |>
  add_trace(y = ~product_C, name = "Product C", type = "scatter", mode = "lines")

# Right: Long format for grouped plot
long_data <- wide_data |>
  pivot_longer(cols = starts_with("product_"),
               names_to = "product",
               values_to = "sales") |>
  mutate(product = gsub("product_", "Product ", product))

# Clean and automatic
plot_ly(long_data, x = ~year, y = ~sales, color = ~product,
        type = "scatter", mode = "lines+markers")
```

**When wide format is acceptable:**

```r
# Single trace with multiple y-values is fine in wide format
plot_ly(wide_data, x = ~year, y = ~product_A,
        type = "scatter", mode = "lines")

# Heatmaps expect wide/matrix format
heatmap_matrix <- as.matrix(wide_data[, -1])
plot_ly(z = ~heatmap_matrix, type = "heatmap")
```

### Pre-Aggregation Strategies

**Always aggregate before plotting when possible:**

```r
# Bad: Plotting raw data with many duplicate x-values
raw_data <- data.frame(
  category = rep(LETTERS[1:5], each = 1000),
  value = rnorm(5000)
)
plot_ly(raw_data, x = ~category, y = ~value, type = "scatter", mode = "markers")
# 5000 points! Slow rendering

# Good: Aggregate to summary statistics
summary_data <- raw_data |>
  group_by(category) |>
  summarise(
    mean = mean(value),
    median = median(value),
    q25 = quantile(value, 0.25),
    q75 = quantile(value, 0.75)
  )

plot_ly(summary_data, x = ~category, y = ~median, type = "bar") |>
  add_segments(x = ~category, xend = ~category,
               y = ~q25, yend = ~q75,
               line = list(color = "black", width = 2),
               showlegend = FALSE)
# Clean, fast, informative
```

**Pre-aggregate time series:**

```r
# Raw: 1-minute data for a year = 525,600 points
minute_data <- data.frame(
  timestamp = seq(as.POSIXct("2023-01-01"),
                  as.POSIXct("2023-12-31 23:59:00"),
                  by = "1 min"),
  value = rnorm(525600)
)

# Aggregate to hourly for visualization
hourly_data <- minute_data |>
  mutate(hour = lubridate::floor_date(timestamp, "hour")) |>
  group_by(hour) |>
  summarise(
    value = mean(value),
    min_val = min(value),
    max_val = max(value)
  )

plot_ly(hourly_data, x = ~hour, y = ~value,
        type = "scatter", mode = "lines")
# 8,760 points instead of 525,600
```

**When NOT to pre-aggregate:**

```r
# Don't pre-aggregate scatter plots showing individual relationships
plot_ly(mtcars, x = ~wt, y = ~mpg, type = "scatter", mode = "markers")
# Each point is unique and meaningful

# Don't pre-aggregate when showing raw distributions
plot_ly(iris, y = ~Sepal.Length, color = ~Species, type = "box")
# Box plot needs raw data to calculate quartiles
```

### Handling Missing Data

**Strategies for missing values:**

**Option 1: Remove missing values explicitly:**

```r
# Clean approach - filter before plotting
clean_data <- data |>
  filter(!is.na(x), !is.na(y))

plot_ly(clean_data, x = ~x, y = ~y, type = "scatter", mode = "markers")
```

**Option 2: Keep gaps in time series:**

```r
# Plotly automatically handles NA as gaps
time_series <- data.frame(
  date = seq(as.Date("2023-01-01"), as.Date("2023-12-31"), by = "day"),
  value = c(rnorm(100), rep(NA, 50), rnorm(215))
)

plot_ly(time_series, x = ~date, y = ~value,
        type = "scatter", mode = "lines",
        connectgaps = FALSE)  # FALSE = show gaps (default)
```

**Option 3: Impute for continuous appearance:**

```r
# Only if scientifically justified
plot_ly(time_series, x = ~date, y = ~value,
        type = "scatter", mode = "lines",
        connectgaps = TRUE)  # Connect across NA values
```

**Handle missing categories:**

```r
# Complete missing combinations
library(tidyr)

incomplete_data <- data.frame(
  category = c("A", "A", "B", "C", "C"),
  time = c(1, 2, 1, 1, 2),
  value = c(10, 15, 20, 25, 30)
)
# Missing: B at time 2

complete_data <- incomplete_data |>
  complete(category, time, fill = list(value = 0))

plot_ly(complete_data, x = ~time, y = ~value, color = ~category,
        type = "scatter", mode = "lines+markers")
```

### Type Coercion Best Practices

**Ensure proper data types before plotting:**

```r
# Common type issues
data <- data.frame(
  category = c("1", "2", "3", "10", "20"),  # Character, not numeric!
  date_str = c("2023-01-01", "2023-02-01", "2023-03-01"),  # Character, not Date!
  factor_num = factor(c(1, 2, 3, 1, 2))  # Factor, not numeric!
)

# Fix types explicitly
data_fixed <- data |>
  mutate(
    category = as.numeric(category),
    date_str = as.Date(date_str),
    factor_num = as.numeric(as.character(factor_num))
  )

# Now plots correctly
plot_ly(data_fixed, x = ~date_str, y = ~category, type = "scatter", mode = "lines")
```

**Factor ordering for categorical plots:**

```r
# Unordered factors plot alphabetically (often wrong)
data <- data.frame(
  month = c("Jan", "Feb", "Mar", "Apr"),
  value = c(10, 20, 15, 25)
)

plot_ly(data, x = ~month, y = ~value, type = "bar")
# Wrong order: Apr, Feb, Jan, Mar (alphabetical)

# Fix with factor levels
data_ordered <- data |>
  mutate(month = factor(month, levels = c("Jan", "Feb", "Mar", "Apr")))

plot_ly(data_ordered, x = ~month, y = ~value, type = "bar")
# Correct order: Jan, Feb, Mar, Apr
```

**Numeric vs categorical aesthetics:**

```r
# Discrete numeric values should be factors for color mapping
data <- data.frame(
  x = rnorm(100),
  y = rnorm(100),
  group = sample(1:3, 100, replace = TRUE)  # Numeric but categorical
)

# Wrong: Treats as continuous color scale
plot_ly(data, x = ~x, y = ~y, color = ~group, type = "scatter")

# Right: Convert to factor for discrete colors
plot_ly(data, x = ~x, y = ~y, color = ~factor(group), type = "scatter")
```

---

## Performance Optimization

Strategies for fast, responsive visualizations with large datasets.

### Data Size Limits

**General guidelines:**

- **< 1,000 points**: No optimization needed, plot directly
- **1,000 - 10,000 points**: Consider aggregation or WebGL for scatter plots
- **10,000 - 100,000 points**: Use WebGL (`scattergl`), aggregate time series, use heatmaps
- **> 100,000 points**: Mandatory aggregation or server-side rendering; plotly not ideal

**Test performance:**

```r
library(microbenchmark)

# Compare rendering times
small_data <- data.frame(x = rnorm(1000), y = rnorm(1000))
medium_data <- data.frame(x = rnorm(10000), y = rnorm(10000))
large_data <- data.frame(x = rnorm(100000), y = rnorm(100000))

microbenchmark(
  small = plot_ly(small_data, x = ~x, y = ~y),
  medium = plot_ly(medium_data, x = ~x, y = ~y),
  large = plot_ly(large_data, x = ~x, y = ~y),
  times = 5
)
```

### Trace Count Management

**Limit number of traces:**

```r
# Bad: One trace per data point
many_traces <- mtcars |>
  split(.$cyl) |>
  lapply(function(df) {
    plot_ly(df, x = ~wt, y = ~mpg, name = unique(df$cyl))
  }) |>
  subplot()
# Complex, slow

# Good: Use color aesthetic to group
plot_ly(mtcars, x = ~wt, y = ~mpg, color = ~factor(cyl),
        type = "scatter", mode = "markers")
# Single trace with color grouping, fast
```

**Trace optimization for time series:**

```r
# Bad: Adding 100 separate traces
plot_obj <- plot_ly()
for (i in 1:100) {
  series_data <- data.frame(x = 1:100, y = rnorm(100))
  plot_obj <- plot_obj |>
    add_trace(data = series_data, x = ~x, y = ~y, type = "scatter", mode = "lines")
}

# Good: Single trace with color grouping
all_data <- lapply(1:100, function(i) {
  data.frame(x = 1:100, y = rnorm(100), series = i)
}) |> bind_rows()

plot_ly(all_data, x = ~x, y = ~y, color = ~series,
        type = "scatter", mode = "lines") |>
  layout(showlegend = FALSE)  # Hide legend if too many series
```

**Maximum recommended traces:**

- **Interactive exploration**: 5-10 traces
- **Presentation**: 3-5 traces
- **Many series**: Use single trace with color or consider alternatives (heatmap, small multiples)

### WebGL for Large Scatter Plots

**Use `scattergl` for large point clouds:**

```r
# Standard scatter (slow with many points)
large_data <- data.frame(
  x = rnorm(50000),
  y = rnorm(50000),
  group = sample(LETTERS[1:3], 50000, replace = TRUE)
)

# Slow: SVG rendering
plot_ly(large_data, x = ~x, y = ~y, type = "scatter", mode = "markers")

# Fast: WebGL rendering
plot_ly(large_data, x = ~x, y = ~y, type = "scattergl", mode = "markers")
```

**WebGL limitations:**

- Fewer customization options than SVG
- Some marker symbols not supported
- Browser must support WebGL (most modern browsers do)
- Hover can be less precise with many overlapping points

**When to use WebGL:**

```r
# Use scattergl when:
# - More than 5,000 points
# - Real-time updates
# - Need smooth panning/zooming with large data

# Stick with scatter when:
# - < 5,000 points
# - Need all marker customization options
# - Targeting older browsers
```

**WebGL for 3D plots:**

```r
# 3D scatter with many points
plot_ly(large_data, x = ~x, y = ~y, z = ~x * y,
        type = "scatter3d", mode = "markers",
        marker = list(size = 2, opacity = 0.5))
# Automatically uses WebGL
```

### Animation Performance Limits

**Keep animations simple:**

```r
# Bad: Too many frames, large data per frame
large_animated <- data.frame(
  x = rep(1:100, 100),  # 10,000 points
  y = rnorm(10000),
  frame = rep(1:100, each = 100)  # 100 frames!
)

plot_ly(large_animated, x = ~x, y = ~y, frame = ~frame)
# Slow, janky animation

# Good: Reasonable frame count, aggregated data
aggregated_animated <- large_animated |>
  group_by(frame, bin = cut(x, breaks = 20)) |>
  summarise(y = mean(y), x = as.numeric(bin))

plot_ly(aggregated_animated, x = ~x, y = ~y, frame = ~frame,
        type = "scatter", mode = "markers") |>
  animation_opts(frame = 100, transition = 50)
# Smooth, responsive
```

**Animation best practices:**

```r
# Optimal settings
plot_ly(data, x = ~x, y = ~y, frame = ~time) |>
  animation_opts(
    frame = 100,         # 100ms per frame (10 fps) - adjust based on complexity
    transition = 50,     # 50ms transition
    redraw = FALSE       # Don't redraw entire plot each frame (faster)
  ) |>
  animation_slider(
    currentvalue = list(prefix = "Time: ", font = list(size = 16))
  )
```

**Limits:**

- **Frames**: Keep under 50 frames for smooth playback
- **Points per frame**: < 5,000 for smooth animation
- **Frame rate**: 50-200ms per frame is comfortable
- **Transitions**: 30-100ms transition time

### Aggregation Strategies

**Spatial aggregation for maps:**

```r
# Bad: 100,000 individual points on map
library(maps)
map_data_large <- data.frame(
  lat = rnorm(100000, mean = 40, sd = 5),
  lon = rnorm(100000, mean = -95, sd = 10),
  value = rnorm(100000)
)

# Slow
plot_ly(map_data_large, lat = ~lat, lon = ~lon,
        type = "scattergeo", mode = "markers")

# Good: Aggregate to grid or hexbins
library(dplyr)

# Create spatial bins
binned_map <- map_data_large |>
  mutate(
    lat_bin = round(lat, 1),  # 0.1 degree bins
    lon_bin = round(lon, 1)
  ) |>
  group_by(lat_bin, lon_bin) |>
  summarise(
    count = n(),
    value = mean(value)
  )

plot_ly(binned_map, lat = ~lat_bin, lon = ~lon_bin,
        marker = list(size = ~count, sizemode = "area"),
        color = ~value,
        type = "scattergeo", mode = "markers")
# Fast, shows density patterns
```

**Temporal aggregation:**

```r
# Automatic binning for histograms
plot_ly(data, x = ~timestamp, type = "histogram",
        xbins = list(size = 86400000))  # 1 day bins (milliseconds)

# Manual aggregation for better control
daily_agg <- data |>
  mutate(day = as.Date(timestamp)) |>
  group_by(day) |>
  summarise(
    value = mean(value),
    count = n(),
    min = min(value),
    max = max(value)
  )

plot_ly(daily_agg, x = ~day, y = ~value, type = "scatter", mode = "lines")
```

**Downsample with LTTB (Largest Triangle Three Buckets):**

```r
# Not built into plotly, but can implement or use {downsample} package
# Preserves visual appearance while reducing points

# Simple downsampling alternative
downsample_every_n <- function(data, n = 10) {
  data[seq(1, nrow(data), by = n), ]
}

large_ts <- data.frame(
  time = 1:100000,
  value = cumsum(rnorm(100000))
)

downsampled <- downsample_every_n(large_ts, n = 100)

plot_ly(downsampled, x = ~time, y = ~value,
        type = "scatter", mode = "lines")
# 1,000 points instead of 100,000, visually similar
```

---

## Styling Best Practices

Create consistent, professional visualizations.

### Consistent Theming

**Define a custom theme:**

```r
# Create reusable theme
my_org_theme <- function() {
  list(
    plot_bgcolor = "#f8f9fa",
    paper_bgcolor = "white",
    font = list(family = "Arial, sans-serif", size = 12, color = "#333333"),
    title = list(font = list(size = 16, color = "#1a1a1a")),
    xaxis = list(
      gridcolor = "#e0e0e0",
      linecolor = "#666666",
      tickcolor = "#666666"
    ),
    yaxis = list(
      gridcolor = "#e0e0e0",
      linecolor = "#666666",
      tickcolor = "#666666"
    ),
    legend = list(
      bgcolor = "rgba(255, 255, 255, 0.8)",
      bordercolor = "#cccccc",
      borderwidth = 1
    )
  )
}

# Apply to plots
plot_ly(data, x = ~x, y = ~y) |>
  layout(my_org_theme())
```

**Use plotly templates:**

```r
# Built-in templates
templates <- c("plotly", "plotly_white", "plotly_dark", "ggplot2",
               "seaborn", "simple_white", "none")

# Apply template
plot_ly(data, x = ~x, y = ~y) |>
  layout(template = "plotly_white")

# Customize template
plot_ly(data, x = ~x, y = ~y) |>
  layout(
    template = "plotly_white",
    title = "Custom Title",
    xaxis = list(title = "X Label")
  )
```

### Color Selection Guidelines

**Use semantic colors:**

```r
# Define color palette with meaning
colors_semantic <- list(
  primary = "#0066cc",
  success = "#28a745",
  warning = "#ffc107",
  danger = "#dc3545",
  neutral = "#6c757d"
)

# Use consistently across plots
plot_ly(data, x = ~x, y = ~positive,
        type = "scatter", mode = "lines",
        line = list(color = colors_semantic$success, width = 2))
```

**Categorical color scales:**

```r
# Qualitative palettes for categories (no inherent order)
qualitative_palettes <- c(
  "Set1", "Set2", "Set3", "Pastel1", "Pastel2", "Dark2", "Accent"
)

plot_ly(data, x = ~x, y = ~y, color = ~category,
        colors = "Set2",  # ColorBrewer palette
        type = "scatter", mode = "markers")

# Custom categorical colors
custom_colors <- c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728",
                   "#9467bd", "#8c564b", "#e377c2")

plot_ly(data, x = ~x, y = ~y, color = ~category,
        colors = custom_colors)
```

**Sequential color scales:**

```r
# For continuous data with inherent order (low to high)
sequential_scales <- c(
  "Viridis", "Cividis", "Blues", "Greens", "Greys", "Oranges",
  "Purples", "Reds", "YlOrBr", "YlOrRd"
)

plot_ly(data, x = ~x, y = ~y, z = ~value, color = ~value,
        type = "scatter", mode = "markers",
        marker = list(
          colorscale = "Viridis",
          showscale = TRUE,
          colorbar = list(title = "Value")
        ))
```

**Diverging color scales:**

```r
# For data with meaningful midpoint (e.g., zero, average)
diverging_scales <- c("RdBu", "RdYlBu", "RdYlGn", "Spectral", "PiYG")

plot_ly(data, z = ~correlation_matrix, type = "heatmap",
        colorscale = "RdBu",
        zmid = 0,  # Center color scale at zero
        colorbar = list(title = "Correlation"))
```

### Typography Best Practices

**Font hierarchy:**

```r
plot_ly(data, x = ~x, y = ~y) |>
  layout(
    title = list(
      text = "<b>Main Title</b>",
      font = list(size = 18, color = "#1a1a1a")
    ),
    xaxis = list(
      title = list(
        text = "X-Axis Label",
        font = list(size = 14, color = "#333333")
      ),
      tickfont = list(size = 11, color = "#666666")
    ),
    yaxis = list(
      title = list(
        text = "Y-Axis Label",
        font = list(size = 14, color = "#333333")
      ),
      tickfont = list(size = 11, color = "#666666")
    ),
    annotations = list(
      list(
        text = "Annotation text",
        x = 5, y = 10,
        font = list(size = 12, color = "#555555", style = "italic"),
        showarrow = FALSE
      )
    )
  )
```

**Web-safe fonts:**

```r
# Reliable cross-platform fonts
font_families <- c(
  "Arial, sans-serif",
  "Helvetica, sans-serif",
  "Georgia, serif",
  "Times New Roman, serif",
  "Courier New, monospace"
)

plot_ly(data, x = ~x, y = ~y) |>
  layout(font = list(family = "Arial, sans-serif"))
```

### White Space and Margins

**Control margins:**

```r
# Default margins often too large
plot_ly(data, x = ~x, y = ~y) |>
  layout(
    margin = list(l = 60, r = 30, t = 50, b = 60)
    # l = left, r = right, t = top, b = bottom
  )

# Tight margins for dashboards
plot_ly(data, x = ~x, y = ~y) |>
  layout(
    margin = list(l = 40, r = 20, t = 30, b = 40)
  )

# Extra space for long labels
plot_ly(data, x = ~long_category_names, y = ~y, type = "bar") |>
  layout(
    margin = list(l = 60, r = 30, t = 50, b = 120),  # Extra bottom space
    xaxis = list(tickangle = -45)
  )
```

### Responsive Design

**Container-based sizing:**

```r
# Let container dictate size
plot_ly(data, x = ~x, y = ~y) |>
  config(responsive = TRUE) |>
  layout(
    autosize = TRUE,  # Auto-fit to container
    margin = list(l = 50, r = 30, t = 50, b = 50)
  )
```

**Fixed aspect ratio:**

```r
# Maintain aspect ratio (useful for maps, square grids)
plot_ly(data, x = ~x, y = ~y) |>
  layout(
    xaxis = list(scaleanchor = "y", scaleratio = 1),
    yaxis = list(constrain = "domain")
  )
```

---

## Shiny Performance

Optimize plotly visualizations in Shiny applications.

### Reactive Dependency Management

**Minimize reactive recalculations:**

```r
# Bad: Plot recreated on every input change
server <- function(input, output, session) {
  output$plot <- renderPlotly({
    data <- get_data()  # Expensive
    processed <- process_data(data)  # Expensive

    plot_ly(processed, x = ~x, y = ~y, type = input$chart_type)
  })
}

# Good: Cache expensive operations
server <- function(input, output, session) {
  # Reactive values computed once
  data <- reactive({
    get_data()
  })

  processed_data <- reactive({
    process_data(data())
  })

  # Only plot updates on input change
  output$plot <- renderPlotly({
    plot_ly(processed_data(), x = ~x, y = ~y, type = input$chart_type)
  })
}
```

**Isolate non-critical inputs:**

```r
server <- function(input, output, session) {
  output$plot <- renderPlotly({
    # Only recompute when data_selector changes
    data <- get_data(input$data_selector)

    # Isolate cosmetic inputs to prevent recomputation
    plot_ly(data, x = ~x, y = ~y) |>
      layout(
        title = isolate(input$plot_title),
        xaxis = list(title = isolate(input$x_label))
      )
  })
}
```

### Caching Strategies

**Use `bindCache()` for expensive computations:**

```r
server <- function(input, output, session) {
  output$plot <- renderPlotly({
    expensive_data <- get_expensive_data(input$param)
    plot_ly(expensive_data, x = ~x, y = ~y)
  }) |>
    bindCache(input$param)  # Cache based on param value
}
```

**Memoise expensive functions:**

```r
library(memoise)

# Cache function results
get_data_cached <- memoise(function(date_range) {
  # Expensive database query
  fetch_from_database(date_range)
})

server <- function(input, output, session) {
  data <- reactive({
    get_data_cached(input$date_range)
  })

  output$plot <- renderPlotly({
    plot_ly(data(), x = ~x, y = ~y)
  })
}
```

### plotlyProxy for Incremental Updates

**Update plots without full re-render:**

```r
library(shiny)
library(plotly)

ui <- fluidPage(
  sliderInput("n_points", "Points", min = 10, max = 100, value = 50),
  plotlyOutput("plot")
)

server <- function(input, output, session) {
  # Initial plot
  output$plot <- renderPlotly({
    plot_ly(type = "scatter", mode = "markers") |>
      add_trace(x = rnorm(50), y = rnorm(50))
  })

  # Update plot without re-rendering
  observeEvent(input$n_points, {
    new_data <- list(
      x = list(rnorm(input$n_points)),
      y = list(rnorm(input$n_points))
    )

    plotlyProxy("plot", session) |>
      plotlyProxyInvoke("restyle", new_data, 0)  # Update trace 0
  })
}
```

**Update layout without re-rendering:**

```r
observeEvent(input$title, {
  plotlyProxy("plot", session) |>
    plotlyProxyInvoke("relayout", list(title = input$title))
})
```

### Async Operations

**Use `future` for non-blocking operations:**

```r
library(future)
library(promises)

plan(multisession)  # Enable parallel processing

server <- function(input, output, session) {
  output$plot <- renderPlotly({
    # Run expensive operation in background
    future({
      Sys.sleep(2)  # Simulate expensive computation
      data.frame(x = rnorm(100), y = rnorm(100))
    }) %...>% {
      # Plot when ready
      plot_ly(., x = ~x, y = ~y, type = "scatter", mode = "markers")
    }
  })
}
```

---

## Export and Sharing

Save and share plotly visualizations.

### HTML Widgets

**Save as standalone HTML:**

```r
library(htmlwidgets)

p <- plot_ly(mtcars, x = ~wt, y = ~mpg, type = "scatter", mode = "markers")

# Save interactive plot
saveWidget(p, "my_plot.html", selfcontained = TRUE)
# Creates single HTML file with all dependencies
```

**Embed in web pages:**

```html
<!-- Include in HTML -->
<iframe src="my_plot.html" width="800" height="600"></iframe>
```

### Reducing File Size with partial_bundle()

**Reduce HTML file size:**

```r
library(plotly)

p <- plot_ly(mtcars, x = ~wt, y = ~mpg)

# Full bundle (default): ~3MB
saveWidget(p, "full_bundle.html")

# Partial bundle: ~500KB (only includes used features)
saveWidget(partial_bundle(p), "partial_bundle.html")
```

**When to use partial bundle:**

- Emailing HTML files
- Hosting on bandwidth-limited servers
- Embedding in documents
- Faster page load times

**Limitations:**

- Some advanced features may not work
- External dependencies must be available
- Not recommended for complex multi-trace plots

### Static Image Export

**Export to PNG/JPEG/SVG:**

```r
# Requires kaleido package
# install.packages("reticulate")
# reticulate::install_miniconda()
# reticulate::conda_install("r-reticulate", "python-kaleido")

library(plotly)

p <- plot_ly(mtcars, x = ~wt, y = ~mpg, type = "scatter", mode = "markers")

# Save as PNG
orca(p, "plot.png", width = 800, height = 600)

# Save as SVG (vector graphics for publications)
orca(p, "plot.svg", width = 800, height = 600)

# Save as PDF
orca(p, "plot.pdf", width = 8, height = 6)  # Inches for PDF
```

**Configure export button:**

```r
plot_ly(data, x = ~x, y = ~y) |>
  config(
    toImageButtonOptions = list(
      format = "png",      # png, svg, jpeg, webp
      filename = "my_plot",
      width = 1200,
      height = 800,
      scale = 2            # Higher resolution
    )
  )
```

### Embedding in R Markdown

**Default behavior:**

````markdown
```{r}
library(plotly)
plot_ly(mtcars, x = ~wt, y = ~mpg, type = "scatter", mode = "markers")
```
````

**Control size:**

````markdown
```{r, fig.width=8, fig.height=6}
plot_ly(mtcars, x = ~wt, y = ~mpg)
```
````

**Static images in PDF output:**

```r
# In YAML header
output:
  pdf_document: default
  html_document: default

# In R chunk
```{r}
# Will automatically convert to static image for PDF
plot_ly(mtcars, x = ~wt, y = ~mpg)
```
```

---

## Common Pitfalls

Frequent mistakes and how to avoid them.

### Data Format Mistakes

**Issue: Forgetting to use long format for grouped plots**

```r
# Wrong
wide <- data.frame(x = 1:5, A = rnorm(5), B = rnorm(5))
plot_ly(wide, x = ~x, y = ~A, color = ~B)  # Doesn't work as expected

# Right
long <- tidyr::pivot_longer(wide, cols = c(A, B), names_to = "series", values_to = "value")
plot_ly(long, x = ~x, y = ~value, color = ~series)
```

### Trace vs Layout Confusion

**Issue: Putting layout properties in traces**

```r
# Wrong
plot_ly(data, x = ~x, y = ~y, title = "Title")  # title not a trace parameter

# Right
plot_ly(data, x = ~x, y = ~y) |> layout(title = "Title")
```

### Performance Issues

**Issue: Plotting too many points without optimization**

```r
# Wrong: 100k points with default scatter
plot_ly(huge_data, x = ~x, y = ~y, type = "scatter")

# Right: Use scattergl or aggregate
plot_ly(huge_data, x = ~x, y = ~y, type = "scattergl")
# OR
aggregated <- huge_data |> sample_n(5000)  # Random sample
plot_ly(aggregated, x = ~x, y = ~y, type = "scatter")
```

### Browser Compatibility

**Issue: WebGL not supported in older browsers**

```r
# Provide fallback
tryCatch({
  plot_ly(data, x = ~x, y = ~y, type = "scattergl")
}, error = function(e) {
  plot_ly(data, x = ~x, y = ~y, type = "scatter")  # Fallback to SVG
})
```

---

## Summary Checklist

Before deploying a plotly visualization:

- [ ] Data is in correct format (long vs wide)
- [ ] Appropriate chart type for the data and message
- [ ] Color palette is colorblind-safe
- [ ] Font sizes readable on target devices
- [ ] Performance tested with expected data size
- [ ] Trace count is reasonable (< 10 preferred)
- [ ] Responsive mode enabled if needed
- [ ] Modebar configured appropriately
- [ ] Hover templates are informative
- [ ] Tested in target browser/environment
- [ ] Accessibility considered (contrast, screen readers)
- [ ] File size optimized for deployment method

---

For more details, see:
- [Chart Types Reference](chart-types-reference.md)
- [Interactivity Reference](interactivity-reference.md)
- [Shiny Integration Reference](shiny-integration-reference.md)
- [Animation Reference](animation-reference.md)
