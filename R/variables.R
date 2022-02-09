setClass("Nominal", representation(name = "character", cardinality = "integer", categories = "list"), contains = "Measure")
setClass("Ordinal", representation(order = "list"), contains = "Measure")
setClass("Numeric", contains = "Measure")

# Helper method
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

# Default value for number_of_instances is 1
setGeneric("nominal", function(unit, name, cardinality, number_of_instances=1) standardGeneric("nominal"))
# Definition for when @param number_of_instances is an integer
setMethod("nominal", signature("Unit", "character", "integer", "integerORAbstractVariableORAtMostORPer"), function(unit, name, cardinality, number_of_instances)
{
  # Create new measure
  measure = Nominal(name=name, cardinality=cardinality)
  # Create has relationship, add to @param unit and @param measure
  has(unit=unit, measure=measure, number_of_instances=number_of_instances)
  # Return handle to measure
  measure
})

# Default value for number_of_instances is 1
setGeneric("ordinal", function(unit, name, order, cardinality, number_of_instances=1) standardGeneric("ordinal"))
# Definition for when @param number_of_instances is an integer
setMethod("ordinal", signature("Unit", "character", "list", "integer", "integerORAbstractVariableORAtMostORPer"), function(unit, name, order, cardinality, number_of_instances)
{
  # Create new measure
  measure = Ordinal(name=name, order=order, cardinality=cardinality)
  # Add relationship to self and to measure
  has(unit=unit, measure=measure, number_of_instances=number_of_instances)
  # Return handle to measure
  measure
})

# Default value for number_of_instances is 1
setGeneric("numeric", function(unit, name, number_of_instances=1) standardGeneric("numeric"))
# Definition for when @param number_of_instances is an integer
setMethod("numeric", signature("Unit", "character", "integerORAbstractVariableORAtMostORPer"), function(unit, name, number_of_instances)
{
  # Create new measure
  measure = Numeric(name=name)
  # Add relationship to self and to measure
  has(unit=unit, measure=measure, number_of_instances=number_of_instances)
  # Return handle to measure
  measure
})
