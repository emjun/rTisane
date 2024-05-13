#' Specify a causes relationship
#'
#' Method for constructing a causes relationship between two variables.
#' Returns the Causes relationship constructed.
#' @param cause AbstractVariable. The cause.
#' @param effect AbstractVariable. The effect.
#' @keywords
#' @export
# causes()
setGeneric("causes", function(cause, effect, when, then) standardGeneric("causes"))
setMethod("causes", signature("AbstractVariableORUnobservedVariable", "AbstractVariableORUnobservedVariable", "missing", "missing"), function(cause, effect, when, then)
{
  # create a Causes relationship obj
  relat = Causes(cause=cause, effect=effect, when=NULL, then=NULL)

  # Return cause relationship
  relat
})
setMethod("causes", signature("AbstractVariableORUnobservedVariable", "AbstractVariableORUnobservedVariable", "Compares", "Compares"), function(cause, effect, when, then)
{
  # create a Causes relationship obj
  relat = Causes(cause=cause, effect=effect, when=when, then=then)

  # Return cause relationship
  relat
})
setMethod("causes", signature("Interacts", "AbstractVariableORUnobservedVariable", "missing", "missing"), function(cause, effect, when, then)
{
  # create a Causes relationship obj
  relat = Causes(cause=cause, effect=effect, when=NULL, then=NULL)

  # Return cause relationship
  relat
})
setMethod("causes", signature("Interacts", "AbstractVariableORUnobservedVariable", "Compares", "Compares"), function(cause, effect, when, then)
{
  # create a Causes relationship obj
  relat = Causes(cause=cause, effect=effect, when=when, then=then)

  # Return cause relationship
  relat
})
setMethod("causes", signature("AbstractVariableORUnobservedVariable", "Interacts", "missing", "missing"), function(cause, effect, when, then)
{
  # create a Causes relationship obj
  relat = Causes(cause=cause, effect=effect, when=NULL, then=NULL)

  # Return cause relationship
  relat
})
setMethod("causes", signature("AbstractVariableORUnobservedVariable", "Interacts", "Compares", "Compares"), function(cause, effect, when, then)
{
  # create a Causes relationship obj
  relat = Causes(cause=cause, effect=effec, when=when, then=then)

  # Return cause relationship
  relat
})
