#' Checks if two values, treated as integers, are equal. 
#'
#' Returns TRUE if the values are equal. FALSE otherwise.
#' @param variable Variable object with a value to compare
#' @param value numeric value
# checkEquals()
setGeneric("checkEquals", function(variable, value) standardGeneric("checkEquals"))
setMethod("checkEquals", signature(variable = "numeric", value = "numeric"), function(variable, value)
{
    return (as.integer(variable) == as.integer(value))
})

setMethod("checkEquals", signature(variable = "Per", value = "numeric"), function(variable, value)
{
    value = as.integer(value)
    val = variable@number
    stopifnot(is(val, "NumberValue"))
    if (is(val, "Exactly")) {
      var = variable@variable
      totalTimes = val@value * var@cardinality
      stopifnot(is(totalTimes, "integer"))

    } else {
      stopifnot(is(val, "AtMost"))
      var = variable@variable
      totalTimes = val@value * var@cardinality
      stopifnot(is(totalTimes, "integer"))
    }

    return (totalTimes == value)
})
setMethod("checkEquals", signature(variable = "Exactly", value = "numeric"), function(variable, value)
{
  totalTimes = variable@value
  stopifnot(is(totalTimes, "integer"))

      return (totalTimes == value)
})
