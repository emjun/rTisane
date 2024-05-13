#' Specify a (hyper-)specific relationship about two or more relationships.
#'
#' Method for constructing a very specific relationship between two variables.
#' Returns the Causes relationship constructed if @param when is a single Compares/involves one variable.
# #' Returns the Moderates relationship constructed if @param when is a list of Compares/involves multiple variables.
#' @param when Compares.
#' @param then Compares.
#' @keywords
#' @export
# whenThen()
setGeneric("whenThen", function(when, then) standardGeneric("whenThen"))
setMethod("whenThen", signature("Compares", "Compares"), function(when, then)
{
  if (class(when) == "Compares") {
    # Get the variables from the when/then parameters
    # cause_obj = when@variable
    # effect_obj = then@variable
    lhs = when@variable
    rhs = then@variable

    # create a Causes relationship obj
    # relat = Causes(cause=cause_obj, effect=effect_obj)

    # create a Relates relationship obj 
    relat = Relates(lhs=lhs, rhs=rhs)
    
  } 
  # else {
  #   # Assert that @param when is a List of Compares
  #   stopifnot(class(when) == "list")
  #   for (comp in when) {
  #     stopifnot(class(comp) == "Compares")
  #   }

  #   # Create a Moderates relationship obj
  #   moderators = list()
  #   for (comp in when) {
  #     moderators <- append(comp@variable, moderators)
  #   }
  #   relat = Moderates(moderators=moderators, on=then@variable)
  # }

  # Return relationship
  relat
})
