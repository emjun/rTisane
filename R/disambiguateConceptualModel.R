disambiguateConceptualModel <- function(conceptualModel, dv, inputFilePath, dataPath) {
  require(shiny)
  require(purrr)

  #### Read data file, if available ----
  df <- NULL
  if (!is.null(dataPath)) {
    df <- read.csv(dataPath)
  }

  #### Process input JSON file -----
  # Get DV options
  jsonData <- read_json(inputFilePath) # Relative path to input.json file that processQuery outputs
  dvName <- jsonData$dvName
  dvType <- jsonData$dvType
  dvOptions <- jsonData$dvOptions


  # Get Conceptual model info
  graph <- dagitty( "dag { X <- U1 -- M <- U2 -> Y } " ) 

  # START HERE! GET THE JSON TO GIVE YOU THIS
  uncertainRelationships <- list("When A increases, B increases", "B is related to C")
  optionsAB <- c("A causes B", "B causes A")
  optionsBC <- c("B causes C", "C causes B")
  uncertainOptions <- list("When A increases, B increases"=optionsAB, "B is related to C"=optionsBC)

  # Specify App UI
  ui = fluidPage(
    tags$script(src = "conceptualModelDisambiguation.js"),

    titlePanel("rTisane"),
    textOutput("activeTab"),

    tabsetPanel(
      id = "tabset",
      tabPanel("Dependent variable",
               # fileInput("file", "Data", buttonLabel = "Upload..."),
               # Info about dependent variable ---
               p(paste("Dependent variable:", dvName)),
               p(paste(dvName, " looks like this:")),
               plotOutput('dvHist'),
               selectInput("dvType", paste("How do you want to treat", dvName, "?"), choices = unique(dvOptions)),

               # textInput("delim", "Delimiter (leave blank to guess)", ""),
               # numericInput("skip", "Rows to skip", 0, min = 0),
               # numericInput("rows", "Rows to preview", 10, min = 1)
      ),
      tabPanel("Conceptual model",
               p("This is what your conceptual model looks like:"),
               p("WBN: Visualization of conceptual model, look into dynamic vis"),
               plotOutput('cmGraph'),
               uiOutput("cmQuestions"),
               textOutput("palette")
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

    #### DV -----
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

    #### Conceptual Model -----
    # Dynamically generate/ask questions about under-specified relationships
    output$cmQuestions <- renderUI({
      map(uncertainRelationships, ~ div(
        paste("You wrote that:", .x),
        strong("More specifically, what did you mean?"),
        selectInput(.x, NULL, choices = uncertainOptions[[.x]])
      ))
      # map(col_names(), ~ selectInput(.x, NULL, choices = c("A --> B", "A <-- B")))
    })

    output$palette <- renderText({
      map_chr(uncertainRelationships, ~ input[[.x]] %||% "")
    })

    # Update graph vis 
    output$cmGraph <- renderPlot({
      plot(graphLayout(graph))
    })

    # IDEA: wrap inputs in Div, check if Div updates (attach event to that DIV), then regenerate the graph
    # observeEvent(input$option, {
    #   graph <- getExample('mediator')
    # }, ignoreInit = TRUE) # try removing ignoreInit? What does the parameter do anyway? 
    # output$cmGraph <- renderPlot({plot(graphLayout(graph))})



    #### For DEBUGGING -----
    output$activeTab <- renderText({
      paste("Current panel: ", input$tabset)
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
