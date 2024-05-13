# API OVERVIEW
Below is an overview of rTisane's external API. 
[Refer here for more details about the internal API (in middle of update).](INTERNAL_API.md)

There was one primary goal in the design of rTisane's domain-specific language (DSL) design:
Elicit and represent implicit conceptual models in as much detail as analysts find useful.

Towards these goals, rTisane's DSL provides constructs to specify (i) variables, (ii) conceptual models, and (iii) a query for a statistical model. 

Note: Although a dataset is not required to use rTisane, if included, a dataset must be in long format. Furthermore, if a dataset is used, some [parameters for declaring variables become optional](#measures). rTisane will infer them from the dataset. 

This API overview uses the following scenario as an example: 
> You want to know the influence of tutoring on student test performance. To this end, you conduct a study involving 100 students. For each student, you collect data about their race, socioeconomic background, number of extra-curriculars, and test score. Additionally, you randomly assign each student to one of two tutoring conditions: online tutoring vs. in-person tutoring. 

## Variables 
There are two kinds of variables in rTisane: (i) Units and (ii) Measures. 

### Units (e.g., Participants)
Units are entities from which you collect data. Units are declared with the following: 
- `name`: character. Corresponds to the name of the column identifying each unit
- `cardinality`: int. The number of unique instances of a unit observed (e.g., the number of unique participants)

In the example, student is your unit. 
```R
student <- Unit(name="student", cardinality=100)
```

If you prefer to think about students as participants, not units, you can specify
```R
student <- Participant(name="student", cardinality=100)
```
Participant is an alias for Unit. *The above two declarations of `student` are equivalent.*


### Measures
Measures are attributes of a Unit you have directly observed and/or assigned them. There are three types of Measures. 

#### Categories
Categories can be unordered (e.g., race) or ordered (e.g., socioeconomic background). Categorical measures are declared with the following: 
- `unit`: Unit. The Unit the measure describes
- `name`: character. Column name
- `cardinality`: int. Number of unique categories. If `order` is provided, `cardinality` is not needed and will be set to the length of `order`
- `order`: list. List of categories in order from "lowest" to "highest"
- `baseline`: character. Specific category that the other categories in this measure are compared against. If `order` is provided, `baseline` is set to the lowest (left-most) value. Otherwise, by default, the first value in the dataset; `baseline` is useful for adding detail to conceptual relationships, through `when` and `then` parameters ([see below](#optional-when-and-then)).

In the scenario, race and tutoring are *unordered* categories: 
```R
race <- categories(
  unit=student, name="Race",
  cardinality=5, baseline="White")
tutoring <- categories(
  unit=student, name="Tutoring",
  cardinality=2, baseline="in-person")
```

In the scenario, socioeconomic background is an *ordered* category: 
```R
ses <- categories(
  unit=student, name="SES",
  order=list("lower", "middle", "upper"))
```

#### Counts
Counts measures are declared with the following: 
- `unit`: Unit. The Unit the measure describes
- `name`: character. Column name
- `baseline`: optional. By default, 0.

In the scenario, number of extra-curriculars is a count: 
```R 
extra <- counts(unit=student, name="Num Extra-curriculars")
```

#### Continuous (e.g., scores, temperature, time)
Continuous measures are declared with the following: 
- `unit`: Unit. The Unit the measure describes
- `name`: character. Column name
- `baseline`: optional. By default, 0.

In the scenario, test score is a continuous measure: 
```R 
testScore <- continuous(unit=student, name="Test score")
```

## Conceptual model
A conceptual model is a graph with variables (nodes) and conceptual relationships between variables (edges). The conceptual model should accurately represent your background knowledge about the domain. The conceptual model is used to produce a statistical model.

In this tutorial, you'll construct a conceptual model that looks like this:
<!-- <img src="https://raw.githubusercontent.com/emjun/rTisane/main/docs/graph.png" > -->

First, construct a conceptual model and then add conceptual relationships to it.
```R
cm <- ConceptualModel()
```

Specify conceptual relationships to add to the conceptual model. Each relationship has a *type* and a *label* about how to treat it. 

### Two types of conceptual relationships

#### Causes 
Use `causes` to specify that a variable causes another.  

`causes` takes the following parameters: 
- `cause`: Measure
- `effect`: Measure
- `when`: Compares relationship (optional, see below)
- `then`: Compares relationship (optional, see below)

In the graph, `causes` introduces a directed edge from `cause` to `effect`.

For example, you can specify that tutoring causes test scores. 
```R
causes(cause=tutoring, effect=testScore)
```

#### Relates
Use `relates` to specify that two variables are related but you are uncertain about the direction of influence. 

`relates` takes the following parameters: 
- `lhs`: Measure
- `rhs`: Measure
- `when`: Compares relationship (optional, see below)
- `then`: Compares relationship (optional, see below)

In the graph, `relates` introduces a bi-directional edge  between `lhs` and `rhs`.

For example, you can specify that tutoring is related to test scores. 
```R
relates(lhs=tutoring, rhs=testScore)
```

rTisane will guide you through possible graphical structures that a bi-directional edge could represent. To infer a statistical model, rTisane will ask you to assume a direction of influence.

#### Optional: `when` and `then` 
For both `causes` and `relates`, you may want to describe in greater detail how the relationship "behaves" by including `when` and `then` parameters. For instance, if you mean that when tutoring is in-person, then test scores increase, you may specify
```R
causes(
    cause=tutoring, effect=testScore,
    when=equals(tutoring, 'in-person'),
    then=increases(testScore))
# or
relates(
    lhs=tutoring, rhs=testScore,
    when=equals(tutoring, 'in-person'),
    then=increases(testScore))
```

There are four types of comparisons you can include in `when` and `then`, depending on the kind of Measure you have:
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

*Important note:* The change described in the `then` parameter is in comparison to a baseline. The baseline for Counts and Continuous variables is 0 unless otherwise specified. 
 <!-- More precisely, the example `whenThen` statement above states that the average of `testScores` for `"Black"` students is higher than the average of `testScores` for `"White"` students (the baseline specified when `race` was declared.)  -->
 <!-- The baseline for Categorical interactions is the product of baseline values from the interacting Measures.  -->

You may want to include `when` and `then` parameters if they help you keep track of or think through your conceptual model. In `relates` statements, the parameters are used to more highly suggest graphical structures that you might mean. 

### Label conceptual relationships
When adding a relationship to a conceptual model, you must label each relationship (i.e., edge) with either `assume` or `hypothesize`. 

#### Assume 
Assume a conceptual relationship if it is established in prior work or you have a strong belief about it. 
<!-- would be problematic if it did not exist in the current dataset.  -->

For example, you can say that based on prior work, you assume socioeconomic background will cause test scores. 
```R
# Previously, we constructed a Conceptual Model: 
cm <- ConceptualModel()
...
cr <- causes(ses, testScore)
cm <- assume(cm, cr) # cm refers to the Conceptual Model you declared previously and are adding this relationship to

# Alternative syntax: nested function calls
cm <- ConceptualModel()
...
cm <- assume(cm, causes(ses, testScore))

# Alternative syntax: Pipe
cm <- ConceptualModel() %>%
...
assume(causes(ses, testScore))
```

#### Hypothesize 
Hypothesize a conceptual relationship if it is unknown and/or the focus of the ongoing analysis. **In order to infer a statistical model, there must be at least one hypothesized relationship.**

In the scenario, you `hypothesize` that tutoring causes test scores.
```R
cm <- ConceptualModel()
...
cr <- causes(tutoring, testScore)
cm <- hypothesize(cm, cr) # cm refers to the Conceptual Model you declared previously and are adding this relationship to
```

## Additional annotations: Interactions
As you think through conceptual relationships, you may become aware of interactions between variables. Interactions may explain how variables influence an outcome beyond their additive influence. To express an interaction, use `interacts`, which takes the following parameters:
- `conceptualModel`: ConceptualModel. Your conceptual model
- `...`: Measures. Two or more variables you think interact
- `dv` : Measure.

`interacts` expects you to have specified a conceptual relationship between each of the measures in `...` and the `dv` already. `interacts` adds an annotation about these variables to your conceptual model and will return an updated conceptual model. 

To derive statistical models, rTisane will suggest including any interactions that involve a dependent variable of interest.

In the scenario, if we think that the effect of tutoring (on test score) will depend on socioeconomic background, we could create and add an interaction between tutoring and socioeconomic background to our conceptual model.
```R

cm <- interacts(cm, ses, tutoring, dv=testScore)
```

## Query rTisane for a statistical model
Finally, once you have declared variables and specified a conceptual model, you can query the conceptual model for a statistical model!

The `query` captures the relationship you are interested in assessing.

`query` has the following parameters: 
- `conceptualModel`: ConceptualModel
- `iv`: Measure. The independent variable whose effect on the dependent variable you are interested in estimating
- `dv`: Measure. The dependent variable, or outcome, you are interested in
- `data`: Pathlike or Dataframe. (optional) Either the path to a dataset (a CSV in long format) or a Dataframe. 

For example, you can specify
```R
script <- query(
  conceptualModel=cm,
  dv=testScore,
  iv=tutoring)
# with a path to data 
script <- query(
  conceptualModel=cm,
  dv=testScore,
  iv=tutoring,
  data="data.csv")
# with a dataframe (df) that you have already imported
script <- query(
  conceptualModel=cm,
  dv=testScore,
  iv=tutoring,
  data=df) 
```

*Important:* In order to infer a statistical model, there must be a hypothesized relationship between the `iv` and `dv`.

Executing the `query` will initiate an interactive process to clarify the input conceptual model and present you with a few follow-up questions necessary to infer a statistical model. 

## Output
The result of executing an rTisane program (and engaging in the interactive process) is a script with code for fitting a statistical model to assess the average treatment effect of the IV on the DV in your query. 

The last thing to do is to specify data in your script (when you have it) and run your script!
```R
source("model.R") # You can copy and paste the script path that rTisane gives you, which should be something like "model.R"
```

*Important: You can have multiple queries involving the same conceptual model but different IVs and DVs!* Each query will output a separate `model.R` file. You may want to issue multiple queries and compare the statistical models rTisane provides as output, especially if you have multiple variables of interest. 