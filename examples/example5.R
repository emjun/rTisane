## Example 5 (from summative eval Income dataset)
## Conceptual relationships: Assume Causes, Assume Relates, Hypothesize whenThen,
## Data collection: Hierarchical nesting
## Data: [WA income data](examples/data/2019_WA_income.csv)

library(rTisane)

pid <- Participant("ID")

age <- continuous(unit=pid, name="AGEP")
edu <- categories(unit=pid, name="SCHL", cardinality=10)
sex <- categories(unit=pid, name="SEX", cardinality=2)
income <- continuous(unit=pid, name="PINCP")

# Construct Conceptual Model
cm <- ConceptualModel() %>%
# Specify conceptual relationships
  assume(causes(age, income)) %>%
  hypothesize(relates(edu, income)) %>%
  hypothesize(relates(sex, income, when=equals(sex, 1.0), then=increases(income)))
  # conditions <- list(equals(sex, 1.0), increases(edu))
  # cm <- hypothesize(whenThen(when=conditions, then=increases(income)), cm)

# Education is IV, Income is DV
# Need to disambiguate relationship between Education and Income, between Sex and Income in conceptual model
# Random effects:
query(conceptualModel=cm, iv=edu, dv=income) # No data
