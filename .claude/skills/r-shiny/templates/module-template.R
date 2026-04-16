# Shiny Module Template
# A reusable, isolated component with namespaced IDs

# =============================================================================
# Module UI Function
# =============================================================================

#' Data Filter Module UI
#'
#' Creates the UI for a data filtering module
#'
#' @param id Character string, the namespace ID for the module
#' @param label Character string, label for the module (default: "Data Filter")
#'
#' @return A tagList containing the UI elements
#'
#' @examples
#' ui <- fluidPage(
#'   mod_data_filter_ui("filter1", label = "Primary Filter")
#' )
mod_data_filter_ui <- function(id, label = "Data Filter") {
  ns <- NS(id)  # Create namespace function

  tagList(
    h3(label),

    selectInput(
      ns("category"),
      "Select Category:",
      choices = NULL  # Will be updated by server
    ),

    sliderInput(
      ns("threshold"),
      "Minimum Value:",
      min = 0,
      max = 100,
      value = 50
    ),

    checkboxInput(
      ns("exclude_na"),
      "Exclude missing values",
      value = TRUE
    ),

    verbatimTextOutput(ns("info"))
  )
}

# =============================================================================
# Module Server Function
# =============================================================================

#' Data Filter Module Server
#'
#' Server logic for the data filtering module
#'
#' @param id Character string, the namespace ID (must match UI)
#' @param data Reactive expression returning a data frame with columns:
#'   - category (character)
#'   - value (numeric)
#' @param initial_threshold Numeric, initial threshold value (default: 50)
#'
#' @return A list with reactive elements:
#'   - filtered_data: Reactive data frame with filtered results
#'   - n_rows: Reactive integer with number of rows
#'   - selected_category: Reactive string with selected category
#'
#' @examples
#' server <- function(input, output, session) {
#'   raw_data <- reactive({ load_data() })
#'
#'   filter_results <- mod_data_filter_server(
#'     "filter1",
#'     data = raw_data,
#'     initial_threshold = 25
#'   )
#'
#'   output$plot <- renderPlot({
#'     plot(filter_results$filtered_data())
#'   })
#' }
mod_data_filter_server <- function(id, data, initial_threshold = 50) {
  # Validate inputs
  stopifnot(is.reactive(data))
  stopifnot(is.numeric(initial_threshold))

  moduleServer(id, function(input, output, session) {

    # Update category choices when data changes
    observe({
      req(data())

      categories <- unique(data()$category)
      updateSelectInput(
        session,
        "category",
        choices = categories
      )
    })

    # Set initial threshold value
    observe({
      updateSliderInput(
        session,
        "threshold",
        value = initial_threshold
      )
    })

    # Reactive: Filter data based on inputs
    filtered <- reactive({
      req(data(), input$category)

      result <- data() %>%
        filter(category == input$category) %>%
        filter(value >= input$threshold)

      if (input$exclude_na) {
        result <- result %>% filter(!is.na(value))
      }

      result
    })

    # Output: Display filtering info
    output$info <- renderPrint({
      cat("Category:", input$category, "\n")
      cat("Threshold:", input$threshold, "\n")
      cat("Rows filtered:", nrow(filtered()), "\n")
      cat("Rows total:", nrow(data()), "\n")
    })

    # Return reactive values for parent app
    return(list(
      filtered_data = reactive({ filtered() }),
      n_rows = reactive({ nrow(filtered()) }),
      selected_category = reactive({ input$category })
    ))
  })
}

# =============================================================================
# Demo App (for testing module)
# =============================================================================

#' Demo App Function
#'
#' Creates a demo app to test the module
#'
#' @export
mod_data_filter_demo <- function() {
  # Sample data
  demo_data <- reactive({
    data.frame(
      category = rep(c("A", "B", "C"), each = 100),
      value = c(
        rnorm(100, mean = 30, sd = 10),
        rnorm(100, mean = 60, sd = 15),
        rnorm(100, mean = 75, sd = 8)
      )
    )
  })

  ui <- fluidPage(
    titlePanel("Data Filter Module Demo"),

    sidebarLayout(
      sidebarPanel(
        # Use module UI
        mod_data_filter_ui("demo_filter", label = "Demo Filter")
      ),

      mainPanel(
        h3("Filtered Data Plot"),
        plotOutput("plot"),

        h3("Filtered Data Table"),
        dataTableOutput("table")
      )
    )
  )

  server <- function(input, output, session) {
    # Use module server
    filter_results <- mod_data_filter_server(
      "demo_filter",
      data = demo_data,
      initial_threshold = 40
    )

    # Use returned reactives
    output$plot <- renderPlot({
      req(nrow(filter_results$filtered_data()) > 0)

      hist(
        filter_results$filtered_data()$value,
        main = paste("Distribution -", filter_results$selected_category()),
        xlab = "Value",
        col = "steelblue",
        border = "white"
      )
    })

    output$table <- renderDataTable({
      filter_results$filtered_data()
    })
  }

  shinyApp(ui, server)
}

# Uncomment to run demo:
# mod_data_filter_demo()
