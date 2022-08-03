## Example Errors
## Fail due to initial conceptual checks, never gets to query stage

library(rTisane)

# Construct Conceptual Model
cm <- ConceptualModel()
unit <- Unit("unit")
measure_0 <- numeric(unit=unit, name="measure_0")
measure_1 <- numeric(unit=unit, name="measure_1")
measure_2 <- numeric(unit=unit, name="measure_2")

# Specify conceptual relationships
cr <- causes(measure_0, measure_1)
cm <- hypothesize(cr, cm)

# IV is not in conceptual model
query(conceptualModel=cm, iv=measure_2, dv=measure_1)

# DV is not in conceptual model
query(conceptualModel=cm, iv=measure_0, dv=measure_2)

# Empty conceptual model (therefore, IV and DV not in conceptual model)
cm <- ConceptualModel()
query(conceptualModel=cm, iv=measure_0, dv=measure_1)

# DV causes IV
cr <- causes(measure_1, measure_0)
cm <- hypothesize(cr, cm)
query(conceptualModel=cm, iv=measure_0, dv=measure_1)

# Graph is cyclic
cr <- causes(measure_0, measure_1)
cr <- causes(measure_1, measure_2)
cr <- causes(measure_2, measure_0)
cm <- hypothesize(cr, cm)
query(conceptualModel=cm, iv=measure_0, dv=measure_1)