% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/aaa-classes.R
\name{AbstractVariable}
\alias{AbstractVariable}
\title{AbstractVariable Class}
\usage{
AbstractVariable(name, relationships = list())
}
\description{
Abstract super class for declaring variables
}
\section{Slots}{

\describe{
\item{\code{name}}{Name of variable, which should correspond with the column name for variable's data (must be in long format)}

\item{\code{relationships}}{List of relationships this variable has with other variables}
}}

\examples{
AbstractVariable(name="name", relationships=list())
}
