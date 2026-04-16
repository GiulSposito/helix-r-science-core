# r-plotly Skill

Expert interactive data visualization in R using plotly for web-based graphics, animations, Shiny integration, and 3D plots.

## Overview

The **r-plotly** skill provides comprehensive guidance on creating interactive, publication-quality visualizations in R using the plotly package. Unlike static plotting libraries, plotly specializes in web-based, interactive graphics that users can explore through hover, zoom, pan, click, and selection.

### Key Capabilities

- **Interactive plots** with hover tooltips, zoom, pan, and selection
- **Frame-based animations** for temporal narratives
- **3D visualizations** with camera controls
- **Geographic maps** with projections and custom tooltips
- **Shiny integration** with event handling (click, hover, select)
- **Web-ready HTML widgets** for embedding
- **Performance optimization** for large datasets

## When to Use This Skill

This skill activates when you mention:
- `plotly`, `plot_ly()`, `ggplotly()`
- "interactive plot", "interactive visualization", "visualização interativa"
- "animated plot", "animation", "animação"
- "HTML widget", "web graphics"
- "3D plot", "3D surface", "choropleth", "mapbox"
- "plotly shiny", "event_data", "plotlyOutput", "renderPlotly"
- "hover template", "plotly trace", "add_trace"

## Installation

```r
# Install plotly from CRAN
install.packages("plotly")

# For Shiny integration
install.packages("shiny")

# For linked brushing without Shiny
install.packages("crosstalk")

# Load
library(plotly)
```

## Quick Start

### Basic Interactive Plot

```r
library(plotly)

# Simple scatter plot
plot_ly(mtcars, x = ~wt, y = ~mpg, type = "scatter", mode = "markers")

# With color and size aesthetics
plot_ly(mtcars, x = ~wt, y = ~mpg,
        color = ~factor(cyl), size = ~hp,
        type = "scatter", mode = "markers")
```

### Convert ggplot2 to Interactive

```r
library(ggplot2)
library(plotly)

# Create ggplot
p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
  geom_point(size = 3) +
  theme_minimal()

# Make it interactive!
ggplotly(p)
```

### Simple Animation

```r
library(plotly)

# Animated scatter
plot_ly(gapminder::gapminder,
        x = ~gdpPercap, y = ~lifeExp,
        size = ~pop, color = ~continent,
        frame = ~year,
        type = "scatter", mode = "markers") |>
  layout(xaxis = list(type = "log"))
```

## Skill Structure

### Main Skill File

- **[SKILL.md](SKILL.md)** - Core skill with mental model, quick references, and navigation

### Reference Documentation (Deep Dives)

- **[chart-types-reference.md](references/chart-types-reference.md)** - Complete catalog of all chart types (scatter, line, bar, heatmap, 3D, maps, etc.)
- **[layout-styling-reference.md](references/layout-styling-reference.md)** - Axes, legends, annotations, themes, colors, fonts
- **[interactivity-reference.md](references/interactivity-reference.md)** - Hover, click, zoom, brush, modebar, animation, linked views
- **[animation-reference.md](references/animation-reference.md)** - Frame-based animations, controls, advanced patterns
- **[shiny-integration-reference.md](references/shiny-integration-reference.md)** - plotlyOutput, renderPlotly, events, proxy, dashboards
- **[best-practices.md](references/best-practices.md)** - Design principles, performance, accessibility, export

### Examples (Working Code)

- **[basic-plots-gallery.md](examples/basic-plots-gallery.md)** - 30+ complete, runnable examples
- **[interactive-features-examples.md](examples/interactive-features-examples.md)** - Advanced hover, animation, linking, click events
- **[advanced-applications.md](examples/advanced-applications.md)** - Real-world dashboards (financial, geographic, scientific, ML)

### Templates (Copy-Paste Ready)

- **[plot-templates.md](templates/plot-templates.md)** - 30+ templates with placeholders (DATA, X_VAR, etc.)

## Core Concepts

### The Three-Layer Architecture

Every plotly visualization follows this model:

```
Data → Traces (what to draw) → Layout (how it looks) → Config (interactivity)
```

**Example:**

```r
plot_ly(data, x = ~x, y = ~y, type = "scatter") |>  # Trace layer
  layout(title = "My Plot", xaxis = list(title = "X")) |>  # Layout layer
  config(displaylogo = FALSE)  # Config layer
```

### Key Functions

- `plot_ly()` - Initialize plot and add first trace
- `add_trace()` - Add additional layers
- `layout()` - Configure appearance (titles, axes, legends)
- `config()` - Set interactivity options
- `ggplotly()` - Convert ggplot2 to interactive

### When to Use plotly vs ggplot2

**Use plotly when:**
- ✅ Need interactivity (hover, zoom, click)
- ✅ Creating animations or 3D plots
- ✅ Building Shiny dashboards
- ✅ Web deployment (HTML widgets)
- ✅ Exploring data dynamically

**Use ggplot2 when:**
- ✅ Publication-ready static plots
- ✅ Fine-grained aesthetic control
- ✅ Print media
- ✅ Complex statistical transformations

**Use both:**
- ✅ Create plot in ggplot2, convert with `ggplotly()` for quick interactivity

## Common Use Cases

### Exploratory Data Analysis

```r
library(plotly)

# Interactive scatter with hover
plot_ly(iris, x = ~Sepal.Length, y = ~Sepal.Width,
        color = ~Species,
        text = ~paste("Petal Length:", Petal.Length),
        hoverinfo = "text+x+y")
```

### Dashboards (Shiny)

```r
library(shiny)
library(plotly)

ui <- fluidPage(
  plotlyOutput("plot")
)

server <- function(input, output) {
  output$plot <- renderPlotly({
    plot_ly(mtcars, x = ~wt, y = ~mpg, type = "scatter", mode = "markers")
  })
}

shinyApp(ui, server)
```

### Time Series with Range Selector

```r
plot_ly(economics, x = ~date, y = ~unemploy,
        type = "scatter", mode = "lines") |>
  layout(
    xaxis = list(
      rangeslider = list(visible = TRUE),
      rangeselector = list(
        buttons = list(
          list(count = 1, label = "1m", step = "month"),
          list(count = 6, label = "6m", step = "month"),
          list(count = 1, label = "1y", step = "year"),
          list(step = "all", label = "All")
        )
      )
    )
  )
```

### 3D Surface Plot

```r
library(plotly)

# Create surface data
x <- seq(-5, 5, 0.1)
y <- seq(-5, 5, 0.1)
z <- outer(x, y, function(x, y) sin(sqrt(x^2 + y^2)) / sqrt(x^2 + y^2))

plot_ly(z = ~z, type = "surface") |>
  layout(title = "3D Surface Plot")
```

## Learning Path

### Beginner
1. Read [SKILL.md](SKILL.md) - Understand the three-layer model
2. Try [basic-plots-gallery.md](examples/basic-plots-gallery.md) - Run examples
3. Use [plot-templates.md](templates/plot-templates.md) - Copy-paste templates

### Intermediate
4. Study [interactivity-reference.md](references/interactivity-reference.md) - Hover, zoom, events
5. Explore [animation-reference.md](references/animation-reference.md) - Frame-based animations
6. Review [layout-styling-reference.md](references/layout-styling-reference.md) - Professional styling

### Advanced
7. Master [shiny-integration-reference.md](references/shiny-integration-reference.md) - Reactive dashboards
8. Study [advanced-applications.md](examples/advanced-applications.md) - Real-world examples
9. Apply [best-practices.md](references/best-practices.md) - Performance and accessibility

## External Resources

### Primary References
- **[Interactive Web-Based Data Visualization with R, plotly, and shiny](https://plotly-r.com/)** by Carson Sievert - The definitive guide (free online book)
- **[Plotly R Documentation](https://plotly.com/r/)** - Official docs with all chart types
- **[Plotly Figure Reference](https://plotly.com/r/reference/)** - Complete parameter reference

### Key Topics
- Grammar of Graphics: Understand the theoretical foundation
- HTML Widgets: How plotly integrates with R Markdown and Shiny
- JavaScript Interop: Advanced customization with plotly.js

## Features

### Comprehensive Coverage
- **50+ chart types**: Scatter, line, bar, heatmap, 3D, maps, sunburst, sankey, and more
- **Complete interactivity**: Hover, zoom, pan, click, brush, animation
- **Shiny integration**: Full event handling and reactive patterns
- **Performance tips**: WebGL, data aggregation, caching strategies
- **Accessibility**: Colorblind-safe palettes, screen reader support

### Production-Ready
- **100+ code examples**: All complete and runnable
- **30+ templates**: Copy-paste with placeholders
- **Best practices**: Design, performance, export, sharing
- **Real-world applications**: Financial, geographic, scientific, ML dashboards

### Well-Organized
- **Clear navigation**: TOC in every file
- **Progressive learning**: Beginner → intermediate → advanced
- **Cross-referenced**: Links between related topics
- **Code-focused**: Practical examples over theory

## Related Skills

- **ggplot2** - For static plot design principles and ggplotly() conversion
- **r-shiny** - For general Shiny reactive programming concepts
- **r-datascience** - For data preparation before visualization
- **r-tidymodels** - For visualizing model results

## Troubleshooting

### Plot not showing
```r
# Make sure to print the plot
p <- plot_ly(data, x = ~x, y = ~y)
p  # Or print(p)
```

### Large dataset performance
```r
# Use WebGL for scatter plots
plot_ly(big_data, x = ~x, y = ~y, type = "scattergl")

# Or aggregate data first
summary_data <- data |> group_by(bin) |> summarize(y = mean(y))
plot_ly(summary_data, x = ~bin, y = ~y)
```

### Shiny event not firing
```r
# Make sure to use 'source' parameter
plotlyOutput("plot")
renderPlotly({ plot_ly(..., source = "myplot") })
event_data("plotly_click", source = "myplot")
```

## Contributing

This skill is part of the Claude Code skills repository. For issues or improvements, refer to the main repository guidelines.

## Version

- **Version**: 1.0.0
- **Last Updated**: March 2026
- **Skill Author**: Generated with skillMaker following Claude Code best practices

---

## Quick Reference Card

**Basic Plot:**
```r
plot_ly(data, x = ~x, y = ~y, type = "scatter", mode = "markers")
```

**With Aesthetics:**
```r
plot_ly(data, x = ~x, y = ~y, color = ~group, size = ~value)
```

**Add Layers:**
```r
plot_ly(data) |>
  add_trace(y = ~y1, name = "Series 1") |>
  add_trace(y = ~y2, name = "Series 2")
```

**Style:**
```r
p |> layout(title = "My Plot", xaxis = list(title = "X"))
```

**Animation:**
```r
plot_ly(data, x = ~x, y = ~y, frame = ~time) |>
  animation_opts(frame = 500)
```

**Shiny:**
```r
# UI
plotlyOutput("plot")

# Server
output$plot <- renderPlotly({ plot_ly(...) })

# Events
observeEvent(event_data("plotly_click"), { ... })
```

**Convert ggplot2:**
```r
ggplotly(ggplot_object)
```

---

Happy plotting! 🎨📊✨
