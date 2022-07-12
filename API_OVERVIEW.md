# API OVERVIEW

# EXTERNAL API 
## Variable declaration

### [x] Participant
```R
member <- Participant("member", caridinality=386)

motivation <- ordinal(unit=member, name="motivation", order=[1, 2, 3, 4, 5, 6])
age <- numeric(unit=member, name="age", number_of_instances=1)
pounds_lost <- numeric(unit=member, name="pounds_lost")
```

### [x] Condition
```R
condition <- condition(unit=group, "treatment", cardinality=2 number_of_instances=1)
```

## Conceptual relationships
```R
cm <- ConceptualModel()
```

### _Specificity_ of relationship direction 
### UNCERTAIN: Ambiguous direction, general conceptual relationship
The direction of relationship is unclear.
```R
# Either -->, <-- could be true; system needs to ask user for input or explore multiple paths
r0 <- relates(motivation, pounds_lost)
r1 <- relates(motivation, pounds_lost)
```

### Specific relationships
```R
c0 <- causes(age, pounds_lost)
c1 <- causes(condition, pounds_lost)
```

### (Hyper-) specific relationships
The benefit of these functions is (i) closer mapping to the detail with which how analysts think about causal relationships and (ii) more thorough documentation to facilitate analysts' reflection.
```R
# System: Have to infer/follow-up when not all categories in a categorical variable is stated?
# Return set of implied relationships?

# Use keyword "increases" or "decreases"
sr0 <- when(motivation, "increases").then(pounds_lost, "increases")
sr1 <- when(motivation, "increases").then(pounds_lost, "decreases")
# Provide own condition that must parse in R (==, !=)
sr2 <- when(condition, "==`treatment`").then(pounds_lost, "increases")
sr3 <- when(condition, "!=`treatment`").then(pounds_lost, "decreases")
```

### _Evidence_ for relationships
### Known relationship (e.g., from prior work, would be problematic if this did not exist)
```R
c <- causes(age, pounds_lost)
assume(c, cm)
# OR
assume(causes(age, pounds_lost), cm)

r <- relates(motivation, pounds_lost)
assume(r, cm)
# OR
assume(relates(motivation, pounds_lost), cm)
```

### Hypothesized relationship (e.g., the focus of the current ongoing research)
```R
c <- causes(condition, pounds_lost)
hypothesize(c, cm)
# OR 
hypothesize(causes(condition, pounds_lost), cm)

r <- relates(motivation, pounds_lost)
hypothesize(r, cm)
# OR
hypothesize(relates(motivation, pounds_lost), cm)
```

## Unobserved variables (for what previously was associates_with)
```R
#  Mediation
# age -> midlife_crisis -> pounds_lost
# age -> midlife_crisis -> motivation
midlife_crisis <- Unobserved()
assume(causes(age, midlife_crisis), cm)
assume(causes(midlife_crisis, pounds_lost), cm)
assume(causes(midlife_crisis, motivation), cm) # Assume vs. hypothesize does not matter/change behavior later on. For latent variables, should use assume since we cannot test/hypothesize unobserved relationships.

# Common ancestor
# latent_var -> age, latent_var -> motivation
latent_var <- Unobserved()
assume(causes(latent_var, age), cm)
assume(causes(latent_var, motivation), cm)
assume(causes(age, motivation), cm)
```

## Potential interactions
Interactions are a conjunction of multiple "conditions" + a consequence
Why not just all conjunction?: There is an implied consequence/"directionality" of effect in interactions
```R
suspect(when((motivation, "==high"), (age, "increases")).then(pounds_lost, "increases"), cm)
suspect(when((motivation, "==low"), (age, "increases")).then(pounds_lost, "baseline"), cm) # Do we want to allow for baseline?
suspect(when((motivation, "==low"), (age, "increases")).then(pounds_lost, "decreases"), cm)
```

# Queries to issue
## Expressed conceptual model vs. data
```R
assess(conceptual_model=cm, data=data)
```

## Expressed conceptual model --> statistical model 
```R
query(conceptual_model=cm, iv=[list], dv=pounds_lost)
```

# Questions
1. Aesthetically - is it weird to not have the same gradations of specificity for interaction even though empirically we've found that interactions are difficult to reason about without (hyper-)specificity?


## Possible inconveniences
1. Casting all parmeters using integer().
Because we override the ``numeric`` data type/function in R, end-users need to specify integer parameters by explicitly casting/specifying their parameters using ``integer``. For example: 
```R
condition <- condition(unit=participant, name="treatment", order=list("low","medium", "high"), number_of_instances=integer(1))
```
