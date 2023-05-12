# library(rTisane)

# Construct Conceptual Model
cm <- ConceptualModel()
unit <- Unit("person")
measure_0 <- continuous(unit=unit, name="measure_0")
measure_1 <- continuous(unit=unit, name="measure_1")
ambig_relat <- relates(measure_0, measure_1)
cm <- assume(cm, ambig_relat)

# Update graph
# cm@graph <- updateGraph(cm)

# Refine and Disambiguate Conceptual Model
updatedCM <- checkAndRefineConceptualModel(conceptualModel=cm)