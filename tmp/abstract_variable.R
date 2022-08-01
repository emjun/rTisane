### AbstractVariable class
#' @include number_value.R
#' @include data.R
#' AbstractVariable Class
#'
#' Abstract super class for declaring variables
#' @param name Name of variable, which should correspond with the column name for variable's data (must be in long format)
#' @param relationships List of relationships this variable has with other variables
#' @keywords
#' @export
# AbstractVariable()
setClass("AbstractVariable", representation(name = "character", relationships = "list"))
