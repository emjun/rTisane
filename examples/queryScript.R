library(tisaner)

cm <- ConceptualModel()

unit <- Unit("person")
measure_0 <- numeric(unit=unit, name="measure_0")
measure_1 <- numeric(unit=unit, name="measure_1")

cause_relat <- causes(measure_0, measure_1)
cm <- assume(cause_relat, cm)

query(conceptualModel = cm, iv = measure_0, dv = measure_1)


# Read in an input.json
