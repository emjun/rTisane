#' Find family functions.
#'
#' This function finds possible family functions.
#' Helper function to infer family and link function pairs
#' @param dv AbstractVariable. Variable whose outcome we want to assess.
#' @return list of possible family functions
# inferFamilyFunctions()
inferFamilyFunctions <- function(dv) {
  familyCandidates = NULL

  if (class(dv) == "Continuous") {
    # Positive skew
    familyCandidates <- append(familyCandidates, "Inverse Gaussian")
    familyCandidates <- append(familyCandidates, "Gamma")
    # None
    familyCandidates <- append(familyCandidates, "Gaussian")
    # if (dv@skew == "positive") {
    #   familyCandidates <- append(familyCandidates, "Inverse Gaussian")
    #   familyCandidates <- append(familyCandidates, "Gamma")
    # } else {
    #   stopifnot(dv@skew == "none")
    #     familyCandidates <- append(familyCandidates, "Gaussian")
    #   }
  } else if (class(dv) == "Counts") {
    familyCandidates <- append(familyCandidates, "Poisson")
    familyCandidates <- append(familyCandidates, "Negative Binomial")
  } else if (class(dv) == "OrderedCategories") {
    if (dv@cardinality == 2) {
      familyCandidates <- append(familyCandidates, "Binomial")
    } else {
      stopifnot(dv@cardinality > 2)
      familyCandidates <- append(familyCandidates, "Multinomial")
      familyCandidates <- append(familyCandidates, "Inverse Gaussian")
      familyCandidates <- append(familyCandidates, "Gamma")
      familyCandidates <- append(familyCandidates, "Gaussian")
    }
  } else {
    stopifnot(class(dv) == "Categories")
    if (dv@cardinality == 2) {
      familyCandidates <- append(familyCandidates, "Binomial")
    } else {
      stopifnot(dv@cardinality > 2)
      familyCandidates <- append(familyCandidates, "Multinomial")
    }
  }

  # Return family candidates
  stopifnot(length(familyCandidates) > 0)
  familyCandidates
}

#' Find link function for a given family function.
#'
#' This function finds possible link functions for a family function.
#' Helper function to infer family and link function pairs
#' @param family character. Name of family function for which we want to infer possible link functions.
#' @return list of possible link functions
# inferLinkFunctions()
inferLinkFunctions <- function(family) {
  linkFunctions = list()
  if (family == "Binomial") {
    linkFunctions <- append(linkFunctions, "logit") # default (logistic CDF)
    linkFunctions <- append(linkFunctions, "probit") # normal CDF
    linkFunctions <- append(linkFunctions, "cauchit") # Cauchy CDF
    linkFunctions <- append(linkFunctions, "log")
    linkFunctions <- append(linkFunctions, "cloglog")
  } else if (family == "Gamma") {
    linkFunctions <- append(linkFunctions, "inverse") # default
    linkFunctions <- append(linkFunctions, "identity")
    linkFunctions <- append(linkFunctions, "log")
  } else if (family == "Gaussian") {
    linkFunctions <- append(linkFunctions, "identity") # default
    linkFunctions <- append(linkFunctions, "log")
    linkFunctions <- append(linkFunctions, "inverse")
  } else if (family == "Inverse Gaussian") {
    linkFunctions <- append(linkFunctions, "1/mu^2") # default
    linkFunctions <- append(linkFunctions, "inverse")
    linkFunctions <- append(linkFunctions, "identity")
    linkFunctions <- append(linkFunctions, "log")
  } else if (family == "Negative Binomial") { # uses glm.nb
    linkFunctions <- append(linkFunctions, "log") # default
    linkFunctions <- append(linkFunctions, "sqrt")
    linkFunctions <- append(linkFunctions, "identity")
  } else if (family == "Poisson") {
    linkFunctions <- append(linkFunctions, "log") # default
    linkFunctions <- append(linkFunctions, "identity")
    linkFunctions <- append(linkFunctions, "sqrt")
  } else {
    stopifnot(family == "Multinomial")
    # TODO: Fill in with link options
  }

  # Return link function candidates
  # stopifnot(length(linkFunctions) > 0)
  linkFunctions
}

#' Infer possible family and link functions for statistical model.
#'
#' Infers possible family and link function pairs for dependent variable
#' Returns a list of possible family and link function pairs.
#' @param dv ContinuousORCountsORCategories. Wrapped Measure whose outcome we want to assess.
# inferFamilyLinkFunctions()
setGeneric("inferFamilyLinkFunctions", function(dv) standardGeneric("inferFamilyLinkFunctions"))
setMethod("inferFamilyLinkFunctions", signature("ContinuousORCountsORCategories"), function(dv)
{
  familyLinkPairs <- list()

  familyCandidates <- inferFamilyFunctions(dv)
  for (f in familyCandidates) {
    linkCandidates <- inferLinkFunctions(f)
    familyLinkPairs[[f]] <- linkCandidates
  }

  # Return family and link candidates
  stopifnot(length(familyLinkPairs) == length(familyCandidates))
  familyLinkPairs
})
