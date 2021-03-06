% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extract_ECx.R
\name{extract_ECx.jagsMANECfit}
\alias{extract_ECx.jagsMANECfit}
\title{extract_ECx.jagsMANEC}
\usage{
extract_ECx.jagsMANECfit(
  X,
  ECx.val = 10,
  precision = 10000,
  posterior = FALSE,
  type = "absolute",
  hormesis.def = "control",
  xform = NA,
  x.range = NA,
  prob.vals = c(0.5, 0.025, 0.975)
)
}
\arguments{
\item{X}{a fitted jagsMANEC model object, containing a list of jag model fit as returned by a call to jags from
fit.jagsNEC}

\item{ECx.val}{the desired percentage effect value.}

\item{precision}{The number of unique x values over which to find ECx.}

\item{posterior}{A logical value indicating if the full posterior sample of calculated ECx values
should be returned instead of just the median and 95 credible intervals.}

\item{type}{a character vector indicating if relative or absolute values for the ECx should be calculated.}

\item{xform}{A function to apply to the returned estimated concentration values}

\item{prob.vals}{A vector indicating the probability values over which to return the estimated ECx value.}
}
\value{
A vector containing the estimated ECx value, including upper and lower 95 percent Credible Interval bounds
}
\description{
Extracts the predicted ECx value as desired from a jagsNEC model fit obeject
}
