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
  expect_s4_class(eye_color, "Nominal")
  expect_true(inherits(eye_color, "Measure")) # inherits from Measure
  # Verify that number of instances is set to 1 (Integer)
  # expect_s4_class(eye_color@repetitions, "Exactly")

  # Verify that number of instances is set to number greater than 1?
  condition <- nominal(unit=unit, name="condition", cardinality=5, number_of_instances=integer(5))
  # Verify that Has relationship constructed
  expect_s4_class(condition, "Nominal")
  expect_true(inherits(condition, "Measure")) # inherits from Measure
  # Verify that number of instances is set to 5 (Integer)
  # expect_s4_class(condition@repetitions, "Exactly")
  # expect_type(condition@repetitions@value, "integer")
  # expect_equal(condition@repetitions@value, integer(5))

  # Should throw error since there is no cardinality specified
  expect_error(nominal(unit=unit, name="eye_color"), "*")
})

test_that("Ordinal measure created properly", {
  # Create unit
  unit <- Unit("person", cardinality=40)

  # Specified correctly
  grade <- ordinal(unit=unit, name="grade", order=list(1, 2, 3, 4, 5))
  # Verify that Has relationship constructed
  expect_s4_class(grade, "Ordinal")
  expect_true(inherits(grade, "Measure")) # inherits from Measure
  # Verify that number of instances is set to 1 (Integer)
  # expect_s4_class(grade@repetitions, "Exactly")

  # Verify that number of instances is set to number greater than 1?
  condition <- ordinal(unit=unit, name="condition", order=list(1, 2, 3, 4, 5), number_of_instances=integer(5))
  # Verify that Has relationship constructed
  expect_s4_class(condition, "Ordinal")
  expect_true(inherits(condition, "Measure")) # inherits from Measure
  # Verify that number of instances is set to 5 (Integer)
  # expect_s4_class(condition@repetitions, "Exactly")
  # expect_type(condition@repetitions@value, "integer")
  # expect_equal(condition@repetitions@value, integer(5))

  # Should throw error since there is no cardinality specified
   expect_error(ordinal(unit=unit, name="grade"), "*")
})

test_that("Numeric measure created properly", {
  # Create unit
  unit <- Unit("person", cardinality=40)

  # Specified correctly
  age <- numeric(unit=unit, name="age")
  # Verify that Has relationship constructed
  expect_s4_class(age, "Numeric")
  expect_true(inherits(age, "Measure")) # inherits from Measure
  # Verify that number of instances is set to 1 (Integer)
  # expect_s4_class(age@repetitions, "Exactly")

  # Verify that number of instances is set to number greater than 1?
  condition <- numeric(unit=unit, name="condition", number_of_instances=integer(5))
  # Verify that Has relationship constructed
  expect_s4_class(condition, "Numeric")
  expect_true(inherits(condition, "Measure")) # inherits from Measure
  # Verify that number of instances is set to 5 (Integer)
  # expect_s4_class(condition@repetitions, "Exactly")
  # expect_type(condition@repetitions@value, "integer")
  # expect_equal(condition@repetitions@value, integer(5))
})
