# Interactive Features Examples

Advanced interactive plotly examples demonstrating hover customization, animations, linked brushing, click events, and custom controls.

## Table of Contents

- [Custom Hover Templates](#custom-hover-templates)
- [Animation Examples](#animation-examples)
- [Linked Brushing Examples](#linked-brushing-examples)
- [Click Events in Shiny](#click-events-in-shiny)
- [Custom Interactions](#custom-interactions)

---

## Custom Hover Templates

### Rich Formatting with HTML

```r
library(plotly)
library(dplyr)

# Rich hover with multiple formatting
mtcars |>
  mutate(car = rownames(mtcars)) |>
  plot_ly(x = ~wt, y = ~mpg, color = ~factor(cyl),
          size = ~hp, sizes = c(10, 50),
          text = ~car,
          customdata = ~cbind(hp, gear, qsec),
          type = "scatter", mode = "markers",
          hovertemplate = paste(
            "<b style='font-size:14px'>%{text}</b><br>",
            "<i>Performance Metrics</i><br>",
            "━━━━━━━━━━━━━━━━━<br>",
            "Weight: <b>%{x:.2f}</b> tons<br>",
            "MPG: <b>%{y:.1f}</b><br>",
            "Horsepower: <b>%{customdata[0]}</b><br>",
            "Gears: <b>%{customdata[1]}</b><br>",
            "Quarter Mile: <b>%{customdata[2]:.2f}</b> sec<br>",
            "<extra></extra>"
          )) |>
  layout(
    title = "Vehicle Performance Analysis",
    hoverlabel = list(
      bgcolor = "white",
      bordercolor = "#333",
      font = list(family = "Arial", size = 12)
    )
  )
```

### Conditional Hover Formatting

```r
library(plotly)

# Different hover based on condition
data <- data.frame(
  x = 1:50,
  y = rnorm(50, 100, 15)
) |>
  mutate(
    status = ifelse(y > 100, "Above Average", "Below Average"),
    color_val = ifelse(y > 100, "green", "red")
  )

plot_ly(data, x = ~x, y = ~y,
        color = ~status,
        colors = c("red", "green"),
        type = "scatter", mode = "markers",
        marker = list(size = 10),
        hovertemplate = paste(
          "<b>Day %{x}</b><br>",
          "Value: %{y:.1f}<br>",
          "Status: %{customdata}<br>",
          "<extra></extra>"
        ),
        customdata = ~status) |>
  layout(title = "Performance Tracking with Status")
```

### Multi-Variable Hover with Formatted Numbers

```r
library(plotly)

# Financial data with formatted numbers
stocks <- data.frame(
  date = seq.Date(as.Date("2023-01-01"), by = "month", length.out = 24),
  price = cumsum(rnorm(24, 5, 20)) + 1000,
  volume = sample(1e6:5e6, 24)
) |>
  mutate(
    change = c(0, diff(price)),
    pct_change = c(0, diff(price) / head(price, -1) * 100)
  )

plot_ly(stocks, x = ~date, y = ~price,
        type = "scatter", mode = "lines+markers",
        customdata = ~cbind(volume, change, pct_change),
        hovertemplate = paste(
          "<b>%{x|%B %d, %Y}</b><br>",
          "Price: $%{y:,.2f}<br>",
          "Volume: %{customdata[0]:,.0f}<br>",
          "Change: $%{customdata[1]:.2f} (%{customdata[2]:+.2f}%)<br>",
          "<extra></extra>"
        ),
        line = list(color = "steelblue", width = 2),
        marker = list(size = 8)) |>
  layout(
    title = "Stock Price with Rich Hover Info",
    xaxis = list(title = "Date"),
    yaxis = list(title = "Price ($)")
  )
```

### Category-Specific Hover Templates

```r
library(plotly)
library(dplyr)

# Different hover per category
iris |>
  plot_ly(x = ~Sepal.Length, y = ~Sepal.Width,
          color = ~Species,
          type = "scatter", mode = "markers",
          marker = list(size = 10),
          transforms = list(
            list(
              type = "groupby",
              groups = ~Species
            )
          )) |>
  style(
    hovertemplate = "<b>Setosa</b><br>Sepal: %{x} x %{y}<extra></extra>",
    traces = 1
  ) |>
  style(
    hovertemplate = "<b>Versicolor</b><br>Sepal: %{x} x %{y}<extra></extra>",
    traces = 2
  ) |>
  style(
    hovertemplate = "<b>Virginica</b><br>Sepal: %{x} x %{y}<extra></extra>",
    traces = 3
  )
```

---

## Animation Examples

### Time Series Build-Up Animation

```r
library(plotly)
library(dplyr)

# Generate time series data
ts_data <- data.frame(
  time = 1:100
) |>
  mutate(
    series_a = cumsum(rnorm(100, 0, 1)),
    series_b = cumsum(rnorm(100, 0.5, 1.2)),
    series_c = cumsum(rnorm(100, -0.2, 0.8))
  ) |>
  tidyr::pivot_longer(cols = starts_with("series"),
                      names_to = "series",
                      values_to = "value")

# Animated line build-up
plot_ly(ts_data, x = ~time, y = ~value,
        color = ~series,
        frame = ~time,
        type = "scatter", mode = "lines",
        line = list(width = 3)) |>
  animation_opts(
    frame = 50,
    transition = 0,
    redraw = FALSE
  ) |>
  animation_slider(
    currentvalue = list(
      prefix = "Time: ",
      font = list(color = "red", size = 16)
    )
  ) |>
  layout(
    title = "Time Series Build-Up Animation",
    xaxis = list(title = "Time", range = c(0, 100)),
    yaxis = list(title = "Value")
  )
```

### Racing Bar Chart with Companies

```r
library(plotly)
library(dplyr)

# Generate racing bar data
companies <- c("Apple", "Microsoft", "Amazon", "Google", "Meta")
years <- 2015:2023

racing_data <- expand.grid(
  year = years,
  company = companies,
  stringsAsFactors = FALSE
) |>
  mutate(
    revenue = case_when(
      company == "Apple" ~ 200 + (year - 2015) * 25 + rnorm(n(), 0, 10),
      company == "Microsoft" ~ 100 + (year - 2015) * 30 + rnorm(n(), 0, 8),
      company == "Amazon" ~ 150 + (year - 2015) * 35 + rnorm(n(), 0, 12),
      company == "Google" ~ 120 + (year - 2015) * 28 + rnorm(n(), 0, 9),
      company == "Meta" ~ 80 + (year - 2015) * 20 + rnorm(n(), 0, 7)
    )
  ) |>
  group_by(year) |>
  arrange(year, desc(revenue)) |>
  mutate(rank = row_number()) |>
  ungroup()

plot_ly(racing_data,
        x = ~revenue,
        y = ~reorder(company, revenue),
        frame = ~year,
        type = "bar",
        orientation = "h",
        text = ~paste0("$", round(revenue, 1), "B"),
        textposition = "outside",
        marker = list(
          color = ~revenue,
          colorscale = "Viridis",
          showscale = FALSE
        )) |>
  animation_opts(
    frame = 500,
    transition = 300,
    redraw = FALSE
  ) |>
  animation_button(
    x = 1, xanchor = "right",
    y = 0, yanchor = "bottom"
  ) |>
  animation_slider(
    currentvalue = list(
      prefix = "Year: ",
      font = list(size = 20, color = "steelblue")
    )
  ) |>
  layout(
    title = "Tech Company Revenue Race",
    xaxis = list(title = "Revenue (Billions $)", range = c(0, 400)),
    yaxis = list(title = "")
  )
```

### Gapminder-Style Bubble Animation

```r
library(plotly)
library(dplyr)

# Create bubble data
set.seed(123)
countries <- c("USA", "China", "India", "Brazil", "Germany")
years <- seq(2000, 2020, 2)

bubble_data <- expand.grid(
  year = years,
  country = countries,
  stringsAsFactors = FALSE
) |>
  mutate(
    gdp_per_capita = case_when(
      country == "USA" ~ 40000 + (year - 2000) * 800 + rnorm(n(), 0, 1000),
      country == "China" ~ 5000 + (year - 2000) * 1000 + rnorm(n(), 0, 500),
      country == "India" ~ 2000 + (year - 2000) * 300 + rnorm(n(), 0, 200),
      country == "Brazil" ~ 8000 + (year - 2000) * 200 + rnorm(n(), 0, 500),
      country == "Germany" ~ 35000 + (year - 2000) * 600 + rnorm(n(), 0, 800)
    ),
    life_expectancy = case_when(
      country == "USA" ~ 76 + (year - 2000) * 0.15,
      country == "China" ~ 71 + (year - 2000) * 0.3,
      country == "India" ~ 63 + (year - 2000) * 0.5,
      country == "Brazil" ~ 70 + (year - 2000) * 0.2,
      country == "Germany" ~ 78 + (year - 2000) * 0.1
    ),
    population = case_when(
      country == "USA" ~ 280 + (year - 2000) * 3,
      country == "China" ~ 1200 + (year - 2000) * 8,
      country == "India" ~ 1000 + (year - 2000) * 15,
      country == "Brazil" ~ 170 + (year - 2000) * 2,
      country == "Germany" ~ 82 + (year - 2000) * 0.1
    )
  )

plot_ly(bubble_data,
        x = ~gdp_per_capita,
        y = ~life_expectancy,
        size = ~population,
        color = ~country,
        frame = ~year,
        text = ~country,
        hovertemplate = paste(
          "<b>%{text}</b><br>",
          "GDP per capita: $%{x:,.0f}<br>",
          "Life expectancy: %{y:.1f} years<br>",
          "Population: %{marker.size:.0f}M<br>",
          "<extra></extra>"
        ),
        type = "scatter",
        mode = "markers",
        sizes = c(10, 100)) |>
  animation_opts(
    frame = 700,
    transition = 500,
    easing = "elastic"
  ) |>
  layout(
    title = "Wealth and Health of Nations",
    xaxis = list(title = "GDP per Capita ($)", type = "log"),
    yaxis = list(title = "Life Expectancy (years)", range = c(60, 85))
  )
```

### Choropleth Map Animation

```r
library(plotly)

# USA states data over years
states_data <- data.frame(
  state = rep(state.abb[1:10], 5),
  year = rep(2019:2023, each = 10),
  value = runif(50, 50, 150)
)

plot_ly(states_data,
        type = "choropleth",
        locationmode = "USA-states",
        locations = ~state,
        z = ~value,
        frame = ~year,
        colorscale = "Viridis") |>
  animation_opts(frame = 500, transition = 300) |>
  layout(
    title = "State Values Over Time",
    geo = list(scope = "usa")
  )
```

---

## Linked Brushing Examples

### Two-Plot Crosstalk Linking

```r
library(plotly)
library(crosstalk)

# Create shared data
shared_iris <- SharedData$new(iris)

# Scatter plot
p1 <- plot_ly(shared_iris, x = ~Sepal.Length, y = ~Sepal.Width,
              color = ~Species, type = "scatter", mode = "markers",
              marker = list(size = 10)) |>
  layout(
    title = "Sepal Dimensions",
    dragmode = "select"
  )

# Histogram
p2 <- plot_ly(shared_iris, x = ~Petal.Length,
              color = ~Species, type = "histogram") |>
  layout(
    title = "Petal Length Distribution",
    barmode = "overlay"
  )

# Combine
subplot(p1, p2, nrows = 2, heights = c(0.6, 0.4), shareX = FALSE)
# Selecting in scatter highlights in histogram!
```

### Multi-Plot Dashboard with Filters

```r
library(plotly)
library(crosstalk)

# Shared data
shared_cars <- SharedData$new(mtcars |> mutate(car = rownames(mtcars)))

# Scatter: mpg vs weight
p1 <- plot_ly(shared_cars, x = ~wt, y = ~mpg,
              color = ~factor(cyl), size = ~hp,
              text = ~car,
              type = "scatter", mode = "markers") |>
  layout(title = "Efficiency vs Weight", dragmode = "lasso")

# Box plot: mpg by cylinders
p2 <- plot_ly(shared_cars, x = ~factor(cyl), y = ~mpg,
              color = ~factor(cyl),
              type = "box") |>
  layout(title = "MPG by Cylinders", showlegend = FALSE)

# Histogram: horsepower
p3 <- plot_ly(shared_cars, x = ~hp,
              type = "histogram",
              marker = list(color = "steelblue")) |>
  layout(title = "Horsepower Distribution")

# Bar: count by gears
p4 <- shared_cars$data() |>
  count(gear) |>
  plot_ly(x = ~gear, y = ~n, type = "bar",
          marker = list(color = "coral")) |>
  layout(title = "Count by Gears")

# Combine in 2x2 grid
subplot(
  subplot(p1, p2, nrows = 1, shareY = FALSE),
  subplot(p3, p4, nrows = 1, shareX = FALSE),
  nrows = 2, heights = c(0.55, 0.45)
) |>
  layout(title = "Interactive Car Analysis Dashboard")
```

### Filter Cascade Example

```r
library(plotly)
library(crosstalk)
library(dplyr)

# Create hierarchical data
data <- mtcars |>
  mutate(
    car = rownames(mtcars),
    cyl_group = paste(cyl, "cylinders"),
    efficiency = cut(mpg, breaks = c(0, 15, 20, 25, 35),
                     labels = c("Low", "Medium", "High", "Very High"))
  )

shared <- SharedData$new(data, ~car)

# Main scatter
p1 <- plot_ly(shared, x = ~wt, y = ~mpg,
              color = ~cyl_group,
              text = ~car,
              type = "scatter", mode = "markers",
              marker = list(size = 12)) |>
  layout(
    title = "Click legend to filter all plots",
    dragmode = "select"
  )

# Bar by efficiency
p2 <- plot_ly(shared) |>
  add_histogram(x = ~efficiency, marker = list(color = "lightblue")) |>
  layout(title = "Efficiency Distribution")

# Scatter: hp vs qsec
p3 <- plot_ly(shared, x = ~hp, y = ~qsec,
              type = "scatter", mode = "markers",
              marker = list(size = 10, color = "coral")) |>
  layout(title = "Power vs Speed")

subplot(
  p1,
  subplot(p2, p3, nrows = 1, shareX = FALSE),
  nrows = 2, heights = c(0.6, 0.4)
)
```

---

## Click Events in Shiny

### Simple Point Selection Handler

```r
library(shiny)
library(plotly)

ui <- fluidPage(
  titlePanel("Click Point to See Details"),
  sidebarLayout(
    sidebarPanel(
      h4("Clicked Point Info"),
      verbatimTextOutput("click_info")
    ),
    mainPanel(
      plotlyOutput("scatter", height = "500px")
    )
  )
)

server <- function(input, output, session) {
  output$scatter <- renderPlotly({
    plot_ly(iris, x = ~Sepal.Length, y = ~Sepal.Width,
            color = ~Species, type = "scatter", mode = "markers",
            marker = list(size = 12),
            source = "scatter") |>
      layout(title = "Click any point")
  })

  output$click_info <- renderPrint({
    clicked <- event_data("plotly_click", source = "scatter")
    if (is.null(clicked)) {
      cat("Click a point to see details")
    } else {
      data_point <- iris[clicked$pointNumber + 1, ]
      cat("Species:", as.character(data_point$Species), "\n")
      cat("Sepal Length:", data_point$Sepal.Length, "\n")
      cat("Sepal Width:", data_point$Sepal.Width, "\n")
      cat("Petal Length:", data_point$Petal.Length, "\n")
      cat("Petal Width:", data_point$Petal.Width, "\n")
    }
  })
}

shinyApp(ui, server)
```

### Drill-Down Navigation

```r
library(shiny)
library(plotly)
library(dplyr)

ui <- fluidPage(
  titlePanel("Three-Level Drill-Down"),
  plotlyOutput("plot"),
  actionButton("back", "Go Back", style = "margin-top: 10px;"),
  verbatimTextOutput("level_info")
)

server <- function(input, output, session) {
  rv <- reactiveValues(
    level = 1,
    selected_cyl = NULL,
    selected_car = NULL
  )

  output$plot <- renderPlotly({
    if (rv$level == 1) {
      # Level 1: Overview by cylinders
      mtcars |>
        group_by(cyl) |>
        summarize(avg_mpg = mean(mpg), count = n()) |>
        plot_ly(x = ~factor(cyl), y = ~avg_mpg, type = "bar",
                text = ~paste("Count:", count),
                source = "drill") |>
        layout(title = "Average MPG by Cylinders (Click to drill down)",
               xaxis = list(title = "Cylinders"),
               yaxis = list(title = "Average MPG"))

    } else if (rv$level == 2) {
      # Level 2: Cars with selected cylinder count
      mtcars |>
        filter(cyl == rv$selected_cyl) |>
        mutate(car = rownames(mtcars)[cyl == rv$selected_cyl]) |>
        plot_ly(x = ~reorder(car, mpg), y = ~mpg, type = "bar",
                source = "drill") |>
        layout(title = paste("Cars with", rv$selected_cyl, "Cylinders"),
               xaxis = list(title = ""),
               yaxis = list(title = "MPG"))

    } else {
      # Level 3: Selected car details
      car_data <- mtcars |> filter(rownames(mtcars) == rv$selected_car)
      metrics <- data.frame(
        metric = c("MPG", "HP", "Weight", "Qsec"),
        value = c(car_data$mpg, car_data$hp, car_data$wt, car_data$qsec)
      )

      plot_ly(metrics, x = ~metric, y = ~value, type = "bar",
              marker = list(color = c("green", "red", "blue", "orange"))) |>
        layout(title = paste("Details:", rv$selected_car))
    }
  })

  observeEvent(event_data("plotly_click", source = "drill"), {
    clicked <- event_data("plotly_click", source = "drill")

    if (rv$level == 1) {
      rv$selected_cyl <- as.numeric(clicked$x)
      rv$level <- 2
    } else if (rv$level == 2) {
      rv$selected_car <- clicked$x
      rv$level <- 3
    }
  })

  observeEvent(input$back, {
    if (rv$level > 1) {
      rv$level <- rv$level - 1
    }
  })

  output$level_info <- renderPrint({
    cat("Current Level:", rv$level, "\n")
    if (rv$level >= 2) cat("Selected Cylinders:", rv$selected_cyl, "\n")
    if (rv$level == 3) cat("Selected Car:", rv$selected_car, "\n")
  })
}

shinyApp(ui, server)
```

### Dynamic Filtering with Selection

```r
library(shiny)
library(plotly)
library(dplyr)

ui <- fluidPage(
  titlePanel("Select Points to Filter"),
  fluidRow(
    column(6, plotlyOutput("main_plot")),
    column(6, plotlyOutput("filtered_plot"))
  ),
  verbatimTextOutput("selection_info")
)

server <- function(input, output, session) {
  output$main_plot <- renderPlotly({
    plot_ly(mtcars, x = ~wt, y = ~mpg, text = ~rownames(mtcars),
            type = "scatter", mode = "markers",
            marker = list(size = 10),
            source = "main") |>
      layout(
        title = "Select points (box or lasso)",
        dragmode = "lasso"
      )
  })

  output$filtered_plot <- renderPlotly({
    selected <- event_data("plotly_selected", source = "main")

    if (is.null(selected)) {
      data <- mtcars
      title_text <- "All Data"
    } else {
      indices <- selected$pointNumber + 1
      data <- mtcars[indices, ]
      title_text <- paste("Selected:", nrow(data), "points")
    }

    plot_ly(data, x = ~hp, y = ~qsec,
            type = "scatter", mode = "markers",
            marker = list(size = 12, color = "coral")) |>
      layout(title = title_text,
             xaxis = list(title = "Horsepower"),
             yaxis = list(title = "Quarter Mile Time"))
  })

  output$selection_info <- renderPrint({
    selected <- event_data("plotly_selected", source = "main")
    if (is.null(selected)) {
      cat("No selection\n")
    } else {
      cat("Selected", nrow(selected), "points:\n")
      print(rownames(mtcars)[selected$pointNumber + 1])
    }
  })
}

shinyApp(ui, server)
```

---

## Custom Interactions

### Range Slider on Time Series

```r
library(plotly)

# Generate time series
dates <- seq.Date(as.Date("2020-01-01"), by = "day", length.out = 365)
values <- cumsum(rnorm(365, 0, 10)) + 1000

plot_ly(x = dates, y = values, type = "scatter", mode = "lines",
        line = list(color = "steelblue", width = 2)) |>
  layout(
    title = "Stock Price with Range Selector",
    xaxis = list(
      rangeslider = list(visible = TRUE, thickness = 0.1),
      rangeselector = list(
        buttons = list(
          list(count = 1, label = "1m", step = "month", stepmode = "backward"),
          list(count = 3, label = "3m", step = "month", stepmode = "backward"),
          list(count = 6, label = "6m", step = "month", stepmode = "backward"),
          list(count = 1, label = "YTD", step = "year", stepmode = "todate"),
          list(count = 1, label = "1y", step = "year", stepmode = "backward"),
          list(label = "All", step = "all")
        )
      )
    ),
    yaxis = list(title = "Price ($)")
  )
```

### Update Menus for Trace Visibility

```r
library(plotly)

# Multiple series
data <- data.frame(
  x = 1:50,
  series_a = cumsum(rnorm(50, 0, 1)),
  series_b = cumsum(rnorm(50, 0.5, 1.2)),
  series_c = cumsum(rnorm(50, -0.2, 0.8))
)

plot_ly(data, x = ~x) |>
  add_lines(y = ~series_a, name = "Series A", visible = TRUE) |>
  add_lines(y = ~series_b, name = "Series B", visible = TRUE) |>
  add_lines(y = ~series_c, name = "Series C", visible = TRUE) |>
  layout(
    title = "Toggle Series Visibility",
    updatemenus = list(
      list(
        type = "buttons",
        direction = "left",
        x = 0.1, y = 1.15,
        buttons = list(
          list(label = "All",
               method = "restyle",
               args = list("visible", list(TRUE, TRUE, TRUE))),
          list(label = "A Only",
               method = "restyle",
               args = list("visible", list(TRUE, FALSE, FALSE))),
          list(label = "B Only",
               method = "restyle",
               args = list("visible", list(FALSE, TRUE, FALSE))),
          list(label = "C Only",
               method = "restyle",
               args = list("visible", list(FALSE, FALSE, TRUE))),
          list(label = "A + B",
               method = "restyle",
               args = list("visible", list(TRUE, TRUE, FALSE)))
        )
      )
    )
  )
```

### Dropdown Menu for Chart Type

```r
library(plotly)

data <- data.frame(
  category = LETTERS[1:5],
  value = c(23, 45, 12, 67, 34)
)

plot_ly(data, x = ~category, y = ~value) |>
  add_bars(visible = TRUE, name = "Bar") |>
  add_markers(visible = FALSE, name = "Scatter", marker = list(size = 15)) |>
  add_lines(visible = FALSE, name = "Line", line = list(width = 3)) |>
  layout(
    title = "Select Chart Type",
    updatemenus = list(
      list(
        type = "dropdown",
        x = 0.1, y = 1.15,
        buttons = list(
          list(label = "Bar Chart",
               method = "restyle",
               args = list("visible", list(TRUE, FALSE, FALSE))),
          list(label = "Scatter Plot",
               method = "restyle",
               args = list("visible", list(FALSE, TRUE, FALSE))),
          list(label = "Line Chart",
               method = "restyle",
               args = list("visible", list(FALSE, FALSE, TRUE)))
        )
      )
    )
  )
```

### Combined Interactions: Slider + Dropdown + Buttons

```r
library(plotly)
library(dplyr)

# Generate data
years <- 2015:2023
categories <- c("A", "B", "C", "D")

data <- expand.grid(
  year = years,
  category = categories
) |>
  mutate(value = runif(n(), 50, 150))

# Create plot with multiple controls
p <- plot_ly()

# Add traces for each year
for (y in years) {
  year_data <- data |> filter(year == y)

  p <- p |>
    add_bars(
      data = year_data,
      x = ~category,
      y = ~value,
      name = as.character(y),
      visible = if(y == 2015) TRUE else FALSE
    )
}

p |>
  layout(
    title = "Multi-Control Interactive Plot",
    updatemenus = list(
      # Dropdown for year
      list(
        type = "dropdown",
        x = 0.1, y = 1.2,
        buttons = lapply(years, function(y) {
          list(
            label = as.character(y),
            method = "restyle",
            args = list("visible", lapply(years, function(yr) yr == y))
          )
        })
      ),
      # Buttons for chart type
      list(
        type = "buttons",
        direction = "left",
        x = 0.5, y = 1.2,
        buttons = list(
          list(label = "Bar",
               method = "restyle",
               args = list("type", "bar")),
          list(label = "Scatter",
               method = "restyle",
               args = list("type", "scatter"))
        )
      )
    ),
    sliders = list(
      list(
        active = 0,
        steps = lapply(1:length(years), function(i) {
          list(
            label = as.character(years[i]),
            method = "restyle",
            args = list("visible", lapply(1:length(years), function(j) j == i))
          )
        })
      )
    )
  )
```

---

## Summary

These examples demonstrate advanced interactive features:
- **Hover**: Rich formatting, conditional display, HTML styling
- **Animation**: Time series, racing charts, bubble animations, maps
- **Linking**: Crosstalk for client-side, multi-plot coordination
- **Click**: Shiny event handlers, drill-down, dynamic filtering
- **Controls**: Range sliders, update menus, buttons, combined interactions

All examples are complete and runnable - copy, paste, and adapt to your data!

For more interactive patterns, see:
- [Interactivity Reference](../references/interactivity-reference.md)
- [Animation Reference](../references/animation-reference.md)
- [Shiny Integration Reference](../references/shiny-integration-reference.md)
