library(tisaner)
library(dagitty)

# Construct Conceptual Model
cm <- ConceptualModel()
unit <- Unit("person")
measure_0 <- numeric(unit=unit, name="measure_0")
measure_1 <- numeric(unit=unit, name="measure_1")
# Measure 1 is DV
dv = measure_1

# Specify conceptual relationships
relat <- relates(measure_0, measure_1)
cm <- assume(relat, cm)

# Update graph
cm@graph <- updateGraph(cm)
# plot(graphLayout(cm@graph))

# JSON input file
path = "examples/json/simpleDisambiguation.json"

# Data file
dataPath = NULL
updates <- disambiguateConceptualModel(conceptualModel=cm, dv=dv, inputFilePath=path, dataPath=dataPath)

# Update DV, Update Conceptual Model
dvUpdated <- updateDV(dv, updates)
cmUpdated <- updateConceptualModel(cm, updates)

# For debugging
plot(graphLayout(cmUpdated@graph))
