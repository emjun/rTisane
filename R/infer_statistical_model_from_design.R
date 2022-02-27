#' Infer Statistical Model from Design Function
#'
#' This function infers a statistical model from a study design.
#' @param design 
#' @keywords statistical model
#' @export
#' @examples
#' infer_statistical_model_from_design()
infer_statistical_model_from_design <- function(design){
    ### Step 0: Construct graph
    # Infer has relationships
    has_relationships <- infer_has_relationships(design=design)

    # Combine all relationships
    all_relationships <- append(design@relationships, has_relationships)

    # Construct graph from relationships
    vars <- get_all_vars(design=design)
    graphs <- construct_graphs(all_relationships, vars)
    concentual_gr <- graphs[[1]]
    measurement_gr <- graphs[[2]]
    nests_gr <- graphs[[3]]

    ### Step 1: Initial conceptual checks
    check_conceptual_relationships(conceptual_gr)

    ### Step 2: Candidate statistical model inference/generation
    # TODO: There might be some intermediate steps here
    json_file <- NULL

    ### Step 3: Disambiguation loop (GUI)
    # TODO: Call bash script to run GUI

    ### Step 4: Code generation
    # TODO: Generate code
}