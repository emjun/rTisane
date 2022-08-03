# Notes on the scope of statistical models inferred from a conceptual model 
rTisane programs "compile" to scripts that use [lme4 (and related libraries)](https://github.com/lme4/lme4) to fit statistical models. 

## How are confounders selected? 
We follow the guidelines from [Cinelli, Forney, and Pearl, 2022](https://ftp.cs.ucla.edu/pub/stat_ser/r493.pdf). I chose this because (i) it was more comprehensive, covering the guidelines in the modified disjunctive criteria; (ii) more directly appliable to our setting/how I am thinking about querying a conceptual model; and (iii) more recent.

This diverges from what Tisane implements, which is the [modified disjunctive criteria](https://link.springer.com/article/10.1007/s10654-019-00494-6). 

To infer statistical models, we must infer confounders. To do so, we use all assumed and hypothesized relationships. This means that the confounders and statistical model are for the context of the causal graph/conceptual model specified.  
### Supported Family and Link functions
GLM, GLMER in lme4 ([see lme4 reference](https://github.com/lme4/lme4/blob/master/src/glmFamily.h))
Family: 
- Binomial Distribution
- Gamma
- Gaussian
- Inverse Gaussian
- Negative Binomial
- Poission

Link functions: 
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
