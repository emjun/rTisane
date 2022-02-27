#' Infer has relationships from a study design
#'
#' This function infers has relationships from a study design.
#' @param design 
#' @keywords
#' @examples
#' infer_has_relationships()
infer_has_relationships <- function(design){
    # Get all variables in design
    vars <- get_all_vars(design=design)

    has_relationships <- list()

    for (v in vars) {
        # Assert that v is a Measure
        stopifnot(inherits(v, "Measure"))
        # Construct has relationship
        has_relat = has(unit=v@unit, measure=v, number_of_instances=v@number_of_instances)

        has_relationships <- append(has_relationships, has_relat)
    }

    # Reutrn has_relationships
    has_relationships
}