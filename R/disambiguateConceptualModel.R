disambiguateConceptualModel <- function(conceptualModel, iv, dv, inputFilePath, dataPath) {
  # require(shiny)
  # require(purrr)
  # require(shinyjs)
  # require(jsonlite)

  #### Read data file, if available ----
  df <- NULL
  if (!is.null(dataPath)) {
    df <- read.csv(dataPath)
  }

  #### Process input JSON file -----
  # Get DV options
  jsonData <- jsonlite::read_json(inputFilePath) # Relative path to input.json file that processQuery outputs
  dvName <- jsonData$dvName
  dvType <- jsonData$dvType
  dvOptions <- jsonData$dvOptions

  # Get Conceptual model info
  graph <- conceptualModel@graph
  cmValidationRes <- list(isValid=TRUE)

  uncertainRelationships <- jsonData$ambiguousRelationships
  options1 <- jsonData$ambiguousOptions1
  options2 <- jsonData$ambiguousOptions2
  stopifnot(length(uncertainRelationships) == length(options1))
  stopifnot(length(options1) == length(options2))

  #### Specify App UI -----
  ui = fluidPage(
    # tags$script(src = "conceptualModelDisambiguation.js"),
    shinyjs::useShinyjs(),

    titlePanel("rTisane"),
    textOutput("activeTab"),

    tabsetPanel(
      id = "tabset",
      tabPanel("Dependent variable",
               selectInput("dvType", paste("How do you want to treat", dvName, "?"), choices = unique(dvOptions)),
               # Info about dependent variable ---
               textOutput("dvSummary"),
               plotOutput('dvHist'),

               # textInput("delim", "Delimiter (leave blank to guess)", ""),
               # numericInput("skip", "Rows to skip", 0, min = 0),
               # numericInput("rows", "Rows to preview", 10, min = 1)
      ),
      tabPanel("Conceptual model",
               p("This is what your conceptual model looks like:"),
               plotOutput('cmGraph'),
               uiOutput("cmQuestions"),
               div(
                style="color:red",
                textOutput("cmValidation"),
               ),
               textOutput("palette"),
               actionButton("submit", "Done!")
      )
    )
  )

  #### Specify server ------
  server = function(input, output) {

    ## We don't need to disambiguate the conceptual model
    if (is.null(uncertainRelationships)) {
      gr = conceptualModel@graph
      e <- edges(gr)
      # Is the graph empty (has no edges)?
      if (length(e) > 0) {
        output$cmGraph <- renderPlot({
          plot(graphLayout(gr))
        })
      } else {
        # gr is NULL
        output$cmGraph <- renderPlot({})
      }
    }

    ## We need to disambiguate the update the conceptual model
    # Get data to update graph vis, validate conceptual model, etc.
    if (!is.null(uncertainRelationships)) {
      data  <- reactive({
        # Get user input
        lapply(1:length(uncertainRelationships), function(i) {
          cmInputs$uncertainRelationships[[i]] <- input[[uncertainRelationships[[i]]]]
        })
        relationships <- list(uncertainRelationships = cmInputs$uncertainRelationships)

        # Use it to update the conceptual model + graph
        cm <- updateConceptualModel(conceptualModel, relationships)

        return (cm)
      })

      # Update graph vis based on selection
      observe({
        cmUpdated = data() # get data
        browser()
        gr = updateGraph(cmUpdated)

        ## Update data vis for DV
        # Is there data?
        if (!is.null(df)) {
          output$dvSummary <- renderText({paste(dvName, " looks like this:")})

          colnames = names(df)
          stopifnot(c(dvName) %in% colnames)
          output$dvHist <- renderPlot({
            hist(df[dvName])
          })
        }

        ## Update graph vis
        e <- edges(gr)
        # Is the graph empty (has no edges)?
        if (length(e) > 0) {
          output$cmGraph <- renderPlot({
            plot(graphLayout(gr))
          })
        } else {
          # gr is NULL
          output$cmGraph <- renderPlot({})
        }

      })

      # Validate conceptual model, inform user
      observe({
        cmUpdated = data() # get data
        # cmUpdated <- updateGraph(cmUpdated) # update graph

        e <- edges(cmUpdated@graph)
        # Is the graph empty (has no edges)?
        if (length(e) > 0) {
          # Check conceptual model
          cmValidationRes <- checkConceptualModel(conceptualModel=cmUpdated, iv=iv, dv=dv)
        }
        if (isFALSE(cmValidationRes$isValid)) {
          warning <- paste("Error!:", cmValidationRes$reason, sep=" ")

          output$cmValidation <- renderText({
            warning
          })

          # Hide submit button
          shinyjs::hide("submit")
        } else {
          output$cmValidation <- renderText({
          })
          # Show submit button
          shinyjs::show("submit")
        }
      })
    }

    #### DV -----
    # Visualize DV if there is data
    if (!is.null(df)) {
      output$dvHist <- renderPlot({
        input$newplot
        plot(cars2)
      })
    }

    #### Conceptual Model -----
    # Dynamically generate/ask questions about under-specified relationships
    output$cmQuestions <- renderUI({
      l <- list(uncertainRelationships, options1, options2)
      purrr::pmap(l, ~ div(
        paste("You wrote that:", ..1),
        strong("More specifically, what did you mean?"),
        selectInput(paste0(..1),
                    NULL,
                    choices=c(..2, ..3))
      ))
      # map(col_names(), ~ selectInput(.x, NULL, choices = c("A --> B", "A <-- B")))
    })

    # output$palette <- renderText({
    #   purrr::map_chr(uncertainRelationships, ~ input[[.x]] %||% "")
    # })

    # # Update graph vis
    # output$cmGraph <- renderPlot({
    #   plot(graphLayout(graph))
    # })

    # IDEA: wrap inputs in Div, check if Div updates (attach event to that DIV), then regenerate the graph
    # observeEvent(input$option, {
    #   graph <- getExample('mediator')
    # }, ignoreInit = TRUE) # try removing ignoreInit? What does the parameter do anyway?
    # output$cmGraph <- renderPlot({plot(graphLayout(graph))})

    #### Return values -----
    # Toggle Submit button based on validation of conceptual model

    ## There are no uncertain relationships to capture
    if (is.null(uncertainRelationships)) {
      observeEvent(input$submit, {
        # Capture the updated DV data type
        dvType <- observe(paste(input$dvType))

        # Make named list of values to return
        res <- list(uncertainRelationships = NULL, dvName=dvName, dvType=input$dvType)

        # Return updated values
        stopApp(res) # returns whatever is passed as a parameter
      })
    } else {
      stopifnot(!is.null(uncertainRelationships))
      # Collect input for conceptual model
      # Based off of: https://stackoverflow.com/questions/51531006/access-a-dynamically-generated-input-in-r-shiny
      cmInputs <- reactiveValues(uncertainRelationships=NULL)
      observeEvent(input$submit, {
        lapply(1:length(uncertainRelationships), function(i) {
          cmInputs$uncertainRelationships[[i]] <- input[[uncertainRelationships[[i]]]]
        })

        # Capture the updated DV data type
        dvType=input$dvType

        # Make named list of values to return
        res <- list(uncertainRelationships = cmInputs$uncertainRelationships, dvName=dvName, dvType=input$dvType)

        # Return updated values
        stopApp(res) # returns whatever is passed as a parameter
      })
    }

    #### For DEBUGGING -----
    # output$activeTab <- renderText({
    #   paste("Current panel: ", input$tabset)
    # })

    # Store saved values and close app
    # observe({
    #   if (input$submit) {
    #     # Update DV, Update Conceptual Model
    #     dvUpdated <- updateDV(dv, userInput)
    #     cmUpdated <- updateConceptualModel(conceptualModel, userInput)

    #     # Make named list of values to return
    #     res <- list(updatedDV = dvUpdated, updatedConceptualModel = cmUpdated)
    #     stopApp(res) # returns whatever is passed as a parameter
    #   }

    # })
  }
  # Run the application
  # shinyApp(ui = ui, server = server)
  runApp(shinyApp(ui = ui, server = server))
}
