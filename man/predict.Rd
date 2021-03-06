% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Predict_fitted_vals.R
\name{predict}
\alias{predict}
\title{predict}
\usage{
predict(
  X,
  precision = 100,
  posterior = FALSE,
  x.range = NA,
  prob.vals = c(0.5, 0.025, 0.975),
  link = "identity"
)
}
\arguments{
\item{X}{a jags model fit as returned by a call to jags from fit.jagsNEC}

\item{precision}{The number of unique x values over which to find fitted - large values will make the fitted estimate more
precise.}

\item{posterior}{A logical value indicating if the full posterior sample of calculated fitted values should be returned
instead of just the median and 95 credible intervals.}

\item{x.range}{A range of x values over which to consider extracting fitted}

\item{prob.vals}{A vector indicating the probability values over which to return the estimated fitted value. Defaults to 0.5 (median) and 0.025 and 0.975 (95 percent credible intervals).}
}
\value{
A vector containing the estimated fitted value, including upper and lower 95 percent Credible Interval bounds
}
\description{
Calculated predicted values for a jagsNEC or a jagsMANEC model fit.
}
