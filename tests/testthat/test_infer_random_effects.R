library(rTisane)

test_that("Random effects for repeated measures inferred properly", {

    ## Example without NO random effects
    pid <- Participant("ID")
    condition <- condition(unit=pid, name="condition", cardinality=2) # numberOfInstances=1
    accuracy <- numeric(unit=pid, name="accuracy") # numberOfInstances=1

    confounders = list()
    interactions = list()
    conceptualModel = NULL
    iv = condition
    dv = accuracy
    randomEffects <- inferRandomEffects(confounders=confounders, interactions=interactions, conceptualModel=conceptualModel, iv=iv, dv=dv)

    expect_type(randomEffects, "list")
    expect_length(randomEffects, 0)

    ## Example with NO random effects
    pid <- Participant("ID")
    income <- numeric(unit=pid, name="PINCP") # One for each year
    age <- numeric(unit=pid, name="AGEP")
    edu <- nominal(unit=pid, name="SCHL", cardinality=10)
    # sex <- nominal(unit=pid, name="SEX", cardinality=2)

    confounders = list()
    interactions = list()
    conceptualModel = NULL
    iv = edu
    dv = income
    randomEffects <- inferRandomEffects(confounders=confounders, interactions=interactions, conceptualModel=conceptualModel, iv=iv, dv=dv)

    expect_type(randomEffects, "list")
    expect_length(randomEffects, 0) # No random effects necessary!


    ## Example with multiple observations for an IV, multiple observations for a DV
    pid <- Participant("ID")
    condition <- condition(unit=pid, name="condition", cardinality=2, numberOfInstances=2)
    accuracy <- numeric(unit=pid, name="accuracy", numberOfInstances=per(1, condition))

    confounders = list()
    interactions = list()
    conceptualModel = NULL
    iv = condition
    dv = accuracy
    randomEffects <- inferRandomEffects(confounders=confounders, interactions=interactions, conceptualModel=conceptualModel, iv=iv, dv=dv)

    expect_type(randomEffects, "list")
    expect_length(randomEffects, 1)
    ri = randomEffects[[1]]
    expect_s4_class(ri, "RandomIntercept")

    ## Example with one observation for IV, multiple observations for a DV
    pid <- Participant("ID")
    year <- Time(name="year", cardinality=5)
    income <- numeric(unit=pid, name="PINCP", numberOfInstances=per(1, year)) # One for each year
    age <- numeric(unit=pid, name="AGEP")
    edu <- nominal(unit=pid, name="SCHL", cardinality=10)
    # sex <- nominal(unit=pid, name="SEX", cardinality=2)

    confounders = list()
    interactions = list()
    conceptualModel = NULL
    iv = edu
    dv = income
    randomEffects <- inferRandomEffects(confounders=confounders, interactions=interactions, conceptualModel=conceptualModel, iv=iv, dv=dv)

    expect_type(randomEffects, "list")
    expect_length(randomEffects, 2) # Correct? Should this be 1? 
    expect_s4_class(randomEffects[[1]], "RandomIntercept")
    hasPaticipantRI = FALSE
    hasYearRI = FALSE

    for (re in randomEffects) {
        expect_s4_class(re, "RandomIntercept")
        if (is(re@group, "Unit")) {
            expect_equal(re@group, pid)
            hasParticipantRI = TRUE
        } else {
            stopifnot(is(re@group, "Time"))
            expect_equal(re@group, year)
            hasYearRI = TRUE
        }
    }
    expect_true(hasParticipantRI)
    expect_true(hasYearRI)


    # Does not make sense to have multiple observations for an IV and only one observation for a DV

    ## Examples/tests from Tisane tests and examples
    u = Unit("Unit")
    time = Time("Time", order=list(1, 2, 3, 4, 5))
    feed = ordinal(unit=u, name="Feed", order=list("A", "B", "C")) # numberOfInstances = 1
    dv = numeric(unit=u, "Dependent_variable", numberOfInstances=per(1, time))

    confounders = list()
    interactions = list()
    conceptualModel = NULL
    iv = feed
    dv = dv
    randomEffects <- inferRandomEffects(confounders=confounders, interactions=interactions, conceptualModel=conceptualModel, iv=iv, dv=dv)
    # browser()

    ## START HERE: Time is a within-subjets variable here!

    expect_length(randomEffects, 2)
    hasUnitRI = FALSE
    hasTimeRI = FALSE

    for (re in randomEffects) {
        expect_s4_class(re, "RandomIntercept")
        if (is(re@group, "Unit")) {
            expect_equal(re@group, u)
            hasUnitRI = TRUE
        } else {
            stopifnot(is(re@group, "Time"))
            expect_equal(re@group, time)
            hasTimeRI = TRUE
        }
    }
    expect_true(hasUnitRI)
    expect_true(hasTimeRI)
})

test_that("Random effects for nesting relationships inferred properly",
{
    ## Original source: Lauridsen, C., Højsgaard, S.,Sørensen, M.T. C. (1999) Influence of Dietary Rapeseed Oli, Vitamin E, and Copper on Performance and Antioxidant and Oxidative Status of Pigs. J. Anim. Sci.77:906-916
    litter = Unit("Litter", cardinality=25)
    pig = Unit("Pig", cardinality=69, nestsWithin=litter)
    week = Time("week", order=list(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12), cardinality=12)
    weight = numeric(unit=pig, name="Weight", numberOfInstances=per(1, week))

    confounders = list()
    interactions = list()
    conceptualModel = NULL
    iv = week
    dv = weight
    randomEffects <- inferRandomEffects(confounders=confounders, interactions=interactions, conceptualModel=conceptualModel, iv=iv, dv=dv)

    expect_length(randomEffects, 3)
    hasLitterRI = FALSE
    hasPigRI = FALSE
    hasWeekRI = FALSE
    for (re in randomEffects) {
        expect_s4_class(re, "RandomIntercept")
        if (identical(re@group, litter)) {
            hasLitterRI = TRUE
        }
        if (identical(re@group, pig)) {
            hasPigRI = TRUE 
        }
        if (identical(re@group, week)) {
            hasWeekRI = TRUE
        }
    }
    expect_true(hasLitterRI)
    expect_true(hasPigRI)
    expect_true(hasWeekRI)

    ## Example from Cohen, Cohen, West, Aiken 2003. 
    group = Unit("group", cardinality=40)  # 40 groups
    adult = Participant("adult", cardinality=386, nestsWithin=group)  # 386 adults
    # Each adult has a value for motivation, which is ordinal
    motivationLevel = ordinal(adult, "motivation", order=list(1, 2, 3, 4, 5, 6))
    poundsLost = numeric(adult, "pounds_lost")
    
    # Each group has one of two approaches to weight loss they promote
    treatment = condition(group, "treatment", cardinality=2)  # 2 approaches to weight loss ("Control" and "Treatment")

    confounders = list(motivationLevel)
    interactions = list()
    conceptualModel = NULL
    iv = treatment
    dv = poundsLost
    randomEffects <- inferRandomEffects(confounders=confounders, interactions=interactions, conceptualModel=conceptualModel, iv=iv, dv=dv)

    expect_length(randomEffects, 1)
    ri = randomEffects[[1]]
    expect_s4_class(ri, "RandomIntercept")
    expect_equal(ri@group, group)

    # ## TODO: Example from Barr et al.
    # # pid = Participant("ID")
    # # responseTime = numeric(unit=pid, name="response time", numberOfInstances=per(1, word))
    # # condition = condition(unit=pid, name="type of words", numberOfInstances=2) # Each participant is exposed to both conditions

    # # word = Trial("word", nestsWithin=condition) # Each trial has a word that belongs to only one condition
    # # word = nominal(unit=condition, name="word", numberOfInstances=per(4, condition)) # Each condition has 4 words
    # #### Randomization is implied unless specified, using the nestsWithin construct.

    # ## TODO: Example from Barr et al. with interactions

    # ## TODO: Reuse Cohen, Cohen, West, Aiken 2003 Group Exercise example with interaction effect!
})
