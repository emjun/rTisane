# @param iv is NULL by default
# @param dv is NULL by default
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