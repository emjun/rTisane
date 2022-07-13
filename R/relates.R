#' Specify a relates (ambiguous) relationship
#'
#' Method for constructing an ambiguous "relates" relationship between two variables.
#' Returns the Relates relationship constructed.
#' @param lhs AbstractVariable. A variable.
#' @param rhs AbstractVariable. A variable.
#' @keywords
#' @export
#' @examples
#' relates()
setGeneric("relates", function(lhs, rhs) standardGeneric("relates"))
setMethod("relates", signature("AbstractVariable", "AbstractVariable"), function(lhs, rhs)
{
  # create a Relates relationship obj
  relat = Relates(lhs=lhs, rhs=rhs)

  # Return relationship
  relat
})
