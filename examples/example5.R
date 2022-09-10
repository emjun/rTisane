## Example 4 (from summative eval Income dataset)
## Conceptual relationships: Assume Causes, Assume Relates, Hypothesize whenThen, 
## Data collection: Hierarchical nesting
## Data: [WA income data](examples/data/2019_WA_income.csv)

library(rTisane)

family <- Unit("FAMILY")
pid <- Participant("ID", nestsWithin=family)

age <- numeric(unit=pid, name="AGEP")
edu <- nominal(unit=pid, name="SCHL", cardinality=10)
sex <- nominal(unit=pid, name="SEX", cardinality=2)
income <- numeric(unit=pid, name="PINCP")

# Construct Conceptual Model
cm <- ConceptualModel()
# Specify conceptual relationships
cm <- assume(causes(age, income), cm)
cm <- hypothesize(relates(edu, income), cm)
cm <- hypothesize(whenThen(when=equals(sex, 1.0), then=increases(income)), cm)
conditions <- list(equals(sex, 1.0), increases(edu))
cm <- hypothesize(whenThen(when=conditions, then=increases(income)), cm) # Interaction

# Education is IV, Income is DV
# Need to disambiguate relationship between Education and Income, between Sex and Income in conceptual model
# Random effects:
query(conceptualModel=cm, iv=edu, dv=income) # No data