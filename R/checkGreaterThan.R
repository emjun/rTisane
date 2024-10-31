#' Checks if a value is greater than another value. 
#'
#' Returns TRUE if @param lhs is greater than @param rhs.
#' @param lhs numeric value
#' @param rhs numeric value
#' @export
# checkGreaterThan()
setGeneric("checkGreaterThan", function(lhs, rhs) standardGeneric("checkGreaterThan"))
setMethod("checkGreaterThan", signature(lhs = "numeric", rhs = "numeric"), function(lhs, rhs) 
{
    return (as.integer(lhs) > as.integer(rhs))
})
setMethod("checkGreaterThan", signature(lhs = "Per", rhs = "numeric"), function(lhs, rhs) 
{
    rhs = as.integer(rhs)
    val = lhs@number
    stopifnot(is(val, "NumberValue"))

    if (is(val, "Exactly")) {
      var = lhs@variable
      totalTimes = val@value * var@cardinality
      stopifnot(is(totalTimes, "integer"))

    } else {
      stopifnot(is(val, "AtMost"))
      var = lhs@variable
      totalTimes = val@value * var@cardinality
      stopifnot(is(totalTimes, "integer"))
    }

    return (totalTimes > rhs)
})
setMethod("checkGreaterThan", signature(lhs="Exactly", rhs="numeric"), function(lhs, rhs)
{
  return (as.integer(lhs@value) > as.integer(rhs))
})