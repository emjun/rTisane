# Abstract Variable class
setClass("AbstractVariable", representation(name = "character", data = "DataVector", relationships = "list"))

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
setClass("Repeats", representation(unit = "Unit", measure = "Measure", according_to = "Measure"))
setClass("Nests", representation(base = "Unit", group = "Unit"))

setMethod("causes", signature("AbstractVariable", "AbstractVariable"), function(cause, effect) 
{
 # create a Causes relationship obj
 cause_relat = Causes(cause=cause, effect=effect)
 # append the Causes relationship obj to both @param cause and effect variables
 cause@relationships = append(cause@relationships, cause_relat)
 effect@relationships = append(effect@relationships, cause_relat)
})


# Variable types
setClass("Unit", representation(cardinality = "int"), contains = "AbstractVariable")
setClass("Measure", contains = "AbstractVariable")
setClass("SetUp", representation(variable = "Measure"), contains = "AbstractVariable")

# Measure sub-types
setClass("Nominal", representation(categories = "list"), contains = "Measure")
setClass("Ordinal", representation(order = "list"), contains = "Measure")
setClass("Numeric", contains = "Measure")
