# Tips for writing rTisane programs
rTisane is compatible with common programming idioms in R, including chaining function calls using pipes (`%>%`). Using pipes is completely optional, but you might find it helpful. Pipes make the focus of rTisane programs, conceptual models, more obvious. 

The following two programs are equivalent. The first uses pipes. The second does not. 

With pipes: 
```R
student <- Participant(name="student", cardinality=100)
race <- categories(unit=student, name="Race", cardinality=5, baseline="White")
tutoring <- categories(unit=student, name="Tutoring", cardinality=2, baseline="in-person")
ses <- categories(unit=student, name="SES", order=list("lower", "middle", "upper"))
extra <- counts(unit=student, name="Num Extra-curriculars")
testScore <- continuous(unit=student, name="Test score")

cm <- ConceptualModel() %>%
    assume(causes(ses, testScore))

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

query(conceptualModel=cm, iv=tutoring, dv=testScore)
```