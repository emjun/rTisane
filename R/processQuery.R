#' Output info to JSON
#'
#' Writes info to a JSON file
#' @import jsonlite
#' @keywords
# generateConceptualModelJSON()
generateConceptualModelJSON <- function(conceptualModel, path) {
  output <- list()
  #### Generate options for Conceptual Model
  ambigRelationships <- c()
  ambigOptions1 <- c()
  ambigOptions2 <- c()

  relatationships <- conceptualModel@relationships
  for (relat in relatationships) {
    relatClass <- class(relat)

    r <- relat@relationship
    rClass <- class(r)

    if (relatClass == "Assumption") {
      if (rClass == "Relates") {
        # Create and track relationship
        relatString <- paste("assume", r@lhs@name, "is related to", r@rhs@name, sep=" ")
        ambigRelationships <- append(ambigRelationships, relatString)

        # Create options to resolve/make more specific relationship
        ambigOptions1 <- append(ambigOptions1, paste("Assume", r@lhs@name, "causes", r@rhs@name, sep=" "))
        ambigOptions2 <- append(ambigOptions2, paste("Assume", r@rhs@name, "causes", r@lhs@name, sep=" "))
      } else {
        stopifnot(rClass == "Causes")  # Could Moderates reach here?
        # Do nothing for causes relationships
      }
    } else {
      stopifnot(relatClass == "Hypothesis")
      if (rClass == "Relates") {
        # Create and track relationship
        relatString <- paste("hypothesize", r@lhs@name, "is related to", r@rhs@name, sep=" ")
        ambigRelationships <- append(ambigRelationships, relatString)

        # Create options to resolve/make more specific relationship
        ambigOptions1 <- append(ambigOptions1, paste("Hypothesize", r@lhs@name, "causes", r@rhs@name, sep=" "))
        ambigOptions2 <- append(ambigOptions2, paste("Hypothesize", r@rhs@name, "causes", r@lhs@name, sep=" "))
      } else {
        stopifnot(rClass == "Causes")  # Could Moderates reach here?
        # Do nothing for causes relationships
      }
    }
  }

  # Add to output list
  # stopifnot(length(ambigRelationships) == length(ambigOptions))
  if (length(ambigRelationships) > 0) {
    output <- append(output, list(ambiguousRelationships = ambigRelationships, ambiguousOptions1 = ambigOptions1, ambiguousOptions2 = ambigOptions2))
  }

  # Write output to JSON file
    jsonlite::write_json(output, path=path, auto_unbox = TRUE)

  # Return path
  path
}

#' Updates DV type
#'
#' Casts DV to be Continuous, Counts, or Categories, which is necessary to infer family and link functions
#' @param dv AbstractVariable to cast.
#' @param values ReactiveValues from disambiguating DV type.
#' @import stringr
#' @keywords
# updateDV()
updateDV <- function(dv, values) {
  # Extract values from disambiguation process
  dvName <- values$dvName
  dvType <- values$dvType
  stopifnot(dvName == dv@name)

  # Update DV
  updatedDv <- NULL
  if (stringr::str_detect(dvType, "continuous")) {
    updatedDv <- asContinuous(dv)
  } else if (stringr::str_detect(dvType, "counts")) {
    updatedDv <- asCounts(dv)
  } else {
    browser()
    stopifnot(stringr::str_detect(dvType, "categories"))
    updatedDv <- asCategories(dv)
  }

  # Return updated DV
  stopifnot(!is.null(updatedDv))
  updatedDv
}

#' Returns handle to variable whose name we know
#'
#' Helper function for navigating and updating a Conceptual Model. Returns handle to a variable or NULL otherwise.
#' precondition: There must be a variable with the @param name in the @param conceptualModel.
#' @param conceptualModel ConceptualModel with a variable of interest.
#' @param name character. Name of variable we would like a handle to.
#' @keywords
# getVariable()
getVariable <- function(conceptualModel, name) {
  for (v in conceptualModel@variables) {
    if (v@name == name) {
      return(v)
    }
  }

  # Return null if haven't found variable yet
  NULL
}



#' Updates Conceptual Model
#'
#' Updates Conceptual model based on analyst input during disambiguation
#' @param conceptualModel ConceptualModel to update.
#' @param values ReactiveValues from disambiguating DV type.
#' @import stringr
#' @keywords
# updateConceptualModel()
updateConceptualModel <- function(conceptualModel, values) {
  newRelat <- values$uncertainRelationships

  # Are there any new relationships to process?
  # There are no relationships to process. Return the original conceptual model
  if (is.null(newRelat)) {
    return(conceptualModel)
  }
  # else
  # There are relationships to process.
  for (nr in newRelat) {
    assump <- FALSE
    # Is this an Assumption or Hypothesis?
    if (stringr::str_detect(nr, "Assume ")) {

      # Parse the relationship
      tmp <- stringr::str_split(nr, "Assume ")[[1]]
      vars <- tmp[2]
      vars <- stringr::str_split(vars, " causes ")[[1]]
      stopifnot(length(vars) == 2)

      # Find the variables involved in the new relationship
      cause <- getVariable(conceptualModel, vars[1])
      effect <- getVariable(conceptualModel, vars[2])

      # Make sure the variables already exist in the Conceptual Model
      variables <- conceptualModel@variables
      stopifnot(c(cause) %in% variables)
      stopifnot(c(effect) %in% variables)

      # Remove the older relationship
      index = 1
      for (i in 1:length(conceptualModel@relationships)) {
        r <- conceptualModel@relationships[[i]]
        # Does this relationship match the one we are trying to replace?
        if (class(r) == "Assumption") {
            if (class(r@relationship) == "Relates") {
              relat <- r@relationship
              if (identical(relat@lhs, cause) && identical(relat@rhs, effect)) {
                index = i
                break
              } else if (identical(relat@lhs, effect) && identical(relat@rhs, cause)) {
                index = i
                break
              }
            }
        }
      }
      conceptualModel@relationships[[index]] = NULL
      # if (is.null(relatToAdd)) {
      #   browser()
      # }
      # Add the relationship to the Conceptual Model
      conceptualModel <- assume(conceptualModel, causes(cause, effect))
    } else {
      stringr::str_detect(nr, "Hypothesize ")

      # Parse the relationship
      tmp <- stringr::str_split(nr, "Hypothesize ")[[1]]
      vars <- tmp[2]
      vars <- stringr::str_split(vars, " causes ")[[1]]
      stopifnot(length(vars) == 2)

      # Find the variables involved in the new relationship
      cause <- getVariable(conceptualModel, vars[1])
      effect <- getVariable(conceptualModel, vars[2])

      # Make sure the variables already exist in the Conceptual Model
      variables <- conceptualModel@variables
      stopifnot(c(cause) %in% variables)
      stopifnot(c(effect) %in% variables)

      # Remove the older relationship
      index = 1
      for (i in 1:length(conceptualModel@relationships)) {
        r <- conceptualModel@relationships[[i]]
        # Does this relationship match the one we are trying to replace?
        if (class(r) == "Hypothesis") {
          if (class(r@relationship) == "Relates") {
            relat <- r@relationship
            if (identical(relat@lhs, cause) && identical(relat@rhs, effect)) {
              index = i
              break
            } else if (identical(relat@lhs, effect) && identical(relat@rhs, cause)) {
              index = i
              break
            }
          }
        }
      }
      conceptualModel@relationships[[index]] = NULL
      # Add the relationship to the Conceptual Model
      conceptualModel <- hypothesize(conceptualModel, causes(cause, effect))
    }
  }

  # Update the Conceptual Model to reflect new relationships
  conceptualModel@graph <- updateGraph(conceptualModel)

  # Return updated Conceptual Model
  stopifnot(!is.null(conceptualModel))
  conceptualModel
}


refineConceptualModel <- function(conceptualModel) {
  # Write ConceptualModel to JSON, which is read to create disambiguation GUI
  path <- generateConceptualModelJSON(conceptualModel, "input.json")

  # Start up disambiguation process
  inputFilePath <- path
  updates <- disambiguateConceptualModel(conceptualModel=conceptualModel, iv=iv, dv=dv, inputFilePath=path)

  # Update Conceptual Model
  cmUpdated <- updateConceptualModel(conceptualModel, updates)  

  cmUpdated
}

#' Elicit any additional information about Conceptual Model (graph) if necessary
#'
#' This function disambiguates the Conceptual Model before using it in future query steps.
#' @param conceptualModel ConceptualModel. Contains causal graph to process.
#' @param iv AbstractVariable. Independent variable whose influence on @param dv we want to assess.
#' @param dv AbstractVariable. Dependent variable.
#' @return
#' @keywords
# processQuery()
setGeneric("processQuery", function(conceptualModel, iv, dv, data) standardGeneric("processQuery"))
setMethod("processQuery", signature("ConceptualModel", "AbstractVariable", "AbstractVariable", "characterORDataframeORnull"), function(conceptualModel, iv, dv, data)
{
  # Write ConceptualModel to JSON, which is read to create disambiguation GUI
  path <- generateConceptualModelJSON(conceptualModel, "input.json")

  # Start up disambiguation process
  inputFilePath <- path
  updates <- disambiguateConceptualModel(conceptualModel=conceptualModel, iv=iv, dv=dv, inputFilePath=path)

  # Update DV, Update Conceptual Model
  # dvUpdated <- updateDV(dv, updates)
  cmUpdated <- updateConceptualModel(conceptualModel, updates)

  results <- list(updatedConceptualModel=cmUpdated)

  # Return updated values
  results
})
