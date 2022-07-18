library(tisaner)

test_that("Assume updates Conceptual Model properly", {
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

test_that("Hypothesize WhenThen updated Conceptual Model properly", {
  cm <- ConceptualModel()

  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")
  measure_2 <- numeric(unit=unit, name="measure_2")

  wt <- whenThen(when=list(increases(measure_0), increases(measure_1)), then=increases(measure_2))
  cm <- hypothesize(wt, cm)

  expect_s4_class(cm, "ConceptualModel")
  expect_type(cm@variables, "list")
  expect_length(cm@variables, 3)
  expect_true(c(measure_0) %in% cm@variables)
  expect_true(c(measure_1) %in% cm@variables)
  expect_true(c(measure_2) %in% cm@variables)

  expect_type(cm@relationships, "list")
  expect_length(cm@relationships, 1)
  relat = cm@relationships[[1]]
  expect_s4_class(relat, "Hypothesis")
  expect_equal(relat@relationship, wt)

  # Ordinal variable
  measure_3 <- ordinal(unit=unit, name="measure_3", order=list(1, 2, 3, 4, 5))
  wt <- whenThen(when=list(equals(measure_3, integer(3)), increases(measure_1)), then=increases(measure_2))
  cm <- hypothesize(wt, cm)

  expect_s4_class(cm, "ConceptualModel")
  expect_type(cm@variables, "list")
  expect_length(cm@variables, 4)
  expect_true(c(measure_0) %in% cm@variables)
  expect_true(c(measure_1) %in% cm@variables)
  expect_true(c(measure_2) %in% cm@variables)
  expect_true(c(measure_3) %in% cm@variables)

  expect_type(cm@relationships, "list")
  expect_length(cm@relationships, 2)
  relat = cm@relationships[[2]]
  expect_s4_class(relat, "Hypothesis")
  expect_equal(relat@relationship, wt)

})

test_that("Assume WhenThen updated Conceptual Model properly", {
  cm <- ConceptualModel()

  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")
  measure_2 <- numeric(unit=unit, name="measure_2")

  wt <- whenThen(when=list(increases(measure_0), increases(measure_1)), then=increases(measure_2))
  cm <- assume(wt, cm)

  expect_s4_class(cm, "ConceptualModel")
  expect_type(cm@variables, "list")
  expect_length(cm@variables, 3)
  expect_true(c(measure_0) %in% cm@variables)
  expect_true(c(measure_1) %in% cm@variables)
  expect_true(c(measure_2) %in% cm@variables)

  expect_type(cm@relationships, "list")
  expect_length(cm@relationships, 1)
  relat = cm@relationships[[1]]
  expect_s4_class(relat, "Assumption")
  expect_equal(relat@relationship, wt)

  # Nominal variable
  measure_3 <- nominal(unit=unit, name="measure_3", cardinality=5)
  wt <- whenThen(when=list(equals(measure_3, integer(3)), increases(measure_1)), then=increases(measure_2))
  cm <- assume(wt, cm)

  expect_s4_class(cm, "ConceptualModel")
  expect_type(cm@variables, "list")
  expect_length(cm@variables, 4)
  expect_true(c(measure_0) %in% cm@variables)
  expect_true(c(measure_1) %in% cm@variables)
  expect_true(c(measure_2) %in% cm@variables)
  expect_true(c(measure_3) %in% cm@variables)

  expect_type(cm@relationships, "list")
  expect_length(cm@relationships, 2)
  relat = cm@relationships[[2]]
  expect_s4_class(relat, "Assumption")
  expect_equal(relat@relationship, wt)
})

test_that("Causal graph consstructed/updated properly", {
  cm <- ConceptualModel()
  # Test empty graph
  gr <- updateGraph(cm)
  expect_true(is.dagitty(gr))
  expect_equal(nrow(edges(gr)), 0)

  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")
  measure_2 <- numeric(unit=unit, name="measure_2")

  # Assume 1 relationship
  cm <- assume(causes(measure_0, measure_1), cm)
  gr <- updateGraph(cm)
  expect_true(is.dagitty(gr))
  expect_equal(nrow(edges(gr)), 1)
  expect_equal(edges(gr)[[1]][1], measure_0@name)
  expect_equal(edges(gr)[[2]][1], measure_1@name)
  expect_equal(edges(gr)[[3]][1], "->")

  # Add an assume relationship
  cm <- assume(causes(measure_1, measure_2), cm)
  gr <- updateGraph(cm)
  expect_true(is.dagitty(gr))
  expect_equal(nrow(edges(gr)), 2)
  expect_equal(edges(gr)[[1]][1], measure_0@name)
  expect_equal(edges(gr)[[2]][1], measure_1@name)
  expect_equal(edges(gr)[[3]][1], "->")
  expect_equal(edges(gr)[[1]][2], measure_1@name)
  expect_equal(edges(gr)[[2]][2], measure_2@name)
  expect_equal(edges(gr)[[3]][2], "->")

  # Add a hypothesized relationship
  # Should not matter if relationship is assumed vs. hypothesized
  cm <- hypothesize(causes(measure_0, measure_2), cm)
  gr <- updateGraph(cm)
  expect_true(is.dagitty(gr))
  expect_equal(nrow(edges(gr)), 3)
  expect_equal(edges(gr)[[1]][1], measure_0@name)
  expect_equal(edges(gr)[[2]][1], measure_1@name)
  expect_equal(edges(gr)[[3]][1], "->")
  expect_equal(edges(gr)[[1]][2], measure_0@name) # alpha-numeric ordering
  expect_equal(edges(gr)[[2]][2], measure_2@name)
  expect_equal(edges(gr)[[3]][2], "->")
  expect_equal(edges(gr)[[1]][3], measure_1@name)
  expect_equal(edges(gr)[[2]][3], measure_2@name)
  expect_equal(edges(gr)[[3]][3], "->")
})

test_that("Validate Conceptual Model's causal graph properly", {
  cm <- ConceptualModel()
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")
  measure_2 <- numeric(unit=unit, name="measure_2")
  measure_3 <- numeric(unit=unit, name="measure_3")
  measure_4 <- numeric(unit=unit, name="measure_4")

  cm <- assume(causes(measure_0, measure_1), cm)
  cm <- assume(causes(measure_1, measure_2), cm)
  cm <- hypothesize(causes(measure_0, measure_2), cm)

  cm@graph <- updateGraph(cm)
  isValid <- checkConceptualModel(cm, measure_0, measure_2)
  expect_true(isValid)

  # DV is not in the Conceptual Model/graph
  cm <- ConceptualModel()
  cm <- assume(causes(measure_0, measure_1), cm)
  cm@graph <- updateGraph(cm)
  expect_error(checkConceptualModel(cm, measure_0, measure_2))
  # IV is not in the Conceptual Model/graph
  expect_error(checkConceptualModel(cm, measure_2, measure_0))

  # No path between IV and DV!
  cm <- ConceptualModel()
  cm <- assume(causes(measure_0, measure_2), cm)
  cm <- assume(causes(measure_1, measure_2), cm)
  cm <- assume(causes(measure_3, measure_4), cm)
  cm@graph <- updateGraph(cm)
  expect_error(checkConceptualModel(cm, measure_0, measure_4))

  # DV causes IV!
  cm <- ConceptualModel()
  cm <- assume(causes(measure_0, measure_2), cm)
  cm@graph <- updateGraph(cm)
  expect_error(checkConceptualModel(cm, measure_2, measure_0))

  # Cycles!
  cm <- ConceptualModel()
  cm <- assume(causes(measure_0, measure_2), cm)
  cm <- assume(causes(measure_2, measure_0), cm)
  cm@graph <- updateGraph(cm)
  expect_error(checkConceptualModel(cm, measure_0, measure_2))
  expect_error(checkConceptualModel(cm, measure_2, measure_0))
})
