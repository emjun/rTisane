# library(rTisane)

# Construct Conceptual Model
cm <- ConceptualModel()
unit <- Unit("person")
measure_0 <- continuous(unit=unit, name="measure_0")
measure_1 <- continuous(unit=unit, name="measure_1")
cause_relat <- causes(measure_0, measure_1)
cm <- assume(cm, cause_relat)
# Update graph
cm@graph <- updateGraph(cm)

# JSON input file
# fileName = "simpleInput.json"
fileName = "test-new-input.json"
path = file.path(getwd(), fileName)

# Data file
dataPath = NULL
# updates <- disambiguateConceptualModel(conceptualModel=cm, iv=iv, dv=dv, inputFilePath=path)
updates <- refineConceptualModel(conceptualModel=cm)
dvUpdated <- updates$updatedDV
cmUpdated <- updates$updatedConceptualModel
