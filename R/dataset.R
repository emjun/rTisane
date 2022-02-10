#' Dataset class 
#'
#' Class for Dataset
#' @slot df DataFrame. 
#' @keywords
#' @export Dataset
#' @exportClass Dataset
#' @examples
#' Dataset()
Dataset <- setClass("Dataset", 
    slots = list(df = "character")
)