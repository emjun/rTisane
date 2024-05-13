library(rTisane)

# test_that("Creates Continuous measure wrapper properly", {
#   participant <- Participant("pid", cardinality=40)
#   age <- continuous(unit=participant, name="age")
#   grade <- categories(unit=participant, name="grade", order=list("low","medium", "high"), numberOfInstances=integer(1))
#   race <- categories(unit=participant, name="race", cardinality=5)
#
#   # Verify that Continuous wrapper created correctly
#   cont <- asContinuous(age)
#   expect_s4_class(cont, "Continuous")
#   expect_equal(cont@skew, "none")
#   cont <- asContinuous(measure=grade)
#   expect_s4_class(cont, "Continuous")
#   expect_equal(cont@skew, "none")
#   # Nominal measures cannot be wrapped/treated as a Continuous measure
#   expect_error(asContinuous(measure=race))
# })
#
# test_that("Creates Counts measure wrapper properly", {
#   participant <- Participant("pid", cardinality=40)
#   age <- continuous(unit=participant, name="age")
#   grade <- categories(unit=participant, name="grade", order=list("low","medium", "high"), numberOfInstances=integer(1))
#   race <- categories(unit=participant, name="race", cardinality=5)
#
#   # Verify that Counts wrapper created correctly
#   count <- asCounts(measure=age)
#   expect_s4_class(count, "Counts")
#   count <- asCounts(measure=grade)
#   expect_s4_class(count, "Counts")
#   # Nominal measures cannot be wrapped/treated as a Counts measure
#   expect_error(asCounts(measure=race))
# })
#
# test_that("Creates Categories measure wrapper properly", {
#   participant <- Participant("pid", cardinality=40)
#   age <- continuous(unit=participant, name="age")
#   grade <- categories(unit=participant, name="grade", order=list("low","medium", "high"), numberOfInstances=integer(1))
#   race <- categories(unit=participant, name="race", cardinality=5)
#
#   # Verify that Categories measure created correctly
#   cat <- asCategories(measure=grade)
#   expect_s4_class(cat, "Categories")
#   expect_equal(cat@numberOfCategories, as.integer(3))
#   # Nominal measures cannot be wrapped/treated as a Categories measure
#   cat <- asCategories(measure=race)
#   expect_s4_class(cat, "Categories")
#   expect_equal(cat@numberOfCategories, as.integer(5))
#   expect_error(asCategories(measure=age))
# })

test_that("Infers candidate family functions properly", {
  participant <- Participant("pid", cardinality=40)
  age <- continuous(unit=participant, name="age")
  grade <- categories(unit=participant, name="grade", order=list("low","medium", "high"), numberOfInstances=integer(1))
  grade_binary <- categories(unit=participant, name="grade", order=list("low", "high"), numberOfInstances=integer(1))
  race <- categories(unit=participant, name="race", cardinality=5)
  extra <- counts(unit=participant, name="Number of extracurriculars")

  # Infer family functions for Continuous wrappers
  familyFunctions <- inferFamilyFunctions(age)
  expect_length(familyFunctions, 3)
  expect_true("Gaussian" %in% familyFunctions)
  expect_true("Inverse Gaussian" %in% familyFunctions)
  expect_true("Gamma" %in% familyFunctions)

  familyFunctions <- inferFamilyFunctions(age)
  expect_length(familyFunctions, 3)
  expect_true("Gaussian" %in% familyFunctions)
  expect_true("Inverse Gaussian" %in% familyFunctions)
  expect_true("Gamma" %in% familyFunctions)

  # Infer family functions for Counts measures
  familyFunctions <- inferFamilyFunctions(extra)
  expect_length(familyFunctions, 2)
  expect_true(c("Poisson") %in% familyFunctions)
  expect_true(c("Negative Binomial") %in% familyFunctions)

  # Infer family functions for Categories measures
  familyFunctions <- inferFamilyFunctions(grade_binary)
  expect_length(familyFunctions, 1)
  expect_equal(familyFunctions[[1]], "Binomial")
  familyFunctions <- inferFamilyFunctions(grade)
  expect_length(familyFunctions, 4)
  expect_equal(familyFunctions[[1]], "Multinomial")
  expect_true("Multinomial" %in% familyFunctions)
  expect_true("Inverse Gaussian" %in% familyFunctions)
  expect_true("Gamma" %in% familyFunctions)
  expect_true("Gaussian" %in% familyFunctions)
})

test_that("Infers candidate link functions properly", {
  linkFunctions <- inferLinkFunctions("Binomial")
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

  linkFunctions <- inferLinkFunctions("Gaussian")
  expect_length(linkFunctions, 3)
  expect_true(c("identity") %in% linkFunctions)
  expect_true(c("log") %in% linkFunctions)
  expect_true(c("inverse") %in% linkFunctions)

  linkFunctions <- inferLinkFunctions("Inverse Gaussian")
  expect_length(linkFunctions, 4)
  expect_true(c("1/mu^2") %in% linkFunctions)
  expect_true(c("inverse") %in% linkFunctions)
  expect_true(c("identity") %in% linkFunctions)
  expect_true(c("log") %in% linkFunctions)

  linkFunctions <- inferLinkFunctions("Negative Binomial")
  expect_length(linkFunctions, 3)
  expect_true(c("log") %in% linkFunctions)
  expect_true(c("sqrt") %in% linkFunctions)
  expect_true(c("identity") %in% linkFunctions)

  linkFunctions <- inferLinkFunctions("Poisson")
  expect_length(linkFunctions, 3)
  expect_true(c("log") %in% linkFunctions)
  expect_true(c("identity") %in% linkFunctions)
  expect_true(c("sqrt") %in% linkFunctions)

  linkFunctions <- inferLinkFunctions("Multinomial")
  expect_length(linkFunctions, 0)
})

test_that("Infer Family and Link functions properly", {
  participant <- Participant("pid", cardinality=40)
  age <- continuous(unit=participant, name="age")
  extra <- counts(unit=participant, name="Number of extracurriculars")

  familyLinkPairs <- inferFamilyLinkFunctions(age)
  familyCandidates <- inferFamilyFunctions(age)
  expect_equal(length(familyLinkPairs), length(familyCandidates))

  familyLinkPairs <- inferFamilyLinkFunctions(extra)
  familyCandidates <- inferFamilyFunctions(extra)
  expect_equal(length(familyLinkPairs), length(familyCandidates))
  expect_length(familyLinkPairs, 2)
})
# test_that("Asks questions to disambiguate variables properly", {
#
# })
