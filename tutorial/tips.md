# Tips for writing rTisane programs
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
    assume(whenThen(when=equals(tutoring, "in-person"), then=increases(testScore)))

query(cm, iv=tutoring, dv=testScore)
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