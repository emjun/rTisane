#' Create a nominal measure
#'
#' Method for constructing a nominal measure through a Unit.
#' @param unit Unit object. Unit that has/contributes the nominal measure.
#' @param name Character. Name of measure, corresponds to column name in data.
#' @param cardinality. Integer. Optional. Only required if no data is assigned.
#' @param number_of_instances Integer or AbstractVariable or AtMost or Per. Number of instances of the measure the @param unit has. Default is 1.
#' @return Has Relationship representing Unit having the Nominal Measure.
#' @keywords
#' @export
#' @examples
#' nominal()
setGeneric("nominal", function(unit, name, cardinality, number_of_instances) standardGeneric("nominal"))
setMethod("nominal", signature("Unit", "character", "numeric", "integerORAbstractVariableORAtMostORPer"), function(unit, name, cardinality, number_of_instances) {
  # Create new measure
  measure = Nominal(unit=unit, name=name, cardinality=as.integer(cardinality), number_of_instances=number_of_instances)
  # Create has relationship
  # has_relat = has(unit=unit, measure=measure, number_of_instances=number_of_instances)
  # Return has relationship
  # has_relat

  # Return handle to measure
  measure
})
setMethod("nominal", signature("Unit", "character", "numeric", "missing"), function(unit, name, cardinality, number_of_instances) {
  number_of_instances = as.integer(1)

  # Create new measure
  measure = Nominal(unit=unit, name=name, cardinality=as.integer(cardinality), number_of_instances=number_of_instances)
  # Create has relationship
  # has_relat = has(unit=unit, measure=measure, number_of_instances=number_of_instances)
  # Return has relationship
  # has_relat
  # Return handle to measure
  measure

  # # Add has relationship to @param unit
  # unit@relationships <- append(unit@relationships, has_relat)
  # # Add has relationship to @param measure
  # measure@relationships <- append(measure@relationships, has_relat)
  # # Return handle to measure
  # # measure
})
