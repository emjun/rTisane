library(tisaner)

test_that("Conceptual Model created properly", {
  cm <- ConceptualModel()

  expect_s4_class(cm, "ConceptualModel")
  expect_type(cm@variables, "list")
  expect_equal(length(cm@variables), 0)
  expect_type(cm@relationships, "list")
  expect_equal(length(cm@relationships), 0)
})

test_that("Ambiguous Relates created properly", {
  participant <- Participant("pid")
  measure_0 <- numeric(unit=participant, name="measure_0")
  measure_1 <- numeric(unit=participant, name="measure_1")

  ambig_relat <- relates(measure_0, measure_1)
  expect_s4_class(ambig_relat, "Relates")

})

test_that("Causes created properly", {
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")

  cause_relat <- causes(measure_0, measure_1)
  expect_s4_class(cause_relat, "Causes")
  # Verify that Causes relationship created correctly
  expect_equal(cause_relat@cause, measure_0)
  expect_equal(cause_relat@effect, measure_1)
})

test_that("Moderates created properly", {
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")
  measure_2 <- numeric(unit=unit, name="measure_2")
  measure_3 <- numeric(unit=unit, name="measure_3")

  # Two variables moderate
  moderate_relat_0 <- moderates(var=measure_0, moderator=measure_2, on=measure_1)
  expect_s4_class(moderate_relat_0, "Moderates")
  expect_type(moderate_relat_0@moderators, "list")
  expect_true(list(measure_0) %in% moderate_relat_0@moderators)
  expect_true(list(measure_2) %in% moderate_relat_0@moderators)
  expect_equal(measure_1, moderate_relat_0@on)

  # Three variables moderate
  moderate_relat_1 <- moderates(var=measure_0, moderator=list(measure_2, measure_3), on=measure_1)
  expect_s4_class(moderate_relat_1, "Moderates")
  expect_type(moderate_relat_0@moderators, "list")
  expect_true(list(measure_0) %in% moderate_relat_1@moderators)
  expect_true(list(measure_2) %in% moderate_relat_1@moderators)
  expect_true(list(measure_3) %in% moderate_relat_1@moderators)
  expect_equal(measure_1, moderate_relat_1@on)
})

test_that("Nests created properly", {
  unit_0 <- Unit("person")
  unit_1 <- Unit("group")

  nests_relat <- nests_within(unit_0, unit_1) # add to docs that can read like: first param.nests_within(second param)?
  expect_s4_class(nests_relat, "Nests")
  # Verify that Nests is created correctly
  expect_equal(nests_relat@base, unit_0)
  expect_equal(nests_relat@group, unit_1)

  measure_0 <- numeric(unit=unit_0, name="measure_0")
  measure_1 <- numeric(unit=unit_0, name="measure_1")

  # Nests within only makes sense between Units
  expect_error(nests_within(measure_0, measure_1), "*")
})

test_that("Compares created properly", {
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")

  # increases
  inc <- increases(measure_0)

  expect_s4_class(inc, "Compares")
  expect_equal(inc@variable, measure_0)
  expect_equal(inc@condition, "increases")

  # decreases
  measure_1 <- ordinal(unit=unit, name="measure_1", order=list(1, 2, 3, 4, 5))
  dec <- decreases(measure_1)

  expect_s4_class(inc, "Compares")
  expect_equal(dec@variable, measure_1)
  expect_equal(dec@condition, "decreases")

  # equals
  eq <- equals(measure_1, 4)
  expect_s4_class(eq, "Compares")
  expect_equal(eq@variable, measure_1)
  expect_equal(eq@condition, "==4")

  # not equals
  measure_2 <- nominal(unit=unit, name="measure_2", cardinality=5)
  neq <- notEquals(measure_2, 4)
  expect_s4_class(neq, "Compares")
  expect_equal(neq@variable, measure_2)
  expect_equal(neq@condition, "!=4")

})

test_that("WhenThen created properly", {
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")

  # increases
  wt <- whenThen(increases(measure_0), increases(measure_1))
  expect_s4_class(wt, "Relates")
  expect_equal(wt@lhs, measure_0)
  expect_equal(wt@rhs, measure_1)

  # decreases
  wt <- whenThen(increases(measure_0), decreases(measure_1))
  expect_s4_class(wt, "Relates")
  expect_equal(wt@lhs, measure_0)
  expect_equal(wt@rhs, measure_1)

  measure_2 <- nominal(unit=unit, name="measure_2", cardinality=5)
  # ==
  wt <- whenThen(equals(measure_2, integer(3)), increases(measure_1))
  expect_s4_class(wt, "Relates")
  expect_equal(wt@lhs, measure_2)
  expect_equal(wt@rhs, measure_1)

  # !=
  wt <- whenThen(notEquals(measure_2, integer(3)), increases(measure_1))
  expect_s4_class(wt, "Relates")
  expect_equal(wt@lhs, measure_2)
  expect_equal(wt@rhs, measure_1)

  # Multiple list of Compares
  measure_2 <- numeric(unit=unit, name="measure_2")
  wt <- whenThen(when=list(increases(measure_0), increases(measure_1)), then=increases(measure_2))
  expect_s4_class(wt, "Moderates")
})

# TODO: Need to make sure that measure, unit has relationship is inferred
