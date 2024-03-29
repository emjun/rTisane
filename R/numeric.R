#' Numeric class 
#'
#' Class for Numeric measures, inherits from Measure.
#' Not called directly. All measures are declared through Units. 
#' @param name Character. Name of measure, corresponds to column name in data.
#' @keywords
#' @examples
#' Numeric()
setClass("Numeric", representation(name = "character"), contains = "Measure")

#' Create a numeric measure
#'
#' Method for constructing a numeric measure through a Unit.
#' @param unit Unit object. Unit that has/contributes the numeric measure.
#' @param name Character. Name of measure, corresponds to column name in data.
#' @param number_of_instances Integer or AbstractVariable or AtMost or Per. Number of instances of the measure the @param unit has. Default is 1.
#' @keywords
#' @export
#' @examples
#' numeric()
setGeneric("numeric", function(unit, name, number_of_instances=1) standardGeneric("numeric"))
setMethod("numeric", signature("Unit", "character", "integerORAbstractVariableORAtMostORPer"), function(unit, name, number_of_instances)
{
  # Create new measure
  measure = Numeric(name=name)
  # Add relationship to self and to measure
  has(unit=unit, measure=measure, number_of_instances=number_of_instances)
  # Return handle to measure
  measure
})
