#context("Variable declaration and construction")
library(rTisane)

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

test_that("Nested Unit created properly", {
  class <- Unit("class")
  student <- Unit("student", nestsWithin=class)

  # One nest
  expect_s4_class(student, "Unit")
  expect_equal(student@nestsWithin, class)
  expect_s4_class(class, "Unit")

  # Two nests
  expect_error(Unit("student", nestsWithin=list(class, family))) # family is not defined, therefore is NULL
  family <- Unit("family")
  student <- Unit("student", nestsWithin=list(class, family))
  expect_s4_class(student, "Unit")
  expect_type(student@nestsWithin, "list")
  expect_true(c(class) %in% student@nestsWithin)
  expect_true(c(family) %in% student@nestsWithin)
  expect_s4_class(class, "Unit")
  expect_s4_class(family, "Unit")
})

test_that("Participant created properly", {
  participant <- Participant("pid")
  expect_true(inherits(participant, "AbstractVariable")) # inherits from AbstractVariable (supersuperclass)
  expect_true(inherits(participant, "Unit")) # inherits from AbstractVariable (superclass)
  expect_s4_class(participant, "Participant")
  expect_match(participant@name, "pid")
  expect_equal(participant@cardinality, as.integer(0)) # cardinality not calculated yet

  participant <- Participant("pid", cardinality=40)
  expect_match(participant@name, "pid")
  expect_equal(participant@cardinality, as.integer(40))
})

test_that("Time created properly", {
  week <- Time("week", order=list(1,2,3,4))
  expect_true(inherits(week, "AbstractVariable")) # inherits from AbstractVariable
  expect_s4_class(week, "Time")
  expect_equal(week@order, list(1,2,3,4))
  expect_equal(length(week@order), 4)
  expect_type(week@cardinality, "integer")
  expect_equal(week@cardinality, as.integer(4)) # cardinality equals length of order

  week <- Time("week", order=list(1,2,3,4), cardinality=4)
  expect_true(inherits(week, "AbstractVariable")) # inherits from AbstractVariable
  expect_s4_class(week, "Time")
  expect_equal(week@order, list(1,2,3,4))
  expect_equal(length(week@order), 4)
  expect_type(week@cardinality, "integer")
  expect_equal(week@cardinality, as.integer(4)) # cardinality equals length of order

  # Throws an error
  expect_error(Time("week", order=list(1,2,3,4), cardinality=10), "*")
})

test_that("Unordered Categories measure created properly", {
  # Create unit
  unit <- Unit("person", cardinality=40)

  # Specified correctly
  eye_color <- categories(unit=unit, name="eye_color", cardinality=10)
  expect_s4_class(eye_color, "Categories")
  expect_s4_class(eye_color, "UnorderedCategories")
  expect_true(inherits(eye_color, "Measure")) # inherits from Measure
  expect_equal(eye_color@numberOfInstances, 1)
  expect_equal(eye_color@cardinality, 10)

  # Verify that number of instances is set to number greater than 1?
  condition <- categories(unit=unit, name="condition", cardinality=5, numberOfInstances=as.integer(5))
  expect_s4_class(condition, "Categories")
  expect_s4_class(condition, "UnorderedCategories")
  expect_true(inherits(condition, "Measure")) # inherits from Measure
  expect_equal(condition@numberOfInstances, 5)
  expect_equal(condition@cardinality, 5)

  # Should throw error since there is no cardinality or order specified
  expect_error(categories(unit=unit, name="eye_color"), "*")
})

test_that("Ordered Categories measure created properly", {
  # Create unit
  unit <- Unit("person", cardinality=40)

  # Specified correctly
  grade <- categories(unit=unit, name="grade", order=list(1, 2, 3, 4, 5))
  # Verify that Has relationship constructed
  expect_s4_class(grade, "Categories")
  expect_s4_class(grade, "OrderedCategories")
  expect_true(inherits(grade, "Measure")) # inherits from Measure
  expect_equal(grade@cardinality, 5)
  expect_equal(grade@numberOfInstances, 1)

  # Should throw error since there is no cardinality specified
   expect_error(categories(unit=unit, name="grade"), "*")

   # Create Participant
   participant <- Participant("pid", cardinality=40)

   # Specified correctly
   grade <- categories(unit=participant, name="grade", order=list(1, 2, 3, 4, 5))
   # Verify that Has relationship constructed
   expect_s4_class(grade, "OrderedCategories")
   expect_true(inherits(grade, "Measure")) # inherits from Measure
   # Verify that number of instances is set to 1 (Integer)
   # expect_s4_class(grade@repetitions, "Exactly")

   # Verify that number of instances is set to number greater than 1?
   condition <- categories(unit=participant, name="condition", order=list(1, 2, 3, 4, 5), numberOfInstances=integer(5))
   # Verify that Has relationship constructed
   expect_s4_class(condition, "OrderedCategories")
   expect_true(inherits(condition, "Measure")) # inherits from Measure
})

test_that("Continuous measure created properly", {
  # Create unit
  unit <- Unit("person", cardinality=40)

  # Specified correctly
  age <- continuous(unit=unit, name="age")
  # Verify that Has relationship constructed
  expect_s4_class(age, "Continuous")
  expect_true(inherits(age, "Measure")) # inherits from Measure

  # Create Participant
  participant <- Participant("pid", cardinality=40)

  # Specified correctly
  age <- continuous(unit=participant, name="age")
  # Verify that Has relationship constructed
  expect_s4_class(age, "Continuous")
  expect_true(inherits(age, "Measure")) # inherits from Measure

  # Verify that number of instances is set to number greater than 1?
  age <- continuous(unit=participant, name="age", numberOfInstances=integer(5))
  # Verify that Has relationship constructed
  expect_s4_class(age, "Continuous")
  expect_true(inherits(age, "Measure")) # inherits from Measure
})

test_that("Condition constructed properly", {
  # Create Participant
  participant <- Participant("pid", cardinality=40)

  # Assign condition with cardinality, no order
  condition <- condition(unit=participant, name="treatment", cardinality=integer(2), numberOfInstances=integer(1))
  expect_s4_class(condition, "UnorderedCategories")
  expect_true(inherits(condition, "Measure"))

  # Assign condition with order, no cardinality
  condition <- condition(unit=participant, name="treatment", order=list("low","medium", "high"), numberOfInstances=integer(1))
  expect_s4_class(condition, "OrderedCategories")
  expect_true(inherits(condition, "Measure"))

  # Throws an error
  # Provide neither cardinality no order
  expect_error(condition(unit=participant, name="treatment", numberOfInstances=integer(1)))
  # Provide both cardinality and order
  expect_error(condition(unit=participant, name="treatment", cardinality=integer(3), order=list("low","medium", "high"), numberOfInstances=integer(1)))
})


test_that("Unobserved variable properly", {
  midlife_crisis <- Unobserved()

  expect_s4_class(midlife_crisis, "UnobservedVariable")
  expect_equal(midlife_crisis@name, "Unobserved")
})

test_that("Interacts created properly", {
  unit <- Unit("person")
  measure_0 <- continuous(unit=unit, name="measure_0")
  measure_1 <- continuous(unit=unit, name="measure_1")
  measure_2 <- continuous(unit=unit, name="measure_2")
  measure_3 <- continuous(unit=unit, name="measure_3")

  cm <- ConceptualModel()

  # 2-way interaction
  updatedCM <- interacts(cm, measure_0, measure_1, dv=measure_2)
  expect_s4_class(updatedCM, "ConceptualModel")
  ixn <- updatedCM@relationships[[1]]
  expect_equal(ixn@name, "measure_0*measure_1")
  expect_length(ixn@variables, 2)
  expect_true(c(measure_0) %in% ixn@variables)
  expect_true(c(measure_1) %in% ixn@variables)
  expect_equal(measure_2, ixn@dv)
  expect_equal(unit, ixn@units[[1]])
  expect_equal(1, length(ixn@units))

  # 3-way interaction
  updatedCM <- interacts(updatedCM, measure_0, measure_1, measure_2, dv=measure_3)
  expect_s4_class(updatedCM, "ConceptualModel")
  ixn <- updatedCM@relationships[[2]]
  expect_equal(ixn@name, "measure_0*measure_1*measure_2")
  expect_length(ixn@variables, 3)
  expect_true(c(measure_0) %in% ixn@variables)
  expect_true(c(measure_1) %in% ixn@variables)
  expect_true(c(measure_2) %in% ixn@variables)
  expect_equal(measure_3, ixn@dv)
  expect_equal(unit, ixn@units[[1]])
  expect_equal(1, length(ixn@units))

  # TODO: Add more tests for to make sure that measure, unit has relationship is inferred
  # especially when multiple units involved

})


# test_that("Per object created properly", {
#   pid <- Participant("ID")
#   year <- Time(name="year", cardinality=5) # 5 years
#   # income <- numeric(unit=pid, name="PINCP", numberOfInstances=per(1, year)) # One for each year
#   perObj <- per(1, year)

#   expect_s4_class(perObj, "Per")
#   expect_s4_class(perObj@number, "NumberValue")
#   expect_s4_class(perObj@number, "Exactly")
#   expect_equal(perObj@variable, year)
#   expect_true(perObj@cardinality)
#   expect_false(checkEquals(perObj, as.integer(1)))
#   expect_true(checkEquals(perObj, as.integer(5)))
#   expect_true(checkGreaterThan(perObj, as.integer(1)))

#   perObj <- per(AtMost(1), year)

#   expect_s4_class(perObj, "Per")
#   expect_s4_class(perObj@number, "NumberValue")
#   expect_s4_class(perObj@number, "AtMost")
#   expect_equal(perObj@variable, year)
#   expect_true(perObj@cardinality)
#   expect_false(checkEquals(perObj, as.integer(1)))
#   expect_true(checkEquals(perObj, as.integer(5)))
#   expect_true(checkGreaterThan(perObj, as.integer(1)))
# })
