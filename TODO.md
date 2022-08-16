
# Discussion points 
Focus is on technique of eliciting conceptual models to prompt reflection during authoring process. 


## How the language structures thought 
`nestsWithin` as a parameter when constructing Units --> requires people to specify outer group first to be able to pass it as a `nestsWithin` parameter.
- Design considerations: (i) a Unit usually nests within only 1 other Unit, (ii) a Unit can nest multiple Units though. 

How analysts express their variables indicates how they are thinking about the problem/implicit assumptions about independence. For example, do they list "State" as a Unit and "Participant" as a Unit nested within State? This would trigger rTisane to treat State as a grouping variable and include a random effect. However, maybe people want to assume independence between observations? Is this right? Should it be a bigger deal for them to move away from nesting/random effects towards independent observations? 

- TODO: Should we have a notion of SetUp like "Time" and "Trial" or allow for declaration of variables that do not have a unit (e.g., ``numeric("week")`` and ``ordinal("trial")``) where the assumption is that these variables do not belong to a specific Unit but rather belong to all of them in a sense?  --> What would this allow in terms of non-nesting relationships?
--> For now, implement Time 

## Statistical model inference 
Random effects inference 
- Repeated measures --> email Dale Barr? 

## Disambiguation interaction design
Conceptual model disambiguation 
1. Remove the Dependent Variable tab and put it in statistical model disambiguation process? Separate step? 
    - Motivation for current design: Observation that people are surprised by what their DV looks like, and this surprise should happen earlier in the process *before* infer/get to phase of considering statistical models. 
2. If we keep both: Order in which we disambiguate the first round: Variables then Conceptual Relationships? Or Conceptual Relationships then Variables? How does the order influence the following step? 
3. (may need to hack around to change the layout algo/keep the graph steady.) Graph layout (uses "Spring") in Conceptual Model disambiguation is stochastic, so it jumps around. That's annoying and distracting. 

Connecting conceptual model and statistical model disambiguation 
1. Combine them into one interface? 
    - Motivation behind current design: Designed them to be separate because had idea that if end-user gets familiar with the API, they can avoid the first round of conceptual model disambiguation and dive into statistical model disambiguation. 
    - Alternative: Update program to show code result of conceptual model disambiguation? (Concern: Non-coders?)

Statistical model disambiguation 
1. Do we want to keep main effect selection in the GUI as checkboxes? What if end-user deselects confounders that are important to account for?


## Major differences between rTisane and Tisane 


## Important limitations 
Family/link functions: 
    - **Is it more in line with rTisane's design goals to just provide the default link functions rather than allow the end-user to select among options? Right now, we've opted for using the default + showing end-users alternatives that they can select among**
    - lme4 doesn't support multinomial linear models, so we need to use another library if we want to support multinomial family. (https://github.com/lme4/lme4/issues/594) -- **Is this necessary for the eval? (seems like not depending on our datasets)**
    - For zero-inflated counts, use glmmTMB rather than lme4? zero-inflated negative binomial?

## TODO: Summative evaluation idea 
- Focus on GLM (make eval shorter?)
    - Motivation: Since focus is on conceptual modeling
    - Concern: This is too narrow/focused?
    - Think of GLM as conceptual core and then GLMM as study design/data collection details as a variable to add in 

## Summative Evaluation 
Treatment: rTisane
Control/baseline: scaffolded workflow 

We hypothesize that this will lead to a different analysis process (could mean less iteration after seeing model/results, could be steps in a different order). 
- For example, when using rTisane we might see that analysts spend less time trying multiple family and link functions because rTisane narrows the choices sufficiently. 

We also hypothesize that this process of becoming aware of implicit conceptual models (and assumptions more generally) and using this information during the authoring process will lead to statistical models that 
- (i) account for confounding more accurately (as judged by statistician), 
- (ii) reflect the data collection procedure more accurately (as judged by statistician),
- (iii) use appropriate family/link functions (as judged by statistician or us)

New ideas: 
- Measure generalizability (ii): Use random sample of dataset for study; assess resulting models with remainder of dataset after lab study (compare AIC/BIC, robustness of coefficient magnitude + sign)
- Add a fourth outcome?: (iv) Statistical models authored using rTisane are more precise in estimating causal effects (because of how confounders are selected/included). --> Need to look into methods using simulations + real datasets.

## Features to implement
*Update API OVERVIEW along the way*

1. Interactions 
    - [Example program](examples/example3.R) 
    - Design decisions:
        - Don't need to disambiguate interaction effects in the same way as binary relationships. Include as suggested interaction effect (during statistical model disambiguation) if one or more of the variables is included as the IV or confounders? 
            - Motivation: Tisane represents an interaction as a new variable in the graph. I'm thinking about taking a different approach in rTisane since interaction effects aren't reasoned about in quite the same way. 

2. Random effects:
    - [ ] _init_help 
    - [ ] randomEffects = self.getGeneratedRandomEffects()
    - [ ] 'measures to units'

3. Code generation

4. Conceptual model disambiguation: Questions for narrowing family/link based on data 

5. Explanations
    - [ ] # explanations = self.getExplanations() in createEffectPopovers()

6. More checks  
    - Add a check that the IV in a query has a hypothesized relationship (not an assumed one) to the DV. 
    - Idea: If end-users assess an Assumed relationship (IV in query), ask if they want to proceed/should the relationship be hypothesized?  (interaction)
    - Do we want to pre-check DV before allowing for casting to Continuous/Counts/Categories? For example, if there are any floats, can't be counts. 

7. Consider renaming `numeric` since casting all parmeters using integer() can be tedious.
    - Because we override the ``numeric`` data type/function in R, end-users need to specify integer parameters by explicitly casting/specifying their parameters using ``integer``. For example: 
  ```R
  condition <- condition(unit=participant, name="treatment", order=list("low","medium", "high"), numberOfInstances=integer(1))
  ```

8. Make GUIs look better. 
    - Little titles and breaks for questions/sections.
    - Make Conceptual Model disambiguation GUI look like Statistical Modeling one? Add sidepanel.
    
9. Language implementation details: 
  - Does ``Assumption`` have to have a ConceptualModel piv? 
  - `isObserved` returns NULL if ask about Unit variable because Unit variable is not added to Conceptual Model -- This seems wrong? 
  - Update selectInput generation to take a dataframe from input.json NOT list of three lists

10. Stress test with edge cases
    - In the presence of ambiguous relationships, such as multiple expressed relationships between the same two variables, rTisane will check ask for what the analyst intends to communicate at the level of a directional summary.


## Language design questions 
1. Aesthetically - is it weird to not have the same gradations of specificity for interaction even though empirically we've found that interactions are difficult to reason about without (hyper-)specificity?

2. Do we want to provide some kind of "baseline" declaration for interactions? 
```R
suspect(when((motivation, "==low"), (age, "increases")).then(pounds_lost, "baseline"), cm) # Do we want to allow for baseline?
```

## Timeline
- Add interaction (rest of this week)
- Mixed effects (2-3 days)
- Start recruiting participants + line them up! (dates?)
- Sytem study-ready: by Aug. 22 
- Aug. 22: Upload + test on CRAN 
- Weeks of Aug. 22, Aug. 29, some into Sept. 5: Run study! 


## Future work
- Is there anything we can do with the hyper-specific information end-users provide? (maybe for interpretation?)

- Since we are going with one IV at a time, we start to see the need to facilitate/support improved interpretation of the results.

- Why install and use Python in R analysis session? For the Statistical Model Disambiguation process, we can rewrite in R so that end-user doesn'thave to install Python. This may be more important for adoption. For the sake of this study, it might not matter as long as we give installation scripts/instructions since our focus is on assessing the impact of conceptual modeling (technique) on the analysis process + models authored.

- WBN: Suppress Dash/Flask output when starting Dash app 

- Make rTisane statistical model GUI a separate repo/pypi package? Or just rewrite in R...?

- Write blog comparing Dash and Shiny 

- Write blog comparing statsmodels, lme4