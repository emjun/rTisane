library(rTisane)

cm <- ConceptualModel()

unit <- Unit("person")
measure_0 <- numeric(unit=unit, name="measure_0")
measure_1 <- numeric(unit=unit, name="measure_1")

relat <- relates(measure_0, measure_1)
cm <- assume(relat, cm)

# Update graph
cm@graph <- updateGraph(cm)

# Output json
path = file.path(getwd(), "examples/json/simpleDisambiguation.json")
generateDVConceptualModelJSON(cm, measure_1, path)
