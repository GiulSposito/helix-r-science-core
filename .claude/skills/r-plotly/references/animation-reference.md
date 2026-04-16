# Animation Reference - R Plotly

Complete guide to creating frame-based animations in plotly for temporal narratives, data evolution, and dynamic storytelling.

## Table of Contents

1. [Animation Fundamentals](#animation-fundamentals)
2. [Creating Animations](#creating-animations)
3. [Animation Controls](#animation-controls)
4. [Buttons and Sliders](#buttons-and-sliders)
5. [Advanced Patterns](#advanced-patterns)
6. [Performance Optimization](#performance-optimization)

---

## Animation Fundamentals

### The Frame Concept

Plotly animations work by creating **multiple frames** of data, where each frame represents one state of the visualization. When played, plotly transitions smoothly between frames.

**Key mental model:**
```
Frame 1 → Frame 2 → Frame 3 → ... → Frame N
 (2000)    (2001)    (2002)         (2020)
```

Each frame is a complete snapshot of the data at that point in time.

### Creating Frames

Use the `frame` aesthetic to split data into animation frames:

```r
library(plotly)

# Each unique value of 'year' becomes a frame
plot_ly(data, x = ~x, y = ~y, frame = ~year, type = "scatter", mode = "markers")
```

**What happens internally:**
1. Plotly groups data by unique `frame` values
2. Creates one plot state per group
3. Renders first frame initially
4. Adds play/pause controls automatically
5. Interpolates between frames during transitions

### Frame Aesthetic vs Manual Frames

**Automatic (recommended):**
```r
# Plotly handles frame creation
plot_ly(data, frame = ~time_variable)
```

**Manual (advanced):**
```r
# Explicit frame specification using frames argument
plot_ly() |>
  add_trace(..., frame = "frame1") |>
  add_trace(..., frame = "frame2")
```

**Use automatic frames** unless you need precise control over frame structure.

### Data Structure Requirements

Animation data must be in **long format** with a frame identifier column.

**Correct structure:**
```r
# Long format: One row per observation per time point
data <- data.frame(
  country = rep(c("USA", "China", "India"), each = 20),
  year = rep(2000:2019, times = 3),
  gdp = runif(60, 1000, 50000),
  population = runif(60, 1e6, 1.5e9)
)
```

**Incorrect structure:**
```r
# Wide format: Years as columns
data_wide <- data.frame(
  country = c("USA", "China", "India"),
  gdp_2000 = c(...),
  gdp_2001 = c(...),
  # ...
)
# Won't work for frame animations!
```

**Converting wide to long:**
```r
library(tidyr)
data_long <- data_wide |>
  pivot_longer(
    cols = starts_with("gdp_"),
    names_to = "year",
    values_to = "gdp",
    names_prefix = "gdp_"
  )
```

### Frame Ordering

Frames play in **alphanumeric order** of frame values.

**Numeric ordering:**
```r
# Years automatically order correctly
plot_ly(data, frame = ~year)  # 2000, 2001, 2002, ...
```

**Character ordering (careful!):**
```r
# Wrong order: "Month 1", "Month 10", "Month 2", ...
data$month <- paste("Month", 1:12)

# Fix: Use ordered factor
data$month <- factor(data$month, levels = paste("Month", 1:12))
plot_ly(data, frame = ~month)
```

**Best practice**: Use numeric or Date columns for frames when possible.

### The ids Aesthetic

The `ids` aesthetic tells plotly which points to transition between frames.

**Without ids (wrong):**
```r
# Points will randomly connect between frames
plot_ly(data, x = ~x, y = ~y, frame = ~year)
```

**With ids (correct):**
```r
# Each country's point transitions smoothly
plot_ly(data, x = ~gdp, y = ~life_exp, frame = ~year, ids = ~country)
```

**Rule of thumb**: Always use `ids` when animating entities (countries, people, products) over time.

---

## Creating Animations

### Time Series Animation

Animate data evolving over time, revealing one time point at a time.

**Example 1: Simple line build-up**

```r
library(plotly)
library(dplyr)

# Generate time series data
data <- data.frame(
  date = seq.Date(as.Date("2020-01-01"), by = "month", length.out = 24),
  value = cumsum(rnorm(24, 10, 5))
) |>
  mutate(
    # Create cumulative frames: frame 1 shows Jan 2020, frame 2 shows Jan-Feb, etc.
    frame = format(date, "%Y-%m")
  ) |>
  group_by(frame) |>
  mutate(cumulative_data = list(cur_data())) |>
  unnest(cumulative_data) |>
  ungroup()

# Animate line drawing
plot_ly(data, x = ~date, y = ~value, frame = ~frame,
        type = "scatter", mode = "lines+markers",
        line = list(color = "#1f77b4", width = 3),
        marker = list(size = 8)) |>
  layout(
    title = "Sales Growth Over Time",
    xaxis = list(title = "Date", type = "date"),
    yaxis = list(title = "Cumulative Sales ($)", range = c(0, max(data$value) * 1.1))
  ) |>
  animation_opts(frame = 500, transition = 300, redraw = FALSE) |>
  animation_button(
    x = 1, xanchor = "right", y = 0,
    yanchor = "bottom"
  ) |>
  animation_slider(
    currentvalue = list(prefix = "Month: ", font = list(size = 16))
  )
```

**Example 2: Multiple series racing**

```r
# Three product lines
data <- expand.grid(
  month = 1:12,
  product = c("Product A", "Product B", "Product C")
) |>
  mutate(
    sales = case_when(
      product == "Product A" ~ month * 10 + rnorm(36, 0, 5),
      product == "Product B" ~ month * 8 + rnorm(36, 0, 4),
      product == "Product C" ~ month * 12 + rnorm(36, 0, 6)
    ),
    month_label = factor(month.abb[month], levels = month.abb)
  )

plot_ly(data, x = ~month, y = ~sales, color = ~product,
        frame = ~month, ids = ~product,
        type = "scatter", mode = "lines+markers") |>
  layout(
    title = "Product Sales Race",
    xaxis = list(title = "Month", range = c(0.5, 12.5)),
    yaxis = list(title = "Sales", range = c(0, 160))
  ) |>
  animation_opts(frame = 400, transition = 200)
```

### Categorical Animation

Animate transitions between discrete categories or groups.

**Example 3: Switching between groups**

```r
library(plotly)

# Create data with different categories
data <- data.frame(
  category = rep(c("North", "South", "East", "West"), each = 10),
  region = rep(c("North", "South", "East", "West"), each = 10),
  product = rep(paste("Product", 1:10), times = 4),
  sales = runif(40, 50, 200)
)

plot_ly(data, x = ~product, y = ~sales, color = ~product,
        frame = ~region, type = "bar") |>
  layout(
    title = "Sales by Region",
    xaxis = list(title = ""),
    yaxis = list(title = "Sales ($)", range = c(0, 250)),
    showlegend = FALSE
  ) |>
  animation_opts(frame = 1000, transition = 500, easing = "elastic") |>
  animation_slider(
    currentvalue = list(prefix = "Region: ", font = list(size = 20, color = "blue"))
  )
```

**Example 4: Distribution evolution**

```r
# Animate histogram showing distribution changes
set.seed(123)
data <- data.frame(
  year = rep(2015:2020, each = 200),
  score = c(
    rnorm(200, 60, 10),  # 2015: mean 60
    rnorm(200, 62, 9),   # 2016: mean 62
    rnorm(200, 65, 8),   # 2017: mean 65
    rnorm(200, 68, 7),   # 2018: mean 68
    rnorm(200, 70, 6),   # 2019: mean 70
    rnorm(200, 72, 5)    # 2020: mean 72
  )
)

plot_ly(data, x = ~score, frame = ~year, type = "histogram",
        marker = list(color = "#1f77b4", line = list(color = "white", width = 1))) |>
  layout(
    title = "Test Score Distribution by Year",
    xaxis = list(title = "Score", range = c(30, 90)),
    yaxis = list(title = "Count", range = c(0, 60)),
    bargap = 0.1
  ) |>
  animation_opts(frame = 800, transition = 400)
```

### Cumulative Animation

Show data accumulating over time - useful for cumulative sums, running totals.

**Example 5: Cumulative scatter plot**

```r
library(dplyr)

# Generate event data
events <- data.frame(
  event_date = seq.Date(as.Date("2023-01-01"), by = "day", length.out = 100),
  customer_id = paste0("C", sample(1:50, 100, replace = TRUE)),
  revenue = runif(100, 10, 500)
) |>
  arrange(event_date) |>
  mutate(
    cumulative_revenue = cumsum(revenue),
    event_num = row_number(),
    frame_id = event_num  # Each event is a frame
  )

plot_ly(events, x = ~event_date, y = ~cumulative_revenue,
        frame = ~frame_id, ids = ~event_num,
        type = "scatter", mode = "lines+markers",
        marker = list(size = 6, color = "#d62728"),
        line = list(width = 2, color = "#d62728")) |>
  layout(
    title = "Cumulative Revenue Growth",
    xaxis = list(title = "Date", type = "date"),
    yaxis = list(title = "Cumulative Revenue ($)", range = c(0, max(events$cumulative_revenue) * 1.05))
  ) |>
  animation_opts(frame = 50, transition = 30, redraw = FALSE)
```

**Example 6: Gapminder-style bubble chart**

Classic Hans Rosling style visualization.

```r
# Gapminder-style data
set.seed(42)
countries <- c("USA", "China", "India", "Brazil", "Nigeria", "Germany", "Japan")
years <- 2000:2020

gapminder_data <- expand.grid(
  country = countries,
  year = years
) |>
  mutate(
    gdp_per_capita = case_when(
      country == "USA" ~ 40000 + (year - 2000) * 1000 + rnorm(n(), 0, 1000),
      country == "China" ~ 3000 + (year - 2000) * 800 + rnorm(n(), 0, 500),
      country == "India" ~ 2000 + (year - 2000) * 300 + rnorm(n(), 0, 200),
      country == "Brazil" ~ 8000 + (year - 2000) * 400 + rnorm(n(), 0, 400),
      country == "Nigeria" ~ 2000 + (year - 2000) * 200 + rnorm(n(), 0, 300),
      country == "Germany" ~ 35000 + (year - 2000) * 900 + rnorm(n(), 0, 800),
      country == "Japan" ~ 38000 + (year - 2000) * 600 + rnorm(n(), 0, 700)
    ),
    life_expectancy = case_when(
      country == "USA" ~ 76 + (year - 2000) * 0.15 + rnorm(n(), 0, 0.5),
      country == "China" ~ 71 + (year - 2000) * 0.25 + rnorm(n(), 0, 0.5),
      country == "India" ~ 63 + (year - 2000) * 0.35 + rnorm(n(), 0, 0.5),
      country == "Brazil" ~ 70 + (year - 2000) * 0.20 + rnorm(n(), 0, 0.5),
      country == "Nigeria" ~ 51 + (year - 2000) * 0.40 + rnorm(n(), 0, 0.5),
      country == "Germany" ~ 78 + (year - 2000) * 0.10 + rnorm(n(), 0, 0.3),
      country == "Japan" ~ 81 + (year - 2000) * 0.12 + rnorm(n(), 0, 0.3)
    ),
    population = case_when(
      country == "USA" ~ 280 + (year - 2000) * 2.5,
      country == "China" ~ 1270 + (year - 2000) * 8,
      country == "India" ~ 1050 + (year - 2000) * 15,
      country == "Brazil" ~ 174 + (year - 2000) * 2,
      country == "Nigeria" ~ 123 + (year - 2000) * 4,
      country == "Germany" ~ 82 + (year - 2000) * 0.1,
      country == "Japan" ~ 127 + (year - 2000) * 0.1
    )
  )

plot_ly(gapminder_data,
        x = ~gdp_per_capita,
        y = ~life_expectancy,
        size = ~population,
        color = ~country,
        frame = ~year,
        ids = ~country,
        type = "scatter",
        mode = "markers",
        marker = list(sizemode = "diameter", sizeref = 2, line = list(width = 1, color = "white")),
        text = ~paste(country, "<br>GDP:", round(gdp_per_capita),
                     "<br>Life Exp:", round(life_expectancy, 1),
                     "<br>Pop:", round(population), "M"),
        hoverinfo = "text") |>
  layout(
    title = "Wealth and Health of Nations (2000-2020)",
    xaxis = list(
      title = "GDP per Capita ($)",
      type = "log",
      range = c(log10(1500), log10(60000))
    ),
    yaxis = list(
      title = "Life Expectancy (years)",
      range = c(45, 85)
    )
  ) |>
  animation_opts(
    frame = 500,
    transition = 400,
    easing = "cubic-in-out",
    redraw = FALSE
  ) |>
  animation_slider(
    currentvalue = list(
      prefix = "Year: ",
      font = list(size = 20, color = "red")
    )
  )
```

---

## Animation Controls

### animation_opts() - Core Animation Settings

Control timing, transitions, and behavior.

**Function signature:**
```r
animation_opts(
  p,                      # plotly object
  frame = 500,            # Duration of each frame (ms)
  transition = 250,       # Transition time between frames (ms)
  easing = "linear",      # Easing function
  redraw = TRUE,          # Redraw each frame (FALSE = smoother for large data)
  mode = "immediate"      # Animation mode
)
```

### Frame Duration

**frame** = How long each frame is displayed (milliseconds).

```r
# Fast animation (200ms per frame)
plot_ly(data, frame = ~year) |>
  animation_opts(frame = 200, transition = 100)

# Slow animation (1000ms per frame)
plot_ly(data, frame = ~year) |>
  animation_opts(frame = 1000, transition = 500)

# Very slow (2s per frame)
plot_ly(data, frame = ~year) |>
  animation_opts(frame = 2000, transition = 1000)
```

**Guidelines:**
- **100-300ms**: Fast, for many frames (50+)
- **500-800ms**: Medium, general purpose
- **1000-2000ms**: Slow, for few frames with detail

### Transition Duration

**transition** = Time to animate between frames (milliseconds).

```r
# Instant transition (no animation)
animation_opts(frame = 500, transition = 0)

# Quick transition
animation_opts(frame = 500, transition = 100)

# Smooth transition (half of frame time)
animation_opts(frame = 1000, transition = 500)
```

**Rule of thumb**: Set `transition = frame / 2` for smooth animations.

### Easing Functions

**easing** = Motion curve for transitions.

**Available easing functions:**
- **linear**: Constant speed (default)
- **quad**: Quadratic (accelerate/decelerate)
- **cubic**: Cubic curve
- **sin**: Sinusoidal
- **exp**: Exponential
- **circle**: Circular curve
- **elastic**: Elastic bounce
- **back**: Slight overshoot
- **bounce**: Bouncing effect

**With direction modifiers:**
- **[name]-in**: Accelerate into frame
- **[name]-out**: Decelerate out of frame
- **[name]-in-out**: Both (symmetric)

**Examples:**

```r
# Linear (default) - constant speed
animation_opts(easing = "linear")

# Cubic-in-out - smooth acceleration/deceleration
animation_opts(easing = "cubic-in-out")

# Elastic - bouncy effect (fun for presentations!)
animation_opts(easing = "elastic-in-out")

# Back - slight overshoot (emphasizes arrival)
animation_opts(easing = "back-out")

# Bounce - bouncing finish
animation_opts(easing = "bounce-out")
```

**Choosing easing:**
- **Data dashboards**: Use `linear` or `cubic-in-out` (professional)
- **Presentations**: Try `elastic` or `bounce` (engaging)
- **Emphasis on arrival**: Use `back-out`
- **Smooth motion**: Use `cubic-in-out` or `sin-in-out`

### Redraw Setting

**redraw** = Whether to completely redraw each frame.

```r
# Redraw each frame (default, safer but slower)
animation_opts(redraw = TRUE)

# Interpolate without redrawing (faster, smoother for many points)
animation_opts(redraw = FALSE)
```

**When to use redraw = FALSE:**
- Large datasets (1000+ points)
- Smooth continuous animations (time series)
- Performance is critical

**When to use redraw = TRUE:**
- Structural changes between frames (different number of points)
- Discrete categorical transitions
- Complex multi-trace animations

**Example comparison:**

```r
# Without redraw (smooth for time series)
plot_ly(large_timeseries, x = ~x, y = ~y, frame = ~date, ids = ~id) |>
  animation_opts(frame = 100, transition = 80, redraw = FALSE)

# With redraw (safe for changing structure)
plot_ly(categorical_data, x = ~category, y = ~value, frame = ~year) |>
  animation_opts(frame = 500, transition = 300, redraw = TRUE)
```

---

## Buttons and Sliders

### animation_button() - Play/Pause Control

Customize the play/pause button appearance and position.

**Function signature:**
```r
animation_button(
  p,
  x = 1.1,                    # x position (0-1 = fraction of plot width, or paper coordinates)
  xanchor = "right",          # Anchor: "left", "center", "right"
  y = 0,                      # y position
  yanchor = "bottom",         # Anchor: "top", "middle", "bottom"
  visible = TRUE,             # Show/hide button
  label = NULL,               # Custom label (default: play/pause symbols)
  bgcolor = "#f8f9fa",        # Background color
  bordercolor = "#dee2e6",    # Border color
  font = list(size = 12)      # Font styling
)
```

**Example 1: Default button**

```r
plot_ly(data, frame = ~year) |>
  animation_button()  # Defaults: top-left
```

**Example 2: Positioned button**

```r
plot_ly(data, frame = ~year) |>
  animation_button(
    x = 0.1, xanchor = "left",
    y = 0, yanchor = "bottom"
  )
```

**Example 3: Styled button**

```r
plot_ly(data, frame = ~year) |>
  animation_button(
    x = 1, xanchor = "right",
    y = 1, yanchor = "top",
    bgcolor = "#007bff",
    bordercolor = "#0056b3",
    font = list(size = 14, color = "white")
  )
```

**Example 4: Hide button (slider only)**

```r
plot_ly(data, frame = ~year) |>
  animation_button(visible = FALSE) |>
  animation_slider()
```

### animation_slider() - Frame Slider Control

Customize the slider for manual frame selection.

**Function signature:**
```r
animation_slider(
  p,
  visible = TRUE,              # Show/hide slider
  currentvalue = list(         # Current value indicator
    prefix = "",               # Text before value
    suffix = "",               # Text after value
    visible = TRUE,            # Show current value
    xanchor = "right",         # Anchor position
    font = list(size = 14)     # Font styling
  ),
  len = 1,                     # Slider length (0-1 = fraction of plot width)
  x = 0,                       # x position
  xanchor = "left",            # Anchor
  y = 0,                       # y position
  yanchor = "top",             # Anchor
  pad = list(t = 40, b = 10),  # Padding
  bgcolor = "#f8f9fa",         # Background color
  bordercolor = "#dee2e6",     # Border color
  tickcolor = "#6c757d"        # Tick color
)
```

**Example 5: Default slider**

```r
plot_ly(data, frame = ~year) |>
  animation_slider()
```

**Example 6: Styled slider with custom current value**

```r
plot_ly(data, frame = ~year) |>
  animation_slider(
    currentvalue = list(
      prefix = "Year: ",
      font = list(size = 20, color = "blue")
    ),
    bgcolor = "#e9ecef",
    bordercolor = "#adb5bd",
    tickcolor = "#495057"
  )
```

**Example 7: Compact slider (shorter)**

```r
plot_ly(data, frame = ~year) |>
  animation_slider(
    len = 0.8,          # 80% of plot width
    x = 0.1,            # Start at 10% from left
    xanchor = "left",
    currentvalue = list(
      visible = FALSE   # Hide current value text
    )
  )
```

### Combining Buttons and Sliders

**Example 8: Full custom controls**

```r
plot_ly(gapminder_data,
        x = ~gdp_per_capita,
        y = ~life_expectancy,
        frame = ~year,
        ids = ~country) |>
  animation_opts(
    frame = 600,
    transition = 400,
    easing = "cubic-in-out"
  ) |>
  animation_button(
    x = 0, xanchor = "left",
    y = 1.15, yanchor = "top",
    bgcolor = "#28a745",
    bordercolor = "#218838",
    font = list(size = 14, color = "white", family = "Arial")
  ) |>
  animation_slider(
    currentvalue = list(
      prefix = "Year: ",
      suffix = " ",
      font = list(size = 18, color = "#343a40")
    ),
    len = 0.9,
    x = 0.05,
    y = 0,
    yanchor = "top",
    pad = list(t = 50, b = 10),
    bgcolor = "#ffffff",
    bordercolor = "#343a40",
    tickcolor = "#6c757d"
  ) |>
  layout(
    margin = list(t = 80, b = 80)  # Add space for controls
  )
```

---

## Advanced Patterns

### Racing Bar Chart

Animated bar chart showing rankings changing over time - highly engaging for presentations.

**Complete example:**

```r
library(plotly)
library(dplyr)

# Generate racing data - top companies by revenue over years
companies <- c("Apple", "Microsoft", "Amazon", "Google", "Meta",
               "Tesla", "Nvidia", "Berkshire", "Walmart", "Samsung")
years <- 2015:2023

racing_data <- expand.grid(
  company = companies,
  year = years
) |>
  mutate(
    # Simulate different growth trajectories
    revenue = case_when(
      company == "Apple" ~ 200 + (year - 2015) * 25 + rnorm(n(), 0, 10),
      company == "Microsoft" ~ 90 + (year - 2015) * 22 + rnorm(n(), 0, 8),
      company == "Amazon" ~ 100 + (year - 2015) * 35 + rnorm(n(), 0, 12),
      company == "Google" ~ 70 + (year - 2015) * 28 + rnorm(n(), 0, 9),
      company == "Meta" ~ 40 + (year - 2015) * 18 + rnorm(n(), 0, 7),
      company == "Tesla" ~ 5 + (year - 2015) * 15 + rnorm(n(), 0, 8),
      company == "Nvidia" ~ 10 + (year - 2015) * 32 + rnorm(n(), 0, 10),
      company == "Berkshire" ~ 220 + (year - 2015) * 15 + rnorm(n(), 0, 8),
      company == "Walmart" ~ 480 + (year - 2015) * 12 + rnorm(n(), 0, 10),
      company == "Samsung" ~ 180 + (year - 2015) * 8 + rnorm(n(), 0, 12)
    )
  ) |>
  group_by(year) |>
  arrange(desc(revenue)) |>
  mutate(
    rank = row_number(),
    # Add color per company (consistent across frames)
    color = case_when(
      company == "Apple" ~ "#A2AAAD",
      company == "Microsoft" ~ "#F25022",
      company == "Amazon" ~ "#FF9900",
      company == "Google" ~ "#4285F4",
      company == "Meta" ~ "#1877F2",
      company == "Tesla" ~ "#CC0000",
      company == "Nvidia" ~ "#76B900",
      company == "Berkshire" ~ "#003087",
      company == "Walmart" ~ "#0071CE",
      company == "Samsung" ~ "#034EA2"
    )
  ) |>
  ungroup() |>
  arrange(year, rank)

# Create racing bar chart
plot_ly(
  racing_data,
  x = ~revenue,
  y = ~reorder(company, revenue),  # Order by revenue
  frame = ~year,
  ids = ~company,
  type = "bar",
  orientation = "h",
  marker = list(color = ~color),
  text = ~paste0("$", round(revenue), "B"),
  textposition = "outside",
  hoverinfo = "text",
  hovertext = ~paste0(company, "<br>Revenue: $", round(revenue, 1), "B<br>Rank: #", rank)
) |>
  layout(
    title = list(
      text = "Top 10 Companies by Revenue",
      font = list(size = 24)
    ),
    xaxis = list(
      title = "Revenue (Billions USD)",
      range = c(0, max(racing_data$revenue) * 1.15)
    ),
    yaxis = list(
      title = "",
      categoryorder = "total ascending"
    ),
    plot_bgcolor = "#f8f9fa",
    paper_bgcolor = "white",
    font = list(family = "Arial", size = 14),
    margin = list(l = 120, r = 100)
  ) |>
  animation_opts(
    frame = 800,
    transition = 600,
    easing = "cubic-in-out",
    redraw = TRUE  # Important for bar charts!
  ) |>
  animation_slider(
    currentvalue = list(
      prefix = "Year: ",
      font = list(size = 22, color = "#343a40")
    ),
    len = 0.9,
    x = 0.05
  ) |>
  animation_button(
    x = 0, xanchor = "left",
    y = 1.1, yanchor = "top"
  ) |>
  config(displaylogo = FALSE)
```

**Key techniques for racing bar charts:**
1. **Reorder y-axis**: Use `reorder(company, revenue)` or `categoryorder = "total ascending"`
2. **Consistent colors**: Define color per entity, not per frame
3. **Use ids**: Essential for smooth transitions (`ids = ~company`)
4. **Set redraw = TRUE**: Bar charts need redrawing between frames
5. **Add text labels**: Show values on bars
6. **Slower timing**: Use longer frame duration (800ms+) for readability

### Scatter Plot with Trailing Path

Show current position plus historical trail.

**Complete example:**

```r
library(plotly)
library(dplyr)

# Generate trajectory data - object moving in 2D space
set.seed(123)
n_frames <- 50
trajectory_data <- data.frame(
  frame_num = rep(1:n_frames, each = 1:n_frames |> sum()),
  time_point = unlist(lapply(1:n_frames, function(i) 1:i))
) |>
  mutate(
    # Parametric trajectory (spiral)
    angle = time_point * 0.3,
    radius = time_point * 0.5,
    x = radius * cos(angle) + rnorm(n(), 0, 0.3),
    y = radius * sin(angle) + rnorm(n(), 0, 0.3),
    # Mark current point
    is_current = (time_point == frame_num)
  )

# Create plot with trail
plot_ly() |>
  # Trail (all historical points)
  add_trace(
    data = trajectory_data |> filter(!is_current),
    x = ~x, y = ~y,
    frame = ~frame_num,
    type = "scatter",
    mode = "lines+markers",
    marker = list(size = 4, color = "#6c757d", opacity = 0.5),
    line = list(color = "#6c757d", width = 2, opacity = 0.5),
    name = "Trail",
    showlegend = TRUE
  ) |>
  # Current position (highlighted)
  add_trace(
    data = trajectory_data |> filter(is_current),
    x = ~x, y = ~y,
    frame = ~frame_num,
    type = "scatter",
    mode = "markers",
    marker = list(size = 15, color = "#dc3545",
                 line = list(color = "white", width = 2)),
    name = "Current",
    showlegend = TRUE
  ) |>
  layout(
    title = "Object Trajectory with Trail",
    xaxis = list(title = "X Position", range = c(-30, 30)),
    yaxis = list(title = "Y Position", range = c(-30, 30)),
    plot_bgcolor = "white"
  ) |>
  animation_opts(
    frame = 100,
    transition = 80,
    redraw = FALSE
  ) |>
  animation_slider(
    currentvalue = list(prefix = "Time: ", suffix = "s")
  )
```

**Key technique**: Use two traces:
1. **Trail trace**: All points up to current frame
2. **Current trace**: Only the current frame point

### Morphing Shapes Animation

Animate shape transformations - useful for geographic regions, categories, distributions.

**Complete example:**

```r
library(plotly)
library(dplyr)

# Generate polygon data - shape morphing from circle to square to star
generate_shape <- function(shape_type, n_points = 100) {
  if (shape_type == "circle") {
    angles <- seq(0, 2 * pi, length.out = n_points)
    data.frame(
      x = cos(angles),
      y = sin(angles)
    )
  } else if (shape_type == "square") {
    # Square with n_points distributed around perimeter
    side_points <- n_points / 4
    data.frame(
      x = c(seq(-1, 1, length.out = side_points),
            rep(1, side_points),
            seq(1, -1, length.out = side_points),
            rep(-1, side_points)),
      y = c(rep(-1, side_points),
            seq(-1, 1, length.out = side_points),
            rep(1, side_points),
            seq(1, -1, length.out = side_points))
    )
  } else if (shape_type == "star") {
    # 5-pointed star
    angles <- seq(0, 2 * pi, length.out = n_points)
    radius <- ifelse(angles %% (2*pi/5) < pi/5, 1, 0.4)
    data.frame(
      x = radius * cos(angles),
      y = radius * sin(angles)
    )
  }
}

# Create frames with interpolation
n_interpolation <- 20
shapes <- list(
  list(name = "Circle", data = generate_shape("circle", 100)),
  list(name = "Square", data = generate_shape("square", 100)),
  list(name = "Star", data = generate_shape("star", 100)),
  list(name = "Circle", data = generate_shape("circle", 100))  # Back to start
)

# Interpolate between shapes
morphing_data <- data.frame()
frame_num <- 1
for (i in 1:(length(shapes) - 1)) {
  shape1 <- shapes[[i]]$data
  shape2 <- shapes[[i + 1]]$data

  for (t in seq(0, 1, length.out = n_interpolation)) {
    interpolated <- data.frame(
      x = shape1$x * (1 - t) + shape2$x * t,
      y = shape1$y * (1 - t) + shape2$y * t,
      frame_id = frame_num,
      shape_name = paste(shapes[[i]]$name, "→", shapes[[i + 1]]$name)
    )
    morphing_data <- rbind(morphing_data, interpolated)
    frame_num <- frame_num + 1
  }
}

# Create morphing animation
plot_ly(morphing_data, x = ~x, y = ~y,
        frame = ~frame_id,
        type = "scatter",
        mode = "lines",
        fill = "toself",
        fillcolor = "rgba(31, 119, 180, 0.5)",
        line = list(color = "#1f77b4", width = 3)) |>
  layout(
    title = "Shape Morphing Animation",
    xaxis = list(title = "", range = c(-1.2, 1.2), showgrid = FALSE),
    yaxis = list(title = "", range = c(-1.2, 1.2), showgrid = FALSE),
    plot_bgcolor = "white",
    showlegend = FALSE
  ) |>
  animation_opts(
    frame = 50,
    transition = 40,
    easing = "sin-in-out",
    redraw = FALSE
  ) |>
  animation_slider(visible = FALSE) |>
  animation_button(
    x = 0.5, xanchor = "center",
    y = 1.1, yanchor = "top"
  )
```

### Multi-Trace Coordinated Animation

Animate multiple traces simultaneously with coordination.

**Complete example:**

```r
library(plotly)
library(dplyr)

# Generate coordinated data - stock prices + volume
set.seed(42)
years <- 2015:2023
months <- 1:12

stock_data <- expand.grid(
  year = years,
  month = months
) |>
  mutate(
    date = as.Date(paste(year, month, "01", sep = "-")),
    frame_id = paste(year, sprintf("%02d", month), sep = "-"),
    # Stock price with trend
    price = 100 + (row_number() * 0.5) + cumsum(rnorm(n(), 0, 3)),
    # Volume (higher when price changes more)
    volume = abs(price - lag(price, default = 100)) * 1000 + rnorm(n(), 5000, 1000)
  ) |>
  arrange(date)

# Create dual-axis animation
plot_ly() |>
  # Price line (primary y-axis)
  add_trace(
    data = stock_data,
    x = ~date,
    y = ~price,
    frame = ~frame_id,
    type = "scatter",
    mode = "lines+markers",
    name = "Stock Price",
    line = list(color = "#1f77b4", width = 3),
    marker = list(size = 6),
    yaxis = "y1"
  ) |>
  # Volume bars (secondary y-axis)
  add_trace(
    data = stock_data,
    x = ~date,
    y = ~volume,
    frame = ~frame_id,
    type = "bar",
    name = "Volume",
    marker = list(color = "rgba(31, 119, 180, 0.3)"),
    yaxis = "y2"
  ) |>
  layout(
    title = "Stock Price and Volume Over Time",
    xaxis = list(title = "Date", type = "date"),
    yaxis = list(
      title = "Price ($)",
      side = "left"
    ),
    yaxis2 = list(
      title = "Volume",
      overlaying = "y",
      side = "right"
    ),
    showlegend = TRUE,
    legend = list(x = 0.1, y = 0.9)
  ) |>
  animation_opts(
    frame = 200,
    transition = 150,
    redraw = FALSE
  ) |>
  animation_slider(
    currentvalue = list(prefix = "Date: ")
  )
```

---

## Performance Optimization

### Frame Limits

**Problem**: Too many frames slow down loading and playback.

**Solution strategies:**

**1. Limit total frames**
```r
# Instead of 100 years of monthly data (1200 frames)
# Use yearly data (100 frames)
data_yearly <- data |>
  group_by(year) |>
  summarize(across(everything(), mean))

plot_ly(data_yearly, frame = ~year)
```

**2. Sample frames**
```r
# Keep every 5th frame
data_sampled <- data |>
  filter(frame_num %% 5 == 0)

plot_ly(data_sampled, frame = ~frame_num)
```

**Guidelines:**
- **< 30 frames**: Optimal (smooth playback)
- **30-60 frames**: Good (acceptable performance)
- **60-100 frames**: OK (may have slight delays)
- **> 100 frames**: Problematic (consider sampling)

### Data Aggregation

**Problem**: Too many points per frame cause rendering lag.

**Solution strategies:**

**1. Aggregate data**
```r
# Instead of 10,000 points per frame
# Aggregate to 100 bins
data_binned <- data |>
  mutate(x_bin = cut(x, breaks = 100)) |>
  group_by(frame, x_bin) |>
  summarize(
    x = mean(x),
    y = mean(y),
    .groups = "drop"
  )

plot_ly(data_binned, x = ~x, y = ~y, frame = ~frame)
```

**2. Use WebGL for scatter plots**
```r
# WebGL renderer handles large datasets better
plot_ly(large_data, x = ~x, y = ~y, frame = ~frame,
        type = "scattergl",  # Note: scattergl not scatter
        mode = "markers")
```

**3. Reduce point size/opacity**
```r
# Smaller markers render faster
plot_ly(data, x = ~x, y = ~y, frame = ~frame,
        marker = list(size = 2, opacity = 0.5))
```

**Guidelines per frame:**
- **< 1,000 points**: No problem
- **1,000-5,000 points**: Use `scattergl` or reduce size
- **5,000-10,000 points**: Aggregate if possible
- **> 10,000 points**: Definitely aggregate

### Optimized Animation Settings

**Use `redraw = FALSE` when possible:**
```r
# Faster for continuous data with consistent structure
animation_opts(frame = 200, transition = 150, redraw = FALSE)
```

**Reduce transition time for many frames:**
```r
# Quick transitions prevent frame buildup
animation_opts(frame = 100, transition = 50)
```

**Disable slider for auto-playing animations:**
```r
# Slider can slow down large animations
plot_ly(data, frame = ~frame) |>
  animation_slider(visible = FALSE)
```

### Complete Optimized Example

```r
library(plotly)
library(dplyr)

# Large dataset: 50 frames × 5000 points each = 250,000 total points
set.seed(123)
large_data <- expand.grid(
  frame_id = 1:50,
  point_id = 1:5000
) |>
  mutate(
    x = rnorm(n()),
    y = rnorm(n()) + frame_id * 0.1
  )

# BEFORE optimization: 250k points, slow!
# plot_ly(large_data, x = ~x, y = ~y, frame = ~frame_id)

# AFTER optimization:
# 1. Sample frames (every 5th) = 10 frames
# 2. Aggregate to 100 bins per frame = 1000 total points
# 3. Use scattergl
# 4. Set redraw = FALSE
optimized_data <- large_data |>
  filter(frame_id %% 5 == 0) |>                    # 1. Sample frames
  mutate(
    x_bin = cut(x, breaks = 20),
    y_bin = cut(y, breaks = 20)
  ) |>
  group_by(frame_id, x_bin, y_bin) |>
  summarize(                                         # 2. Aggregate
    x = mean(x),
    y = mean(y),
    count = n(),
    .groups = "drop"
  )

plot_ly(optimized_data,
        x = ~x,
        y = ~y,
        frame = ~frame_id,
        size = ~count,                               # Size by point count
        type = "scattergl",                          # 3. WebGL
        mode = "markers",
        marker = list(sizemode = "diameter", sizeref = 0.1)) |>
  animation_opts(
    frame = 300,
    transition = 200,
    redraw = FALSE                                   # 4. No redraw
  ) |>
  animation_slider(visible = FALSE)                  # Hide slider

# Result: Smooth animation, 250x fewer points!
```

### Performance Checklist

Before deploying an animation:

- [ ] **Frames**: < 60 frames total
- [ ] **Points**: < 5,000 points per frame
- [ ] **Use `scattergl`** for scatter plots > 1,000 points
- [ ] **Set `redraw = FALSE`** for continuous data
- [ ] **Aggregate** data when possible
- [ ] **Sample** frames if needed
- [ ] **Test** in target browser/environment
- [ ] **Consider** hiding slider for auto-play

---

## Tips and Best Practices

### General Animation Tips

1. **Tell a story**: Animation should reveal insight, not just add motion
2. **Keep it simple**: Fewer frames with clear transitions > many busy frames
3. **Consistent scales**: Fix axis ranges to prevent confusing scale changes
4. **Use `ids`**: Always specify `ids` for entity tracking
5. **Test timing**: Adjust frame/transition duration based on audience and complexity
6. **Add context**: Use titles, annotations, current value indicators

### Common Pitfalls

❌ **Don't:**
- Animate for the sake of animating (use when it adds value)
- Use too many frames (> 100)
- Forget to set `ids` for tracking entities
- Use automatic y-axis ranges (causes jumpy animations)
- Animate large datasets without optimization

✅ **Do:**
- Use animation to show temporal change or progression
- Keep frames under 60 when possible
- Always use `ids = ~entity_column` for tracking
- Fix axis ranges: `layout(xaxis = list(range = c(min, max)))`
- Aggregate or sample large datasets

### When to Use Animation

**Good use cases:**
- Temporal evolution (time series, trends)
- Ranking changes (racing bar charts)
- Geographic spread (disease, migration)
- Cumulative growth (sales, users)
- Comparisons over time (before/after, scenarios)

**Poor use cases:**
- Static comparisons (use facets instead)
- Complex multi-variable relationships (use interactivity instead)
- When print output needed (animation doesn't export to static formats)

---

## See Also

- **Interactivity Reference**: [interactivity-reference.md](interactivity-reference.md) - Hover, click, selection events
- **Chart Types Reference**: [chart-types-reference.md](chart-types-reference.md) - All available plot types
- **Shiny Integration**: [shiny-integration-reference.md](shiny-integration-reference.md) - Reactive animations in dashboards
- **Layout & Styling**: [layout-styling-reference.md](layout-styling-reference.md) - Customize appearance

---

*This reference is part of the r-plotly skill. For main skill documentation, see SKILL.md*
