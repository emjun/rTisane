# Written with ChatGPT
# Transform conceptual model graph to adjacency matrix
#' @import dagitty
getAdjMatrix <- function(conceptualModel) {
  gr <- conceptualModel@graph

  # Extract the adjacency list manually
  nodes <- names(gr)
  adjList <- vector("list", length(nodes))

  for (i in 1:length(nodes)) {
    adjList[[i]] <- parents(gr, nodes[i])
  }

  # Return
  adjList
}

# Written with ChatGPT
# Function to find a cycle using DFS and return the cycle path
#' @import igraph
findCycles <- function(conceptualModel) {
  # Get adjacency matrix
  adjList <- getAdjMatrix(conceptualModel)

  # # Helper function for DFS traversal
  # dfs <- function(node, visited, stack, path) {
  #   visited[node] <- TRUE
  #   stack[node] <- TRUE
  #   path <- c(path, node)  # Add current node to the path
    
  #   # Perform DFS on adjacent nodes
  #   for (adjNode in adjList[[node]]) {
  #     if (isFALSE(visited[adjNode])) {
  #       if (dfs(adjNode, visited, stack, path))
  #         return(TRUE)
  #     } else if (isTRUE(stack[adjNode])) {
  #       # Cycle detected, return the path
  #       # cycleStartIndex <- match(adjNode, path)
  #       # cycle <- path[cycleStartIndex:length(path)]
  #       cycle[[length(cycle) + 1]] <- adjNode
  #       return(TRUE)
  #     }
  #   }
    
  #   stack[node] <- FALSE  # Remove node from the recursion stack
  #   return(FALSE)
  # }
  
  # # Initialize visited, recursion stack, and path
  # numNodes <- length(adjList)
  # visited <- rep(FALSE, numNodes)
  # stack <- rep(FALSE, numNodes)
  # path <- c()
  
  # # Perform DFS traversal from each unvisited node
  # for (node in 1:numNodes) {
  #   if (isFALSE(visited[node])) {
  #     if (dfs(node)) {
  #       cycle[[length(cycle) + 1]] <- node
  #       return(unlist(cycle))
  #     }
  #   }
  # }

  
  # return(NULL)  # No cycle found

  return (list("A --> B --> C")) # a cycle
}


#' Check Conceptual Model (graph) is valid, meaning there are no cycles and that the @param dv does not cause @param iv
#' Use once have a query (i.e., iv and dv) of interest
#'
#' This function validates the Conceptual Model
#' @param conceptualModel ConceptualModel. Causal graph to validate.
#' @param iv AbstractVariable. Independent variable that should cause (directly or indirectly) the @param dv.
#' @param dv AbstractVariable. Dependent variable that should not cause the @param iv.
#' @return TRUE if the Conceptual Model is valid, FALSE otherwise
#' @import dagitty
#' @keywords
# checkConceptualModel()
setGeneric("checkConceptualModel", function(conceptualModel, iv, dv) standardGeneric("checkConceptualModel"))
setMethod("checkConceptualModel", signature("ConceptualModel", "AbstractVariable", "AbstractVariable"), function(conceptualModel, iv, dv)
{

  gr <- conceptualModel@graph
  nodes <- names(gr) # Get the names of nodes in gr

  # Check that IV is in the Conceptual Model
  if (!(iv@name %in% nodes)) {
    msg <- paste("IV", iv@name, "is not in the conceptual model.", sep=" ")
    output <- list(isValid=FALSE, reason=msg)
    return(output)
  }

  # Check that DV is in the Conceptual Model
  if (!(dv@name %in% nodes)) {
    msg <- paste("DV", dv@name, "is not in the conceptual model.", sep=" ")
    output <- list(isValid=FALSE, reason=msg)
    return(output)
  }

  # Check that there is a path between IV and DV if there are any edges in the graph
  p <- paths(gr, iv@name, dv@name)
  if(length(p[[1]]) <= 0) {
    output <- list(isValid=FALSE, reason="Graph has no relationships.")
    return(output)
  }

  # Check that DV does not cause IV
  dvCausingIv = paste(iv@name, "<-", dv@name)
  if (p[[1]][1] == dvCausingIv) {
    output <- list(isValid=FALSE, reason="DV cannot cause IV.")
    return(output)
  }

  # # Check that there are no cycles
  # if (isFALSE(isAcyclic(gr))) {
  #   output <- list(isValid=FALSE, reason="Graph is cyclic.")
  #   return(output)
  # }

  # Return TRUE if pass all the above checks
  list(isValid=TRUE)
})
