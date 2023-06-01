#' Specify an interaction relationship
#'
#' Method for constructing an interaction between two or more variables.
#' Returns the Interacts"constructed.
#' @param conceptualModel ConceptualModel.
#' @param ... AbstractVariables.
#' @param dv AbstractVariable.
#' @keywords
#' @export
# interacts()
# setGeneric("interacts", function(...) standardGeneric("interacts"))
interacts <- function(conceptualModel, ..., dv){
  vars = c(...)
  # Check that every variable passed as a parameter is an AbstractVariable
  for (r in vars) {
    stopifnot(is(r, "AbstractVariable"))
  }
  # create a name for the interaction
  name = ""
  for (r in vars) {
    if (name == "") {
        name = r@name
    } else {
        name = paste(name, r@name, sep="*")
    }
  }
  # create a list of units
  runits = list() 
  for (r in vars) {
    runits = append(runits, r@unit)
  }
  # filter out duplicate units 
  units = runits[!duplicated(runits)]
  
  # create list of variables 
  variables = list() 
  for (r in vars) {
    variables = append(variables, r)

    # Is the variable involved in the interaction in the Conceptual Model?
    if (!(c(r) %in% conceptualModel@variables)) {
      # Add variables to Conceptual Model 
      conceptualModel@variables <- append(conceptualModel@variables, r)
    }
  }

  # Is the dv in the Conceptual Model?
  if (!(c(dv) %in% conceptualModel@variables)) {
    # Add dv to Conceptual Model 
    conceptualModel@variables <- append(conceptualModel@variables, dv)
  }

  # create an Interacts relationship obj
  ixn = Interacts(name=name, units=units, variables=variables, dv=dv)

  # Add relationship to ConceptualModel 
  conceptualModel@relationships <- append(conceptualModel@relationships, ixn)

  # Return updated ConceptualModel
  conceptualModel
}
