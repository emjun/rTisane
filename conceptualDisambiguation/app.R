## Helper functions
# Is there a query for a statistical model or are we just refining the conceptual model?
isQuery <- function(iv, dv) {
    return (!is.null(iv) && !is.null(dv))
}
create_disambig_id <- function(relationship) {
    idName <- trimws(relationship)
    idName <- paste(idName, "-disambig", sep="")

    # Return
    idName
}

create_cycle_description <- function(cycle) {
    
    cy_str <- unlist(cycle)

    desc <- ""

    for (i in 1:(length(cy_str)-1)) {
        print(i)
        phrase <- paste(cy_str[i], cy_str[i+1], sep=" causes ")

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

cycleExplanationUI <- function(id, conceptualModel) {
    ns <- NS(id)

    # Info about why cycles are problems
    tl <- tagList({
        h5("🚨 There are circular relationships!")
        p("Circular relationships impede rTisane's ability to derive a statistical model because the direction of influence among variables is unclear.")
        p("Did you forget to specify some relationships? If so, consider re-visiting your input program.")
        p("Alternatively, you can consider removing one or more relationships below.")
        uiOutput("cycle")
    })

    # Return
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

cycleUI <- function(iv, dv) {
    tl <- NULL

    if (isQuery(iv, dv)) {
        tl <- tagList(
            # Heading for cycles
            h4("To derive a statistical model..."),
            # Output:
            # cycleExplanationUI("spec")
            uiOutput("cycle")
        )
    } else {
        tl <- tagList()
    }

    # Return
    tl
}

cycleBreakingUI <- function(cycles) {
    generateCycleOptions <- function(cycle) {
        choices <- list()

        for (i in 1:(length(cycle)-1)) {
            ch <- paste(cycle[i], cycle[i+1], sep=" causes ")
            choices <- append(choices, ch)
        }

        # Return
        choices
    }

    uiElts <- list()
    # browser()
    for (cy in cycles) {
        cy_desc <- create_cycle_description(cy)
        id <- create_cycle_breaking_id(cy)

        cyElts <- tagList(
            p(cy_desc),
            checkboxGroupInput(
                inputId = id,
                label = "Select at least one relationship to remove:",
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
        fluidRow(
            column(4,
                div (style="background-color:#e6e6e6;  border-radius: 3px !important; padding: 10px",
                    # "Heading"
                    h4("You specified the following relationships:"),

                    # Input:
                    conceptualModelSpecUI("spec", relationships, choices),
                ),
                br(),
                div (style="background-color:#e6e6e6;  border-radius: 3px !important; padding: 10px",
                    cycleUI(iv, dv)
                )
            ),
            column(8,
                # "Heading"
                h4("This is what your conceptual model looks like:"),

                # Output: Graph ----
                plotOutput("graph"),

                uiOutput("submit")
            )
        ),
    )

    server <- function(input, output) {
        # Gather and return updated relationships
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

            if (isQuery(iv, dv)) {
                print("Updating cycle breaking questions")
                cycles <- findCycles(updatedCM)

                # There are cycles
                if (length(cycles) > 0) {
                    # warningText <- "There is 1 cycle:"
                    # if (length(cycles) > 1) {
                    #     warningText <- "There are multiple cycles:"
                    # }
                    # Create cycle breaking UI
                    output$cycle <- renderUI({
                        tagList(
                            h5("🚨 There are circular relationships!"),
                            p("Circular relationships impede rTisane's ability to derive a statistical model because the direction of influence among variables is unclear."),
                            p("Did you forget to specify some relationships? If so, consider re-visiting your input program."),
                            p("Alternatively, you can consider removing one or more circular relationships below."),
                            p("Circular relationship:"),
                            cycleBreakingUI(cycles)
                        )
                    })
                    output$submit <- renderUI({
                        actionButton("submit", label="Continue", class = "btn-success") #, disabled=TRUE)
                    })
                } else {
                    output$cycle <- renderUI({
                        tagList(
                            p("✅ You have resolved all circular relationships!")
                        )
                    })
                    output$submit <- renderUI({
                        actionButton("submit", label="Continue", class = "btn-success")
                    })
                }
            }
            print("Finish updating cycle breaking questions")
        })

        # Verify conceptual model does not have a cycle, which impedes ability to infer statistical model
        checkForCycles <- reactive({
            
            removals <- list()

            # Go through cycles
            print("Checking for cycles")
            cm@graph <- updateGraph(cm) # Some race condition? Make sure to update graph before finding cycles
            cycles <- findCycles(cm)

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
                }
            }
            # Return
            removals
        })

        # Update conceptual model graph based on disambiguation choices and cycle breaking
        updateGraph <- observe({
            print("Start graph update")
            # Get updated relationships
            new_relats <- updates()
            # Update conceptual model based on new relationships
            updatedCM <- updateConceptualModel(conceptualModel, new_relats)
            # browser()

            # Are we deriving statistical models? So, therefore, do we need to break cycles that impede our ability to derive statistical models?
            if (isQuery(iv, dv)) {
                # Check which relationships to remove
                removals <- checkForCycles()
                # Remove them to break cycles
                updatedCM <- updateConceptualModel(updatedCM, removals)
            }

            # Update graph
            gr <- updatedCM@graph
            if (length(updatedCM@relationships) > 0) {
              print("Rendering graph")
              # Use igraph instead of dagitty for graph layout on Posit Cloud due to V8 crash issues:
              # https://github.com/r-causal/ggdag/issues/55
              edgeList <- as.matrix(edges(gr)[1:2])
              igr <- igraph::graph_from_edgelist(edgeList)
              output$graph <- renderPlot({
                plot(igr, layout=igraph::layout_with_drl)
                # plot(graphLayout(gr))
              })
            } else {
                output$graph <- renderText("No relationships in your conceptual model!")
            }
        })

        # Show submit button if all relationships disambiguated and cycles broken
        observe({
            enableButton <- FALSE

            allAmbigAnswered <- TRUE
            for (re in relationships) {
                # Create object id name
                idName <- create_disambig_id(re)

                r <- input[[idName]]
                if (is.null(r)) {
                    enableButton <- FALSE
                }
            }

            if(isTRUE(allAmbigAnswered)) {
                enableButton <- TRUE
            }

            if (isQuery(iv, dv)) {
                print("Updating button")
                cycles <- findCycles(updatedCM) # list of lists
                # browser()

                allCyclesBroken <- TRUE
                # Are there any cycles?
                if (length(cycles) > 0) {
                    for (cy in cycles) {
                        # cy is a list
                        idName <- create_cycle_breaking_id(cy)

                        removal <- input[[idName]]
                        if (is.null(removal)) {
                            allCyclesBroken <- FALSE
                        }
                    }
                }

                if (isTRUE(allCyclesBroken)) {
                    enableButton <- TRUE
                } else {
                    # output$submit <- renderUI({
                    #     actionButton("submit", label="Continue", class = "btn-success", disabled=TRUE)
                    # })
                    enableButton <- FALSE
                }
            }
            # else {
                # output$submit <- renderUI({
                #         actionButton("submit", label="Continue", class = "btn-success", disabled=TRUE)
                #     })
            # }

            if (isTRUE(enableButton)) {
                output$submit <- renderUI({
                        actionButton("submit", label="Continue", class = "btn-success")
                    })
            } else {
                # browser()
                output$submit <- renderUI({
                        actionButton("submit", label="Continue", class = "btn-success")#, disabled=TRUE)
                    })
            }

        })

        

        ## Submit
        observeEvent(input$submit, {
            # Get updated relationships
            updated_relats <- updates()

            if (isQuery(iv, dv)) {
                removals <- checkForCycles()
                updated_relats <- append(updated_relats, unlist(removals))
                print(updated_relats)
            }

            # Shut down app and return updated values
            stopApp(updated_relats) # returns whatever is passed as a parameter
        })
    }

    # Return handle to Shiny App for conceptual model disambiguation
    shinyApp(ui, server)
}
