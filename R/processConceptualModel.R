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
  
  #### Generate options for Conceptual Model 
  ambigRelationships <- c()
  ambigOptions <- list()
  relatationships <- conceptualModel@relationships
  for (relat in relatationships) {
    r <- relat@relationship # Could be Assumption or Hypothesis
    rClass <- class(r)

    if (rClass == "Relates") {
        # Create and track relationship
        relatString <- paste(r@lhs, "is related to", r@rhs, sep=" ")
        ambigRelationships <- append(ambigRelationships, relatString)

        # Create options to resolve/make more specific relationship
        options <- c(paste(r@lhs, "causes", r@rhs, sep=" "), paste(r@rhs, "causes", r@lhs, sep=" ")) 
        ambigOptions <- append(ambigOptions, list(relatString=options))
    } else if (rClass == "WhenThen") {
        # Create and track relationship 
        relatString <- paste(r@lhs, "is related to", r@rhs, sep=" ")
        ambigRelationships <- append(ambigRelationships, relatString)

    } else {
      stopifnot(rClass == "Causes") 
      # Do nothing for causes relationships
    }
    
    
  }

  
  # Create list to output
  dvInfo <- list(dvName = dv@name, dvClass = dvClass, dvOptions = dvOptions)

  # Output JSON with DV info to file
  # jsonData <- jsonlite::toJSON(dvInfo, pretty=TRUE)
  write_json(dvInfo, path=path)

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

  # for (v in conceptualModel@variables) {
  #   if (v@name == dvName) {
  #     cat(v@name)
  #   }
  #

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
  disambiguateConceptualModel(conceptualModel=conceptualModel, dv=dv, inputFilePath=path, dataPath=dataPath)
  print(dv)


  # Show variables

  # DV as Continuous/Counts/Categories?

  # Do we have any ambiguous relationships?
  # Which direction are "relates"?
  # For WhenThen, does that mean A --> B or B --> A or ....?


})
