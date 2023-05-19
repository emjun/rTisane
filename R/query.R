initialCheck <- function(conceptualModel, iv, dv) {
  validationResults <- checkConceptualModel(conceptualModel=conceptualModel, iv=iv, dv=dv)
  isValid <- validationResults$isValid
  reason <- validationResults$reason

  # Layout validation results nicely
  if (!isValid) {
    stop(reason)
  }

}

#' Query a conceptual model for a statistical model
#'
#' Method for querying a conceptual model for a statistical model
#' Fits and shows results of executing a statistical model + visualizing it from the conceptual model.
#' Returns an R script for running the statistical models + visualization
#' @param conceptualModel ConceptualModel we are assuming in order to assess the effects of @param ivs on @param dv.
#' @param iv AbstractVariable. Which variable whose effect on @param dv we want to evaluate.
#' @param dv AbstractVariable. Variable whose outcome we want to assess.
#' @import reticulate
#' @keywords
#' @export
# query()
setGeneric("query", function(conceptualModel, iv, dv, data) standardGeneric("query"))
setMethod("query", signature("ConceptualModel", "AbstractVariable", "AbstractVariable", "missingORCharacterORDataframe"), function(conceptualModel, iv, dv, data)
{
  ## TODO: Check that there is a hypothesized relationship IV -> DV 

  ### Step 0: Construct causal graph from declared relationships in ConceptualModel
  # conceptualModel@graph <- updateGraph(conceptualModel)

  # ### Step 1: Check the conceptual model for any issues right away
  # initialCheck(conceptualModel=conceptualModel, iv=iv, dv=dv)


  ### Step 1: Conceptual Model Disambiguation
  #### A: How to treat DV? (as Continuous, Count, Categories), B: Check + Ask for "causes"-level of info
  #### Check ConceptualModel during disambiguation
  if (missing(data)) {
    data = NULL
  }
  # updatedCM <- processQuery(conceptualModel=conceptualModel, iv=iv, dv=dv, data=data)
  # dvUpdated <- updates$updatedDV
  # cmUpdated <- updates$updatedConceptualModel

  # Check and refine conceptual model 
  updatedCM <- checkAndRefineConceptualModel(conceptualModel, iv, dv)

  #### ????Step 1C: Data collection checks

  ### Step 2: Candidate statistical model inference/generation
  # Use Assumed and Hypothesized relationships to infer confounders
  # What happens if there are multiple Hypothesized relationships (not just the one with the IV)?
  confounders <- inferConfounders(conceptualModel=updatedCM, iv=iv, dv=dv)
  # main_effects <- infer_main_effects_with_explanations(causal_gr, associative_gr, design)

  interactions <- inferInteractions(conceptualModel=updatedCM, iv=iv, dv=dv, confounders=confounders)
  # interaction_effects <- infer_interaction_effects_with_explanations(causal_gr, associative_gr, design, main_effects)
  randomEffects <- inferRandomEffects(confounders=confounders, interactions=interactions, conceptualModel=updatedCM, iv=iv, dv=dv)
  # random_effects <- infer_random_effects_with_explanations(measurement_gr, nests_gr, design, all_relationships, main_effects, interaction_effects)

  familyLinkFunctions <- inferFamilyLinkFunctions(dv)

  ### Step 3: Statistical Model Disambiguation (GUI)
  ## Call Python script to create and run disambiguation process
  codePath <- deriveStatisticalModel(confounders=confounders, interactions=interactions, randomEffects=randomEffects, familyLinkFunctions=familyLinkFunctions, iv=iv, dv=dv, data=data)
  
  ### Step 4: Code generation
  # TODO: Generate code

  # Return path to statistical model script
  codePath
})
