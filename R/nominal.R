#' Nominal class 
#'
#' Class for Nominal measures, inherits from Measure.
#' Not called directly. All measures are declared through Units. 
#' @param name Name of measure, corresponds to column name if assigning data.
#' @param cardinality Integer for cardinality. 
#' @param categories List of categories. 
#' @param isInteraction Logical. True if variable is an interaction. False otherwise.
#' @keywords
#' @examples
#' Nominal()
setClass("Nominal", representation(name = "character", cardinality = "integer", categories = "list", isInteraction = "logical"), contains = "Measure")

#' Create a nominal measure
#'
#' Method for constructing a nominal measure through a Unit.
#' @param unit Unit object. Unit that has/contributes the nominal measure.
#' @param name Character. Name of measure, corresponds to column name in data.
#' @param cardinality. Integer. Optional. Only required if no data is assigned. 
#' @param number_of_instances Integer or AbstractVariable or AtMost or Per. Number of instances of the measure the @param unit has. Default is 1.
#' @keywords
#' @export
#' @examples
#' nominal()
setGeneric("nominal", function(unit, name, cardinality, number_of_instances=1) standardGeneric("nominal"))
setMethod("nominal", signature("Unit", "character", "integer", "integerORAbstractVariableORAtMostORPer"), function(unit, name, cardinality, number_of_instances)
{
  # Create new measure
  measure = Nominal(name=name, cardinality=cardinality)
  # Create has relationship, add to @param unit and @param measure
  has(unit=unit, measure=measure, number_of_instances=number_of_instances)
  # Return handle to measure
  measure
})
