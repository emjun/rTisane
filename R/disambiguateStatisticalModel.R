#' Disambiguate statistical model candidates
#' @import reticulate
disambiguateStatisticallModel <- function(inputFilePath) {
    fileName = "start.py"
    path = file.path(getwd(), "gui", fileName)
    reticulate::py_run_file(path)
}