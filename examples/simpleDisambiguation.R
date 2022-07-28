library(tisaner)

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
path = "examples/json/simpleDisambiguation.json"

# Data file
dataPath = NULL
updates <- disambiguateConceptualModel(conceptualModel=cm, dv=dv, inputFilePath=path, dataPath=dataPath)

# Update DV, Update Conceptual Model
# dvUpdated <- updateDV(dv, userInput)
# cmUpdated <- updateConceptualModel(conceptualModel, cmInputs)
#
# # Make named list of values to return
# res <- list(updatedDV = dvUpdated, updatedConceptualModel = cmUpdated)
#
# dvUpdated <- updates$updatedDV
# cmUpdated <- updates$updatedConceptualModel
# browser()
