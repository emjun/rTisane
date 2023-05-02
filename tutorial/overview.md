# Introduction 
✋ **Status check:** At this point, you have successfully installed rTisane! If not, look at [the instructions for installing rTisane](tutorial/start.qmd) or [ask for help](https://github.com/emjun/rTisane/issues). 

**What you will learn:** will use rTisane to author a statistical model without a priori knowing how exactly to formulate it. 

In five steps (!!!), rTisane will help you leverage what you know about your domain in order to mathematically formulate a statistical model and implement it in code.

Note: Although a dataset is not required to use rTisane, if included, a dataset must be in long format. Furthermore, if a dataset is used, some [parameters for declaring variables become optional](#measures). rTisane will infer them from the dataset. 


# Consider the following scenario: 
> You want to know the influence of tutoring on student test performance. To this end, you conduct a study involving 100 students. For each student, you collect data about their race, socioeconomic background, number of extra-curriculars, and test score. Additionally, you randomly assign each student to one of two tutoring conditions: online tutoring vs. in-person tutoring. 

## Step 1: Declare variables 
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
race <- categories(unit=student, name="Race", cardinality=5, baseline="White")
tutoring <- categories(unit=student, name="Tutoring", cardinality=2, baseline="in-person")
```

In the scenario, socioeconomic background is an *ordered* category: 
```R
ses <- categories(unit=student, name="SES", order=list("lower", "middle", "upper"))
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

### Interactions
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

## Step 2: Specify conceptual model
A conceptual model is a graph with variables (nodes) and conceptual relationships between variables (edges). The conceptual model should accurately represent your background knowledge about the domain. The conceptual model is used to produce a statistical model.

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
causes(causes=tutoring, effect=testScore)
```

#### Relates
Use `relates` th specify that two variables are related but you are uncertain about the direction of influence. 

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
causes(causes=tutoring, effect=testScore, when=equals(tutoring, 'in-person'), then=increases(testScore))
# or
relates(lhs=tutoring, rhs=testScore, when=equals(tutoring, 'in-person'), then=increases(testScore))
```

To add detail to conceptual relationships involving interactions, specify values corresponding to each of the interacting Measures. For example, 
```R 
ixn <- interacts(ses,tutoring)
# ses == "high", tutoring == "in-person"
causes(when=equals(ixn, list("high", "in-person")), then=increases(testScore))
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

*Important note:* The change described in the `then` parameter is in comparison to a baseline. More precisely, the example `whenThen` statement above states that the average of `testScores` for `"Black"` students is higher than the average of `testScores` for `"White"` students (the baseline specified when `race` was declared.) The baseline for Counts and Continuous variables is 0 unless otherwise specified. The baseline for Categorical interactions is the product of baseline values from the interacting Measures. 

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
assume(cm, cr) # cm refers to the Conceptual Model you declared previously and are adding this relationship to

# Alternative syntax: nested function calls
cm <- ConceptualModel()
...
cr <- assume(cm, causes(ses, testScore))

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
hypothesize(cm, cr) # cm refers to the Conceptual Model you declared previously and are adding this relationship to
```

## Step 3: Query rTisane for a statistical model
Finally, once you have declared variables and specified a conceptual model, you can query the conceptual model for a statistical model!

The `query` captures the relationship you are interested in assessing.

`query` has the following parameters: 
- `conceptualModel`: ConceptualModel
- `iv`: Measure. The independent variable whose effect on the dependent variable you are interested in estimating
- `dv`: Measure. The dependent variable, or outcome, you are interested in

For example, you can specify
```R
query(conceptualModel=cm, dv=testScore, iv=tutoring)
```

*Important note:* In order to infer a statistical model, there must be a hypothesized relationship between the `iv` and `dv`.

Executing the `query` will initiate an interactive process to clarify the input conceptual model and present you with a few follow-up questions necessary to infer a statistical model. 

See a video here: 
# TODO: image of first disambiguation phase!

## START HERE: Output
Result: A generated script with code for the resulting statistical model you can run! 
Run the output script with data! 

If you did not specify data in your query, you will need to specify a data path in the script. So, open the script up in a code editor. Type in the path, as the comments instruct you, and then run it! 
# TODO: Record video showing me update the path!

If you specified data in your query, run the script! 
```{r}
source("model.R") # The output script will be called model.R, but you might have to find it's path/location on your computer. 
```
Result: Summary of your statistical model + a visualization for how well the data fit. 

Run your statistical model!