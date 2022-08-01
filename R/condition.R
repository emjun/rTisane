#' Create a condition
#'
#' Method for constructing a condition through a Unit
#' @param unit Unit object. The condition was assigned to a Unit instance.
#' @param name Character. Name of measure, corresponds to column name in data.
#' @param cardinality. Integer. Optional. Only required if no data is assigned.
#' @param number_of_instances Integer or AbstractVariable or AtMost or Per. Number of instances of the measure the @param unit has. Default is 1.
#' @return Has Relationship representing Unit having the Nominal Measure.
#' @keywords
#' @export
# condition()
setGeneric("condition", function(unit, name, cardinality, order, number_of_instances) standardGeneric("condition"))
setMethod("condition", signature("Unit", "character", "integer", "missing", "integerORAbstractVariableORAtMostORPer"), function(unit, name, cardinality, number_of_instances)
{
  # Create new measure
  measure = Nominal(unit=unit, name=name, cardinality=as.integer(cardinality), number_of_instances=number_of_instances)

  # Return handle to measure
  measure
})
setMethod("condition", signature("Unit", "character", "missing", "list", "integerORAbstractVariableORAtMostORPer"), function(unit, name, order, number_of_instances)
{
  # Calculate cardinality from order
  cardinality = length(order)
  # Create new measure
  measure = Ordinal(unit=unit, name=name, order=order, cardinality=cardinality, number_of_instances=number_of_instances)

  # Return handle to measure
  measure
})

