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
# inferRandomEffects
inferRandomEffects <- function(conceptualModel, iv, dv) {
    randomEffects = list()
    # dv <- design@dv

    # unit <- parents(measurement_gr, dv@name)
    # stopifnot(length(unit) == 1)

    # for (r in all_relationships) {
    #     if (is(r, "Has")) {
    #         # Is this the has relationship we are looking for?  
    #         if (is(r@variable, unit) && is(r@measure, dv)) {
                
    #         }
    #     }
    # }

    # Return random effects
    randomEffects
}

