#' Method to assigning cardinality from data
#'
#' This function calculates cardinality from data and updates the variable's cardinality
#' @param variable AbstractVariable
#' @param data Dataset from which calculate cardinality for @param variable
#' @keywords
#' @export
#' @examples
#' assign_cardinality_from_data()
setGeneric("assign_cardinality_from_data", function(variable, data) standardGeneric("assign_cardinality_from_data"))
setMethod("assign_cardinality_from_data", signature("AbstractVariable", "Dataset"), function(variable, data)
{
  variable@cardinality <- calculate_cardinality_from_data(variable=variable, data=data)
})
