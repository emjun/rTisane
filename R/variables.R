# Question: How do dependencies across files work in R  -- can I reference SetUp variable in a different file? What order are the files loaded?
# Abstract Variable class
setClass("AbstractVariable", representation(name = "character", data = "DataVector", relationships = "list"))

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
setMethod("calculate_cardinality_from_data", signature("AbstractVariable", "Dataset"), function(variable, data) 
{
  data <- get_data(data@dataset, variable@name)
  unique_values <- get_unique_values(data)
  length(unique_values)
})

setMethod("assign_cardinality_from_data", signature("AbstractVariable", "Dataset"), function(variable, data) 
{
  variable@cardinality <- calculate_cardinality_from_data(variable=variable, data=data)
})


# if (class(variable) == "AbstractVariable") {
    
#   }

# Number Value class
setClass(NumberValue, representation(value = "int"))
setMethod("is_greater_than_one", signature(object = "NumberValue"), function(object) {
  return object@value < 1
})
setMethod("is_equal_to_one", signature(object = "NumberValue"), function(object) {
    return object@value == 1
})
setMethod("get_value")

# Conceptual Relationships
setClass("Causes", representation(cause = "AbstractVariable", effect = "AbstractVariable"))
setClass("Associates", representation(lhs = "AbstractVariable", rhs = "AbstractVariable"))
setClass("Moderates", representation(moderator = "AbstractVariable", on = "AbstractVariable"))
setClass("Has", representation(variable = "AbstractVariable", measure = "AbstractVariable", repetitions = "NumberValue", according_to = "AbstractVariable"))
# setClass("Repeats", representation(unit = "Unit", measure = "Measure", according_to = "Measure"))
setClass("Nests", representation(base = "Unit", group = "Unit"))

setMethod("causes", signature("AbstractVariable", "AbstractVariable"), function(cause, effect) 
{
  # create a Causes relationship obj
  relat = Causes(cause=cause, effect=effect)
  # append the Causes relationship obj to both @param cause and effect variables
  cause@relationships <- append(cause@relationships, relat)
  effect@relationships <- append(effect@relationships, relat)
})

setMethod("associates_with", signature("AbstractVariable", "AbstractVariable"), function(lhs, rhs)
{
  relat = Associates(lhs=lhs, rhs=rhs)
  lhs@relationships <- append(lhs@relationships, relat)
  rhs@relationships <- append(rhs@relationships, relat)
})

# Question: How to specify Union (AbstractVariable or List of Abstract Variables?)
setMethod("moderates", signature("AbstractVariable", "Union(AbstractVariable, List)", "AbstractVariable"), function(var, moderator, on)
{
  if istype(moderator, "AbstractVariable"):
  ...
})

setMethod("nests_within", signature("AbstractVariable", "AbstractVariable"), function(base, group)
{
  relat = Nests(base=base, group=group)
  base@relationships <- append(base@relationships, relat)
  group@relationships <- append(group@relationships, relat)
})

# Variable types
setClass("Unit", representation(cardinality = "int"), contains = "AbstractVariable")
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
