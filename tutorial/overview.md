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

## Step 2: Specify conceptual relationships START HERE
To start, specify a conceptual model to add conceptual relationships to. The conceptual model is used to produce a statistical model. 
```{r}
cm <- ConceptualModel()
```

rTisane represents the conceptual model as a directed acyclic graph. The nodes are variables, and the edges describe how the variables relate to one another. For example, here is the conceptual node you will be asked to specify at the end of this section. 
# TODO: ADD PICTURE (Same one as later!)

There are **three different types of relationships (and edges)**. You should specify how variables relate according to what most closely represents your understanding. In the case of ambiguity when inferring a statistical model, rTisane will ask you follow-up questions. 

<!-- What happens if you specify a relationship?  -->

### WhenThen 
Use `whenThen` to specify how exactly a variable causes another. 

For example, you might want to say that when students receive in-person tutoring, their test scores increase. 
```{r}
whenThen(when=equals(tutoring, "in-person"), then=increases(testScore))
```

### Relates
Use `relates` when you want to note that two variables are related, but the direction of influence is unclear. 

For example, you could also say that tutoring is related to test scores. 
```{r}
relates(tutoring, testScore)
```

To infer a statistical model, rTisane will ask you to assume a direction. 

### Causes 
Use `causes` to specify that a variable causes another, but you do not know or want to specify how specific values of a variable influence another variable. 

For example, you might want to say that tutoring causes test scores. 
```{r}
causes(tutoring, testScore)
```
*When inferring statistical models, the above two statements are equivalent.*

Each edge also has one of two labels: assume or hypothesize. 

### Assume 
Assume a conceptual relationship if it is established in prior work and would be problematic if it did not exist in the current dataset. 

For example, you can say that based on prior work, you assume socioeconomic background will cause test scores. 
```{r}
cr <- causes(ses, testScore)
assume(cm, cr) # cm refers to the Conceptual Model you declared previously and are adding this relationship to
```

### Hypothesize 
Hypothesize a conceptual relationship if it is the focus of the ongoing analysis. **In order to infer a statistical model, there must be at least one hypothesized relationship.**

For example, you desigend the study so that each student was randomly assigned a tutoring condition. You hypothesize tutoring influences test scores. 
```{r}
cr <- causes(tutoring, testScore)
hypothesize(cm, cr) # cm refers to the Conceptual Model you declared previously and are adding this relationship to
```

> Try it out! In a separate `tutorial.R` script, write the other two relationships that would result in the conceptual model below. 
# TODO: Add picture + key below!

Result: Set of variables + conceptual relationships that represent your background knowledge about the domain. 

# FAQs
1. How do I know which conceptual relationships I specify? 
Reflect on what understanding of the domain you are bringing to data analysis. Express the type of relationships as what feels most accurate to your understanding. Label each relationship according to what you want to assume or hypothesize. 

2. What is the impact of specifying conceptual relationships? What happens if I omit a variable relationship? 
The conceptual relationships help rTisane infer a statistical model that most accurately represents your conceptual knowledge and understanding of the domain. If you omit a variable relationship, the statistical model may not be applicable because it does not capture your complete conceptual understanding. 

3. Can I go back and change my relationships? 
Yes! If you become aware of conceptual relationships as you use rTisane, you should go back and add new conceptual relationships and/or update ones you already specified. Query rTisane again with this updated conceptual model. 

## Step 3: Query rTisane for a statistical model based on your variable relationships
Query rTisane for a statistical model estimating the infuence of a variable on a dependent variable based on the conceptual relationships specified in a conceptual model. 
```{r}
query(conceptualModel=cm, iv=tutoring, dv=testScore) # cm refers to the Conceptual Model you declared previously and are adding this relationship to
```
Note: **Data is not required in order to generate a statistical model.**
If you have data, pass its path to the query: 
```{r}
query(conceptualModel=cm, iv=tutoring, dv=testScore, data="data.csv")
```

At this point, :clap:! You have a complete rTisane program with variables, conceptual relationships, and a query for a statistical model!

## Step 4: Clarify any relationships + answer a few more targeted questions
rTisane will show you an overview of your conceptual model's graph. If you specified that a variable `relates` to another conceptually, rTisane will ask you to assume a specific direction of influence in order to infer a statistical model. For example: 
# TODO: image of first disambiguation phase!

Once you have finalized your conceptual model, rTisane will generate a space of valid statistical models and ask a few follow-up questions via a graphical user interface (GUI). The GUI will explain how rTisane determined which variables should be included in a linear model and what family and link options to pick among based on your variable data types. After answering all the questions, generate code to fit and summarize a statistical model!

For example: 
# TODO: Add gif of GUI for school tutoring! 

Result: A generated script with code for the resulting statistical model you can run! 

## Step 5: Run your statistical model!
Run the output script with data! 

If you did not specify data in your query, you will need to specify a data path in the script. So, open the script up in a code editor. Type in the path, as the comments instruct you, and then run it! 
# TODO: Record video showing me update the path!

If you specified data in your query, run the script! 
```{r}
source("model.R") # The output script will be called model.R, but you might have to find it's path/location on your computer. 
```
Result: Summary of your statistical model + a visualization for how well the data fit. 


# Tip: Use the pipe character for specifying your conceptual model! 
Consider the below rTisane program.
```{r}
student <- Unit(name="student", cardinality=100)
ses <- ordinal(unit=student, name="SES", order=list("low", "middle", "high"))
tutoring <- nominal(unit=student, name="condition")
testScore <- numeric(unit=student, name="testScore")

cm <- ConceptualModel() 

cr <- causes(ses, testScore)
cm <- assume(cm, cr)

cr <- whenThen(when=equals(tutoring, "in-person"), then=increases(testScore))
cm <- assume(cm, cr)

query(conceptualModel=cm, iv=tutoring, dv=testScore)
```
The above program is equivalent to this program: 
```{r}
student <- Unit(name="student", cardinality=100)
ses <- ordinal(unit=student, name="SES", order=list("low", "middle", "high"))
tutoring <- nominal(unit=student, name="condition")
testScore <- numeric(unit=student, name="testScore")

cm <- ConceptualModel() %>%
    assume(causes(ses, testScore)) %>%
    assume(whenThen(when=equals(tutoring, "in-person"), then=increases(testScore))) %>%
    query(iv=tutoring, dv=testScore)
```
By using the "piping" idiom common in R, the second program emphasizes that the conceptual model is driving the statistical modeling process. You may also find the second program easier to read and write.