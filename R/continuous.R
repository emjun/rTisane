#' Create a Continuous measure
#'
#' Method for constructing a Continuous measure through a Unit.
#' @param unit Unit object. Unit that has/contributes the Continuous measure.
#' @param name Character. Name of measure, corresponds to column name in data.
#' @return handle to Continuous measure.
#' @export
# continuous()
setGeneric("continuous", function(unit, name, numberOfInstances=1) standardGeneric("continuous"))
setMethod("continuous", signature("Unit", "character", "integerORPer"), function(unit, name, numberOfInstances)
{
    # Create new measure
    measure = Continuous(unit=unit, name=name, numberOfInstances=numberOfInstances)

    # Return measure
    measure
})
setMethod("continuous", signature("Unit", "character", "missing"), function(unit, name, numberOfInstances) {
    numberOfInstances = as.integer(1)
    # Create new measure
    measure = Continuous(unit=unit, name=name, numberOfInstances=numberOfInstances)

    # Return measure
    measure
})
