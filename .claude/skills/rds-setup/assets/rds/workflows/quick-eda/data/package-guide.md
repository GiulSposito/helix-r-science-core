# Package Guide for Quick-EDA

**Version:** 1.0
**Created:** 2026-03-17

---

## Core Packages (Always Installed)

### Tidyverse Core
| Package | Purpose | Key Functions |
|---------|---------|---------------|
| dplyr | Data manipulation | `filter()`, `select()`, `mutate()`, `summarise()`, `group_by()` |
| tidyr | Data reshaping | `pivot_longer()`, `pivot_wider()`, `separate()`, `unite()` |
| readr | Data import | `read_csv()`, `read_tsv()`, `write_csv()` |
| ggplot2 | Visualization | `ggplot()`, `geom_*()`, `theme_*()` |
| purrr | Functional programming | `map()`, `map_df()`, `walk()` |
| tibble | Modern data frames | `tibble()`, `as_tibble()`, `glimpse()` |
| stringr | String manipulation | `str_detect()`, `str_replace()`, `str_extract()` |
| forcats | Factor handling | `fct_reorder()`, `fct_lump()`, `fct_relevel()` |

### Project Utilities
| Package | Purpose | Key Functions |
|---------|---------|---------------|
| here | Path management | `here()` — always works regardless of WD |
| fs | File system operations | `dir_create()`, `file_copy()`, `path_file()` |

### Quick Cleaning
| Package | Purpose | Key Functions |
|---------|---------|---------------|
| janitor | Name cleaning & tabulations | `clean_names()`, `remove_empty()`, `tabyl()` |
| naniar | Missing data visualization | `miss_var_summary()`, `gg_miss_var()`, `gg_miss_upset()` |
| skimr | Comprehensive summaries | `skim()` — one-function EDA |

### Visualization Extras
| Package | Purpose | Key Functions |
|---------|---------|---------------|
| patchwork | Combine plots | `+`, `/`, `|`, `plot_layout()` |
| scales | Scale formatting | `percent()`, `comma()`, `dollar()` |

### Reporting
| Package | Purpose | Key Functions |
|---------|---------|---------------|
| quarto | Document rendering | `quarto_render()` |
| rmarkdown | R Markdown (alternative) | `render()` |

---

## Import Packages (Install as Needed)

### File Formats

| Data Type | Package | Import Function | When to Use |
|-----------|---------|-----------------|-------------|
| CSV/TSV | readr | `read_csv()`, `read_tsv()` | Standard tabular data |
| Large CSV (>100MB) | vroom | `vroom()` | Fast import, lazy loading |
| Excel | readxl | `read_excel()` | .xlsx, .xls files |
| SPSS | haven | `read_spss()` | .sav files |
| Stata | haven | `read_stata()` | .dta files |
| SAS | haven | `read_sas()` | .sas7bdat files |
| JSON | jsonlite | `fromJSON()` | API data, nested structures |
| XML | xml2 | `read_xml()` | XML documents |
| Parquet | arrow | `read_parquet()` | Large columnar data |
| Feather | arrow | `read_feather()` | Fast R/Python interchange |
| RDS | base | `readRDS()` | R native format |
| RData | base | `load()` | Multiple R objects |

### Database Connections

| Database | Package | Connection | Query |
|----------|---------|------------|-------|
| PostgreSQL | RPostgres | `dbConnect(Postgres())` | `dbGetQuery()` |
| MySQL | RMySQL | `dbConnect(MySQL())` | `dbGetQuery()` |
| SQLite | RSQLite | `dbConnect(SQLite())` | `dbGetQuery()` |
| SQL Server | odbc | `dbConnect(odbc())` | `dbGetQuery()` |
| Generic | DBI | `dbConnect()` | `dbGetQuery()`, `dbReadTable()` |

### Web Data

| Source | Package | Function | Use Case |
|--------|---------|----------|----------|
| Web scraping | rvest | `read_html()`, `html_table()` | Extract tables from HTML |
| APIs | httr | `GET()`, `POST()` | RESTful API access |
| Google Sheets | googlesheets4 | `read_sheet()` | Collaborative data |
| URLs | readr | `read_csv("https://...")` | Direct CSV download |

---

## EDA Packages (Optional Additions)

### Advanced Visualization

| Package | Purpose | Key Functions | Install If... |
|---------|---------|---------------|---------------|
| corrplot | Correlation heatmaps | `corrplot()` | Many numeric variables |
| GGally | Scatterplot matrices | `ggpairs()` | Need multivariate viz |
| plotly | Interactive plots | `ggplotly()` | Want interactivity |
| patchwork | Combine plots | `wrap_plots()` | Multiple plot layouts |
| ggridges | Ridgeline plots | `geom_density_ridges()` | Compare distributions |
| ggdist | Distribution viz | `stat_halfeye()` | Bayesian/uncertainty |

### Data Exploration

| Package | Purpose | Key Functions | Install If... |
|---------|---------|---------------|---------------|
| DataExplorer | Automated EDA | `create_report()` | Want automated report |
| inspectdf | Dataset comparison | `inspect_na()`, `inspect_types()` | Compare datasets |
| summarytools | Detailed summaries | `dfSummary()` | Need rich HTML summaries |
| visdat | Data structure viz | `vis_dat()`, `vis_miss()` | Visualize data types |

### Statistical Analysis

| Package | Purpose | Key Functions | Install If... |
|---------|---------|---------------|---------------|
| broom | Tidy model outputs | `tidy()`, `glance()`, `augment()` | Running models |
| car | Regression diagnostics | `vif()`, `leveneTest()` | ANOVA/regression |
| psych | Psychometric analysis | `describe()`, `alpha()` | Scales/questionnaires |

---

## Performance Packages (Large Data)

### Fast Data Manipulation

| Package | Purpose | When to Use |
|---------|---------|-------------|
| data.table | Lightning-fast manipulation | Datasets > 1M rows |
| dtplyr | dplyr syntax on data.table | Want speed + dplyr syntax |
| collapse | Ultra-fast aggregation | Complex grouping operations |

### Parallel Processing

| Package | Purpose | When to Use |
|---------|---------|-------------|
| furrr | Parallel purrr | Slow `map()` operations |
| future | Async evaluation | Long-running tasks |
| parallel | Base parallelization | Built-in parallel processing |

### Memory Management

| Package | Purpose | When to Use |
|---------|---------|-------------|
| arrow | Memory-mapped data | Datasets > RAM |
| disk.frame | Out-of-memory workflows | Cannot load full dataset |
| vroom | Lazy loading | Large CSVs |

---

## Specialized Data Types

### Time Series

| Package | Purpose | Key Functions |
|---------|---------|---------------|
| lubridate | Date/time manipulation | `ymd()`, `floor_date()`, `interval()` |
| tsibble | Tidy time series | `as_tsibble()`, `index_by()` |
| fable | Time series models | `ARIMA()`, `ETS()` |
| zoo | Irregular time series | `zoo()`, `rollmean()` |

### Text Data

| Package | Purpose | Key Functions |
|---------|---------|---------------|
| tidytext | Tidy text mining | `unnest_tokens()`, `bind_tf_idf()` |
| stringr | String operations | `str_detect()`, `str_extract()` |
| textrecipes | Text feature engineering | `step_tokenize()`, `step_tf()` |

### Geospatial

| Package | Purpose | Key Functions |
|---------|---------|---------------|
| sf | Simple features | `st_read()`, `st_as_sf()` |
| leaflet | Interactive maps | `leaflet()`, `addTiles()` |
| tmap | Thematic maps | `tm_shape()`, `tm_polygons()` |

### Network Data

| Package | Purpose | Key Functions |
|---------|---------|---------------|
| igraph | Network analysis | `graph_from_data_frame()`, `degree()` |
| tidygraph | Tidy networks | `as_tbl_graph()` |
| ggraph | Network visualization | `ggraph()`, `geom_edge_link()` |

---

## Installation Strategies

### Minimal Install (Quick-EDA Default)
```r
# ~15 packages, < 5 minutes
essential <- c(
  "dplyr", "tidyr", "readr", "ggplot2", "purrr",
  "tibble", "stringr", "forcats", "here", "fs",
  "skimr", "janitor", "naniar", "patchwork", "scales"
)
renv::install(essential)
```

### Standard Install (Recommended)
```r
# ~25 packages, 10-15 minutes
standard <- c(
  essential,
  "readxl", "haven",           # Import
  "corrplot", "GGally",        # EDA viz
  "lubridate", "quarto"        # Dates & reporting
)
renv::install(standard)
```

### Full Install (Comprehensive)
```r
# ~40+ packages, 20-30 minutes
full <- c(
  standard,
  "vroom", "arrow",            # Performance
  "DataExplorer", "visdat",    # Auto-EDA
  "plotly", "DT",              # Interactivity
  "broom", "car"               # Statistics
)
renv::install(full)
```

### On-Demand Install
```r
# Install only what you need when you need it
if (!requireNamespace("readxl", quietly = TRUE)) {
  renv::install("readxl")
}
```

---

## Package Conflicts & Solutions

### Common Conflicts

| Conflict | Solution |
|----------|----------|
| `filter()` — dplyr vs stats | Use `dplyr::filter()` or `library(dplyr)` after stats |
| `select()` — dplyr vs MASS | Use `dplyr::select()` or load MASS before dplyr |
| `lag()` — dplyr vs stats | Use `dplyr::lag()` explicitly |
| `here()` — here vs lubridate | Always use `here::here()` |

### Load Order (Recommended)
```r
# 1. Base packages
library(here)
library(fs)

# 2. Tidyverse (loads core packages)
library(tidyverse)

# 3. Tidyverse extensions
library(janitor)
library(skimr)
library(naniar)

# 4. Visualization
library(patchwork)
library(scales)

# 5. Domain-specific (as needed)
library(readxl)
library(haven)
library(corrplot)
```

---

## renv Management

### Common renv Commands
```r
# Initialize (bare = faster, minimal packages)
renv::init(bare = TRUE)

# Install packages
renv::install("package_name")

# Update all packages
renv::update()

# Check status
renv::status()

# Save current state
renv::snapshot()

# Restore to saved state
renv::restore()

# Remove unused packages
renv::clean()
```

### Troubleshooting renv

| Problem | Solution |
|---------|----------|
| Install too slow | Use binary packages: `options(pkgType = "binary")` |
| Package not found | Check CRAN mirror: `options(repos = "https://cran.r-project.org")` |
| Version conflicts | Use `renv::restore()` to reset |
| Lock file corrupt | Delete `renv.lock`, run `renv::snapshot()` again |

---

## Performance Tips

1. **Install binaries first** (much faster)
   ```r
   options(pkgType = "binary")
   ```

2. **Use local CRAN mirror** (faster downloads)
   ```r
   options(repos = "https://cran.rstudio.com/")
   ```

3. **Parallel installation** (renv default)
   - Already enabled, no action needed

4. **Skip dependencies you don't need**
   ```r
   renv::install("package", dependencies = c("Depends", "Imports"))
   ```

5. **Use pak for faster installs** (alternative)
   ```r
   install.packages("pak")
   pak::pak("tidyverse/dplyr")
   ```

---

_Package guide created on 2026-03-17 for quick-eda workflow_
