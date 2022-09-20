#' Specify an interaction relationship
#'
#' Method for constructing an interaction between two or more variables.
#' Returns the Interacts"constructed.
#' @param lhs AbstractVariable.
#' @param rhs AbstractVariable.
#' @keywords
#' @export
# interacts()
# setGeneric("interacts", function(...) standardGeneric("interacts"))
interacts <- function(...){
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
        name = paste(name, r@name, sep="_X_")
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
  }
  # create an Interacts"relationship obj
  relat = Interacts(name=name, units=units, variables=variables)

  # Return cause relationship
  relat
}
