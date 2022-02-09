#' Measure class 
#'
#' Super class for measure variables
#' Not called directly. Measures are declared through Units. 
#' @keywords
#' @examples
#' Measure()
setClass("Measure", contains = "AbstractVariable")