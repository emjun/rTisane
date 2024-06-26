% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/construct_graphs.R
\name{construct_graphs}
\alias{construct_graphs}
\title{Construct graph of all relationships}
\usage{
construct_graphs(all_relationships, vars)
}
\arguments{
\item{all_relationships}{List of all relationships (edges) to include in this graph}

\item{vars}{List of AbstractVariables involved in the graph}
}
\value{
Tuple of graphs: (conceptual graph, data measurement graph)
}
\description{
This function constructs a graph representing all relationships
}
