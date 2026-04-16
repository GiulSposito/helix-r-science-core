# Chart Types Reference - Part 2

Complete documentation for comparison, composition, geographic, 3D, and specialized chart types in plotly.

---

## Comparison Visualizations

Charts for comparing values across categories or groups.

### Bar Charts

**Basic vertical bar chart** - Compare values across discrete categories.

```r
# Simple bar chart
plot_ly(data, x = ~category, y = ~value, type = "bar")

# Styled bar chart
plot_ly(data, x = ~category, y = ~value, type = "bar",
        marker = list(color = "steelblue", line = list(color = "navy", width = 2)))
```

**Horizontal bar chart** - Better for long category names.

```r
plot_ly(data, x = ~value, y = ~category, type = "bar", orientation = "h")
```

**Key parameters:**

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `x`, `y` | formula | Axes mapping | Required |
| `orientation` | string | "v" for vertical, "h" for horizontal | "v" |
| `marker` | list | Marker styling (color, line, opacity) | Auto |
| `width` | numeric | Bar width (0-1) | Auto |
| `text` | formula | Text labels on bars | None |
| `textposition` | string | Label position: "inside", "outside", "auto" | "auto" |

**When to use:**
- Comparing magnitudes across categories
- Showing rankings or ordered data
- Categorical data with clear groupings

### Grouped Bar Charts

**Multiple series side-by-side** - Compare across categories AND groups.

```r
# Grouped bars
plot_ly(data, x = ~category, y = ~value, color = ~group, type = "bar") |>
  layout(barmode = "group")

# With custom colors
plot_ly(data, x = ~category, y = ~value, color = ~group, type = "bar",
        colors = c("#1f77b4", "#ff7f0e", "#2ca02c")) |>
  layout(barmode = "group", bargap = 0.15, bargroupgap = 0.1)
```

**Key layout parameters:**

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `barmode` | string | "group", "stack", "relative", "overlay" | "stack" |
| `bargap` | numeric | Gap between bar groups (0-1) | 0.2 |
| `bargroupgap` | numeric | Gap within a group (0-1) | 0 |

**When to use:**
- Comparing multiple metrics across same categories
- Side-by-side year/year comparisons
- A/B test results across segments

### Stacked Bar Charts

**Cumulative composition** - Show part-to-whole relationships.

```r
# Stacked bars
plot_ly(data, x = ~category, y = ~value, color = ~segment, type = "bar") |>
  layout(barmode = "stack")

# 100% stacked (normalized)
data_pct <- data |>
  group_by(category) |>
  mutate(pct = value / sum(value) * 100)

plot_ly(data_pct, x = ~category, y = ~pct, color = ~segment, type = "bar") |>
  layout(
    barmode = "stack",
    yaxis = list(title = "Percentage", ticksuffix = "%")
  )
```

**When to use:**
- Showing composition over categories
- Comparing totals AND proportions
- Budget breakdowns, market share by segment

### Waterfall Charts

**Cumulative effect** - Show how sequential values add up to a total.

```r
# Waterfall for financial statement
data <- data.frame(
  measure = c("relative", "relative", "relative", "relative", "total"),
  x = c("Sales", "COGS", "Operating", "Taxes", "Net Income"),
  y = c(200, -80, -40, -20, 60),
  text = c("+200", "-80", "-40", "-20", "60")
)

plot_ly(data, x = ~x, y = ~y, measure = ~measure, type = "waterfall",
        text = ~text, textposition = "outside",
        connector = list(line = list(color = "gray", dash = "dot"))) |>
  layout(
    title = "Income Statement Waterfall",
    yaxis = list(title = "Amount ($M)"),
    showlegend = FALSE
  )
```

**Measure types:**

| Measure | Description |
|---------|-------------|
| `"relative"` | Floating bar from previous total |
| `"total"` | Bar from zero to current cumulative |
| `"absolute"` | Bar from zero to specified value |

**Key parameters:**

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `measure` | formula | Type of each bar ("relative", "total", "absolute") | "relative" |
| `base` | numeric | Starting value | 0 |
| `connector` | list | Line connecting bars (visible, line) | Visible |
| `increasing` | list | Style for positive changes (marker color) | Green |
| `decreasing` | list | Style for negative changes (marker color) | Red |
| `totals` | list | Style for total bars (marker color) | Blue |

**When to use:**
- Financial statements (income, cash flow)
- Budget variance analysis
- Sequential contribution analysis

### Funnel Charts

**Conversion stages** - Show progressive reduction through process stages.

```r
# Marketing funnel
funnel_data <- data.frame(
  stage = c("Visitors", "Signups", "Trials", "Paying", "Retained"),
  value = c(10000, 3000, 800, 200, 150),
  pct = c(100, 30, 8, 2, 1.5)
)

plot_ly(funnel_data, y = ~stage, x = ~value, type = "funnel",
        text = ~paste0(value, " (", pct, "%)"),
        textposition = "inside",
        marker = list(color = c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd"))) |>
  layout(
    title = "Conversion Funnel",
    yaxis = list(categoryorder = "array", categoryarray = funnel_data$stage)
  )

# Horizontal funnel (stacked area style)
plot_ly(funnel_data, x = ~value, y = ~stage, type = "funnel",
        orientation = "h")
```

**Key parameters:**

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `x`, `y` | formula | Values and stage labels | Required |
| `orientation` | string | "v" or "h" | "v" |
| `marker` | list | Color, line styling | Auto |
| `textinfo` | string | "value", "percent", "label+value+percent" | "label+percent" |

**When to use:**
- Sales or marketing funnels
- Manufacturing yield analysis
- Multi-stage process flows

---

## Composition Visualizations

Charts showing part-to-whole relationships.

### Pie Charts

**Simple proportions** - Classic circular composition view.

```r
# Basic pie chart
plot_ly(data, labels = ~category, values = ~value, type = "pie")

# Styled pie with pulled slices
plot_ly(data, labels = ~category, values = ~value, type = "pie",
        pull = c(0, 0.1, 0, 0),  # Pull second slice out
        marker = list(colors = c("#636EFA", "#EF553B", "#00CC96", "#AB63FA"),
                      line = list(color = "white", width = 2)),
        textinfo = "label+percent",
        textposition = "inside",
        hoverinfo = "label+value+percent") |>
  layout(title = "Market Share by Company")
```

**Key parameters:**

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `labels` | formula | Category names | Required |
| `values` | formula | Values for each slice | Required |
| `pull` | numeric vector | How far to pull each slice (0-1) | 0 |
| `hole` | numeric | Size of center hole (0-1) for donut | 0 |
| `direction` | string | "clockwise" or "counterclockwise" | "counterclockwise" |
| `rotation` | numeric | Starting angle in degrees | 0 |
| `textinfo` | string | "label", "value", "percent", or combinations | "label+percent" |
| `textposition` | string | "inside", "outside", "auto" | "auto" |

**When to use:**
- Simple composition (< 6 categories)
- Showing dominant category
- Non-technical audiences

**Avoid when:**
- Many small slices (hard to compare)
- Need precise value comparison (use bar chart)
- Comparing multiple compositions (use stacked bars)

### Donut Charts

**Pie with center space** - Modern alternative to pie charts.

```r
# Donut with custom center annotation
plot_ly(data, labels = ~category, values = ~value, type = "pie",
        hole = 0.4,
        marker = list(colors = RColorBrewer::brewer.pal(5, "Set2"))) |>
  layout(
    title = "Revenue Composition",
    annotations = list(
      text = paste0("Total<br>$", sum(data$value), "M"),
      x = 0.5, y = 0.5,
      font = list(size = 20, color = "gray"),
      showarrow = FALSE
    )
  )
```

**When to use:**
- Same as pie charts
- When you need center space for total/label
- More modern aesthetic

### Sunburst Charts

**Hierarchical composition** - Multi-level nested circles showing hierarchy.

```r
# Two-level hierarchy
hierarchy_data <- data.frame(
  labels = c("Total", "North", "South", "East", "West",
             "N-1", "N-2", "S-1", "S-2", "E-1", "W-1"),
  parents = c("", "Total", "Total", "Total", "Total",
              "North", "North", "South", "South", "East", "West"),
  values = c(100, 30, 25, 25, 20, 15, 15, 10, 15, 25, 20)
)

plot_ly(hierarchy_data, labels = ~labels, parents = ~parents, values = ~values,
        type = "sunburst", branchvalues = "total") |>
  layout(title = "Sales by Region and Subregion")

# Three-level with color control
plot_ly(hierarchy_data, labels = ~labels, parents = ~parents, values = ~values,
        type = "sunburst",
        marker = list(colorscale = "Blues"),
        branchvalues = "total",
        textinfo = "label+value+percent parent") |>
  layout(margin = list(l = 0, r = 0, t = 40, b = 0))
```

**Key parameters:**

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `labels` | formula | Node names | Required |
| `parents` | formula | Parent of each node ("" for root) | Required |
| `values` | formula | Node values | Required |
| `branchvalues` | string | "total" or "remainder" | "remainder" |
| `textinfo` | string | Info to display on sectors | "label+value+percent parent" |
| `maxdepth` | numeric | Levels to show (-1 for all) | -1 |

**When to use:**
- Multi-level hierarchies (organization, file systems)
- Budget breakdowns with categories and subcategories
- Drill-down exploration of composition

### Treemap Charts

**Rectangular hierarchy** - Space-filling rectangles for hierarchy.

```r
# Treemap with hierarchy
plot_ly(hierarchy_data, labels = ~labels, parents = ~parents, values = ~values,
        type = "treemap", branchvalues = "total") |>
  layout(title = "Budget Allocation")

# Styled treemap
plot_ly(hierarchy_data, labels = ~labels, parents = ~parents, values = ~values,
        type = "treemap",
        marker = list(colorscale = "Viridis", cmid = 50),
        textinfo = "label+value+percent parent",
        pathbar = list(visible = TRUE)) |>
  layout(margin = list(l = 0, r = 0, t = 40, b = 0))
```

**Key parameters:**

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `labels` | formula | Node names | Required |
| `parents` | formula | Parent of each node | Required |
| `values` | formula | Node values (determines size) | Required |
| `branchvalues` | string | "total" or "remainder" | "remainder" |
| `pathbar` | list | Show breadcrumb path (visible) | Visible |
| `tiling` | list | Layout algorithm (packing, squarify, etc.) | "squarify" |

**When to use:**
- Same as sunburst but with more space for labels
- Comparing many small categories in hierarchy
- File system visualization, portfolio allocation

---

## Geographic Visualizations

Maps for spatial data analysis.

### Choropleth Maps

**Region coloring** - Color regions by data values (states, countries).

```r
# US state choropleth
library(dplyr)

state_data <- data.frame(
  state = state.abb,
  value = rnorm(50, 100, 20)
)

plot_ly(state_data, type = "choropleth",
        locations = ~state,
        locationmode = "USA-states",
        z = ~value,
        colorscale = "Viridis",
        colorbar = list(title = "Value")) |>
  layout(
    title = "State-Level Data",
    geo = list(scope = "usa")
  )

# World choropleth
country_data <- data.frame(
  country = c("USA", "CAN", "MEX", "BRA", "ARG"),
  value = c(100, 80, 60, 90, 70)
)

plot_ly(country_data, type = "choropleth",
        locations = ~country,
        locationmode = "ISO-3",
        z = ~value,
        colorscale = "Blues") |>
  layout(
    title = "Country-Level Data",
    geo = list(projection = list(type = "natural earth"))
  )
```

**Key parameters:**

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `locations` | formula | Location identifiers | Required |
| `locationmode` | string | "ISO-3", "USA-states", "country names" | "ISO-3" |
| `z` | formula | Values to color by | Required |
| `colorscale` | string/list | Color scale name or custom | "RdBu" |
| `colorbar` | list | Colorbar configuration | Default |
| `geo` | string | Reference to geo layout object | "geo" |

**Geo layout options:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `scope` | string | "world", "usa", "europe", "asia", "africa", "north america", "south america" |
| `projection` | list | Map projection (type: "mercator", "orthographic", "natural earth", etc.) |
| `showland` | logical | Show land masses |
| `landcolor` | string | Color for land |
| `showcountries` | logical | Show country borders |

**When to use:**
- Regional aggregates (sales by state, population by country)
- Election results, demographics
- Regional performance comparisons

### Scatter Geo Maps

**Points on map** - Plot lat/lon coordinates with markers.

```r
# City locations with sizes
cities <- data.frame(
  city = c("New York", "Los Angeles", "Chicago", "Houston", "Phoenix"),
  lat = c(40.7128, 34.0522, 41.8781, 29.7604, 33.4484),
  lon = c(-74.0060, -118.2437, -87.6298, -95.3698, -112.0740),
  population = c(8.3, 3.9, 2.7, 2.3, 1.7)
)

plot_ly(cities, lat = ~lat, lon = ~lon, type = "scattergeo",
        mode = "markers+text",
        text = ~city,
        marker = list(size = ~population * 5, color = "red", sizemode = "diameter"),
        textposition = "top center") |>
  layout(
    title = "US Cities by Population",
    geo = list(
      scope = "usa",
      projection = list(type = "albers usa"),
      showland = TRUE,
      landcolor = toRGB("gray95"),
      countrycolor = toRGB("gray80")
    )
  )

# Flight routes with lines
routes <- data.frame(
  origin_lat = c(40.7128, 34.0522),
  origin_lon = c(-74.0060, -118.2437),
  dest_lat = c(51.5074, 48.8566),
  dest_lon = c(-0.1278, 2.3522)
)

plot_ly(routes, lat = ~origin_lat, lon = ~origin_lon, type = "scattergeo",
        mode = "lines+markers",
        line = list(width = 2, color = "red")) |>
  add_trace(lat = ~dest_lat, lon = ~dest_lon, mode = "markers",
            marker = list(size = 10, color = "blue"))
```

**Key parameters:**

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `lat`, `lon` | formula | Latitude/longitude coordinates | Required |
| `mode` | string | "markers", "lines", "markers+lines", "text" | "markers" |
| `marker` | list | Marker styling (size, color, symbol) | Default |
| `line` | list | Line styling for routes | Default |

**When to use:**
- Store locations, branch offices
- Flight/shipping routes
- Point-specific data on map

### Mapbox Maps

**Modern map tiles** - High-quality base maps with Mapbox tiles.

```r
# Setup: Get free token at mapbox.com
Sys.setenv("MAPBOX_TOKEN" = "your_token_here")

# Scatter mapbox
plot_ly(cities, lat = ~lat, lon = ~lon, type = "scattermapbox",
        mode = "markers+text",
        text = ~city,
        marker = list(size = 15, color = "red")) |>
  layout(
    mapbox = list(
      style = "open-street-map",  # or "light", "dark", "satellite"
      zoom = 3,
      center = list(lat = 37, lon = -95)
    )
  )

# Density heatmap on mapbox
plot_ly(lat = ~lat, lon = ~lon, type = "densitymapbox",
        radius = 20,
        colorscale = "Viridis") |>
  layout(
    mapbox = list(
      style = "light",
      zoom = 10,
      center = list(lat = 40.7, lon = -74)
    )
  )
```

**Mapbox styles:**

| Style | Description | Token Required? |
|-------|-------------|-----------------|
| `"open-street-map"` | Free OpenStreetMap tiles | No |
| `"white-bg"` | Blank white background | No |
| `"carto-positron"` | Light Carto basemap | No |
| `"carto-darkmatter"` | Dark Carto basemap | No |
| `"light"`, `"dark"` | Mapbox standard styles | Yes |
| `"satellite"`, `"satellite-streets"` | Satellite imagery | Yes |

**Setup Mapbox token:**

```r
# Option 1: Environment variable
Sys.setenv("MAPBOX_TOKEN" = "pk.your_token")

# Option 2: In layout
layout(mapbox = list(accesstoken = "pk.your_token", style = "light"))
```

**When to use:**
- Modern, professional map appearance
- Need custom map styles
- High zoom levels with detail
- Mobile/web applications

---

## 3D Visualizations

Three-dimensional charts for spatial and volumetric data.

### 3D Scatter Plots

**3D point clouds** - Explore relationships in three dimensions.

```r
# Basic 3D scatter
plot_ly(mtcars, x = ~wt, y = ~hp, z = ~mpg, type = "scatter3d", mode = "markers",
        marker = list(size = 5, color = ~cyl, colorscale = "Viridis",
                      showscale = TRUE, colorbar = list(title = "Cylinders"))) |>
  layout(
    scene = list(
      xaxis = list(title = "Weight"),
      yaxis = list(title = "Horsepower"),
      zaxis = list(title = "MPG")
    )
  )

# With text labels
plot_ly(mtcars, x = ~wt, y = ~hp, z = ~mpg, type = "scatter3d",
        mode = "markers+text",
        text = row.names(mtcars),
        marker = list(size = 5, color = "red"))
```

**Key parameters:**

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `x`, `y`, `z` | formula | Three-dimensional coordinates | Required |
| `mode` | string | "markers", "lines", "markers+lines", "text" | "markers" |
| `marker` | list | Size, color, symbol, colorscale | Default |
| `line` | list | Line width and color | Default |

**When to use:**
- Multivariate relationships (3+ variables)
- Spatial point data
- Cluster analysis visualization

### 3D Line Plots

**3D trajectories** - Show paths or sequences in 3D space.

```r
# 3D parametric curve
t <- seq(0, 4*pi, length.out = 100)
spiral_data <- data.frame(
  x = cos(t),
  y = sin(t),
  z = t
)

plot_ly(spiral_data, x = ~x, y = ~y, z = ~z, type = "scatter3d",
        mode = "lines",
        line = list(width = 4, color = ~z, colorscale = "Viridis")) |>
  layout(
    title = "3D Spiral",
    scene = list(
      camera = list(
        eye = list(x = 1.5, y = 1.5, z = 1.5)
      )
    )
  )

# Multiple 3D paths
plot_ly(type = "scatter3d", mode = "lines") |>
  add_trace(x = ~x1, y = ~y1, z = ~z1, line = list(color = "red", width = 3),
            name = "Path 1") |>
  add_trace(x = ~x2, y = ~y2, z = ~z2, line = list(color = "blue", width = 3),
            name = "Path 2")
```

**When to use:**
- Flight paths, trajectories
- Time series in 3D space
- Parametric curves, mathematical functions

### 3D Surface Plots

**Continuous surfaces** - Visualize z = f(x, y) functions.

```r
# Function surface
x <- seq(-5, 5, length.out = 50)
y <- seq(-5, 5, length.out = 50)
z <- outer(x, y, function(x, y) sin(sqrt(x^2 + y^2)) / sqrt(x^2 + y^2 + 0.1))

plot_ly(x = ~x, y = ~y, z = ~z, type = "surface",
        colorscale = "Viridis",
        contours = list(
          z = list(show = TRUE, usecolormap = TRUE, project = list(z = TRUE))
        )) |>
  layout(
    title = "3D Surface Plot",
    scene = list(
      xaxis = list(title = "X"),
      yaxis = list(title = "Y"),
      zaxis = list(title = "Z")
    )
  )

# Terrain-style surface
plot_ly(x = ~x, y = ~y, z = ~z, type = "surface",
        colorscale = list(c(0, "blue"), c(0.5, "green"), c(1, "red")),
        lighting = list(ambient = 0.4, diffuse = 0.6, specular = 0.3))
```

**Key parameters:**

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `x`, `y` | vector | Grid coordinates | Required |
| `z` | matrix | Height values (nrow = length(x), ncol = length(y)) | Required |
| `colorscale` | string/list | Color mapping for height | "Viridis" |
| `contours` | list | Contour line configuration | None |
| `lighting` | list | Light source parameters | Default |
| `opacity` | numeric | Surface transparency (0-1) | 1 |

**When to use:**
- Mathematical functions of two variables
- Terrain/elevation data
- Response surfaces in optimization
- Heatmaps in 3D

### 3D Mesh Plots

**3D shapes** - Custom 3D geometries with triangular meshes.

```r
# Simple tetrahedron
vertices <- data.frame(
  x = c(0, 1, 0.5, 0.5),
  y = c(0, 0, sqrt(3)/2, sqrt(3)/6),
  z = c(0, 0, 0, sqrt(6)/3)
)

faces <- data.frame(
  i = c(0, 0, 0, 1),
  j = c(1, 2, 3, 2),
  k = c(2, 3, 1, 3)
)

plot_ly(x = vertices$x, y = vertices$y, z = vertices$z,
        i = faces$i, j = faces$j, k = faces$k,
        type = "mesh3d",
        opacity = 0.8,
        color = "lightblue")
```

**When to use:**
- Custom 3D shapes and models
- Molecular structures
- Engineering CAD visualization

### Camera and Scene Configuration

**Control 3D view** - Set camera position and scene properties.

```r
plot_ly(data, x = ~x, y = ~y, z = ~z, type = "scatter3d") |>
  layout(
    scene = list(
      # Camera position
      camera = list(
        eye = list(x = 1.87, y = 0.88, z = -0.64),  # Camera location
        center = list(x = 0, y = 0, z = 0),          # Look-at point
        up = list(x = 0, y = 0, z = 1)               # Up direction
      ),

      # Axes configuration
      xaxis = list(title = "X", range = c(-5, 5), showgrid = TRUE),
      yaxis = list(title = "Y", range = c(-5, 5)),
      zaxis = list(title = "Z", range = c(0, 10)),

      # Aspect ratio
      aspectmode = "cube",  # or "auto", "data", "manual"
      aspectratio = list(x = 1, y = 1, z = 0.5),

      # Background
      bgcolor = "#f5f5f5"
    )
  )
```

**Camera presets:**

```r
# Top-down view
camera = list(eye = list(x = 0, y = 0, z = 2.5))

# Side view
camera = list(eye = list(x = 2.5, y = 0, z = 0))

# Isometric view
camera = list(eye = list(x = 1.5, y = 1.5, z = 1.5))
```

---

## Specialized Charts

Advanced chart types for specific use cases.

### Heatmaps

**Matrix visualization** - Color-coded grid for two-dimensional data.

```r
# Correlation heatmap
cor_matrix <- cor(mtcars[, c("mpg", "cyl", "disp", "hp", "wt")])

plot_ly(x = colnames(cor_matrix),
        y = rownames(cor_matrix),
        z = cor_matrix,
        type = "heatmap",
        colorscale = "RdBu",
        zmid = 0,
        text = round(cor_matrix, 2),
        hovertemplate = "%{y} vs %{x}<br>Correlation: %{z:.2f}<extra></extra>") |>
  layout(
    title = "Correlation Matrix",
    xaxis = list(side = "bottom"),
    yaxis = list(autorange = "reversed")  # Origin at top
  )

# Time series heatmap (calendar view)
dates <- seq(as.Date("2023-01-01"), as.Date("2023-12-31"), by = "day")
values <- rnorm(length(dates), 50, 10)

date_matrix <- matrix(values, nrow = 7)  # 7 rows = days of week

plot_ly(z = date_matrix, type = "heatmap",
        colorscale = "Viridis",
        colorbar = list(title = "Value"))
```

**Key parameters:**

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `x`, `y` | vector | Axis labels | Row/col indices |
| `z` | matrix | Values to color (nrow x ncol) | Required |
| `colorscale` | string/list | Color mapping | "Viridis" |
| `zmid` | numeric | Center value for diverging scales | NULL |
| `showscale` | logical | Show colorbar | TRUE |
| `text` | matrix | Custom text for cells | NULL |

**When to use:**
- Correlation matrices
- Confusion matrices in ML
- Calendar heatmaps (day x week)
- Gene expression data

### Contour Plots

**Isolines** - Lines connecting points of equal value.

```r
# Function contours
x <- seq(-2, 2, length.out = 100)
y <- seq(-2, 2, length.out = 100)
z <- outer(x, y, function(x, y) x^2 + y^2)

plot_ly(x = ~x, y = ~y, z = ~z, type = "contour",
        colorscale = "Jet",
        contours = list(
          showlabels = TRUE,
          labelfont = list(size = 12, color = "white")
        ),
        colorbar = list(title = "Value")) |>
  layout(
    title = "Contour Plot: x² + y²",
    xaxis = list(title = "X"),
    yaxis = list(title = "Y")
  )

# Filled contours
plot_ly(x = ~x, y = ~y, z = ~z, type = "contour",
        contours = list(coloring = "heatmap"))  # or "lines", "fill"
```

**Contour options:**

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `coloring` | string | "heatmap", "lines", "fill", "none" | "fill" |
| `showlabels` | logical | Show value labels on lines | FALSE |
| `start` | numeric | First contour level | Auto |
| `end` | numeric | Last contour level | Auto |
| `size` | numeric | Spacing between levels | Auto |

**When to use:**
- Topographic maps
- Optimization landscapes
- Probability density visualization

### Sankey Diagrams

**Flow visualization** - Show flows between nodes with proportional widths.

```r
# Simple Sankey
sankey_data <- list(
  node = list(
    label = c("Source A", "Source B", "Middle", "End 1", "End 2"),
    color = c("blue", "blue", "green", "red", "red")
  ),
  link = list(
    source = c(0, 1, 2, 2),    # Node indices (0-based)
    target = c(2, 2, 3, 4),
    value = c(50, 30, 40, 40)
  )
)

plot_ly(type = "sankey",
        orientation = "h",
        node = sankey_data$node,
        link = sankey_data$link) |>
  layout(title = "Flow Diagram")

# Budget flow example
budget <- list(
  node = list(
    label = c("Revenue", "Products", "Services", "COGS", "Opex", "Profit"),
    color = rep("lightblue", 6)
  ),
  link = list(
    source = c(0, 0, 1, 1, 2, 2),
    target = c(1, 2, 3, 5, 4, 5),
    value = c(700, 300, 400, 300, 150, 150)
  )
)

plot_ly(type = "sankey", node = budget$node, link = budget$link) |>
  layout(title = "Budget Allocation")
```

**Key parameters:**

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `node` | list | Node labels and colors | Required |
| `link` | list | Source, target, value for each flow | Required |
| `orientation` | string | "h" or "v" | "h" |
| `valueformat` | string | Number format for values | ".3s" |

**When to use:**
- Budget allocation flows
- User journey mapping
- Energy/material flow analysis
- Network traffic visualization

### Parallel Coordinates

**Multivariate profiles** - Show multiple variables per observation.

```r
# Iris dataset parallel coordinates
plot_ly(iris, type = "parcoords",
        line = list(color = ~as.numeric(Species),
                    colorscale = list(c(0, "red"), c(0.5, "green"), c(1, "blue"))),
        dimensions = list(
          list(label = "Sepal Length", values = ~Sepal.Length),
          list(label = "Sepal Width", values = ~Sepal.Width),
          list(label = "Petal Length", values = ~Petal.Length),
          list(label = "Petal Width", values = ~Petal.Width)
        )) |>
  layout(title = "Iris Dataset - Parallel Coordinates")

# With custom ranges
plot_ly(mtcars, type = "parcoords",
        line = list(color = ~mpg, colorscale = "Viridis", showscale = TRUE),
        dimensions = list(
          list(label = "MPG", values = ~mpg, range = c(10, 35)),
          list(label = "Cylinders", values = ~cyl, range = c(4, 8)),
          list(label = "Weight", values = ~wt, range = c(1, 6)),
          list(label = "HP", values = ~hp, range = c(50, 350))
        ))
```

**Key parameters:**

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `dimensions` | list | List of dimension configs (label, values, range) | Required |
| `line` | list | Line color mapping and colorscale | Default |

**When to use:**
- High-dimensional data exploration (5-10 variables)
- Finding patterns across many attributes
- Comparing observation profiles
- Feature selection in ML

### Candlestick Charts

**Financial OHLC** - Open, High, Low, Close price visualization.

```r
# Stock price candlestick
stock_data <- data.frame(
  date = seq(as.Date("2024-01-01"), by = "day", length.out = 50),
  open = runif(50, 95, 105),
  high = runif(50, 100, 110),
  low = runif(50, 90, 100),
  close = runif(50, 95, 105)
)

plot_ly(stock_data, type = "candlestick",
        x = ~date,
        open = ~open, high = ~high, low = ~low, close = ~close,
        increasing = list(line = list(color = "green")),
        decreasing = list(line = list(color = "red"))) |>
  layout(
    title = "Stock Price",
    xaxis = list(title = "Date", rangeslider = list(visible = TRUE)),
    yaxis = list(title = "Price ($)")
  )

# OHLC bars (alternative to candlestick)
plot_ly(stock_data, type = "ohlc",
        x = ~date,
        open = ~open, high = ~high, low = ~low, close = ~close)
```

**Key parameters:**

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `open`, `high`, `low`, `close` | formula | OHLC price data | Required |
| `increasing` | list | Style for up days (line color) | Green |
| `decreasing` | list | Style for down days (line color) | Red |

**When to use:**
- Stock price analysis
- Forex trading charts
- Any OHLC time series data

### Range Slider

**Add interactive range selector** - Works with any x-axis.

```r
# Time series with range slider
plot_ly(data, x = ~date, y = ~value, type = "scatter", mode = "lines") |>
  layout(
    xaxis = list(
      rangeslider = list(
        visible = TRUE,
        thickness = 0.1,  # Height as fraction of plot
        bgcolor = "#f5f5f5",
        bordercolor = "gray",
        borderwidth = 1
      )
    )
  )
```

**When to use:**
- Long time series (months to years)
- Need to zoom into specific periods
- Financial charts

---

## Chart Type Decision Tree

**Choose chart based on data type and goal:**

```
1. What are you showing?
   ├─ Comparison across categories
   │  ├─ Single series → Bar chart
   │  ├─ Multiple series → Grouped or stacked bars
   │  └─ Sequential contribution → Waterfall
   │
   ├─ Distribution of values
   │  ├─ Single variable → Histogram or box plot
   │  └─ Multiple variables → Multiple box plots or violin
   │
   ├─ Relationship between variables
   │  ├─ Two continuous → Scatter plot
   │  ├─ Three continuous → 3D scatter or bubble chart
   │  └─ Over time → Line plot
   │
   ├─ Part-to-whole composition
   │  ├─ Simple (< 6 parts) → Pie or donut
   │  ├─ Hierarchical → Sunburst or treemap
   │  └─ Over time → Stacked area or bar
   │
   ├─ Geographic patterns
   │  ├─ Regional aggregates → Choropleth
   │  ├─ Point locations → Scatter geo or scatter mapbox
   │  └─ Routes/connections → Line geo
   │
   ├─ Flows and networks
   │  ├─ Between stages → Sankey diagram
   │  └─ Conversion funnel → Funnel chart
   │
   └─ High-dimensional data
      ├─ Correlation → Heatmap
      ├─ Surface function → 3D surface or contour
      └─ Many variables per obs → Parallel coordinates
```

---

## Performance Considerations

### Large Dataset Optimization

```r
# Use scattergl for > 10k points
plot_ly(large_data, x = ~x, y = ~y, type = "scattergl", mode = "markers")

# Aggregate before plotting
aggregated <- large_data |>
  group_by(bin = cut(x, breaks = 100)) |>
  summarize(y_mean = mean(y), y_sd = sd(y))

# Use heatmap2d instead of scatter for dense data
plot_ly(large_data, x = ~x, y = ~y, type = "histogram2d")
```

### Best Practices

1. **Limit complexity**: Keep to < 20 traces per plot
2. **Simplify data**: Round to reasonable precision
3. **Use WebGL types**: `scattergl`, `scatter3d` for large data
4. **Reduce points**: Downsample time series when appropriate
5. **Lazy load**: In Shiny, use renderPlotly with caching

---

## Summary Table: When to Use Each Chart Type

| Chart Type | Best For | Data Structure | Max Categories |
|-----------|----------|----------------|----------------|
| Bar | Category comparison | Long format | 20-30 |
| Grouped bar | Multi-series comparison | Long with groups | 5 groups x 10 cats |
| Stacked bar | Composition over categories | Long with segments | 5-8 segments |
| Waterfall | Sequential contribution | Wide with measure types | 10-15 steps |
| Funnel | Conversion stages | Wide, ordered stages | 5-8 stages |
| Pie | Simple composition | Labels + values | 4-6 slices |
| Sunburst | Hierarchical composition | Labels + parents + values | Unlimited |
| Treemap | Hierarchical size | Labels + parents + values | Unlimited |
| Choropleth | Regional aggregates | Locations + values | 50-200 regions |
| Scatter geo | Point locations | Lat/lon + values | 100-1000 points |
| 3D scatter | Multivariate relationships | x, y, z columns | 1000s points |
| 3D surface | Continuous function | x, y vectors + z matrix | 100x100 grid |
| Heatmap | Matrix patterns | x, y vectors + z matrix | 50x50 typical |
| Contour | Function isolines | x, y vectors + z matrix | 100x100 grid |
| Sankey | Flow between nodes | Node list + link list | 20-30 nodes |
| Parallel coords | High-dimensional profiles | Wide format, many columns | 5-15 dimensions |
| Candlestick | Financial OHLC | Date + OHLC columns | 100-1000 periods |

---

**Next Steps:**
- For layout and styling details: [layout-styling-reference.md](layout-styling-reference.md)
- For interactivity patterns: [interactivity-reference.md](interactivity-reference.md)
- For working examples: [examples/basic-plots-gallery.md](../examples/basic-plots-gallery.md)
