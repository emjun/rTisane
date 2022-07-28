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
  expectedKey = paste(measure_0@name, "is related to", measure_1@name, sep=" ")
  expect_true(expectedKey %in% options$ambiguousRelationships)
  expect_length(options$ambiguousOptions1, 1)
  expectedValue = paste(measure_0@name, "causes", measure_1@name, sep=" ")
  expect_true(expectedValue %in% options$ambiguousOptions1)
  expect_length(options$ambiguousOptions2, 1)
  expectedValue = paste(measure_1@name, "causes", measure_0@name, sep=" ")
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
  expectedKey = paste(measure_0@name, "is related to", measure_1@name, sep=" ")
  expect_true(expectedKey %in% options$ambiguousRelationships)
  expect_length(options$ambiguousOptions1, 1)
  expectedValue = paste(measure_0@name, "causes", measure_1@name, sep=" ")
  expect_true(expectedValue %in% options$ambiguousOptions1)
  expect_length(options$ambiguousOptions2, 1)
  expectedValue = paste(measure_1@name, "causes", measure_0@name, sep=" ")
  expect_true(expectedValue %in% options$ambiguousOptions2)

})
