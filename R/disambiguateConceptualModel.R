disambiguateConceptualModel <- function(conceptualModel, dv, inputFilePath, dataPath) {
  require(shiny)

  # Process input JSON file
  jsonData <- read_json(inputFilePath) # Relative path to input.json file that processConceptualModel outputs
  dvName <- jsonData$dvName
  dvType <- jsonData$dvType
  dvOptions <- jsonData$dvOptions

  # Read data file, if available
  df <- NULL
  if (!is.null(dataPath)) {
    df <- read.csv(dataPath)
  }

  # Specify App UI
  ui = fluidPage(
    tags$script(src = "conceptualModelDisambiguation.js"),

    titlePanel("rTisane: Conceptual Modeling"),

    sidebarLayout(

      # Sidebar panel for inputs ----
      sidebarPanel(),
      # sidebarPanel(
      #
      #   # Input: Slider for DV  ----
      #   # sliderInput(inputId = "dvType",
      #   #             label = "Number of bins:",
      #   #             min = 1,
      #   #             max = 50,
      #   #             value = 30)
      #
      #   p(paste("Dependent variable:", dvName)),
      #   selectInput("dvType", "", choices = unique(dvOptions)),
      #   # selectInput("customername", "Customer", choices = NULL),
      #   # selectInput("ordernumber", "Order number", choices = NULL),
      #   tableOutput("data")
      # ),

      # Main panel for displaying outputs ----
      mainPanel(
        # Info about dependent variable ---
        p(paste("Dependent variable:", dvName)),
        p(paste(dvName, " looks like this:")),
        plotOutput('dvHist'),
        selectInput("dvType", paste("How do you want to treat", dvName, "?"), choices = unique(dvOptions)),

        # selectInput("customername", "Customer", choices = NULL),
        # selectInput("ordernumber", "Order number", choices = NULL),
        tableOutput("data")
        # Output: Histogram ----

      )
    ),

    actionButton("stop", "Done!")
  )

  server = function(input, output) {

    # User input values to store and process at the end of disambiguation
    userInput <- reactiveValues(
      dvName = NULL,
      dvType = NULL
    )
    # React to updated dvType
    # re <- reactive({
    #   output$dvType
    # })


    # Visualize DV if there is data
    if (!is.null(df)) {
      output$dvHist <- renderPlot({
        input$newplot
        plot(cars2)
      })
    }

    # Capture the updated DV data type
    observeEvent(input$dvType, {
      userInput$dvName <- dvName
      userInput$dvType <- input$dvType
    })

    # Store saved values and close app
    observe({
      if (input$stop) {
        # Update conceptual model
        dvUpdated <- updateDV(dv, userInput)
        cmUpdated <- updateConceptualModel(conceptualModel, userInput)

        # Make named list of values to return
        res <- list(updatedDV = dvUpdated, updatedConceptualModel = cmUpdated)
        stopApp(res) # returns whatever is passed as a parameter
      }

    })
  }
  # Run the application
  # shinyApp(ui = ui, server = server)
  runApp(shinyApp(ui = ui, server = server))
}

# disambiguateConceptualModel <- function(conceptualModel, inputFilePath, dataPath) {
#   userInput <- NULL
#   getUserInput(conceptualModel, inputFilePath, dataPath, userInput)
# }
