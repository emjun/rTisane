#' Checks if a value is greater than another value. 
#'
#' Returns TRUE if @param lhs is greater than @param rhs.
#' @param lhs
#' @param rhs
#' @keywords
#' @export
# checkGreaterThan()
setGeneric("checkGreaterThan", function(lhs, rhs) standardGeneric("checkGreaterThan"))
setMethod("checkGreaterThan", signature(lhs = "integer", rhs = "integer"), function(lhs, rhs) 
{
    return (lhs > rhs)
})

setMethod("checkGreaterThan", signature(lhs = "Per", rhs = "integer"), function(lhs, rhs) 
{
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