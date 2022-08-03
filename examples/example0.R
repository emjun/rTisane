## Example 0 
## Relationships: Causes only
## Data: No data

library(rTisane)

# Construct Conceptual Model
cm <- ConceptualModel()
unit <- Unit("unit")
measure_0 <- numeric(unit=unit, name="measure_0")
measure_1 <- numeric(unit=unit, name="measure_1")

# Specify conceptual relationships
cr <- causes(measure_0, measure_1)
cm <- hypothesize(cr, cm)

# Measure 0 is IV, Measure 1 is DV
# Don't need to disambiguate conceptual model
query(conceptualModel=cm, iv=measure_0, dv=measure_1)