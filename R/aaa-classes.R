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

#' Associates class
#'
#' Class for Associates relationships.
#' Not called directly.
#' @slot lhs AbstractVariable. A variable that is associated with another.
#' @slot rhs AbstractVariable. A variable that is associated with another.
#' @keywords
#' @examples
#' Associates(measure_0, measure_1)
Associates <- setClass("Associates",
    slot = c(
        lhs = "AbstractVariable",
        rhs = "AbstractVariable"
    )
)
# Helper to create instances of the Associates class
Associates <- function(lhs,
                   rhs) {
  new("Associates",
      lhs = lhs,
      rhs = rhs
  )
}

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
        cause = "AbstractVariable",
        effect = "AbstractVariable"
    )
)

#' Moderates class
#'
#' Class for Associates relationships.
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
#' @slot isInteraction Logical. True if variable is an interaction. False otherwise.
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


setClassUnion("DF_OR_NULL", c("list", "NULL"))

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
        source = "DF_OR_NULL" # Should be a data.frame (with data) or NULL (no data)
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