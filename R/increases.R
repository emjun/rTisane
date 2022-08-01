#' Specify an increasing Compares relationship.
#'
#' Returns the Compares relationship constructed.
#' @param variable numericORordinal. The variable increasing.
#' @keywords
#' @export
# increases()
setGeneric("increases", function(variable) standardGeneric("increases"))
setMethod("increases", signature("numericORordinal"), function(variable)
{
  # create a Compares obj
  comp = Compares(variable=variable, condition="increases")

  # Return Compares obj
  comp
})

