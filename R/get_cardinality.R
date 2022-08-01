#' Method to get cardinality
#'
#' Method for getting the cardinality of an AbstractVariable
#' @param variable AbstractVariable to inspect
#' @keywords
#' @export
# get_cardinality()
setGeneric("get_cardinality", function(variable) standardGeneric("get_cardinality"))
setMethod("get_cardinality", signature("AbstractVariable"), function(variable)
{
  if (class(variable) == "SetUp") {
    var <- variable@variable
    var@cardinality
  } else {
    variable@cardinality
  }
})