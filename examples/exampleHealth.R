## Example 4 (from summative eval Income dataset)
## Conceptual relationships: Assume Causes, Assume Relates, Hypothesize whenThen,
## Data collection: Hierarchical nesting
## Data: [WA income data](examples/data/2019_WA_income.csv)

library(rTisane)

pid <- Unit("Patient")

income <- categories(unit=pid, name="Income", order=list("low","high"))
edu <- categories(unit=pid, name="Educ", order=list(1, 2, 3, 4, 5))
sex <- categories(unit=pid, name="Sex", cardinality=2)
spending <- continuous(unit=pid, name="Spending")

# Construct Conceptual Model
cm <- ConceptualModel() %>%
assume(causes(edu, spending)) %>%
assume(relates(sex, spending)) %>% #, when=equals(sex, 'Female'), then=increases(spending))) %>%
hypothesize(causes(income, spending))

query(cm, iv=income, dv=spending) #, data="health_data.csv")
