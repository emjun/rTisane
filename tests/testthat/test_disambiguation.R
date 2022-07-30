library(tisaner)

library(jsonlite)

test_that("DV disambiguation options created properly", {
  cm <- ConceptualModel()

  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")

  # Assume causal relationship
  cause_relat <- causes(measure_0, measure_1)
  cm <- assume(cause_relat, cm)

  path <- generateJSON(conceptualModel=cm, dv=measure_1, "test_input.json")

  options <- read_json(path)

  expect_equal("Numeric", options$dvClass[[1]])
  expect_equal(measure_1@name, options$dvName[[1]])
  expect_true("Continuous" %in% options$dvOptions)
  expect_true("Counts" %in% options$dvOptions)
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

  path <- generateJSON(conceptualModel=cm, dv=measure_1, "test_input.json")

  options <- read_json(path)

  expect_equal("Numeric", options$dvClass[[1]])
  expect_equal(measure_1@name, options$dvName[[1]])
  expect_true("Continuous" %in% options$dvOptions)
  expect_true("Counts" %in% options$dvOptions)
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

  path <- generateJSON(conceptualModel=cm, dv=measure_1, "test_input.json")

  options <- read_json(path)

  expect_equal("Numeric", options$dvClass[[1]])
  expect_equal(measure_1@name, options$dvName[[1]])
  expect_true("Continuous" %in% options$dvOptions)
  expect_true("Counts" %in% options$dvOptions)
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

test_that("DV updates properly", {
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")

  # Values to update to
  uRelat <- paste("Assume", measure_0@name, "causes", measure_1@name, sep=" ")
  dvName = measure_1@name
  dvType = "Continuous"

  # Create updates list to pass to updateDV function
  updates <- list(dvName=dvName, dvType=dvType)
  updates$uncertainRelationships[[1]] = uRelat
  dvUpdated <- updateDV(dv=measure_1, values=updates)

  expect_s4_class(dvUpdated, "Continuous")
  expect_equal(dvUpdated@measure, measure_1)
  expect_equal(dvUpdated@skew, "none")
})

test_that("Conceptual model updated after disambiguation properly", {
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
  browser()
  cmUpdated <- updateConceptualModel(conceptualModel=cm, values=updates)

  expect_s4_class(cmUpdated, "ConceptualModel")
  relationships <- cmUpdated@relationships
  expect_length(relationships, 1)
  hypo <- relationships[[1]]
  expect_s4_class(hypo, "Hypothesis")
  r <- hypo@relationship
  expect_s4_class(r, "Causes")
  browser()
  expect_equal(r@cause, relat@rhs)
  expect_equal(r@effect, relat@lhs)
})
