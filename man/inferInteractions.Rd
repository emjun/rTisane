% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/inferInteractions.R
\name{inferInteractions}
\alias{inferInteractions}
\title{Infers interaction/moderation effects.}
\usage{
inferInteractions(conceptualModel, iv, dv, confounders)
}
\arguments{
\item{conceptualModel}{ConceptualModel. With causal graph to use in order to identify confounders.}

\item{iv}{AbstractVariable. Independent variable that should cause (directly or indirectly) the @param dv.}

\item{dv}{AbstractVariable. Dependent variable that should not cause the @param iv.}

\item{confounders}{List. List of confounders to account for in order to estimate the causal effect of @param iv accurately.}
}
\value{
List of interaction/moderation effects and their explanations.
}
\description{
This function infers interaction/moderation effects from a conceptual graph.
}
