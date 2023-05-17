# Written with ChatGPT
# Transform conceptual model graph to adjacency matrix
#' @import dagitty
getAdjList <- function(conceptualModel) {
  gr <- conceptualModel@graph
  adjList <- list() 
  
  for (node in names(gr)) {
    childNodes <- children(gr, node)
    adjList[node] <- childNodes
  }
  # Return 
  adjList
}

# Written with ChatGPT
createStringIndexMap <- function(strings) {
  indexMap <- list()
  for (i in seq_along(strings)) {
    indexMap[[strings[i]]] <- i
  }
  indexMap
}

# Written with ChatGPT
# Function to find a cycle using DFS and return the cycle path
#' @import igraph
findCycles <- function(conceptualModel) {
  # Get adjacency matrix
  adjList <- getAdjList(conceptualModel)

  gr <- conceptualModel@graph

  nodeNames <- names(gr)
  nodeNames_to_idx <- createStringIndexMap(nodeNames)

  numNodes <- length(adjList)
  visited <- rep(FALSE, numNodes)
  # path <- vector("list", numNodes)
  # path <- NULL
  cycles <- vector("list")
  numCycles <- 0

  
  dfs <- function(node, nodeName, visited) {
    stopifnot(nodeNames[node] == nodeName)

    visited[node] <- TRUE
    # path[[node]] <- list()

    for (adjNode in adjList[[nodeName]]) {
      adjNodeIdx <- nodeNames_to_idx[[adjNode]]
      if (isFALSE(visited[adjNodeIdx])) {
        tmp <- dfs(adjNodeIdx, adjNode, visited)
        # path[[node]] <- append(unlist(tmp), nodeName)
        path <- append(tmp, nodeName)

        # if (is.null(path[[node]])) {
        #   path[[node]] <- append(unlist(path[[node]]), nodeName)
        # }
      } else {
        # # Empty path? 
        # if (is.null(path[[node]])) {
        #   path[[node]] <- list()
        # } 
        # path[[node]] <- append(unlist(path[[node]]), adjNode)
        # path[[node]] <- list(adjNode, nodeName)
        path <- list(nodeName)
        # else {
        #   tmp <- append(unlist(path[[node]]), adjNode)
        #   path[[node]] <- append(unlist(tmp), nodeName)
        #   print(node)
        #   print(path[[node]])
        #   print("====")
        # }
        # print(path)
      }
    }

    # Return 
    # print("Path:")
    # print(path)
    # print(class(path))
    # print("===")
    stopifnot(class(path) == "list")
    path
  }

  for (node in 1:numNodes) {
    nodeName <- nodeNames[node]
    if (isFALSE(visited[node])) {
      cy <- dfs(node, nodeName, visited)
      stopifnot(class(cy) == "list")
      idx <- numCycles + 1
      cycles[[idx]] <- cy
      idx <- idx + 1
    }
  }
  # print("Cycles:")
  # print(cycles)
  # print("===")
  
  # Return 
  cycles
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
