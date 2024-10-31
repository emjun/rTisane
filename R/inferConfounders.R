setGeneric("isObserved", function(conceptualModel, variable) standardGeneric("isObserved"))
setMethod("isObserved", signature("ConceptualModel", "AbstractVariable"), function(conceptualModel, variable)
{
  for (v in conceptualModel@variables) {
    if (variable@name == v@name) {
      return(is(v, "Measure"))
    }
  }
})
setMethod("isObserved", signature("ConceptualModel", "character"), function(conceptualModel, variable)
{
  for (v in conceptualModel@variables) {
    if (variable == v@name) {
      return(is(v, "Measure"))
    }
  }
})
setMethod("isObserved", signature("ConceptualModel", "UnobservedVariable"), function(conceptualModel, variable)
{
  FALSE
})


#' Find mediators.
#'
#' This function finds Observed mediators on paths between @param x and @param y
#' Helper function to follow recommendations from Cinelli, Forney, and Pearl 2020
#' @param ConceptualModel Conceptual model whose graph to analyze
#' @param x character. Name of AbstractVariable in @param graph.
#' @param y character. Name of AbstractVariable in @param graph.
#' @return list of Observed mediators.
#' @import dagitty
# getMediators()
getMediators <- function(conceptualModel, x, y) {
  graph = conceptualModel@graph
  mediators = list()
  xyPaths <- paths(graph, from=x, to=y)$paths

  for (path in xyPaths) {
    # Do we have two -> ??
    tokenLength = 2
    expMatches <- gregexpr("->", path)
    backwardMatches <- gregexpr("<-", path)
    # Found a mediator!
    if (length(expMatches[[1]]) == 2 && backwardMatches[[1]][1] == -1) {
      firstIdx = expMatches[[1]][1]
      secondIdx = expMatches[[1]][2]

      start = firstIdx + tokenLength
      end = secondIdx - 1
      stopifnot(start < end)
      mediatorName = substr(path, start, end)
      # Strip whitespace
      mediatorName = trimws(mediatorName)

      # Mediators must be Observed
      if (isObserved(conceptualModel, mediatorName)) {
        # Add to list of mediators
        mediators <- append(mediators, mediatorName)
      }
    }
  }
  # Return mediators
  mediators
}

#' Infer confounders to account for when assessing the direct effect of @param iv on @param dv.
#'
#' This function findings confounders to account for.
#' Follows recommendations from Cinelli, Forney, and Pearl 2020
#' @param conceptualModel ConceptualModel. With causal graph to use in order to identify confounders.
#' @param iv AbstractVariable. Independent variable that should cause (directly or indirectly) the @param dv.
#' @param dv AbstractVariable. Dependent variable that should not cause the @param iv.
#' @return list of confounders to include.
#' @import dagitty
# inferConfounders()
setGeneric("inferConfounders", function(conceptualModel, iv, dv) standardGeneric("inferConfounders"))
setMethod("inferConfounders", signature("ConceptualModel", "AbstractVariable", "AbstractVariable"), function(conceptualModel, iv, dv)
{
  confounders <- list()
  gr <- conceptualModel@graph
  nodes <- names(gr) # Get the names of nodes in gr

  # Models 1, 2, and 3: Good Controls
  ivParents <- parents(gr, iv@name)
  dvParents <- parents(gr, dv@name)
  commonParents <- intersect(ivParents, dvParents)

  # Model 1: Common cause of both IV and DV
  for (p in commonParents) {
    # Is p an Observed variable?
    if (isObserved(conceptualModel, p)) {
      confounders <- append(confounders, p)
    }
  }

  # Model 2: Unobserved variable is common cause of IV and DV, but Z is mediating Unobserved --> Z --> X
  for (ip in ivParents) {
    ivGrandparentsUnobserved <- list()

    tmp <- parents(gr, ip)
    for (v in tmp) {
      if (!isObserved(conceptualModel, v)) {
        ivGrandparentsUnobserved <- append(ivGrandparentsUnobserved, v)
      }
    }

    for (gp in ivGrandparentsUnobserved) {
      if (gp %in% dvParents) {
        if (isObserved(conceptualModel, ip)) {
          # Add Z to confounders
          confounders <- append(confounders, ip)
        }
      }
    }
  }

  # Model 3: Unobserved variable is common cause of IV and DV, but Z is mediating Unobserved --> Z --> Y
  for (dp in dvParents) {
    dvGrandparentsUnobserved <- list()

    tmp <- parents(gr, dp)
    for (v in tmp) {
      if (!isObserved(conceptualModel, v)) {
        dvGrandparentsUnobserved <- append(dvGrandparentsUnobserved, v)
      }
    }

    for (gp in dvGrandparentsUnobserved) {
      if (gp %in% ivParents) {
        if (isObserved(conceptualModel, dp)) {
          # Exclude IV
          if (dp != iv@name)  {
            # Add Z to confounders
            confounders <- append(confounders, dp)
          }
        }
      }
    }
  }

  # Model 4: Common cause of X and any mediator between X and Y
  mediators <- getMediators(conceptualModel, iv@name, dv@name)
  for (m in mediators) {
    mParents <- parents(gr, m)

    sharedParents <- intersect(ivParents, mParents)

    for (sp in sharedParents) {
      if (isObserved(conceptualModel, sp)) {
        confounders <- append(confounders, sp)
      }
    }
  }

  # # Model 5: Unobserved variable is common ancestor of IV and Mediator, but Z is mediating Unobserved --> Z --> M
  ivParentsUnobserved = NULL
  for (ip in ivParents) {
    if (!isObserved(conceptualModel, ip)) {
      ivParentsUnobserved <- append(ivParentsUnobserved, ip)
    }
  }
  for (m in mediators) {
    mParents <- parents(gr, m)

    for (mp in mParents) {
      # Only consider mediator parents that are not the IV
      if (mp != iv@name) {
        mGrandparents <- parents(gr, mp)

        sharedAncestors <- intersect(ivParentsUnobserved, mGrandparents)
        if (length(sharedAncestors) == 1) {
          confounders <- append(confounders, mp)
        }
      }
    }
  }

  # Model 6: Unobserved variable is common ancestor of IV and Mediator, but Z is mediating Unobserved --> Z --> X (Unobserved --> M)
  mParentsUnobserved = NULL
  for (m in mediators) {
    mParents <- parents(gr, m)

    for (mp in mParents) {
      if (!isObserved(conceptualModel, mp)) {
        mParentsUnobserved <- append(mParentsUnobserved, mp)
      }
    }
    for (mpu in mParentsUnobserved) {
      for (ip in ivParents) {
        ivGrandparents <- parents(gr, ip)

        sharedAncestors <- intersect(ivGrandparents, mParentsUnobserved)
        if (length(sharedAncestors) == 1) {
          confounders <- append(confounders, ip)
        }
      }
    }
  }

  # Neutral Controls
  # Model 8: Parent of Y that is unrelated to X (Maybe good for precision)
  for (dp in dvParents) {
    # Is dp observed?
    if (isObserved(conceptualModel, dp)) {
      dAncestors <- ancestors(gr, dp) # dAncestors has dp in the list
      # Not a shared a common parent of IV
      if ((length(dAncestors) == 1) && (dAncestors[[1]] == dp)) {
        # Exclude IV as a parent of DV
        if(dp != iv@name) {
          # Is the ancestor's only child the DV?
          aChildren <- children(gr, dp)
          if ((length(aChildren) == 1) && (aChildren[[1]] == dv@name)) {
            confounders <- append(confounders, dp)
          }
        }
      }
    }
  }

  # # SKIP: Model 9: Parent of X that is unrelated to Y (Maybe bad for precision)

  # Model 13: Parent of Mediator (Maybe good for precision)
  for (m in mediators) {
    mParents <- parents(gr, m)

    for (mp in mParents) {
      # Exclude IV as a parent of DV
      if (mp!= iv@name && isObserved(conceptualModel, mp)) {
        mpAncestors <- ancestors(gr, mp)
        # Mediator's parent has no other ancestors
        if ((length(mpAncestors) == 1) && (mpAncestors[[1]] == mp)) {
          # Mediator's parent has no other children
          mpChildren <- children(gr, mp)
          if ((length(mpChildren) == 1) && (mpChildren[[1]] == m)) {
            confounders <- append(confounders, mp)
          }
        }
      }
    }
  }
  # Model 14, 15: Post-treatment (Maybe good for selection bias)
  # Model 14: Child of X
  ivChildren <- children(gr, iv@name)
  for (ic in ivChildren) {
    # Don't consider the IV, Don't consider the DV, and Is the child Observed?
    if ((ic != iv@name) && (ic != dv@name) && (isObserved(conceptualModel, ic))) {
      # The child has no other ancestors except itself and the IV
      icAncestors <- ancestors(gr, ic)
      if ((length(icAncestors) == 2) && (ic %in% icAncestors) && (iv@name %in% icAncestors)) {
        # The child has no other children
        icChildren <- children(gr, ic)
        if (length(icChildren) == 0) {
          confounders <- append(confounders, ic)
        }
      }
    }
  }

  # Model 15: Child of X that has child that is also child of Unobserved variable that causes Y
  ivChildrenObserved = NULL
  for (ic in children(gr, iv@name)) {
    # Don't consider the IV and Is the child Observed?
    if ((ic != iv@name) && (isObserved(conceptualModel, ic))) {
      ivChildrenObserved <- append(ivChildrenObserved, ic)
    }
  }


  dvParentsUnobserved = NULL
  for (dp in dvParents) {
    if(!isObserved(conceptualModel, dp)) {
      dvParentsUnobserved <- append(dvParentsUnobserved, dp)
    }
  }

  for (ico in ivChildrenObserved) {
    ivGrandchildren <- children(gr, ico)
    for (ig in ivGrandchildren) {
      if (isObserved(conceptualModel, ig)) {
        for (dp in dvParentsUnobserved) {
          dpChildren <- children(gr, dp)

          if (c(ig) %in% dpChildren) {
            confounders <- append(confounders, ico)
          }
        }
      }
    }
  }


  # # Bad Controls (Pre-treatment, )
  # # Model 7: Unobserved variables of X and Y both cause Z
  #
  # # Model 10: Parent of X in the presence of common Unobserved parent shared between X and Y.
  #
  # # Model 11: Mediator (X --> Z --> Y)
  #
  # # Model 12: Child of Mediator
  #
  # # Model 16: Child of X that is direct child of Unobserved variable that is also parent to Y
  #
  # # Model 17: "Case-control bias"/"Selection bias" Child of Y


  # Return list of confounders
  confounders
})
