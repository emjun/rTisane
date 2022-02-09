# Conceptual Relationships
setClass("Causes", representation(cause = "AbstractVariable", effect = "AbstractVariable"))
setClass("Associates", representation(lhs = "AbstractVariable", rhs = "AbstractVariable"))
setClass("Moderates", representation(moderator = "AbstractVariable", on = "AbstractVariable"))

# Data Measurement Relationships
setClass("Nests", representation(base = "Unit", group = "Unit"))
# Specify Union type for number_of_instances
# https://stackoverflow.com/questions/13002200/s4-classes-multiple-types-per-slot
setClassUnion("integerORAbstractVariableORAtMostORPer", c("integer", "AbstractVariable", "AtMost", "Per"))
setClass("Has", representation(variable = "AbstractVariable", measure = "AbstractVariable", repetitions = "NumberValue", according_to = "AbstractVariable"))


#' @include number_value.R
setGeneric("causes", function(cause, effect) standardGeneric("causes"))
setMethod("causes", signature("AbstractVariable", "AbstractVariable"), function(cause, effect)
{
  # create a Causes relationship obj
  relat = Causes(cause=cause, effect=effect)
  # append the Causes relationship obj to both @param cause and effect variables
  cause@relationships <- append(cause@relationships, relat)
  effect@relationships <- append(effect@relationships, relat)
})

setGeneric("associates_with", function(lhs, rhs) standardGeneric("associates_with"))
setMethod("associates_with", signature("AbstractVariable", "AbstractVariable"), function(lhs, rhs)
{
  relat = Associates(lhs=lhs, rhs=rhs)
  lhs@relationships <- append(lhs@relationships, relat)
  rhs@relationships <- append(rhs@relationships, relat)
})

# Provide two implementations for moderates
# In case moderator is an AbstractVariable
setGeneric("moderates", function(var, moderator, on) standardGeneric("moderates"))
setMethod("moderates", signature("AbstractVariable", "AbstractVariable", "AbstractVariable"), function(var, moderator, on)
{
  mods = list(var, moderator)
  relat = Moderates(moderator=mods, on=on)
  var@relationships <- append(var@relationships, relat)
  moderator@relationships <- append(moderator@relationships, relat)
  on@relationships <- append(on@relationships, relat)
})
# Or moderator is a list of AbstractVariables
setMethod("moderates", signature("AbstractVariable", "list", "AbstractVariable"), function(var, moderator, on)
{
  # TODO: Add validity that the list of moderators is all AbstractVariables
  mods = append(moderator, var)
  relat = Moderates(moderator=mods, on=on)
  var@relationships <- append(var@relationships, relat)
  # Add Moderates relationship to all the moderating variables
  for (m in moderator) {
    m@relationships <- append(moderator@relationships, relat)
  }
  on@relationships <- append(on@relationships, relat)
})

setGeneric("nests_within", function(base, group) standardGeneric("nests_within"))
setMethod("nests_within", signature("AbstractVariable", "AbstractVariable"), function(base, group)
{
  relat = Nests(base=base, group=group)
  base@relationships <- append(base@relationships, relat)
  group@relationships <- append(group@relationships, relat)
})
