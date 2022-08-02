library(rTisane)

# Construct Conceptual Model
cm <- ConceptualModel()
unit <- Unit("person")
measure_0 <- numeric(unit=unit, name="measure_0")
measure_1 <- numeric(unit=unit, name="measure_1")
cause_relat <- causes(measure_0, measure_1)
cm <- assume(cause_relat, cm)
# Update graph
cm@graph <- updateGraph(cm)

# JSON input file
fileName = "mainEffectsOnly.json"
path = file.path(getwd(), "examples", "json", fileName)

# Data file
dataPath = NULL
updates <- disambiguateStatisticallModel(inputFilePath="input2.json")
