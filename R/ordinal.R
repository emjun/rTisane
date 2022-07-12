#' Create an ordinal measure
#'
#' Method for constructing an ordinal measure through a Unit.
#' @param unit Unit object. Unit that has/contributes the ordinal measure.
#' @param name Character. Name of measure, corresponds to column name in data.
#' @param order List. Ordered list of categories.
#' @param cardinality. Integer. Optional. Only required if no data is assigned. If provided, checked to make sure @param cardinality == length(@param order)
#' @param number_of_instances Integer or AbstractVariable or AtMost or Per. Number of instances of the measure the @param unit has. Default is 1.
#' @return Has Relationship representing Unit having the Nominal Measure.
#' @keywords
#' @export
#' @examples
#' ordinal()
setGeneric("ordinal", function(unit, name, order, number_of_instances) standardGeneric("ordinal"))
setMethod("ordinal", signature("Unit", "character", "list", "integerORAbstractVariableORAtMostORPer"), function(unit, name, order, number_of_instances)
{
  # Calculate cardinality from order
  cardinality = length(order)
  # Create new measure
  measure = Ordinal(unit=unit, name=name, order=order, cardinality=cardinality, number_of_instances=number_of_instances)
  # Create has relationship
  # has_relat = has(unit=unit, measure=measure, number_of_instances=number_of_instances)
  # Return has relationship
  # has_relat
  # Return handle to measure
  measure
})
setMethod("ordinal", signature("Unit", "character", "list", "missing"), function(unit, name, order, number_of_instances) {
  number_of_instances = as.integer(1)

  # Calculate cardinality from order
  cardinality = length(order)
  # Create new measure
  measure = Ordinal(unit=unit, name=name, order=order, cardinality=cardinality, number_of_instances=number_of_instances)

  # Create has relationship
  # has_relat = has(unit=unit, measure=measure, number_of_instances=number_of_instances)
  # Return has relationship
  # has_relat
  # Return handle to measure
  measure
})

