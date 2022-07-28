library(tisaner)

library(jsonlite)

test_that("DV disambiguation options created properly", {
  cm <- ConceptualModel()

  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")

  # # Assume causal relationship
  # cause_relat <- causes(measure_0, measure_1)
  # cm <- assume(cause_relat, cm)

  path <- outputJSON(dv=measure_1, "test_input.json")

  options <- read_json(path)

  expect_equal("Numeric", options$dvClass)
  expect_equal(measure_1@name, options$dvName)
  expect_true("Continuous" %in% options$dvOptions)
  expect_true("Counts" %in% options$dvOptions)
})
