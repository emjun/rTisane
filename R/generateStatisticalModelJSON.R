#' Output info to JSON
#'
#' Writes info to a JSON file
#' @param confounders list of confounders to include in the statistical model.
#' @param interactions list of interaction effects to consider including in the statistical model. Optional.
#' @param randomEffects list of random effects to include in the statistical model to maximize generalizability. Optional.
#' @param familyLinkFunctions list of family and link functions to consider.
#' @param iv AbstractVariable whose influence on @param dv we are interested in.
#' @param dv Continuous, Counts, or Categories. 
#' @param path Path-like or character. Path to write out the JSON.
#' @import jsonlite
#' @keywords
# generateStatisticalModelJSON()
generateStatisticalModelJSON <- function(confounders, interactions, randomEffects, familyLinkFunctions, iv, dv, path) {
    #### Generate main effects list from confounders
    stopifnot(!is.null(confounders))
    generatedMainEffects=confounders
    # Add IV 
    generatedMainEffects <- append(generatedMainEffects, iv@name)

    # Populate list to output
    # output <- list(generatedMainEffects=generatedMainEffects)

    #### Generate options for interaction effects
    generatedInteractionEffects = list()

    # Are there interaction effects to consider?
    if (length(interactions) > 0) {
        cat('IMPLEMENT interactions')
        browser()
    }

    #### Generate options for random effects
    # generatedRandomEffects = data.frame(randomSlopes=c("", ""), randomIntercepts=c("", ""))
    # generatedRandomEffects = data.frame(character()) # Empty dataframe
    generatedRandomEffects = list(" "=list())

    # Are there any random effects to consider?
    if (length(randomEffects) > 0) {
        cat('IMPLEMENT random effects')
        browser()
    }

    #### Generate options for family and link functions
    stopifnot(!is.null(familyLinkFunctions))
    generatedFamilyLinkFunctions = familyLinkFunctions


    #### Create query
    dvVar <- dv
    query = list(DV=dvVar@name, IVs=list(iv@name))

    #### Gather info about DV 
    dvInfo = list(dvType=class(dvVar), dvTreatAs=class(dv))

    ##### Create measures-to-units mapping
    # measureToUnits = data.frame()

    # "measures to units": {
    #         "Dependent_variable": "Unit",
    #         "Measure_0": "Unit",
    #         "Measure_1": "Unit"
    #     },

    #### Add to output list
    output <- list(generatedMainEffects=generatedMainEffects, generatedInteractionEffects=generatedInteractionEffects, generatedRandomEffects=generatedRandomEffects, generatedFamilyLinkFunctions=generatedFamilyLinkFunctions, query=query, dvInfo=dvInfo)
    output <- list(input=output) # to conform to format that statistical model disambiguation GUI expects

    #### Write output to JSON file
    jsonlite::write_json(output, path=path, auto_unbox = TRUE) # auto_unbox makes all atomic vectors in a list single elements in a list ("unboxes" them)

    #### Return absolute path
    # R.utils::getAbsolutePath(path)

    #### Return (relative) path
    path
}