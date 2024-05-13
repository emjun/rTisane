library(rTisane)

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
  measure_0 <- continuous(unit=participant, name="measure_0")
  measure_1 <- continuous(unit=participant, name="measure_1")
  measure_2 <- continuous(unit=participant, name="measure_2")
  measure_3 <- continuous(unit=participant, name="measure_3")
  u_0 <- Unobserved()
  u_1 <- Unobserved()

  # Relates involving measures only
  ambig_relat <- relates(measure_0, measure_1)
  expect_s4_class(ambig_relat, "Relates")
  expect_null(ambig_relat@when)
  expect_null(ambig_relat@then)

  # Relates involving measures, when then
  ambig_relat <- relates(measure_0, measure_1, increases(measure_0), decreases(measure_1))
  expect_s4_class(ambig_relat, "Relates")
  # Verify that Relates relationship created correctly
  expect_equal(ambig_relat@lhs, measure_0)
  expect_equal(ambig_relat@rhs, measure_1)
  expect_s4_class(ambig_relat@when, "Compares")
  expect_s4_class(ambig_relat@then, "Compares")

  # Relates involving unobserved variables only
  ambig_relat <- relates(u_0, u_1)
  expect_s4_class(ambig_relat, "Relates")
  # Verify that Relates relationship created correctly
  expect_equal(ambig_relat@lhs, u_0)
  expect_equal(ambig_relat@rhs, u_1)
  expect_null(ambig_relat@when)
  expect_null(ambig_relat@then)

  # Relates involving unobserved variables and measures
  ambig_relat <- relates(u_0, measure_0)
  expect_s4_class(ambig_relat, "Relates")
  # Verify that Relates relationship created correctly
  expect_equal(ambig_relat@lhs, u_0)
  expect_equal(ambig_relat@rhs, measure_0)
  expect_null(ambig_relat@when)
  expect_null(ambig_relat@then)

  ambig_relat <- relates(measure_1, u_1)
  expect_s4_class(ambig_relat, "Relates")
  # Verify that Relates relationship created correctly
  expect_equal(ambig_relat@lhs, measure_1)
  expect_equal(ambig_relat@rhs, u_1)
  expect_null(ambig_relat@when)
  expect_null(ambig_relat@then)

  # # Relates involving 2-way interaction
  # ixn <- interacts(measure_0, measure_1)
  # # ixn relates m
  # ambig_relat <- relates(ixn, measure_2)
  # # Verify that Relates relationship created correctly
  # expect_equal(ambig_relat@lhs, ixn)
  # expect_equal(ambig_relat@rhs, measure_2)
  # expect_null(ambig_relat@when)
  # expect_null(ambig_relat@then)
  # # m relates ixn
  # ambig_relat <- relates(measure_2, ixn)
  # # Verify that Relates relationship created correctly
  # expect_equal(ambig_relat@lhs, measure_2)
  # expect_equal(ambig_relat@rhs, ixn)
  # expect_null(ambig_relat@when)
  # expect_null(ambig_relat@then)

  # # Relates involving 3-way interaction
  # ixn <- interacts(measure_0, measure_1, measure_2)
  # # ixn relates m
  # ambig_relat <- relates(ixn, measure_3)
  # # Verify that Relates relationship created correctly
  # expect_equal(ambig_relat@lhs, ixn)
  # expect_equal(ambig_relat@rhs, measure_3)
  # expect_null(ambig_relat@when)
  # expect_null(ambig_relat@then)
  # # m relates ixn
  # ambig_relat <- relates(measure_3, ixn)
  # # Verify that Relates relationship created correctly
  # expect_equal(ambig_relat@lhs, measure_3)
  # expect_equal(ambig_relat@rhs, ixn)
  # expect_null(ambig_relat@when)
  # expect_null(ambig_relat@then)

})

test_that("Causes created properly", {
  unit <- Unit("person")
  measure_0 <- continuous(unit=unit, name="measure_0")
  measure_1 <- continuous(unit=unit, name="measure_1")
  measure_2 <- continuous(unit=unit, name="measure_2")
  measure_3 <- continuous(unit=unit, name="measure_3")
  u_0 <- Unobserved()
  u_1 <- Unobserved()

  # Causes involving measures only
  cause_relat <- causes(measure_0, measure_1)
  expect_s4_class(cause_relat, "Causes")
  # Verify that Causes relationship created correctly
  expect_equal(cause_relat@cause, measure_0)
  expect_equal(cause_relat@effect, measure_1)
  expect_null(cause_relat@when)
  expect_null(cause_relat@then)

  # Causes involving measures, when then
  cause_relat <- causes(measure_0, measure_1, increases(measure_0), decreases(measure_1))
  expect_s4_class(cause_relat, "Causes")
  # Verify that Causes relationship created correctly
  expect_equal(cause_relat@cause, measure_0)
  expect_equal(cause_relat@effect, measure_1)
  expect_s4_class(cause_relat@when, "Compares")
  expect_s4_class(cause_relat@then, "Compares")

  # Causes involving unobserved variables only
  cause_relat <- causes(u_0, u_1)
  expect_s4_class(cause_relat, "Causes")
  # Verify that Causes relationship created correctly
  expect_equal(cause_relat@cause, u_0)
  expect_equal(cause_relat@effect, u_1)
  expect_null(cause_relat@when)
  expect_null(cause_relat@then)

  # Causes involving unobserved variables and measures
  cause_relat <- causes(u_0, measure_0)
  expect_s4_class(cause_relat, "Causes")
  # Verify that Causes relationship created correctly
  expect_equal(cause_relat@cause, u_0)
  expect_equal(cause_relat@effect, measure_0)
  expect_null(cause_relat@when)
  expect_null(cause_relat@then)

  cause_relat <- causes(measure_1, u_1)
  expect_s4_class(cause_relat, "Causes")
  # Verify that Causes relationship created correctly
  expect_equal(cause_relat@cause, measure_1)
  expect_equal(cause_relat@effect, u_1)
  expect_null(cause_relat@when)
  expect_null(cause_relat@then)

  # # Causes involving 2-way interaction involving influence of variables measure_0, measure_1 on measure_3
  # ixn <- interacts(measure_0, measure_1, measure_3)
  
  # # cause_relat <- causes(ixn, measure_3)
  # # Verify that Causes relationship created correctly
  # expect_equal(cause_relat@cause, ixn)
  # expect_equal(cause_relat@effect, measure_3)
  # expect_null(cause_relat@when)
  # expect_null(cause_relat@then)
  # # m causes ixn
  # cause_relat <- causes(measure_3, ixn)
  # # Verify that Causes relationship created correctly
  # expect_equal(cause_relat@cause, measure_3)
  # expect_equal(cause_relat@effect, ixn)
  # expect_null(cause_relat@when)
  # expect_null(cause_relat@then)

  # # Causes involving 3-way interaction
  # ixn <- interacts(measure_0, measure_1, measure_2)
  # # ixn causes m
  # cause_relat <- causes(ixn, measure_3)
  # # Verify that Causes relationship created correctly
  # expect_equal(cause_relat@cause, ixn)
  # expect_equal(cause_relat@effect, measure_3)
  # expect_null(cause_relat@when)
  # expect_null(cause_relat@then)
  # # m causes ixn
  # cause_relat <- causes(measure_3, ixn)
  # # Verify that Causes relationship created correctly
  # expect_equal(cause_relat@cause, measure_3)
  # expect_equal(cause_relat@effect, ixn)
  # expect_null(cause_relat@when)
  # expect_null(cause_relat@then)

})

test_that("Compares created properly", {
  unit <- Unit("person")
  measure_0 <- continuous(unit=unit, name="measure_0")
  measure_1 <- categories(unit=unit, name="measure_1", order=list(1, 2, 3, 4, 5))
  measure_2 <- categories(unit=unit, name="measure_2", cardinality=5)

  # increases
  inc <- increases(measure_0)
  expect_s4_class(inc, "Compares")
  expect_equal(inc@variable, measure_0)
  expect_equal(inc@condition, "increases")

  inc <- increases(measure_1)
  expect_s4_class(inc, "Compares")
  expect_equal(inc@variable, measure_1)
  expect_equal(inc@condition, "increases")

  # decreases
  dec <- decreases(measure_0)
  expect_s4_class(inc, "Compares")
  expect_equal(dec@variable, measure_0)
  expect_equal(dec@condition, "decreases")

  dec <- decreases(measure_1)
  expect_s4_class(inc, "Compares")
  expect_equal(dec@variable, measure_1)
  expect_equal(dec@condition, "decreases")

  # equals
  eq <- equals(measure_0, 2.5)
  expect_s4_class(eq, "Compares")
  expect_equal(eq@variable, measure_0)
  expect_equal(eq@condition, "==2.5")

  eq <- equals(measure_1, 4)
  expect_s4_class(eq, "Compares")
  expect_equal(eq@variable, measure_1)
  expect_equal(eq@condition, "==4")

  eq <- equals(measure_1, 6)
  expect_s4_class(eq, "Compares")
  expect_equal(eq@variable, measure_1)
  expect_equal(eq@condition, "==6")

  eq <- equals(measure_2, 3)
  expect_s4_class(eq, "Compares")
  expect_equal(eq@variable, measure_2)
  expect_equal(eq@condition, "==3")

  # not equals
  neq <- notEquals(measure_0, -1)
  expect_s4_class(neq, "Compares")
  expect_equal(neq@variable, measure_0)
  expect_equal(neq@condition, "!=-1")

  neq <- notEquals(measure_1, 4)
  expect_s4_class(neq, "Compares")
  expect_equal(neq@variable, measure_1)
  expect_equal(neq@condition, "!=4")

  neq <- notEquals(measure_2, 4)
  expect_s4_class(neq, "Compares")
  expect_equal(neq@variable, measure_2)
  expect_equal(neq@condition, "!=4")

})

test_that("Nests created properly", {
  unit_0 <- Unit("person")
  unit_1 <- Unit("group")

  nests_relat <- nests(unit_0, unit_1) # add to docs that can read like: first param.nests(second param)?
  expect_s4_class(nests_relat, "Nests")
  # Verify that Nests is created correctly
  expect_equal(nests_relat@base, unit_0)
  expect_equal(nests_relat@group, unit_1)

  measure_0 <- continuous(unit=unit_0, name="measure_0")
  measure_1 <- continuous(unit=unit_0, name="measure_1")

  # Nests within only makes sense between Units
  expect_error(nests(measure_0, measure_1), "*")
})
