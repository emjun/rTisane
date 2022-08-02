#' Infers interaction/moderation effects.
#'
#' This function infers interaction/moderation effects from a conceptual graph.
#' @param conceptualModel ConceptualModel. With causal graph to use in order to identify confounders.
#' @param iv AbstractVariable. Independent variable that should cause (directly or indirectly) the @param dv.
#' @param dv AbstractVariable. Dependent variable that should not cause the @param iv.
#' @return List of interaction/moderation effects and their explanations.
#' @import dagitty
#' @keywords
# inferInteractions()
inferInteractions <- function(conceptualModel, iv, dv) {
    interactions = list()

    # Return interactions
    interactions
}

