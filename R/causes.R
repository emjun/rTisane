#' Specify a causes relationship
#'
#' Method for constructing a causes relationship between two variables. 
#' Updates the relationships for each variable to include the newly constructed Causes relationship. 
#' @param cause AbstractVariable. The cause. 
#' @param effect AbstractVariable. The effect. 
#' @keywords
#' @export
#' @examples
#' causes()
setGeneric("causes", function(cause, effect) standardGeneric("causes"))
setMethod("causes", signature("AbstractVariable", "AbstractVariable"), function(cause, effect)
{
  # create a Causes relationship obj
  relat = Causes(cause=cause, effect=effect)
  # append the Causes relationship obj to both @param cause and effect variables
  cause@relationships <- append(cause@relationships, relat)
  effect@relationships <- append(effect@relationships, relat)
})

