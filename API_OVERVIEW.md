# API OVERVIEW

# EXTERNAL API 

## Variable declaration

### Can explicitly state Participant (as a subclass of Unit)
```R
member <- Participant("member", caridinality=386)

motivation <- ordinal(unit=member, name="motivation", order=[1, 2, 3, 4, 5, 6])
age <- numeric(unit=member, name="age", number_of_instances=1)
pounds_lost <- numeric(unit=member, name="pounds_lost")
```

### Explicitly state Condition (instead of as a measure)
```R
condition <- condition(unit=group, "treatment", cardinality=2 number_of_instances=1)
```
### TODO: Add Units + Measures info from Tisane

## Conceptual relationships between 2 variables
Conceptual relationships are added to a conceptual model that provides an evaluation context for queries (further below). 
Each conceptual relationship has two parts: (i) a _relational direction_ (i.e., What causes what?) and (ii) _evidence_ for that direction (i.e., Is the end-user assuming or hypothesizing a specific relationship?). When declaring a _relational direction_, end-users can specify relationships by stating one of the following: (i) the general presence of a relationship (no specific direction, must be clarified before executing a query), a directional summary (i.e., A causes B), or a hyper-specific direction (i.e., when A is "treatment", B increases. 


To derive statistical models from conceptual models (see "Query" section), rTisane reasons about relationships at the middle-level (directional summary). In the presence of ambiguous relationships, such as multiple expressed relationships between the same two variables, rTisane will check ask for what the analyst intends to communicate at the level of a directional summary. 
<!-- As a result, rTisane will ask users who provide relationships at a general level to specify further and infer direciotnal summaries from hyper-specific expressions.  -->

```R
cm <- ConceptualModel()
```

### How to express _relational direction_
These constructs create relationship objects that must then get added to the conceptual model based on the evidence for each relationship.

**Option 1: Ambiguous direction, general conceptual relationship**
The direction of relationship is unclear.
```R
# Either -->, <-- could be true; system needs to ask user for input or explore multiple paths
r0 <- relates(motivation, pounds_lost)
r1 <- relates(motivation, pounds_lost)
```

**Option 2: Specific relationships**
```R
c0 <- causes(age, pounds_lost)
c1 <- causes(condition, pounds_lost)
```

**Option 3: (Hyper-) specific relationships: whenThen statements**
The benefit of these functions is (i) closer mapping to how/level of detail analysts think about causal relationships and (ii) more thorough documentation to facilitate analysts' reflection and increase their awareness of conceptual assumptions. 

```R
whenThen(when=increases(motivation), then=increases(pounds_lost))
whenThen(decreases(motivation), increases(pounds_lost))
whenThen(equals(condition, "control"), increases(pounds_lost))
whenThen(notEquals(condition, "treatment"), decreases(pounds_lost))
```

### _Evidence_ for relationships
Specifying the evidence for a relationship adds it to the conceptual model. 

**Option 1: Known relationship (e.g., from prior work, would be problematic if this did not exist)**
```R
c <- causes(age, pounds_lost)
cm <- assume(c, cm)
# OR
cm <- assume(causes(age, pounds_lost), cm)

r <- relates(motivation, pounds_lost)
cm <- assume(r, cm)
# OR
cm <- assume(relates(motivation, pounds_lost), cm)
```

**Option 2: Hypothesized relationship (e.g., the focus of the current ongoing analysis)**
```R
c <- causes(condition, pounds_lost)
cm <- hypothesize(c, cm)
# OR 
cm <- hypothesize(causes(condition, pounds_lost), cm)

r <- relates(motivation, pounds_lost)
cm <- hypothesize(r, cm)
# OR
cm <- hypothesize(relates(motivation, pounds_lost), cm)
```

## Conceptual relationships for 3+ variables in a relationship
### Unobserved variables (for what previously was associates_with)
Can only assume, not hypothesize, relationships with Unobserved variables (enforced by function type signature). 
Must be Assume because (i) Unobserved variables are not measured and therefore (2) we cannot test/hypothesize unobserved relationships.

Unobserved variables can be involved in conceptual relationships that are stated at the ambiguous/general (``relates``) or directional mid-level (``causes``). Unobserved variables cannot be involved in hyper-specific relationships (``whenThen``) because an Unobserved variable is, by definition, not measured. 

```R
#  Mediation
# age -> midlife_crisis -> pounds_lost
# age -> midlife_crisis -> motivation
midlife_crisis <- Unobserved()
cm <- assume(causes(age, midlife_crisis), cm)
cm <- assume(causes(midlife_crisis, pounds_lost), cm)
cm <- assume(causes(midlife_crisis, motivation), cm) # Must be Assume. Because (i) Unobserved variables are not measured and therefore (2) We cannot test/hypothesize unobserved relationships.

# Common ancestor
# latent_var -> age, latent_var -> motivation
latent_var <- Unobserved()
cm <- assume(causes(latent_var, age), cm)
cm <- assume(causes(latent_var, motivation), cm)
cm <- assume(causes(age, motivation), cm)
```

### Interactions
Interactions are a conjunction of multiple "conditions" + a consequence. (Why not just all conjunction?: There is an implied consequence/"directionality" of effect in interactions.)

```R
wt <- whenThen(when=list(increases(motivation), increases(age)), then=increases(pounds_lost))
cm <- hypothesize(wt, cm)

wt <- whenThen(when=list(equals(motivation, 'high'), increases(age)), then=increases(pounds_lost))
cm <- assume(wt, cm)
```

## TODO: Data measurement relationships 

### UPDATED: Specify nesting relationship
```R
student <- Unit("student", nests_within=family) # Can only nest within 1 Unit (family)
family <- Unit("family") # Don't need to specify all the observations that family nests, could nest multiple
```

## Queries to issue
With an explicit handle to the conceptual model, we don't need to construct an intermediate "Study Design." We can directly assess/query the conceptual model. 

### Infer an (initial) statistical model from a conceptual model
A query for a statistical model from a conceptual model probes into the influence of one IV on a DV in the context of the assumed + hypothesized relationships in the conceptual model. A query outputs a script for fitting and visualizing an output statistical model inferred from the conceptual model. 

The statistical models are designed to assess the causal influence/effect of an independent variable on a dependent variable. To avoid the mutual adjustment fallacy (http://dagitty.net/learn/graphs/table2-fallacy.html) and support precise estimation, end-users can only query about 1 IV at a time. If they are interested in multiple variables, they can treat each IV sequentially. (In some cases, statistical models to assess the influence of two different variables may be identical.)

Confounders are selected on the assumption that end-users are interested in the average causal effect ("ACE") of an independent variable on the dependent/outcome variable. Confounders are suggested based on recommendations by Cinelli, Forney, and Pearl (TR 2022) to prioritize precision of ACE estimates in regression. 

```R
query(conceptual_model=cm, iv=age, dv=pounds_lost)
```

[See details about statistical model inference details and scope](STATISTICAL_MODEL_INFERENCE.md). 

### Expressed conceptual model vs. data
Returns a script for running one or more statistical models that assess the conceptual model based on conditional independencies.

Only assesses the presence of evidence for *assumed* relationships. Hypothesized relationships are discarded in the assessment.
```R
assess(conceptual_model=cm, data=data)
```

## Internal API

`updateGraph(conceptualModel)`: Updates causal graph based on relationships specified in the conceptualModel (and stored in `conceptualModel$relationships`). 
- `causes` relationships are stored as unidirectional edges. 
- `relates` relationships are stored as bidirectional edges. (Can be disambiguated.)
- `whenThen` relationships are stored as bidirectionl edges. (Can be disambiguated.)

## Query: Infer a statistical model from a conceptual model 
Steps involved in answering query: 
1. `checkConceptualModel` to detect any issues right away prior to disambiguation
2. `processQuery` to disambiguate how to treat the DV and resolve any ambiguity in the conceptual model before inferring a statistical model. Disambiguation is complete once all ambiguities are resolved and the conceptual model is validated (`checkConceptualModel`). Disambiguation occurs in a GUI.
3. `updateDV` and `updateConceptualModel` based on inputs during disambiguation. 
4. Use disambiguated DV and conceputal model to derive candidate statistical models: `inferConfounders`, `inferFamilyLinkFunctions`
5. `processStatisticalModels` to disambiguate modeling choices. Disambiguation occurs in a GUI. 
[See details about statistical model inference details and scope](STATISTICAL_MODEL_INFERENCE.md). 

### Ongoing development
[Follow ongoing todos.](TODO.md) 

[Notes and tips for contributing.](CONTRIBUTING.md)
