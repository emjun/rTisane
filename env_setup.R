options(shiny.launch.browser = .rs.invokeShinyWindowExternal)

library(shiny)
library(plotly)

# For development
devtools::load_all()

# For conceptual model disambiguation
source("conceptualDisambiguation/app.R")
