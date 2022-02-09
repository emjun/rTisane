#' Nests class 
#'
#' Class for Nesting relationships. 
#' Not called directly.
#' @param base AbstractVariable. Variable that is nested within another. 
#' @param group AbstractVariable. Variable that contains multiple instances of @param base.
#' @keywords
#' @examples
#' Nests()
setClass("Nests", representation(base = "Unit", group = "Unit"))

#' Specify a Nests relationship
#'
#' Method for constructing a nesting relationship between two variables. 
#' Updates the relationships for each variable to include the newly constructed Nests relationship. 
#' @param base AbstractVariable. Variable that is nested within another. 
#' @param group AbstractVariable. Variable that contains multiple instances of @param base.
#' @keywords
#' @export
#' @examples
#' nests_within()
setGeneric("nests_within", function(base, group) standardGeneric("nests_within"))
setMethod("nests_within", signature("AbstractVariable", "AbstractVariable"), function(base, group)
{
  relat = Nests(base=base, group=group)
  base@relationships <- append(base@relationships, relat)
  group@relationships <- append(group@relationships, relat)
})
