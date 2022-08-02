# Notes on the scope of statistical models inferred from a conceptual model 

rTisane programs "compile" to scripts that use [lme4 (and related libraries)](https://github.com/lme4/lme4) to fit statistical models. 
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
