#' Elicit additional information about to narrow the space of candidate statistical models to a final output one.
#'
#' This function disambiguates the Statistical Model.
#' @param confounders list of confounders to include in the statistical model.
#' @param interactions list of interaction effects to consider including in the statistical model. Optional.
#' @param randomEffects list of random effects to include in the statistical model to maximize generalizability. Optional.
#' @param familyLinkFunctions list of family and link functions to consider.
#' @param iv AbstractVariable whose influence on @param dv we are interested in.
#' @param dv AbstractVariable whose outcome we are interested in.
#' @return path to generated code
# deriveStatisticalModel()
setGeneric("deriveStatisticalModel", function(confounders, interactions, randomEffects, familyLinkFunctions, iv, dv, data) standardGeneric("deriveStatisticalModel"))
setMethod("deriveStatisticalModel", signature("list", "list", "list", "list", "AbstractVariable", "ContinuousORCountsORCategories", "characterORDataframeORnull"), function(confounders, interactions, randomEffects, familyLinkFunctions, iv, dv, data)
{
    # Write candidate statistical models to JSON, which is read to create disambiguation GUI
    path <- generateStatisticalModelJSON(confounders, interactions, randomEffects, familyLinkFunctions, iv, dv, "input2.json")

    # Start up disambiguation process
    inputFilePath <- path
    # dataPath = NULL # TODO: update
    smScriptPath <- disambiguateStatisticallModel(inputFilePath=path) #, dataPath=dataPath)

    # Necesssary? Create a Statistical Model object
    # sm <- constructStatisticalModel(values)

    # Generate code
    # codePath <- generateCode(sm)

    # Return path to generated code
    smScriptPath
})
