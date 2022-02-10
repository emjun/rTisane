context("Variable Relationship")
library(tisaner)

test_that("Causes created properly", {
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")

  causes(measure_0, measure_1)

  # Verify that Causes relationship in measure_0 relationships and measure_1 relationships


  # Verify that Causes relationship created correctly
})

test_that("Associates created properly", {
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")

  associates_with(measure_0, measure_1)

  # Verify that Associates in relationships for measure_0 and measure_1

  # Verify that Associates is created correctly

  # Verify that Associates relationship are identical/the same object
})

test_that("Nests created properly", {
  unit_0 <- Unit("person")
  unit_1 <- Unit("group")

  nests_within(measure_0, measure_1) # add to docs that can read like: first param.nests_within(second param)?

  # Verify that....

})