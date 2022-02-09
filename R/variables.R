#' @include number_value.R
#' @include data.R
# Abstract Variable class
setClass("AbstractVariable", representation(name = "character", data = "DataVector", relationships = "list"))

setGeneric("get_cardinality", function(variable) standardGeneric("get_cardinality"))
setMethod("get_cardinality", signature("AbstractVariable"), function(variable)
{
  if (class(variable) == "SetUp") {
    var <- variable@variable
    var@cardinality
  } else {
    variable@cardinality
  }
})

#  Question: How to read data into and store as a dataframe
# TODO: May need to update for Nominal variable
setGeneric("calculate_cardinality_from_data", function(variable, data) standardGeneric("calculate_cardinality_from_data"))
setMethod("calculate_cardinality_from_data", signature("AbstractVariable", "Dataset"), function(variable, data)
{
  data <- get_data(data@dataset, variable@name)
  unique_values <- get_unique_values(data)
  length(unique_values)
})

setGeneric("assign_cardinality_from_data", function(variable, data) standardGeneric("assign_cardinality_from_data"))
setMethod("assign_cardinality_from_data", signature("AbstractVariable", "Dataset"), function(variable, data)
{
  variable@cardinality <- calculate_cardinality_from_data(variable=variable, data=data)
})

# Conceptual Relationships
setClass("Causes", representation(cause = "AbstractVariable", effect = "AbstractVariable"))
setClass("Associates", representation(lhs = "AbstractVariable", rhs = "AbstractVariable"))
setClass("Moderates", representation(moderator = "AbstractVariable", on = "AbstractVariable"))

# Data Measurement Relationships
setClass("Nests", representation(base = "Unit", group = "Unit"))
# Specify Union type for number_of_instances
# https://stackoverflow.com/questions/13002200/s4-classes-multiple-types-per-slot
setClassUnion("integerORAbstractVariableORAtMostORPer", c("integer", "AbstractVariable", "AtMost", "Per"))
setClass("Has", representation(variable = "AbstractVariable", measure = "AbstractVariable", repetitions = "NumberValue", according_to = "AbstractVariable"))


#' @include number_value.R
setGeneric("causes", function(cause, effect) standardGeneric("causes"))
setMethod("causes", signature("AbstractVariable", "AbstractVariable"), function(cause, effect)
{
  # create a Causes relationship obj
  relat = Causes(cause=cause, effect=effect)
  # append the Causes relationship obj to both @param cause and effect variables
  cause@relationships <- append(cause@relationships, relat)
  effect@relationships <- append(effect@relationships, relat)
})

setGeneric("associates_with", function(lhs, rhs) standardGeneric("associates_with"))
setMethod("associates_with", signature("AbstractVariable", "AbstractVariable"), function(lhs, rhs)
{
  relat = Associates(lhs=lhs, rhs=rhs)
  lhs@relationships <- append(lhs@relationships, relat)
  rhs@relationships <- append(rhs@relationships, relat)
})

# Provide two implementations for moderates
# In case moderator is an AbstractVariable
setGeneric("moderates", function(var, moderator, on) standardGeneric("moderates"))
setMethod("moderates", signature("AbstractVariable", "AbstractVariable", "AbstractVariable"), function(var, moderator, on)
{
  mods = list(var, moderator)
  relat = Moderates(moderator=mods, on=on)
  var@relationships <- append(var@relationships, relat)
  moderator@relationships <- append(moderator@relationships, relat)
  on@relationships <- append(on@relationships, relat)
})
# Or moderator is a list of AbstractVariables
setMethod("moderates", signature("AbstractVariable", "list", "AbstractVariable"), function(var, moderator, on)
{
  # TODO: Add validity that the list of moderators is all AbstractVariables
  mods = append(moderator, var)
  relat = Moderates(moderator=mods, on=on)
  var@relationships <- append(var@relationships, relat)
  # Add Moderates relationship to all the moderating variables
  for (m in moderator) {
    m@relationships <- append(moderator@relationships, relat)
  }
  on@relationships <- append(on@relationships, relat)
})

setGeneric("nests_within", function(base, group) standardGeneric("nests_within"))
setMethod("nests_within", signature("AbstractVariable", "AbstractVariable"), function(base, group)
{
  relat = Nests(base=base, group=group)
  base@relationships <- append(base@relationships, relat)
  group@relationships <- append(group@relationships, relat)
})

# Variable types
setClass("Unit", representation(cardinality = "integer"), contains = "AbstractVariable")
setClass("Measure", contains = "AbstractVariable")
# Question: How to override init method in R for SetUp?
setClass("SetUp", representation(variable = "Measure"), contains = "AbstractVariable")


# Measure sub-types
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
