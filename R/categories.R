#' Create a Categories measure
#'
#' Method for constructing a categories measure through a Unit.
#' @param unit Unit object. Unit that has/contributes the categories measure.
#' @param name Character. Name of measure, corresponds to column name in data.
#' @param cardinality. Integer. Optional. Only required if no data is assigned. Number of unique categories. If @param order is provided, @param cardinality is not needed and will be set to the length of @order.
#' @param order. List. Optional. List of categories in order from "lowest" to "highest".
#' @param numberOfInstances Integer or AbstractVariable or AtMost or Per. Number of instances of the measure the @param unit has. Default is 1.
#' @return handle to Categories measure
#' @keywords
#' @export
# categories()
setGeneric("categories", function(unit, name, cardinality, order, numberOfInstances=1) standardGeneric("categories"))
# Unordered Categories, numberOfInstances specified
setMethod("categories", signature("Unit", "character", "numeric", "missing", "integerORPer"), function(unit, name, cardinality, order, numberOfInstances) {
    # if (class(numberOfInstances) == "numeric") {
    #     numberOfInstances <- as.integer(numberOfInstances)
    # }

    # Create new measure
    measure = UnorderedCategories(unit=unit, name=name, cardinality=as.integer(cardinality), numberOfInstances=numberOfInstances)

    # Return handle to measure
    measure
})
# Unordered Categories, numberOfInstances not specified
setMethod("categories", signature("Unit", "character", "numeric", "missing", "missing"), function(unit, name, cardinality, order, numberOfInstances) {
    numberOfInstances = as.integer(1)

    # Create new measure
    measure = UnorderedCategories(unit=unit, name=name, cardinality=as.integer(cardinality), numberOfInstances=numberOfInstances)

    # Return handle to measure
    measure
})
# # Unordered Categories, numberOfInstances not specified
# setMethod("categories", signature("Unit", "character", "numeric", "missing", "missing"), function(unit, name, cardinality, order, numberOfInstances) {
#     numberOfInstances = as.integer(1)

#     # Create new measure
#     measure = UnorderedCategories(unit=unit, name=name, cardinality=as.integer(cardinality), numberOfInstances=numberOfInstances)

#     # Return handle to measure
#     measure
# })


# Ordered Categories, numberOfInstances specified
setMethod("categories", signature("Unit", "character", "missing", "list", "integerORPer"), function(unit, name, cardinality, order, numberOfInstances) {
    # Create new measure
    measure = OrderedCategories(unit=unit, name=name, cardinality=length(order), order=order, numberOfInstances=numberOfInstances)

    # Return handle to measure
    measure
})
# Ordered Categories, numberOfInstances not specified
setMethod("categories", signature("Unit", "character", "missing", "list", "missing"), function(unit, name, cardinality, order, numberOfInstances) {

    # Create new measure
    measure = OrderedCategories(unit=unit, name=name, cardinality=length(order), order=order, numberOfInstances=numberOfInstances)

    # Return handle to measure
    measure
})
