## Helper functions
create_disambig_id <- function(relationship) {
    idName <- trimws(relationship)
    idName <- paste(idName, "-disambig", sep="")

    # Return 
    idName
}

hasAmbiguitiesAtStart <- function(relationships, choices) {
    hasAmbiguities <- FALSE

    for (re in relationships) {
        re_choices <- choices[[re]]
        
        # Are there any choices?
        if (length(re_choices) > 0) {
            print(re_choices)
            return (TRUE)
        }
    }

    # Return 
    hasAmbiguities
}


relationshipUI <- function(id, choices) {
    ns <- NS(id)
    ## TODO: Somehow cluster the text + options to be more visually related
    # Add text for relationship
    tl <- tagList(
        p(id),
        # br()
    )
    
    # Create object id name
    idName <- create_disambig_id(id)

    if(length(choices) > 0) {
        # Create dropdown to ask for disambiguation
        disambig_dropdown <- tagList(
            selectInput(inputId=idName,
                        label="Do you want to assume...",
                        choices=choices)
        )

        # Append input (for disambiguation) to text describing relationship
        tl <- append(tl, disambig_dropdown)    
    } else {
        # store id somewhere can access during Server
    } 

    # Return tag list
    tl
}
conceptualModelSpecUI <- function(id, relationships, choices) {
    ns <- NS(id)
    tl <- list()
    for (re in relationships) {
        # print(paste("Considering: ", re))
        re_choices <- choices[[re]]
        
        rel_ui <- relationshipUI(re, re_choices)
        tl <- append(tl, rel_ui)
    }

    # tl <- tagList(
    #     div()
    # )
    print(id)
    tl <- tags$div(id=id, 
        tl
    )
    
    tl
}

submitButtonUI <- function(id, iv, dv, relationships, choices) {
    ns <- NS(id)

    
    if (! hasAmbiguitiesAtStart(relationships, choices)) {
        buttonLabel <- "Continue"
    } else {
        buttonLabel <- "Update conceptual model!"
        if (!is.null(iv)) {
            stopifnot(!is.null(dv))
            buttonLabel <- "Update conceptual model + Infer statistical model!"
        }
    } 
    
    # Return button
    actionButton(id, label=buttonLabel, class = "btn-success")
    # actionButton(id, label=buttonLabel, class = "btn-success", disabled=TRUE)
}

relationshipServer <- function(id) {
    # print("In Relationship Server")
    moduleServer(
        id,
        function(input, output, session) {
            # print("Output:")
            # print(input[[id]])
            eventReactive(input$disambig, {
                print("in relationship server")
                print(input$disambig)
            })
            # getRelat <- observe({
            #     val <- input$disambig
                
            #     return (val)
            # })
            # # print("=====")

            # output$observeEvent(event, {
                
            # })

            # observe({
            #     relat <- getRelat()
            #     # print(relat)

            #     output$summary <- renderText(
            #         relat
            #     )
            # })

            # getRelat()
            
            # output$summary <- renderText({
            #     id
            # })

            # output$summary
        }
    )
}

# Replace relationships with only those that are ambiguous (could return in relationshipsUI and store??)
conceptualModelSpecServer <- function(id, relationships) {
    # print("in ConceptualModelServer")
    relat_servers <- list()
    for (re in relationships) {
        rs <- relationshipServer(re)
        relat_servers <- append(relat_servers, rs)
    }
    print('in conceptual model spec server')
    relat_servers

    # moduleServer(
    #     id,
    #     function(input, output, session) {
    #         print(id)
    #     }
    # )
}

conceptualDisambiguationApp <- function(conceptualModel, iv, dv, inputFilePath) {
    updatedCM <- conceptualModel
    #### Process input JSON file -----
    jsonData <- jsonlite::read_json(inputFilePath) # Relative path to input.json file
    # print(jsonData)
    
    # Get Conceptual model info
    graph <- conceptualModel@graph
    cmValidationRes <- list(isValid=TRUE)

    uncertainRelationships <- jsonData$ambiguousRelationships
    options1 <- jsonData$ambiguousOptions1
    options2 <- jsonData$ambiguousOptions2
    stopifnot(length(uncertainRelationships) == length(options1))
    stopifnot(length(options1) == length(options2))


    relationships <- jsonData[["relationships"]]
    choices <- jsonData[["choices"]]

    global_updated_relats <- list()

    # for (re in relationships) {
    
    #### Define App UI -----
    ui <- fluidPage(
        shinyjs::useShinyjs(),

        # App title ----
        titlePanel("🌺 rTisane"),

        # Sidebar layout with input and output definitions ----
        sidebarLayout(

            # Sidebar panel for inputs ----
            sidebarPanel(

                # "Heading"
                h4("You specified the following relationships:"),

                # Input:
                conceptualModelSpecUI("spec", relationships, choices),

                # Output: Disambiguation questions
                # disambiguationQuestionsUI("cmQuestions")

                # Output: Cycle breaking questions

            ),

            # Main panel for displaying outputs ----
            mainPanel(

                # "Heading"
                h4("This is what your conceptual model looks like:"),

                # Output: Graph ----
                plotOutput("graph"),
                # textOutput("summary"),
                
                submitButtonUI("submit", iv, dv, relationships, choices)
            )
        )
    )

    server <- function(input, output) {
        # Update global store of updated relationships
        updates <- reactive({
            updated_relats <- global_updated_relats
            
            for (re in relationships) {

                # Create object id name
                idName <- create_disambig_id(re)
    
                r <- input[[idName]]
                if (!is.null(r)) {
                    updated_relats <- append(updated_relats,r )
                }
            }

            updated_relats
        })

        # Update conceptual model based on disambiguation choices
        observe({
            # Get updated relationships
            new_relats <- updates()
            
            # Save updated relationships globally
            global_updated_relats <- new_relats

            # Update conceptual model based on new relationships
            updatedCM <- updateConceptualModel(conceptualModel, new_relats)            

            # Update graph 
            gr <- updatedCM@graph
            output$graph <- renderPlot({
                plot(graphLayout(gr))
            })
        })

        # Verify conceptual model if there is an IV, DV
        # Enable submit
        check <- reactive({
            if (!is.null(iv)) {
                stopifnot(!is.null(dv))
                # if (updatedCM != conceptualModel) {
                cmCheckResults <- checkConceptualModel(updatedCM, iv, dv)
                isValid <- cmCheckResults$isValid
                reason <- cmCheckResults$reason

                # We can't infer a statistical model from the conceptual model yet
                if(!isValid) {
                    # Do things if the graph is not valid
                    # if (reason == "cycle") {
                    #     # Do something to input/output to further disambiguate/change
                    # }
                    shinyjs::disable(input$submit)
                }

                # Check there is no cycle

                # }

                # Return 
                return (isValid)
            } else {
                stopifnot(is.null(iv))
                stopifnot(is.null(dv))

                # Check there is no cycle
                return (TRUE)
            } 

            # # Return TRUE
            # return (isValid = FALSE, reason = "")
        })

        # # Check conceptual model, update submit button 
        # observe({
        #     canContinue <- check()
            
        #     if (isTRUE(canContinue)) {
        #         shinyjs::enable(input$submit)
        #     }
        # })
        

        # TODO: Verify conceptual model does not have a cycle, which impedes ability to infer statistical model

        ## Submit
        observeEvent(input$submit, {
            # Shut down app and return updated values
            stopApp(global_updated_relats) # returns whatever is passed as a parameter
        })
        
    }

    # Return handle to Shiny App for conceptual model disambiguation
    shinyApp(ui, server)
}