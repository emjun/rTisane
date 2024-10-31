#' Create a condition
#'
#' Method for constructing a condition through a Unit
#' @param unit Unit object. The condition was assigned to a Unit instance.
#' @param name Character. Name of measure, corresponds to column name in data.
#' @param cardinality. Integer. Optional. Only required if no data is assigned.
#' @param numberOfInstances Integer or AbstractVariable or AtMost or Per. Number of instances of the measure the @param unit has. Default is 1.
#' @return Has Relationship representing Unit having the Nominal Measure.
#' @export
# condition()
setGeneric("condition", function(unit, name, cardinality, order, numberOfInstances) standardGeneric("condition"))
setMethod("condition", signature("Unit", "character", "numeric", "missing", "numeric"), function(unit, name, cardinality, numberOfInstances)
{
  # Create new measure
  measure = UnorderedCategories(unit=unit, name=name, cardinality=as.integer(cardinality), numberOfInstances=as.integer(numberOfInstances))

  # Return handle to measure
  measure
})
setMethod("condition", signature("Unit", "character", "numeric", "missing", "numericORAbstractVariableORAtMostORPer"), function(unit, name, cardinality, numberOfInstances)
{
  # Create new measure
  measure = UnorderedCategories(unit=unit, name=name, cardinality=as.integer(cardinality), numberOfInstances=numberOfInstances)

  # Return handle to measure
  measure
})
setMethod("condition", signature("Unit", "character", "numeric", "missing", "missing"), function(unit, name, cardinality, numberOfInstances)
{
  # Create new measure
  measure = UnorderedCategories(unit=unit, name=name, cardinality=as.integer(cardinality), numberOfInstances=as.integer(1))

  # Return handle to measure
  measure
})
setMethod("condition", signature("Unit", "character", "missing", "list", "numeric"), function(unit, name, order, numberOfInstances)
{
  # Calculate cardinality from order
  cardinality = length(order)
  # Create new measure
  measure = OrderedCategories(unit=unit, name=name, order=order, cardinality=cardinality, numberOfInstances=as.integer(numberOfInstances))

  # Return handle to measure
  measure
})
setMethod("condition", signature("Unit", "character", "missing", "list", "numericORAbstractVariableORAtMostORPer"), function(unit, name, order, numberOfInstances)
{
  # Calculate cardinality from order
  cardinality = length(order)
  # Create new measure
  measure = OrderedCategories(unit=unit, name=name, order=order, cardinality=cardinality, numberOfInstances=numberOfInstances)

  # Return handle to measure
  measure
})
setMethod("condition", signature("Unit", "character", "missing", "list", "missing"), function(unit, name, order, numberOfInstances)
{
  # Calculate cardinality from order
  cardinality = length(order)
  # Create new measure
  measure = OrderedCategories(unit=unit, name=name, order=order, cardinality=cardinality, numberOfInstances=as.integer(1))

  # Return handle to measure
  measure
})

