# API OVERVIEW

# Variable declaration

## Participant
```R
member <- Participant("member", caridinality=386)

motivation <- ordinal(unit=member, name="motivation", order=[1, 2, 3, 4, 5, 6])
age <- numeric(unit=member, name="age", number_of_instances=1)
pounds_lost <- numeric(unit=member, name="pounds_lost")
```

## Condition
```R
condition <- condition(unit=group, "treatment", cardinality=2 number_of_instances=1)
```

# Conceptual relationships
```R
cm <- ConceptualModel()
```

## _Specificity_ of relationship direction 
## UNCERTAIN: Ambiguous direction, general conceptual relationship
The direction of relationship is unclear.
```R
# Either -->, <-- could be true; system needs to ask user for input or explore multiple paths
r0 <- relates(motivation, pounds_lost)
r1 <- relates(motivation, pounds_lost)
```

## Specific relationships
```R
c0 <- causes(age, pounds_lost)
c1 <- causes(condition, pounds_lost)
```

## (Hyper-) specific relationships
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

## _Evidence_ for relationships
## Known relationship (e.g., from prior work, would be problematic if this did not exist)
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

## Hypothesized relationship (e.g., the focus of the current ongoing research)
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
suspect_causes(midlife_crisis, motivation, cm)
# Could have used know_causes as well - Does not change behavior later on.

# Common ancestor
# latent_var -> age, latent_var -> motivation
latent_var <- Unobserved()
causes(latent_var, age, cm)
causes(latent_var, motivation, cm)

```

## Potential interactions
```R

```

# Queries to issue
## Expressed conceptual model vs. data

## Expressed conceptual model --> statistical model 
