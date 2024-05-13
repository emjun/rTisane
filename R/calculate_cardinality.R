#' Method to calculate cardinality from data
#'
#' Method for calculating cardinality
#' @param variable AbstractVariable
#' @param data Dataset from which calculate cardinality for @param variable
#' @keywords
#' @export
# calculate_cardinality_from_data()
setGeneric("calculate_cardinality_from_data", function(variable, data) standardGeneric("calculate_cardinality_from_data"))
setMethod("calculate_cardinality_from_data", signature("AbstractVariable", "Dataset"), function(variable, data)
{
  data <- get_data(data@dataset, variable@name)
  unique_values <- get_unique_values(data)
  length(unique_values)
})