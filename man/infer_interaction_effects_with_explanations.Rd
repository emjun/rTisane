% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/infer_interaction_effects_with_explanations.R
\name{infer_interaction_effects_with_explanations}
\alias{infer_interaction_effects_with_explanations}
\title{Infers interaction/moderation effects.}
\usage{
infer_interaction_effects_with_explanations(
  causal_gr,
  associative_gr,
  design,
  main_effects
)
}
\arguments{
\item{causal_gr}{Graph representing causal relationships between variables.}

\item{associative_gr}{Graph representing associative relationships between variables.}

\item{design}{Design}
}
\value{
List of interaction/moderation effects and their explanations
}
\description{
This function infers interaction/moderation effects from a conceptual graph.
}
