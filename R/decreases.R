#' Specify a decreasing Compares relationship.
#'
#' Returns the Compares relationship constructed.
#' @param variable numericORordinal. The variable decreasing.
#' @export
# decreases()
setGeneric("decreases", function(variable) standardGeneric("decreases"))
setMethod("decreases", signature("Continuous"), function(variable)
{
  # create a Compares obj
  comp = Compares(variable=variable, condition="decreases")

  # Return Compares obj
  comp
})
setMethod("decreases", signature("Counts"), function(variable)
{
  # create a Compares obj
  comp = Compares(variable=variable, condition="decreases")

  # Return Compares obj
  comp
})
setMethod("decreases", signature("OrderedCategories"), function(variable)
{
  # create a Compares obj
  comp = Compares(variable=variable, condition="decreases")

  # Return Compares obj
  comp
})
