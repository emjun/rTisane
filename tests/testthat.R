library(testthat)
library(rTisane)

test_dir(
  "./testthat",
  # env = shiny::loadSupport(),
  reporter = c("progress", "fail")
)
testthat::set_max_fails(Inf)
test_check("rTisane")
