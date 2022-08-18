
# Discussion points 
Two observations to discuss: 

- Disambiguation is not really necessary with improved language constructs and inference techniques. Necessary for (i) "fixing" conceptual model (if necessary), (ii) specifying how to treat DV, and (iii) picking a family/link function. In a sense the disambiguation process is mostly necessary for going for one step deeper/closer to statistical model implementation in the hypothesis formalization process. 

- Focus is on technique of eliciting conceptual models to prompt reflection during authoring process. Therefore, what if we focused on evaluating the impact of this conceptual modeling on the authoring process by focusing on GLMs instead of introducing more language constructs for data measurement details that are necessary for GLMMs? (See "Summative Evaluation" below). 

## TO DISCUSS: Summative evaluation idea 
Idea: Focus on GLM 
    - Motivation: Since focus is on conceptual modeling
    - Concern: This is too narrow/focused?
    - Concern: Not an evaluation of the complete capabilities of rTisane. 
    - Nice control: Think of GLM as conceptual core and then GLMM as study design/data collection details as a variable to add in 

### Overall design
- 2 (dataset) x 2 (tool) within-subjects
- Treatment: rTisane
- Control/baseline: scaffolded workflow 
- Particiants: Upwork, mailing lists; incentivize helping with statistical analyses for CHI?
- N: 30ish? -- What is humanly possible in the next 3 weeks (with/without help)

### Tasks -- Any way to reduce this?
- State personal conceptual model
- Author statistical model for conceptual model
- Author statistical models for presented conceptual models

### Research questions and Hypotheses
> What are the most important results?: 
> - Errors (quantitative), 
> - Conceptual model (mostly descriptive, some frequency stats), 
> - Statistical model (mostly descriptive, some frequency stats) 


Authored statistical models
- **RQ 1 - Errors:** What errors are analysts more likely to make when formulating statistical models without vs. with rTisane?

    - **Hypothesis 1 - Errors:** We hypothesize that this process of becoming aware of implicit conceptual models (and assumptions more generally) and using this - information during the authoring process will lead to statistical models that (quantitative, qualitative)
        - (i) account for confounding more accurately (as judged by statistician, measure: # of errors, frequency certain kinds of causal structures get overlooked), 
        - [no longer applies if focus on GLMs?] (ii) reflect the data collection procedure more accurately (as judged by statistician),
        - (iii) use appropriate family/link functions (as judged by statistician or us, measure: # of errors)

 
- **RQ 2 - Statistical models**: When analysts use rTisane, are the statistical models authored descriptively different than when following a structured workflow?

    - **Hypothesis 2 - Statistical models:** We hypothesize that the statistical models authored using rTisane will be descriptively different from those authored - without rTisane. 

- **RQ 3 - Expertise’s influence on models:** How does statistical expertise influence the authored statistical models?
 
    - **Hypothesis 3 - Expertise’s influence on models:** -

Authoring process

- **RQ 4 - DSL:** How does using the DSL to specify conceptual models impact the conceptual models analysts express? 

    - **Hypothesis 5 - DSL:** We hypothesize that the DSL will be productive in prompting reflection on conceptual assumptions. (Should see a carryover effect in numbers - of relationships stated, etc?)
 
- **RQ5 - Reasoning:** What are the implicit guidelines analysts use to derive statistical models from their conceptual models? How do they compare to formal causal - reasoning rules rTisane employs?
 
    - **Hypothesis 5 - Reasoning:** - 

- **RQ6 - Expertise’s influence on process:** How does statistical expertise influence the statistical model authoring processes? Does Tisane impact those with - little-to-no modeling experience differently than those with more experience?
 
    - **Hypothesis 6 - Expertise's influence on process:** - 


### Additional measures ideas
- Survey questions about awareness of assumptions, focus areas
- Measure generalizability (for ii): Use random sample of dataset for study; assess resulting models with remainder of dataset after lab study (compare AIC/BIC, robustness of coefficient magnitude + sign)
- Add a fourth outcome?: (iv) Statistical models authored using rTisane are more precise in estimating causal effects (because of how confounders are selected/included). --> Need to look into methods using simulations + real datasets.

## Timeline
- Add interaction (rest of this week)
- Start recruiting participants + line them up! (dates?)
- System study-ready: by Aug. 22 
- Aug. 22: Upload + test on CRAN 
- Pilot: early next week? 
- Weeks of Aug. 22, Aug. 29, some into Sept. 5: Run study! 

## Language design questions 
1. (x) Aesthetically - is it weird to not have the same gradations of specificity for interaction even though empirically we've found that interactions are difficult to reason about without (hyper-)specificity? --> Stick with our observations from the qual lab study.

2. (may no longer need) Do we want to provide some kind of "baseline" declaration for interactions? 
```R
suspect(when((motivation, "==low"), (age, "increases")).then(pounds_lost, "baseline"), cm) # Do we want to allow for baseline?
```
3. For random effects: Should we have a notion of SetUp like "Time" and "Trial" or allow for declaration of variables that do not have a unit (e.g., ``numeric("week")`` and ``ordinal("trial")``) where the assumption is that these variables do not belong to a specific Unit but rather belong to all of them in a sense?  --> What would this allow in terms of non-nesting relationships? --> For now, implement Time 

## Overall Interaction Design
State conceptual model, disambiguate [fixpoint] 
Disambiguate DV [fixpoint] 
Main effects (inferred) [fixpoint] 
Interaction (inferred) [fixpoint] 
Random + family/link [fixpoint] 
Generate code [endpoint]

## Statistical model inference 
Random effects inference 
- Repeated measures --> 

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


## Important limitations 
Family/link functions: 
    - **Is it more in line with rTisane's design goals to just provide the default link functions rather than allow the end-user to select among options? Right now, we've opted for using the default + showing end-users alternatives that they can select among**
    - lme4 doesn't support multinomial linear models, so we need to use another library if we want to support multinomial family. (https://github.com/lme4/lme4/issues/594) -- **Is this necessary for the eval? (seems like not depending on our datasets)**
    - For zero-inflated counts, use glmmTMB rather than lme4? zero-inflated negative binomial?


## TODO: Major differences between rTisane and Tisane 

## NEED TO UPDATE: Features to implement
*Update API OVERVIEW along the way*
1. Interactions 
    - [Example program](examples/example3.R) 
    - [ ] External API + tests 
    - [ ] Statistical model inference rules + tests
    - Design decisions:
        - Don't need to disambiguate interaction effects in the same way as binary relationships. Include as suggested interaction effect (during statistical model disambiguation) if one or more of the variables is included as the IV or confounders? 
            - Motivation: Tisane represents an interaction as a new variable in the graph. I'm thinking about taking a different approach in rTisane since interaction effects aren't reasoned about in quite the same way. 

2. Code generation

3. Conceptual model disambiguation: Questions for narrowing family/link based on data 

4. (may not need) Explanations
    - [ ] # explanations = self.getExplanations() in createEffectPopovers()
5. More checks  
    - Add a check that the IV in a query has a hypothesized relationship (not an assumed one) to the DV. 
    - Idea: If end-users assess an Assumed relationship (IV in query), ask if they want to proceed/should the relationship be hypothesized?  (interaction)
    - Do we want to pre-check DV before allowing for casting to Continuous/Counts/Categories? For example, if there are any floats, can't be counts. 

6. Consider renaming `numeric` since casting all parmeters using integer() can be tedious.
    - Because we override the ``numeric`` data type/function in R, end-users need to specify integer parameters by explicitly casting/specifying their parameters using ``integer``. For example: 
  ```R
  condition <- condition(unit=participant, name="treatment", order=list("low","medium", "high"), numberOfInstances=integer(1))
  ```

7. Make GUIs look better. 
    - Little titles and breaks for questions/sections.
    - Make Conceptual Model disambiguation GUI look like Statistical Modeling one? Add sidepanel.
    
8. Language implementation details: 
  - Does ``Assumption`` have to have a ConceptualModel piv? 
  - `isObserved` returns NULL if ask about Unit variable because Unit variable is not added to Conceptual Model -- This seems wrong? 
  - Update selectInput generation to take a dataframe from input.json NOT list of three lists

9. Stress test with edge cases
    - In the presence of ambiguous relationships, such as multiple expressed relationships between the same two variables, rTisane will check ask for what the analyst intends to communicate at the level of a directional summary.

10. [hold off] Random effects:
    - [ ] _init_help 
    - [ ] randomEffects = self.getGeneratedRandomEffects()
    - [ ] 'measures to units'

## Language design observations 
*Analysts' stated conceptual assumptions drive their statistical models.*
Example: How analysts express their variables indicates how they are thinking about the problem/implicit assumptions about independence. For example, do they list "State" as a Unit and "Participant" as a Unit nested within State? This would trigger rTisane to treat State as a grouping variable and include a random effect. However, maybe people want to assume independence between observations? Is this right? Should it be a bigger deal for them to move away from nesting/random effects towards independent observations?

*How the language structures thought*
`nestsWithin` as a parameter when constructing Units --> requires people to specify outer group first to be able to pass it as a `nestsWithin` parameter.
- Design considerations: (i) a Unit usually nests within only 1 other Unit, (ii) a Unit can nest multiple Units though. 
- Nice effect: program looks nested since subgroup (i.e., student) comes after group (i.e., family). 


## Future work
- Is there anything we can do with the hyper-specific information end-users provide? (maybe for interpretation?)

- Since we are going with one IV at a time, we start to see the need to facilitate/support improved interpretation of the results.

- Why install and use Python in R analysis session? For the Statistical Model Disambiguation process, we can rewrite in R so that end-user doesn'thave to install Python. This may be more important for adoption. For the sake of this study, it might not matter as long as we give installation scripts/instructions since our focus is on assessing the impact of conceptual modeling (technique) on the analysis process + models authored.

- WBN: Suppress Dash/Flask output when starting Dash app 

- Make rTisane statistical model GUI a separate repo/pypi package? Or just rewrite in R...?

- Write blog comparing Dash and Shiny 

- Write blog comparing statsmodels, lme4