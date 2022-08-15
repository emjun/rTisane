#' Checks if two values are equal.
#'
#' Returns TRUE if the values are equal. FALSE otherwise.
#' @param variable
#' @param value
#' @keywords
#' @export
# checkEquals()

setGeneric("checkEquals", function(variable, value) standardGeneric("checkEquals"))
setMethod("checkEquals", signature(variable = "integer", value = "integer"), function(variable, value)
{
    # stopifnot(is(variable, "integer"))
    # stopifnot(is(value, "integer"))
    return (variable == value)
})

setMethod("checkEquals", signature(variable = "Per", value = "integer"), function(variable, value)
{

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
