setGeneric("toString", function(obj) standardGeneric("toString"))
setMethod("toString", signature("Relates"), function(obj)
{
    lhs <- obj@lhs
    rhs <- obj@rhs
    str <- paste(lhs@name, "and", rhs@name, "are related", sep=" ")

    # Return str
    str
})
setMethod("toString", signature("Causes"), function(obj)
{
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