#' Specify an Assumes statement
#'
#' Method for constructing an assumption about a relationship.
#' Returns the Assumption created.
#' @param conceptualModel ConceptualModel to which we should add the Assumption.
#' @param relationship Relationship to assume.
#' @keywords
#' @export
setGeneric("assume", function(conceptualModel, relationship) standardGeneric("assume"))
setMethod("assume", signature("ConceptualModel", "relatesORcausesORmoderates"), function(conceptualModel, relationship)
{

  if (class(relationship) == "Causes") {
    # Create an Assumption obj
    assump = Assumption(conceptualModel=conceptualModel, relationship=relationship)

    # Add Assumption obj to ConceptualModel
    # Update variables
    if (!(c(relationship@cause) %in% conceptualModel@variables)) {

      conceptualModel@variables <- append(conceptualModel@variables, relationship@cause)
    }
    if (!(c(relationship@effect) %in% conceptualModel@variables)) {
      conceptualModel@variables <- append(conceptualModel@variables, relationship@effect)
    }
    # Update relationships
    conceptualModel@relationships <- append(conceptualModel@relationships, assump) # Add Assumption
  } else if (class(relationship) == "Moderates") {
    # Create an Assumption obj
    assump = Assumption(conceptualModel=conceptualModel, relationship=relationship)

    # Add Assumption obj to ConceptualModel
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
    conceptualModel@relationships <- append(conceptualModel@relationships, assump) # Add Assumption

  } else {
    stopifnot(class(relationship) == "Relates")

    # Create an Assumption obj
    assump = Assumption(conceptualModel=conceptualModel, relationship=relationship)

    # Add Assumption obj to ConceptualModel
    # Update variables
    if (!(c(relationship@lhs) %in% conceptualModel@variables)) {

      conceptualModel@variables <- append(conceptualModel@variables, relationship@lhs)
    }
    if (!(c(relationship@rhs) %in% conceptualModel@variables)) {
      conceptualModel@variables <- append(conceptualModel@variables, relationship@rhs)
    }
    # Update relationships
    conceptualModel@relationships <- append(conceptualModel@relationships, assump) # Add Assumption
  }

  # Return updated ConceptualModel
  conceptualModel
})

