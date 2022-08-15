#' Time class 
#'
#' Class for Time variables
#' @param name Name of Time, corresponds to column name if assigning data 
#' @param order Optional. Order of categories if the Time variable represents an ordinal value (e.g., week of the month)
#' @param cardinality Optional. Cardinality of Time variable if itrepresents a nominal or ordinal value (e.g., trial identifier)
#' @keywords
#' @export
# Time()
setClass("Time", representation(name = "character", order = "list", cardinality = "integer"), contains = "AbstractVariable")

