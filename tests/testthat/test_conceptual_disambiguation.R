library(rTisane)

library(jsonlite)

# Generate (CM --> JSON)
test_that("Conceptual model disambiguation options created properly", {
  cm <- ConceptualModel()

  unit <- Unit("person")
  measure_0 <- continuous(unit=unit, name="measure_0")
  measure_1 <- continuous(unit=unit, name="measure_1")

  ### All causes relationships
  cm <- ConceptualModel()
  # Assume causal relationship
  cause_relat <- causes(measure_0, measure_1, when=increases(measure_0), then=increases(measure_1))
  cm <- assume(cm, cause_relat)

  path <- generateConceptualModelJSON(conceptualModel=cm, "test_input.json")

  options <- jsonlite::read_json(path)

  expect_length(options$ambiguousRelationships, 0)

  # Hypothesize causal relationship
  cause_relat <- causes(measure_0, measure_1)
  cm <- hypothesize(cm, cause_relat)

  path <- generateConceptualModelJSON(conceptualModel=cm, "test_input.json")

  options <- jsonlite::read_json(path)

  expect_length(options$ambiguousRelationships, 0)

  ### All causes with when, then
  cm <- ConceptualModel()
  # Assume causal relationship
  cause_relat <- causes(measure_0, measure_1, when=increases(measure_0), then=increases(measure_1))
  cm <- assume(cm, cause_relat)

  path <- generateConceptualModelJSON(conceptualModel=cm, "test_input.json")

  options <- jsonlite::read_json(path)

  expect_length(options$ambiguousRelationships, 0)

  # Hypothesize causal relationship
  cause_relat <- causes(measure_0, measure_1)
  cm <- hypothesize(cm, cause_relat)

  path <- generateConceptualModelJSON(conceptualModel=cm, "test_input.json")

  options <- jsonlite::read_json(path)

  expect_length(options$ambiguousRelationships, 0)

  ### All relates relationships
  cm <- ConceptualModel()
  ambig_relat <- relates(measure_0, measure_1)
  # Assume relates relationship
  cm <- assume(cm, ambig_relat)

  path <- generateConceptualModelJSON(conceptualModel=cm, "test_input.json")

  options <- jsonlite::read_json(path)

  relationships <- options$relationships
  expect_length(relationships, 1)
  expectedKey = paste("Assume", measure_0@name, "and", measure_1@name, "are related", sep=" ")
  expect_true(expectedKey %in% relationships)
  choices <- options$choices
  disambig_choices <- choices[[expectedKey]]
  expect_length(disambig_choices, 2)
  expectedValue = paste("Assume", measure_0@name, "causes", measure_1@name, sep=" ")
  expect_true(expectedValue %in% disambig_choices)
  expectedValue = paste("Assume", measure_1@name, "causes", measure_0@name, sep=" ")
  expect_true(expectedValue %in% disambig_choices)

  # Hypothesize relates relationship
  ambig_relat <- relates(measure_0, measure_1)
  cm <- hypothesize(cm, ambig_relat)

  path <- generateConceptualModelJSON(conceptualModel=cm, "test_input.json")

  options <- jsonlite::read_json(path)

  relationships <- options$relationships
  expect_length(relationships, 2)
  expectedKey = paste("Hypothesize", measure_0@name, "and", measure_1@name, "are related", sep=" ")
  expect_true(expectedKey %in% relationships)
  choices <- options$choices
  disambig_choices <- choices[[expectedKey]]
  expect_length(disambig_choices, 2)
  expectedValue = paste("Hypothesize", measure_0@name, "causes", measure_1@name, sep=" ")
  expect_true(expectedValue %in% disambig_choices)
  expectedValue = paste("Hypothesize", measure_1@name, "causes", measure_0@name, sep=" ")
  expect_true(expectedValue %in% disambig_choices)

  ### All relates with when, then
  cm <- ConceptualModel()
  ambig_relat <- relates(measure_0, measure_1, when=decreases(measure_0), then=decreases(measure_1))
  # Assume relates relationship
  cm <- assume(cm, ambig_relat)

  path <- generateConceptualModelJSON(conceptualModel=cm, "test_input.json")

  options <- jsonlite::read_json(path)

  relationships <- options$relationships
  expect_length(relationships, 1)
  expectedKey = paste("Assume", measure_0@name, "and", measure_1@name, "are related", sep=" ")
  expect_true(expectedKey %in% relationships)
  choices <- options$choices
  disambig_choices <- choices[[expectedKey]]
  expect_length(disambig_choices, 2)
  expectedValue = paste("Assume", measure_0@name, "causes", measure_1@name, sep=" ")
  expect_true(expectedValue %in% disambig_choices)
  expectedValue = paste("Assume", measure_1@name, "causes", measure_0@name, sep=" ")
  expect_true(expectedValue %in% disambig_choices)

  # Hypothesize relates relationship
  ambig_relat <- relates(measure_0, measure_1)
  cm <- hypothesize(cm, ambig_relat)

  path <- generateConceptualModelJSON(conceptualModel=cm, "test_input.json")

  options <- jsonlite::read_json(path)

  relationships <- options$relationships
  expect_length(relationships, 2)
  expectedKey = paste("Hypothesize", measure_0@name, "and", measure_1@name, "are related", sep=" ")
  choices <- options$choices
  disambig_choices <- choices[[expectedKey]]
  expect_length(disambig_choices, 2)
  expectedValue = paste("Hypothesize", measure_0@name, "causes", measure_1@name, sep=" ")
  expect_true(expectedValue %in% disambig_choices)
  expectedValue = paste("Hypothesize", measure_1@name, "causes", measure_0@name, sep=" ")
  expect_true(expectedValue %in% disambig_choices)

  ### Mix causes, relates
  cm <- ConceptualModel()
  # Assume causal relationship
  ambig_relat <- relates(measure_0, measure_1)
  cm <- assume(cm, ambig_relat)

  path <- generateConceptualModelJSON(conceptualModel=cm, "test_input.json")

  options <- jsonlite::read_json(path)

  relationships <- options$relationships
  expect_length(relationships, 1)

  expectedKey = paste("Assume", measure_0@name, "and", measure_1@name, "are related", sep=" ")
  expect_true(expectedKey %in% relationships)
  choices <- options$choices
  disambig_choices <- choices[[expectedKey]]
  expect_length(disambig_choices, 2)
  expectedValue = paste("Assume", measure_0@name, "causes", measure_1@name, sep=" ")
  expect_true(expectedValue %in% disambig_choices)
  expectedValue = paste("Assume", measure_1@name, "causes", measure_0@name, sep=" ")
  expect_true(expectedValue %in% disambig_choices)

})

# # Disambiguate (JSON --> interface) --> NEW TEST CASE FUNCTION (see below link for shiny app testing)
# test_that("Conceptual model disambiguation shown on interface as expected   properly", {
#   # TODO: Add tests for shiny app testing
#   #
# })

# Update Conceptual Model
test_that("Conceptual model updates after disambiguation properly", {
  cm <- ConceptualModel()
  unit <- Unit("person")
  measure_0 <- continuous(unit=unit, name="measure_0")
  measure_1 <- continuous(unit=unit, name="measure_1")

  ## Assume
  relat <- relates(measure_0, measure_1)
  cm <- assume(cm, relat)
  # Update graph
  cm@graph <- updateGraph(cm)

  # Values to update to
  uRelat <- paste("Assume", measure_0@name, "causes", measure_1@name, sep=" ")

  # Create updates list to pass to update conceptual model function
  updates <- list("Assume measure_0 causes measure_1")
  cmUpdated <- updateConceptualModel(conceptualModel=cm, values=updates)

  expect_s4_class(cmUpdated, "ConceptualModel")
  relationships <- cmUpdated@relationships
  expect_length(relationships, 1)
  assump <- relationships[[1]]
  expect_s4_class(assump, "Assumption")
  r <- assump@relationship
  expect_s4_class(r, "Causes")
  expect_equal(r@cause, relat@lhs)
  expect_equal(r@effect, relat@rhs)


  ## Hypothesize
  cm <- ConceptualModel()
  relat <- relates(measure_0, measure_1)
  cm <- hypothesize(cm, relat)
  # Update graph
  cm@graph <- updateGraph(cm)

  # Create updates list to pass to updateDV function
  updates <- list("Hypothesize measure_0 causes measure_1")
  cmUpdated <- updateConceptualModel(conceptualModel=cm, values=updates)

  expect_s4_class(cmUpdated, "ConceptualModel")
  relationships <- cmUpdated@relationships
  expect_length(relationships, 1)
  hypo <- relationships[[1]]
  expect_s4_class(hypo, "Hypothesis")
  r <- hypo@relationship
  expect_s4_class(r, "Causes")
  expect_equal(r@cause, relat@lhs)
  expect_equal(r@effect, relat@rhs)

  ## Hypothesize, reverse direction of causes
  cm <- ConceptualModel()
  relat <- relates(measure_0, measure_1)
  cm <- hypothesize(cm, relat)
  # Update graph
  cm@graph <- updateGraph(cm)

  # Values to update to
  updates <- list("Hypothesize measure_1 causes measure_0")
  cmUpdated <- updateConceptualModel(conceptualModel=cm, values=updates)

  expect_s4_class(cmUpdated, "ConceptualModel")
  relationships <- cmUpdated@relationships
  expect_length(relationships, 1)
  hypo <- relationships[[1]]
  expect_s4_class(hypo, "Hypothesis")
  r <- hypo@relationship
  expect_s4_class(r, "Causes")
  expect_equal(r@cause, relat@rhs)
  expect_equal(r@effect, relat@lhs)
})

# Check Stats JSON generation
test_that("Statistical modeling options created properly", {
  cm <- ConceptualModel()
  unit <- Unit("person")
  measure_0 <- continuous(unit=unit, name="measure_0")
  measure_1 <- continuous(unit=unit, name="measure_1")
  measure_2 <- continuous(unit=unit, name="measure_2")

  # Model 1: measure_1 is a common parent
  cm <- assume(cm, causes(measure_1, measure_0))
  cm <- assume(cm, causes(measure_0, measure_2))
  cm <- assume(cm, causes(measure_1, measure_2))
  cm@graph <- updateGraph(cm)
  confounders <- inferConfounders(conceptualModel=cm, iv=measure_0, dv=measure_2)
  cont <- asContinuous(measure_2)
  familyLinkPairs <- inferFamilyLinkFunctions(cont)

  path <- generateStatisticalModelJSON(confounders=confounders, interactions=NULL, randomEffects=NULL, familyLinkFunctions=familyLinkPairs, path="test_input2.json", iv=measure_0, dv=cont)

  options <- jsonlite::read_json(path)
  expect_false(is.null(options$input))
  input <- options$input
  expect_type(input$generatedMainEffects, "list")
  expect_length(input$generatedMainEffects, 2) # IV and confounders
  expect_true(measure_0@name %in% input$generatedMainEffects) # IV
  expect_true(measure_1@name %in% input$generatedMainEffects) # confounder
  expect_type(input$generatedInteractionEffects, "list")
  expect_length(input$generatedInteractionEffects, 0)
  expect_type(input$generatedRandomEffects, "list")
  re <- getElement(input$generatedRandomEffects, " ")
  expect_length(re, 0)
  expect_false(is.null(input$generatedFamilyLinkFunctions)) # Key exists!
  expect_false(is.null(input$query)) # Key exists!
  query <- input$query
  expect_equal(query$DV, measure_2@name)
  expect_length(query$IVs, 1)
  expect_equal(query$IVs[[1]], measure_0@name)
})

# Check code generation -- manual inspect?


# Add default choices for updating --> add to test script

### Separate query processing file?
# Test checkConceptualModel (without iv/dv) -- might be in other test file
# Test checkConceptualModel (with iv/dv) -- might be in other test file