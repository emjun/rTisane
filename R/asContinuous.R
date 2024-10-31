#' Create a Continuous measure wrapper.
#'
#' Method for constructing a Continuous wrapper.
#' @param measure. Measure to wrap. Must be either Numeric or Ordinal.
#' @return Continuous variable wrapped around @param measure.
#' @export
#' asContinuous()
setGeneric("asContinuous", function(measure) standardGeneric("asContinuous"))
setMethod("asContinuous", signature("Measure"), function(measure)
{
  # Create new Continuous wrapper
  continuous = Continuous(measure=measure)

  # Return handle to Continuous wrapper
  continuous
})
setMethod("asContinuous", signature("Measure"), function(measure)
{
  # Create new Continuous wrapper
  continuous = Continuous(measure=measure)

  # Return handle to Continuous wrapper
  continuous
})
