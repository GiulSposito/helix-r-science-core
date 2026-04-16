# Basic Shiny App Template
# A minimal but complete Shiny app structure

library(shiny)
library(dplyr)
library(ggplot2)

# =============================================================================
# UI
# =============================================================================

ui <- fluidPage(
  # App title
  titlePanel("My Shiny App"),

  # Sidebar layout
  sidebarLayout(
    # Sidebar panel for inputs
    sidebarPanel(
      width = 3,

      h3("Controls"),

      selectInput(
        "dataset",
        "Choose a dataset:",
        choices = c("mtcars", "iris", "faithful")
      ),

      selectInput(
        "variable",
        "Choose a variable:",
        choices = NULL  # Will be updated based on dataset
      ),

      numericInput(
        "bins",
        "Number of bins (for histograms):",
        value = 30,
        min = 5,
        max = 50
      ),

      actionButton(
        "update",
        "Update Plot",
        class = "btn-primary"
      )
    ),

    # Main panel for outputs
    mainPanel(
      width = 9,

      tabsetPanel(
        tabPanel("Plot",
          plotOutput("plot", height = "500px")
        ),

        tabPanel("Summary",
          verbatimTextOutput("summary")
        ),

        tabPanel("Data",
          dataTableOutput("table")
        )
      )
    )
  )
)

# =============================================================================
# Server
# =============================================================================

server <- function(input, output, session) {

  # Reactive: Load selected dataset
  data <- reactive({
    switch(input$dataset,
      "mtcars" = mtcars,
      "iris" = iris,
      "faithful" = faithful
    )
  })

  # Update variable choices when dataset changes
  observe({
    choices <- names(data())
    updateSelectInput(session, "variable", choices = choices)
  })

  # Event-reactive: Only update when button clicked
  plotData <- eventReactive(input$update, {
    req(input$variable)
    data()[[input$variable]]
  })

  # Output: Histogram
  output$plot <- renderPlot({
    req(plotData())

    hist(
      plotData(),
      breaks = input$bins,
      main = paste("Histogram of", input$variable),
      xlab = input$variable,
      col = "steelblue",
      border = "white"
    )
  })

  # Output: Statistical summary
  output$summary <- renderPrint({
    req(input$variable)
    summary(data()[[input$variable]])
  })

  # Output: Data table
  output$table <- renderDataTable({
    data()
  }, options = list(pageLength = 10))
}

# =============================================================================
# Run App
# =============================================================================

shinyApp(ui = ui, server = server)
