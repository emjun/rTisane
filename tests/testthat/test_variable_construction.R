#context("Variable declaration and construction")
library(tisaner)

test_that("AbstractVariable created properly", {
  #var <- new("AbstractVariable", name="name")
  var <- AbstractVariable("name")

  expect_s4_class(var, "AbstractVariable")
  expect_match(var@name, "name")
})


test_that("Unit created properly", {
  unit <- Unit("person")
  expect_true(inherits(unit, "AbstractVariable")) # inherits from AbstractVariable
  expect_s4_class(unit, "Unit")
  expect_match(unit@name, "person")
  expect_equal(unit@cardinality, as.integer(0)) # cardinality not calculated yet

  unit <- Unit("person", cardinality=40)
  expect_match(unit@name, "person")
  expect_equal(unit@cardinality, as.integer(40))
  })

test_that("SetUp created properly", {
  week <- SetUp("week", order=list(1,2,3,4))
  expect_true(inherits(week, "AbstractVariable")) # inherits from AbstractVariable
  expect_s4_class(week, "SetUp")
  expect_equal(week@order, list(1,2,3,4))
  expect_equal(length(week@order), 4)
  expect_type(week@cardinality, "integer")
  expect_equal(week@cardinality, as.integer(4)) # cardinality equals length of order

  week <- SetUp("week", order=list(1,2,3,4), cardinality=4)
  expect_true(inherits(week, "AbstractVariable")) # inherits from AbstractVariable
  expect_s4_class(week, "SetUp")
  expect_equal(week@order, list(1,2,3,4))
  expect_equal(length(week@order), 4)
  expect_type(week@cardinality, "integer")
  expect_equal(week@cardinality, as.integer(4)) # cardinality equals length of order

  # Throws an error
  expect_error(SetUp("week", order=list(1,2,3,4), cardinality=10), "*")
})

test_that("Nominal measure created properly", {
  # Create unit
  unit <- Unit("person", cardinality=40)

  # Specified correctly
  eye_color <- nominal(unit=unit, name="eye_color", cardinality=10)
  # Verify that Has relationship constructed
  # Verify that number of instances is set to 1 (Integer)


  # Verify that number of instances is set to number greater than 1?

  # Should throw error since there is no cardinality specified
  expect_error(nominal(unit=unit, name="eye_color"), "*")
})
