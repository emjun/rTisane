#' Specify a not notEquals Compares relationship.
#'
#' Returns the Compares relationship constructed.
#' @param variable nominalORordinal The variable whose value may not equal @param value.
#' @param value integerORnumericORcharacter. The value to look for/filter on in @param variable.
#' @keywords
#' @export
# notEquals()
setGeneric("notEquals", function(variable, value) standardGeneric("notEquals"))
setMethod("notEquals", signature("Continuous", "integerORnumericORcharacter"), function(variable, value)
{
  # create condition
  if (is.numeric(value) || is.integer(value)) {
    condition = paste(c("!=", value), collapse = "")
  } else {
    rhs = paste(c("\'", value, "\'"), collapse = "")
    condition = paste(c("!=", rhs), collapse = "")
  }

  # create a Compares obj
  comp = Compares(variable=variable, condition=condition)

  # Return Compares obj
  comp
})
setMethod("notEquals", signature("OrderedCategories", "integerORnumericORcharacter"), function(variable, value)
{
  # create condition
  if (is.numeric(value) || is.integer(value)) {
    condition = paste(c("!=", value), collapse = "")
  } else {
    rhs = paste(c("\'", value, "\'"), collapse = "")
    condition = paste(c("!=", rhs), collapse = "")
  }

  # create a Compares obj
  comp = Compares(variable=variable, condition=condition)

  # Return Compares obj
  comp
})

# TODO: Validate that the value exists!
