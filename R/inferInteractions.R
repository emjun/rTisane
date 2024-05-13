# Helper method 
# Returns a list of interactions that involve the @param dv
getInteractions <- function(conceptualModel, dv) {
    interactions <- list()     
    gr <- conceptualModel@graph
    # dvParents <- parents(gr, dv@name)
    relationships <- conceptualModel@relationships

    stopifnot(is(conceptualModel, "ConceptualModel")) 

    for (r in relationships) {
        if (is(r, "Interacts")) {
            if (identical(r@dv, dv)) {
                interactions <- append(interactions, r)
            }
        }
    }
    # for (var in conceptualModel@variables) {
    #     # Is the variable an Interaction?
    #     if (is(var, "Interacts")) {
    #         # Does the interaction cause the @param dv? 
    #         if (var@name %in% dvParents) {
    #             interactions <- append(interactions, var)
    #         }
            
    #     }        
    # }

    # Return interactions 
    interactions
}
#' Infers interaction/moderation effects.
#'
#' This function infers interaction/moderation effects from a conceptual graph.
#' @param conceptualModel ConceptualModel. With causal graph to use in order to identify confounders.
#' @param iv AbstractVariable. Independent variable that should cause (directly or indirectly) the @param dv.
#' @param dv AbstractVariable. Dependent variable that should not cause the @param iv.
#' @param confounders List. List of confounders to account for in order to estimate the causal effect of @param iv accurately.
#' @return List of interaction/moderation effects and their explanations.
#' @import dagitty
#' @keywords
# inferInteractions()
inferInteractions <- function(conceptualModel, iv, dv, confounders) {
    # interactions = list() # interactions that should be considered as candidates given the @param iv and @param confounders

    interactions = getInteractions(conceptualModel=conceptualModel, dv=dv)

    # allMainEffects = append(iv, confounders)
    # allInteractionVarsAsMain = TRUE
    # for (ixn in allInteractions) {
    #     browser()

    #     if (ixn@dv == dv) {
    #         interactions <- append(interactions, ixn)
    #     }

    #     # for (var in ixn@variables) {
    #     #     # A variable involved in the interaction ixn is not found as a main effect
    #     #     if (!(list(var) %in% allMainEffects)) {
    #     #         FALSE
    #     #     }
    #     # }

    #     # # All the variables involved in an interaction effect are included as main effects
    #     # if (allInteractionVarsAsMain) {
    #     #     interactions = append(interactions, ixn)
    #     # }
    # }

    # Return interactions
    interactions
}

