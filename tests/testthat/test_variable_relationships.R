library(tisaner)

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

test_that("Associates created properly", {
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")

  associates_relat <- associates_with(measure_0, measure_1)
  expect_s4_class(associates_relat, "Associates")
  # Verify that Associates is created correctly
  expect_equal(associates_relat@lhs, measure_0)
  expect_equal(associates_relat@rhs, measure_1)
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

# Need to make sure that measure, unit has relationship is inferred
