#' Checks if value is greater than 1
setGeneric("is_greater_than_one", function(object) standardGeneric("is_greater_than_one"))
setMethod("is_greater_than_one", signature(object = "NumberValue"), function(object) {
  object@value < 1
})
#' Checks if value equals 1
setGeneric("is_equal_to_one", function(object) standardGeneric("is_equal_to_one"))
setMethod("is_equal_to_one", signature(object = "NumberValue"), function(object) {
  object@value == 1
})
# setMethod("get_value")