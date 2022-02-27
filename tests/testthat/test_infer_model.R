library("tisaner")
test_that("Design created properly", {
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")

  cause_relat = causes(measure_0, measure_1)

  design <- Design(relationships=list(cause_relat), ivs=list(measure_0), dv=measure_1)
  expect_s4_class(design, "Design")
  expect_type(design@relationships, "list")
  expect_equal(length(design@relationships), 1)
  expect_equal(design@relationships[[1]], cause_relat) # R is 1-indexed
  expect_type(design@ivs, "list")
  expect_equal(length(design@ivs), 1)
  expect_equal(design@ivs[[1]], measure_0)
  expect_s4_class(design@dv, "Numeric")
  expect_true(inherits(design@dv, "AbstractVariable"))
  expect_null(design@source)

  # IVs can be a single variable, too
  expect_error(Design(relationships=list(cause_relat), ivs=measure_0, dv=measure_1))

  # Verify that parameters are set correctly
  expect_error(Design(relationships=list(), ivs=list(measure_0), dv=measire_1))
  expect_error(Design(relationships=list(cause_relat), ivs=list(), dv=measure_1))
  expect_error(Design(relationships=list(cause_relat), ivs=list(measure_0)))

})

test_that("Infer has relationships", {
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")

  cause_relat = causes(measure_0, measure_1)
  design <- Design(relationships=list(cause_relat), ivs=list(measure_0), dv=measure_1)

  relationships <- infer_has_relationships(design)

  expect_type(relationships, "list")
  expect_equal(length(relationships), 2)
  for (r in relationships) {
    expect_s4_class(r, "Has")
  }

})

test_that("Graphs constructed correcty", {
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")

  cause_relat = causes(measure_0, measure_1)
  design <- Design(relationships=list(cause_relat), ivs=list(measure_0), dv=measure_1)

  # Infer has relationships
  has_relationships <- infer_has_relationships(design=design)
  # Combine all relationships
  all_relationships <- append(design@relationships, has_relationships)

  # Construct graph from relationships
  vars <- get_all_vars(design=design)
  print(all_relationships)
  graphs <- construct_graphs(all_relationships, vars)

})
