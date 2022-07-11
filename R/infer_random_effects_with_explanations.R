#' Infers random effects.
#'
#' This function infers random effects from data measurement relationships.
#' @param measurement_gr Graph representing data measurement relationships.
#' @param nests_gr Graph representing nesting relationships between variables.
#' @param design Design
#' @param main_effects List of candidate main effects
#' @param interaction_effects List of candidate interaction effects
#' @return List of random effects and their explanations
#' @import dagitty
#' @keywords
#' @examples
#' infer_interaction_effects_with_explanations()
infer_random_effects_with_explanations <- function(measurement_gr, nests_gr, design, all_relationships, main_effects, interaction_effects) {
    dv <- design@dv

    unit <- parents(measurement_gr, dv@name)
    stopifnot(length(unit) == 1)

    for (r in all_relationships) {
        if (is(r, "Has")) {
            # Is this the has relationship we are looking for? 
            if (is(r@variable, unit) && is(r@measure, dv)) {
                
            }
        }
    }
}

