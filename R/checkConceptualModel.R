#' Check Conceptual Model (graph) is valid, meaning there are no cycles and that the @param dv does not cause @param iv
#'
#' This function validates the Conceptual Model
#' @param conceptualModel ConceptualModel. Causal graph to validate.
#' @param iv AbstractVariable. Independent variable that should cause (directly or indirectly) the @param dv.
#' @param dv AbstractVariable. Dependent variable that should not cause the @param iv.
#' @return TRUE if the Conceptual Model is valid, FALSE otherwise
#' @import dagitty
#' @keywords
#' @examples
#' checkConceptualModel()
setGeneric("checkConceptualModel", function(conceptualModel, iv, dv) standardGeneric("checkConceptualModel"))
setMethod("checkConceptualModel", signature("ConceptualModel", "AbstractVariable", "AbstractVariable"), function(conceptualModel, iv, dv)
{

  gr <- conceptualModel@graph
  nodes <- names(gr) # Get the names of nodes in gr

  # (Automatically/Implicitly) Check that IV and DV are in the Conceptual Model
  # Check that there is a path between IV and DV
  p <- paths(gr, iv@name, dv@name)
  stopifnot(length(p[[1]]) > 0)

  # Check that DV does not cause IV
  dvCausingIv = paste(iv@name, "<-", dv@name)
  stopifnot(p[[1]] != dvCausingIv)

  # Check that there are no cycles
  stopifnot(isTRUE(isAcyclic(gr)))

  # Return TRUE if pass all the above checks
  TRUE
})
