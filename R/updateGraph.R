#' Update graph of all relationships in a Conceptual Model.
#'
#' Constructs and returns a graph representing causal relationships.
#' @param conceptualModel ConceptualModel. Conceptual Model for which to create a causal graph.
#' @return Dagitty DAG representing causal graph.
#' @import dagitty
#' @keywords
#' @examples
#' updateGraph()
updateGraph <- function(conceptualModel){
  # Get variable names
  varNames = list()
  for (v in conceptualModel@variables) {
    varNames <- append(varNames, v@name)
  }
  stopifnot(length(varNames) == length(conceptualModel@variables))

  # Specify edges
  causalEdges = c()
  # measurement_edges = c()
  # nests_edges = c()

  for (relat in conceptualModel@relationships) {
    if (is(relat, "Assumption")) {
      r = relat@relationship
      if(is(r, "Causes")) {
        edge <- paste(r@cause@name, "->", r@effect@name)
        causalEdges <- append(causalEdges, edge)
      }
    } else if (is(relat, "Hypothesis")) {
      r = relat@relationship
      if(is(r, "Causes")) {
        edge <- paste(r@cause@name, "->", r@effect@name)
        causalEdges <- append(causalEdges, edge)
      }
    }
  }
  #   if (is(r, "Has")) {
  #     # data_gr <- add_edges(data_gr, c(r@unit@name, r@measure@name)) %>%
  #     #     set_edge_attr("type", value = "has") %>%
  #     #     set_edge_attr("color", value = "black")
  #     edge <- paste(r@variable@name, "->", r@measure@name)
  #     measurement_edges <- append(measurement_edges, edge)
  #   } else if (is(r, "Nests")) {
  #     # data_gr <- add_edges(data_gr, c(r@base@name, r@group@name)) %>%
  #     #     set_edge_attr("type", value = "nests") %>%
  #     #     set_edge_attr("color", value = "green")
  #     edge <- paste(r@base@name, "->", r@group@name)
  #     nests_edges <- append(nests_edges, edge)
  #   } else if (is(r, "Causes")) {
  #     # conceptual_gr <- add_edges(conceptual_gr, c(r@cause@name, r@effect@name)) %>%
  #     #     set_edge_attr("type", value = "causes") %>%
  #     #     set_edge_attr("color", value = "red")
  #
  #     edge <- paste(r@cause@name, "->", r@effect@name)
  #     causal_edges <- append(causal_edges, edge)
  #   }else if (is(r, "Moderates")) {
  #
  #     # Construct new interaction variable
  #     # Get Units
  #     m_units = list()
  #     for (m in r@moderators) {
  #       if (is(m, "Measure")) {
  #         m_units <- append(m_units, m@unit)
  #       } else {
  #         err_msg <- paste("Moderator is of type", typeof(m), collapse=" ")
  #         stop(err_msg)
  #       }
  #       # else if (is(m, "Unit")) {
  #       #     m_units <- append(m_units, m)
  #       # }
  #
  #     }
  #     # Create name
  #     m_names = list()
  #     for (m in r@moderators) {
  #       m_names <- append(m_names, m@name)
  #     }
  #     name = paste(m_names, collapse="_X_")
  #     # Calculate cardinality
  #     m_cardinality = as.integer(-1) # Need to calculate
  #     # for (m in r@moderators) {
  #     #     if ()
  #     #     m_cardinality = m_cardinality * m@cardinality
  #     # }
  #
  #     var <- ModerationNominal(
  #       units=m_units, name=name, cardinality=m_cardinality, moderators=r@moderators
  #     )
  #
  #     # Add has relationships
  #     # for (u in var@units) {
  #     #     edge <- paste(u@name, "->", var@name)
  #     #     measurement_edges <- append(measurement_edges, edge)
  #     # }
  #
  #     # Associate moderation variable with on (outcome/dependent) variable
  #     edge <- paste(var@name, "->", r@on@name)
  #     associative_edges <- append(associative_edges, edge)
  #     edge <- paste(var@name, "<-", r@on@name)
  #     associative_edges <- append(associative_edges, edge)
  #   } else {
  #     stop(paste("Not an accepted relationship type: ", typeof(r)))
  #   }
  # }
  # Combine edges
  causalEdges <- paste(causalEdges, collapse=";")
  # associative_edges <- paste(associative_edges, collapse=";")
  # measurement_edges <- paste(measurement_edges, collapse=";")
  # nests_edges <- paste(nests_edges, collapse=";")

  # Add edges to the graphs
  causalDag <- paste("dag{", causalEdges, "}")
  # associative_dag <- paste("dag{", associative_edges, "}")
  # measurement_dag <- paste("dag{", measurement_edges, "}")
  # nests_dag <- paste("dag{", nests_edges, "}")
  # causal_gr <- dagitty(causal_dag)
  # associative_gr <- dagitty(associative_dag)
  # measurement_gr <- dagitty(measurement_dag)
  # nests_gr <- dagitty(nests_dag)

  # Save updated graph
  # conceptualModel@graph <- dagitty(causalDag)

  # Return updated graph
  # conceptualModel@graph
  dagitty(causalDag)
  }
