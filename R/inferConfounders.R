# getVariableType <- function(conceptualModel, variable) {
#   for (v in conceptualModel@variables) {
#     if (variable@name == v@name) {
#       return(class(v))
#     }
#   }
# }

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
#' This function findings mediators on paths between @param x and @param y
#' Helper function to follow recommendations from Cinelli, Forney, and Pearl 2020
#' @param graph DAG (from dagitty) that is part of a ConceptualModel.
#' @param x character. Name of AbstractVariable in @param graph.
#' @param y character. Name of AbstractVariable in @param graph.
#' @return list of mediators.
#' @import dagitty
#' @keywords
#' @examples
#' getMediators()
getMediators <- function(graph, x, y) {
  mediators = list()
  xyPaths <- paths(graph, from=x, to=y)

  for (path in xyPaths) {
    # Do we have two -> ??
    tokenLength = 2
    expMatches <- gregexpr("->", path)
    # Found a mediator!
    if (length(expMatches[[1]]) == 2) {
      firstIdx = expMatches[[1]][1]
      secondIdx = expMatches[[1]][2]

      start = firstIdx + tokenLength
      end = secondIdx - 1
      stopifnot(start < end)
      mediatorName = substr(path, start, end)
      # Strip whitespace
      mediatorName = trimws(mediatorName)

      # Add to list of mediators
      mediators <- append(mediators, mediatorName)
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
#' @keywords
#' @examples
#' inferConfounders()
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
  # mediators <- getMediators(gr, iv, dv)
  # mParentsObserved = list()
  # mParentsUnobserved = list()
  # for (m in mediators) {
  #   mps <- parents(gr, m)
  #   for (p in mps) {
  #     if (isObserved(p)) {
  #       mParentsObserved <- append(mParentsObserved, p)
  #     } else {
  #       mParentsUnobserved <- append(mParentsUnobserved, p)
  #     }
  #   }
  # }
  # commonMediatorParents <- intersect(ivParents, mParentsObserved)
  #
  # # Model 5: Unobserved variable is common ancestor of IV and Mediator, but Z is mediating Unobserved --> Z --> M
  # mediatorGrandparentsUnobserved = list()
  # for (mp in mParentsObserved) {
  #   grandparents <- parents(gr, mp)
  #
  #   for (gp in grandparents) {
  #     # Check that the grandparent is UNOBSERVED
  #     if (!isObserved(gp)) {
  #       mediatorGrandparentsUnobserved <- append(mediatorGrandparentsUnobserved, gp)
  #     }
  #   }
  #   commonAncestorsUnobserved <- intersect(ivParents, mediatorGrandparentsUnobserved)
  #   if (length(commonAncestorsUnobserved) > 0) {
  #    confounders <- append(confounders, mp)
  #   }
  #   mediatorGrandparentsUnobserved <- list()
  # }
  #
  # # Model 6: Unobserved variable is common ancestor of IV and Mediator, but Z is mediating Unobserved --> Z --> X (Unobserved --> M)
  # for (ip in ivParents) {
  #   ivGrandparents <- parents(gr, ip)
  #
  #   for (gp in ivGrandparents) {
  #     # Check that the grandparent is UNOBSERVED
  #     if (!isObserved(gp)) {
  #       # Is the Unobserved grandparent also the parent of the mediator?
  #       if (gp %in% mParentsUnobserved) {
  #         confounders <- append(confounders, ip)
  #       }
  #     }
  #   }
  # }
  #
  # # Neutral Controls
  # # Model 8: Parent of Y that is unrelated to X (Maybe good for precision)
  # for (dp in dvParents) {
  #   # Not a shared a common parent of IV
  #   if (!(dp %in% commonParents)) {
  #     confounders <- append(confounders, dp)
  #   }
  # }
  #
  # # SKIP: Model 9: Parent of X that is unrelated to Y (Maybe bad for precision)
  #
  # # Model 13: Parent of Mediator (Maybe good for precision)
  # mParentsObserved
  #
  # for (mp in mParentsObserved) {
  #  ps = paths(gr, iv@name, mp)
  #  closedPaths = list()
  #  # TODO: Check and add closed paths?
  # }
  #
  # # Model 14, 15: Post-treatment (Maybe good for selection bias)
  # # Model 14: Child of X
  # ivChildren <- children(gr, iv@name)
  # # TODO: Check that children are not related to Y in any way except through X
  #
  # # Model 15: Child of X that has child that is also child of Unobserved variable that causes Y
  # dvParentsUnobserved
  # for (dp in dvParentsUnobserved) {
  #   # Get children
  #   childrenUnobserved = children(gr, dp)
  #
  #   # Check if there is a path between IV and each childrenUnobserved
  #   # Is there an Observed mediator on this path?
  #   # If so, add to confounders
  # }
  #
  #
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


  # Return confounders
  confounders
})
