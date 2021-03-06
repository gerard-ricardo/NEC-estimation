% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Predict_fitted_vals.R
\name{predict_ECxExpmod}
\alias{predict_ECxExpmod}
\title{predict_EcxExpmod}
\usage{
predict_ECxExpmod(x.vec, top, beta)
}
\arguments{
\item{x.vec}{the x vector over which to calculate}

\item{top}{the upper plateau}

\item{beta}{the exponential decay rate (hillslope)}
}
\value{
A list containing x and fitted y, with up and lw values
}
\description{
Calculates predicted y (response) values for a supplied vector of x (concentration) values
}
