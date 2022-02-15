context("Variable declaration and construction")
library(tisaner)

test_that("AbstractVariable created properly", {
  #var <- new("AbstractVariable", name="name")
  var <- AbstractVariable("name")

  expect_s4_class(var, "AbstractVariable")
  expect_match(var@name, "name")
})


test_that("Unit created properly", {
<<<<<<< HEAD
  unit <- Unit("person")
  expect_is(unit, AbstractVariable) # inherits from AbstractVariable
  expect_is(unit, Unit)
  expect_match(unit@name, "person")
  expect_match(unit@cardinality, NULL) # cardinality not calculated yet

  unit <- Unit("person", cardinality=40)
  expect_match(unit@name, "person")
  expect_match(unit@cardinality, 40)
=======
    unit <- Unit("person")
>>>>>>> 78d0d5b3a379f33d980d95a1f1d474a02ff790ec

})

test_that("SetUp created properly", {
  week <- SetUp("week", order=list(1,2,3,4))

  week <- SetUp("week", order=list(1,2,3,4), cardinality=4)

  # Throws an error
  week <- SetUp("week", order=list(1,2,3,4), cardinality=10)

})

test_that("Nominal measure created properly", {
<<<<<<< HEAD
  # Create unit
  unit <- Unit("person")

  eye_color <- nominal(unit=unit, name="eye_color", cardinality=10)

  # Should throw error since there is no cardinality specified
  eye_color <- nominal(unit=unit, name="eye_color")

  # Verify that Has relationship constructed
  # Verify that number of instances is set to 1 (Integer)
=======
    # Create unit
    unit <- Unit("person")

    eye_color <- nominal(unit=unit, name="eye_color", cardinality=10)

    # Should throw error since there is no cardinality specified
    eye_color <- nominal(unit=unit, name="eye_color")

    # Verify that Has relationship constructed
    # Verify that number of instances is set to 1 (Integer)
>>>>>>> 78d0d5b3a379f33d980d95a1f1d474a02ff790ec
})

test_that("Ordinal measure created properly", {
  # Create unit
  unit <- Unit("person")

  school_grade <- ordinal(unit=unit, name="school_grade", orderlist(1,2,3,4,5))

<<<<<<< HEAD
  # Throws error since @param order is not provided
  school_grade <- ordinal(unit=unit, name="school_grade")
=======
    school_grade <- ordinal(unit=unit, name="school_grade", orderlist(1,2,3,4,5))

    # Throws error since @param order is not provided
    school_grade <- ordinal(unit=unit, name="school_grade")
>>>>>>> 78d0d5b3a379f33d980d95a1f1d474a02ff790ec

  # Throws error since @param order and @param cardinality disagree
  school_grade <- ordinal(unit=unit, name="school_grade", orderlist(1,2,3,4,5), cardinality=10)
})

test_that("Numeric measure created properly", {
  # Create unit
  unit <- Unit("person")

  age <- numeric(unit=unit, name="age")

  # Verify unit and measure relationships
  # Verify Has relationship is constructed correctly
})

# Write test for passing Has multiple different types to number_of_instances
test_that("Has relationship created properly", {
  # Create unit
  unit <- Unit("person")
  # Create setup
  week <- SetUp("week", orderlist(1,2,3,4))

  age <- numeric(unit=unit, name="age")
  # Verify that number of instaces == 1 (integer)

<<<<<<< HEAD
=======

    # Integer
    age <- numeric(unit=unit, name="age", number_of_instances=10)
>>>>>>> 78d0d5b3a379f33d980d95a1f1d474a02ff790ec

  # Integer
  age <- numeric(unit=unit, name="age", number_of_instances=10)

  # AbstractVariable
  age <- numeric(unit=unit, name="age", number_of_instances=week)

<<<<<<< HEAD
  # AtMost
  age <- numeric(unit=unit, name="age", number_of_instances=AtMost(2))

  # Per
  age <- numeric(unit=unit, name="age", number_of_instances=Exactly(1).per(week))

  # Per
  age <- numeric(unit=unit, name="age", number_of_instances=AtMost(1).per(week))
=======
    # Per
    age <- numeric(unit=unit, name="age", number_of_instances=Exactly(1).per(week))
    ExactlyPer(1, week)

    # Per
    age <- numeric(unit=unit, name="age", number_of_instances=AtMost(1).per(week))
    AtMostPer(1, week)
>>>>>>> 78d0d5b3a379f33d980d95a1f1d474a02ff790ec
})
