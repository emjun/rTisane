#' Unit class 
#'
#' Class for Unit variables
#' @param name Name of Unit, corresponds to column name if assigning data 
#' @param integer Integer for cardinality, optional. Only required if no data is assigned
#' @keywords
#' @export
# Unit()
setClass("Unit", representation(name = "character", cardinality = "integer"), contains = "AbstractVariable")