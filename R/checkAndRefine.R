#' Check and refine conceptual model through interactive disambiguation
setGeneric("checkAndRefine", function(conceptualModel, iv, dv) standardGeneric("checkAndRefine"))
setMethod("checkAndRefine", signature("ConceptualModel", "missing", "missing"), function(conceptualModel, iv, dv)
{
  ### Step 0: Construct causal graph from declared relationships in ConceptualModel
  conceptualModel@graph <- updateGraph(conceptualModel)

  ### Step 1: Write ConceptualModel to JSON, which is read to create disambiguation GUI
  path <- generateConceptualModelJSON(conceptualModel)

  ### Step 1: Check the conceptual model for any issues right away
  # initialCheck(conceptualModel=conceptualModel, iv=iv, dv=dv)

  ### Step 2: Refine the conceptual model for any ambiguous relationships and cycles
  inputFilePath <- path
  updatedCM <- disambiguateConceptualModel(conceptualModel=conceptualModel, iv=NULL, dv=NULL, inputFilePath=inputFilePath)

  ### Return updated conceptual model
  updatedCM
})
setMethod("checkAndRefine", signature("ConceptualModel", "AbstractVariable", "AbstractVariable"), function(conceptualModel, iv, dv)
{
  ### Step 0: Construct causal graph from declared relationships in ConceptualModel
  conceptualModel@graph <- updateGraph(conceptualModel)

  ### Step 1: Write ConceptualModel to JSON, which is read to create disambiguation GUI
  path <- generateConceptualModelJSON(conceptualModel)

  ### Step 1: Check the conceptual model for any issues right away
  # initialCheck(conceptualModel=conceptualModel, iv=iv, dv=dv)

  ### Step 2: Refine the conceptual model for any ambiguous relationships and cycles
  inputFilePath <- path
  updatedCM <- disambiguateConceptualModel(conceptualModel=conceptualModel, iv=iv, dv=dv, inputFilePath=inputFilePath)

  ### Return updated conceptual model
  updatedCM
})