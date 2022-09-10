library(shiny)
library(jsonlite)

jsonData <- jsonlite::read_json("../../input.json") # Relative path to input.json file that processQuery outputs
dvType <- jsonData$dvType
dvOptions <- jsonData$dvOptions

# Define UI for application that draws a histogram
ui <- fluidPage(
    tags$script(src = "conceptualModelDisambiguation.js"),

    sidebarLayout(

      # Sidebar panel for inputs ----
      sidebarPanel(

        # Input: Slider for DV  ----
        # sliderInput(inputId = "dvType",
        #             label = "Number of bins:",
        #             min = 1,
        #             max = 50,
        #             value = 30)

      selectInput("dvType", "Type of data", choices = unique(dvOptions)),
      # selectInput("customername", "Customer", choices = NULL),
      # selectInput("ordernumber", "Order number", choices = NULL),
      tableOutput("data")
      ),

      # Main panel for displaying outputs ----
      mainPanel(

        # Output: Histogram ----

      )
    ),

    # tags$script(HTML("
    #     fetch('input.json')
    #     .then(resp => {
    #     console.log('fetch json');
    #     console.log(resp)
    #     let output = resp.json();
    #     load(output);
    #     });

    # ")),

    actionButton("stop", "Done!")
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    browser()

}

# Run the application
shinyApp(ui = ui, server = server)
