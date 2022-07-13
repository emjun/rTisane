#' Specify a (hyper-)specific relationship
#'
#' Method for constructing a very specific relationship between two variables.
#' Returns the Causes relationship constructed.
#' @param when Compares.
#' @param then Compares.
#' @keywords
#' @export
#' @examples
#' whenThen()
setGeneric("whenThen", function(when, then) standardGeneric("whenThen"))
setMethod("whenThen", signature("Compares", "Compares"), function(when, then)
{
  # Get the variables from the when/then parameters
  cause_obj = when@variable
  effect_obj = then@variable

  # create a Causes relationship obj
  relat = Causes(cause=cause_obj, effect=effect_obj)

  # Return relationship
  relat
})
