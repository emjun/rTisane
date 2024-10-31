#' Infers main effects.
#'
#' This function infers main effects from a conceptual graph.
#' @param causal_gr Graph representing causal relationships between variables.
#' @param associative_gr Graph representing associative relationships between variables.
#' @param design Design
#' @return List of main effects and their explanations
#' @import dagitty
# infer_main_effects_with_explanations()
infer_main_effects_with_explanations <- function(causal_gr, associative_gr, design) {
    main_effects <- list()

    # Check if there are causal relationships
    if (length(names(causal_gr)) > 0) {
        # Rule 1: Causal parents
        causal_parents <- list()

        for (iv in design@ivs) {
            iv_name <- iv@name
            parent <- parents(causal_gr, iv_name)
            causal_parents <- append(causal_parents, parent)
        }
        main_effects <- append(main_effects, causal_parents)

        # Rule 2: Possible causal omissions
        other_causes <- parents(causal_gr, design@dv@name)
        main_effects <- append(main_effects, other_causes)
    }

    # Check if there are associative relationships that involve the DV
    if (length(names(associative_gr)) > 0 && design@dv@name %in% names(associative_gr))     {
        # Rule 3: Possible confounding associations
        assoc_intermediaries <- list()
        dv_parents <- parents(associative_gr, design@dv@name)
        for (iv in design@ivs) {
            iv_name <- iv@name
            # Find their descendants
            if (iv_name %in% names(associative_gr)) {
                desc <- descendants(associative_gr, iv_name)

                # For each descendant, is it a parent of the dv?
                for (d in desc) {
                    if (d %in% dv_parents) {
                        assoc_intermediaries <- append(assoc_intermediaries, d)
                    }
                }
            }
        }
        main_effects <- append(main_effects, assoc_intermediaries)
    }

    # Remove duplicates
    main_effects <- main_effects[!duplicated(main_effects)]

    # Return main effects
    main_effects
}
