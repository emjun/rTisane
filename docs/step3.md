## Step 3: Query rTisane for a statistical model
Finally, once you have declared variables and specified a conceptual model, you can query the conceptual model for a statistical model!

The `query` captures the relationship you are interested in assessing.

`query` has the following parameters: 
- `conceptualModel`: ConceptualModel
- `iv`: Measure. The independent variable whose effect on the dependent variable you are interested in estimating
- `dv`: Measure. The dependent variable, or outcome, you are interested in
- `data`: Pathlike or Dataframe. (optional) Either the path to a dataset (a CSV in long format) or a Dataframe. 

For example, you can specify
```R
query(conceptualModel=cm, dv=testScore, iv=tutoring)
# with a path to data 
query(conceptualModel=cm, dv=testScore, iv=tutoring, data="data.csv")
# with a dataframe (df) that you have already imported
query(conceptualModel=cm, dv=testScore, iv=tutoring, data=df) 
```

*Important note:* In order to infer a statistical model, there must be a hypothesized relationship between the `iv` and `dv`.

Executing the `query` will initiate an interactive process to clarify the input conceptual model and present you with a few follow-up questions necessary to infer a statistical model. 

See a video here: 
# TODO: Video of running program + disambiguation loops

## Output
The result of executing an rTisane program (and engaging in the interactive process) is a script with code for fitting a statistical model to assess the average treatment effect of the IV on the DV in your query. 

The last thing to do is to specify data in your script (when you have it) and run your script!
```R
source("model.R")
```