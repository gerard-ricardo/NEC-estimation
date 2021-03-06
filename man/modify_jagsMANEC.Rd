% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/modify_jagsMANEC.R
\name{modify_jagsMANEC}
\alias{modify_jagsMANEC}
\title{modify.jagsMANEC}
\usage{
modify_jagsMANEC(
  jagsMANECfit,
  model.set = NA,
  drop.models = NA,
  add.models = NA
)
}
\arguments{
\item{jagsMANECfit}{a jagsMANECfit output list, as returned by fit.jagsMANEC}

\item{model.set}{A character vector containing the of names of model types to be included in the modified fit.}

\item{drop.models}{A character vector containing the names of model types you which to drop for the modified fit.}

\item{add.models}{A character vector containing the names of model types to add to the modified fit.}
}
\value{
All successully fitted jagsMANECfit model fit.
}
\description{
Modifys an existing jagsMANECfit, for example, but adding or removing fitted models.
}
