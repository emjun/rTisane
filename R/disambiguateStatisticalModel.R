#' Disambiguate statistical model candidates
#' @import reticulate
disambiguateStatisticallModel <- function(inputFilePath) {
    fileName = "start.py"
    path = file.path(getwd(), "gui", fileName)
    # path = "/Users/cse-loaner/Git/rTisane/gui/start.py"
    # setwd("/Users/cse-loaner/Git/rTisane")
    reticulate::py_run_file(path)
}
