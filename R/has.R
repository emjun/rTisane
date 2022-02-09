# Specify Union type for number_of_instances
# https://stackoverflow.com/questions/13002200/s4-classes-multiple-types-per-slot
setClassUnion("integerORAbstractVariableORAtMostORPer", c("integer", "AbstractVariable", "AtMost", "Per"))

#' Has class 
#'
#' Class for Has relationships between AbstractVariables.
#' Not called directly. For internal purposes only.
#' @param variable AbstractVariable. Variable that has another Variable. For example, the Unit that has a Measure. 
#' @param measure AbstractVariable. Variable that @param variable has. For example, the Measure a Unit has.
#' @param repetitions NumberValue. Number of times that @param variable has @param measure. 
#' @param according_to AbstractVariable. Variable whose unique values differentiate the repeated instances of @param measure. 
#' @keywords
#' @examples
#' Has()
setClass("Has", representation(variable = "AbstractVariable", measure = "AbstractVariable", repetitions = "NumberValue", according_to = "AbstractVariable"))

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

