context("Variable Relationship")
library(tisaner)

test_thank("AbstractVariable created properly", {
  var <- AbstractVariable("name")
  
  expect_is(var, "AbstractVariable")
})

# test_that("Unit variable created propertly", {

# })

# test_that("Causes object created properly", {

#   expect_equal(str_length("a"), 1)
#   expect_equal(str_length("ab"), 2)
#   expect_equal(str_length("abc"), 3)
# })
