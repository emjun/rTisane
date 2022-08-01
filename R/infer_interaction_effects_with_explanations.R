#' Infers interaction/moderation effects.
#'
#' This function infers interaction/moderation effects from a conceptual graph.
#' @param causal_gr Graph representing causal relationships between variables.
#' @param associative_gr Graph representing associative relationships between variables.
#' @param design Design
#' @return List of interaction/moderation effects and their explanations
#' @import dagitty
#' @keywords
# infer_interaction_effects_with_explanations()
infer_interaction_effects_with_explanations <- function(causal_gr, associative_gr, design, main_effects) {
    interaction_effects = list()

    ## Generate interaction effects
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

    ## Filter interaction_effects to only include those that involve two or more main effects
    filtered_interaction_effects = list()
    for (ixn in interaction_effects) {
        num_vars <- as.integer(0)
        for (me in main_effects) {
            if (grepl(me, ixn, fixed=TRUE)) {
                num_vars = num_vars + 1
            }
        }

        if (num_vars >= 2) {
            filtered_interaction_effects <- append(filtered_interaction_effects, ixn)
        }
    }

    # Return interaction/moderation effects
    filtered_interaction_effects
}


