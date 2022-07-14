#' Specify a Hypothesize statement
#'
#' Method for constructing a hypothesis about a relationship.
#' Returns the Hypothesis created.
#' @param relationship Relationship to assume.
#' @param conceptualModel ConceptualModel to which we should add the Hypothesized relationship.
#' @keywords
#' @export
#' @examples
#' hypothesize()
setGeneric("hypothesize", function(relationship, conceptualModel) standardGeneric("hypothesize"))
setMethod("hypothesize", signature("relatesORcausesORmoderates", "ConceptualModel"), function(relationship, conceptualModel)
{

  if (class(relationship) == "Causes") {
    stopifnot(is(relationship@cause, "AbstractVariable")) # Check superclass
    stopifnot(is(relationship@effect, "AbstractVariable")) # Check superclass
    # create a Hypothesis obj
    hypo = Hypothesis(relationship=relationship, conceptualModel=conceptualModel)

    # Add Hypothesis obj to ConceptualModel
    # Update variables
    if (!(c(relationship@cause) %in% conceptualModel@variables)) {

      conceptualModel@variables <- append(conceptualModel@variables, relationship@cause)
    }
    if (!(c(relationship@effect) %in% conceptualModel@variables)) {
      conceptualModel@variables <- append(conceptualModel@variables, relationship@effect)
    }
    # Update relationships
    conceptualModel@relationships <- append(conceptualModel@relationships, hypo) # Add Hypothesis

  } else if (class(relationship) == "Moderates") {
    # create a Hypothesis obj
    hypo = Hypothesis(relationship=relationship, conceptualModel=conceptualModel)

    # Add Hypothesis obj to ConceptualModel
    # Update variables
    for (var in relationship@moderators) {
      if (!(c(var) %in% conceptualModel@variables)) {
        conceptualModel@variables <- append(conceptualModel@variables, var)
      }
    }
    if (!(c(relationship@on) %in% conceptualModel@variables)) {
      conceptualModel@variables <- append(conceptualModel@variables, relationship@on)
    }
    # Update relationships
    conceptualModel@relationships <- append(conceptualModel@relationships, hypo) # Add Hypothesis

  } else {
    stopifnot(class(relationship) == "Relates")
    # TODO: If relationship is Relates, ask for more specificity before adding to ConceptualModel?
    cat("Should specify how relationship Causes")
  }

  # Return updated ConceptualModel
  conceptualModel
})

