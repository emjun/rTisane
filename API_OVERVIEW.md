# API OVERVIEW
Below is an overview of the external API for the rTisane conceptual modeling language. [Refer here for more details about the internal API.](INTERNAL_API.md)

## Variable declaration

### Specify observational/experimental units
```R
student <- Unit("student", cardinality=100)
```

### Special case: Explicitly specify Participants as a Unit
```R
member <- Participant("member", cardinality=386)
```

### Specify measures
```R
# A student has an age 
age <- numeric(unit=student, name="age")
# A student has an eye color 
eyeColor <- nominal(unit=student, name="eyeColor")
# A student has a test score
testScore <- ordinal(unit=student, name="testScore", order=list("A", "B", "C", "D", "F"))
```

### Special case: Explicitly specify experimental conditions
```R
member <- Participant("member", cardinality=386)
# Each participant was assigned 1 condition, between-subjects
condition <- condition(unit=member, "treatment", cardinality=2) # default: numberOfInstances=1
# Each participant was assigned both (2) conditions, within-subjects
condition <- condition(unit=member, "treatment", cardinality=2, numberOfInstances=2)
```

## Conceptual relationships between 2 variables
Analysts specify conceptual relationships that are added to a conceptual model, which ultimately provides an evaluation context for queries (further below). 

Each conceptual relationship has a directed edge and a label. Directed edges can be expressed in one of three ways that differ in their specificity/ambiguity. Analysts can use whichever option most closely matches their internal mental model and helps them reason through implicit conceptual assumptions.

<!-- two parts: (i) a _relational direction_ (i.e., What causes what?) and (ii) _evidence_ for that direction (i.e., Is the end-user assuming or hypothesizing a specific relationship?). When declaring a _relational direction_, analysts can specify relationships by stating one of the following: (i) the general presence of a relationship (no specific direction, must be clarified before executing a query), a directional summary (i.e., A causes B), or a hyper-specific direction (i.e., when A is "treatment", B increases.  -->
<!-- As a result, rTisane will ask users who provide relationships at a general level to specify further and infer directional summaries from hyper-specific expressions.  -->

To start, analysts must specify a conceptual model to add conceptual relationships to. 
```R
cm <- ConceptualModel()
```

### Three different edge types
**Option 1: Ambiguous relates**
An edge's direction is unclear.
```R
# Either -->, <-- could be true; system needs to ask user for input or explore multiple paths
r0 <- relates(motivation, poundsLost)
r1 <- relates(motivation, poundsLost)
```

**Option 2: Directed causes**
```R
c0 <- causes(age, poundsLost)
c1 <- causes(condition, poundsLost)
```

**Option 3: Hyper-specific whenThen statements**
The benefit of the ``whenThen`` construct is (i) closer mapping to how/level of detail analysts think about causal relationships and (ii) more thorough documentation to facilitate analysts' reflection and increase their awareness of conceptual assumptions. 

```R
whenThen(when=increases(motivation), then=increases(poundsLost))
whenThen(decreases(motivation), increases(poundsLost))
whenThen(equals(condition, "control"), increases(poundsLost))
whenThen(notEquals(condition, "treatment"), decreases(poundsLost))
```

To derive statistical models from conceptual models (see "Query" section), rTisane reasons about relationships at the middle-level (directed relationships without specific details). In the presence of ambiguous, undirected relationships, rTisane will disambiguate with analysts which directed relationship they mean. For hyper-specific, directed relationships expressed using the ``whenThen`` construct, rTisane will infer a directed causal relationship. 

### Two different labels: Assume or Hypothesize
**Option 1: Assume a known relationship (e.g., from prior work, would be problematic if this did not exist)**
```R
c <- causes(age, poundsLost)
cm <- assume(cm, c)
# OR
cm <- assume(cm, causes(age, poundsLost))

r <- relates(motivation, poundsLost)
cm <- assume(cm, r)
# OR
cm <- assume(cm, relates(motivation, poundsLost))
```

**Option 2: Hypothesize a relationship (e.g., the focus of the current ongoing analysis)**
```R
c <- causes(condition, poundsLost)
cm <- hypothesize(c)
# OR 
cm <- hypothesize(causes(condition, poundsLost))

r <- relates(motivation, poundsLost)
cm <- hypothesize(r)
# OR
cm <- hypothesize(relates(motivation, poundsLost))
```

## Conceptual relationships for 3+ variables in a relationship
### Unobserved variables (for what previously was ``associates_with``)
Can only assume, not hypothesize, relationships with Unobserved variables (enforced by function type signature). 
Must be Assume because (i) Unobserved variables are not measured and therefore (2) we cannot test/hypothesize unobserved relationships.

Unobserved variables can be involved in conceptual relationships that are constructed using the ambiguous ```relates`` or directed ``causes`` constructs. Unobserved variables cannot be involved in hyper-specific ``whenThen`` relationships because an Unobserved variable is, by definition, not measured. 

```R
#  Mediation
# age -> midlife_crisis -> poundsLost
# age -> midlife_crisis -> motivation
midlife_crisis <- Unobserved()
cm <- assume(cm, causes(age, midlife_crisis))
cm <- assume(cm, causes(midlife_crisis, poundsLost))
cm <- assume(cm, causes(midlife_crisis, motivation)) # Must be Assume. Because (i) Unobserved variables are not measured and therefore (2) We cannot test/hypothesize unobserved relationships.

# Common ancestor
# latent_var -> age, latent_var -> motivation
latent_var <- Unobserved()
cm <- assume(cm, causes(latent_var, age))
cm <- assume(cm, causes(latent_var, motivation))
cm <- assume(cm, causes(age, motivation))
```

### TO DISCUSS: Interactions
Design considerations: 
- Specify that an IV's influence on a DV changes. 
- Capture how (magnitude, direction) the IV's influence changes. For example, 
    *As age increases, the influence of motivation (IV of interest) on pounds lost (DV) becomes “less negative.” — "less" indicates magnitude changing, "negative" indicates direction*
- Distinguish between additive and multiplicative terms. I.e., *c = a + b || c = a * b || c = a + b + a * b || (less common) c = a + a * b || (less common) c = b + a * b*

Information we need to capture: 
- *Influence of interest*: Which IV's influence on another (DV) do we care about? (consider pairwise for the time being)
- *Change*: How does the influence of interest change in terms of magnitude and direction? 
- *Reference variable*: According to what other variable does an influence of interest change?

Ideas: 
For ordinal or continuous "reference" variable (i.e., age, below):
```R
rel <- becomesLessNegative(influence=(of=motivation, on=poundsLost), asIncreases=age) # similar to how we would read causes(a, b)
# Other options
# functions: becomesLessNegative, becomesMoreNegative, becomesLessPositive, becomesMorePositive 
# parameters: asIncreases, asDecreases

rel <- becomesLessNegative(increases=age, iv=motivation, dv=poundsLost)

rel <- changes(influence=motivation, on=poundsLost, "less negative", increases=age)

rel <- influenceChanges(iv=motivation, dv=poundsLost, becomes="less negative", as=increases(age))

rel <- lessNegative(iv=motivation, dv=poundsLost, increases=age)

rel <- as(increases=age) %>% LessNegative(iv=motivation, dv=poundsLost)

cm = Conceptual Model() # if not previously constructed
cm <- assume(cm, rel)

# Using %>%
cm <- ConceptualModel() %>%
    assume(...)
```

For categorical "reference" variable: 
```R
# Imagine we have a condition variable 
condition <- nominal(member, "condition", cardinality=3)
rel <- becomesLessNegative(influence=(of=motivation, on=poundsLost), asChange=list(condition, c("control", "treatment a", "treatment b"))) # similar to how we would read causes(a, b)
# asChange parameter: Order categories according to "least" to "most" negative; must include all categories in variable (above: condition)
```

When do these interaction variables get added to the statistical model? 
Answer: Depends on (i) what relationships are specified in the conceptual model and (ii) the query issued.
```R
# If rel is not added to the Conceptual Model
query(conceptualModel=cm, iv=motivation, dv=poundsLost) # age gets suggested as a confounder to account for
# ==> poundsLost = motivation + age

query(conceptualModel=cm, relationship=rel) # Provide 2 different options for issuing a query
# ==> poundsLost = motivation*age

query(conceptualModel=cm, iv=motivation, dv=poundsLost) # age gets suggested as a confounder to account for
# ==> poundsLost = motivation + age + motivation*age 

## COULD ALSO ALLOW FOR THESE LESS COMMON CASES:
# If age does not get suggested as a confounder
query(conceptualModel=cm, iv=motivation, dv=poundsLost)
# ==> poundsLost = motivation + motivation*age

# If age is IV and motivation does not get suggested as a confounder
query(conceptualModel=cm, iv=age, dv=poundsLost)
# ==> poundsLost = age + motivation*age

# Heuristic: Add interaction when one or more of the variables involved in an interaction (becomesLessNegative/etc.) are included as main effects. 
```

Notes: 
- Discuss: Interactions are closer to the data/statistical model than the previous conceptual relationships. So does it still make sense for it to follow a similar ConceptualModel updating pattern as the others?
- The redesign ideas differ from the previous design idea (below) because they move away from a discrete expression (truth table) to a more continuous expression of interaction relationships. 


Previous design:
    Interactions are a conjunction of multiple "conditions" + a consequence. (Why not just all conjunction?: There is an implied consequence/"directionality" of effect in interactions.)

    ```R
    wt <- whenThen(when=list(increases(motivation), increases(age)), then=increases(poundsLost))
    cm <- hypothesize(wt)

    wt <- whenThen(when=list(equals(motivation, 'high'), increases(age)), then=increases(poundsLost))
    cm <- assume(cm, wt)
    ```

## Queries to issue
With an explicit handle to the conceptual model, we don't need to construct an intermediate "Study Design." We can directly assess/query the conceptual model. 

### Infer an (initial) statistical model from a conceptual model
A query for a statistical model from a conceptual model probes into the influence of one IV on a DV in the context of the assumed + hypothesized relationships in the conceptual model. A query outputs a script for fitting and visualizing an output statistical model inferred from the conceptual model. 

The statistical models are designed to assess the causal influence/effect of an independent variable on a dependent variable. To avoid the [mutual adjustment fallacy](http://dagitty.net/learn/graphs/table2-fallacy.html) and support precise estimation of the influence of an IV on a DV, analysts can only query about 1 IV at a time. If they are interested in multiple variables, they can treat each IV sequentially. (In some cases, statistical models to assess the influence of different variables may be identical.)

Confounders are selected on the assumption that analysts are interested in the average causal effect ("ACE") of an independent variable on the dependent/outcome variable. Confounders are suggested based on recommendations by [Cinelli, Forney, and Pearl (TR 2022)](https://ftp.cs.ucla.edu/pub/stat_ser/r493.pdf) to prioritize precision of ACE estimates in regression. 

```R
query(conceptual_model=cm, iv=age, dv=poundsLost)
```

[See details about statistical model inference details and scope](STATISTICAL_MODEL_INFERENCE.md). 

### NOT IMPLEMENTED: Expressed conceptual model vs. data
Returns a script for running one or more statistical models that assess the conceptual model based on conditional independencies.

Only assesses the presence of evidence for *assumed* relationships. Hypothesized relationships are discarded in the assessment.
```R
assess(conceptual_model=cm, data=data)
```

## Ongoing development
- [Follow ongoing todos.](TODO.md) 
- [Notes and tips for contributing.](CONTRIBUTING.md)