## Example 2 (from summative eval Income dataset)
## Relationships: Assume Causes, Assume Relates, Hypothesize whenThen
## Data: [WA income data](examples/data/2019_WA_income.csv)

library(magrittr)
library(rTisane)

pid <- Participant("ID")
age <- numeric(unit=pid, name="AGEP")
edu <- nominal(unit=pid, name="SCHL", cardinality=10)
sex <- nominal(unit=pid, name="SEX", cardinality=2)
income <- numeric(unit=pid, name="PINCP")

# Construct Conceptual Model
cm <- ConceptualModel() %>%
    # Specify conceptual relationships
    assume(causes(age, income)) %>%
    hypothesize(relates(edu, income)) %>%
    hypothesize(whenThen(when=equals(sex, 1.0), then=increases(income)))

# Education is IV, Income is DV
# Need to disambiguate relationship between Education and Income, between Sex and Income in conceptual model
query(conceptualModel=cm, iv=edu, dv=income, data="examples/data/2019_WA_income.csv")
