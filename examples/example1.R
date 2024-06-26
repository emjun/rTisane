## Example 1
## Relationships: Relates, Causes
## Data: data

library(rTisane)

# Construct Conceptual Model
cm <- ConceptualModel()
pid <- Participant("ID")
age <- numeric(unit=pid, name="AGEP")
edu <- nominal(unit=pid, name="SCHL", cardinality=10)
income <- numeric(unit=pid, name="PINCP")


# Specify conceptual relationships
cm <- assume(causes(age, income), cm)
cm <- hypothesize(relates(edu, income), cm)

# Education is IV, Income is DV
# Need to disambiguate relationship between Education and Income in conceptual model
query(conceptualModel=cm, iv=edu, dv=income, data="examples/data/2019_WA_income.csv")