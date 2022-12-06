## Questions for Carlos 
- Interactions 
- Assessing multiple variables and their influence on the same outcome. Using the recommendations, should run multiple statistical models?
    - --> How to think about this problem for multiple comparisons (Tibshirani?)

# Common failure cases

## API OVERVIEW
How to specify repeated measures
```R
week <- Time("week") # 1 - 5
condition <- condition(unit=member, "condition", cadinality=5, numberOfInstances=per(2, week))
```

## TODO: Data measurement relationships 

### UPDATED: Specify nesting relationship
```R
student <- Unit("student", nestsWithin=family) # Can only nest within 1 Unit (family)
family <- Unit("family") # Don't need to specify all the observations that family nests, could nest multiple
```


### THINKING THROUGH INTERACTION 
Design considerations: 
- Convey proportionality (e.g., motivation becomes "weaker/less negative" as age increases) (magnitude + direction = more negative) --> We can communicate this in the language
- Distinguish between additive, multiplicative, or both, i.e. Which one of the functions do we want? --> 
```R
c = a + b vs
c = a * b vs
c = a + b + a * b vs
(less common) c = a + a * b vs
(less common) c = b + a * b
```

What does an interaction really mean?

Quote from lab study: 
- No individual effect but interaction effect
- 
Y = AX1 + BX2 + CX1*X2 + error

The influence of motivation depends on age. 

The influence of motivation varies for different age groups. 

As age increases, the influence motivation exerts on pounds_lost grows (magnitude) and becomes more negative (direction)

```R
wt <- whenThen(when=list(increases(motivation), increases(age)), then=increases(pounds_lost))
cm <- hypothesize(wt, cm)


as age increases # as loop
  the influence of motivation on pounds_lost gets less negative

as increases(age), decreases()


wt <- whenThen(when=list(equals(motivation, 'high'), increases(age)), then=increases(pounds_lost))
cm <- assume(wt, cm)
```

The influence of motivation varies across age. 

Age matters when thinking about the influence of motivation. 


** Disambiguation as not a cop out for better/improved language semantics **