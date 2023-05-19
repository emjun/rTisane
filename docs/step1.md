> *Scenario* You want to know the influence of tutoring on student test performance. To this end, you conduct a study involving 100 students. For each student, you collect data about their race, socioeconomic background, number of extra-curriculars, and test score. Additionally, you randomly assign each student to one of two tutoring conditions: online tutoring vs. in-person tutoring.

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