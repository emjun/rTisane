## Internal API

`updateGraph(conceptualModel)`: Updates causal graph based on relationships specified in the conceptualModel (and stored in `conceptualModel$relationships`). 
- `causes` relationships are stored as unidirectional edges. 
- `relates` relationships are stored as bidirectional edges. (Can be disambiguated.)
- `whenThen` relationships are stored as bidirectionl edges. (Can be disambiguated.)

## Query: Infer a statistical model from a conceptual model 
Steps involved in answering query: 
1. `checkConceptualModel` to detect any issues right away prior to disambiguation
2. `processQuery` to disambiguate how to treat the DV and resolve any ambiguity in the conceptual model before inferring a statistical model. Disambiguation is complete once all ambiguities are resolved and the conceptual model is validated (`checkConceptualModel`). Disambiguation occurs in a GUI.
3. `updateDV` and `updateConceptualModel` based on inputs during disambiguation. 
4. Use disambiguated DV and conceputal model to derive candidate statistical models: `inferConfounders`, `inferFamilyLinkFunctions`
5. `processStatisticalModels` to disambiguate modeling choices. Disambiguation occurs in a GUI. 
[See details about statistical model inference details and scope](STATISTICAL_MODEL_INFERENCE.md). 
