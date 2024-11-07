#' Disambiguate from among possible conceptual models
#'
#' This function starts a GUI (implemented as a Shiny web app) so that the user
#' can see their specified conceptual model and resolve any ambiguities as
#' necessary
#' @param conceptualModel ConceptualModel to disambiguate
#' @param iv NULL by default
#' @param dv NULL by default
#' @param inputFilePath path to conceptual model to disambiguate
#' @return updated ConceptualModel
# disambiguateConceptualModel()
disambiguateConceptualModel <- function(conceptualModel, iv=NULL, dv=NULL, inputFilePath) {
  # Disambiguate conceptual model
  interface <- conceptualDisambiguationApp(conceptualModel, iv, dv, inputFilePath)
  updated_relats <- shiny::runApp(interface)
  # print(updated_relats)

  # Update conceptual model with disambiguation choices
  updatedCM <- updateConceptualModel(conceptualModel, updated_relats)

  # Return updated conceptual model 
  updatedCM

}