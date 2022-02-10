#' Create a has relationship
#'
#' Method for specifying and creating a has relationship between Unit and Measure/
#' Not called directly. For internal purposes only.
#' @param unit Unit. The Unit that has @param measure.
#' @param measure Measure. The Measure that @param unit has.
#' @param number_of_instances Integer or AbstractVariable or AtMost or Per. Number of instances of the @param measure the @param unit has. Default is 1.
#' @keywords
#' @examples
#' has()
setGeneric("has", function(unit, measure, number_of_instances=1) standardGeneric("has"))
setMethod("has", signature("Unit", "Measure", "integerORAbstractVariableORAtMostORPer"), function(unit, measure, number_of_instances)
{
  # Figure out the number of times/repetitions this Unit (self) has of the measure
  repet = None
  according_to = None
  if (is.integer(number_of_instances)) {
    repet <- Exactly(number_of_instances=number_of_instances)
  } else if (is(number_of_instances, "AbstractVariable")) {
    repet <- Exactly(1)
    repet <- repet.per(cardinality=number_of_instances)
    according_to <- number_of_instances
  } else if (is(number_of_instances, "AtMost")) {
    repet = number_of_instances
  } else if (is(number_of_instances, "Per")) {
    repet = number_of_instances
  }
  # Create has relationship
  has_relat = Has(variable=unit, measure=measure, repetitions=repet, according_to=according_to)
  # Add relationship to unit
  unit@relationships <- append(unit@relationships, has_relat)
  # Add relationship to measure
  measure@relationships <- append(measure@relationships, has_relat)
})

