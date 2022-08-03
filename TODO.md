Explanations 
- [ ] # explanations = self.getExplanations() in createEffectPopovers()

Random effects:
- [ ] _init_help 
- [ ] randomEffects = self.getGeneratedRandomEffects()
- [ ] 'measures to units'


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

14. Keep disambiguation running in background?


15. - Is there anything we can do with the hyper-specific information end-users provide? (maybe for interpretation?)

16. How much control to give the end-user in terms of main effects to include? Should we make main effect selection in the Tisane GUI optional checkboxes? Maybe have them all selected first and then allow the end-user to de-select? 

17. Check/Validate choice of Continuous/Categories/Counts

18. Graph layout in Conceptual Model disambiguation is not stochastic, so it jumps around. That's annoying and distracting. 