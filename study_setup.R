# Load dependencies
# library(reticulate)
library(shinyjs)
library(shiny)

# Use local build of rTisane (under development)
devtools::load_all()
# For conceptual model disambiguation
source("conceptualDisambiguation/app.R")