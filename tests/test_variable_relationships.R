context("Variable Relationship")
library(tisaner)

test_that("Causes object created properly", {

  expect_equal(str_length("a"), 1)
  expect_equal(str_length("ab"), 2)
  expect_equal(str_length("abc"), 3)
})
