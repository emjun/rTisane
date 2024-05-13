#' Create a Counts measure
#'
#' Method for constructing a Counts measure through a Unit.
#' @param unit Unit object. Unit that has/contributes the Counts measure.
#' @param name Character. Name of measure, corresponds to column name in data.
#' @return handle to Counts measure.
#' @keywords
#' @export
# counts()
setGeneric("counts", function(unit, name, numberOfInstances=1) standardGeneric("counts"))
setMethod("counts", signature("Unit", "character", "integerORPer"), function(unit, name, numberOfInstances)
{
    # Create new measure
    measure = Counts(unit=unit, name=name, numberOfInstances=numberOfInstances)

    # Return measure
    measure
})
setMethod("counts", signature("Unit", "character", "missing"), function(unit, name, numberOfInstances) {
    numberOfInstances = as.integer(1)
    # Create new measure
    measure = Counts(unit=unit, name=name, numberOfInstances=numberOfInstances)

    # Return measure
    measure
})
