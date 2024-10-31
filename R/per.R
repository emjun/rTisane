#' Constructs a Per object. 
#'
#' Returns TRUE if @param value is greater than @param variable.
#' @param value numeric value
#' @param variable Variable object with a value to compare
#' @export
# per()
setGeneric("per", function(value, variable, cardinality) standardGeneric("per"))
setMethod("per", signature(value = "numeric", variable = "AbstractVariable", cardinality = "missing"), function(value, variable, cardinality=TRUE) {
    stopifnot(value > 0)
    
    cardinality = TRUE
    new("Per", number = Exactly(as.integer(value)), variable = variable, cardinality = cardinality)
})
setMethod("per", signature(value = "Exactly", variable = "AbstractVariable", cardinality = "missing"), function(value, variable, cardinality=TRUE) {
    stopifnot(value@value > 0)
    stopifnot(is(value@value, "integer"))

    cardinality = TRUE
    new("Per", number = value, variable = variable, cardinality = cardinality)
})
setMethod("per", signature(value = "AtMost", variable = "AbstractVariable", cardinality = "missing"), function(value, variable, cardinality=TRUE) {
    stopifnot(value@value > 0)
    stopifnot(is(value@value, "integer"))

    cardinality = TRUE
    new("Per", number = value, variable = variable, cardinality = cardinality)
})