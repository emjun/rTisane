#' AbstractVariable Class
#'
#' Abstract super class for declaring variables
#' @slot name Name of variable, which should correspond with the column name for variable's data (must be in long format)
#' @slot relationships List of relationships this variable has with other variables
#' @keywords
#' @export AbstractVariable
#' @examples
#' AbstractVariable()
AbstractVariable <- setClass("AbstractVariable", 
    slots = c(
        name = "character", relationships = "list"
    ),
    prototype = list(
        name = NULL,
        relationships = NULL
    )
)

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
    )
)

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
#' Associates()
Associates <- setClass("Associates", 
    slot = c(
        lhs = "AbstractVariable",
        rhs = "AbstractVariable"
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
        cause = "AbstractVariable", 
        effect = "AbstractVariable"
    )
)


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
        repetitions = "NumberValue", 
        according_to = "AbstractVariable"
    )
)


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
    contains = "AbstractVariable"
)

#' Measure class 
#'
#' Super class for measure variables
#' Not called directly. Measures are declared through Units. 
#' @keywords
#' @examples
#' Measure()
Measure <- setClass("Measure", 
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
        cardinality = "integer", 
        order = "list"
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
    contains = "AbstractVariable"
)

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