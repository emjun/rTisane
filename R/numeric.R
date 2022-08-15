#' Create a numeric measure
#'
#' Method for constructing a numeric measure through a Unit.
#' @param unit Unit object. Unit that has/contributes the numeric measure.
#' @param name Character. Name of measure, corresponds to column name in data.
#' @param numberOfInstances Integer or AbstractVariable or AtMost or Per. Number of instances of the measure the @param unit has. Default is 1.
#' @return Has Relationship representing Unit having the Nominal Measure.
#' @keywords
#' @export
# numeric()
setGeneric("numeric", function(unit, name, numberOfInstances=1) standardGeneric("numeric"))
setMethod("numeric", signature("Unit", "character", "integerORAbstractVariableORAtMostORPer"), function(unit, name, numberOfInstances)
{
  # Create new measure
  measure = Numeric(unit=unit, name=name, numberOfInstances=numberOfInstances)
  # Create has relationship
  # has_relat = has(unit=unit, measure=measure, numberOfInstances=numberOfInstances)
  # Return has relationship
  # has_relat
  # Return handle to measure
  measure
})
setMethod("numeric", signature("Unit", "character", "missing"), function(unit, name, numberOfInstances) {
numberOfInstances = as.integer(1)
# Create new measure
measure = Numeric(unit=unit, name=name, numberOfInstances=numberOfInstances)
# Create has relationship
# has_relat = has(unit=unit, measure=measure, numberOfInstances=numberOfInstances)
# Return has relationship
# has_relat
# Return handle to measure
measure

})
