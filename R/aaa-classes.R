#' AbstractVariable Class
#'
#' Abstract super class for declaring variables
#' @slot name Name of variable, which should correspond with the column name for variable's data (must be in long format)
#' @slot relationships List of relationships this variable has with other variables
#' @keywords
#' @export AbstractVariable
#' @examples
#' AbstractVariable(name="name", relationships=list())
AbstractVariable <- setClass("AbstractVariable",
    slots = c(
        name = "character",
        relationships = "list"
    ),
    prototype = list(
        name = NULL,
        relationships = list()
    )
)
# Helper to create instances of the AbstractVariable class
AbstractVariable <- function(name,
                   relationships = list()) {
  new("AbstractVariable",
      name = name,
      relationships = relationships
  )
}

#' UnobservedVariable class
#'
#' Class for Unobserved variables.
#' @keywords
#' @export
#' @examples
#' Unobserved()
UnobservedVariable <- setClass("UnobservedVariable",
                               slot = c(
                                 name = "character"
                               ),
                               prototype = list(
                                 name = "Unobserved"
                               )
)
# Helper to create instances of the Unobserved class
# Used internally only
Unobserved <- function() {
  new("UnobservedVariable")
}

#' Number Value class
#'
#' Abstract super class for number values, used for number_of_instances that a Unit has of a Measure
#' @slot value Number value
#' @keywords
#' @export NumberValue
#' @exportClass NumberValue
#' @examples
#' NumberValue()
NumberValue <- setClass("NumberValue",
    slots = c(
        value = "integer"
    )
)

#' Exactly class
#'
#' Wrapper class for exact number values. Extends NumberValue class.
#' @slot value Number value
#' @keywords
#' @export Exactly
#' @examples
#' Exactly(3)
Exactly <- setClass("Exactly",
    slots = c(
        value = "integer", contains = "NumberValue"
    ),
    prototype = list(
        value = NULL
    )
)
# Helper to create instances of the AbstractVariable class
Exactly <- function(value) {
  new("Exactly",
      value = value
  )
}

#' AtMost class
#'
#' Wrapper class for upperbound of number values. Extends NumberValue class.
#' @slot value Number value
#' @keywords
#' @export AtMost
#' @examples
#' AtMost(3), could be 0, 1, 2, xor 3 value!
AtMost <- setClass("AtMost",
    slots = c(
        value = "integer"
    ),
    contains = "NumberValue"
)

#' Per class
#'
#' Wrapper class for ratios between number values. Extends NumberValue class.
#' @slot number NumberValue
#' @slot variable AbstractVariable that contains
#' @slot cardinality
#' @slot number_of_instances
#' @slot value
#' @keywords
#' @examples
#' Per()
Per <- setClass("Per",
    slots = c(
        number = "NumberValue",
        variable = "AbstractVariable",
        cardinality = "logical",
        number_of_instances = "logical",
        value = "integer"
    ),
    prototype = list(
        number = NULL,
        variable = NULL,
        cardinality = TRUE,
        number_of_instances = FALSE,
        value = NULL
    ),
    contains = "NumberValue"
)

# Specify Union type for number_of_instances
# https://stackoverflow.com/questions/13002200/s4-classes-multiple-types-per-slot
setClassUnion("integerORAbstractVariableORAtMostORPer", c("integer", "AbstractVariable", "AtMost", "Per"))
setClassUnion("missingORintegerORAbstractVariableORAtMostORPer", c("missing", "integerORAbstractVariableORAtMostORPer"))

#' Dataset class
#'
#' Class for Dataset
#' @slot df DataFrame.
#' @keywords
#' @export Dataset
#' @exportClass Dataset
#' @examples
#' Dataset()
Dataset <- setClass("Dataset",
    slots = c(
      df = "character"
    ),
    prototype = list(
      df = NULL
    )
)

setClassUnion("AbstractVariableORUnobservedVariable", c("AbstractVariable", "UnobservedVariable"))
#' Relates class
#'
#' Class for Relates relationships.
#' Not called directly.
#' @slot lhs AbstractVariable. A variable.
#' @slot rhs AbstractVariable. A variable.
#' @keywords
#' @examples
#' Relates()
Relates <- setClass("Relates",
                   slot = c(
                     lhs = "AbstractVariableORUnobservedVariable",
                     rhs = "AbstractVariableORUnobservedVariable"
                   )
)

#' Causes class
#'
#' Class for Causes relationships.
#' Not called directly.
#' @slot cause AbstractVariable. Variable that causes another.
#' @slot effect AbstractVariable. Variable that is caused by @slot cause.
#' @keywords
#' @examples
#' Causes()
Causes <- setClass("Causes",
    slot = c(
        cause = "AbstractVariableORUnobservedVariable",
        effect = "AbstractVariableORUnobservedVariable"
    )
)

#' Moderates class
#'
#' Class for Moderates relationships.
#' Not called directly.
#' @slot moderators List of AbstractVariables.
#' @slot on AbstractVariable that the moderators moderate each other on
#' @keywords
#' @examples
#' Moderates(moderators=list(x1, x2), on=dv)
Moderates <- setClass("Moderates",
    slot = c(
        moderators = "list",
        on = "AbstractVariable"
    ),
    prototype = list(
        moderators = NULL,
        on = NULL
    )
)
# Helper to create instances of the Moderates class
Moderates <- function(moderators,
                   on) {
  new("Moderates",
      moderators=moderators,
      on = on
  )
}


setClassUnion("numberValueORExactlyORAtMostORPer", c("NumberValue", "Exactly", "AtMost", "Per"))
setClassUnion("AbstractVariableORNull", c("AbstractVariable", "NULL"))
#' Has class
#'
#' Class for Has relationships between AbstractVariables.
#' Not called directly. For internal purposes only.
#' @slot variable AbstractVariable. Variable that has another Variable. For example, the Unit that has a Measure.
#' @slot measure AbstractVariable. Variable that @slot variable has. For example, the Measure a Unit has.
#' @slot repetitions NumberValue. Number of times that @slot variable has @slot measure.
#' @slot according_to AbstractVariable. Variable whose unique values differentiate the repeated instances of @slot measure.
#' @keywords
#' @examples
#' Has()
Has <- setClass("Has",
    slot = c(
        variable = "AbstractVariable",
        measure = "AbstractVariable",
        repetitions = "numberValueORExactlyORAtMostORPer",
        according_to = "AbstractVariableORNull"
    ),
    prototype = list(
        variable = NULL,
        measure = NULL,
        repetitions = NULL,
        according_to = NULL
    )
)
# Helper to create instances of the AbstractVariable class
Has <- function(variable, measure, repetitions, according_to) {
  new("Has",
      variable = variable,
      measure = measure,
      repetitions = repetitions,
      according_to = according_to
  )
}


#' Unit class
#'
#' Class for Unit variables
#' @slot name Name of Unit, corresponds to column name if assigning data
#' @slot integer Integer for cardinality, optional. Only required if no data is assigned
#' @keywords
#' @export
#' @examples
#' Unit()
Unit <- setClass("Unit",
    slot = c(
        name = "character",
        cardinality = "integer"
    ),
    contains = "AbstractVariable",
    prototype = list(
        name = NULL,
        cardinality = as.integer(0)
    )

)
# Helper to create instances of the Unit class
Unit <- function(name,
                   cardinality=as.integer(0)) {
  new("Unit",
      name = name,
      cardinality = as.integer(cardinality)
  )
}

#' Participant class
#'
#' Class for Participant variables
#' @slot name Name of Participant, corresponds to column name if assigning data
#' @slot integer Integer for cardinality, optional. Only required if no data is assigned
#' @keywords
#' @export
#' @examples
#' Participant()
Participant <- setClass("Participant",
    slot = c(
      name = "character",
      cardinality = "integer"
    ),
    contains = "Unit",
    prototype = list(
      name = NULL,
      cardinality = as.integer(0)
    )
)
# Helper to create instances of the Participant class
Participant <- function(name,
                 cardinality=as.integer(0)) {
  new("Participant",
      name = name,
      cardinality = as.integer(cardinality)
  )
}

#' Measure class
#'
#' Super class for measure variables
#' Not called directly. Measures are declared through Units.
#' @keywords
#' @examples
#' Measure()
Measure <- setClass("Measure",
    slot = c(
        unit = "Unit",
        number_of_instances = "integerORAbstractVariableORAtMostORPer"
    ),
    contains = "AbstractVariable"
)


#' Numeric class
#'
#' Class for Numeric measures, inherits from Measure.
#' Not called directly. All measures are declared through Units.
#' @slot name Character. Name of measure, corresponds to column name in data.
#' @keywords
#' @examples
#' Numeric()
Numeric <- setClass("Numeric",
    slot = c(
        name = "character"
    ),
    contains = "Measure"
)

#' Nominal class
#'
#' Class for Nominal measures, inherits from Measure.
#' Not called directly. All measures are declared through Units.
#' @slot name Name of measure, corresponds to column name if assigning data.
#' @slot cardinality Integer for cardinality.
#' @slot categories List of categories.
#' @keywords
#' @examples
#' Nominal()
Nominal <- setClass("Nominal",
    slot = c(
        name = "character",
        cardinality = "integer",
        categories = "list",
        isInteraction = "logical"
    ),
    prototype = list(
        name = "",
        cardinality = as.integer(0),
        categories = list(),
        isInteraction = FALSE
    ),
    contains = "Measure"
)

#' Moderation Nominal class
#'
#' Class for representing Moderation (or Moderation) effects as nominal variables.
#' Not called directly. All moderations are declared through moderates.
#' @slot units List of Units, may only be one unit if the moderation is constructed from Measures from the same Unit
#' @slot name Character name (shorthand) for the interaction/moderation effect
#' @slot cardinality Integer for cardinality.
#' @slot moderators List of AbstractVariables that moderate each other
#' @slot categories List of categories that are the product of interacting the moderators.
#' @keywords
#' @examples
#' Nominal()
ModerationNominal <- setClass("ModerationNominal",
    slot = c(
        units = "list", # List of Units
        name = "character",
        cardinality = "integer",
        # categories = "list",
        moderators = "list" # List of AbstractVariables
    ),
    contains = "Measure"
)


#' Ordinal class
#'
#' Class for Ordinal measures, inherits from Measure.
#' Not called directly. All measures are declared through Units.
#' @slot name Name of measure, corresponds to column name in data.
#' @slot cardinality Integer for cardinality.
#' @slot order Ordered list of categories.
#' @keywords
#' @examples
#' Ordinal()
Ordinal <- setClass("Ordinal",
    slot = c(
        name = "character",
        order = "list",
        cardinality = "integer"
    ),
    contains = "Measure"
)

#' SetUp class
#'
#' Class for SetUp variables
#' @slot name Name of SetUp, corresponds to column name if assigning data
#' @slot order Optional. Order of categories if the SetUp variable represents an ordinal value (e.g., week of the month)
#' @slot cardinality Optional. Cardinality of SetUp variable if itrepresents a nominal or ordinal value (e.g., trial identifier)
#' @keywords
#' @export
#' @examples
#' SetUp()
SetUp <- setClass("SetUp",
    slot = c(
        name = "character",
        order = "list",
        cardinality = "integer"
    ),
    contains = "AbstractVariable",
    prototype = list(
        name = NULL,
        order = list(),
        cardinality = as.integer(0)
    )
)
# Helper to create instances of the Unit class
SetUp <- function(name,
                    order= list(),
                    cardinality=as.integer(-1)) {
  if (cardinality != -1 && length(order) != cardinality) {
      stop("If @cardinality and @order are both provided, they need to match")
  }
  new("SetUp",
      name = name,
      order = order,
      cardinality = as.integer(length(order))
  )
}
# Validator to ensure that the slots corroborate with each other
setValidity("SetUp", function(object) {
  if (length(object@order)   !=  object@cardinality) {
          stop("If @cardinality and @order are both provided, they need to match")
    } else {
    TRUE
    }
})

#' Nests class
#'
#' Class for Nesting relationships.
#' Not called directly.
#' @slot base AbstractVariable. Variable that is nested within another.
#' @slot group AbstractVariable. Variable that contains multiple instances of @slot base.
#' @keywords
#' @examples
#' Nests()
Nests <- setClass("Nests",
    slot = c(
        base = "Unit",
        group = "Unit"
    )
)

#' @import dagitty
setOldClass("dagitty")

#' ConceptualModel class
#'
#' Class for Conceptual Models
#' @keywords
#' @import dagitty
#' @export
#' @examples
#' ConceptualModel()
ConceptualModel <- setClass("ConceptualModel",
    slot = c(
      variables = "list",
      relationships = "list",
      graph = "dagitty"
    ),
    prototype = list(
      variables = NULL,
      relationships = NULL,
      graph = NULL
    ),
    contains = "dagitty"
)
# Helper to create instances of the ConceptualModel class
ConceptualModel <- function(variables=list(), relationships=list(), graph=dagitty({''})) {
  new("ConceptualModel",
      variables=variables,
      relationships=relationships,
      graph=graph)
}

setClassUnion("dfOrNull", c("list", "NULL"))

#' Design class
#'
#' Class for Study designs.
#' @slot relationships List of relationships between variables.
#' @slot ivs List of AbstractVariables. Varibale that are independent variables.
#' @slot dv AbstractVariable. Variable that is the dependent variable.
#' @slot source Data frame containing data for Design.
#' @keywords
#' @examples
#' Design()
Design <- setClass("Design",
    slot = c(
        relationships = "list",
        ivs = "list", # list of AbstractVariables
        dv = "AbstractVariable",
        source = "dfOrNull" # Should be a data.frame (with data) or NULL (no data)
    ),
    prototype = list(
        relationships = NULL,
        ivs = NULL,
        dv = NULL,
        source = NULL
    )
)
# Helper to create instances of Design
Design <- function(relationships=list(),
                    ivs=NULL,
                    dv=NULL,
                    source=NULL) {
  # Check parameters
  if (length(relationships) == 0) {
      stop("There are no relationships. Provide @relationship in order to infer a statistical model.")
  }
  if (is.null(ivs) || length(ivs) == 0) {
      stop("@ivs is not specified. Please provide at least one variable to model.")
  }
  if (is.null(dv)) {
      stop("@dv is not specified. Please provide a variable to model.")
  }

  if (is.list(ivs)) {

  }
  new("Design",
      relationships=relationships,
      ivs=ivs,
      dv=dv,
      source=source)
}

#' Compares class
#'
#' Class for comparison relationships.
#' Not called directly.
#' @slot variable AbstractVariable. Variable that is being compared.
#' @slot condition character. Condition to filter values of @slot variable on.
#' @keywords
#' @examples
#' Compares()
Compares <- setClass("Compares",
                  slot = c(
                    variable = "AbstractVariable",
                    condition = "character"
                  )
)

setClassUnion("relatesORcausesORmoderates", c("Relates", "Causes", "Moderates"))
#' Assumption class
#'
#' Class for Assumptions.
#' @slot relationship. Relationship to assume.
#' @slot conceptualModel ConceptualModel to which this Assumption belongs.
#' @keywords
#' @export
#' @examples
#' Assumption()
Assumption <- setClass("Assumption",
                        slot = c(
                          relationship = "relatesORcausesORmoderates",
                          conceptualModel = "ConceptualModel"
                        )
)
# Helper to create instances of the Assumptions class
# Used internally only
Assumption <- function(relationship,
                        conceptualModel) {
  new("Assumption",
      relationship = relationship,
      conceptualModel = conceptualModel
  )
}

#' Hypothesis class
#'
#' Class for Hypotheses.
#' @slot relationship. Relationship to hypothesize.
#' @slot conceptualModel ConceptualModel to which this Hypothesis belongs.
#' @keywords
#' @export
#' @examples
#' Hypothesis()
Hypothesis <- setClass("Hypothesis",
                       slot = c(
                         relationship = "relatesORcausesORmoderates",
                         conceptualModel = "ConceptualModel"
                       )
)
# Helper to create instances of the Hypothesis class
# Used internally only
Hypothesis <- function(relationship,
                       conceptualModel) {
  new("Hypothesis",
      relationship = relationship,
      conceptualModel = conceptualModel
  )
}

setClassUnion("numericORordinal", c("Numeric", "Ordinal"))
setClassUnion("nominalORordinal", c("Nominal", "Ordinal"))
setClassUnion("integerORnumericORcharacter", c("integer", "numeric", "character"))
setClassUnion("ComparesORComparesList", c("Compares", "list"))
