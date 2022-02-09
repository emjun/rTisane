#' Ordinal class 
#'
#' Class for Ordinal measures, inherits from Measure.
#' Not called directly. All measures are declared through Units. 
#' @param name Name of measure, corresponds to column name in data.
#' @param cardinality Integer for cardinality. 
#' @param order Ordered list of categories.
#' @keywords
#' @examples
#' Ordinal()
setClass("Ordinal", representation(name = "character", cardinality = "integer", order = "list"), contains = "Measure")

#' Create an ordinal measure
#'
#' Method for constructing an ordinal measure through a Unit.
#' @param unit Unit object. Unit that has/contributes the ordinal measure.
#' @param name Character. Name of measure, corresponds to column name in data.
#' @param order List. Ordered list of categories. 
#' @param cardinality. Integer. Optional. Only required if no data is assigned. If provided, checked to make sure @param cardinality == length(@param order)
#' @param number_of_instances Integer or AbstractVariable or AtMost or Per. Number of instances of the measure the @param unit has. Default is 1.
#' @keywords
#' @export
#' @examples
#' ordinal()
setGeneric("ordinal", function(unit, name, order, cardinality, number_of_instances=1) standardGeneric("ordinal"))
setMethod("ordinal", signature("Unit", "character", "list", "integer", "integerORAbstractVariableORAtMostORPer"), function(unit, name, order, cardinality, number_of_instances)
{
  # Create new measure
  measure = Ordinal(name=name, order=order, cardinality=cardinality)
  # Add relationship to self and to measure
  has(unit=unit, measure=measure, number_of_instances=number_of_instances)
  # Return handle to measure
  measure
})

