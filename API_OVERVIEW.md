# API OVERVIEW

# EXTERNAL API 
## Variable declaration

### [x] Participant
```R
member <- Participant("member", caridinality=386)

motivation <- ordinal(unit=member, name="motivation", order=[1, 2, 3, 4, 5, 6])
age <- numeric(unit=member, name="age", number_of_instances=1)
pounds_lost <- numeric(unit=member, name="pounds_lost")
```

### [x] Condition
```R
condition <- condition(unit=group, "treatment", cardinality=2 number_of_instances=1)
```

## [x] Conceptual relationships
Conceptual relationships are added to a conceptual model that provides an evaluation context for queries (further below). 
Conceptual relationships are comprised of two parts: (i) a relational direction (i.e., What causes what?) and (ii) evidence for that direction (i.e., Is the end-user assuming or hypothesizing a specific relationship?). When declaring a relational direction, end-users can specify relationships in three degrees of specificity: (i) the general presence of a relationship (no specific direction, must be clarified before executing a query), a directional summary (i.e., A causes B), or a hyper-specific direction (i.e., when A is "treatment", B increases. 

TODO?: In the presence of multiple expressed relationships between the same two variables, rTisane will check....

To derive statistical models from conceptual models, rTisane reasons about relationships at the middle-level (directional summary). As a result, rTisane will ask users who provide relationships at a general level to specify further and infer direciotnal summaries from hyper-specific expressions. 

```R
cm <- ConceptualModel()
```


### [x] _Specificity_ of relationship direction 
These constructs create relationship objects that must then get added to the conceptual model based on the evidence for each relationship.
### [x] UNCERTAIN: Ambiguous direction, general conceptual relationship
The direction of relationship is unclear.
```R
# Either -->, <-- could be true; system needs to ask user for input or explore multiple paths
r0 <- relates(motivation, pounds_lost)
r1 <- relates(motivation, pounds_lost)
```

### [x] Specific relationships
```R
c0 <- causes(age, pounds_lost)
c1 <- causes(condition, pounds_lost)
```

### [x] (Hyper-) specific relationships
The benefit of these functions is (i) closer mapping to the detail with which how analysts think about causal relationships and (ii) more thorough documentation to facilitate analysts' reflection.

Return a Cause relationship.
**Idea could the specificity be used to facilitate statistical model/result interpretation?**
```R
# System: Have to infer/follow-up when not all categories in a categorical variable is stated?
# Return set of implied relationships?

# New construct 
# Concern: Too similar to ifelse? 
whenThen(when=increases(motivation), then=increases(pounds_lost))
whenThen(decreases(motivation), increases(pounds_lost))
whenThen(equals(condition, "control"), increases(pounds_lost))
whenThen(notEquals(condition, "treatment"), decreases(pounds_lost))

# Idea, not implemented:
whenThen(when=list((increases(motivation)), then=increases(pounds_lost))
```

### _Evidence_ for relationships
Specifying the evidence for a relationship adds it to the conceptual model. 
**TODO: Ask for user input if they assume an ambiguous Relates, not Causes**
### [x] Known relationship (e.g., from prior work, would be problematic if this did not exist)
```R
c <- causes(age, pounds_lost)
cm <- assume(c, cm)
# OR
cm <- assume(causes(age, pounds_lost), cm)

r <- relates(motivation, pounds_lost)
cm <- assume(r, cm)
# OR
cm <- assume(relates(motivation, pounds_lost), cm)
```
**TODO: Ask for user input if they assume an ambiguous Relates, not Causes**
### [x] Hypothesized relationship (e.g., the focus of the current ongoing research)
```R
c <- causes(condition, pounds_lost)
cm <- hypothesize(c, cm)
# OR 
cm <- hypothesize(causes(condition, pounds_lost), cm)

r <- relates(motivation, pounds_lost)
cm <- hypothesize(r, cm)
# OR
cm <- hypothesize(relates(motivation, pounds_lost), cm)
```

### 3+ variables in a relationship
## [x] Unobserved variables (for what previously was associates_with)
Can only assume, not hypothesize, relationships with Unobserved variables (enforced by function type signature). 
Must be Assume. Because (i) Unobserved variables are not measured and therefore (2) We cannot test/hypothesize unobserved relationships.

Can only say a variable causes an Unobserved variable (middle level of specificity, directional summary), not a hyper-specific relationship because that would focus more on measurement even though an Unobserved variable is defined to be not measured. 

Can also say a variable is related to an Unobserved variable (ambiguous level of specifity)
```R
#  Mediation
# age -> midlife_crisis -> pounds_lost
# age -> midlife_crisis -> motivation
midlife_crisis <- Unobserved()
cm <- assume(causes(age, midlife_crisis), cm)
cm <- assume(causes(midlife_crisis, pounds_lost), cm)
cm <- assume(causes(midlife_crisis, motivation), cm) # Must be Assume. Because (i) Unobserved variables are not measured and therefore (2) We cannot test/hypothesize unobserved relationships.

# Common ancestor
# latent_var -> age, latent_var -> motivation
latent_var <- Unobserved()
cm <- assume(causes(latent_var, age), cm)
cm <- assume(causes(latent_var, motivation), cm)
cm <- assume(causes(age, motivation), cm)
```

## [x] Potential interactions
Reuses whenThen + hypothesize/assume -- Is this a concern? <-- Separating out Specificity and Evidence!

Interactions are a conjunction of multiple "conditions" + a consequence
Why not just all conjunction?: There is an implied consequence/"directionality" of effect in interactions

```R
wt <- whenThen(when=list(increases(motivation), increases(age)), then=increases(pounds_lost))
cm <- hypothesize(wt, cm)

wt <- whenThen(when=list(equals(motivation, 'high'), increases(age)), then=increases(pounds_lost))
cm <- assume(wt, cm)
```

# Queries to issue
With an explicit handle to the conceptual model, we don't need to construct an intermediate "Study Design." We can directly assess/query the conceptual model. 

## Expressed conceptual model --> statistical model 
Which/how many IVs to specify in my query? Include variable/s whose impact on the DV you care about.  
Currently: Allow for only 1 IV at a time to avoid mutual adjustment fallacy (http://dagitty.net/learn/graphs/table2-fallacy.html)
1 IV at a time. (could treat each IV sequentially)

A query for a statistical model from a conceptual model probes into the influence of one IV on a DV in the context of the assumed + hypothesized relationships in the conceptual model. 

Confounders are selected on the basis that end-users are interested in the average causal effect ("ACE") of an independent variable on the dependent/outcome variable. Confounders are suggested based on recommendations by Cinelli, Forney, and Pearl (TR 2020) to prioritize precision of ACE estimates in regression. Causal interpretation of regression models. 

Fits and shows results of executing a statistical model + visualizing it from the conceptual model. 

Returns script for running the statistical models + visualization 
```R
query(conceptual_model=cm, iv=[list], dv=pounds_lost)
```

### Supported Family and Link functions
GLM, GLMER in lme4 ([see lme4 reference](https://github.com/lme4/lme4/blob/master/src/glmFamily.h))
Family: 
- Binomial Distribution
- Gamma
- Gaussian
- Inverse Gaussian
- Negative Binomial
- Poission

Link: "logit", "probit", "cauchit", "cloglog", "identity", "log", "sqrt", "1/mu^2", "inverse".


- cauchit
- Cloglog
- Identity
- Inverse
- Log
- Logit
- Probit
- Sqrt
- 1/mu^2

### Notes about code generation: 
- Negative Binomial: glm.nb, glmer.nb

### Programming idiom 
1. Create ConceptualModel 
3. Call updateGraph

## Expressed conceptual model vs. data
Fits and shows results of executing one or more statistical models for assessing the conceptual model. 
Returns a script for running the statistical models

Only assesses the presence of evidence for *assumed* relationships. Hypothesized relationships are discarded in the assessment.
```R
assess(conceptual_model=cm, data=data)
```

# Questions
1. Aesthetically - is it weird to not have the same gradations of specificity for interaction even though empirically we've found that interactions are difficult to reason about without (hyper-)specificity?
2. Should we add a check that the IV in a query has a hypothesized relationship (not an assumed one) to the DV? Right now, we don't check for Assumed/Hypothesized relationship between the IV and DV although the intended (?) use case is that the IV in a query is "hypothesized" implicitly. 
- Idea: If end-users assess an Assumed relationship (IV in query), ask if they want to proceed/should the relationship be hypothesized?  (interaction)
- For end-users who want to assess an Assumed relationship, what should they do? 
- Variable data types (i.e., Numeric, Ordinal, Nominal) vs. treat-as types (i.e., Continuous, Counts, Categories) -- What do we want to call this type system? Just external vs. internal types? As wrapper (current implementation) Should inherit from Measure?
  - Wrapper feels a bit "backwards" like should be removing layers of ambiguity rather than adding layers of specifity? 

## Possible inconveniences
1. Casting all parmeters using integer().
Because we override the ``numeric`` data type/function in R, end-users need to specify integer parameters by explicitly casting/specifying their parameters using ``integer``. For example: 
```R
condition <- condition(unit=participant, name="treatment", order=list("low","medium", "high"), number_of_instances=integer(1))
```
2. Do we want to provide some kind of "baseline" declaration for interactions? 
```R
suspect(when((motivation, "==low"), (age, "increases")).then(pounds_lost, "baseline"), cm) # Do we want to allow for baseline?
```
3. Especially if we go with one IV at a time, we start to see the need to facilitate/support improved interpretation of the results...

4. Does ``Assumption`` have to have a ConceptualModel piv? 

5. isObserved returns NULL if ask about Unit variable because Unit variable is not added to Conceptual Model -- This seems wrong? 

6. Might be able to get rid of disambiguation for Family/Link functions if we have a more expressive type system for data. 
- Pro of keeping in disambiguation: Keep specification focused on conceptual modeling, less focus on specific data types. Disambiguation can be for specifying data types. <Phased concerns>
- Con of keeping in disambiguation: Might be more efficient and not actually that confusing/distracting for end-user to use better type system. Could run into problem where end-user commits too prematurely? 

7. Could be nice: For zero-inflated counts, use glmmTMB rather than lme4? zero-inflated negative binomial?

8. Is it more in line with rTisane's design goals to just provide the default link functions rather than allow the end-user to select among options? Right now, we've opted for using the default + showing end-users alternatives that they can select among

9. Lme4 doesn't support multinomial, so need to use another library (https://github.com/lme4/lme4/issues/594)

10. Order in which we disambiguate the first round: Variables then Conceptual Relationships? Or Conceptual Relationships then Variables? How does the order influence the following step? 

11. Do we want to pre-check DV before allowing for casting to Continuous/Counts/Categories? For example, if there are any floats, can't be counts. 

12. Why install and use Python in R analysis session? For the Statistical Model Disambiguation process, we can rewrite in R so that end-user doesn'thave to install Python. This may be more important for adoption. For the sake of this study, it might not matter as long as we give installation scripts/instructions since our focus is on assessing the impact of conceptual modeling (technique) on the analysis process + models authored.

13. WBN: Suppress Dash/Flask output when starting Dash app 

## TODOs
- [x]Before doing any inference, check that all of the variable relationships are "Causes" not "Relates"
- Is there anything we can do with the hyper-specific information end-users provide? (maybe for interpretation?)

## Internal API 

## Data measurement relationships 
### Has 

### Nest (should be external)



## Debugging tips 
```R
library(devtools)
add browser() checkpoint
rlang::with_interactive(test_active_file())
```


For testing shiny Apps
```R
# Add to ~/.Rprofile to prevent Shiny from opening new RStudio internal browser each time
options(shiny.launch.browser = .rs.invokeShinyWindowExternal)
```