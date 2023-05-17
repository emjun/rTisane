library(rTisane)

pid <- Participant("ID")

age <- continuous(unit=pid, name="AGEP")
edu <- categories(unit=pid, name="SCHL", cardinality=10)
sex <- categories(unit=pid, name="SEX", cardinality=2)
income <- continuous(unit=pid, name="PINCP")

cm <- ConceptualModel() %>%
# Specify conceptual relationships
  assume(causes(age, income)) %>%
#   hypothesize(causes(edu, age)) %>%
  hypothesize(causes(income, age))
  
updatedCM <- checkAndRefineConceptualModel(conceptualModel=cm)
stopifnot(length(updatedCM@relationships) != 1)
print(updatedCM@graph)