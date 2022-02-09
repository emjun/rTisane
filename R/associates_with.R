#' Associates class 
#'
#' Class for Associates relationships. 
#' Not called directly.
#' @param lhs AbstractVariable. A variable that is associated with another. 
#' @param rhs AbstractVariable. A variable that is associated with another. 
#' @keywords
#' @examples
#' Associates()
setClass("Associates", representation(lhs = "AbstractVariable", rhs = "AbstractVariable"))

#' Specify a Associates relationship
#'
#' Method for constructing an associates with relationship between two variables. 
#' Updates the relationships for each variable to include the newly constructed Associates relationship. 
#' @param lhs AbstractVariable.
#' @param rhs AbstractVariable.
#' @keywords
#' @export
#' @examples
#' associates_with()
setGeneric("associates_with", function(lhs, rhs) standardGeneric("associates_with"))
setMethod("associates_with", signature("AbstractVariable", "AbstractVariable"), function(lhs, rhs)
{
  relat = Associates(lhs=lhs, rhs=rhs)
  lhs@relationships <- append(lhs@relationships, relat)
  rhs@relationships <- append(rhs@relationships, relat)
})