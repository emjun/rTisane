#' Infers random effects.
#'
#' This function infers random effects from data measurement relationships. 
#' @param confounders List of confounders to include in a statistical model. 
#' @param interactions List of interaction terms to include in a statistical model. 
#' @param conceptualModel ConceptualModel expressing conceptual relationships. 
#' @param iv AbstractVariable whose influence on @param dv we are interested in estimating. 
#' @param dv AbstractVariable whose outcome we are interested in estimating in a statsitical model. 
#' @return List of random effects to include. 
#' @import dagitty
#' @keywords
# inferRandomEffects
inferRandomEffects <- function(confounders, interactions, conceptualModel, iv, dv) {
    randomEffects = list()
    dvUnit = dv@unit # Get the DV's unit 

    # Construct random effects for repeated measures 
    mainEffects = append(confounders, iv)
    for (var in confounders) {
        # Is the variable a between-subjects variable? 
        
        if (var@numberOfInstances == 1) {
            RandomIntercept(variable=var, group=var@unit)
        }
        else {
            # The variable is a within-subjects variable. 
            stopifnot(var@numberOfInstances > 1)
            # Are there multiple observations of each instance of the unit? 


            # There is only one observation. 
        }
    }

    # Construct random effects for nesting relationships

    # Construct random effects for non-nesting composition

    # TODO: Construct random effects for interaction effects 

    # Return random effects
    randomEffects
}

