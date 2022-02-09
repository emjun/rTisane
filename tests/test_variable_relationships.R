context("Variable Relationship")
library(tisaner)

test_thank("AbstractVariable created properly", {
  var <- AbstractVariable("name")

  expect_is(var, "AbstractVariable")
})

# Write test for passing Has multiple different types to number_of_instances

# TODO:
# student <- unit("student id")
# school <- unit("school")

# # Python
# student = ts.Unit("student id")
# test_score = student.numeric("test score", number_of_instances=2)

# # R
# test_score <- numeric(student, "test score", number_of_instances=2)
# test_score <- student$numeric("test score", number_of_instances=2)


# setClass("DataVector")


# test_that("Unit variable created propertly", {

# })

# test_that("Causes object created properly", {

#   expect_equal(str_length("a"), 1)
#   expect_equal(str_length("ab"), 2)
#   expect_equal(str_length("abc"), 3)
# })
