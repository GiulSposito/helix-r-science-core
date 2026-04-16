# Plotly Interactivity Reference

Comprehensive guide to all interactive features in plotly for R - hover, click, zoom, brush, animations, and linked views.

## Table of Contents

- [Understanding Interactivity](#understanding-interactivity)
- [Hover Information](#hover-information)
- [Click Events](#click-events)
- [Zoom and Pan](#zoom-and-pan)
- [Brush and Select](#brush-and-select)
- [Modebar Configuration](#modebar-configuration)
- [Animation](#animation)
- [Linked Brushing](#linked-brushing)

---

## Understanding Interactivity

Plotly provides two types of interactivity:

### Client-Side Interactivity (No Server)

**Runs entirely in the browser** - instant feedback, no network latency.

**Capabilities:**
- Hover tooltips
- Zoom and pan
- Click to highlight
- Legend filtering
- Modebar tools
- Basic animations
- Linked brushing via crosstalk

**Use when:**
- Creating standalone HTML visualizations
- Need instant response
- No complex logic required
- Static dashboards

### Server-Side Interactivity (Shiny)

**Runs in R on server** - full R capabilities, requires Shiny.

**Capabilities:**
- All client-side features
- Click/hover/select event handling
- Dynamic data filtering
- Complex calculations
- Database queries
- Multi-plot coordination with R logic

**Use when:**
- Need reactive R computations
- Complex filtering/aggregation
- Real-time data updates
- User authentication
- Database integration

### Default Interactions

Every plotly plot has these interactions enabled by default:

```r
library(plotly)

plot_ly(mtcars, x = ~wt, y = ~mpg, type = "scatter", mode = "markers")

# Default interactions available:
# - Hover: shows data values
# - Zoom: drag to zoom, double-click to reset
# - Pan: shift+drag to pan
# - Modebar: download, zoom, pan, select tools
```

---

## Hover Information

### Default Hover Behavior

By default, plotly shows x, y, and trace name on hover.

```r
plot_ly(iris, x = ~Sepal.Length, y = ~Sepal.Width, color = ~Species,
        type = "scatter", mode = "markers")
# Hover shows: Species name, Sepal.Length value, Sepal.Width value
```

### hoverinfo Parameter

Control what information appears in hover tooltips.

**Options:** `"x"`, `"y"`, `"z"`, `"text"`, `"name"`, `"all"`, `"none"`, `"skip"`

```r
# Show only y values
plot_ly(mtcars, x = ~wt, y = ~mpg, type = "scatter", mode = "markers",
        hoverinfo = "y")

# Show x and text
plot_ly(mtcars, x = ~wt, y = ~mpg, text = ~rownames(mtcars),
        type = "scatter", mode = "markers",
        hoverinfo = "x+text")

# Combine multiple
plot_ly(mtcars, x = ~wt, y = ~mpg, text = ~paste("HP:", hp),
        type = "scatter", mode = "markers",
        hoverinfo = "x+y+text+name", name = "Cars")

# Disable hover
plot_ly(mtcars, x = ~wt, y = ~mpg, type = "scatter", mode = "markers",
        hoverinfo = "none")
```

### hovertext vs text

**Key distinction:**

- `text`: Shows on plot AND in hover (if hoverinfo includes "text")
- `hovertext`: Shows ONLY in hover, not on plot

```r
# text shows on plot
plot_ly(mtcars, x = ~wt, y = ~mpg, text = ~rownames(mtcars),
        type = "scatter", mode = "markers+text")

# hovertext only in hover
plot_ly(mtcars, x = ~wt, y = ~mpg,
        hovertext = ~paste("Car:", rownames(mtcars), "<br>HP:", hp),
        type = "scatter", mode = "markers")
```

### hovertemplate - Formatted Tooltips

**Most powerful option** - custom HTML formatting with variables.

**Template variables:**
- `%{x}`: x-axis value
- `%{y}`: y-axis value
- `%{z}`: z-axis value (3D plots)
- `%{text}`: text aesthetic value
- `%{customdata}`: custom data array
- `<extra></extra>`: Controls secondary hover box

**Formatting:**
- `%{y:.2f}`: 2 decimal places
- `%{x:.0%}`: Percentage
- `%{y:,.0f}`: Thousands separator
- `%{x|%b %Y}`: Date formatting

```r
# Basic template
plot_ly(mtcars, x = ~wt, y = ~mpg,
        type = "scatter", mode = "markers",
        hovertemplate = "Weight: %{x:.2f}<br>MPG: %{y:.1f}<extra></extra>")

# Rich formatting with text
plot_ly(mtcars, x = ~wt, y = ~mpg, text = ~rownames(mtcars),
        type = "scatter", mode = "markers",
        hovertemplate = paste(
          "<b>%{text}</b><br>",
          "Weight: %{x:.2f} tons<br>",
          "Efficiency: %{y:.1f} mpg<br>",
          "<extra></extra>"
        ))

# With custom data
plot_ly(mtcars, x = ~wt, y = ~mpg,
        customdata = ~hp,
        type = "scatter", mode = "markers",
        hovertemplate = paste(
          "MPG: %{y}<br>",
          "Weight: %{x} lbs<br>",
          "Horsepower: %{customdata}<br>",
          "<extra></extra>"
        ))

# Conditional formatting with customdata array
data <- mtcars |>
  mutate(label = paste0(rownames(mtcars), " (", cyl, " cyl)"),
         details = paste("HP:", hp, "| Gears:", gear))

plot_ly(data, x = ~wt, y = ~mpg,
        text = ~label,
        customdata = ~details,
        type = "scatter", mode = "markers",
        hovertemplate = paste(
          "<b>%{text}</b><br>",
          "%{customdata}<br>",
          "Efficiency: %{y:.1f} mpg<br>",
          "<extra></extra>"
        ))
```

### hoverlabel Styling

Customize hover tooltip appearance.

```r
plot_ly(mtcars, x = ~wt, y = ~mpg, type = "scatter", mode = "markers",
        hoverlabel = list(
          bgcolor = "white",
          bordercolor = "black",
          font = list(family = "Arial", size = 14, color = "black")
        ))

# Per-trace styling
plot_ly(iris, x = ~Sepal.Length, y = ~Sepal.Width, color = ~Species,
        type = "scatter", mode = "markers") |>
  style(hoverlabel = list(bgcolor = "lightyellow"), traces = 1) |>
  style(hoverlabel = list(bgcolor = "lightblue"), traces = 2)
```

### hovermode - Global Hover Behavior

Control how hover activates across the plot.

```r
# Default: closest point
plot_ly(data, x = ~x, y = ~y) |>
  layout(hovermode = "closest")

# Show all points at same x value
plot_ly(data, x = ~date, y = ~value, color = ~series,
        type = "scatter", mode = "lines") |>
  layout(hovermode = "x")

# Show all points at same y value
plot_ly(data, x = ~value, y = ~category,
        type = "scatter", mode = "markers") |>
  layout(hovermode = "y")

# X unified: single hover box for all traces at x
plot_ly(data, x = ~date, y = ~value, color = ~series,
        type = "scatter", mode = "lines") |>
  layout(hovermode = "x unified")

# Disable hover
plot_ly(data, x = ~x, y = ~y) |>
  layout(hovermode = FALSE)
```

### Complete Hover Example

```r
library(plotly)
library(dplyr)

# Rich hover with multiple data dimensions
mtcars |>
  mutate(car = rownames(mtcars),
         efficiency = case_when(
           mpg >= 25 ~ "High",
           mpg >= 20 ~ "Medium",
           TRUE ~ "Low"
         )) |>
  plot_ly(x = ~wt, y = ~mpg, color = ~factor(cyl),
          size = ~hp, sizes = c(10, 50),
          text = ~car,
          customdata = ~cbind(hp, gear, efficiency),
          type = "scatter", mode = "markers",
          hovertemplate = paste(
            "<b>%{text}</b><br><br>",
            "Weight: %{x:.2f} tons<br>",
            "MPG: %{y:.1f}<br>",
            "Horsepower: %{customdata[0]}<br>",
            "Gears: %{customdata[1]}<br>",
            "Efficiency: %{customdata[2]}<br>",
            "<extra></extra>"
          )) |>
  layout(
    title = "Car Performance Analysis",
    hovermode = "closest",
    hoverlabel = list(
      bgcolor = "white",
      bordercolor = "#333",
      font = list(family = "Arial", size = 12)
    )
  )
```

---

## Click Events

**Note:** Click events require Shiny for server-side handling.

### Click Data Structure

When a point is clicked, `event_data("plotly_click")` returns:

```r
# Structure:
# $curveNumber: Trace index (0-based)
# $pointNumber: Point index within trace
# $x, $y, $z: Clicked coordinates
# $customdata: Custom data if provided
```

### Basic Click Handler (Shiny)

```r
library(shiny)
library(plotly)

ui <- fluidPage(
  plotlyOutput("plot"),
  verbatimTextOutput("click_info")
)

server <- function(input, output, session) {
  output$plot <- renderPlotly({
    plot_ly(mtcars, x = ~wt, y = ~mpg, text = ~rownames(mtcars),
            type = "scatter", mode = "markers",
            source = "main_plot")  # Named source for event tracking
  })

  output$click_info <- renderPrint({
    clicked <- event_data("plotly_click", source = "main_plot")
    if (is.null(clicked)) {
      "Click a point"
    } else {
      list(
        Point = clicked$pointNumber + 1,
        X = clicked$x,
        Y = clicked$y,
        Trace = clicked$curveNumber + 1
      )
    }
  })
}

shinyApp(ui, server)
```

### Click to Filter (Shiny)

```r
ui <- fluidPage(
  plotlyOutput("scatter"),
  plotlyOutput("filtered_data")
)

server <- function(input, output, session) {
  output$scatter <- renderPlotly({
    plot_ly(iris, x = ~Sepal.Length, y = ~Sepal.Width,
            color = ~Species, type = "scatter", mode = "markers",
            source = "scatter")
  })

  output$filtered_data <- renderPlotly({
    clicked <- event_data("plotly_click", source = "scatter")

    if (is.null(clicked)) {
      data <- iris
    } else {
      # Filter to clicked species
      species_clicked <- iris$Species[clicked$pointNumber + 1]
      data <- iris |> filter(Species == species_clicked)
    }

    plot_ly(data, x = ~Petal.Length, y = ~Petal.Width,
            type = "scatter", mode = "markers")
  })
}

shinyApp(ui, server)
```

### Multi-Select with customdata

```r
server <- function(input, output, session) {
  selected_cars <- reactiveVal(character(0))

  output$plot <- renderPlotly({
    plot_ly(mtcars, x = ~wt, y = ~mpg,
            customdata = ~rownames(mtcars),
            type = "scatter", mode = "markers",
            source = "cars")
  })

  observeEvent(event_data("plotly_click", source = "cars"), {
    clicked <- event_data("plotly_click", source = "cars")
    car <- clicked$customdata

    current <- selected_cars()
    if (car %in% current) {
      selected_cars(setdiff(current, car))  # Deselect
    } else {
      selected_cars(c(current, car))  # Add to selection
    }
  })

  output$selected <- renderPrint({
    selected_cars()
  })
}
```

---

## Zoom and Pan

### Default Zoom/Pan Behavior

```r
# Default: drag to zoom, double-click to reset
plot_ly(mtcars, x = ~wt, y = ~mpg, type = "scatter", mode = "markers")

# Shift+drag to pan
# Scroll to zoom (if enabled)
```

### Constraining Zoom

```r
# Fix x-axis, allow y-axis zoom
plot_ly(data, x = ~date, y = ~value, type = "scatter", mode = "lines") |>
  layout(
    xaxis = list(fixedrange = TRUE),
    yaxis = list(fixedrange = FALSE)
  )

# Set explicit ranges
plot_ly(data, x = ~x, y = ~y) |>
  layout(
    xaxis = list(range = c(0, 10)),
    yaxis = list(range = c(0, 100))
  )
```

### Range Sliders (Time Series)

```r
# Add range slider below plot
plot_ly(data, x = ~date, y = ~value, type = "scatter", mode = "lines") |>
  layout(
    xaxis = list(
      rangeslider = list(visible = TRUE),
      type = "date"
    )
  )

# Custom range slider styling
plot_ly(data, x = ~date, y = ~value, type = "scatter", mode = "lines") |>
  layout(
    xaxis = list(
      rangeslider = list(
        visible = TRUE,
        thickness = 0.1,
        bgcolor = "#f0f0f0",
        bordercolor = "#ccc",
        borderwidth = 1
      ),
      type = "date"
    )
  )
```

### Zoom Events (Shiny)

```r
server <- function(input, output, session) {
  output$plot <- renderPlotly({
    plot_ly(mtcars, x = ~wt, y = ~mpg, type = "scatter", mode = "markers",
            source = "zoom_plot")
  })

  output$zoom_info <- renderPrint({
    relayout <- event_data("plotly_relayout", source = "zoom_plot")
    if (!is.null(relayout)) {
      list(
        xrange = c(relayout$`xaxis.range[0]`, relayout$`xaxis.range[1]`),
        yrange = c(relayout$`yaxis.range[0]`, relayout$`yaxis.range[1]`)
      )
    }
  })
}
```

### Programmatic Zoom

```r
# Create plot with initial range
p <- plot_ly(mtcars, x = ~wt, y = ~mpg, type = "scatter", mode = "markers") |>
  layout(
    xaxis = list(range = c(2, 4)),
    yaxis = list(range = c(15, 25))
  )

# In Shiny, update zoom via plotlyProxy
observeEvent(input$zoom_btn, {
  plotlyProxy("plot", session) |>
    plotlyProxyInvoke("relayout", list(
      "xaxis.range" = c(3, 5),
      "yaxis.range" = c(20, 30)
    ))
})
```

---

## Brush and Select

### Box Select Mode

```r
# Enable box select (default)
plot_ly(iris, x = ~Sepal.Length, y = ~Sepal.Width,
        type = "scatter", mode = "markers") |>
  layout(dragmode = "select")  # Box select
```

### Lasso Select Mode

```r
# Enable lasso select
plot_ly(iris, x = ~Sepal.Length, y = ~Sepal.Width,
        type = "scatter", mode = "markers") |>
  layout(dragmode = "lasso")
```

### Selection Styling

```r
# Custom selected/unselected styling
plot_ly(iris, x = ~Sepal.Length, y = ~Sepal.Width,
        type = "scatter", mode = "markers",
        marker = list(size = 10),
        selected = list(marker = list(color = "red", size = 15)),
        unselected = list(marker = list(opacity = 0.3)))
```

### Selection Events (Shiny)

```r
server <- function(input, output, session) {
  output$plot <- renderPlotly({
    plot_ly(iris, x = ~Sepal.Length, y = ~Sepal.Width,
            color = ~Species, type = "scatter", mode = "markers",
            source = "select_plot") |>
      layout(dragmode = "lasso")
  })

  output$selection_info <- renderPrint({
    selected <- event_data("plotly_selected", source = "select_plot")
    if (is.null(selected)) {
      "No selection"
    } else {
      paste("Selected", nrow(selected), "points")
    }
  })

  output$selected_table <- renderTable({
    selected <- event_data("plotly_selected", source = "select_plot")
    if (!is.null(selected)) {
      iris[selected$pointNumber + 1, ]
    }
  })
}
```

---

## Modebar Configuration

### Built-in Buttons

Reference of all modebar buttons:

**2D Drawing:**
- `"drawline"`, `"drawopenpath"`, `"drawclosedpath"`, `"drawcircle"`, `"drawrect"`, `"eraseshape"`

**Zoom/Pan:**
- `"zoom2d"`, `"pan2d"`, `"zoomIn2d"`, `"zoomOut2d"`, `"autoScale2d"`, `"resetScale2d"`

**3D:**
- `"zoom3d"`, `"pan3d"`, `"orbitRotation"`, `"tableRotation"`, `"resetCameraDefault3d"`, `"resetCameraLastSave3d"`

**Selection:**
- `"select2d"`, `"lasso2d"`

**Export:**
- `"toImage"`, `"sendDataToCloud"`

**Other:**
- `"hoverClosestCartesian"`, `"hoverCompareCartesian"`, `"toggleSpikelines"`, `"resetViewMapbox"`

### Removing Buttons

```r
# Remove specific buttons
plot_ly(data, x = ~x, y = ~y) |>
  config(modeBarButtonsToRemove = c("pan2d", "lasso2d", "select2d"))

# Minimal modebar
plot_ly(data, x = ~x, y = ~y) |>
  config(
    modeBarButtonsToRemove = c("pan2d", "select2d", "lasso2d",
                                "zoomIn2d", "zoomOut2d", "autoScale2d"),
    displaylogo = FALSE
  )
```

### Adding Custom Buttons

```r
# Add drawing tools
plot_ly(data, x = ~x, y = ~y) |>
  config(
    modeBarButtonsToAdd = c("drawline", "drawopenpath", "drawclosedpath",
                             "drawcircle", "drawrect", "eraseshape")
  )
```

### Download Plot Options

```r
plot_ly(data, x = ~x, y = ~y) |>
  config(
    toImageButtonOptions = list(
      format = "png",      # or "svg", "jpeg", "webp"
      filename = "my_plot",
      width = 1200,
      height = 800,
      scale = 2            # Resolution multiplier
    )
  )
```

### Hiding Modebar

```r
# Hide completely
plot_ly(data, x = ~x, y = ~y) |>
  config(displayModeBar = FALSE)

# Show only on hover
plot_ly(data, x = ~x, y = ~y) |>
  config(displayModeBar = "hover")
```

### Logo Removal

```r
plot_ly(data, x = ~x, y = ~y) |>
  config(displaylogo = FALSE)
```

### Complete Config Example

```r
plot_ly(mtcars, x = ~wt, y = ~mpg, type = "scatter", mode = "markers") |>
  config(
    displayModeBar = TRUE,
    displaylogo = FALSE,
    modeBarButtonsToRemove = c("pan2d", "lasso2d"),
    modeBarButtonsToAdd = c("drawline", "eraseshape"),
    toImageButtonOptions = list(
      format = "png",
      filename = "car_analysis",
      width = 1600,
      height = 900,
      scale = 2
    ),
    scrollZoom = FALSE,      # Disable scroll-to-zoom
    responsive = TRUE        # Auto-resize on window change
  )
```

---

## Animation

### Frame-Based Animation

Plotly animations work by defining **frames** - discrete states of the visualization.

```r
# Basic animation
plot_ly(gapminder::gapminder,
        x = ~gdpPercap, y = ~lifeExp, size = ~pop,
        color = ~continent, frame = ~year,
        text = ~country, type = "scatter", mode = "markers") |>
  layout(xaxis = list(type = "log"))
```

### animation_opts()

Control animation timing and behavior.

```r
plot_ly(data, x = ~x, y = ~y, frame = ~time) |>
  animation_opts(
    frame = 500,          # Frame duration (ms)
    transition = 300,     # Transition duration (ms)
    redraw = FALSE,       # Full redraw vs smooth transition
    easing = "elastic"    # Easing function
  )
```

**Easing options:** `"linear"`, `"quad"`, `"cubic"`, `"sin"`, `"exp"`, `"circle"`, `"elastic"`, `"back"`, `"bounce"`

### animation_button()

Customize play/pause button.

```r
plot_ly(data, x = ~x, y = ~y, frame = ~time) |>
  animation_button(
    x = 1, xanchor = "right",
    y = 0, yanchor = "bottom"
  )
```

### animation_slider()

Customize frame slider.

```r
plot_ly(data, x = ~x, y = ~y, frame = ~time) |>
  animation_slider(
    currentvalue = list(
      prefix = "Year: ",
      font = list(color = "red")
    )
  )
```

### Time Series Animation

```r
library(dplyr)
library(plotly)

# Generate time series data
data <- expand.grid(
  time = 1:50,
  series = c("A", "B", "C")
) |>
  mutate(value = sin(time / 5 + as.numeric(as.factor(series))) +
                  rnorm(n(), 0, 0.1))

plot_ly(data, x = ~time, y = ~value, color = ~series,
        frame = ~time, type = "scatter", mode = "lines+markers") |>
  animation_opts(frame = 100, transition = 50, redraw = FALSE) |>
  animation_slider(currentvalue = list(prefix = "Time: ")) |>
  layout(title = "Animated Time Series")
```

### Racing Bar Chart

```r
library(dplyr)
library(plotly)

# Sample data - country populations over years
data <- data.frame(
  year = rep(2000:2020, each = 5),
  country = rep(c("USA", "China", "India", "Brazil", "Russia"), 21)
) |>
  mutate(population = case_when(
    country == "USA" ~ 280 + (year - 2000) * 2,
    country == "China" ~ 1200 + (year - 2000) * 10,
    country == "India" ~ 1000 + (year - 2000) * 15,
    country == "Brazil" ~ 170 + (year - 2000) * 3,
    country == "Russia" ~ 140 + (year - 2000) * 0.5
  ))

plot_ly(data, x = ~population, y = ~reorder(country, population),
        frame = ~year, type = "bar", orientation = "h") |>
  animation_opts(frame = 300, transition = 200, redraw = FALSE) |>
  layout(
    title = "Population Race",
    xaxis = list(title = "Population (millions)"),
    yaxis = list(title = "")
  )
```

### Scatter with Trails

```r
# Show path with fading trail
library(dplyr)

# Generate trajectory data
trajectory <- data.frame(
  time = 1:100
) |>
  mutate(
    x = cos(time / 10) * time / 20,
    y = sin(time / 10) * time / 20
  )

# Create cumulative frames
frames_list <- lapply(1:nrow(trajectory), function(i) {
  trail_length <- 20
  start_idx <- max(1, i - trail_length)

  data.frame(
    x = trajectory$x[start_idx:i],
    y = trajectory$y[start_idx:i],
    opacity = seq(0.3, 1, length.out = i - start_idx + 1)
  )
})

# Plotly animation setup requires more complex frame handling
# Use cumulative traces approach instead
plot_ly() |>
  add_trace(x = trajectory$x, y = trajectory$y,
            frame = ~time, type = "scatter", mode = "lines+markers",
            line = list(width = 2),
            marker = list(size = 10))
```

---

## Linked Brushing

### Using crosstalk Package

**crosstalk** enables client-side linking between plots without Shiny.

```r
library(plotly)
library(crosstalk)

# Create shared data
shared_iris <- SharedData$new(iris)

# Two plots sharing selection
p1 <- plot_ly(shared_iris, x = ~Sepal.Length, y = ~Sepal.Width,
              type = "scatter", mode = "markers")

p2 <- plot_ly(shared_iris, x = ~Petal.Length, y = ~Petal.Width,
              type = "scatter", mode = "markers")

subplot(p1, p2, nrows = 2)
# Selecting in one plot highlights in the other!
```

### highlight_key() for Grouped Data

```r
library(crosstalk)
library(plotly)

# Add key for linking
iris_key <- highlight_key(iris, ~Species)

p1 <- plot_ly(iris_key, x = ~Sepal.Length, y = ~Sepal.Width,
              color = ~Species, type = "scatter", mode = "markers")

p2 <- plot_ly(iris_key, x = ~Petal.Length, y = ~Petal.Width,
              color = ~Species, type = "scatter", mode = "markers")

subplot(p1, p2, nrows = 1, shareX = FALSE, shareY = FALSE)
```

### Click-to-Filter (No Shiny)

```r
library(crosstalk)
library(plotly)

shared <- SharedData$new(mtcars, ~cyl)

plot_ly(shared, x = ~wt, y = ~mpg, color = ~factor(cyl),
        type = "scatter", mode = "markers") |>
  layout(title = "Click legend to filter")
# Clicking legend filters data!
```

### Brush-to-Filter Dashboard

```r
library(crosstalk)
library(plotly)

# Shared data
shared_iris <- SharedData$new(iris)

# Main scatter
p1 <- plot_ly(shared_iris, x = ~Sepal.Length, y = ~Sepal.Width,
              color = ~Species, type = "scatter", mode = "markers") |>
  layout(title = "Brush to filter other plots")

# Histogram responds to brush
p2 <- plot_ly(shared_iris, x = ~Petal.Length, type = "histogram")

# Box plot responds to brush
p3 <- plot_ly(shared_iris, y = ~Petal.Width, color = ~Species,
              type = "box")

subplot(
  subplot(p2, p3, nrows = 1),
  p1,
  nrows = 2, heights = c(0.3, 0.7)
) |>
  layout(dragmode = "select")  # Enable brushing
```

### Complex Multi-Plot Dashboard

```r
library(crosstalk)
library(plotly)
library(dplyr)

# Prepare data with key
mtcars_shared <- mtcars |>
  mutate(car = rownames(mtcars)) |>
  SharedData$new(~car)

# Scatter: mpg vs weight
p1 <- plot_ly(mtcars_shared, x = ~wt, y = ~mpg,
              color = ~factor(cyl), size = ~hp,
              text = ~car, type = "scatter", mode = "markers") |>
  layout(title = "Efficiency vs Weight", dragmode = "select")

# Bar: average by cylinders
p2 <- mtcars_shared$data() |>
  group_by(cyl) |>
  summarize(avg_mpg = mean(mpg)) |>
  plot_ly(x = ~factor(cyl), y = ~avg_mpg, type = "bar") |>
  layout(title = "Average MPG by Cylinders")

# Histogram: distribution
p3 <- plot_ly(mtcars_shared, x = ~hp, type = "histogram") |>
  layout(title = "Horsepower Distribution")

subplot(
  p1,
  subplot(p2, p3, nrows = 1, shareX = FALSE),
  nrows = 2, heights = c(0.6, 0.4)
)
```

---

## Performance Considerations

### Hover Performance

```r
# For large datasets, limit hover complexity
plot_ly(large_data, x = ~x, y = ~y, type = "scattergl",  # Use WebGL
        hoverinfo = "x+y")  # Minimal hover info
```

### Animation Performance

```r
# Limit frame count for smooth animation
# 50-100 frames is usually sufficient

# Aggregate data if too many points per frame
data_agg <- data |>
  group_by(time, category) |>
  summarize(value = mean(value))

plot_ly(data_agg, x = ~x, y = ~value, frame = ~time)
```

### Selection Performance

```r
# For very large datasets, use crosstalk with caution
# Consider server-side filtering with Shiny instead

# Or aggregate before plotting
data_summary <- data |>
  group_by(category) |>
  sample_n(1000)  # Sample per group

SharedData$new(data_summary)
```

---

## Summary

Plotly interactivity enables:
- **Hover**: Rich tooltips with custom formatting
- **Click**: Point selection and event handling (Shiny)
- **Zoom/Pan**: Intuitive navigation with constraints
- **Brush/Select**: Multi-point selection with styling
- **Modebar**: Customizable toolbar with tools
- **Animation**: Frame-based transitions for temporal data
- **Linking**: Multi-plot coordination (crosstalk/Shiny)

**Choose the right approach:**
- **Client-side** (crosstalk): Fast, standalone HTML, limited logic
- **Server-side** (Shiny): Full R power, reactive, database integration

For Shiny integration patterns, see [shiny-integration-reference.md](shiny-integration-reference.md).

For complete interactive examples, see [examples/interactive-features-examples.md](../examples/interactive-features-examples.md).
