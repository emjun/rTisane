library(testthat)
library(rTisane)

test_dir(
  "./testthat",
  env = shiny::loadSupport(),
  reporter = c("progress", "fail")
)
test_check("rTisane")
