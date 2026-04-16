---
name: r-plotly
description: Expert interactive data visualization in R with plotly - web-based graphics, animations, Shiny integration, and 3D plots. Use when user works with plotly, mentions "plotly", "plot_ly", "ggplotly", "interactive plot", "interactive visualization", "visualização interativa", "gráfico interativo", "animated plot", "animação", "animation", "plotly em R", "plotly for R", "plotly in R", "web graphics", "HTML widget", "3D plot", "3D surface", "choropleth", "mapbox", "plotly animation", "plotly shiny", "event_data", "plotlyOutput", "renderPlotly", "hover template", "plotly trace", "add_trace", "layout plotly", or discusses interactive/web-based visualization in R. Do NOT activate for static ggplot2 plots without plotly conversion.
version: 1.0.0
allowed-tools: Read, Write, Edit, Grep, Glob
user-invocable: false
---

# r-plotly - Expert Interactive Data Visualization in R

Master interactive, web-based data visualization in R using plotly for exploratory analysis, dashboards, animations, and production applications.

## Overview

Plotly is R's leading framework for **interactive, web-based visualizations**. Unlike static plotting libraries, every plotly graphic is interactive by default - users can hover for details, zoom, pan, select data, and trigger events. This skill provides comprehensive guidance on creating publication-quality interactive visualizations, from basic charts to complex animated dashboards integrated with Shiny.

**Key Capabilities:**
- Interactive plots with hover, zoom, pan, click, and brush
- Frame-based animations for temporal narratives
- 3D visualizations with camera controls
- Geographic maps with projections and tooltips
- Shiny integration with event handling
- Web-ready HTML widgets for embedding
- Performance optimization for large datasets

**When to use plotly vs ggplot2:**
- **Use plotly when**: Need interactivity, animations, 3D plots, web deployment, Shiny dashboards, or exploring data dynamically
- **Use ggplot2 when**: Creating publication-ready static plots, need fine-grained aesthetic control, or working with print media
- **Use both**: Convert ggplot2 to interactive with `ggplotly()` for quick interactivity layer

For static plot design principles, see the **ggplot2** skill. For general Shiny concepts, see the **r-shiny** skill.

---

## The Three-Layer Architecture

Every plotly figure follows a **declarative three-layer model**:

```
Data → Traces (what to draw) → Layout (how it looks) → Config (interactivity options)
```

### Layer 1: Traces (What to Draw)

**Traces** define what gets drawn - the geometric representation of data.

```r
# Scatter trace with markers
plot_ly(data, x = ~x_var, y = ~y_var, type = "scatter", mode = "markers")

# Multiple traces on one plot
plot_ly(data) |>
  add_trace(x = ~x, y = ~y1, type = "scatter", mode = "lines", name = "Series 1") |>
  add_trace(x = ~x, y = ~y2, type = "scatter", mode = "lines", name = "Series 2")
```

**Key trace parameters:**
- `type`: Chart type ("scatter", "bar", "box", "heatmap", "surface", etc.)
- `mode`: For scatter traces ("markers", "lines", "markers+lines", "text")
- `name`: Legend label
- Data aesthetics: `x`, `y`, `z`, `color`, `size`, `symbol`, `text`

### Layer 2: Layout (How It Looks)

**Layout** controls everything that isn't data: titles, axes, colors, spacing, legends.

```r
plot_ly(data, x = ~x, y = ~y) |>
  layout(
    title = "Main Title",
    xaxis = list(title = "X Label", gridcolor = "lightgray"),
    yaxis = list(title = "Y Label", gridcolor = "lightgray"),
    legend = list(x = 0.7, y = 0.95),
    plot_bgcolor = "white",
    paper_bgcolor = "#f5f5f5"
  )
```

**Key layout parameters:**
- `title`, `xaxis`, `yaxis`: Labels and axis configuration
- `legend`: Position and styling
- `margin`: Plot spacing
- `annotations`: Text and shapes overlay
- `template`: Built-in themes ("plotly", "ggplot2", "seaborn", "simple_white")

### Layer 3: Config (Interactivity Options)

**Config** controls interactive features and the modebar (toolbar).

```r
plot_ly(data, x = ~x, y = ~y) |>
  config(
    displaylogo = FALSE,                    # Hide plotly logo
    modeBarButtonsToRemove = c("pan2d", "lasso2d"),
    toImageButtonOptions = list(            # Download button options
      format = "png",
      filename = "my_plot",
      width = 800,
      height = 600
    )
  )
```

**Philosophy**: This separation allows independent modification of data representation (traces), appearance (layout), and interaction (config) without affecting each other.

---

## Core Functions & Workflow

### 1. plot_ly() - Initialize Plot

**Starts a plotly figure and optionally adds the first trace.**

```r
# Basic initialization
p <- plot_ly(data, x = ~var1, y = ~var2, type = "scatter", mode = "markers")

# With aesthetics
p <- plot_ly(data, x = ~x, y = ~y, color = ~group, size = ~value,
             type = "scatter", mode = "markers")

# Minimal (add traces later)
p <- plot_ly(data)
```

**Key parameters:**
- `data`: Data frame (required)
- `x`, `y`, `z`: Column mappings using `~variable` syntax
- `type`: Chart type (defaults to "scatter")
- `color`, `size`, `symbol`: Aesthetic mappings
- All trace-level parameters accepted

### 2. add_trace() - Layer Additional Traces

**Adds layers to existing plot, enabling multi-trace visualizations.**

```r
plot_ly(data, x = ~x) |>
  add_trace(y = ~y1, type = "scatter", mode = "lines", name = "Actual") |>
  add_trace(y = ~y2, type = "scatter", mode = "lines", name = "Predicted",
            line = list(dash = "dash"))
```

**Convenience functions** (wrappers around add_trace):
- `add_markers()`, `add_lines()`, `add_paths()`, `add_segments()`
- `add_bars()`, `add_histogram()`, `add_boxplot()`
- `add_heatmap()`, `add_surface()`, `add_polygons()`

### 3. layout() - Configure Appearance

**Modifies plot layout - titles, axes, legends, annotations, themes.**

```r
p |>
  layout(
    title = list(text = "Interactive Plot", font = list(size = 18)),
    xaxis = list(title = "Time", type = "date", tickformat = "%b %Y"),
    yaxis = list(title = "Value", range = c(0, 100)),
    hovermode = "x unified",
    showlegend = TRUE,
    legend = list(x = 1, xanchor = "right", y = 1)
  )
```

### 4. config() - Set Interactivity

**Controls modebar, responsiveness, and interaction settings.**

```r
p |>
  config(
    responsive = TRUE,              # Auto-resize
    displayModeBar = TRUE,          # Show toolbar
    scrollZoom = FALSE,             # Disable scroll-to-zoom
    modeBarButtonsToRemove = c("select2d", "lasso2d")
  )
```

### Complete Example

```r
library(plotly)
library(dplyr)

# Data preparation
data <- mtcars |>
  mutate(cyl = as.factor(cyl))

# Build plot with three layers
data |>
  plot_ly(x = ~wt, y = ~mpg, color = ~cyl, size = ~hp,
          text = ~paste("Car:", row.names(mtcars)),
          type = "scatter", mode = "markers") |>
  layout(
    title = "Fuel Efficiency vs Weight",
    xaxis = list(title = "Weight (1000 lbs)"),
    yaxis = list(title = "Miles per Gallon"),
    hovermode = "closest"
  ) |>
  config(displaylogo = FALSE)
```

---

## Quick Chart Type Selection Guide

Choose chart type based on your analytical goal:

### Relationships & Correlation
- **Scatter plot**: `plot_ly(x = ~x, y = ~y, type = "scatter", mode = "markers")`
- **Line plot**: `plot_ly(x = ~x, y = ~y, type = "scatter", mode = "lines")`
- **Bubble chart**: Add `size = ~variable` to scatter
- **3D scatter**: `plot_ly(x = ~x, y = ~y, z = ~z, type = "scatter3d")`

### Distributions
- **Histogram**: `plot_ly(x = ~var, type = "histogram")`
- **Box plot**: `plot_ly(y = ~var, type = "box")`
- **Violin plot**: `plot_ly(y = ~var, type = "violin")`
- **2D histogram**: `plot_ly(x = ~x, y = ~y, type = "histogram2d")`

### Comparisons
- **Bar chart**: `plot_ly(x = ~category, y = ~value, type = "bar")`
- **Grouped bars**: `plot_ly(x = ~cat, y = ~val, color = ~group, type = "bar")` + `layout(barmode = "group")`
- **Stacked bars**: Same as grouped + `layout(barmode = "stack")`

### Compositions
- **Pie chart**: `plot_ly(labels = ~category, values = ~count, type = "pie")`
- **Sunburst**: `plot_ly(labels = ~labels, parents = ~parents, values = ~values, type = "sunburst")`
- **Treemap**: `plot_ly(labels = ~labels, parents = ~parents, values = ~values, type = "treemap")`

### Geographic
- **Choropleth**: `plot_ly(locations = ~state, z = ~value, type = "choropleth")`
- **Scatter map**: `plot_ly(lat = ~lat, lon = ~lon, type = "scattergeo")`
- **Mapbox**: `plot_ly(lat = ~lat, lon = ~lon, type = "scattermapbox")`

### Statistical
- **Heatmap**: `plot_ly(z = ~matrix, type = "heatmap")`
- **Contour**: `plot_ly(z = ~matrix, type = "contour")`
- **3D surface**: `plot_ly(z = ~matrix, type = "surface")`

**For complete chart type reference with all parameters:** [references/chart-types-reference.md](references/chart-types-reference.md)

---

## Interactivity Patterns Quick Reference

### Hover Information

**Default behavior**: Automatic tooltips with x, y, and trace name.

**Custom hover text:**
```r
plot_ly(data, x = ~x, y = ~y, text = ~paste("Value:", y, "<br>Category:", cat))
```

**Hover template** (formatted tooltips):
```r
plot_ly(data, x = ~x, y = ~y,
        hovertemplate = "<b>%{text}</b><br>X: %{x:.2f}<br>Y: %{y:.2f}<extra></extra>",
        text = ~label)
```

### Zoom and Pan

**Constraints:**
```r
layout(
  xaxis = list(fixedrange = TRUE),   # Disable x-axis zoom/pan
  yaxis = list(range = c(0, 100))    # Fixed y range
)
```

**Reset view:** Modebar "Reset axes" button (default enabled)

### Click Events (Shiny Only)

```r
# In Shiny server
observeEvent(event_data("plotly_click"), {
  clicked_point <- event_data("plotly_click")
  # Access: clicked_point$x, clicked_point$y, clicked_point$curveNumber
})
```

### Selection

**Box select / Lasso select:**
```r
plot_ly(x = ~x, y = ~y, type = "scatter", mode = "markers") |>
  layout(dragmode = "lasso")  # or "select" for box
```

### Animation

**Frame-based animation:**
```r
plot_ly(data, x = ~x, y = ~y, frame = ~time_var, type = "scatter", mode = "markers") |>
  animation_opts(frame = 500, transition = 300)
```

**For complete interactivity patterns:** [references/interactivity-reference.md](references/interactivity-reference.md)

---

## ggplotly() Conversion

Convert ggplot2 graphics to interactive plotly with `ggplotly()`.

### Basic Conversion

```r
library(ggplot2)
library(plotly)

# Create ggplot
p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
  geom_point(size = 3) +
  theme_minimal()

# Convert to interactive
ggplotly(p)
```

### When to Convert vs Build Natively

**Use ggplotly() when:**
- ✅ Already have ggplot2 plots to make interactive
- ✅ Need quick interactivity layer with minimal effort
- ✅ Prefer ggplot2's grammar for building plots
- ✅ Working with ggplot2 extensions (gganimate not supported, but ggplotly works)

**Use plot_ly() when:**
- ✅ Need custom interactivity (hover templates, click events, animations)
- ✅ Want 3D plots or advanced chart types (sunburst, sankey)
- ✅ Optimizing performance for large datasets
- ✅ Integrating with Shiny (more control with native plotly)
- ✅ Need features not available in ggplot2 (3D, certain map types)

### Customizing Converted Plots

```r
# Convert then customize
p_interactive <- ggplotly(p)

p_interactive |>
  layout(
    title = "Interactive Version",
    hovermode = "x unified"
  ) |>
  config(displaylogo = FALSE)
```

### Limitations

Some ggplot2 features don't convert perfectly:
- Complex annotations may not transfer
- Custom geoms might not have plotly equivalents
- Faceting converts but loses some polish
- Theme elements may not match exactly

**Workaround**: Build core plot in ggplot2, convert, then polish with plotly's layout/config.

---

## Common Patterns

### Grouping and Coloring

**Discrete groups:**
```r
plot_ly(data, x = ~x, y = ~y, color = ~group, colors = "Set1", type = "scatter")
```

**Continuous color scale:**
```r
plot_ly(data, x = ~x, y = ~y, z = ~value, color = ~value,
        type = "scatter", mode = "markers",
        marker = list(colorscale = "Viridis", showscale = TRUE))
```

### Multiple Traces on One Plot

```r
plot_ly(data) |>
  add_trace(x = ~date, y = ~sales, type = "scatter", mode = "lines", name = "Sales") |>
  add_trace(x = ~date, y = ~target, type = "scatter", mode = "lines",
            name = "Target", line = list(dash = "dash"))
```

### Subplots and Faceting

**Shared axes:**
```r
library(plotly)

p1 <- plot_ly(data, x = ~x, y = ~y1, type = "scatter", mode = "lines")
p2 <- plot_ly(data, x = ~x, y = ~y2, type = "scatter", mode = "lines")

subplot(p1, p2, nrows = 2, shareX = TRUE)
```

**Grid layout:**
```r
subplot(
  plot1, plot2, plot3, plot4,
  nrows = 2, margin = 0.05,
  shareX = FALSE, shareY = FALSE
)
```

### Theming

**Built-in templates:**
```r
plot_ly(data, x = ~x, y = ~y) |>
  layout(template = "plotly_dark")  # or "ggplot2", "seaborn", "simple_white"
```

**Custom theme:**
```r
my_theme <- list(
  plot_bgcolor = "#f5f5f5",
  paper_bgcolor = "white",
  font = list(family = "Arial", size = 12),
  xaxis = list(gridcolor = "white"),
  yaxis = list(gridcolor = "white")
)

plot_ly(data, x = ~x, y = ~y) |>
  layout(my_theme)
```

### Handling Dates and Time Series

```r
plot_ly(data, x = ~date_var, y = ~value, type = "scatter", mode = "lines") |>
  layout(
    xaxis = list(
      type = "date",
      tickformat = "%b %Y",
      dtick = "M3"  # Tick every 3 months
    )
  )
```

---

## Shiny Integration Basics

Plotly integrates seamlessly with Shiny for reactive dashboards.

### Basic Integration

**UI:**
```r
library(shiny)
library(plotly)

ui <- fluidPage(
  selectInput("var", "Variable", choices = c("mpg", "hp", "wt")),
  plotlyOutput("plot", height = "500px")
)
```

**Server:**
```r
server <- function(input, output, session) {
  output$plot <- renderPlotly({
    plot_ly(mtcars, x = ~wt, y = ~get(input$var), type = "scatter", mode = "markers") |>
      layout(yaxis = list(title = input$var))
  })
}
```

### Event Handling

**Click events:**
```r
observeEvent(event_data("plotly_click"), {
  d <- event_data("plotly_click")
  showModal(modalDialog(
    title = "Clicked Point",
    paste("X:", d$x, "Y:", d$y)
  ))
})
```

**Selection events:**
```r
observeEvent(event_data("plotly_selected"), {
  selected <- event_data("plotly_selected")
  # Access selected$x, selected$y, selected$curveNumber
  # Filter data based on selection
})
```

**For complete Shiny patterns:** [references/shiny-integration-reference.md](references/shiny-integration-reference.md)

---

## Common Mistakes to Avoid

### 1. Data Format Issues

❌ **Wrong**: Wide format when long format needed
```r
# Won't work for grouped plots
wide_data <- data.frame(x = 1:5, series1 = rnorm(5), series2 = rnorm(5))
plot_ly(wide_data, x = ~x, y = ~series1, color = ~series2)  # Wrong!
```

✅ **Right**: Long format for grouping
```r
library(tidyr)
long_data <- pivot_longer(wide_data, cols = c(series1, series2),
                          names_to = "series", values_to = "value")
plot_ly(long_data, x = ~x, y = ~value, color = ~series)
```

### 2. Trace vs Layout Confusion

❌ **Wrong**: Putting layout properties in trace
```r
plot_ly(x = ~x, y = ~y, title = "My Plot")  # title is layout property!
```

✅ **Right**: Separate traces from layout
```r
plot_ly(x = ~x, y = ~y) |> layout(title = "My Plot")
```

### 3. Performance with Large Data

❌ **Wrong**: Plotting 100k+ points without aggregation
```r
plot_ly(huge_data, x = ~x, y = ~y, type = "scatter", mode = "markers")  # Slow!
```

✅ **Right**: Aggregate or use WebGL
```r
# Option 1: Aggregate
summary_data <- huge_data |> group_by(bin = cut(x, 100)) |> summarize(y = mean(y))
plot_ly(summary_data, x = ~bin, y = ~y)

# Option 2: WebGL for large scatter
plot_ly(huge_data, x = ~x, y = ~y, type = "scattergl", mode = "markers")
```

### 4. Browser Compatibility

Some features require modern browsers:
- WebGL (for large datasets)
- CSS animations
- SVG rendering

**Always test** in target deployment environment.

---

## Resource Navigation

### Reference Documentation (Deep Dives)

- **Chart Types**: [references/chart-types-reference.md](references/chart-types-reference.md) - Complete catalog of all chart types with parameters
- **Layout & Styling**: [references/layout-styling-reference.md](references/layout-styling-reference.md) - Axes, legends, annotations, themes, colors
- **Interactivity**: [references/interactivity-reference.md](references/interactivity-reference.md) - Hover, click, zoom, brush, animation, linking
- **Animation**: [references/animation-reference.md](references/animation-reference.md) - Frame-based animations, controls, advanced patterns
- **Shiny Integration**: [references/shiny-integration-reference.md](references/shiny-integration-reference.md) - Events, proxy, dashboards, performance
- **Best Practices**: [references/best-practices.md](references/best-practices.md) - Design principles, performance, accessibility, export

### Examples (Working Code)

- **Basic Plots Gallery**: [examples/basic-plots-gallery.md](examples/basic-plots-gallery.md) - 30+ complete, runnable examples
- **Interactive Features**: [examples/interactive-features-examples.md](examples/interactive-features-examples.md) - Hover, animation, linking, events
- **Advanced Applications**: [examples/advanced-applications.md](examples/advanced-applications.md) - Financial, geographic, scientific, ML dashboards

### Templates (Copy-Paste Ready)

- **Plot Templates**: [templates/plot-templates.md](templates/plot-templates.md) - 30+ templates with placeholders (DATA, X_VAR, etc.)

### External Resources

- **Primary book**: [Interactive Web-Based Data Visualization with R, plotly, and shiny](https://plotly-r.com/) by Carson Sievert
- **Official docs**: [Plotly R Documentation](https://plotly.com/r/)
- **Gallery**: [Plotly R Figure Reference](https://plotly.com/r/reference/)

---

## Workflow Guidance

When user asks about plotly visualizations:

1. **Understand the goal**: What pattern/relationship to show? What interactivity is needed?
2. **Choose chart type**: Match data structure and analytical goal to appropriate type
3. **Build with three layers**:
   - Traces: Data mapping and chart type
   - Layout: Titles, axes, styling
   - Config: Interaction controls
4. **Add interactivity**: Hover templates, click events, animations as needed
5. **Optimize**: Aggregate large data, use WebGL, restrict tools if needed
6. **Integrate**: Add to Shiny if reactive behavior needed
7. **Test**: Verify interactions work in target environment

Always provide complete, runnable code examples with proper library calls and best practices applied.
