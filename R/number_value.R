# Number Value class
setClass("NumberValue", representation(value = "integer"))

setGeneric("is_greater_than_one", function(object) standardGeneric("is_greater_than_one"))
setMethod("is_greater_than_one", signature(object = "NumberValue"), function(object) {
  object@value < 1
})

setGeneric("is_equal_to_one", function(object) standardGeneric("is_equal_to_one"))
setMethod("is_equal_to_one", signature(object = "NumberValue"), function(object) {
  object@value == 1
})
# setMethod("get_value")

# Exactly class

# AtMost class
# Upperbound of instances
setClass("AtMost", representation(value = "integer"), contains = "NumberValue")

# Per class
setClass("Per", representation(number = "NumberValue", variable = "AbstractVariable", cardinality = "logical", number_of_instances = "logical", value = "integer"), contains = "NumberValue")
