#    Copyright 2020 Australian Institute of Marine Science
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

#' extract_ECx
#'
#' Extracts the predicted ECx value as desired from a jagsNEC or a jagsMANEC model fit.
#'
#' @param  X a jag model fit as returned by a call to jags from fit.jagsNEC
#'
#' @param ECx.val the desired percentage effect value. This must be a value between 1 and 99 (for type = "relative"
#' and "absolute"), defaults to 10.
#'
#' @param type a character vector, taking values of "relative",  "absolute" (the default) or "direct".
#' Type "relative" is calculated as the percentage decrease from the maximum predicted value of the response (top) to the minimum predicted value
#' of the response. Type "absolute" (the default) is calculated as the percentage decrease from the maximum value of the response (top)
#' to 0 (or bot for a 4 parameter model fit). Type "direct" provides a direct estimate of the x value for a given y.
#' Note that for the current version, ECx for an NECHormesis model is estimated at a percent decline from the control
#'
#' @param precision The number of unique x values over which to find ECx - large values will make the ECx estimate more
#' precise.
#'
#' @param posterior A logical value indicating if the full posterior sample of calculated ECx values should be returned
#' instead of just the median and 95 credible intervals.
#'
#' @param xform A function to apply to the returned estimated concentration values
#'
#' @param x.range A range of x values over which to consider extracting ECx
#'
#' @param prob.vals A vector indicating the probability values over which to return the estimated ECx value. Defaults to 0.5 (median) and 0.025 and 0.975 (95 percent credible intervals).
#'
#' @export
#' @return A vector containing the estimated ECx value, including upper and lower 95 percent Credible Interval bounds
#'
extract_ECx <- function(X, ECx.val = 10, precision = 10000, posterior = FALSE, type = "absolute",
                        hormesis.def = "control", xform = NA, x.range = NA,
                        prob.vals = c(0.5, 0.025, 0.975), link = "identity") {
  if (class(X) == "jagsNECfit") {
    ECx <- extract_ECx.jagsNECfit(X,
      x.range = x.range,
      ECx.val = ECx.val, precision = precision,
      posterior = posterior, type = type, hormesis.def = hormesis.def,
      xform = xform,
      prob.vals = prob.vals
    )
  }
  if (class(X) == "jagsMANECfit") {
    ECx <- extract_ECx.jagsMANECfit(X,
      ECx.val = ECx.val, precision = precision,
      posterior = posterior, type = type, xform = xform, x.range = x.range,
      prob.vals = prob.vals
    )
  }

  if (exists("ECx") == FALSE) {
    stop("Failed to estimate ECx value for the supplied object class. Only jagsNECfit and jagsMANECfit classes are suported.")
  }

  return(ECx)
}

#' extract_ECx.jagsNEC
#'
#' Extracts the predicted ECx value as desired from a jagsNEC model fit obeject
#'
#' @param  X a jag model fit as returned by a call to jags from fit.jagsNEC
#'
#' @param ECx.val the desired percentage effect value.
#'
#' @param type a character vector indicating if relative or absolute values for the ECx should be calculated.
#'
#' @param precision The number of unique x values over which to find ECx.
#'
#' @param posterior A logical value indicating if the full posterior sample of calculated ECx values should be returned
#' instead of just the median and 95 credible intervals.
#'
#' @param xform A function to apply to the returned estimated concentration values
#'
#' @param prob.vals A vector indicating the probability values over which to return the estimated ECx value.
#'
#' @export
#' @return A vector containing the estimated ECx value, including upper and lower 95 percent Credible Interval bounds

extract_ECx.jagsNECfit <- function(X, ECx.val = 10, precision = 10000, posterior = FALSE, type = "absolute",
                                   hormesis.def = "control", x.range = NA,
                                   xform = NA, prob.vals = c(0.5, 0.025, 0.975)) {
  if (type != "direct") {
    if (ECx.val < 1 | ECx.val > 99) {
      stop("Supplied ECx.val is not in the required range. Please supply a percentage value between 1 and 99.")
    }
  }

  if (length(grep("ECx", X$model)) > 0) {
    mod.class <- "ECx"
  } else {
    mod.class <- "NEC"
  }
  if (is.null(X$bot) == FALSE) {
    m4param <- 1
  } else {
    m4param <- 0
  }

  if (X$y.type == "gaussian" & type == "absolute") {
    stop("Absolute ECx values are not valid for a gaussian response variable unless a 4 parameter model is fit")
  }
  # if(X$x.type=="gaussian" &  X$model == "ECxLinear"  & type=="absolute"){
  #    stop("Absolute ECx values are not valid for a linear model when
  #         x-values are gaussian, because 'top' merely indicates the y-intercept. Use type 'relative'.")
  #  }

  label <- paste("EC", ECx.val, sep = "_")

  pred.vals <- predict_NECbugsmod(X, precision = precision, x.range = x.range)
  posterior.sample <- pred.vals$posterior
  x.vec <- pred.vals$"x"


  if (X$model == "NECHormesis" & hormesis.def == "max") { # remove values prior to the NEC for the hormesis model
    posterior.sample <- do.call(
      "cbind",
      lapply(1:length(X$sims.list$NEC), FUN = function(x) {
        NEC.x <- X$sims.list$NEC[x]
        posterior.x <- posterior.sample[, x]
        posterior.x[which(x.vec < NEC.x)] <- NA
        return(posterior.x)
      })
    )
  }

  if (X$model == "NECHormesis" & hormesis.def == "control") { # remove values greater than the control for the hormesis model
    posterior.sample <- do.call(
      "cbind",
      lapply(1:ncol(posterior.sample), FUN = function(x) {
        control.x <- posterior.sample[1, x]
        posterior.x <- posterior.sample[, x]
        posterior.x[which(posterior.x >= control.x)] <- NA
        return(posterior.x)
      })
    )
  }


  ECx.out <- apply(posterior.sample, MARGIN = 2, FUN = function(y) {
    if (type == "relative") {
      range.y <- range(y, na.rm = T)
    }
    if (type == "absolute") {
      range.y <- c(0, max(y, na.rm = T))
    }
    if (type != "direct") {
      ECx.y <- max(range.y) - diff(range.y) * (ECx.val / 100)
    } else {
      ECx.y <- ECx.val
    }
    ECx.x <- x.vec[which.min(abs(y - ECx.y))]
    return(ECx.x)
  })

  # calculate the quantile values from the posterior?
  ECx.estimate <- quantile(unlist(ECx.out), probs = prob.vals)
  names(ECx.estimate) <- c(label, paste(label, "lw", sep = "_"), paste(label, "up", sep = "_"))

  # if a transformation is required
  if (class(xform) == "function") {
    ECx.estimate <- xform(ECx.estimate)
    ECx.out <- xform(ECx.out)
  }

  if (posterior == FALSE) {
    return(ECx.estimate)
  } else {
    return(ECx.out)
  }
}

#' extract_ECx.jagsMANEC
#'
#' Extracts the predicted ECx value as desired from a jagsNEC model fit obeject
#'
#' @param  X a fitted jagsMANEC model object, containing a list of jag model fit as returned by a call to jags from
#' fit.jagsNEC
#'
#' @param ECx.val the desired percentage effect value.
#'
#' @param type a character vector indicating if relative or absolute values for the ECx should be calculated.
#'
#' @param precision The number of unique x values over which to find ECx.
#'
#' @param posterior A logical value indicating if the full posterior sample of calculated ECx values
#' should be returned instead of just the median and 95 credible intervals.
#'
#' @param xform A function to apply to the returned estimated concentration values
#'
#' @param prob.vals A vector indicating the probability values over which to return the estimated ECx value.
#'
#' @export
#' @return A vector containing the estimated ECx value, including upper and lower 95 percent Credible Interval bounds

extract_ECx.jagsMANECfit <- function(X, ECx.val = 10, precision = 10000, posterior = FALSE, type = "absolute",
                                     hormesis.def = "control", xform = NA, x.range = NA,
                                     prob.vals = c(0.5, 0.025, 0.975)) {
  ECx.out <- unlist(sapply(X$success.models, FUN = function(x) {
    base::sample(
      extract_ECx.jagsNECfit(X$mod.fits[[x]],
        ECx.val = ECx.val,
        precision = precision, # precision,
        posterior = TRUE,
        x.range = x.range,
        type = type
      ),
      round(X$n.sims * X$mod.stats[x, "wi"])
    )
  }))

  label <- paste("EC", ECx.val, sep = "_")
  # calculate the quantile values from the posterior
  ECx.estimate <- quantile(ECx.out, probs = prob.vals)
  names(ECx.estimate) <- c(label, paste(label, "lw", sep = "_"), paste(label, "up", sep = "_"))

  # if a transformation is required
  if (class(xform) == "function") {
    ECx.estimate <- xform(ECx.estimate)
    ECx.out <- xform(ECx.out)
  }


  if (posterior == FALSE) {
    return(ECx.estimate)
  } else {
    return(ECx.out)
  }
}
