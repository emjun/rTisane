# API OVERVIEW
Below is an overview of rTisane's external API. [Refer here for more details about the internal API (in middle of update).](INTERNAL_API.md)

Two goals guided rTisane's domain-specific language (DSL) re-design:
1. Represent implicit conceptual models in as much detail as analysts find useful.
2. Capture analysis goals precisely. 

Towards these goals, rTisane's DSL provides constructs to specify (i) variables, (ii) conceptual models, and (iii) a query for a statistical model. 

Note: Although data is not required to use rTisane, if included, a dataset must be in long format. 

This API overview uses the following scenario as an example: 
> You want to know the influence of tutoring on student test performance. To this end, you conduct a study involving 100 students. For each student, you collect data about their race, socioeconomic background, number of extra-curriculars, and test score. Additionally, you randomly assign each student to one of two tutoring conditions: online tutoring vs. in-person tutoring. 

# Variables
There are two kinds of variables in rTisane: Units and Measures.

## Units (e.g., Participants)
Units are entities from which you collect data. Units are declared with the following: 
- `name`: character. Should correspond to the header of the column identifying each unit
- `cardinality`: int. The number of unique instances of a unit observed

In the scenario, student is your unit. 
```R
student <- Unit(name="student", cardinality=100)
```

If you prefer to think about students as participants, not units, you can specify
```R
student <- Participant(name="student", cardinality=100)
```
Participant is a special type of Unit. The above two declarations of `student` are equivalent.

## Measures 
Measures are attributes of a Unit you have directly observed and/or assigned them. There are three types of Measures. 

### Categories
Categories can be unordered (e.g., race) or ordered (e.g., socioeconomic background). Categorical measures are declared with the following: 
- `unit`: Unit. The Unit the measure describes
- `name`: character. Column name
- `cardinality`: int. Number of unique categories. If `order` is provided, `cardinality` is not needed and will be set to the length of `order`
- `order`: list. List of categories in order from "lowest" to "highest"
- `baseline`: character. Specific category that the other categories in this measure are compared against. If `order` is provided, `baseline` is set to the lowest (left-most) value. Otherwise, by default, the first value in the dataset; `baseline` is useful for `whenThen` statements

In the scenario, race and tutoring are *unordered* categories: 
```R
race <- categories(unit=student, name="Race", cardinality=5, baseline="White")
tutoring <- categories(unit=student, name="Tutoring", cardinality=2, baseline="in-person")
```

In the scenario, socioeconomic background is an *ordered* category: 
```R
ses <- categories(unit=student, name="SES", order=list("lower", "middle", "upper"))
```

<!-- If a query's DV is a Categories variable, Possible families: Binomial, Multinomial -->

### Counts
Counts measures are declared with the following: 
- `unit`: Unit. The Unit the measure describes
- `name`: character. Column name
- `baseline`: optional. By default, 0.

In the scenario, number of extra-curriculars is a count: 
```R 
extra <- counts(unit=student, name="Num Extra-curriculars")
```

<!-- If a query's DV is a Counts measure, Possible families: Poisson, Negative Binomial (counts)  -->

### Continuous (e.g., scores, temperature, time)
Continuous measures are declared with the following: 
- `unit`: Unit. The Unit the measure describes
- `name`: character. Column name
- `baseline`: optional. By default, 0.

In the scenario, test score is a continuous measure: 
```R 
testScore <- continuous(unit=student, name="Test score")
```

<!-- *Follow-up q: Skew?*
If a query's DV is Continuous, Possible families: Inverse Gaussian, Gamma, Gaussian
#### TODO: Add checks with data -->

## Interactions
Interacting variables influence an outcome beyond their additive influence. To express an interaction, use `interacts`, which takes the following parameters:
- `lhs`: Measure.
- `rhs`: Measure.
- `...` : Measure (optional, for more than 2-way interactions)

`interacts` returns a new Measure that is the multiplicative result of all the parameter Measures. 

Like any other Measure, an interaction can be `categories`, `counts`, or `continuous`. rTisane follows these rules: 
- If one or more of the interacting Measures are Categories, the returned variable will also be of type Categories. By default, the returned variable will have no order.
- If all interacting Measures are Counts, the returned Measure will also be Counts. 
- If all interacting Measures are Continuous, the returned Measure will be Continuous. 
- If some interacting Measures are Counts and others are Continuous, the returned Measure will be Continuous. 

In the scenario, if we think that the effect of tutoring (on test score) will depend on socioeconomic background, we could create an interaction between tutoring and socioeconomic background. 
```R
ixn <- interacts(ses, tutoring)
```

# Conceptual model: Three types of relationships
A conceptual model is a graph variables (nodes) and conceptual relationships between variables (edges). The conceptual model is used to produce a statistical model. 

First, construct a conceptual model and then add conceptual relationships to it. 
```R
cm <- ConceptualModel()
```

There can be three types of relationships (edges) between two Measures: `causes`, `whenThen`, and `relates`.

## Causes 
Use `causes` to specify that a variable causes another.

### How to use
Causes takes two parameters: 
- `cause`: Measure
- `effect`: Measure

In the scenario, if you think that tutoring causes test scores, you could specify
```R
causes(tutoring, testScore)
```

### Impact on statistical modeling 
rTisane uses causal relationships between variables to suggest potential confounders. 

## Relates 
Use `relates` to specify that two variables influence each other without specifying a direction of influence. 

### How to use 
Relates takes two parameters: 
- `lhs`: Measure
- `rhs`: Measure

### Impact on statistical modeling 
rTisane allows analysts to specify `relates` between variables because that may be more accurate to analysts' understanding of a domain (Goal #1). However, these `relates` relationships are ambiguous, and a direction of influence must be assumed in order to infer a statistical model. Thus, rTisane engages analysts in a disambiguation step to assume directions.
 <!-- Under the hood, this means `relates` relationships get cast as more specific `causes` relationships prior to deriving statistical models.  -->

<!-- **Why does it make sense to allow someone to express Relates and then ask them if it is Causes A->B or B->A? -->

## WhenThen 
`whenThen` describes how a change to one Measure results in a change to another Measure. 

### How to use
In the scenario, if you think that as the number of extracurriculars a student has increases, the student's test score will decrease, you specify
```R
whenThen(when=increases(extra), then=decreases(testScore))
```
There are four types of changes to a Measure: 
- `increases(measure)`
    - measure: Categories with an order, Counts, or Continuous
- `decreases(measure)`:
    - measure: Categories with an order, Counts, or Continuous
- `equals(measure, value)`
    - measure: Categories, Counts, or Continuous
    - value: character, int, float, or list
- `notEquals(measure, value)`
    - measure: Categories, Counts, or Continuous
    - value: character, int, float, or list

To specify `whenThen` relationships involving interactions, specify values corresponding to each of the interacting Measures. For example, 
```R 
when(when=equals(interacts(ses,tutoring), list("high", "in-person")), then=increases(testScore))
```

### Common cases
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
*Important note:* The change described in the `then` parameter is in comparison to a baseline. More precisely, the example `whenThen` statement above states that the average of `testScores` for `"Black"` students is higher than the average of `testScores` for `"White"` students (the baseline specified when `race` was declared.) The baseline for Counts and Continuous variables is 0 unless otherwise specified. The baseline for Categorical interactions is the product of baseline values from the interacting Measures. 
<!-- Not necesary: The baseline for interaction variable: combination of baselines (e.g., 0, first value, first value)
ixn - res: cat
ixn - res: count
ixn - res: cont -->

Also possible but less common:

4. When a Measure increases/decreases, then another Measure equals/does not equal a specific value. 
```R
whenThen(when=increases(extra), then=equals(testScore, 85)) # Could describe a piecewise function or a plateauing effect
```
### Impact on statistical modeling
A program can have multiple `whenThen` statements involving the same two Measures. (In the future, rTisane will check that these statements do not contradict one another.) When inferring a statistical model, rTisane will infer a `relates(when, then)` for each `whenThen` statement. 
<!-- A When Then will be causes(when, Then), so if the multiple whenThen statements introduce a cycle, rTisane will halt.  -->
In the scenario, if we write
```R 
whenThen(when=increases(extra), then=decreases(testScore))
```
rTisane infers
```R 
relates(extra, testScore)
```
Like any `relates` statement, further disambiguation is necessary. 
<!-- # TODO: Edge case contradictory satements -->

<!-- 
#### For interacts 
This new variable can be used to specify `causes` relationships. To use an interaction inside a `whenThen` statement, analysts must specify values for the variables comprising the interaction. The baseline will be when the interaction variable takes on the baseline values for all the individual variables. 
```R 
ixn <- interacts(a, b)
when(when=equals(interacts(ses,tutoring), list("high", "in-person")), then=increases(testScore))
when(when=equals(interacts(ses,tutoring), list("low", "in-person")), then=increases(testScore))
``` -->


# Conceptual model: Label variable relationships
To add conceptual relationships to a conceptual model, analysts must label these relationships as asssumed or hypothesized. 

## Assume 
Assume a conceptual relationship if it is established in prior work and would be problematic if it did not exist in the current dataset. 

In the scenario, you can say that based on prior work, you `assume` socioeconomic background will cause test scores. 
```R
# Previously, we constructed a Conceptual Model: 
cm <- ConceptualModel()
...
cr <- causes(ses, testScore)
assume(cm, cr) 
```

## Hypothesize 
Hypothesize a conceptual relationship if it is unknown and/or the focus of the ongoing analysis. 

In the scenario, we `hypothesize` that tutoring causes test scores. 
```R
# Previously, we constructed a Conceptual Model: 
cm <- ConceptualModel()
...
cr <- causes(tutoring, testScore)
hypothesize(cm, cr)
```

# Query 
Finally, once you have declared variables and specified a conceptual model, you can query the conceptual model for a statistical model!

The query captures the relationship we are interested in assessing.

A `query` is comprised of three parts: 
- `conceptualModel`: ConceptualModel containing conceptual relationships rTisane should consider to infer  a statistical model
- `iv`: Measure. The independent variable whose effect on the dependent variable we are interested in estimating
- `dv`: Measure. The dependent variable, or outcome, we are interested in

In the scenario, we can specify 
```R
query(conceptualModel=cm, iv=tutoring, dv=testScore)
```
*Important note:* In order to infer a statistical model, there must be a hypothesized relationship between the `iv` and `dv`. 

# Tip: Programming style
rTisane is compatible with common programming idioms in R, including chaining function calls using pipes (`%>%`). Using pipes is completely optional, but you might find it helpful. Pipes make the focus of rTisane programs, conceptual models, more obvious. 

The following two programs are equivalent. The first uses pipes, and the second does not. 

With pipes: 
```R
student <- Participant(name="student", cardinality=100)
race <- categories(unit=student, name="Race", cardinality=5, baseline="White")
tutoring <- categories(unit=student, name="Tutoring", cardinality=2, baseline="in-person")
ses <- categories(unit=student, name="SES", order=list("lower", "middle", "upper"))
extra <- counts(unit=student, name="Num Extra-curriculars")
testScore <- continuous(unit=student, name="Test score")

cm <- ConceptualModel() %>%
    assume(causes(ses, testScore)) %>%
    assume(whenThen(when=equals(tutoring, "in-person"), then=increases(testScore))) %>%
    query(iv=tutoring, dv=testScore)
```

Without pipes: 
```R
student <- Participant(name="student", cardinality=100)
race <- categories(unit=student, name="Race", cardinality=5, baseline="White")
tutoring <- categories(unit=student, name="Tutoring", cardinality=2, baseline="in-person")
ses <- categories(unit=student, name="SES", order=list("lower", "middle", "upper"))
extra <- counts(unit=student, name="Num Extra-curriculars")
testScore <- continuous(unit=student, name="Test score")

cm <- ConceptualModel() 

cr <- causes(ses, testScore)
cm <- assume(cm, cr)

cr <- whenThen(when=equals(tutoring, "in-person"), then=increases(testScore))
cm <- assume(cm, cr)

query(conceptualModel=cm, iv=tutoring, dv=testScore)
```

# FAQs
## Why do we need all these different ways of specifying conceptual relationships? 
In our observations of strategies analysts use to specify conceptual relationships, we have found two predominant approaches: 

1. Analysts state directional relationships right away using the language constructs `causes` or `whenThen`. Analysts mix the two throughout their brainstorming process, using whichever most accurately captures their thought process. [language-based specification]
2. Analysts start by indicating that two variables `relate` without specifying a direction of influence. Sometimes they do not know. Other times, the direction isn't important to them until they want to infer a statistical model. When they are ready to infer a statistical model, they rely on rTisane to help them visualize their conceptual model and then make more specific assumptions about directions of influence. [system-based specification]

## If I specify an interaction, what gets added to the derived statistical model?
It depends on the query issued.

- If the query's independent variable is not an interaction, then rTisane will identify a set of confounders recommended for most accurately estimating the independent variable's influence on the dependent variable in the query. If there is an interaction involving the independent variable and/or confounders, rTisane will suggest the interactions but leave their inclusion up to the analyst. By default, rTisane will include all the confounders and no interactions.

- If the query's independent variable is an interaction, then, rTisane will, by default, include the interaction and all the Measures comprising the interaction. During disambiguation, the end-user can remove Measures. rTisane does not suggest other confounders based on causality because there are no causal DAG-based recommendations for accurately estimating interactions in the causal reasoning literature. If end-users are concerned about confounders for interactions, they should issue a query for accurately estimating each component variable accurately, include the interaction of interest, and then compare the multiple output statistical models (if they are different). 

## Interactions are already captured in causal DAGs. Why do we need a separate `interacts` construct?
In a causal DAG, interactions are implied. We aren't trying to do formal causal analyses, just use causal DAGs to methodically derive possible statistical model formulations, so it is ok to ask for and include interactions directly. In fact, to achieve the goal of capturing analysts' conceptual models and analysis goals accurately, it is necessary to support statements of interactions, since many statistical non-experts care about interactions. 

## Why isn't rTisane fully automated? Why do I have to answer specific questions to get a statistical model? 
There are some decisions rTisane cannot make for analysts, such as which exact pair of family and link functions to use. However, we do narrow the space of family/link functions to justifiable ones. Wherever possible, rTisane provide defaults (e.g., confounders, random effects). We anticipate that for most use cases and users, the defaults and any of the choices provided will lead to conceptually sound statistical models that accurately estimate variables that analysts care about. For the users who want most of the scaffolding but some choice, we give them the option of removing confounders and correlating random effects. 

## I have multiple hypothesized relationships and want to assess all of them. How do I do that? 
We recommend issuing multiple queries for a statistical model with different independent variables (and conceptual relationships) of interest. Depending on your conceptual model, the queries may result in the same statistical model or multiple that are each designed to optimally asses a specific hypothesized relationship.