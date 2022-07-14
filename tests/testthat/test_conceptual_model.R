library(tisaner)

test_that("Assumes updates Conceptual Model properly", {
  cm <- ConceptualModel()

  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")

  # Assume causal relationship
  cause_relat <- causes(measure_0, measure_1)
  cm <- assume(cause_relat, cm)

  expect_s4_class(cm, "ConceptualModel")
  expect_type(cm@variables, "list")
  expect_length(cm@variables, 2)
  expect_true(c(measure_0) %in% cm@variables)
  expect_true(c(measure_1) %in% cm@variables)

  expect_type(cm@relationships, "list")
  expect_length(cm@relationships, 1)
  relat = cm@relationships[[1]]
  expect_s4_class(relat, "Assumption")
  expect_equal(relat@relationship, cause_relat)

  # Assume ambiguous relationship
  ambig_relat <- relates(measure_0, measure_1)
  expect_output(assume(ambig_relat, cm))
  cm <- assume(ambig_relat, cm)

  expect_s4_class(cm, "ConceptualModel")
  expect_type(cm@variables, "list")
  expect_length(cm@variables, 2)
  expect_true(c(measure_0) %in% cm@variables)
  expect_true(c(measure_1) %in% cm@variables)

  expect_type(cm@relationships, "list")
  expect_length(cm@relationships, 1)
  relat = cm@relationships[[1]]
  expect_s4_class(relat, "Assumption")
  expect_equal(relat@relationship, cause_relat)
  # relat = cm@relationships[[2]]
  # expect_s4_class(relat, "Assumption")
  # expect_equal(relat@relationship, ambig_relat)

})

test_that("Hypothesize updates Conceptual Model properly", {
  cm <- ConceptualModel()

  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")

  # Hypothesize causal relationship
  cause_relat <- causes(measure_0, measure_1)
  cm <- hypothesize(cause_relat, cm)

  expect_s4_class(cm, "ConceptualModel")
  expect_type(cm@variables, "list")
  expect_length(cm@variables, 2)
  expect_true(c(measure_0) %in% cm@variables)
  expect_true(c(measure_1) %in% cm@variables)

  expect_type(cm@relationships, "list")
  expect_length(cm@relationships, 1)
  relat = cm@relationships[[1]]
  expect_s4_class(relat, "Hypothesis")
  expect_equal(relat@relationship, cause_relat)

  # Assume ambiguous relationship
  ambig_relat <- relates(measure_0, measure_1)
  expect_output(hypothesize(ambig_relat, cm))
  cm <- hypothesize(ambig_relat, cm)

  expect_s4_class(cm, "ConceptualModel")
  expect_type(cm@variables, "list")
  expect_length(cm@variables, 2)
  expect_true(c(measure_0) %in% cm@variables)
  expect_true(c(measure_1) %in% cm@variables)

  expect_type(cm@relationships, "list")
  expect_length(cm@relationships, 1)
  relat = cm@relationships[[1]]
  expect_s4_class(relat, "Hypothesis")
  expect_equal(relat@relationship, cause_relat)
  # relat = cm@relationships[[2]]
  # expect_s4_class(relat, "Hypothesis")
  # expect_equal(relat@relationship, ambig_relat)

})

test_that("Unobserved variables treated properly in Conceptual Models", {
  cm <- ConceptualModel()

  unit <- Unit("person", cardinality=40)
  age <- numeric(unit=unit, name="age")
  motivation <- numeric(unit=unit, name="motivation")
  pounds_lost <- numeric(unit=unit, name="pounds_lost")
  midlife_crisis <- Unobserved()

  expect_error(hypothesize(causes(age, midlife_crisis), cm))

  cr1 <- causes(age, midlife_crisis)
  cm <- assume(cr1, cm)
  cr2 <- causes(midlife_crisis, pounds_lost)
  cm <- assume(cr2, cm)
  cr3 <- causes(midlife_crisis, motivation)
  cm <- assume(cr3, cm)

  expect_s4_class(cm, "ConceptualModel")
  expect_type(cm@variables, "list")
  expect_length(cm@variables, 4)
  expect_true(c(age) %in% cm@variables)
  expect_true(c(midlife_crisis) %in% cm@variables)
  expect_true(c(pounds_lost) %in% cm@variables)
  expect_true(c(motivation) %in% cm@variables)

  expect_type(cm@relationships, "list")
  expect_length(cm@relationships, 3)
  relat = cm@relationships[[1]]
  expect_s4_class(relat, "Assumption")
  expect_equal(relat@relationship, cr1)
  relat = cm@relationships[[2]]
  expect_s4_class(relat, "Assumption")
  expect_equal(relat@relationship, cr2)
  relat = cm@relationships[[3]]
  expect_s4_class(relat, "Assumption")
  expect_equal(relat@relationship, cr3)
})
