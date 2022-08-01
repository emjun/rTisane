#' Specify a decreasing Compares relationship.
#'
#' Returns the Compares relationship constructed.
#' @param variable numericORordinal. The variable decreasing.
#' @keywords
#' @export
# decreases()
setGeneric("decreases", function(variable) standardGeneric("decreases"))
setMethod("decreases", signature("numericORordinal"), function(variable)
{
  # create a Compares obj
  comp = Compares(variable=variable, condition="decreases")

  # Return Compares obj
  comp
})
