library(rTisane)
library(dagitty)

test_that("Assume updates Conceptual Model properly", {
  cm <- ConceptualModel()

  unit <- Unit("person")
  measure_0 <- continuous(unit=unit, name="measure_0")
  measure_1 <- continuous(unit=unit, name="measure_1")

  # Assume causal relationship
  cause_relat <- causes(measure_0, measure_1)
  cm <- assume(cm, cause_relat)

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
  cm <- assume(cm, ambig_relat)

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
  measure_0 <- continuous(unit=unit, name="measure_0")
  measure_1 <- continuous(unit=unit, name="measure_1")

  # Hypothesize causal relationship
  cause_relat <- causes(measure_0, measure_1)
  cm <- hypothesize(cm, cause_relat)

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
  cm <- hypothesize(cm, ambig_relat)

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
  age <- continuous(unit=unit, name="age")
  motivation <- continuous(unit=unit, name="motivation")
  pounds_lost <- continuous(unit=unit, name="pounds_lost")
  midlife_crisis <- rTisane:::Unobserved()

  expect_error(hypothesize(cm, causes(age, midlife_crisis)))

  cr1 <- causes(age, midlife_crisis)
  cm <- assume(cm, cr1)
  cr2 <- causes(midlife_crisis, pounds_lost)
  cm <- assume(cm, cr2)
  cr3 <- causes(midlife_crisis, motivation)
  cm <- assume(cm, cr3)

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

test_that("Causal graph constructed/updated properly", {
  cm <- ConceptualModel()
  # Test empty graph
  gr <- rTisane:::updateGraph(cm)
  expect_true(dagitty::is.dagitty(gr))
  expect_equal(nrow(dagitty::edges(gr)), 0)

  unit <- Unit("person")
  measure_0 <- continuous(unit=unit, name="measure_0")
  measure_1 <- continuous(unit=unit, name="measure_1")
  measure_2 <- continuous(unit=unit, name="measure_2")

  # Assume 1 relationship
  cm <- assume(cm, causes(measure_0, measure_1))
  gr <- rTisane:::updateGraph(cm)
  expect_true(is.dagitty(gr))
  expect_equal(nrow(dagitty::edges(gr)), 1)
  expect_equal(dagitty::edges(gr)[[1]][1], measure_0@name)
  expect_equal(dagitty::edges(gr)[[2]][1], measure_1@name)
  expect_equal(dagitty::edges(gr)[[3]][1], "->")

  # Add an assume relationship
  cm <- assume(cm, causes(measure_1, measure_2))
  gr <- rTisane:::updateGraph(cm)
  expect_true(is.dagitty(gr))
  expect_equal(nrow(dagitty::edges(gr)), 2)
  expect_equal(dagitty::edges(gr)[[1]][1], measure_0@name)
  expect_equal(dagitty::edges(gr)[[2]][1], measure_1@name)
  expect_equal(dagitty::edges(gr)[[3]][1], "->")
  expect_equal(dagitty::edges(gr)[[1]][2], measure_1@name)
  expect_equal(dagitty::edges(gr)[[2]][2], measure_2@name)
  expect_equal(dagitty::edges(gr)[[3]][2], "->")

  # Add a hypothesized relationship
  # Should not matter if relationship is assumed vs. hypothesized
  cm <- hypothesize(cm, causes(measure_0, measure_2))
  gr <- rTisane:::updateGraph(cm)
  expect_true(is.dagitty(gr))
  expect_equal(nrow(dagitty::edges(gr)), 3)
  expect_equal(dagitty::edges(gr)[[1]][1], measure_0@name)
  expect_equal(dagitty::edges(gr)[[2]][1], measure_1@name)
  expect_equal(dagitty::edges(gr)[[3]][1], "->")
  expect_equal(dagitty::edges(gr)[[1]][2], measure_0@name) # alpha-numeric ordering
  expect_equal(dagitty::edges(gr)[[2]][2], measure_2@name)
  expect_equal(dagitty::edges(gr)[[3]][2], "->")
  expect_equal(dagitty::edges(gr)[[1]][3], measure_1@name)
  expect_equal(dagitty::edges(gr)[[2]][3], measure_2@name)
  expect_equal(dagitty::edges(gr)[[3]][3], "->")

  # Unobserved variable
  cm <- ConceptualModel()
  unit <- Unit("person")
  x <- continuous(unit=unit, name="x")
  y <- continuous(unit=unit, name="y")
  z <- continuous(unit=unit, name="z")
  m <- continuous(unit=unit, name="m")
  w <- continuous(unit=unit, name="w")
  u <- rTisane:::Unobserved()

  cm <- assume(cm, causes(x, y))
  cm <- assume(cm, causes(u, y))
  cm <- assume(cm, causes(u, z))
  cm <- assume(cm, causes(z, x))
  gr <- rTisane:::updateGraph(cm)
  expect_true(is.dagitty(gr))
  expect_equal(nrow(dagitty::edges(gr)), 4)
  expect_length(names(gr), 4)
})

test_that("Validate Conceptual Model's causal graph properly", {
  cm <- ConceptualModel()
  unit <- Unit("person")
  measure_0 <- continuous(unit=unit, name="measure_0")
  measure_1 <- continuous(unit=unit, name="measure_1")
  measure_2 <- continuous(unit=unit, name="measure_2")
  measure_3 <- continuous(unit=unit, name="measure_3")
  measure_4 <- continuous(unit=unit, name="measure_4")

  cm <- assume(cm, causes(measure_0, measure_1))
  cm <- assume(cm, causes(measure_1, measure_2))
  cm <- hypothesize(cm, causes(measure_0, measure_2))

  cm@graph <- rTisane:::updateGraph(cm)
  isValid <- rTisane:::checkConceptualModel(cm, measure_0, measure_2)
  expect_type(isValid, "list")
  expect_named(isValid, c("isValid"))
  expect_true(isValid$isValid)
  expect_null(isValid$reason)

  # DV is not in the Conceptual Model/graph
  cm <- ConceptualModel()
  cm <- assume(cm, causes(measure_0, measure_1))
  cm@graph <- rTisane:::updateGraph(cm)
  res <- rTisane:::checkConceptualModel(cm, measure_0, measure_2)
  expect_false(res$isValid)
  # IV is not in the Conceptual Model/graph
  res <- rTisane:::checkConceptualModel(cm, measure_2, measure_0)
  expect_false(res$isValid)

  # No path between IV and DV!
  cm <- ConceptualModel()
  cm <- assume(cm, causes(measure_0, measure_2))
  cm <- assume(cm, causes(measure_1, measure_2))
  cm <- assume(cm, causes(measure_3, measure_4))
  cm@graph <- rTisane:::updateGraph(cm)
  res <- rTisane:::checkConceptualModel(cm, measure_0, measure_4)
  expect_named(res, c("isValid", "reason"))

  # DV causes IV!
  cm <- ConceptualModel()
  cm <- assume(cm, causes(measure_0, measure_2))
  cm@graph <- rTisane:::updateGraph(cm)
  res <- rTisane:::checkConceptualModel(cm, measure_2, measure_0)
  expect_named(res, c("isValid", "reason"))
  expect_false(res$isValid)

  # Cycles are OK *until* a query
  cm <- ConceptualModel()
  cm <- assume(cm, causes(measure_0, measure_2))
  cm <- assume(cm, causes(measure_2, measure_0))
  cm@graph <- rTisane:::updateGraph(cm)
  res <- rTisane:::checkConceptualModel(cm, measure_0, measure_2)
  expect_named(res, c("isValid"))
  expect_true(res$isValid)
  res <- rTisane:::checkConceptualModel(cm, measure_2, measure_0)
  expect_named(res, c("isValid"))
  expect_true(res$isValid)
})

test_that("Mediators found correctly", {
  unit <- Unit("person")
  x <- continuous(unit=unit, name="x")
  y <- continuous(unit=unit, name="y")
  z <- continuous(unit=unit, name="z")
  m <- continuous(unit=unit, name="m")
  w <- continuous(unit=unit, name="w")
  u <- rTisane:::Unobserved()

  cm <- ConceptualModel()
  cm <- assume(cm, causes(x, m))
  cm <- assume(cm, causes(m, y))
  cm@graph <- rTisane:::updateGraph(cm)

  mediators <- getMediators(cm, x@name, y@name)
  expect_length(mediators, 1)
  expect_true(m@name %in% mediators)

  cm <- ConceptualModel()
  cm <- assume(cm, causes(x, m))
  cm <- assume(cm, causes(m, y))
  cm <- assume(cm, causes(z, x))
  cm <- assume(cm, causes(z, m))
  cm@graph <- rTisane:::updateGraph(cm)

  mediators <- getMediators(cm, x@name, y@name)
  expect_length(mediators, 1)
  expect_true(m@name %in% mediators)
})

test_that("Observed variables found correctly", {
  unit <- Unit("person")
  x <- continuous(unit=unit, name="x")
  y <- continuous(unit=unit, name="y")
  z <- continuous(unit=unit, name="z")
  m <- continuous(unit=unit, name="m")
  w <- continuous(unit=unit, name="w")
  u <- rTisane:::Unobserved()

  cm <- ConceptualModel()
  cm <- assume(cm, causes(x, m))
  cm <- assume(cm, causes(m, y))
  cm <- assume(cm, causes(u, x))
  cm@graph <- rTisane:::updateGraph(cm)


  expect_true(isObserved(cm, x))
  expect_true(isObserved(cm, y))
  expect_true(isObserved(cm, m))
  expect_null(isObserved(cm, unit))
  expect_false(isObserved(cm, u))
})

test_that("Interactions found correctly", {
  unit <- Unit("person")
  measure_0 <- continuous(unit=unit, name="measure_0")
  measure_1 <- continuous(unit=unit, name="measure_1")
  measure_2 <- continuous(unit=unit, name="measure_2")
  measure_3 <- continuous(unit=unit, name="measure_3")

  cm <- ConceptualModel()
  # No interactions
  cm <- assume(cm, causes(measure_0, measure_3))
  cm <- assume(cm, causes(measure_1, measure_3))
  cm@graph <- rTisane:::updateGraph(cm)

  interactions <- rTisane:::getInteractions(cm, measure_3)
  expect_length(interactions, 0)

  # 1 interaction
  cm <- interacts(cm, measure_0, measure_1, dv=measure_3)
  cm@graph <- rTisane:::updateGraph(cm)

  interactions <- rTisane:::getInteractions(cm, measure_3)
  expect_length(interactions, 1)
  ixn <- interactions[[1]]
  expect_equal(ixn@name, "measure_0*measure_1")
  expect_equal(ixn@dv, measure_3)

  # 2 interactions
  cm <- interacts(cm, measure_0, measure_1, dv=measure_2)
  cm@graph <- rTisane:::updateGraph(cm)

  interactions <- rTisane:::getInteractions(cm, measure_3)
  expect_length(interactions, 1)
  ixn <- interactions[[1]]
  expect_equal(ixn@name, "measure_0*measure_1")
  expect_equal(ixn@dv, measure_3)
  interactions <- rTisane:::getInteractions(cm, measure_2)
  expect_length(interactions, 1)
  ixn <- interactions[[1]]
  expect_equal(ixn@name, "measure_0*measure_1")
  expect_equal(ixn@dv, measure_2)
})

test_that("Infer confounders correctly", {
  cm <- ConceptualModel()
  unit <- Unit("person")
  measure_0 <- continuous(unit=unit, name="measure_0")
  measure_1 <- continuous(unit=unit, name="measure_1")
  measure_2 <- continuous(unit=unit, name="measure_2")
  measure_3 <- continuous(unit=unit, name="measure_3")
  measure_4 <- continuous(unit=unit, name="measure_4")

  # Model 1: measure_1 is a common parent
  cm <- assume(cm, causes(measure_1, measure_0))
  cm <- assume(cm, causes(measure_0, measure_2))
  cm <- assume(cm, causes(measure_1, measure_2))
  cm@graph <- rTisane:::updateGraph(cm)
  confounders <- rTisane:::inferConfounders(conceptualModel=cm, iv=measure_0, dv=measure_2)
  expect_length(confounders, 1)
  expect_true(measure_1@name %in% confounders)

  # Model 2: Mediator, Unobserved common parent
  cm <- ConceptualModel()
  unit <- Unit("person")
  x <- continuous(unit=unit, name="x")
  y <- continuous(unit=unit, name="y")
  z <- continuous(unit=unit, name="z")
  m <- continuous(unit=unit, name="m")
  w <- continuous(unit=unit, name="w")
  u <- rTisane:::Unobserved()

  cm <- assume(cm, causes(x, y))
  cm <- assume(cm, causes(u, y))
  cm <- assume(cm, causes(u, z))
  cm <- assume(cm, causes(z, x))

  cm@graph <- rTisane:::updateGraph(cm)
  confounders <- rTisane:::inferConfounders(conceptualModel=cm, iv=x, dv=y)
  expect_length(confounders, 1)
  expect_true(z@name %in% confounders)

  # Model 3: Mediator, Unobserved common parent
  cm <- ConceptualModel()
  cm <- assume(cm, causes(x, y))
  cm <- assume(cm, causes(u, x))
  cm <- assume(cm, causes(u, z))
  cm <- assume(cm, causes(z, y))

  cm@graph <- rTisane:::updateGraph(cm)
  confounders <- rTisane:::inferConfounders(conceptualModel=cm, iv=x, dv=y)
  expect_length(confounders, 1)
  expect_true(z@name %in% confounders)

  # Model 4: Common cause of X and any mediator between X and Y
  cm <- ConceptualModel()
  cm <- assume(cm, causes(x, m))
  cm <- assume(cm, causes(m, y))
  cm <- assume(cm, causes(z, x))
  cm <- assume(cm, causes(z, m))

  cm@graph <- rTisane:::updateGraph(cm)
  confounders <- rTisane:::inferConfounders(conceptualModel=cm, iv=x, dv=y)
  expect_length(confounders, 1)
  expect_true(z@name %in% confounders)

  # Model 5: Unobserved variable is common ancestor of IV and Mediator, but Z is mediating Unobserved --> Z --> M
  cm <- ConceptualModel()
  cm <- assume(cm, causes(x, m))
  cm <- assume(cm, causes(m, y))
  cm <- assume(cm, causes(u, x))
  cm <- assume(cm, causes(u, z))
  cm <- assume(cm, causes(z, m))

  cm@graph <- rTisane:::updateGraph(cm)
  confounders <- rTisane:::inferConfounders(conceptualModel=cm, iv=x, dv=y)
  expect_length(confounders, 1)
  expect_true(z@name %in% confounders)

  # Model 6: Unobserved variable is common ancestor of IV and Mediator, but Z is mediating Unobserved --> Z --> X (Unobserved --> M)
  cm <- ConceptualModel()
  cm <- assume(cm, causes(x, m))
  cm <- assume(cm, causes(m, y))
  cm <- assume(cm, causes(z, x))
  cm <- assume(cm, causes(u, z))
  cm <- assume(cm, causes(u, m))

  cm@graph <- rTisane:::updateGraph(cm)
  confounders <- rTisane:::inferConfounders(conceptualModel=cm, iv=x, dv=y)
  expect_length(confounders, 1)
  expect_true(z@name %in% confounders)

  # Model 8: Parent of Y that is unrelated to X (Maybe good for precision)
  cm <- ConceptualModel()
  cm <- assume(cm, causes(x, y))
  cm <- assume(cm, causes(z, y))

  cm@graph <- rTisane:::updateGraph(cm)
  confounders <- rTisane:::inferConfounders(conceptualModel=cm, iv=x, dv=y)
  expect_length(confounders, 1)
  expect_true(z@name %in% confounders)

  # Model 13: Parent of Mediator (Maybe good for precision)
  cm <- ConceptualModel()
  cm <- assume(cm, causes(x, w))
  cm <- assume(cm, causes(w, y))
  cm <- assume(cm, causes(z, w))

  cm@graph <- rTisane:::updateGraph(cm)
  confounders <- rTisane:::inferConfounders(conceptualModel=cm, iv=x, dv=y)
  expect_length(confounders, 1)
  expect_true(z@name %in% confounders)

  # Model 14: Child of X
  cm <- ConceptualModel()
  cm <- assume(cm, causes(x, y))
  cm <- assume(cm, causes(x, z))

  cm@graph <- rTisane:::updateGraph(cm)
  confounders <- rTisane:::inferConfounders(conceptualModel=cm, iv=x, dv=y)
  expect_length(confounders, 1)
  expect_true(z@name %in% confounders)

  # Model 15: Child of X that has child that is also child of Unobserved variable that causes Y
  cm <- ConceptualModel()
  cm <- assume(cm, causes(x, y))
  cm <- assume(cm, causes(x, z))
  cm <- assume(cm, causes(z, w))
  cm <- assume(cm, causes(u, w))
  cm <- assume(cm, causes(u, y))

  cm@graph <- rTisane:::updateGraph(cm)
  confounders <- rTisane:::inferConfounders(conceptualModel=cm, iv=x, dv=y)
  expect_length(confounders, 1)
  expect_true(z@name %in% confounders)
})

test_that("Infer interactions correctly", {
  unit <- Unit("unit")
  measure_0 <- continuous(unit=unit, name="measure_0")
  measure_1 <- continuous(unit=unit, name="measure_1")
  measure_2 <- continuous(unit=unit, name="measure_2")
  measure_3 <- continuous(unit=unit, name="measure_3")

  # Construct Conceptual Model
  cm <- ConceptualModel()

  # Specify conceptual relationships
  cm <- assume(cm, causes(measure_1, measure_0))
  cm <- assume(cm, causes(measure_0, measure_2))
  cm <- assume(cm, causes(measure_1, measure_2))
  cr <- causes(measure_0, measure_1)
  cm <- hypothesize(cm, cr)

  # There are no interactions
  cm@graph <- rTisane:::updateGraph(cm)
  confounders <- rTisane:::inferConfounders(conceptualModel=cm, iv=measure_0, dv=measure_2)
  interactions <- inferInteractions(conceptualModel=cm, iv=measure_0, dv=measure_2, confounders=confounders)
  expect_length(interactions, 0)

  # There is 1 interaction
  cm <- interacts(cm, measure_0, measure_1, dv=measure_2)
  cm@graph <- rTisane:::updateGraph(cm)
  confounders <- rTisane:::inferConfounders(conceptualModel=cm, iv=measure_0, dv=measure_2)
  interactions <- inferInteractions(conceptualModel=cm, iv=measure_0, dv=measure_2, confounders=confounders)
  expect_length(interactions, 1)

  # There is only 1 interaction with the applicable DV
  cm <- interacts(cm, measure_1, measure_2, dv=measure_3)
  cm@graph <- rTisane:::updateGraph(cm)
  confounders <- rTisane:::inferConfounders(conceptualModel=cm, iv=measure_0, dv=measure_2)
  interactions <- inferInteractions(conceptualModel=cm, iv=measure_0, dv=measure_2, confounders=confounders)
  expect_length(interactions, 1)

  # There are 2 interactions
  cm <- interacts(cm, measure_1, measure_3, dv=measure_2)

  cm@graph <- rTisane:::updateGraph(cm)
  confounders <- rTisane:::inferConfounders(conceptualModel=cm, iv=measure_0, dv=measure_2)
  interactions <- inferInteractions(conceptualModel=cm, iv=measure_0, dv=measure_2, confounders=confounders)
  expect_length(interactions, 2)
})

# MANUAL: Opens up disambiguation interface
# test_that("Catches errors in conceptual model properly", {
#   unit <- Unit("unit")
#   measure_0 <- continuous(unit=unit, name="measure_0")
#   measure_1 <- continuous(unit=unit, name="measure_1")
#   measure_2 <- continuous(unit=unit, name="measure_2")

#   # Construct Conceptual Model
#   cm <- ConceptualModel()

#   # Specify conceptual relationships
#   cr <- causes(measure_0, measure_1)
#   cm <- hypothesize(cm, cr)

#   # IV is not in conceptual model
#   expect_error(query(conceptualModel=cm, iv=measure_2, dv=measure_1))

#   # DV is not in conceptual model
#   expect_error(query(conceptualModel=cm, iv=measure_0, dv=measure_2))

#   # Empty conceptual model (therefore, IV and DV not in conceptual model)
#   cm <- ConceptualModel()
#   expect_error(query(conceptualModel=cm, iv=measure_0, dv=measure_1))

#   # DV causes IV
#   cr <- causes(measure_1, measure_0)
#   cm <- hypothesize(cm, cr)
#   expect_error(query(conceptualModel=cm, iv=measure_0, dv=measure_1))

#   # Graph is cyclic
#   cr <- causes(measure_0, measure_1)
#   cr <- causes(measure_1, measure_2)
#   cr <- causes(measure_2, measure_0)
#   cm <- hypothesize(cm, cr)
#   expect_error(query(conceptualModel=cm, iv=measure_0, dv=measure_1))
# })