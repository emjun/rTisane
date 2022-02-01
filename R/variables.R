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
setClass("Has", representation(variable = "AbstractVariable", measure = "AbstractVariable", repetitions = "NumberValue", according_to = "AbstractVariable"))
# setClass("Repeats", representation(unit = "Unit", measure = "Measure", according_to = "Measure"))
setClass("Nests", representation(base = "Unit", group = "Unit"))

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
  # START HERE
})
# Or moderator is a list of AbstractVariables
setMethod("moderates", signature("AbstractVariable", "list", "AbstractVariable"), function(var, moderators, on)
{
  # TODO: Add validity that the list of moderators is all AbstractVariables
})

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
setClass("Nominal", representation(categories = "list"), contains = "Measure")
setClass("Ordinal", representation(order = "list"), contains = "Measure")
setClass("Numeric", contains = "Measure")

# Question: Defult value for methods in R?
setMethod("nominal", signature("Unit", "character", ), function(base, group)
{

})
