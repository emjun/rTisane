
#' Returns list of disambiguation choices
#' @param relationship is a Relates or Causes object
#' @param tag is "Assume" or "Hypothesize"
generateDisambiguationChoices <- function(relationship, tag) {
  choices <- list()

  if (class(relationship) == "Relates") {
    lhs <- relationship@lhs
    rhs <- relationship@rhs
    
    choices <- append(choices, paste(tag, lhs@name, "causes", rhs@name, sep=" "))
    choices <- append(choices, paste(tag, rhs@name, "causes", lhs@name, sep=" "))
  }

  choices
}

#' Output info to JSON
#'
#' Writes info to a JSON file
#' @import jsonlite
#' @param path should be different from "input.json" only for development/testing
# generateConceptualModelJSON()
generateConceptualModelJSON <- function(conceptualModel, path="input.json") {
  output <- list()
  relationships <- list()
  choices <- list()

  for (relat in conceptualModel@relationships) {
  
    relatClass <- class(relat)
    
    if (relatClass == "Assumption") {
      r <- relat@relationship

      # Construct Assumption string
      str <- toString(r)
      str <- paste("Assume", str, sep=" ")

      # Append to output list of relationships
      relationships <- append(relationships, str)

      # Append to list of choices
      disambig_choices <- generateDisambiguationChoices(r, "Assume")
      tmp <- list()
      tmp[[str]] <- disambig_choices
      choices <- append(choices, tmp)
    } else if (relatClass == "Hypothesis") {
      
      r <- relat@relationship

      # Construct Hypothesize string
      str <- toString(r)
      str <- paste("Hypothesize", str, sep=" ")

      # Append to output list of relationships
      relationships <- append(relationships, str)

      # Append to list of choices
      disambig_choices <- generateDisambiguationChoices(r, "Hypothesize")
      tmp <- list()
      tmp[[str]] <- disambig_choices
      choices <- append(choices, tmp)
    } else {
      stopifnot(relatClass == "Interacts")
      # pass
    }
  }

  # Add to output list
  output <- list(relationships=relationships, choices=choices)

  # Write output to JSON file
  jsonlite::write_json(output, path=path, auto_unbox = TRUE)

  # Return path
  path

}

#' Returns handle to variable whose name we know
#'
#' Helper function for navigating and updating a Conceptual Model. Returns handle to a variable or NULL otherwise.
#' precondition: There must be a variable with the @param name in the @param conceptualModel.
#' @param conceptualModel ConceptualModel with a variable of interest.
#' @param name character. Name of variable we would like a handle to.
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
# updateConceptualModel()
updateConceptualModel <- function(conceptualModel, values) {
  # newRelat <- values$uncertainRelationships
  newRelat <- values

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
      # print(paste("tmp:", tmp, sep=" "))
      # print(paste("vars:", vars, sep=" "))
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
    } else if (stringr::str_detect(nr, "Hypothesize ")) {
      # Parse the relationship
      tmp <- stringr::str_split(nr, "Hypothesize ")[[1]]
      vars <- tmp[2]
      vars <- stringr::str_split(vars, " causes ")[[1]]
      # if (length(vars) != 2) {
      #   browser()
      # }
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
    } else {
      stopifnot(stringr::str_detect(nr, "Remove "))
      stopifnot(stringr::str_detect(nr, " causes "))
      tmp <- stringr::str_split(nr, "Remove ")[[1]]
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
      tag <- NULL
      index = NULL
      # print("Look for relationship")
      for (i in 1:length(conceptualModel@relationships)) {
        r <- conceptualModel@relationships[[i]]
        tag <- class(r)
        # Does this relationship match the one we are trying to replace?
        if (class(r@relationship) == "Causes") {
          relat <- r@relationship
          # print(relat)
          if (identical(relat@cause, cause) && identical(relat@effect, effect)) {
            index = i
            print("Found relat: cause --> effect")
          } else if (identical(relat@effect, cause) && identical(relat@cause, effect)) {
            index = i
            print("Found relat: effect --> cause")
          }
          # print("Index: ")
          # print(index)
        }
      }
      stopifnot(!is.null(index))
      # if(is.null(index))  {
      #   browser()
      #   ## START HERE: Spec and graph dont seem to align??
      # }
      conceptualModel@relationships[[index]] = NULL
      # Add the relationship to the Conceptual Model
      # if (tag == "Assumption") {
      #   print("Assumption")
      #   conceptualModel <- assume(conceptualModel, causes(effect, cause))
      # } else {
      #   stopifnot(tag == "Hypothesis")
      #   print("Hypothesis")
      #   conceptualModel <- hypothesize(conceptualModel, causes(effect, cause))
      # }
    }
  }
  # Update the Conceptual Model to reflect new relationships
  conceptualModel@graph <- updateGraph(conceptualModel)
  # print(conceptualModel@graph)

  # Return updated Conceptual Model
  stopifnot(!is.null(conceptualModel))
  conceptualModel
}


# refineConceptualModel <- function(conceptualModel) {
#   # Write ConceptualModel to JSON, which is read to create disambiguation GUI
#   path <- generateConceptualModelJSON(conceptualModel)

#   # Start up disambiguation process
#   inputFilePath <- path
#   updates <- disambiguateConceptualModel(conceptualModel=conceptualModel, inputFilePath=path)
#   # For Conceptual Model UI development
#   # updates <- disambiguateConceptualModel(conceptualModel=conceptualModel, inputFilePath="test-new-input.json")

#   # Update Conceptual Model
#   cmUpdated <- updateConceptualModel(conceptualModel, updates)  

#   cmUpdated
# }

#' Elicit any additional information about Conceptual Model (graph) if necessary
#'
#' This function disambiguates the Conceptual Model before using it in future query steps.
#' @param conceptualModel ConceptualModel. Contains causal graph to process.
#' @param iv AbstractVariable. Independent variable whose influence on @param dv we want to assess.
#' @param dv AbstractVariable. Dependent variable.
#' @return updated conceptual model 
# processQuery()
setGeneric("processQuery", function(conceptualModel, iv, dv, data) standardGeneric("processQuery"))
setMethod("processQuery", signature("ConceptualModel", "AbstractVariable", "AbstractVariable", "characterORDataframeORnull"), function(conceptualModel, iv, dv, data)
{
  # # Write ConceptualModel to JSON, which is read to create disambiguation GUI
  # path <- generateConceptualModelJSON(conceptualModel)

  # # Start up disambiguation process
  # inputFilePath <- path
  # updates <- disambiguateConceptualModel(conceptualModel=conceptualModel, iv=iv, dv=dv, inputFilePath=path)

  # # Update DV, Update Conceptual Model
  # # dvUpdated <- updateDV(dv, updates)
  # cmUpdated <- updateConceptualModel(conceptualModel, updates)

  updatedCM <- checkAndRefineConceptualModel(conceptualModel, iv, dv)

  # results <- list(updatedConceptualModel=cmUpdated)

  # Return updated conceptual model
  updatedCM
})
