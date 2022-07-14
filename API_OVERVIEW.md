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

## [x] Conceptual relationships
Conceptual relationships are added to a conceptual model that provides an evaluation context for queries (further below). 
Conceptual relationships are comprised of two parts: (i) a relational direction (i.e., What causes what?) and (ii) evidence for that direction (i.e., Is the end-user assuming or hypothesizing a specific relationship?). When declaring a relational direction, end-users can specify relationships in three degrees of specificity: (i) the general presence of a relationship (no specific direction, must be clarified before executing a query), a directional summary (i.e., A causes B), or a hyper-specific direction (i.e., when A is "treatment", B increases. 

TODO?: In the presence of multiple expressed relationships between the same two variables, rTisane will check....

To derive statistical models from conceptual models, rTisane reasons about relationships at the middle-level (directional summary). As a result, rTisane will ask users who provide relationships at a general level to specify further and infer direciotnal summaries from hyper-specific expressions. 

```R
cm <- ConceptualModel()
```


### [x] _Specificity_ of relationship direction 
These constructs create relationship objects that must then get added to the conceptual model based on the evidence for each relationship.
### [x] UNCERTAIN: Ambiguous direction, general conceptual relationship
The direction of relationship is unclear.
```R
# Either -->, <-- could be true; system needs to ask user for input or explore multiple paths
r0 <- relates(motivation, pounds_lost)
r1 <- relates(motivation, pounds_lost)
```

### [x] Specific relationships
```R
c0 <- causes(age, pounds_lost)
c1 <- causes(condition, pounds_lost)
```

### [x] (Hyper-) specific relationships
The benefit of these functions is (i) closer mapping to the detail with which how analysts think about causal relationships and (ii) more thorough documentation to facilitate analysts' reflection.

Return a Cause relationship.
**Idea could the specificity be used to facilitate statistical model/result interpretation?**
```R
# System: Have to infer/follow-up when not all categories in a categorical variable is stated?
# Return set of implied relationships?

# New construct 
# Concern: Too similar to ifelse? 
whenThen(when=increases(motivation), then=increases(pounds_lost))
whenThen(decreases(motivation), increases(pounds_lost))
whenThen(equals(condition, "control"), increases(pounds_lost))
whenThen(notEquals(condition, "treatment"), decreases(pounds_lost))

# Idea, not implemented:
whenThen(when=list((increases(motivation)), then=increases(pounds_lost))
```

### _Evidence_ for relationships
Specifying the evidence for a relationship adds it to the conceptual model. 
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

# Unique/extensible function
whenThen(increases(motivation), comapres(motivation, "=='high'"), increases(pounds_lost))

# Piping
# Gives a sense of passage of time, which seems closer to how people think about cause/effect
when(motivation, "==high") & when(age, "increases") %>% increases(pounds_lost)
 
# More like SQL, invoking mental model of SQL could be confusing especially for people who are unfamiliar with SQL
where(motivation, "==high") %>% where(age, "increases") %>% increases(pounds_lost)
where(motivation, "==high") & where(age, "increases") %>% increases(pounds_lost)

# Combine nesting with piping 
compares(list((motivation, "==high"), (age, "increases"))) %>% increases(pounds_lost)
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


## TODOs
- Before doing any inference, check that all of the variable relationships are "Causes" not "Relates"

## Internal API 
