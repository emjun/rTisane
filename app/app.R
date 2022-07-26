library(shiny)
library(tisaner)
source("../R/queryScript.R")
ui <- fluidPage(
  shinyjs::useShinyjs(), # Set up shinyjs
  selectInput("dataset", label = "Dataset", choices = ls("package:datasets")),
  verbatimTextOutput("variables"),
  tableOutput("table"),

  actionButton("nextButton", "Run Query Script")
)

server <- function(input, output, session) {
  # Create a reactive expression
  dataset <- reactive({
    get(input$dataset, "package:datasets")
  })

  output$variables <- renderPrint({
    # Use a reactive expression by calling it like a function
    summary(dataset())
  })

  output$table <- renderTable({
    dataset()
  })

  # output$nextButton <- reactive({
  #   # doSomething()
  #   print("in script")
  # })

  onclick("nextButton", logjs(inferLinkFunctions("gaussian")))
}

shinyApp(ui, server)
