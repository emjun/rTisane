#' Create a nominal measure
#'
#' Method for constructing a nominal measure through a Unit.
#' @param unit Unit object. Unit that has/contributes the nominal measure.
#' @param name Character. Name of measure, corresponds to column name in data.
#' @param cardinality. Integer. Optional. Only required if no data is assigned.
#' @param numberOfInstances Integer or AbstractVariable or AtMost or Per. Number of instances of the measure the @param unit has. Default is 1.
#' @return Has Relationship representing Unit having the Nominal Measure.
#' @keywords
#' @export
# nominal()
setGeneric("nominal", function(unit, name, cardinality, numberOfInstances) standardGeneric("nominal"))
setMethod("nominal", signature("Unit", "character", "numeric", "integerORAbstractVariableORAtMostORPer"), function(unit, name, cardinality, numberOfInstances) {
  # Create new measure
  measure = Nominal(unit=unit, name=name, cardinality=as.integer(cardinality), numberOfInstances=numberOfInstances)
  # Create has relationship
  # has_relat = has(unit=unit, measure=measure, numberOfInstances=numberOfInstances)
  # Return has relationship
  # has_relat

  # Return handle to measure
  measure
})
setMethod("nominal", signature("Unit", "character", "numeric", "missing"), function(unit, name, cardinality, numberOfInstances) {
  numberOfInstances = as.integer(1)

  # Create new measure
  measure = Nominal(unit=unit, name=name, cardinality=as.integer(cardinality), numberOfInstances=numberOfInstances)
  # Create has relationship
  # has_relat = has(unit=unit, measure=measure, numberOfInstances=numberOfInstances)
  # Return has relationship
  # has_relat
  # Return handle to measure
  measure
})
