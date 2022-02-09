#' Moderates class 
#'
#' Class for Moderates relationships. 
#' Not called directly.
#' @param moderator List of AbstractVariables. Variables that moderate each other's effect on the @param on variable. 
#' @param on AbstractVariable. The outcome variable. 
#' @keywords
#' @examples
#' Moderates()
setClass("Moderates", representation(moderator = "list", on = "AbstractVariable"))

## Provide two implementations for moderates
## In case moderator is an AbstractVariable
#' Specify a Moderates relationship
#'
#' Method for constructing a moderates relationship between two variables. 
#' Updates the relationships for each variable to include the newly constructed Moderates relationship. 
#' @param var AbstractVariable. Variable that moderates the effect of @param moderator on @param on variable. 
#' @param moderator AbstractVariable.
#' @param on AbstractVariable.
#' @keywords
#' @export
#' @examples
#' moderates()
setGeneric("moderates", function(var, moderator, on) standardGeneric("moderates"))
setMethod("moderates", signature("AbstractVariable", "AbstractVariable", "AbstractVariable"), function(var, moderator, on)
{
  mods = list(var, moderator)
  relat = Moderates(moderator=mods, on=on)
  var@relationships <- append(var@relationships, relat)
  moderator@relationships <- append(moderator@relationships, relat)
  on@relationships <- append(on@relationships, relat)
})

## Or moderator is a list of AbstractVariables
#' Specify a Moderates relationship
#'
#' Method for constructing a moderates relationship between two variables. 
#' Updates the relationships for each variable to include the newly constructed Moderates relationship. 
#' @param var AbstractVariable. Variable that moderates the effect of @param moderator on @param on variable. 
#' @param moderator List of AbstractVaraibles.
#' @param on AbstractVariable.
#' @keywords
#' @export
#' @examples
#' moderates()
setMethod("moderates", signature("AbstractVariable", "list", "AbstractVariable"), function(var, moderator, on)
{
  # TODO: Add validity that the list of moderators is all AbstractVariables
  mods = append(moderator, var)
  relat = Moderates(moderator=mods, on=on)
  var@relationships <- append(var@relationships, relat)
  # Add Moderates relationship to all the moderating variables
  for (m in moderator) {
    m@relationships <- append(moderator@relationships, relat)
  }
  on@relationships <- append(on@relationships, relat)
})