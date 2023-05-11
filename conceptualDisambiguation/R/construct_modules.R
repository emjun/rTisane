
#   #### Process input JSON file -----
#   jsonData <- jsonlite::read_json(inputFilePath) # Relative path to input.json file
  
#   # Get Conceptual model info
#   graph <- conceptualModel@graph
#   cmValidationRes <- list(isValid=TRUE)

#   uncertainRelationships <- jsonData$ambiguousRelationships
#   options1 <- jsonData$ambiguousOptions1
#   options2 <- jsonData$ambiguousOptions2
#   stopifnot(length(uncertainRelationships) == length(options1))
#   stopifnot(length(options1) == length(options2))

# getUI <- function() {

# }

# getServer <- function() {

# }

# conceptualModelUI <- function() {
#   fluidRow(
#       column(8, offset=2, 
#         tabsetPanel(
#           id = "tabset",
#           tabPanel("Conceptual model",
#                   br(),
#                   div(
#                     style="color:red",
#                     textOutput("cmValidation"),
#                   ),
#                   uiOutput("cmQuestions"),
#                   p("This is what your conceptual model looks like:"),
#                   plotOutput('cmGraph'),
#                   actionButton("submit", "Update!")
#           )
#         )
#       )
#     )
# }

# cycleUI <- function() {
#   # TODO
# }

# conceptualModelServer <- function(id) {
#   moduleServer(
#     id, 
#     function(input, output, session) {
#       ## We don't need to disambiguate the conceptual model
#       if (is.null(uncertainRelationships)) {
#         gr = conceptualModel@graph
#         e <- edges(gr)
#         # Is the graph empty (has no edges)?
#         if (length(e) > 0) {
#           output$cmGraph <- renderPlot({
#             plot(graphLayout(gr))
#           })
#         } else {
#           # gr is NULL
#           output$cmGraph <- renderPlot({})
#         }
#       }

#       ## We need to disambiguate the update the conceptual model
#       # Get data to update graph vis, validate conceptual model, etc.
#       if (!is.null(uncertainRelationships)) {
#         data  <- reactive({
#           # Get user input
#           lapply(1:length(uncertainRelationships), function(i) {
#             cmInputs$uncertainRelationships[[i]] <- input[[uncertainRelationships[[i]]]]
#           })
#           relationships <- list(uncertainRelationships = cmInputs$uncertainRelationships)

#           # Use it to update the conceptual model + graph
#           cm <- updateConceptualModel(conceptualModel, relationships)

#           return (cm)
#         })

#         # Update graph vis based on selection
#         observe({
#           cmUpdated = data() # get data
#           gr = updateGraph(cmUpdated)

#           ## Update graph vis
#           e <- edges(gr)
#           # Is the graph empty (has no edges)?
#           if (length(e) > 0) {
#             output$cmGraph <- renderPlot({
#               plot(graphLayout(gr))
#             })
#           } else {
#             # gr is NULL
#             output$cmGraph <- renderPlot({})
#           }

#         })

#         # Validate conceptual model, inform user
#         observe({
#           cmUpdated = data() # get data
#           # cmUpdated <- updateGraph(cmUpdated) # update graph

#           e <- edges(cmUpdated@graph)
#           # Is the graph empty (has no edges)?
#           if (length(e) > 0) {
#             if(!is.null(iv)) {
#               stopifnot(!is.null(dv))
#               # Check conceptual model
#               cmValidationRes <- checkConceptualModel(conceptualModel=cmUpdated, iv=iv, dv=dv)
#             }
#           }
#           if (isFALSE(cmValidationRes$isValid)) {
#             warning <- paste("Error!:", cmValidationRes$reason, sep=" ")

#             output$cmValidation <- renderText({
#               warning
#             })

#             # Hide submit button
#             shinyjs::hide("submit")
#           } else {
#             output$cmValidation <- renderText({
#             })
#             # Show submit button
#             shinyjs::show("submit")
#           }
#         })
#       }      
#     }
#   )
# }

# conceptualModelQuestionsServer() <- function(input, output) {
#   # START HERE: (1) Wrap module server; (2) Create each UI module 
#   # Idea: Start with one UI module at a time --> Add code, add tests
#   # **GOAL: add and pass tests for conceptual model disambiguation**
  
#   moduleServer(
#     id,
#     function(input, output, session) { 
#       # Dynamically generate/ask questions about under-specified relationships
#       output$cmQuestions <- renderUI({
#         l <- list(uncertainRelationships, options1, options2)
#         purrr::pmap(l, ~ div(
#           paste("You specified that you ", ..1),
#           br(),
#           strong("What do you mean?"),
#           paste("Did you mean..."),
#           selectInput(paste0(..1),
#                       NULL,
#                       choices=c(..2, ..3))
#         ))
#         # map(col_names(), ~ selectInput(.x, NULL, choices = c("A --> B", "A <-- B")))
#       })
#     }
#   )
# }

# returnValuesServer() <- function(input, output) {

#   ## There are no uncertain relationships to capture
#   if (is.null(uncertainRelationships)) {
#     observeEvent(input$submit, {

#       # Make named list of values to return
#       res <- list(uncertainRelationships = NULL)

#       # Return updated values
#       stopApp(res) # returns whatever is passed as a parameter
#     })
#   } else {
#     stopifnot(!is.null(uncertainRelationships))
#     # Collect input for conceptual model
#     # Based off of: https://stackoverflow.com/questions/51531006/access-a-dynamically-generated-input-in-r-shiny
#     cmInputs <- reactiveValues(uncertainRelationships=NULL)
#     observeEvent(input$submit, {
#       lapply(1:length(uncertainRelationships), function(i) {
#         cmInputs$uncertainRelationships[[i]] <- input[[uncertainRelationships[[i]]]]
#       })

#       # Make named list of values to return
#       res <- list(uncertainRelationships = cmInputs$uncertainRelationships)

#       # Return updated values
#       stopApp(res) # returns whatever is passed as a parameter
#     })
#   }
# }

# exampleModuleUI <- function(id, label = "Counter") {
#   jsonData <- jsonlite::read_json("../input.json") # Relative path to input.json file
#   print(jsonData)
#   # All uses of Shiny input/output IDs in the UI must be namespaced,
#   # as in ns("x").
#   ns <- NS(id)
#   tagList(
#     actionButton(ns("button"), label = label),
#     verbatimTextOutput(ns("out"))
#   )
# }

# exampleModuleServer <- function(id) {
#   # moduleServer() wraps a function to create the server component of a
#   # module.
#   moduleServer(
#     id,
#     function(input, output, session) {
#       count <- reactiveVal(0)
#       observeEvent(input$button, {
#         count(count() + 1)
#       })
#       output$out <- renderText({
#         count()
#       })
#       count
#     }
#   )
# }


generateConceptualModelQuestions <- function(id) {
  uiOutput("cmQuestions")
}