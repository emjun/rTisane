#' Prints a relationship
#'
#' Returns string describing what type of relationship the @param obj is
#' @param obj Relates or Causes object
#' @export
# toString()
setGeneric("toString", function(obj) standardGeneric("toString"))
setMethod("toString", signature("Relates"), function(obj)
{
    if (!is(obj, "Relates")) stop("Object is not of class 'Relates'")
    lhs <- obj@lhs
    rhs <- obj@rhs
    str <- paste(lhs@name, "and", rhs@name, "are related", sep=" ")

    # Return str
    str
})
setMethod("toString", signature("Causes"), function(obj)
{
    if (!is(obj, "Causes")) stop("Object is not of class 'Causes'")
    cause <- obj@cause
    effect <- obj@effect
    str <- paste(cause@name, "causes", effect@name, sep=" ")

    # Return str
    str
})
# setMethod("toString", signature("Assumption"), function(obj)
# {
#     rel <- obj@relationship
#     rel_str <- toString(rel)
#     str <- paste("Assume", rel_str, sep=" ")

#     # Return str
#     str
# })
# setMethod("toString", signature("Hypothesis"), function(obj)
# {
#     rel <- obj@relationship
#     rel_str <- toString(rel)
#     str <- paste("Hypothesize", rel_str, sep=" ")
    
#     # Return str
#     str
# })