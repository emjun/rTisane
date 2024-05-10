# rTisane

**rTisane is an R library and interactive system for authoring statistical models from domain knowledge.** rTisane provides (i) a [domain-specific language](#rtisane-dsl) for expressing domain knowledge and (ii) an [interactive disambiguation process](#two-phase-interactive-disambiguation) for deriving an output statistical model. 

rTisane is designed for analysts who have domain expertise, are not statistical experts, and are comfortable with minimal programming (e.g., many researchers). Currently, rTisane supports authoring generalized linear models. 

## rTisane DSL
**rTisane's DSL supports expression of domain knowledge as *conceptual models.*** rTisane's DSL is implemented as an R library. 

Conceptual models describe variables in a domain and the relationships between them. In other words, conceptual models capture the underlying data generating process. 

For example, your conceptual model may look like

In the rTisane DSL it would look like
```R
cm <- ConceptualModel()%>%
    assume(causes(sex, income, 
        when=equals(sex,”Female”), then=increases(income)))%>%
    assume(relates(edu, income, 
        when=increases(edu), then=increases(income)))%>%
    hypothesize(causes(emp, income))
```

rTisane's DSL is designed to support analysts in externalizing their domain knowledge, including uncertainties they may have about the direction or existence of relationships. 

## Two-phase interactive disambiguation
**rTisane interactively derives a statistical model from a conceptual model.** rTisane guides analysts through (i) refining their conceptual models to resolve any uncertainties and (ii) narrowing the space of possible statistical models down to one output statistical model. Both occur in a graphical user interface that asks analysts specific questions. 

Note: rTisane's second interactive dismabiguation process extends the interactive compilation process in [Tisane](tisane-stats.org).

rTisane is currently an active research project at UCLA Computer Science. 