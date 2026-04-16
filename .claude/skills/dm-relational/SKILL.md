---
name: dm-relational
description: Relational data modeling with {dm} package - create, visualize, and manipulate multi-table data models with primary/foreign keys. Use when mentions "dm package", "pacote dm", "relational data", "dados relacionais", "primary key", "chave primária", "foreign key", "chave estrangeira", "data model", "modelo de dados", "multi-table", "múltiplas tabelas", "tabelas relacionadas", "relate tables", "relacionar tabelas", "database schema", "esquema de banco", "esquema de dados", "dm_from_data_frames", "dm_add_pk", "dm_add_fk", "dm_draw", "dm_flatten", "dm_filter", "dm_zoom_to", "visualize schema", "visualizar esquema", "create data model", "criar modelo", "model relational data", "modelar dados relacionais", "work with related data", "trabalhar com dados relacionados", "multiple related tables", "várias tabelas relacionadas", or working with related data frames, relational databases, or referential integrity in R.
version: 1.1.0
user-invocable: false
allowed-tools: Read, Grep, Glob
---

# Relational Data Modeling with {dm}

*Best practices for working with the {dm} package for relational data structures in R*

## Core Principles

1. **Think relationally** - Model data with multiple connected tables, not single wide tables
2. **Define keys explicitly** - Always specify primary and foreign keys to establish relationships
3. **Visualize early** - Use `dm_draw()` frequently to understand your data model structure
4. **Validate constraints** - Check data integrity with `dm_examine_constraints()` before analysis
5. **Leverage cascading operations** - Let dm propagate filters and joins through relationships

## What is dm?

The **dm** package bridges individual data frames and relational databases, enabling you to:

- Work with multiple related tables as a single coherent object
- Automatically track relationships via primary and foreign keys
- Scale from in-memory data frames to billion-row database tables
- Perform intelligent joins that leverage existing relationships
- Maintain data integrity through constraint validation

### Philosophy

**"Use it for data analysis today. Build data models tomorrow. Deploy the data models to your organization's RDBMS the day after."**

The dm package serves as a bridge in data pipelines - start with local data frames for prototyping, evolve into structured models, and ultimately deploy to production databases. It functions as a **named list of tables** that works seamlessly with dplyr verbs while adding relational model features.

## Creating dm Objects

### From Data Frames

```r
library(dm)

# Initialize dm from multiple data frames
my_dm <- dm(
  customers,
  orders,
  products
)

# Add primary keys
my_dm <- my_dm |>
  dm_add_pk(customers, customer_id) |>
  dm_add_pk(orders, order_id) |>
  dm_add_pk(products, product_id)

# Add foreign keys to establish relationships
my_dm <- my_dm |>
  dm_add_fk(orders, customer_id, customers) |>
  dm_add_fk(orders, product_id, products)

# Visualize the model
my_dm |> dm_draw()
```

### From Databases

```r
# Connect to database and load entire model
con <- DBI::dbConnect(RPostgres::Postgres(), ...)
my_dm <- dm_from_con(con)

# Keys are AUTOMATICALLY imported for: Postgres, SQL Server, MariaDB
# For other databases, add keys manually

# Load without automatic key detection
my_dm <- dm_from_con(con, learn_keys = FALSE)

# Load specific tables only
my_dm <- dm(
  customers = tbl(con, "customers"),
  orders = tbl(con, "orders")
)

# Then add keys manually
my_dm <- my_dm |>
  dm_add_pk(customers, customer_id) |>
  dm_add_fk(orders, customer_id, customers)
```

### Discovering Keys

```r
# Find valid primary key candidates
my_dm |> dm_enum_pk_candidates(orders)

# Check if column(s) can serve as primary key
orders |> check_key(order_id)

# Find valid foreign key candidates
my_dm |> dm_enum_fk_candidates(orders, customers)

# Verify foreign key relationship exists
my_dm |> check_subset(orders, customer_id, customers, customer_id)
```

## Key Management

### Primary Keys

```r
# Add primary key
my_dm <- my_dm |> dm_add_pk(table_name, key_column)

# Compound primary key (multiple columns)
my_dm <- my_dm |> dm_add_pk(table_name, c(col1, col2))

# Check if table has primary key
my_dm |> dm_has_pk(table_name)

# Get primary key columns
my_dm |> dm_get_pk(table_name)

# Get all primary keys in model
my_dm |> dm_get_all_pks()

# Remove primary key
my_dm <- my_dm |> dm_rm_pk(table_name)
```

### Unique Keys (UK)

**Unique keys differ from primary keys:**

- A table can have **only one PK** but **unlimited UKs**
- PKs support autoincrement; UKs do not
- When copying to database, PKs are set by default; UKs are ignored
- UKs are useful for delta load processes and documenting additional uniqueness constraints

```r
# Add unique key
my_dm <- my_dm |> dm_add_uk(table_name, unique_column)

# Multiple unique keys allowed
my_dm <- my_dm |>
  dm_add_uk(users, email) |>
  dm_add_uk(users, username)

# Get all unique keys
my_dm |> dm_get_all_uks()

# Remove unique key
my_dm <- my_dm |> dm_rm_uk(table_name, unique_column)
```

### Foreign Keys

```r
# Add foreign key relationship
my_dm <- my_dm |>
  dm_add_fk(
    child_table,
    child_column,
    parent_table
  )

# Compound foreign key
my_dm <- my_dm |>
  dm_add_fk(
    child_table,
    c(col1, col2),
    parent_table
  )

# Check if foreign key exists
my_dm |> dm_has_fk(child_table, parent_table)

# Get all foreign keys
my_dm |> dm_get_all_fks()

# Remove foreign key
my_dm <- my_dm |> dm_rm_fk(child_table, parent_table)
```

## Visualization

```r
# Draw complete data model diagram
my_dm |> dm_draw()

# Control what columns are shown
my_dm |> dm_draw(view_type = "keys_only")  # Default - only keys
my_dm |> dm_draw(view_type = "all")        # All columns
my_dm |> dm_draw(view_type = "title_only") # Only table names

# Customize colors by table (supports tidyselect)
my_dm <- my_dm |>
  dm_set_colors(
    maroon4 = flights,
    orange = starts_with("air"),
    lightblue = customers
  )

# View diagram with custom colors
my_dm |> dm_draw()

# Get current color scheme
my_dm |> dm_get_colors()

# Get available color names
dm_get_available_colors()

# Interactive Shiny GUI (experimental)
my_dm |> dm_gui()
# Opens interactive app for defining dm objects
# Generates R code you can copy/paste
```

## Filtering with Cascading

**Key Feature**: Filters automatically propagate through foreign key relationships

```r
# Filter flights from specific airport - automatically filters related tables
flights_dm |>
  dm_filter(airports, name == "John F Kennedy Intl") |>
  dm_apply_filters()

# Multiple filters cascade through relationships
flights_dm |>
  dm_filter(carriers, name == "Delta Air Lines Inc.") |>
  dm_filter(airports, city == "New York") |>
  dm_apply_filters()

# Cascading filters use semi-joins internally
# Only related records in connected tables are retained
```

### How Cascading Works

Filtering uses **successive semi-joins** along relationship paths:

> "filtering semi-joins are successively performed along the paths from each of the filtered tables to the requested table, each join reducing the left-hand side tables of the joins to only those of their rows with key values that have corresponding values in key columns of the right-hand side tables"

For database-backed dm objects, filters generate optimized SQL with nested `WHERE EXISTS` clauses.

**Important**: The foreign key graph must be **cycle-free** for filtering to work.

## Joining and Flattening

### Flatten to Single Table

```r
# Join two directly related tables
flights_dm |>
  dm_flatten_to_tbl(flights, airlines, .join = left_join)

# Specify starting table and recursively flatten all related tables
flights_dm |>
  dm_flatten_to_tbl(.start = flights, .recursive = TRUE)

# Flatten only direct neighbors (default)
flights_dm |>
  dm_flatten_to_tbl(.start = flights, .recursive = FALSE)

# Use different join types
flights_dm |>
  dm_flatten_to_tbl(flights, planes, .join = inner_join)

# Anti-join for validation (find unmatched records)
flights_dm |>
  dm_flatten_to_tbl(flights, weather, .join = anti_join)

# Automatic column renaming for conflicts
# e.g., "name" becomes "name.airlines" and "name.airports"
```

### Advantages of dm Joins

- Automatically uses foreign key columns (no need to specify `by =`)
- Handles column name conflicts with automatic renaming
- Cleaner code than manual dplyr joins
- Maintains referential integrity

## Zoom Workflow

**Use zoom to focus on one table while preserving relationships**

```r
# Enter zoom mode on specific table
zoomed_dm <- my_dm |>
  dm_zoom_to(orders)

# Apply dplyr operations
zoomed_dm <- zoomed_dm |>
  mutate(total_price = quantity * unit_price) |>
  filter(status == "completed")

# Exit zoom - three options:

# 1. Update original table
my_dm <- zoomed_dm |> dm_update_zoomed()

# 2. Insert as new table
my_dm <- zoomed_dm |> dm_insert_zoomed("completed_orders")

# 3. Discard changes
my_dm <- zoomed_dm |> dm_discard_zoomed()
```

### When to Use Zoom

- Adding computed columns to tables
- Creating surrogate keys
- Building summary/aggregate tables
- Enriching tables with joins
- Resolving cyclic relationships

### Supported Operations in Zoom

- **Data transformation:** `mutate()`, `transmute()`, `select()`, `relocate()`, `rename()`, `filter()`, `arrange()`, `slice()`, `distinct()`
- **Grouping:** `summarise()`, `group_by()`, `ungroup()`
- **Joins:** `left_join()`, `inner_join()`, `full_join()`, `right_join()`, `semi_join()`, `anti_join()`
- **tidyr:** `unite()`, `separate()`

### Important: Key Tracking

**Keys are tracked by column names** - if you rename a key column, the relationship may be lost and need manual re-establishment with `dm_add_pk()` or `dm_add_fk()`.

## Database Operations

### Copy to Database

```r
# Copy entire dm to database
con <- DBI::dbConnect(...)
copy_dm_to(con, my_dm, temporary = FALSE)

# Avoid naming conflicts with custom table names
copy_dm_to(
  con,
  my_dm,
  table_names = ~ paste0("project_", .x)
)

# Copy with temporary tables (default)
copy_dm_to(con, my_dm, temporary = TRUE)
```

### Materialize Computed Tables

```r
# Compute intermediate results to avoid repeated queries
my_dm |>
  dm_zoom_to(orders) |>
  filter(year == 2023) |>
  compute() |>  # Materializes as temp table on database
  dm_insert_zoomed("orders_2023")
```

### Collect from Database

```r
# Bring data into memory
local_dm <- my_dm |> collect()

# Extract specific table
orders_local <- my_dm |> pull_tbl(orders) |> collect()
```

### Row Operations (Insert/Update/Delete)

**All `dm_rows_*()` functions follow the same workflow:**

1. Create a changeset dm with rows to modify
2. Copy changeset to same database as destination
3. **Simulate first** with `in_place = FALSE` (default)
4. Execute with `in_place = TRUE` to persist changes

```r
# Insert new rows (ignores existing PKs)
dm_rows_insert(
  target_dm,
  changeset_dm,
  in_place = FALSE  # Simulate first!
)

# Update existing rows (requires matching PKs)
dm_rows_update(
  target_dm,
  changeset_dm,
  in_place = FALSE
)

# Delete rows (processes children before parents)
# Currently works only with local R objects
dm_rows_delete(
  target_dm,
  changeset_dm,
  in_place = FALSE
)
```

**Important:** You are responsible for setting database transactions to ensure integrity across multiple tables.

## Validation and Constraints

```r
# Examine all constraints
my_dm |> dm_examine_constraints()

# Returns table showing:
# - Which primary keys are valid (no duplicates)
# - Which foreign keys are valid (referential integrity)
# - Which constraints are violated

# Examine relationship cardinalities
my_dm |> dm_examine_cardinalities()

# Returns cardinality types:
# - 0_n: zero to many (one-to-many, allows multiple children per parent)
# - 1_n: one to many (surjective, requires at least one child per parent)
# - 0_1: zero to one (injective, allows zero or one child per parent)
# - 1_1: one to one (bijective, exactly one child per parent)

# Check specific cardinalities
check_cardinality_0_n(parent_table, parent_col, child_table, child_col)
check_cardinality_1_n(parent_table, parent_col, child_table, child_col)
check_cardinality_0_1(parent_table, parent_col, child_table, child_col)
check_cardinality_1_1(parent_table, parent_col, child_table, child_col)

# Discover cardinality automatically
examine_cardinality(parent_table, parent_col, child_table, child_col)
```

## Table Management

```r
# Add new table
my_dm <- my_dm |> dm_add_tbl(new_table_df)

# Remove table
my_dm <- my_dm |> dm_rm_tbl(table_name)

# Rename table
my_dm <- my_dm |> dm_rename_tbl(new_name = old_name)

# Select subset of tables
my_dm <- my_dm |> dm_select_tbl(customers, orders)

# Extract single table
customers_tbl <- my_dm |> pull_tbl(customers)

# Extract with key tracking (experimental)
keyed_tbl <- my_dm |> pull_tbl(customers, keyed = TRUE)
# Returns dm_keyed_tbl with PK/FK metadata preserved

# Update table with modified version (experimental)
my_dm <- my_dm |>
  dm_mutate_tbl(orders = orders |> filter(year >= 2020))

# Get number of rows per table
my_dm |> dm_nrow()

# Get metadata
my_dm |> dm_get_tables()  # List of table names
my_dm |> dm_get_con()     # Database connection

# Generate code to extract all tables as variables
dm_deconstruct(my_dm)
# Produces code like: customers <- pull_tbl(my_dm, customers, keyed = TRUE)
```

## Column Operations

```r
# Select columns across tables
my_dm <- my_dm |>
  dm_select(orders, order_id, customer_id, total) |>
  dm_select(customers, customer_id, name)

# Rename columns in specific table
my_dm <- my_dm |>
  dm_rename(orders, order_date = date)

# Add table descriptions (metadata)
my_dm <- my_dm |>
  dm_set_table_description(
    orders = "Customer orders with line items",
    customers = "Customer master data"
  )
```

## Normalization

```r
# Decompose table into parent-child relationship (normalization)
# Splits table into lookup table (parent) and observation table (child)
decomposed <- orders |>
  decompose_table(
    new_id_column,
    customer_name,
    customer_email
  )

# Returns list with:
# - parent_table: unique combinations (lookup table)
# - child_table: original table with foreign key to parent

# Reunite normalized tables (denormalization)
reunited <- reunite_parent_child(
  child_table,
  parent_table,
  id_column
)

# Reunite from list structure
reunited <- reunite_parent_child_from_list(decomposed_list)
```

## Best Practices

### Model Design

- **Start simple** - Begin with core tables and relationships
- **Normalize appropriately** - Avoid redundant data, but don't over-normalize
- **Document relationships** - Use `dm_draw()` as living documentation
- **Check cardinalities** - Understand if relationships are 1:1, 1:many, many:many

### Development Workflow

```r
# 1. Create dm from data frames or database
my_dm <- dm(...)

# 2. Define keys
my_dm <- my_dm |>
  dm_add_pk(...) |>
  dm_add_fk(...)

# 3. Visualize
my_dm |> dm_draw()

# 4. Validate
my_dm |> dm_examine_constraints()

# 5. Work with data (filter, zoom, flatten)
my_dm |>
  dm_filter(...) |>
  dm_flatten_to_tbl(...)
```

### Database Connection Management

**Important**: Database connections don't serialize. Always wrap dm creation in functions:

```r
# Good - Function recreates connection
get_my_dm <- function() {
  con <- DBI::dbConnect(...)
  dm_from_con(con)
}

my_dm <- get_my_dm()

# Bad - Connection will break after save/load
my_dm <- dm_from_con(con)
saveRDS(my_dm, "model.rds")  # Connection won't work after loading
```

### Performance Tips

- Use `compute()` for expensive intermediate results in database queries
- Check `dm_nrow()` before calling `collect()` on large tables
- Filter early and often before flattening
- Use lazy evaluation - only materialize when necessary
- For large databases, work with filtered subsets

### Memory Management

```r
# Check table sizes before collecting
my_dm |> dm_nrow()

# Filter before collecting
small_dm <- my_dm |>
  dm_filter(orders, year == 2023) |>
  dm_apply_filters()

# Collect only what you need
small_dm |> collect()
```

## Common Patterns

### Pattern 1: Load, Validate, Visualize

```r
# Load from database
my_dm <- dm_from_con(con)

# Validate integrity
constraints <- my_dm |> dm_examine_constraints()

if (any(!constraints$is_valid)) {
  warning("Constraint violations detected!")
  print(constraints |> filter(!is_valid))
}

# Visualize
my_dm |> dm_draw()
```

### Pattern 2: Build from Scratch

```r
# Create from data frames
my_dm <- dm(
  customers = customers_df,
  orders = orders_df,
  products = products_df
)

# Add structure
my_dm <- my_dm |>
  # Primary keys
  dm_add_pk(customers, customer_id) |>
  dm_add_pk(orders, order_id) |>
  dm_add_pk(products, product_id) |>
  # Foreign keys
  dm_add_fk(orders, customer_id, customers) |>
  dm_add_fk(orders, product_id, products)

# Verify
my_dm |> dm_examine_constraints()
```

### Pattern 3: Filter and Flatten

```r
# Filter related tables
filtered_dm <- my_dm |>
  dm_filter(customers, country == "USA") |>
  dm_filter(orders, year == 2023) |>
  dm_apply_filters()

# Flatten to analysis table
analysis_tbl <- filtered_dm |>
  dm_flatten_to_tbl(orders, .recursive = TRUE)
```

### Pattern 4: Zoom for Derived Tables

```r
# Create summary table using zoom
my_dm <- my_dm |>
  dm_zoom_to(orders) |>
  group_by(customer_id) |>
  summarise(
    total_orders = n(),
    total_spent = sum(amount)
  ) |>
  ungroup() |>
  dm_insert_zoomed("customer_summary")

# Add relationships for new table
my_dm <- my_dm |>
  dm_add_pk(customer_summary, customer_id) |>
  dm_add_fk(customer_summary, customer_id, customers)
```

### Pattern 5: Database Deployment

```r
# Build model locally
local_dm <- dm(table1, table2, table3) |>
  dm_add_pk(...) |>
  dm_add_fk(...)

# Validate before deployment
local_dm |> dm_examine_constraints()

# Deploy to database
con <- DBI::dbConnect(...)
copy_dm_to(
  con,
  local_dm,
  temporary = FALSE,
  table_names = ~ paste0("prod_", .x)
)
```

## Antipatterns to Avoid

### ❌ Don't: Skip Key Definition

```r
# Bad - No keys defined
my_dm <- dm(customers, orders)
# Relationships unknown, joins won't work automatically
```

```r
# Good - Define keys explicitly
my_dm <- dm(customers, orders) |>
  dm_add_pk(customers, customer_id) |>
  dm_add_pk(orders, order_id) |>
  dm_add_fk(orders, customer_id, customers)
```

### ❌ Don't: Forget to Validate

```r
# Bad - Assume keys are valid
my_dm <- my_dm |> dm_add_pk(orders, order_id)
```

```r
# Good - Check first
if (orders |> check_key(order_id)) {
  my_dm <- my_dm |> dm_add_pk(orders, order_id)
}
```

### ❌ Don't: Flatten Everything Immediately

```r
# Bad - Loses relational structure
wide_table <- my_dm |> dm_flatten_to_tbl(orders, .recursive = TRUE)
# Now you can't use cascading filters or relationship-aware operations
```

```r
# Good - Keep dm structure, flatten only when needed
analysis_tbl <- my_dm |>
  dm_filter(orders, year == 2023) |>  # Filter in dm context
  dm_flatten_to_tbl(orders, customers)  # Flatten for analysis
```

### ❌ Don't: Collect Large Database Tables

```r
# Bad - Downloads everything
my_dm <- dm_from_con(con) |> collect()
```

```r
# Good - Filter on database, collect only what's needed
my_dm <- dm_from_con(con) |>
  dm_filter(orders, year == 2023) |>
  dm_apply_filters()

small_tbl <- my_dm |> pull_tbl(orders) |> collect()
```

### ❌ Don't: Ignore Cyclic Relationships

```r
# Bad - Creates cycle, breaks filtering
my_dm <- my_dm |>
  dm_add_fk(table_a, id_b, table_b) |>
  dm_add_fk(table_b, id_a, table_a)
# dm_filter won't work with cycles
```

```r
# Good - Break cycles by duplicating table
my_dm <- my_dm |>
  dm_add_tbl(table_b_copy = table_b) |>
  dm_add_fk(table_a, id_b, table_b) |>
  dm_add_fk(table_b_copy, id_a, table_a)
```

## Integration with tidyverse

The dm package works seamlessly with tidyverse:

```r
library(dplyr)
library(tidyr)
library(ggplot2)

# Filter and flatten for visualization
plot_data <- my_dm |>
  dm_filter(orders, year >= 2020) |>
  dm_flatten_to_tbl(orders, customers, products) |>
  collect()

# Use with ggplot2
plot_data |>
  ggplot(aes(x = order_date, y = amount)) +
  geom_line()

# Use pipe operators throughout
result <- my_dm |>
  dm_zoom_to(orders) |>
  filter(status == "completed") |>
  dm_update_zoomed() |>
  dm_flatten_to_tbl(orders, customers)
```

## Sample Data

```r
# NYC flights dataset (most commonly used for examples)
dm_nycflights13()

# Financial sample data
dm_financial()

# Pixar films dataset
dm_pixarfilms()

# Use for learning and testing
flights_dm <- dm_nycflights13()
flights_dm |> dm_draw()
```

## Code Generation and Utilities

```r
# Generate R code to recreate a dm object
my_dm |> dm_paste()
# Outputs code as text that can be copy/pasted

# Create prototype dm object
my_dm |> dm_ptype()

# Generate SQL DDL (Data Definition Language)
my_dm |> dm_sql()

# Generate DDL for specific operations
my_dm |> dm_ddl_pre()    # CREATE TABLE statements

# Generate DML (Data Manipulation Language)
my_dm |> dm_dml_load()   # INSERT statements
```

## Schema Management (Database)

```r
# List available schemas
db_schema_list(con)

# Create schema
db_schema_create(con, "my_schema")

# Drop schema
db_schema_drop(con, "my_schema")
```

## Keyed Tables Workflow (Experimental)

An alternative to zoom for working with individual tables:

```r
# Extract tables with key tracking
customers <- my_dm |> pull_tbl(customers, keyed = TRUE)
orders <- my_dm |> pull_tbl(orders, keyed = TRUE)

# Transform with dplyr/tidyr - keys are preserved
customers_updated <- customers |>
  mutate(full_name = paste(first_name, last_name))

orders_filtered <- orders |>
  filter(year >= 2023)

# Joins automatically use tracked keys (no 'by' needed)
enriched <- orders_filtered |>
  left_join(customers_updated)  # Uses FK automatically

# Reconstruct dm with transformed tables
my_dm <- dm(
  customers = customers_updated,
  orders = orders_filtered
)
# Keys are automatically restored from keyed_tbl metadata
```

## Resources

- **Official Documentation**: https://dm.cynkra.com/
- **GitHub Repository**: https://github.com/cynkra/dm
- **Cheat Sheet**: https://dm.cynkra.com/articles/cheatsheet.html
- **Getting Started Guide**: `vignette("dm")`
- **Current Version**: 1.1.1 (March 2026)

## Quick Reference

| Task | Function |
|------|----------|
| Create dm | `dm()`, `dm_from_con()` |
| Add keys | `dm_add_pk()`, `dm_add_fk()`, `dm_add_uk()` |
| Visualize | `dm_draw()`, `dm_gui()` |
| Validate | `dm_examine_constraints()` |
| Filter | `dm_filter()` |
| Flatten | `dm_flatten_to_tbl()` |
| Zoom | `dm_zoom_to()`, `dm_insert_zoomed()` |
| Copy to DB | `copy_dm_to()` |
| Modify rows | `dm_rows_insert()`, `dm_rows_update()` |
| Collect | `collect()` |
| Get table | `pull_tbl()` |
| Generate code | `dm_paste()`, `dm_deconstruct()` |

---

*Use this skill when working with multiple related data frames, connecting to databases with foreign keys, or building relational data pipelines in R.*
