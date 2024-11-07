#' Transform conceptual model graph to adjacency matrix
#'
#' This function takes a graph and represents its adjacency matrix representation
#' @param conceptualModel ConceptualModel
#' @return list of lists representing adjacency matrix of graph
#' @import dagitty
# getAdjList()
# Written with ChatGPT
getAdjList <- function(conceptualModel) {
  gr <- conceptualModel@graph
  adjList <- list() 
  
  for (node in names(gr)) {
    childNodes <- children(gr, node)
    # There are no children
    if (length(childNodes) == 0)  {
      adjList[node] <- NULL
    } else {
      adjList[node] <- childNodes
    }
  }
  # Return 
  adjList
}

#' Generate map from strings to indices
#'
#' This function helps map variable names to their numeric representation in the underlying graph
#' @param strings list of variable names
#' @return Dict of variable names (keys) to their corresponding indices (values)
# createStringIndexMap()
# Written with ChatGPT
createStringIndexMap <- function(strings) {
  indexMap <- list()
  for (i in seq_along(strings)) {
    indexMap[[strings[i]]] <- i
  }
  indexMap
}


#' Find a cycle using DFS and return the cycle path
#'
#' This function searches for a cycle
#' @param conceptualModel ConceptualModel that may contain a cycle
#' @return Return cycles (using variable names) in graph
#' @import igraph
#' findCycles()
# Written with ChatGPT
findCycles <- function(conceptualModel) {
  # namespaceImportFrom(dagitty, edges)
  # print("Start findCycles")
  # Get adjacency matrix
  # adjList <- getAdjList(conceptualModel)
  # numNodes <- length(adjList)
  # visited <- rep(FALSE, numNodes)
  # cycles <- vector("list")
  # numCycles <- 0

  gr <- conceptualModel@graph
  nodeNames <- names(gr)
  nodeNames_to_idx <- createStringIndexMap(nodeNames)
  
  edgeList <- as.matrix(dagitty::edges(gr)[1:2])
  g <- igraph::graph_from_edgelist(edgeList)
  
  # Adapted from https://stackoverflow.com/questions/55091438/r-igraph-find-all-cycles
  Cycles = NULL
  for(v1 in igraph::V(g)) {
      if(igraph::degree(g, v1, mode="in") == 0) { next }
      GoodNeighbors = igraph::neighbors(g, v1, mode="out")
      GoodNeighbors = GoodNeighbors[GoodNeighbors > v1]
      for(v2 in GoodNeighbors) {
          TempCyc = lapply(igraph::all_simple_paths(g, v2,v1, mode="out"), function(p) c(v1,p))
          TempCyc = TempCyc[which(sapply(TempCyc, length) > 2)]
        TempCyc = TempCyc[sapply(TempCyc, min) == sapply(TempCyc, `[`, 1)]
        Cycles  = c(Cycles, TempCyc)
      }
  }

  # Transform indices into names 
  named_cycles <- NULL
  idx <- 1
  for (cy in Cycles) {
    tmp <- NULL
    for (i in 1:length(cy)) {
      nodeIdx <- cy[i]
      tmp <- append(tmp, nodeNames[nodeIdx])
    }
    stopifnot(length(tmp) == length(cy))
    named_cycles[[idx]] <- tmp
    idx <- idx + 1
  }
  # Cycles
  # Return 
  named_cycles

  
  # dfs <- function(node, nodeName, visited) {
  #   stopifnot(nodeNames[node] == nodeName)

  #   visited[node] <- TRUE
  #   path <- list()

  #   # 
  #   for (adjNode in adjList[[nodeName]]) {
  #     adjNodeIdx <- nodeNames_to_idx[[adjNode]]
  #     if (isFALSE(visited[adjNodeIdx])) {
  #       tmp <- dfs(adjNodeIdx, adjNode, visited)
  #       path <- append(nodeName, tmp)
  #     } else {
  #       path <- list(nodeName)
  #     }
  #   }

  #   all_paths <- list()
  #   curr_path <- list()

  #   all_cycles_from_node(curr_node, cycles, curr_path, visited) {
  #     visited[curr_node] <- TRUE # mark as visited

  #     for (child in children) {
  #       curr_path <- append(curr_path, child)
  #       if (visited(child)) {
          
  #         cycles <- append(cycles, append(curr_path, child))
          
  #         # all_paths <- child + curr
  #         # curr_path <- append(child, curr_path) curr_node
  #       } else {
  #         cycles <- all_cycles_from_node(child, copy(cycles), copy(curr_path), visited)
  #         # path <- function_name()
  #         # child + path
          
  #       }
  #     }
  #     cycles
  #   }

  #   all_cycles_from_node(A, [], [], [])
    

  #   # Return 
  #   # print("Path:")
  #   # print(path)
  #   # print(class(path))
  #   # print("===")
  #   stopifnot(class(path) == "list")
  #   path
  # }

  # for (node in 1:numNodes) {
  #   nodeName <- nodeNames[node]
  #   if (isFALSE(visited[node])) {
  #     cy <- dfs(node, nodeName, visited)
  #     # browser()
  #     stopifnot(class(cy) == "list")
  #     # Is there a cycle?
  #     if (length(cy) > 0 ) {
  #       idx <- numCycles + 1
  #       cycles[[idx]] <- cy
  #       idx <- idx + 1
  #     }
  #   }
  # }
  # # print("Cycles:")
  # # print(cycles)
  # # print("===")
  
  # # Return 
  # # browser()
  # print(paste("cycles:", cycles, sep=" "))
  # print("End findCycles")
  # cycles
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
