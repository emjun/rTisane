#' Specify a causes relationship
#'
#' Method for constructing a causes relationship between two variables.
#' Returns the Causes relationship constructed.
#' @param cause AbstractVariable. The cause.
#' @param effect AbstractVariable. The effect.
#' @keywords
#' @export
#' @examples
#' causes()
setGeneric("causes", function(cause, effect) standardGeneric("causes"))
setMethod("causes", signature("AbstractVariableORUnobservedVariable", "AbstractVariableORUnobservedVariable"), function(cause, effect)
{
  # create a Causes relationship obj
  relat = Causes(cause=cause, effect=effect)

  # Return cause relationship
  relat
})

