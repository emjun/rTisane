#' Dataset class
#'
#' Class for Dataset
#' @slot df DataFrame.
#' @keywords
#' @export Dataset
#' @exportClass Dataset
# Dataset()
Dataset <- setClass("Dataset",
    slots = c(
      df = "character"
    ),
    prototype = list(
      df = NULL
    )
)
