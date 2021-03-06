% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Predict_fitted_vals.R
\name{predict.jagsNECfit}
\alias{predict.jagsNECfit}
\title{predict.jagsNEC}
\usage{
predict.jagsNECfit(
  X,
  precision = 100,
  posterior = FALSE,
  x.range = NA,
  prob.vals = c(0.5, 0.025, 0.975)
)
}
\arguments{
\item{X}{a jag model fit as returned by a call to jags from fit.jagsNEC}

\item{precision}{The number of unique x values over which to find fitted.}

\item{posterior}{A logical value indicating if the full posterior sample of calculated fitted values should be returned
instead of just the median and 95 credible intervals.}

\item{x.range}{A range of x values over which to consider extracting fitted}

\item{prob.vals}{A vector indicating the probability values over which to return the estimated fitted value.}
}
\value{
A vector containing the estimated fitted value, including upper and lower 95 percent Credible Interval bounds
}
\description{
Extracts the predicted fitted value as desired from a jagsNEC model fit obeject
}
