# Example 0: Toy example
Relationships: Hypothesize Causes only
Data: No data
Script: [example0.R](examples/example0.R)
Status: Working!

# Example 1 (from summative eval Income dataset)
Relationships: Assume Causes, Hypothesize Relates
Data: [WA income data](examples/data/2019_WA_income.csv)
Script: [example1.R](examples/example1.R)
Notes: 
- Must disambiguate a direction even for a hypothesized relationship. The directionality helps us to (i) validate the conceptual model and (ii) derive confounders. 

# Example 2 (from summative eval Income dataset)
Relationships: Assume Causes, Assume Relates, Hypothesize whenThen 
Data: [WA income data](examples/data/2019_WA_income.csv)
Script: [example2.R](examples/example2.R)

# TODO: 
- CHECK CONCEPTUAL MODEL PRIOR TO DISAMBIGUATION!
- Examples where there no hypothesize (invalidate early check)
