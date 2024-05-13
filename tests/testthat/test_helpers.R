library(rTisane)

test_that("toString for Relates works properly", {
    participant <- Participant("pid")
    measure_0 <- continuous(unit=participant, name="measure_0")
    measure_1 <- continuous(unit=participant, name="measure_1")
    measure_2 <- continuous(unit=participant, name="measure_2")
    measure_3 <- continuous(unit=participant, name="measure_3")
    u_0 <- Unobserved()
    u_1 <- Unobserved()

    # Relates involving measures only
    ambig_relat <- relates(measure_0, measure_1)

    str <- toString(ambig_relat)
    expect_equal(str, "measure_0 and measure_1 are related")
})

test_that("toString for Causes works properly", {
    participant <- Participant("pid")
    measure_0 <- continuous(unit=participant, name="measure_0")
    measure_1 <- continuous(unit=participant, name="measure_1")
    measure_2 <- continuous(unit=participant, name="measure_2")
    measure_3 <- continuous(unit=participant, name="measure_3")
    u_0 <- Unobserved()
    u_1 <- Unobserved()

    # Relates involving measures only
    cause_relat <- causes(measure_0, measure_1)

    str <- toString(cause_relat)
    expect_equal(str, "measure_0 causes measure_1")
})
# test_that("toString for Assumption works properly", {
#     participant <- Participant("pid")
#     measure_0 <- continuous(unit=participant, name="measure_0")
#     measure_1 <- continuous(unit=participant, name="measure_1")
#     measure_2 <- continuous(unit=participant, name="measure_2")
#     measure_3 <- continuous(unit=participant, name="measure_3")
#     u_0 <- Unobserved()
#     u_1 <- Unobserved()

#     # Relates involving measures only
#     ambig_relat <- relates(measure_0, measure_1)

#     cm <- ConceptualModel()
#     assump <- assume(cm, ambig_relat)

#     str <- toString(assump)
#     expect_equal(str, "Assume measure_0 and measure_1 are related")
# })

# test_that("toString for Hypothesize works properly", {
#     participant <- Participant("pid")
#     measure_0 <- continuous(unit=participant, name="measure_0")
#     measure_1 <- continuous(unit=participant, name="measure_1")
#     measure_2 <- continuous(unit=participant, name="measure_2")
#     measure_3 <- continuous(unit=participant, name="measure_3")
#     u_0 <- Unobserved()
#     u_1 <- Unobserved()

#     # Relates involving measures only
#     cause_relat <- causes(measure_0, measure_1)

#     cm <- ConceptualModel()
#     hypo <- hypothesize(cm, cause_relat)

#     str <- toString(hypo)
#     expect_equal(str, "Hypothesize measure_0 causes measure_1")
# })
