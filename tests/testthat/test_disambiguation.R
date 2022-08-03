library(rTisane)

library(jsonlite)

continuousType <- "Treat as a continuous measure"
countType <- "Treat as counts"
categoriesType <- "Treat as categories"

test_that("DV disambiguation options created properly", {
  cm <- ConceptualModel()

  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")

  # Assume causal relationship
  cause_relat <- causes(measure_0, measure_1)
  cm <- assume(cause_relat, cm)

  path <- generateDVConceptualModelJSON(conceptualModel=cm, dv=measure_1, "test_input.json")

  options <- jsonlite::read_json(path)

  expect_equal("Numeric", options$dvClass[[1]])
  expect_equal(measure_1@name, options$dvName[[1]])
  expect_true(continuousType %in% options$dvOptions)
  expect_true(countType %in% options$dvOptions)
  expect_null(options$ambiguousRelationships) # Does not exist!
  expect_null(options$ambiguousOptions) # Does not exist!
})

test_that("Conceptual model disambiguation options created properly", {
  cm <- ConceptualModel()

  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")

  # Assume causal relationship
  cause_relat <- relates(measure_0, measure_1)
  cm <- assume(cause_relat, cm)

  path <- generateDVConceptualModelJSON(conceptualModel=cm, dv=measure_1, "test_input.json")

  options <- jsonlite::read_json(path)

  expect_equal("Numeric", options$dvClass[[1]])
  expect_equal(measure_1@name, options$dvName[[1]])
  expect_true(continuousType %in% options$dvOptions)
  expect_true(countType %in% options$dvOptions)
  expect_length(options$ambiguousRelationships, 1)
  expectedKey = paste("Assume", measure_0@name, "is related to", measure_1@name, sep=" ")
  expect_true(expectedKey %in% options$ambiguousRelationships)
  expect_length(options$ambiguousOptions1, 1)
  expectedValue = paste("Assume", measure_0@name, "causes", measure_1@name, sep=" ")
  expect_true(expectedValue %in% options$ambiguousOptions1)
  expect_length(options$ambiguousOptions2, 1)
  expectedValue = paste("Assume", measure_1@name, "causes", measure_0@name, sep=" ")
  expect_true(expectedValue %in% options$ambiguousOptions2)

  cm <- ConceptualModel()
  # Hypothesize causal relationship
  cause_relat <- relates(measure_0, measure_1)
  cm <- hypothesize(cause_relat, cm)

  path <- generateDVConceptualModelJSON(conceptualModel=cm, dv=measure_1, "test_input.json")

  options <- jsonlite::read_json(path)

  expect_equal("Numeric", options$dvClass[[1]])
  expect_equal(measure_1@name, options$dvName[[1]])
  expect_true(continuousType %in% options$dvOptions)
  expect_true(countType %in% options$dvOptions)
  expect_length(options$ambiguousRelationships, 1)
  expectedKey = paste("Hypothesize", measure_0@name, "is related to", measure_1@name, sep=" ")
  expect_true(expectedKey %in% options$ambiguousRelationships)
  expect_length(options$ambiguousOptions1, 1)
  expectedValue = paste("Hypothesize", measure_0@name, "causes", measure_1@name, sep=" ")
  expect_true(expectedValue %in% options$ambiguousOptions1)
  expect_length(options$ambiguousOptions2, 1)
  expectedValue = paste("Hypothesize", measure_1@name, "causes", measure_0@name, sep=" ")
  expect_true(expectedValue %in% options$ambiguousOptions2)

})

test_that("DV updates after disambiguation properly", {
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")

  # Values to update to
  uRelat <- paste("Assume", measure_0@name, "causes", measure_1@name, sep=" ")
  dvName = measure_1@name
  dvType = continuousType

  # Create updates list to pass to updateDV function
  updates <- list(dvName=dvName, dvType=dvType)
  updates$uncertainRelationships[[1]] = uRelat
  dvUpdated <- updateDV(dv=measure_1, values=updates)

  expect_s4_class(dvUpdated, "Continuous")
  expect_equal(dvUpdated@measure, measure_1)
  expect_equal(dvUpdated@skew, "none")
})

test_that("Conceptual model updates after disambiguation properly", {
  cm <- ConceptualModel()
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")

  ## Assume
  relat <- relates(measure_0, measure_1)
  cm <- assume(relat, cm)
  # Update graph
  cm@graph <- updateGraph(cm)

  # Values to update to
  uRelat <- paste("Assume", measure_0@name, "causes", measure_1@name, sep=" ")
  dvName = measure_1@name
  dvType = "Continuous"

  # Create updates list to pass to updateDV function
  updates <- list(dvName=dvName, dvType=dvType)
  updates$uncertainRelationships[[1]] = uRelat
  cmUpdated <- updateConceptualModel(conceptualModel=cm, values=updates)

  expect_s4_class(cmUpdated, "ConceptualModel")
  relationships <- cmUpdated@relationships
  expect_length(relationships, 1)
  assump <- relationships[[1]]
  expect_s4_class(assump, "Assumption")
  r <- assump@relationship
  expect_s4_class(r, "Causes")
  expect_equal(r@cause, relat@lhs)
  expect_equal(r@effect, relat@rhs)


  ## Hypothesize
  cm <- ConceptualModel()
  relat <- relates(measure_0, measure_1)
  cm <- hypothesize(relat, cm)
  # Update graph
  cm@graph <- updateGraph(cm)

  # Values to update to
  uRelat <- paste("Hypothesize", measure_0@name, "causes", measure_1@name, sep=" ")
  dvName = measure_1@name
  dvType = "Continuous"

  # Create updates list to pass to updateDV function
  updates <- list(dvName=dvName, dvType=dvType)
  updates$uncertainRelationships[[1]] = uRelat
  cmUpdated <- updateConceptualModel(conceptualModel=cm, values=updates)

  expect_s4_class(cmUpdated, "ConceptualModel")
  relationships <- cmUpdated@relationships
  expect_length(relationships, 1)
  hypo <- relationships[[1]]
  expect_s4_class(hypo, "Hypothesis")
  r <- hypo@relationship
  expect_s4_class(r, "Causes")
  expect_equal(r@cause, relat@lhs)
  expect_equal(r@effect, relat@rhs)

  ## Hypothesize, reverse direction of causes
  cm <- ConceptualModel()
  relat <- relates(measure_0, measure_1)
  cm <- hypothesize(relat, cm)
  # Update graph
  cm@graph <- updateGraph(cm)

  # Values to update to
  uRelat <- paste("Hypothesize", measure_1@name, "causes", measure_0@name, sep=" ")
  dvName = measure_1@name
  dvType = "Continuous"

  # Create updates list to pass to updateDV function
  updates <- list(dvName=dvName, dvType=dvType)
  updates$uncertainRelationships[[1]] = uRelat
  cmUpdated <- updateConceptualModel(conceptualModel=cm, values=updates)

  expect_s4_class(cmUpdated, "ConceptualModel")
  relationships <- cmUpdated@relationships
  expect_length(relationships, 1)
  hypo <- relationships[[1]]
  expect_s4_class(hypo, "Hypothesis")
  r <- hypo@relationship
  expect_s4_class(r, "Causes")
  expect_equal(r@cause, relat@rhs)
  expect_equal(r@effect, relat@lhs)
})

test_that("Statistical modeling options created properly", {
  cm <- ConceptualModel()
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")
  measure_2 <- numeric(unit=unit, name="measure_2")

  # Model 1: measure_1 is a common parent
  cm <- assume(causes(measure_1, measure_0), cm)
  cm <- assume(causes(measure_0, measure_2), cm)
  cm <- assume(causes(measure_1, measure_2), cm)
  cm@graph <- updateGraph(cm)
  confounders <- inferConfounders(conceptualModel=cm, iv=measure_0, dv=measure_2)
  cont <- asContinuous(measure_2)
  familyLinkPairs <- inferFamilyLinkFunctions(cont)

  path <- generateStatisticalModelJSON(confounders=confounders, interactions=NULL, randomEffects=NULL, familyLinkFunctions=familyLinkPairs, path="test_input2.json", iv=measure_0, dv=measure_2)

  options <- jsonlite::read_json(path)
  expect_false(is.null(options$input))
  input <- options$input
  expect_type(input$generatedMainEffects, "list")
  expect_length(input$generatedMainEffects, 2) # IV and confounders
  expect_true(measure_0@name %in% input$generatedMainEffects) # IV
  expect_true(measure_1@name %in% input$generatedMainEffects) # confounder
  expect_type(input$generatedInteractionEffects, "list")
  expect_length(input$generatedInteractionEffects, 0)
  expect_type(input$generatedRandomEffects, "list")
  re <- getElement(input$generatedRandomEffects, " ")
  expect_length(re, 0)
  expect_false(is.null(input$generatedFamilyLinkFunctions)) # Key exists!
  expect_false(is.null(input$query)) # Key exists!
  query <- input$query
  expect_equal(query$DV, measure_2@name)
  expect_length(query$IVs, 1)
  expect_equal(query$IVs[[1]], measure_0@name)
})

# TODO: Add tests for shiny app testing
# https://shiny.rstudio.com/articles/testing-overview.html
