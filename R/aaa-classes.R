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
#' Internal use only. Abstract super class for number values, used for numberOfInstances that a Unit has of a Measure
#' @slot value Number value
#' @keywords
#' @export NumberValue
#' @exportClass NumberValue
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
#' Exactly(as.integer(3))
Exactly <- setClass("Exactly",
    slots = c(
        value = "integer"
    ),
    prototype = list(
        value = as.integer(1)
    ),
    contains = "NumberValue"
)
# Helper to create instances of the Exactly class
Exactly <- function(value=as.integer(1)) {
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
#' AtMost(as.integer(1))
AtMost <- setClass("AtMost",
    slots = c(
        value = "integer"
    ),
    prototype = list(
        value = as.integer(1)
    ),
    contains = "NumberValue"
)
# Helper to create instances of the AtMost class
AtMost <- function(value=as.integer(1)) {
  new("AtMost",
      value = as.integer(value)
  )
}

#' Per class
#'
#' Wrapper class for ratios between number values. Extends NumberValue class.
#' @slot number NumberValue
#' @slot variable AbstractVariable that contains
#' @slot cardinality
# ' @slot numberOfInstances
#' @slot value
#' @keywords
Per <- setClass("Per",
    slots = c(
        number = "NumberValue",
        variable = "AbstractVariable",
        cardinality = "logical"
        # numberOfInstances = "logical",
        # value = "integer"
    ),
    prototype = list(
        number = NULL,
        variable = NULL,
        cardinality = TRUE
        # numberOfInstances = FALSE,
        # value = NULL
    ),
    contains = "NumberValue"
)

# Specify Union type for numberOfInstances
# https://stackoverflow.com/questions/13002200/s4-classes-multiple-types-per-slot
setClassUnion("numericORAbstractVariableORAtMostORPer", c("numeric", "AbstractVariable", "AtMost", "Per"))
setClassUnion("integerORPer", c("integer", "Per"))
setClassUnion("missingORintegerORAbstractVariableORAtMostORPer", c("missing", "numericORAbstractVariableORAtMostORPer"))

#' Dataset class
#'
#' Class for Dataset
#' @slot df DataFrame.
#' @keywords
#' @export Dataset
#' @exportClass Dataset
Dataset <- setClass("Dataset",
    slots = c(
      df = "character"
    ),
    prototype = list(
      df = NULL
    )
)

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

setClassUnion("AbstractVariableORListORNull", c("AbstractVariable", "list", "NULL"))
#' Unit class
#'
#' Class for Unit variables
#' @slot name Name of Unit, corresponds to column name if assigning data
#' @slot integer Integer for cardinality, optional. Only required if no data is assigned
#' @slot nestsWithin Unit if this unit is nested within another (e.g., hierarchical relationship). Optional.
#' @keywords
#' @export
Unit <- setClass("Unit",
    slot = c(
        name = "character",
        cardinality = "integer",
        nestsWithin = "AbstractVariableORListORNull"
    ),
    contains = "AbstractVariable",
    prototype = list(
        name = NULL,
        cardinality = as.integer(0),
        nestsWithin = NULL
    )

)
# Helper to create instances of the Unit class
Unit <- function(name,
                   cardinality=as.integer(0),
                   nestsWithin=NULL) {
  # Check that the nesting variables are Units
  if (is(nestsWithin, "list")) {
    for (fam in nestsWithin) {
      stopifnot(!is.null(fam))
      stopifnot(is(fam, "Unit"))
    }
  }
  new("Unit",
      name = name,
      cardinality = as.integer(cardinality),
      nestsWithin = nestsWithin
  )
}

#' Participant class
#'
#' Class for Participant variables
#' @slot name Name of Participant, corresponds to column name if assigning data
#' @slot integer Integer for cardinality, optional. Only required if no data is assigned
#' @keywords
#' @export
Participant <- setClass("Participant",
    slot = c(
      name = "character",
      cardinality = "integer",
      nestsWithin = "AbstractVariableORListORNull"
    ),
    contains = "Unit",
    prototype = list(
      name = NULL,
      cardinality = as.integer(0),
      nestsWithin = NULL
    )
)
# Helper to create instances of the Participant class
Participant <- function(name,
                 cardinality=as.integer(0),
                 nestsWithin=NULL) {
  # Check that the nesting variables are Units
  if (is(nestsWithin, "list")) {
    for (fam in nestsWithin) {
      stopifnot(!is.null(fam))
      stopifnot(is(fam, "Unit"))
    }
  }
  new("Participant",
      name = name,
      cardinality = as.integer(cardinality),
      nestsWithin = nestsWithin
  )
}

#' Measure class
#'
#' Super class for measure variables
#' Not called directly. Measures are declared through Units.
#' @keywords
Measure <- setClass("Measure",
    slot = c(
        unit = "Unit",
        numberOfInstances = "numericORAbstractVariableORAtMostORPer"
    ),
    contains = "AbstractVariable"
)

#' Interacts class
#'
#' Class for representing Interacts"effects.
#' Not called directly. All interactions are declared through interacts.
#' @slot name Character name (shorthand) for the interaction effect
#' @slot units List of Units, may only be one unit if the moderation is constructed from Measures from the same Unit
# #' @slot cardinality Integer for cardinality.
#' @slot variables List of AbstractVariables or UnobservedVariables that interact with each other
#' @keywords
Interacts <- setClass("Interacts",
    slot = c(
        name = "character",
        units = "list", # List of Units
        variables = "list", # List of AbstractVariables
        dv = "AbstractVariable" # dependent or outcome variable for 
    ),
    contains = "AbstractVariable"
)

#' Continuous class
#' 
#' Class for Continuous measures (e.g., scores, temperature, time)
#' Inherits from Measure.
#' @slot name character. Name of measure, corresponds to column name in data.
# @slot baseline numeric. Optional. By default, 0.
#' @keywords
Continuous <- setClass("Continuous",
    slot = c(
        name = "character"
        # baseline = "numeric",
        # skew = "character"
    ),
    contains = "Measure"
)

#' Counts class
#'
#' Class for Counts
#' Inherits from Measure. 
#' @slot name character. Name of measure, corresponds to column name in data.
# @slot baseline numeric. Optional. By default, 0.
#' @keywords
Counts <- setClass("Counts",
    slot = c(
        name = "character" 
        # baseline = "numeric",
    ),
    contains = "Measure"
)

#' Categories class
#'
#' Class for (ordered, unordered) Categories
#' Inherits from Measure. 
#' @slot name character. Name of measure, corresponds to column name in data.
# @slot baseline character. Specific category that the other categories in this measure are compared against. If @param order is provided, @param baseline is set to the lowest (left-most) value. Otherwise, by default, the first value in the dataset; `baseline` is useful for `whenThen` statements
#' @keywords
Categories <- setClass("Categories",
    slot = c(
    name = "character"
    ),
    contains = "Measure"
)

#' Unordered Categories class
#'
#' Class for unordered Categories
#' Inherits from Measure. 
#' @slot name character. Name of measure, corresponds to column name in data.
#' @slot cardinality integer. Number of unique categories. If @param order is provided, @param cardinality is not needed and will be set to the length of @param order
# @slot baseline character. Specific category that the other categories in this measure are compared against. If @param order is provided, @param baseline is set to the lowest (left-most) value. Otherwise, by default, the first value in the dataset; `baseline` is useful for `whenThen` statements
#' @keywords
UnorderedCategories <- setClass("UnorderedCategories",
    slot = c(
        name = "character",
        cardinality = "integer"
    ),
    contains = "Categories"
)

setClassUnion("listORNULL", c("list", "NULL"))
#' Ordered Categories class
#'
#' Class for ordered Categories
#' Inherits from Measure. 
#' @slot name character. Name of measure, corresponds to column name in data.
#' @slot cardinality integer. Number of unique categories. If @param order is provided, @param cardinality is not needed and will be set to the length of @param order
#' @slot order list. Optional. List of categories in order from "lowest" to "highest"
# @slot baseline character. Specific category that the other categories in this measure are compared against. If @param order is provided, @param baseline is set to the lowest (left-most) value. Otherwise, by default, the first value in the dataset; `baseline` is useful for `whenThen` statements
#' @keywords
OrderedCategories <- setClass("OrderedCategories",
    slot = c(
    name = "character",
    cardinality = "integer",
    order = "listORNULL"
    ),
    contains = "Categories"
)

#' Time class
#'
#' Class for Time variables
#' @slot name Name of Time, corresponds to column name if assigning data
#' @slot order Optional. Order of categories if the Time variable represents an ordinal value (e.g., week of the month)
#' @slot cardinality Optional. Cardinality of Time variable if itrepresents a nominal or ordinal value (e.g., trial identifier)
#' @keywords
#' @export
Time <- setClass("Time",
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
Time <- function(name,
                    order= list(),
                    cardinality=as.integer(0)) {
  if (cardinality == 0) {
    if (length(order) == 0) {
        stop("Please provide at least either @cardinality or @order.")
    }
    new("Time",
      name = name,
      order = order,
      cardinality = as.integer(length(order))
    )
  } else {
    stopifnot(cardinality > 0)
    if (length(order) > 0) {
        if (length(order) != cardinality) {
            stop("If @cardinality and @order are both provided, they need to match")
        }
    }
    new("Time",
            name = name,
            order = order,
            cardinality = as.integer(cardinality)
    )
    # if(length(order) == cardinality) {
    #     new("Time",
    #         name = name,
    #         order = order,
    #         cardinality = cardinality
    #     )
    # } else {
    #     stopifnot(length(order) == 0)
    #     new("Time",
    #         name = name,
    #         order = order,
    #         cardinality = cardinality
    #     )
    # }
  }

}

#' Compares class
#'
#' Class for comparison relationships.
#' Not called directly.
#' @slot variable AbstractVariable. Variable that is being compared.
#' @slot condition character. Condition to filter values of @slot variable on.
#' @keywords
Compares <- setClass("Compares",
                  slot = c(
                    variable = "AbstractVariable",
                    condition = "character"
                  )
)

setClassUnion("AbstractVariableORUnobservedVariable", c("AbstractVariable", "UnobservedVariable"))
setClassUnion("ComparesORNULL", c("Compares", "NULL"))
#' Relates class
#'
#' Class for Relates relationships.
#' Not called directly.
#' @slot lhs AbstractVariable. A variable.
#' @slot rhs AbstractVariable. A variable.
#' @keywords
Relates <- setClass("Relates",
                   slot = c(
                     lhs = "AbstractVariableORUnobservedVariable",
                     rhs = "AbstractVariableORUnobservedVariable",
                     when = "ComparesORNULL",
                     then = "ComparesORNULL"
                   )
)

#' Causes class
#'
#' Class for Causes relationships.
#' Not called directly.
#' @slot cause AbstractVariable. Variable that causes another.
#' @slot effect AbstractVariable. Variable that is caused by @slot cause.
#' @keywords
Causes <- setClass("Causes",
    slot = c(
        cause = "AbstractVariableORUnobservedVariable",
        effect = "AbstractVariableORUnobservedVariable",
        when = "ComparesORNULL",
        then = "ComparesORNULL"
    )
)
#' Nests class
#'
#' Class for Nesting relationships.
#' Not called directly.
#' @slot base AbstractVariable. Variable that is nested within another.
#' @slot group AbstractVariable. Variable that contains multiple instances of @slot base.
#' @keywords
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

setClassUnion("relatesORcausesORInteracts", c("Relates", "Causes", "Interacts"))
#' Assumption class
#'
#' Class for Assumptions.
#' @slot relationship. Relationship to assume.
#' @slot conceptualModel ConceptualModel to which this Assumption belongs.
#' @keywords
#' @export
Assumption <- setClass("Assumption",
                        slot = c(
                          relationship = "relatesORcausesORInteracts",
                          conceptualModel = "ConceptualModel"
                        ),
                        prototype = list(
                            relationship = new("Relates", lhs=Unobserved(), rhs=Unobserved()),
                            conceptualModel = ConceptualModel()
                        )
)
# Helper to create instances of the Assumptions class
# Used internally only
Assumption <- function(relationship=new("Relates", lhs=Unobserved(), rhs=Unobserved()),
                        conceptualModel=ConceptualModel()) {
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
Hypothesis <- setClass("Hypothesis",
                       slot = c(
                         relationship = "relatesORcausesORInteracts",
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


#' RandomEffect class.
#'
#' Abstract super class for declaring random effects.
#' @keywords
#' @export
RandomEffect <- setClass("RandomEffect")

#' RandomSlope class.
#'
#' Class for declaring random slopes
#' @slot variable Measure whose observations we want to calculate a slope for.
#' @slot group Unit whose observations we want to pool.
#' @keywords
#' @export
RandomSlope <- setClass("RandomSlope",
    slots = c(
            variable = "Measure",
            group = "Unit"
        )
)
# Helper to create instances of the RandomSlope class
# Used internally only
RandomSlope <- function(variable, group) {
    new("RandomSlope",
        variable=variable,
        group=group
    )
}

setClassUnion("UnitORTime", c("Unit", "Time"))
#' RandomIntercept class.
#'
#' Class for declaring random intercepts
#' @slot group Unit whose observations we want to pool.
#' @keywords
#' @export
RandomIntercept <- setClass("RandomIntercept",
    slots = c(
            group = "UnitORTime"
        )
)
# Helper to create instances of the RandomIntercept class
# Used internally only
RandomIntercept <- function(group) {
    new("RandomIntercept",
        group=group
    )
}

# setClassUnion("numericORordinal", c("Numeric", "Ordinal"))
# setClassUnion("nominalORordinal", c("Nominal", "Ordinal"))
setClassUnion("integerORnumericORcharacter", c("integer", "numeric", "character"))
setClassUnion("ComparesORComparesList", c("Compares", "list"))
setClassUnion("ContinuousORCountsORCategories", c("Continuous", "Counts", "Categories"))
setClassUnion("characterORDataframeORnull", c("character", "data.frame", "NULL"))
setClassUnion("missingORCharacterORDataframe", c("missing", "character", "data.frame"))
