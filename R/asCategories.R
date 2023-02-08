#' Create a Categories measure wrapper.
#'
#' Method for constructing a Categories wrapper.
#' @param measure. Measure to wrap. Must be either Ordinal or Nominal.
#' @return Continuous variable wrapped around @param measure.
#' @keywords
#' @export
setGeneric("asCategories", function(measure) standardGeneric("asCategories"))
setMethod("asCategories", signature("Measure"), function(measure)
{
  # Create new Categories wrapper
  categories = Categories(measure=measure)

  # Update categories @slot numberOfCategories
  categories@numberOfCategories = measure@cardinality

  # Return handle to Continuous wrapper
  categories
})
setMethod("asCategories", signature("Measure"), function(measure)
{
  # Create new Categories wrapper
  categories = Categories(measure=measure)

  # Update categories @slot numberOfCategories
  categories@numberOfCategories = measure@cardinality

  # Return handle to Categories wrapper
  categories
})
