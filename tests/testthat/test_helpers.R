library(rTisane)

test_that("pretty_print for Relates works properly", {
    participant <- Participant("pid")
    measure_0 <- continuous(unit=participant, name="measure_0")
    measure_1 <- continuous(unit=participant, name="measure_1")
    measure_2 <- continuous(unit=participant, name="measure_2")
    measure_3 <- continuous(unit=participant, name="measure_3")
    u_0 <- rTisane:::Unobserved()
    u_1 <- rTisane:::Unobserved()

    # Relates involving measures only
    ambig_relat <- relates(measure_0, measure_1)

    str <- pretty_print(ambig_relat)
    expect_equal(str, "measure_0 and measure_1 are related")
})

test_that("pretty_print for Causes works properly", {
    participant <- Participant("pid")
    measure_0 <- continuous(unit=participant, name="measure_0")
    measure_1 <- continuous(unit=participant, name="measure_1")
    measure_2 <- continuous(unit=participant, name="measure_2")
    measure_3 <- continuous(unit=participant, name="measure_3")
    u_0 <- rTisane:::Unobserved()
    u_1 <- rTisane:::Unobserved()

    # Relates involving measures only
    cause_relat <- causes(measure_0, measure_1)

    str <- pretty_print(cause_relat)
    expect_equal(str, "measure_0 causes measure_1")
})
# test_that("pretty_print for Assumption works properly", {
#     participant <- Participant("pid")
#     measure_0 <- continuous(unit=participant, name="measure_0")
#     measure_1 <- continuous(unit=participant, name="measure_1")
#     measure_2 <- continuous(unit=participant, name="measure_2")
#     measure_3 <- continuous(unit=participant, name="measure_3")
#     u_0 <- rTisane:::Unobserved()
#     u_1 <- rTisane:::Unobserved()

#     # Relates involving measures only
#     ambig_relat <- relates(measure_0, measure_1)

#     cm <- ConceptualModel()
#     assump <- assume(cm, ambig_relat)

#     str <- rTisane::pretty_print(assump)
#     expect_equal(str, "Assume measure_0 and measure_1 are related")
# })

# test_that("pretty_print for Hypothesize works properly", {
#     participant <- Participant("pid")
#     measure_0 <- continuous(unit=participant, name="measure_0")
#     measure_1 <- continuous(unit=participant, name="measure_1")
#     measure_2 <- continuous(unit=participant, name="measure_2")
#     measure_3 <- continuous(unit=participant, name="measure_3")
#     u_0 <- rTisane:::Unobserved()
#     u_1 <- rTisane:::Unobserved()

#     # Relates involving measures only
#     cause_relat <- causes(measure_0, measure_1)

#     cm <- ConceptualModel()
#     hypo <- hypothesize(cm, cause_relat)

#     str <- rTisane::pretty_print(hypo)
#     expect_equal(str, "Hypothesize measure_0 causes measure_1")
# })
