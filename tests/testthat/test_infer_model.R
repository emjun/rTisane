library("tisaner")

# Helper function
get_graphs <- function(design) {
  # Infer has relationships
  has_relationships <- infer_has_relationships(design=design)
  # Combine all relationships
  all_relationships <- append(design@relationships, has_relationships)

  # Construct graph from relationships
  vars <- get_all_vars(design=design)
  graphs <- construct_graphs(all_relationships, vars)
}

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

test_that("Causal graphs constructed correctly", {
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
  graphs <- construct_graphs(all_relationships, vars)

  causal_gr <- graphs[[1]]
  expect_equal(length(names(causal_gr)), 2)
  expect_true(measure_0@name %in% names(causal_gr))
  expect_true(measure_1@name %in% names(causal_gr))
})

test_that("Measurement graphs constructed correctly", {
  # Add moderates relationship
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")
  measure_2 <- numeric(unit=unit, name="measure_2")

  ## Two variables moderate
  moderate_relat_0 <- moderates(var=measure_0, moderator=measure_2, on=measure_1)
  design <- Design(relationships=list(moderate_relat_0), ivs=list(measure_0), dv=measure_1)
  # Infer has relationships
  has_relationships <- infer_has_relationships(design=design)
  # Combine all relationships
  all_relationships <- append(design@relationships, has_relationships)

  # Construct graph from relationships
  vars <- get_all_vars(design=design)
  graphs <- construct_graphs(all_relationships, vars)
  measurement_gr <- graphs[[3]]

  expect_equal(length(names(measurement_gr)), 4)
  expect_equal(length(has_relationships), length(names(measurement_gr)))
  for (r in has_relationships) {
    expect_s4_class(r, "Has")
    expect_equal(r@variable, unit)

    if ("_X_" %in% r@measure@name) {
      expect_equal(r@measure@name == "measure_0_X_measure_2")
    }
  }

  ## Three variables moderate
  measure_3 <- numeric(unit=unit, name="measure_3")
  moderate_relat_1 <- moderates(var=measure_0, moderator=list(measure_2, measure_3), on=measure_1)
  design1 <- Design(relationships=list(moderate_relat_0), ivs=list(measure_0), dv=measure_1)
  # Infer has relationships
  has_relationships <- infer_has_relationships(design=design1)
  # Combine all relationships
  all_relationships <- append(design1@relationships, has_relationships)

  # Construct graph from relationships
  vars <- get_all_vars(design=design1)
  graphs <- construct_graphs(all_relationships, vars)
  measurement_gr <- graphs[[3]]

  expect_equal(length(names(measurement_gr)), 4)
  expect_equal(length(has_relationships), length(names(measurement_gr)))
  for (r in has_relationships) {
    expect_s4_class(r, "Has")
    expect_equal(r@variable, unit)

    if ("_X_" %in% r@measure@name) {
      expect_equal(r@measure@name == "measure_0_X_measure_2_X_measure_3")
    }
  }

})

test_that("Main effects inferred correctly", {
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")

  ## ONLY ONE CAUSAL RELATIONSHIP
  cause_relat <- causes(measure_0, measure_1)
  design <- Design(relationships=list(cause_relat), ivs=list(measure_0), dv=measure_1)

  graphs <- get_graphs(design)

  causal_gr <- graphs[[1]]
  associative_gr <- graphs[[2]]
  main_effects <- infer_main_effects_with_explanations(causal_gr, associative_gr, design)
  expect_equal(length(main_effects), 1)
  expect_true(measure_0@name %in% main_effects)

  ## ONE CAUSAL ANCESTOR
  measure_2 <- numeric(unit=unit, name="measure_2")
  cause_ancestor <- causes(measure_2, measure_0)
  design1 <- Design(relationships=list(cause_relat, cause_ancestor), ivs=list(measure_0), dv=measure_1)

  graphs <- get_graphs(design1)
  causal_gr <- graphs[[1]]
  associative_gr <- graphs[[2]]
  main_effects <- infer_main_effects_with_explanations(causal_gr, associative_gr, design1)
  expect_equal(length(main_effects), 2)
  expect_true(measure_0@name %in% main_effects)
  expect_true(measure_2@name %in% main_effects)

  ## ONE CAUSAL OMISSION
  measure_3 <- numeric(unit=unit, name="measure_3")
  cause_omission <- causes(measure_3, measure_1)
  design2 <- Design(relationships=list(cause_relat, cause_ancestor, cause_omission), ivs=list(measure_0), dv=measure_1)

  graphs <- get_graphs(design2)
  causal_gr <- graphs[[1]]
  associative_gr <- graphs[[2]]
  main_effects <- infer_main_effects_with_explanations(causal_gr, associative_gr, design2)
  expect_equal(length(main_effects), 3)
  expect_true(measure_0@name %in% main_effects)
  expect_true(measure_2@name %in% main_effects)
  expect_true(measure_3@name %in% main_effects)

  ## ONE ASSOCIATIVE RELATIONSHIP
  measure_4 <- numeric(unit=unit, name="measure_4")
  assoc <- associates_with(measure_0, measure_4)
  design3 <- Design(relationships=list(cause_relat, cause_ancestor, cause_omission, assoc), ivs=list(measure_0), dv=measure_1)

  graphs <- get_graphs(design3)
  causal_gr <- graphs[[1]]
  associative_gr <- graphs[[2]]
  main_effects <- infer_main_effects_with_explanations(causal_gr, associative_gr, design3)
  expect_equal(length(main_effects), 3)
  expect_true(measure_0@name %in% main_effects)
  expect_true(measure_2@name %in% main_effects)
  expect_true(measure_3@name %in% main_effects)

  ## ONE ASSOCIATIVE INTERMEDIARY
  assoc_ <- associates_with(measure_0, measure_4) # IV
  assoc_intermediary <- associates_with(measure_1, measure_4) # DV
  design4 <- Design(relationships=list(cause_relat, cause_ancestor, cause_omission, assoc_, assoc_intermediary), ivs=list(measure_0), dv=measure_1)

  graphs <- get_graphs(design4)
  causal_gr <- graphs[[1]]
  associative_gr <- graphs[[2]]
  main_effects <- infer_main_effects_with_explanations(causal_gr, associative_gr, design4)
  expect_equal(length(main_effects), 4)
  expect_true(measure_0@name %in% main_effects)
  expect_true(measure_2@name %in% main_effects)
  expect_true(measure_3@name %in% main_effects)
  expect_true(measure_4@name %in% main_effects)

})

test_that("Interaction effects inferred correctly", {
  unit <- Unit("person")
  measure_0 <- numeric(unit=unit, name="measure_0")
  measure_1 <- numeric(unit=unit, name="measure_1")
  measure_2 <- numeric(unit=unit, name="measure_2")
  measure_3 <- numeric(unit=unit, name="measure_3")

  ## ONE 2-VARIABLE MODERATION
  cause_relat_0 <- causes(measure_0, measure_1)
  cause_relat_1 <- causes(measure_2, measure_1)
  moderate_relat_0 <- moderates(var=measure_0, moderator=measure_2, on=measure_1)
  design <- Design(relationships=list(cause_relat_0, cause_relat_1, moderate_relat_0), ivs=list(measure_0, measure_2), dv=measure_1)
  graphs <- get_graphs(design)
  causal_gr <- graphs[[1]]
  associative_gr <- graphs[[2]]
  main_effects = infer_main_effects_with_explanations(causal_gr, associative_gr, design)
  interaction_effects <- infer_interaction_effects_with_explanations(causal_gr, associative_gr, design, main_effects)
  expect_equal(length(interaction_effects), 1)

  ### FILTERED OUT
  design_f <- Design(relationships=list(cause_relat_0, moderate_relat_0), ivs=list(measure_0), dv=measure_1)
  graphs <- get_graphs(design_f)
  causal_gr <- graphs[[1]]
  associative_gr <- graphs[[2]]
  main_effects_f =  infer_main_effects_with_explanations(causal_gr, associative_gr, design_f)
  interaction_effects <- infer_interaction_effects_with_explanations(causal_gr, associative_gr, design_f, main_effects_f)
  expect_equal(length(interaction_effects), 0)

  ## TWO 2-VARIABLE MODERATIONS
  cause_relat_2 <- causes(measure_3, measure_1)
  moderate_relat_1 <- moderates(var=measure_0, moderator=list(measure_3), on=measure_1)
  design1 <- Design(relationships=list(cause_relat_0, cause_relat_1, cause_relat_2, moderate_relat_0, moderate_relat_1), ivs=list(measure_0, measure_2, measure_3), dv=measure_1)
  graphs <- get_graphs(design1)
  causal_gr <- graphs[[1]]
  associative_gr <- graphs[[2]]
  main_effects <- infer_main_effects_with_explanations(causal_gr, associative_gr, design1)
  interaction_effects <- infer_interaction_effects_with_explanations(causal_gr, associative_gr, design1, main_effects)
  expect_equal(length(interaction_effects), 2)

  ### FILTERED OUT
  design1 <- Design(relationships=list(cause_relat_0, cause_relat_1, moderate_relat_0, moderate_relat_1), ivs=list(measure_0, measure_2), dv=measure_1)
  graphs <- get_graphs(design1)
  causal_gr <- graphs[[1]]
  associative_gr <- graphs[[2]]
  main_effects <- infer_main_effects_with_explanations(causal_gr, associative_gr, design1)
  interaction_effects <- infer_interaction_effects_with_explanations(causal_gr, associative_gr, design1, main_effects)
  expect_equal(length(interaction_effects), 1)

  # ## ONE 3-VARIABLE MODERATION
  moderate_relat_2 <- moderates(var=measure_0, moderator=list(measure_2, measure_3), on=measure_1)
  design2 <- Design(relationships=list(cause_relat_0, cause_relat_1, cause_relat_2, moderate_relat_2), ivs=list(measure_0), dv=measure_1)
  graphs <- get_graphs(design2)
  causal_gr <- graphs[[1]]
  associative_gr <- graphs[[2]]
  main_effects <- infer_main_effects_with_explanations(causal_gr, associative_gr, design2)
  interaction_effects <- infer_interaction_effects_with_explanations(causal_gr, associative_gr, design2, main_effects)
  expect_equal(length(interaction_effects), 1)

})
