#' Specify a Hypothesize statement
#'
#' Method for constructing a hypothesis about a relationship.
#' Returns the Hypothesis created.
#' @param conceptualModel ConceptualModel to which we should add the Hypothesized relationship.
#' @param relationship Relationship to assume.
#' @keywords
#' @export
# hypothesize()
setGeneric("hypothesize", function(conceptualModel, relationship) standardGeneric("hypothesize"))
setMethod("hypothesize", signature("ConceptualModel", "relatesORcausesORInteracts"), function(conceptualModel, relationship)
{

  if (class(relationship) == "Causes") {
    stopifnot(is(relationship@cause, "AbstractVariable")) # Check superclass
    stopifnot(is(relationship@effect, "AbstractVariable")) # Check superclass
    # Create a Hypothesis obj
    hypo = Hypothesis(conceptualModel=conceptualModel, relationship=relationship)

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
    hypo = Hypothesis(conceptualModel=conceptualModel, relationship=relationship)

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
    # Create a Hypothesis obj
    hypo = Hypothesis(conceptualModel=conceptualModel, relationship=relationship)

    # Add Hypothesis obj to ConceptualModel
    # Update variables
    if (!(c(relationship@lhs) %in% conceptualModel@variables)) {

      conceptualModel@variables <- append(conceptualModel@variables, relationship@lhs)
    }
    if (!(c(relationship@rhs) %in% conceptualModel@variables)) {
      conceptualModel@variables <- append(conceptualModel@variables, relationship@rhs)
    }
    # Update relationships
    conceptualModel@relationships <- append(conceptualModel@relationships, hypo) # Add Hypothesis

  }

  # Return updated ConceptualModel
  conceptualModel
})

