#' Measure class 
#'
#' Super class for measure variables, not called directly. Measures are declared through Units. 
#' @keywords
#' @examples
#' Measure()
setClass("Measure", contains = "AbstractVariable")