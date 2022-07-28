#' Query a conceptual model for a statistical model
#'
#' Method for querying a conceptual model for a statistical model
#' Fits and shows results of executing a statistical model + visualizing it from the conceptual model.
#' Returns an R script for running the statistical models + visualization
#' @param conceptualModel ConceptualModel we are assuming in order to assess the effects of @param ivs on @param dv.
#' @param iv AbstractVariable. Which variable whose effect on @param dv we want to evaluate.
#' @param dv AbstractVariable. Variable whose outcome we want to assess.
#' @keywords
#' @export
#' @examples
#' query()
setGeneric("query", function(conceptualModel, iv, dv) standardGeneric("query"))
setMethod("query", signature("ConceptualModel", "AbstractVariable", "AbstractVariable"), function(conceptualModel, iv, dv)
{

  ### Step 0: Update graph
  conceptualModel@graph <- updateGraph(conceptualModel)


  ### Step 1: Disambiguation round 1
  #### A: How to treat DV? (as Continuous, Count, Categories), B: Check + Ask for "causes"-level of info
  updates <- processQuery(conceptualModel=conceptualModel, iv=iv, dv=dv)
  dvUpdated <- updates$updatedDV
  cmUpdated <- updates$updatedConceptualModel

  ## LOOK UP: Validation in Shiny?
  ## TODO: Should check ConceptualModel during disambiguation
  checkConceptualModel(conceptualModel=conceptualModel, iv=iv, dv=dv)

  #### ????Step 1C: Data collection checks

  ### Step 2: Candidate statistical model inference/generation
  # Use Assumed and Hypothesized relationships to infer confounders
  # What happens if there are multiple Hypothesized relationships (not just the one with the IV)?
  confounders <- inferConfounders(conceptualModel=cmUpdated, iv=iv, dv=dv)
  # main_effects <- infer_main_effects_with_explanations(causal_gr, associative_gr, design)

  # interaction_effects <- infer_interaction_effects_with_explanations(causal_gr, associative_gr, design, main_effects)
  # random_effects <- infer_random_effects_with_explanations(measurement_gr, nests_gr, design, all_relationships, main_effects, interaction_effects)

  familyLinkFunctions <- inferFamilyLinkFunctions(dvUpdated)

  # Output JSON file
  json_file <- NULL

  ### Step 3: Disambiguation loop (GUI)
  # TODO: Call bash script to run GUI
  # Also, look into: Multipage app in Shiny https://mastering-shiny.org/scaling-modules.html#scaling-modules

  ### Step 4: Code generation
  # TODO: Generate code
})
