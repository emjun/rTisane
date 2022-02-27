#' Infers interaction/moderation effects.
#'
#' This function infers main effects from a conceptual graph.
#' @param causal_gr Graph representing causal relationships between variables.
#' @param associative_gr Graph representing associative relationships between variables.
#' @param design Design
#' @return List of main effects and their explanations
#' @import dagitty
#' @keywords
#' @examples
#' infer_interaction_effects_with_explanations()
infer_interaction_effects_with_explanations <- function(causal_gr, associative_gr, design) {
    interaction_effects = list()

    # Process string rep of graph
    gr_str = strsplit(associative_gr[[1]], "\n")[[1]]

    vertices = list()
    for (s in gr_str) {
        # Opening or Ending of DAG
        if (grepl("{", s, fixed=TRUE) || grepl("}", s, fixed=TRUE)) {
            # pass
        } else if (grepl("->", s, fixed=TRUE)) {
            # pass
        } else {
            vertices <- append(vertices, s)
        }
    }

    for (v in vertices) {
        # Is this an interaction/moderation effect?
        if (grepl("_X_", v, fixed=TRUE)) {
            interaction_effects <- append(interaction_effects, v)
        }
    }

    # Return interaction/moderation effects
    interaction_effects
}

