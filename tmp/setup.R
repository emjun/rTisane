#' SetUp class 
#'
#' Class for SetUp variables
#' @param name Name of SetUp, corresponds to column name if assigning data 
#' @param order Optional. Order of categories if the SetUp variable represents an ordinal value (e.g., week of the month)
#' @param cardinality Optional. Cardinality of SetUp variable if itrepresents a nominal or ordinal value (e.g., trial identifier)
#' @keywords
#' @export
#' @examples
#' SetUp()
setClass("SetUp", representation(name = "character", order = "list", cardinality = "integer"), contains = "AbstractVariable")

