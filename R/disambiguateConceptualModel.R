disambiguateConceptualModel <- function(conceptualModel, iv, dv, inputFilePath) {
  # require(shiny)
  # require(purrr)
  # require(shinyjs)
  # require(jsonlite)

  #### Process input JSON file -----
  jsonData <- jsonlite::read_json(inputFilePath) # Relative path to input.json file
  
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

    fluidRow(
      column(8, offset=2, 
        titlePanel("🌺 Tisane")
      )
    ),

    fluidRow(
      column(8, offset=2, 
        tabsetPanel(
          id = "tabset",
          tabPanel("Conceptual model",
                  br(),
                  div(
                    style="color:red",
                    textOutput("cmValidation"),
                  ),
                  uiOutput("cmQuestions"),
                  p("This is what your conceptual model looks like:"),
                  plotOutput('cmGraph'),
                  actionButton("submit", "Update!")
          )
        )
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
        gr = updateGraph(cmUpdated)

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
          if(!is.null(iv)) {
            stopifnot(!is.null(dv))
            # Check conceptual model
            cmValidationRes <- checkConceptualModel(conceptualModel=cmUpdated, iv=iv, dv=dv)
          }
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

    #### Conceptual Model -----
    # Dynamically generate/ask questions about under-specified relationships
    output$cmQuestions <- renderUI({
      l <- list(uncertainRelationships, options1, options2)
      purrr::pmap(l, ~ div(
        paste("You specified that you ", ..1),
        br(),
        strong("What do you mean?"),
        paste("Did you mean..."),
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

        # Make named list of values to return
        res <- list(uncertainRelationships = NULL)

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
        
        # Make named list of values to return
        res <- list(uncertainRelationships = cmInputs$uncertainRelationships)

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
