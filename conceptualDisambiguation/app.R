## Helper functions
create_disambig_id <- function(relationship) {
    idName <- trimws(relationship)
    idName <- paste(idName, "-disambig", sep="")

    # Return 
    idName
}

create_cycle_description <- function(cycle) {
    stopifnot(class(cycle) == "list")
    cy_str <- unlist(cycle)
    
    desc <- ""


    for (i in 1:length(cy_str)) {
        if (i < length(cy_str)) {
            phrase <- paste(cy_str[i], cy_str[i+1], sep=" causes ")
        } else {
            phrase <- paste(cy_str[i], cy_str[1], sep= " causes ")
        }
        
        if (desc != "") {
            desc <- paste(desc, phrase, sep=", ")
        } else {
            desc <- phrase
        }
    }

    # Return 
    desc
}

create_cycle_breaking_id <- function(cycle) {
    
    stopifnot(class(cycle) == "list")
    cy_str <- unlist(cycle)
    idName <- ""

    for (i in 1:length(cy_str)) {
        if (idName == "") {
            idName <- cy_str[i]
        } else {
            idName <- paste(idName, cy_str[i], sep=" causes ")
        }
    }

    idName <- trimws(idName)
    idName <- paste(idName, "-breaking", sep="")

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

cycleUI <- function(id, conceptualModel) {
    ns <- NS(id)

    # Info about why cycles are problems
    tagList({
        p("TODO: We care about cycles because...")
        # TODO: Add a widget or small paragraph explaining why we look for/care about cycles in the graph
        # Output
        uiOutput("cycle")
    })

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


cycleBreakingUI <- function(cycles) {
    generateCycleOptions <- function(cycle) {
        choices <- list()
        
        for (i in 1:length(cycle)) {
            if (i < length(cycle)) {
                ch <- paste(cycle[i], cycle[i+1], sep=" causes ")
                choices <- append(choices, ch)
            } else {
                # browser()
                stopifnot(i == length(cycle))
                ch <- paste(cycle[i], cycle[1], sep=" causes ")
                choices <- append(choices, ch)
            }
        }

        # Return
        choices
    }

    uiElts <- list()
    for (cy in cycles) {
        cy_desc <- create_cycle_description(cy)
        id <- create_cycle_breaking_id(cy)

        cyElts <- tagList(
            p(cy_desc),
            checkboxGroupInput(
                inputId = id,
                label = "Select at least one relationships to remove:",
                choices = generateCycleOptions(cy)
                # selected = c("")
            )
        )

        uiElts <- append(uiElts, cyElts)
    }
    
    # Return 
    tagList(uiElts)
}

conceptualDisambiguationApp <- function(conceptualModel, iv, dv, inputFilePath) {
    updatedCM <- conceptualModel

    #### Process input JSON file -----
    jsonData <- jsonlite::read_json(inputFilePath) # Relative path to input.json file
    
    # Get Conceptual model info
    relationships <- jsonData[["relationships"]]
    choices <- jsonData[["choices"]]

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

                br(),
                # Heading for cycles
                h4("Checking to see if a statistical model can be inferred from your conceptual model"),

                # Output: 
                cycleUI("spec"), 

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
                
                # submitButtonUI("submit", iv, dv, relationships, choices)
                # uiOutput("submit")
                uiOutput("submit")
            )
        )
    )

    server <- function(input, output) {
        # Update global store of updated relationships
        updates <- reactive({
            updated_relats <- list()
            
            for (re in relationships) {

                # Create object id name
                idName <- create_disambig_id(re)
    
                r <- input[[idName]]
                if (!is.null(r)) {
                    updated_relats <- append(updated_relats,r )
                }
            }

            print(updated_relats)
            updated_relats
        })

        # Update cycle breaking questions based on disambiguation choices 
        observe({
            # Get updated relationships
            new_relats <- updates()

            # Update conceptual model based on new relationships
            updatedCM <- updateConceptualModel(conceptualModel, new_relats)

            # Update cycleUI
            gr <- updatedCM@graph
            cycles <- findCycles(updatedCM)

            # There are cycles
            if (length(cycles) > 0) {
                warningText <- "There is 1 cycle:"
                if (length(cycles) > 1) {
                    warningText <- "There are multiple cycles:"
                }
                # Create cycle breaking UI 
                output$cycle <- renderUI({
                    tagList(
                        p(warningText),
                        cycleBreakingUI(cycles)
                    )
                })
                output$submit <- renderUI({
                    actionButton("submit", label="Continue", class = "btn-success", disabled=TRUE)
                })
            } else {
                output$cycle <- renderUI({
                    tagList(
                        p("✅ There are no cycles!")    
                    )
                })
                output$submit <- renderUI({
                    actionButton("submit", label="Continue", class = "btn-success")
                })
            }
        })

        # Verify conceptual model does not have a cycle, which impedes ability to infer statistical model
        checkForCycles <- reactive({
            removals <- list()
            
            # Go through cycles 
            cycles <- findCycles(updatedCM)
            

            if (length(cycles) > 0) {
                for (cy in cycles) {
                    idName <- create_cycle_breaking_id(cy)

                    removal <- input[[idName]]
                    if (!is.null(removal) && length(removal) > 0) {
                        # Add to update list
                        for (re in removal) {
                            re_val <- paste("Remove", re, sep=" ")
                            removals <- append(removals, re_val)
                        }
                    } 
                    # else {
                    #     # Issue warning
                    #     showNotification(paste("There is a cycle still"), type="error")
                    # }
                }
                output$submit <- renderUI({
                    actionButton("submit", label="Continue", class = "btn-success")
                })
            }
            # Return 
            removals
        })

        # Update conceptual model graph based on disambiguation choices and cycle breaking
        observe({
            # Get updated relationships
            new_relats <- updates()
            removals <- checkForCycles()

            # Update conceptual model based on new relationships
            # Update relationships before removing some
            updatedCM <- updateConceptualModel(conceptualModel, new_relats)
            updatedCM <- updateConceptualModel(updatedCM, removals)

            # Update graph 
            gr <- updatedCM@graph
            output$graph <- renderPlot({
                plot(graphLayout(gr))
            })
        })

        # Show submit button if all cycles broken
        observe({
            cycles <- findCycles(updatedCM) # list of lists 
        
            allCyclesBroken <- TRUE
            # Are there any cycles?
            if (length(cycles) > 0) {
                
                for (cy in cycles) {
                    # cy is a list
                #     idName <- create_cycle_breaking_id(cy)

                #     removal <- input[[idName]]
                #     if (is.null(removal)) {
                #         allCyclesBroken <- FALSE
                #     }
                }
            }

            if (isTRUE(allCyclesBroken)) {
                output$submit <- renderUI({
                    actionButton("submit", label="Continue", class = "btn-success")
                })
            }
        })

        ## Submit
        observeEvent(input$submit, {
            # Get updated relationships
            updated_relats <- updates()
            removals <- checkForCycles()

            updated_relats <- append(updated_relats, unlist(removals))

            print(updated_relats)

            # Shut down app and return updated values
            stopApp(updated_relats) # returns whatever is passed as a parameter
        })
        
    }

    # Return handle to Shiny App for conceptual model disambiguation
    shinyApp(ui, server)
}