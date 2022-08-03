library(rTisane)

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
  cm <- assume(ambig_relat, cm)

  expect_s4_class(cm, "ConceptualModel")
  expect_type(cm@variables, "list")
  expect_length(cm@variables, 2)
  expect_true(c(measure_0) %in% cm@variables)
  expect_true(c(measure_1) %in% cm@variables)

  expect_type(cm@relationships, "list")
  expect_length(cm@relationships, 2)
  relat = cm@relationships[[1]]
  expect_s4_class(relat, "Assumption")
  expect_equal(relat@relationship, cause_relat)
  relat = cm@relationships[[2]]
  expect_s4_class(relat, "Assumption")
  expect_equal(relat@relationship, ambig_relat)

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
  cm <- hypothesize(ambig_relat, cm)

  expect_s4_class(cm, "ConceptualModel")
  expect_type(cm@variables, "list")
  expect_length(cm@variables, 2)
  expect_true(c(measure_0) %in% cm@variables)
  expect_true(c(measure_1) %in% cm@variables)

  expect_type(cm@relationships, "list")
  expect_length(cm@relationships, 2)
  relat = cm@relationships[[1]]
  expect_s4_class(relat, "Hypothesis")
  expect_equal(relat@relationship, cause_relat)
  relat = cm@relationships[[2]]
  expect_s4_class(relat, "Hypothesis")
  expect_equal(relat@relationship, ambig_relat)

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

  # Unobserved variable
  cm <- ConceptualModel()
  unit <- Unit("person")
  x <- numeric(unit=unit, name="x")
  y <- numeric(unit=unit, name="y")
  z <- numeric(unit=unit, name="z")
  m <- numeric(unit=unit, name="m")
  w <- numeric(unit=unit, name="w")
  u <- Unobserved()

  cm <- assume(causes(x, y), cm)
  cm <- assume(causes(u, y), cm)
  cm <- assume(causes(u, z), cm)
  cm <- assume(causes(z, x), cm)
  gr <- updateGraph(cm)
  expect_true(is.dagitty(gr))
  expect_equal(nrow(edges(gr)), 4)
  expect_length(names(gr), 4)
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
  expect_type(isValid, "list")
  expect_named(isValid, c("isValid"))
  expect_true(isValid$isValid)
  expect_null(isValid$reason)

  # DV is not in the Conceptual Model/graph
  cm <- ConceptualModel()
  cm <- assume(causes(measure_0, measure_1), cm)
  cm@graph <- updateGraph(cm)
  res <- checkConceptualModel(cm, measure_0, measure_2)
  expect_false(res$isValid)
  # IV is not in the Conceptual Model/graph
  res <- checkConceptualModel(cm, measure_2, measure_0)
  expect_false(res$isValid)

  # No path between IV and DV!
  cm <- ConceptualModel()
  cm <- assume(causes(measure_0, measure_2), cm)
  cm <- assume(causes(measure_1, measure_2), cm)
  cm <- assume(causes(measure_3, measure_4), cm)
  cm@graph <- updateGraph(cm)
  res <- checkConceptualModel(cm, measure_0, measure_4)
  expect_named(res, c("isValid", "reason"))

  # DV causes IV!
  cm <- ConceptualModel()
  cm <- assume(causes(measure_0, measure_2), cm)
  cm@graph <- updateGraph(cm)
  res <- checkConceptualModel(cm, measure_2, measure_0)
  expect_named(res, c("isValid", "reason"))
  expect_false(res$isValid)

  # Cycles!
  cm <- ConceptualModel()
  cm <- assume(causes(measure_0, measure_2), cm)
  cm <- assume(causes(measure_2, measure_0), cm)
  cm@graph <- updateGraph(cm)
  res <- checkConceptualModel(cm, measure_0, measure_2)
  expect_named(res, c("isValid", "reason"))
  expect_false(res$isValid)
  res <- checkConceptualModel(cm, measure_2, measure_0)
  expect_named(res, c("isValid", "reason"))
  expect_false(res$isValid)
})

test_that("Mediators found correctly", {
  unit <- Unit("person")
  x <- numeric(unit=unit, name="x")
  y <- numeric(unit=unit, name="y")
  z <- numeric(unit=unit, name="z")
  m <- numeric(unit=unit, name="m")
  w <- numeric(unit=unit, name="w")
  u <- Unobserved()

  cm <- ConceptualModel()
  cm <- assume(causes(x, m), cm)
  cm <- assume(causes(m, y), cm)
  cm@graph <- updateGraph(cm)

  mediators <- getMediators(cm, x@name, y@name)
  expect_length(mediators, 1)
  expect_true(m@name %in% mediators)

  cm <- ConceptualModel()
  cm <- assume(causes(x, m), cm)
  cm <- assume(causes(m, y), cm)
  cm <- assume(causes(z, x), cm)
  cm <- assume(causes(z, m), cm)
  cm@graph <- updateGraph(cm)

  mediators <- getMediators(cm, x@name, y@name)
  expect_length(mediators, 1)
  expect_true(m@name %in% mediators)
})

test_that("Observed variables found correctly", {
  unit <- Unit("person")
  x <- numeric(unit=unit, name="x")
  y <- numeric(unit=unit, name="y")
  z <- numeric(unit=unit, name="z")
  m <- numeric(unit=unit, name="m")
  w <- numeric(unit=unit, name="w")
  u <- Unobserved()

  cm <- ConceptualModel()
  cm <- assume(causes(x, m), cm)
  cm <- assume(causes(m, y), cm)
  cm <- assume(causes(u, x), cm)
  cm@graph <- updateGraph(cm)


  expect_true(isObserved(cm, x))
  expect_true(isObserved(cm, y))
  expect_true(isObserved(cm, m))
  expect_null(isObserved(cm, unit))
  expect_false(isObserved(cm, u))
})

test_that("Infer confounders correctly", {
  cm <- ConceptualModel()
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")
  measure_2 <- numeric(unit=unit, name="measure_2")
  measure_3 <- numeric(unit=unit, name="measure_3")
  measure_4 <- numeric(unit=unit, name="measure_4")

  # Model 1: measure_1 is a common parent
  cm <- assume(causes(measure_1, measure_0), cm)
  cm <- assume(causes(measure_0, measure_2), cm)
  cm <- assume(causes(measure_1, measure_2), cm)
  cm@graph <- updateGraph(cm)
  confounders <- inferConfounders(conceptualModel=cm, iv=measure_0, dv=measure_2)
  expect_length(confounders, 1)
  expect_true(measure_1@name %in% confounders)

  # Model 2: Mediator, Unobserved common parent
  cm <- ConceptualModel()
  unit <- Unit("person")
  x <- numeric(unit=unit, name="x")
  y <- numeric(unit=unit, name="y")
  z <- numeric(unit=unit, name="z")
  m <- numeric(unit=unit, name="m")
  w <- numeric(unit=unit, name="w")
  u <- Unobserved()

  cm <- assume(causes(x, y), cm)
  cm <- assume(causes(u, y), cm)
  cm <- assume(causes(u, z), cm)
  cm <- assume(causes(z, x), cm)

  cm@graph <- updateGraph(cm)
  confounders <- inferConfounders(conceptualModel=cm, iv=x, dv=y)
  expect_length(confounders, 1)
  expect_true(z@name %in% confounders)

  # Model 3: Mediator, Unobserved common parent
  cm <- ConceptualModel()
  cm <- assume(causes(x, y), cm)
  cm <- assume(causes(u, x), cm)
  cm <- assume(causes(u, z), cm)
  cm <- assume(causes(z, y), cm)

  cm@graph <- updateGraph(cm)
  confounders <- inferConfounders(conceptualModel=cm, iv=x, dv=y)
  expect_length(confounders, 1)
  expect_true(z@name %in% confounders)

  # Model 4: Common cause of X and any mediator between X and Y
  cm <- ConceptualModel()
  cm <- assume(causes(x, m), cm)
  cm <- assume(causes(m, y), cm)
  cm <- assume(causes(z, x), cm)
  cm <- assume(causes(z, m), cm)

  cm@graph <- updateGraph(cm)
  confounders <- inferConfounders(conceptualModel=cm, iv=x, dv=y)
  expect_length(confounders, 1)
  expect_true(z@name %in% confounders)

  # Model 5: Unobserved variable is common ancestor of IV and Mediator, but Z is mediating Unobserved --> Z --> M
  cm <- ConceptualModel()
  cm <- assume(causes(x, m), cm)
  cm <- assume(causes(m, y), cm)
  cm <- assume(causes(u, x), cm)
  cm <- assume(causes(u, z), cm)
  cm <- assume(causes(z, m), cm)

  cm@graph <- updateGraph(cm)
  confounders <- inferConfounders(conceptualModel=cm, iv=x, dv=y)
  expect_length(confounders, 1)
  expect_true(z@name %in% confounders)

  # Model 6: Unobserved variable is common ancestor of IV and Mediator, but Z is mediating Unobserved --> Z --> X (Unobserved --> M)
  cm <- ConceptualModel()
  cm <- assume(causes(x, m), cm)
  cm <- assume(causes(m, y), cm)
  cm <- assume(causes(z, x), cm)
  cm <- assume(causes(u, z), cm)
  cm <- assume(causes(u, m), cm)

  cm@graph <- updateGraph(cm)
  confounders <- inferConfounders(conceptualModel=cm, iv=x, dv=y)
  expect_length(confounders, 1)
  expect_true(z@name %in% confounders)

  # Model 8: Parent of Y that is unrelated to X (Maybe good for precision)
  cm <- ConceptualModel()
  cm <- assume(causes(x, y), cm)
  cm <- assume(causes(z, y), cm)

  cm@graph <- updateGraph(cm)
  confounders <- inferConfounders(conceptualModel=cm, iv=x, dv=y)
  expect_length(confounders, 1)
  expect_true(z@name %in% confounders)

  # Model 13: Parent of Mediator (Maybe good for precision)
  cm <- ConceptualModel()
  cm <- assume(causes(x, w), cm)
  cm <- assume(causes(w, y), cm)
  cm <- assume(causes(z, w), cm)

  cm@graph <- updateGraph(cm)
  confounders <- inferConfounders(conceptualModel=cm, iv=x, dv=y)
  expect_length(confounders, 1)
  expect_true(z@name %in% confounders)

  # Model 14: Child of X
  cm <- ConceptualModel()
  cm <- assume(causes(x, y), cm)
  cm <- assume(causes(x, z), cm)

  cm@graph <- updateGraph(cm)
  confounders <- inferConfounders(conceptualModel=cm, iv=x, dv=y)
  expect_length(confounders, 1)
  expect_true(z@name %in% confounders)

  # Model 15: Child of X that has child that is also child of Unobserved variable that causes Y
  cm <- ConceptualModel()
  cm <- assume(causes(x, y), cm)
  cm <- assume(causes(x, z), cm)
  cm <- assume(causes(z, w), cm)
  cm <- assume(causes(u, w), cm)
  cm <- assume(causes(u, y), cm)

  cm@graph <- updateGraph(cm)
  confounders <- inferConfounders(conceptualModel=cm, iv=x, dv=y)
  expect_length(confounders, 1)
  expect_true(z@name %in% confounders)
})

test_that("Catches errors in conceptual model properly", {
  unit <- Unit("unit")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")
  measure_2 <- numeric(unit=unit, name="measure_2")

  # Construct Conceptual Model
  cm <- ConceptualModel()

  # Specify conceptual relationships
  cr <- causes(measure_0, measure_1)
  cm <- hypothesize(cr, cm)

  # IV is not in conceptual model
  expect_error(query(conceptualModel=cm, iv=measure_2, dv=measure_1))

  # DV is not in conceptual model
  expect_error(query(conceptualModel=cm, iv=measure_0, dv=measure_2))

  # Empty conceptual model (therefore, IV and DV not in conceptual model)
  cm <- ConceptualModel()
  expect_error(query(conceptualModel=cm, iv=measure_0, dv=measure_1))

  # DV causes IV
  cr <- causes(measure_1, measure_0)
  cm <- hypothesize(cr, cm)
  expect_error(query(conceptualModel=cm, iv=measure_0, dv=measure_1))

  # Graph is cyclic
  cr <- causes(measure_0, measure_1)
  cr <- causes(measure_1, measure_2)
  cr <- causes(measure_2, measure_0)
  cm <- hypothesize(cr, cm)
  expect_error(query(conceptualModel=cm, iv=measure_0, dv=measure_1))

})
