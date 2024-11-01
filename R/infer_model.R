#' Infer Model Function
#'
#' This function infers a statistical model from a study design. Calls infer_statistical_model_from_design
#' @param design 
#' @keywords statistical model
# infer_model()
infer_model <- function(design){
  rTisane::infer_statistical_model_from_design(design=design)
}