> *Scenario* You want to know the influence of tutoring on student test performance. To this end, you conduct a study involving 100 students. For each student, you collect data about their race, socioeconomic background, number of extra-curriculars, and test score. Additionally, you randomly assign each student to one of two tutoring conditions: online tutoring vs. in-person tutoring.

## Step 2: Specify conceptual model
A conceptual model is a graph with variables (nodes) and conceptual relationships between variables (edges). The conceptual model should accurately represent your background knowledge about the domain. The conceptual model is used to produce a statistical model.

In this tutorial, you'll construct a conceptual model that looks like this:
<img src="https://raw.githubusercontent.com/emjun/rTisane/study/docs/graph.png" >

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

<!-- To add detail to conceptual relationships involving interactions, specify values corresponding to each of the interacting Measures. For example, 
```R 
ixn <- interacts(ses,tutoring)
# ses == "high", tutoring == "in-person"
causes(
    when=equals(ixn, list("high", "in-person")), 
    then=increases(testScore))
``` -->

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

## For this task in the study...
To see and refine your conceptual model, you can run the following line: 
```R
updatedCM <- checkAndRefine(cm) # cm is the Conceptual Model you have defined
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
