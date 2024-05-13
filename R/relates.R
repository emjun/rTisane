#' Specify a relates (ambiguous) relationship
#'
#' Method for constructing an ambiguous "relates" relationship between two variables.
#' Returns the Relates relationship constructed.
#' @param lhs AbstractVariable. A variable.
#' @param rhs AbstractVariable. A variable.
#' @keywords
#' @export
# relates()
setGeneric("relates", function(lhs, rhs, when, then) standardGeneric("relates"))
setMethod("relates", signature("AbstractVariableORUnobservedVariable", "AbstractVariableORUnobservedVariable", "missing", "missing"), function(lhs, rhs, when, then)
{
  # create a Relates relationship obj
  relat = Relates(lhs=lhs, rhs=rhs, when=NULL, then=NULL)

  # Return relationship
  relat
})
setMethod("relates", signature("AbstractVariableORUnobservedVariable", "AbstractVariableORUnobservedVariable", "Compares", "Compares"), function(lhs, rhs, when, then)
{
  # create a Relates relationship obj
  relat = Relates(lhs=lhs, rhs=rhs, when=when, then=then)

  # Return relationship
  relat
})
setMethod("relates", signature("Interacts", "AbstractVariableORUnobservedVariable", "missing", "missing"), function(lhs, rhs, when, then)
{
  # create a Relates relationship obj
  relat = Relates(lhs=lhs, rhs=rhs, when=NULL, then=NULL)

  # Return relationship
  relat
})
setMethod("relates", signature("Interacts", "AbstractVariableORUnobservedVariable", "Compares", "Compares"), function(lhs, rhs, when, then)
{
  # create a Relates relationship obj
  relat = Relates(lhs=lhs, rhs=rhs, when=when, then=then)

  # Return relationship
  relat
})
setMethod("relates", signature("AbstractVariableORUnobservedVariable", "Interacts", "missing", "missing"), function(lhs, rhs, when, then)
{
  # create a Relates relationship obj
  relat = Relates(lhs=lhs, rhs=rhs, when=NULL, then=NULL)

  # Return relationship
  relat
})
setMethod("relates", signature("AbstractVariableORUnobservedVariable", "Interacts", "Compares", "Compares"), function(lhs, rhs, when, then)
{
  # create a Relates relationship obj
  relat = Relates(lhs=lhs, rhs=rhs, when=when, then=then)

  # Return relationship
  relat
})

