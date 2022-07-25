library(tisaner)

test_that("Creates Continuous measure wrapper properly", {
  participant <- Participant("pid", cardinality=40)
  age <- numeric(unit=participant, name="age")
  grade <- ordinal(unit=participant, name="grade", order=list("low","medium", "high"), number_of_instances=integer(1))
  race <- nominal(unit=participant, name="race", cardinality=5)

  # Verify that Continuous wrapper created correctly
  cont <- asContinuous(measure=age)
  expect_s4_class(cont, "Continuous")
  expect_equal(cont@skew, "none")
  cont <- asContinuous(measure=grade)
  expect_s4_class(cont, "Continuous")
  expect_equal(cont@skew, "none")
  # Nominal measures cannot be wrapped/treated as a Continuous measure
  expect_error(asContinuous(measure=race))
})

test_that("Creates Counts measure wrapper properly", {
  participant <- Participant("pid", cardinality=40)
  age <- numeric(unit=participant, name="age")
  grade <- ordinal(unit=participant, name="grade", order=list("low","medium", "high"), number_of_instances=integer(1))
  race <- nominal(unit=participant, name="race", cardinality=5)

  # Verify that Counts wrapper created correctly
  count <- asCounts(measure=age)
  expect_s4_class(count, "Counts")
  count <- asCounts(measure=grade)
  expect_s4_class(count, "Counts")
  # Nominal measures cannot be wrapped/treated as a Counts measure
  expect_error(asCounts(measure=race))
})

test_that("Creates Categories measure wrapper properly", {
  participant <- Participant("pid", cardinality=40)
  age <- numeric(unit=participant, name="age")
  grade <- ordinal(unit=participant, name="grade", order=list("low","medium", "high"), number_of_instances=integer(1))
  race <- nominal(unit=participant, name="race", cardinality=5)

  # Verify that Categories measure created correctly
  cat <- asCategories(measure=grade)
  expect_s4_class(cat, "Categories")
  expect_equal(cat@numberOfCategories, as.integer(3))
  # Nominal measures cannot be wrapped/treated as a Categories measure
  cat <- asCategories(measure=race)
  expect_s4_class(cat, "Categories")
  expect_equal(cat@numberOfCategories, as.integer(5))
  expect_error(asCategories(measure=age))
})

test_that("Infers candidate family functions properly", {
  participant <- Participant("pid", cardinality=40)
  age <- numeric(unit=participant, name="age")
  grade <- ordinal(unit=participant, name="grade", order=list("low","medium", "high"), number_of_instances=integer(1))
  grade_binary <- ordinal(unit=participant, name="grade", order=list("low", "high"), number_of_instances=integer(1))
  race <- nominal(unit=participant, name="race", cardinality=5)

  # Infer family functions for Continuous wrappers
  cont <- asContinuous(measure=age)
  familyFunctions <- inferFamilyFunctions(cont)
  expect_length(familyFunctions, 1)
  expect_equal(familyFunctions[[1]], "gaussian")

  cont <- asContinuous(measure=age)
  cont@skew = "positive"
  familyFunctions <- inferFamilyFunctions(cont)
  expect_length(familyFunctions, 2)
  expect_true(c("inverse.gaussian") %in% familyFunctions)
  expect_true(c("Gamma") %in% familyFunctions)

  # Infer family functions for Counts measures
  count <- asCounts(measure=age)
  familyFunctions <- inferFamilyFunctions(count)
  expect_length(familyFunctions, 2)
  expect_true(c("poisson") %in% familyFunctions)
  expect_true(c("negativeBinomial") %in% familyFunctions)

  # Infer family functions for Categories measures
  cat <- asCategories(measure=grade_binary)
  familyFunctions <- inferFamilyFunctions(cat)
  expect_length(familyFunctions, 1)
  expect_equal(familyFunctions[[1]], "binomial")
  cat <- asCategories(measure=grade)
  familyFunctions <- inferFamilyFunctions(cat)
  expect_length(familyFunctions, 1)
  expect_equal(familyFunctions[[1]], "multinomial")
})

test_that("Infers candidate link functions properly", {
  linkFunctions <- inferLinkFunctions("binomial")
  expect_length(linkFunctions, 5)
  expect_true(c("logit") %in% linkFunctions)
  expect_true(c("probit") %in% linkFunctions)
  expect_true(c("cauchit") %in% linkFunctions)
  expect_true(c("log") %in% linkFunctions)
  expect_true(c("cloglog") %in% linkFunctions)

  linkFunctions <- inferLinkFunctions("Gamma")
  expect_length(linkFunctions, 3)
  expect_true(c("inverse") %in% linkFunctions)
  expect_true(c("identity") %in% linkFunctions)
  expect_true(c("log") %in% linkFunctions)

  linkFunctions <- inferLinkFunctions("gaussian")
  expect_length(linkFunctions, 3)
  expect_true(c("identity") %in% linkFunctions)
  expect_true(c("log") %in% linkFunctions)
  expect_true(c("inverse") %in% linkFunctions)

  linkFunctions <- inferLinkFunctions("inverse.gaussian")
  expect_length(linkFunctions, 4)
  expect_true(c("1/mu^2") %in% linkFunctions)
  expect_true(c("inverse") %in% linkFunctions)
  expect_true(c("identity") %in% linkFunctions)
  expect_true(c("log") %in% linkFunctions)

  linkFunctions <- inferLinkFunctions("negativeBinomial")
  expect_length(linkFunctions, 3)
  expect_true(c("log") %in% linkFunctions)
  expect_true(c("sqrt") %in% linkFunctions)
  expect_true(c("identity") %in% linkFunctions)

  linkFunctions <- inferLinkFunctions("poisson")
  expect_length(linkFunctions, 3)
  expect_true(c("log") %in% linkFunctions)
  expect_true(c("identity") %in% linkFunctions)
  expect_true(c("sqrt") %in% linkFunctions)

  linkFunctions <- inferLinkFunctions("multinomial")
  expect_length(linkFunctions, 0)
})

# test_that("Asks questions to disambiguate variables properly", {
#
# })
