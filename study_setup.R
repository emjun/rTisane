# Load dependencies
# library(reticulate)
library(shinyjs)
library(shiny)

# Use local build of rTisane (under development)
devtools::load_all()
# For conceptual model disambiguation
source("conceptualDisambiguation/app.R")

# Force conceptual disambiguation browser
options(shiny.launch.browser = .rs.invokeShinyWindowExternal)

# To ensure Python dependencies and paths are correctly found, make sure Console and Terminal in RStudio have current working directories of "Git/rTisane"
