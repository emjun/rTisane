# @param iv is NULL by default
# @param dv is NULL by default
disambiguateConceptualModel <- function(conceptualModel, iv=NULL, dv=NULL, inputFilePath) {
  interface <- conceptualDisambiguationApp(conceptualModel, iv, dv, inputFilePath)
  shiny::runApp(interface)
}