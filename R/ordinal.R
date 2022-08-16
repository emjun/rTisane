#' Create an ordinal measure
#'
#' Method for constructing an ordinal measure through a Unit.
#' @param unit Unit object. Unit that has/contributes the ordinal measure.
#' @param name Character. Name of measure, corresponds to column name in data.
#' @param order List. Ordered list of categories.
#' @param cardinality. Integer. Optional. Only required if no data is assigned. If provided, value to make sure @param cardinality == length(@param order)
#' @param numberOfInstances Integer or AbstractVariable or AtMost or Per. Number of instances of the measure the @param unit has. Default is 1.
#' @return Has Relationship representing Unit having the Nominal Measure.
#' @keywords
#' @export
# ordinal()
setGeneric("ordinal", function(unit, name, order, numberOfInstances) standardGeneric("ordinal"))
setMethod("ordinal", signature("Unit", "character", "list", "integerORPer"), function(unit, name, order, numberOfInstances)
{
  # Calculate cardinality from order
  cardinality = length(order)
  # Create new measure
  measure = Ordinal(unit=unit, name=name, order=order, cardinality=cardinality, numberOfInstances=numberOfInstances)
  # Create has relationship
  # has_relat = has(unit=unit, measure=measure, numberOfInstances=numberOfInstances)
  # Return has relationship
  # has_relat
  # Return handle to measure
  measure
})
setMethod("ordinal", signature("Unit", "character", "list", "missing"), function(unit, name, order, numberOfInstances) {
  numberOfInstances = as.integer(1)

  # Calculate cardinality from order
  cardinality = length(order)
  # Create new measure
  measure = Ordinal(unit=unit, name=name, order=order, cardinality=cardinality, numberOfInstances=numberOfInstances)

  # Create has relationship
  # has_relat = has(unit=unit, measure=measure, numberOfInstances=numberOfInstances)
  # Return has relationship
  # has_relat
  # Return handle to measure
  measure
})

