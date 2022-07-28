library(tisaner)

cm <- ConceptualModel()

unit <- Unit("person")
measure_0 <- numeric(unit=unit, name="measure_0")
measure_1 <- numeric(unit=unit, name="measure_1")

cause_relat <- causes(measure_0, measure_1)
cm <- assume(cause_relat, cm)

# Update graph
cm@graph <- updateGraph(cm)

# Output json
outputJSON(cm, measure_1, "simpleInput.json")
