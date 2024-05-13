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

    ## Construct random effects for repeated measures
    mainEffects = append(confounders, iv)
    # Is there more than one observation for every unit?
    if (checkGreaterThan(dv@numberOfInstances, 1)) {
        # browser()
        for (var in mainEffects) {
            
            if (is(var, "Measure")) {
                # Is the variable a between-subjects variable?
                if (checkEquals(var@numberOfInstances, 1)) {
                    randomEffects <- append(randomEffects, RandomIntercept(group=var@unit))
                } else {
                    # The variable is a within-subjects variable.
                    stopifnot(checkGreaterThan(var@numberOfInstances, 1))

                    if (is(var@numberOfInstances, "Per")) {
                        perObj = var@numberOfInstances
                        repeats = perObj@number
                        # Are there multiple observations of each instance of the unit?
                        if (checkGreaterThan(repeats, 1)) {
                            randomEffects <- append(randomEffects, RandomSlope(variable=var, group=var@unit))
                        } else {
                            # There is only one observation (per treatment level, aka perObj@variable)
                            stopifnot(checkEquals(repeats, 1))
                            randomEffects <- append(randomEffects, RandomIntercept(group=var@unit))
                        }

                    } else {
                        # browser()
                        if(is(var@numberOfInstances, "integer")) {
                            # Are there multiple observations of each instance of the unit?
                            repeats = dv@numberOfInstances
                            stopifnot(checkGreaterThan(repeats, 1))
                            if (is(repeats, "Per")) {
                                # Check if the Per Variable is this var
                                if (identical(repeats@variable,var)) {
                                    # Is the Per Value greater than 1?
                                    if (checkGreaterThan(repeats@number, 1)) {
                                        randomEffects <- append(randomEffects, RandomSlope(variable=var, group=var@unit))
                                    } else {
                                        # There is only one observation (per treatment level)
                                        stopifnot(checkEquals(repeats@number, 1))
                                        browser()
                                        randomEffects <- append(randomEffects, RandomIntercept(group=repeats@variable@unit))
                                    }
                                }

                            }
                            # if (checkGreaterThan(repeats, 1)) {
                            #     randomEffects <- append(randomEffects, RandomSlope(variable=var, group=var@unit))
                            # } else {
                            #     # There is only one observation (per treatment level, aka perObj@variable)
                            #     stopifnot(checkEquals(repeats, 1))
                            #     randomEffects <- append(randomEffects, RandomIntercept(group=var@unit))
                            # }
                        } else {
                            msg = paste("Not implemented!", "Variable: ", var@name, sep=" ")
                            # msg = paste("Not implemented!", "Variable: ", var@name, "Number of instances is of type:", typeof(var@numberOfInstances), sep=" ")
                            stop(msg)
                        }
                    }
                }
            } else {
                stopifnot(is(var, "Time"))
                # msg = paste("Not implemented!", "Variable: ", var@name, "Number of instances is of type:", typeof(var@numberOfInstances), sep=" ")
                # msg = paste("Not implemented!", "Variable: ", var@name, sep=" ")
                # stop(msg)
            }
        }
        # Are there multiple observations of each instance of the unit for the DV?
        repeats = dv@numberOfInstances
        stopifnot(checkGreaterThan(repeats, 1))
        if (is(repeats, "Per")) {
            var = repeats@variable
            randomEffects <- append(randomEffects, RandomIntercept(group=dv@unit)) # For the unit who contributes the DV
            if (is(var, "Measure")) {
                randomEffects <- append(randomEffects, RandomIntercept(group=var@unit)) # For the variable that distinguishes the multiple observations
            } else {
                randomEffects <- append(randomEffects, RandomIntercept(group=var)) # For the variable that distinguishes the multiple observations
            }
            
            
            # Is the Per Value greater than 1? / Do we need to add a Random Slope? 
            if (checkGreaterThan(repeats@number, 1)) {
                var = repeats@variable
                randomEffects <- append(randomEffects, RandomIntercept(group=dv@unit)) # For the unit who contributes the DV
                if (is(var, "Measure")) {
                    randomEffects <- append(randomEffects, RandomIntercept(group=var@unit)) # For the variable that distinguishes the multiple observations
                } else {
                    randomEffects <- append(randomEffects, RandomIntercept(group=var)) # For the variable that distinguishes the multiple observations
                }
            } 
            # else {
            #     # There is only one observation (per treatment level)
            #     stopifnot(checkEquals(repeats@number, 1))
            #     var = repeats@variable
            #     randomEffects <- append(randomEffects, RandomIntercept(group=var)) # For the variable that distinguishes the multiple observations
            # }
        }

    }
    
    ## Construct random effects for nesting relationships
    dvUnit = dv@unit # Get the DV's unit

    # Is the DV unit nested in another Unit? 
    if (!is.null(dvUnit@nestsWithin)) {
        unitParent = dvUnit@nestsWithin
        if (is(unitParent, "Unit")) {
            randomEffects <- append(randomEffects, RandomIntercept(group=unitParent)) # For the parent variable
        } else {
            stopifnot(is(unitParent, "list"))
            # Add random intercepts for all the parent units
            for (p in unitParent) {
                randomEffects <- append(randomEffects, RandomIntercept(group=p))
            }
        }  
    } 

    # Construct random effects for non-nesting composition

    # TODO: Construct random effects for interaction effects

    # Filter out duplicate random effects
    randomEffects <- randomEffects[!duplicated(randomEffects)]
    # Return random effects
    randomEffects
}

