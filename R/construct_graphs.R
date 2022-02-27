#' Construct graph of all relationships
#'
#' This function constructs a graph representing all relationships
#' @param all_relationships List of all relationships (edges) to include in this graph
#' @param vars List of AbstractVariables involved in the graph
#' @return Tuple of graphs: (conceptual graph, data measurement graph)
#' @import dagitty
#' @keywords
#' @examples
#' construct_graphs()
construct_graphs <- function(all_relationships, vars){
    # Get variable names
    var_names = list()
    for (v in vars) {
        var_names <- append(var_names, v@name)
    }
    stopifnot(length(var_names) == length(vars))

    # Initialize graph
    # conceptual_gr <- make_empty_graph(n = length(vars), directed = TRUE)
    # data_gr <- make_empty_graph(n = length(vars), directed = TRUE)
    # Rename vertices
    # conceptual_gr <- set_vertex_attr(conceptual_gr, "label", value = var_names)
    # data_gr <- set_vertex_attr(data_gr, "label", value = var_names)

    # Specify edges
    causal_edges = c()
    associative_edges = c()
    measurement_edges = c()
    nests_edges = c()

    for (r in all_relationships) {
      # browser()
        if (is(r, "Has")) {
            # data_gr <- add_edges(data_gr, c(r@unit@name, r@measure@name)) %>%
            #     set_edge_attr("type", value = "has") %>%
            #     set_edge_attr("color", value = "black")
            edge <- paste(r@variable@name, "->", r@measure@name)
            measurement_edges <- append(measurement_edges, edge)
        } else if (is(r, "Nests")) {
            # data_gr <- add_edges(data_gr, c(r@base@name, r@group@name)) %>%
            #     set_edge_attr("type", value = "nests") %>%
            #     set_edge_attr("color", value = "green")
            edge <- paste(r@base@name, "->", r@group@name)
            nests_edges <- append(nests_edges, edge)
        } else if (is(r, "Causes")) {
            # conceptual_gr <- add_edges(conceptual_gr, c(r@cause@name, r@effect@name)) %>%
            #     set_edge_attr("type", value = "causes") %>%
            #     set_edge_attr("color", value = "red")

            edge <- paste(r@cause@name, "->", r@effect@name)
            causal_edges <- append(causal_edges, edge)
        } else if (is(r, "Associates")) {
            # conceptual_gr <- add_edges(conceptual_gr, c(r@lhs@name,r@rhs@name, r@rhs@name,r@lhs@name)) %>%
            #     set_edge_attr("type", value = "black") %>%
            #     set_edge_attr("color", value = "blue")
            edge <- paste(r@lhs@name, "->", r@rhs@name)
            associative_edges <- append(associative_edges, edge)
            edge <- paste(r@lhs@name, "<-", r@rhs@name)
            associative_edges <- append(associative_edges, edge)
        } else if (is(r, "Moderates")) {
            
            # Construct new interaction variable
            # Get Units
            m_units = list()
            for (m in r@moderators) {
                if (is(m, "Measure")) {
                    m_units <- append(m_units, m@unit)
                } else {
                    err_msg <- paste("Moderator is of type", typeof(m), collapse=" ")
                    stop(err_msg)
                }
                # else if (is(m, "Unit")) {
                #     m_units <- append(m_units, m)
                # }
                    
            }
            # Create name
            m_names = list()
            for (m in r@moderators) {
                m_names <- append(m_names, m@name)
            }
            name = paste(m_names, collapse="_X_")
            # Calculate cardinality
            m_cardinality = as.integer(-1) # Need to calculate
            # for (m in r@moderators) {
            #     if ()
            #     m_cardinality = m_cardinality * m@cardinality
            # }
        
            var <- ModerationNominal(
                units=m_units, name=name, cardinality=m_cardinality, moderators=r@moderators
            )  

            # Add has relationships
            # for (u in var@units) {
            #     edge <- paste(u@name, "->", var@name)
            #     measurement_edges <- append(measurement_edges, edge)
            # }
            
            # Associate moderation variable with on (outcome/dependent) variable
            edge <- paste(var@name, "->", r@on@name)
            associative_edges <- append(associative_edges, edge)
            edge <- paste(var@name, "<-", r@on@name)
            associative_edges <- append(associative_edges, edge)
        } else {
            stop(paste("Not an accepted relationship type: ", typeof(r)))
        }
    }
    # Combine edges
    causal_edges <- paste(causal_edges, collapse=";")
    associative_edges <- paste(associative_edges, collapse=";")
    measurement_edges <- paste(measurement_edges, collapse=";")
    nests_edges <- paste(nests_edges, collapse=";")

    # Add edges to the graphs
    causal_dag <- paste("dag{", causal_edges, "}")
    associative_dag <- paste("dag{", associative_edges, "}")
    measurement_dag <- paste("dag{", measurement_edges, "}")
    nests_dag <- paste("dag{", nests_edges, "}")

    causal_gr <- dagitty(causal_dag)
    associative_gr <- dagitty(associative_dag)
    measurement_gr <- dagitty(measurement_dag)
    nests_gr <- dagitty(nests_dag)

    # Check that all the variables in relationships are a subset (or equal to) @param vars

    # Return graphs
    # browser()
    list(causal_gr, associative_gr, measurement_gr, nests_gr)
}
