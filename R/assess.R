#' Assess a conceptual model to see if there is evidence for/in support of it in the data.
#'
#' Method for assessing if the data provides evidence for/against the conceptual model.
#' Fits and shows results of executing one or more statistical models for assessing the conceptual model.
#' Returns a script for running the statistical models
#' @param conceptualModel ConceptualModel to test.
#' @param data Dataset. Data to assess.
#' @keywords
#' @export
#' @examples
#' assess()
setGeneric("assess", function(conceptualModel, data) standardGeneric("assess"))
setMethod("assess", signature("ConceptualModel", "Dataset"), function(conceptualModel, data)
{
  ### Step 1: Initial conceptual checks
  check_conceptual_relationships(causal_gr, assocative_gr)

  ### Step 2: Generate conditional independencies

  #### Step 3: Construct statistical models
  ### For each set of conditional independencies
  ## COULD WE JUST CALL query(conceptualModel=conceptualModel, ivs, dv)???

  ### Step 4: Code generation
  ## IDEA: Combine all the scripts that query() generates?!
})
