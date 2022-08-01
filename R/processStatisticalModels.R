#' Output info to JSON
#'
#' Writes info to a JSON file
#' @param confounders list of confounders to include in the statistical model.
#' @param interactions list of interaction effects to consider including in the statistical model. Optional.
#' @param randomEffects list of random effects to include in the statistical model to maximize generalizability. Optional.
#' @param familyLinkFunctions list of family and link functions to consider.
#' @param path Path or character. Where to write the JSON to. 
#' @import jsonlite
#' @keywords
# generateStatisticalModelJSON()
generateStatisticalModelJSON <- function(confounders, interactions=NULL, randomEffects=NULL, familyLinkFunctions, path, iv, dv) {
    #### Generate main effects list from confounders
    stopifnot(!is.null(confounders))
    generatedMainEffects=confounders

    # Populate list to output
    # output <- list(generatedMainEffects=generatedMainEffects)

    #### Generate options for interaction effects
    generatedInteractionEffects = list() 

    # Are there interaction effects to consider? 
    if (!is.null(interactions)) {
        cat('IMPLEMENT interactions')
        browser()
    }

    #### Generate options for random effects
    generatedRandomEffects = as.data.frame() 

    # Are there any random effects to consider? 
    if (!is.null(randomEffects)) {
        cat('IMPLEMENT random effects')
        browser()
    }

    #### Generate options for family and link functions
    stopifnot(!is.null(familyLinkFunctions))
    generatedFamilyLinkFunctions = familyLinkFunctions





    #### Create query 
    query = list(DV=dv@name, IVs=list(iv@name))

    ##### Create measures-to-units mapping
    # measureToUnits = data.frame()

    # "measures to units": {
    #         "Dependent_variable": "Unit",
    #         "Measure_0": "Unit",
    #         "Measure_1": "Unit"
    #     },

    #### Add to output list
    output <- list(generatedMainEffects=generatedMainEffects, generatedInteractionEffects=generatedInteractionEffects, generatedRandomEffects=generatedRandomEffects, generatedFamilyLinkFunctions=generatedFamilyLinkFunctions, query=query)
    output <- list(input=output) # to conform to format that statsitical model disambiguation GUI expects

    #### Write output to JSON file
    jsonlite::write_json(output, path=path, auto_unbox = TRUE) # auto_unbox makes all atomic vectors in a list single elements in a list ("unboxes" them)

    ##### Return path
    path
}



#' Elicit additional information about to narrow the space of candidate statistical models to a final output one. 
#'
#' This function disambiguates the Statistical Model.
#' @param conceptualModel ConceptualModel. Contains causal graph to process.
#' @param iv AbstractVariable. Independent variable whose influence on @param dv we want to assess. 
#' @param dv AbstractVariable. Dependent variable. 
#' @return
#' @keywords
# processStatisticalModels()
setGeneric("processStatisticalModels", function(conceptualModel, iv, dv) standardGeneric("processStatisticalModels"))
setMethod("processStatisticalModels", signature("ConceptualModel", "AbstractVariable", "AbstractVariable"), function(conceptualModel, iv, dv)
{
    # Write candidate statistical models to JSON, which is read to create disambiguation GUI
    path <- generateStatisticalModelJSON(conceptualModel, dv, "input2.json")

    # Start up disambiguation process
    inputFilePath <- path
    dataPath = NULL # TODO: update
    disambiguateStatisticallModel(inputFilePath=path) #, dataPath=dataPath)

    # Necesssary? Create a Statistical Model object 
    # sm <- constructStatisticalModel(values)

    # Generate code
    # codePath <- generateCode(sm)

    # Return path to generated code
    # codePath 
})
