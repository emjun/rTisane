# API OVERVIEW
Below is an overview of the external API for the rTisane conceptual modeling language. [Refer here for more details about the internal API.](INTERNAL_API.md)

The rTisane has two goals: 
1. Capture conceptual models accurately. 
2. Capture analysis goals accurately. 
rTisane uses the specified conceptual models and analysis goals to derive a statistical model from a conceptual model.

Towards these goals, rTisane provides a domain-specific language (DSL) for specifying (i) variables, (ii) conceptual relationships, (iii) how to treat variable relationships, and (iv) a query for a statistical model. Although data is not required to use rTisane, if data is included, it must be in long format. 

Throughout this overview, consider the following scenario: 
> You want to know the influence of tutoring on student test performance. To this end, you conduct a study involving 100 students. For each student, you collect data about their race, socioeconomic background, number of extra-curriculars, and test score. Additionally, you randomly assign each student to one of two tutoring conditions: online tutoring, in-person tutoring. 

## Variables
There are three kinds of variables in rTisane. 

### Units 
Units are entities you collect data from through observation or experimentation. Units are declared with the following: 
- `name`: character. Should correspond to the header of the column identifying each unit
- `cardinality`: int. The number of unique units observed

In the scenario, student is your unit. 
```R
student <- Unit(name="student", cardinality=100)
```

If you prefer to think about students as participants, not units, you can specify
```R
student <- Participant(name="student", cardinality=100)
```
Participant is a special type of Unit. The above two declarations of `student` are equivalent.

### Measures 
Measures are attributes of a Unit you have observed and/or assigned them. Each measure can represent `categories`, `counts`, or `continuous` data. 

### Categories
Categories can be unordered (e.g., race) or ordered (e.g., socioeconomic background). Categorical measures are declared with the following: 
- `unit`: Unit. The Unit the measure describes
- `name`: character. Column name (same as above)
- `cardinality`: int. Number of unique categories. If `order` is provided, `cardinality` is not needed and will be set to the length of `order`
- `order`: list. List of categories in order from "lowest" to "highest"
- `baseline`: character. Specific category that the other categories in this measure are compared against. If `order` is provided, `baseline` is set to the lowest (left-most) value. Otherwise, by default, the first value in the dataset

In the scenario, race and tutoring are *unordered* categories: 
```R
race <- categories(unit=student, name="Race", cardinality=5, baseline="White")
tutoring <- categories(unit=student, name="Tutoring", cardinality=2, baseline="in-person")
```

In the scenario, socioeconomic background is an *ordered* category: 
```R
ses <- categories(unit=student, name="SES", order=list("lower", "middle", "upper"))
```

If a query's DV is a Categories variable, Possible families: Binomial, Multinomial

#### Counts
Counts measures are declared with the following: 
- `unit`: Unit. The Unit the measure describes
- `name`: character. Column name (same as above)
- `baseline`: optional. By default, 0.

In the scenario, number of extra-curriculars is a count: 
```R 
extra <- counts(unit=student, name="Num Extra-curriculars")
```

If a query's DV is a Counts measure, Possible families: Poisson, Negative Binomial (counts) 

#### Continuous (e.g., scores, temperature, time)
Continuous measures are declared with the following: 
- `unit`: Unit. The Unit the measure describes
- `name`: character. Column name (same as above)
- `baseline`: optional. By default, 0.

In the scenario, test score is a continuous measure: 
```R 
testScore <- continuous(unit=student, name="Test score")
```

*Follow-up q: Skew?*
If a query's DV is Continuous, Possible families: Inverse Gaussian, Gamma, Gaussian
#### TODO: Add checks with data

#### Interactions: Multiplicative Measures
An interaction is a combination of variables that produces an outcome. Interacting variables influence an outcome beyond their additive influence on the outcome. To express an interaction, use `interacts`
- `lhs`: Measure.
- `rhs`: Measure.
- `...` : Measure (optional). 
Returns a new variable that is the multiplicative result of all the parameter Measures. 

*What type of Measure is the interaction variable?*
- If one or more of the measures are Categories, the returned variable will also be of type Categories. By default, the returned variable will have no order.
- If all measures are Counts, the returned variable will also be Counts. 
- If all measures are Continuous, the returned variable will be Continuous. 
- If some measures are Counts and others are Continuous, the returned variable will be Continuous. 

In the scenario, if we think that the effect of tutoring will depend on socioeconomic background, we could create an interaction between tutoring and socioeconomic background. 
```R
ixn <- interacts(ses, tutoring)
```

## Conceptual model: Three types of relationships
Specify conceptual relationships between two Measures/Interactions. 

### WhenThen 
`whenThen` describes how a change to one Measure causes a change to another Measure. 

A program can have multiple `whenThen` statements involving the same two Measures. When inferring a statistical model, rTisane will infer a `causes(when, then)` for each `whenThen` statement. 
<!-- A When Then will be causes(when, Then), so if the multiple whenThen statements introduce a cycle, rTisane will halt.  -->

In the scenario, if you think that as the number of extracurriculars a student has increases, the student's test score will decrease, you could specify
```R
whenThen(when=increases(extra), then=decreases(testScore))
```
Then, to infer a statistical model, rTisane would infer 
```R 
causes(extra, testScore)
```

**How to use whenThen**
There are four types of changes to a Measure: 
- `increases(variable)`
    - variable: Categories with an order, Counts, or Continuous
- `decreases(variable)`:
    - variable: Categories with an order, Counts, or Continuous
- `equals(variable, value)`
    - variable: Categories, Counts, or Continuous
    - value: character, int, float, or list
- `notEquals(variable, value)`
    - variable: Categories, Counts, or Continuous
    - value: character, int, float, or list

There are three common `whenThen` statements. Below are examples from the scenario. 

1. When a Measure increases/decreases, then another increases/decreases: 
```R
whenThen(when=increases(extra), then=decreases(testScore))
```

2. When a Measure equals/does not equal a specific value, then another Measure equals/does not equal a specific value: 
```R
whenThen(when=equals(ses, "middle"), then=equals(extra, 3))
```

3. When a Measure equals a specific value, then another Measure increases/decreases: 
```R
whenThen(when=equals(race, "Black"), then=increases(testScore))
```
*Important note:* The change described in the `then` parameter is in comparison to a baseline. More precisely, the example `whenThen` statement above states that the average of `testScores` for `"Black"` students is higher than the average of `testScores` for `"White"` students (the baseline specified when `race` was declared.) The baseline for Counts and Continuous variables is 0 unless otherwise specified. 

Also possible but likely less common:
When a Measure increases/decreases, then another Measure equals/does not equal a specific value. 
```R
whenThen(when=increases(extra), then=equals(testScore, 85)) # Could describe a piecewise function or a plateauing effect
```

To specify `whenThen` relationships involving interactions, specify values corresponding to each of the variables involved in the interaction. For example, 
```R 
when(when=equals(interacts(ses,tutoring), list("high", "in-person")), then=increases(testScore))
```
Not necesary: The baseline for interaction variable: combination of baselines (e.g., 0, first value, first value)
ixn - res: cat
ixn - res: count
ixn - res: cont

<!-- 
#### For interacts 
This new variable can be used to specify `causes` relationships. To use an interaction inside a `whenThen` statement, analysts must specify values for the variables comprising the interaction. The baseline will be when the interaction variable takes on the baseline values for all the individual variables. 
```R 
ixn <- interacts(a, b)
when(when=equals(interacts(ses,tutoring), list("high", "in-person")), then=increases(testScore))
when(when=equals(interacts(ses,tutoring), list("low", "in-person")), then=increases(testScore))
``` -->
### Causes 



### Relates 
Requires disambiguation

<!-- **Why does it make sense to allow someone to express Relates and then ask them if it is Causes A->B or B->A? -->

rTisane allows analysts to specify `relates` between variables because that may
be more accurate to analysts' understanding of a domain (goal: capture analysts'
conceptual models accurately). However, these `relates` relationships are ambiguous, and a direction of influence must be assumed in order to infer a statistical model from a conceptual model. Thus, rTisane engages analysts in an initial disambiguation step to assume directions. Under the hood, this means `relates` relationships get cast as more specific `causes` relationships prior to deriving statistical models. 

## Conceptual model: Label variable relationships
### Assume 
### Hypothesize 

## Query 


# Programming style
We designed rTisane to be compatible with common programming idioms in R, including the chaining of calls using the pipe character (`%>%`). Using pipes is completely optional, but may be easier for some analysts to read and write. 

The following two programs are equivalent. The first uses pipes, and the second does not. 


# FAQs
## Why do we need all these different ways of specifying conceptual relationships? 
Analysts think about how variables relate conceptually in idiosyncratic but comparable ways. 

Two approaches: 
1. Language-based specification 
Analysts state directional relationships right away using the language constructs `causes` or `whenThen`. `whenThen` is more specific and implies a causal relationship.
2. System-aided specification
Analysts start by indicating that two variables `relate` without specifying a direction of influence. Then, they use rTisane to help them visualize their conceptual model and then make more specific assumptions about directions of influence. 

## If I specify an interaction, what gets added to the derived statistical model?
It depends on the query issued.

- If the query's independent variable is a measure (not an interaction), then rTisane will identify a set of confounders recommended for most accurately estimating the independent variable's influence on the dependent variable in the query. By default, rTisane will include all the confounders. If there is an interaction involving the independent variable and/or confounders, rTisane will suggest the interactions but leave their inclusion up to the analyst. 

- If the query's independent variable is an interaction, then, rTisane will, by default, include the interaction and all the variables comprising the interaction. During disambiguation, the end-user can remove variables. rTisane does not suggest other confounders based on causality because there are no causal DAG-based recommendations for accurately estimating interactions in the causal reasoning literature. If end-users are concerned about confounders for interactions, they should issue a query for accurately estimating each component variable accurately, include the interaction of interest, and then compare the multiple output statistical models (if they are different). 

## Why do we need a separate `interacts` construct? Interactions are already captured in causal DAGs.
In a causal DAG, interactions are implied. However, we aren't trying to do causal estimation, so it is ok to ask for and include interactions directly. We rely on recommendations from the causal modeling literature on which confounders to include/exclude in order to ensure that estimates of interest are what we expect them to represent, or in other words, avoid common estimation biases (e.g., omitted variable bias). 
Our goal is that, ultimately we allow the analyst to make modifications/final calls, but by adhering to the default, which we anticipate most end-users will, they will have a pretty good statistical model that accurately estimates what they care about + represents their conceptual knowledge. 

## I have multiple hypothesized relationships. I want to assess all of them.
We recommend issuing multiple queries for a statistical model with different independent variables (and conceptual relationships) of interest. Depending on your conceptual model, the queries may result in the same statistical model or multiple that are each designed to optimally asses a specific hypothesized relationship.

## Questions for Carlos 
- Interactions 
- Assessing multiple variables and their influence on the same outcome. Using the recommendations, should run multiple statistical models?
    - --> How to think about this problem for multiple comparisons (Tibshirani?)

# Common failure cases


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