#' Output info to JSON
#'
#' Writes info to a JSON file
#' @param dv AbstractVariable to write to JSON.
#' @import jsonlite
#' @keywords
#' @examples
#' generateJSON()
generateJSON <- function(conceptualModel, dv, path) {
  #### Generate options for DV
  dvClass = class(dv)
  # Create options
  dvOptions <- list()
  if (dvClass == "Numeric") {
    # dvOptions <- append(dvOptions, "Continuous")
    # dvOptions <- append(dvOptions, "Counts")
    dvOptions <- c("Continuous", "Counts")
  } else if (dvClass == "Ordinal") {
    # dvOptions <- append(dvOptions, "Continuous")
    # dvOptions <- append(dvOptions, "Counts")
    # dvOptions <- append(dvOptions, "Categories")
    dvOptions <- c("Continuous", "Counts", "Categories")
  } else {
    stopifnot(dvClass == "Nominal")
    # dvOptions <- append(dvOptions, "Categories")
    dvOptions <- c("Categories")
  }

  # Populate list to output 
  output <- list(dvName = dv@name, dvClass = dvClass, dvOptions = dvOptions)

  #### Generate options for Conceptual Model 
  ambigRelationships <- c()
  ambigOptions1 <- c()
  ambigOptions2 <- c()

  relatationships <- conceptualModel@relationships
  for (relat in relatationships) {
    relatClass <- class(relat)
    # Could be Assumption or Hypothesis
    stopifnot(relatClass == "Assumption" || relatClass=="Hypothesis")

    r <- relat@relationship 
    rClass <- class(r)
    if (rClass == "Relates") {
        # Create and track relationship
        relatString <- paste(r@lhs@name, "is related to", r@rhs@name, sep=" ")
        ambigRelationships <- append(ambigRelationships, relatString)

        # Create options to resolve/make more specific relationship
        ambigOptions1 <- append(ambigOptions1, paste(r@lhs@name, "causes", r@rhs@name, sep=" "))
        ambigOptions2 <- append(ambigOptions2, paste(r@rhs@name, "causes", r@lhs@name, sep=" ")) 
    } else if (rClass == "Moderates") {
      cat("DO SOMETHING!")
    } else {
      stopifnot(rClass == "Causes")  # Could Moderates reach here?
      # Do nothing for causes relationships
    }
  }

  # Add to output list 
  # stopifnot(length(ambigRelationships) == length(ambigOptions))
  if (length(ambigRelationships) > 0) {
    output <- append(output, list(ambiguousRelationships = ambigRelationships, ambiguousOptions1 = ambigOptions1, ambiguousOptions2 = ambigOptions2))
  }
  # Write output to JSON file
  write_json(output, path=path)

  # Return path
  path
}

#' Updates DV type
#'
#' Casts DV to be Continuous, Counts, or Categories, which is necessary to infer family and link functions
#' @param dv AbstractVariable to cast.
#' @param values ReactiveValues from disambiguating DV type.
#' @keywords
#' @examples
#' updateDV()
updateDV <- function(dv, values) {
  # Extract values from disambiguation process
  dvName <- values$dvName
  dvType <- values$dvType
  stopifnot(dvName == dv@name)

  # Update DV
  updatedDv <- NULL
  if (dvType == "Continuous") {
    updatedDv <- asContinuous(dv)
  } else if (dvType == "Counts") {
    updatedDv <- asCounts(dv)
  } else {
    stopifnot(dvType == "Categories")
    updatedDv <- asCategories(dv)
  }

  # Return updated DV
  stopifnot(!is.null(updatedDv))
  updatedDv
}


#' Updates Conceptual Model
#'
#' Updates Conceptual model based on analyst input during disambiguation
#' @param conceptualModel ConceptualModel to update.
#' @param values ReactiveValues from disambiguating DV type.
#' @keywords
#' @examples
#' updateConceptualModel()
updateConceptualModel <- function(conceptualModel, values) {

  browser()

  # Return updated Conceptual Model
  stopifnot(!is.null(conceptualModel))
  conceptualModel
}

#' Elicit any additional information about Conceptual Model (graph) if necessary
#'
#' This function disambiguates the Conceptual Model before using it in future query steps.
#' @param conceptualModel ConceptualModel. Contains causal graph to process.
#' @return
#' @keywords
#' @examples
#' processQuery()
setGeneric("processQuery", function(conceptualModel, iv, dv) standardGeneric("processQuery"))
setMethod("processQuery", signature("ConceptualModel", "AbstractVariable", "AbstractVariable"), function(conceptualModel, iv, dv)
{
  # Write DV to JSON, which is read to create disambiguation GUI
  path <- generateJSON(conceptualModel, dv, "input.json")

  # Start up disambiguation process
  inputFilePath <- path
  dataPath = NULL
  updates <- disambiguateConceptualModel(conceptualModel=conceptualModel, dv=dv, inputFilePath=path, dataPath=dataPath)
  
  # Update DV, Update Conceptual Model
  dvUpdated <- updateDV(dv, updates)
  cmUpdated <- updateConceptualModel(conceptualModel, updates)


  # Show variables

  # DV as Continuous/Counts/Categories?

  # Do we have any ambiguous relationships?
  # Which direction are "relates"?
  # For WhenThen, does that mean A --> B or B --> A or ....?


})
