#' Create a has relationship
#'
#' Method for specifying and creating a has relationship between Unit and Measure/
#' Not called directly. For internal purposes only.
#' @param unit Unit. The Unit that has @param measure.
#' @param measure Measure. The Measure that @param unit has.
#' @param numberOfInstances Integer or AbstractVariable or AtMost or Per. Number of instances of the @param measure the @param unit has. Default is 1.
#' @keywords
setGeneric("has", function(unit, measure, numberOfInstances=1) standardGeneric("has"))
setMethod("has", signature("Unit", "Measure", "numericORAbstractVariableORAtMostORPer"), function(unit, measure, numberOfInstances)
{
  # Figure out the number of times/repetitions this Unit (self) has of the measure
  repet = NULL
  according_to = NULL
  if (is.integer(numberOfInstances)) {
    repet <- Exactly(numberOfInstances)
  } else if (is(numberOfInstances, "AbstractVariable")) {
    repet <- Exactly(1)
    # repet <- repet.per(cardinality=numberOfInstances)
    according_to <- numberOfInstances
  } else if (is(numberOfInstances, "AtMost")) {
    repet <- numberOfInstances
  } else if (is(numberOfInstances, "Per")) {
    repet <- numberOfInstances
  }
  # Create has relationship
  has_relat = Has(variable=unit, measure=measure, repetitions=repet, according_to=according_to)
  # # Add relationship to unit
  # unit@relationships <- append(unit@relationships, has_relat)
  # # Add relationship to measure
  # measure@relationships <- append(measure@relationships, has_relat)

  # Return has relationship
  has_relat
})

