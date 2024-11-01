library(rTisane)

test_that("Finding cycles works properly", {
    pid <- Participant("ID")

    age <- continuous(unit=pid, name="AGEP")
    edu <- categories(unit=pid, name="SCHL", cardinality=10)
    sex <- categories(unit=pid, name="SEX", cardinality=2)
    income <- continuous(unit=pid, name="PINCP")

    cm <- ConceptualModel() %>%
    # Specify conceptual relationships
    assume(causes(age, income)) %>%
    assume(causes(income, age)) %>%
    hypothesize(causes(edu, age)) %>%
    hypothesize(causes(income, edu))

    cm@graph <- rTisane:::updateGraph(cm)
    cycles <- rTisane:::findCycles(cm)
    expect_equal(length(cycles), 2)

    cm <- ConceptualModel() %>%
    # Specify conceptual relationships
    assume(causes(age, income)) %>%
    hypothesize(causes(income, age))

    cm@graph <- rTisane:::updateGraph(cm)
    cycles <- rTisane:::findCycles(cm)
    expect_equal(length(cycles), 1)
})