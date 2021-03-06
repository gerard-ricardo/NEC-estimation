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

#' plot.jagsNEC
#'
#' Generates a plot of a fitted jags NEC model, as returned by fit.jagsNEC.
#'
#' @param X the jags NEC model fit as returned by fit.jagsNEC.
#'
#' @param CI a logical value indicating if confidence intervals on the model fit should be plotted, calculated as the upper and lower bounds of the individual predicted values from all posterior samples
#'
#' @param posterior.median a logical value indicating if the posterior median of the model fit should be plotted, calculated as the median of the individual predicted values from all posterior samples
#'
#' @param median.model a logical value indicating if the fitted model calculated from the median estimates of the NEC, top and beta parameters should be plotted. This is the fitted model as shown in Fox 2010.
#'
#' @param add.NEC a logical value indicating if the estimated NEC value and 95\% credible intervals should be added to the plot.
#'
#' @param add.EC10 a logical value indicating if an estimated EC10 value and 95\% credible intervals should be added to the plot.
#'
#' @param legend.loc a vector indicating the location of the NEC or EC10 legend, as per a call to legend.
#'
#' @param xform a function to be applied as a transformation of the x data.
#'
#' @param lxform a function to be applied as a transformation only to axis labels and the annoted NEC/EC10 values.
#'
#' @param x.jitter a logical value indicating if the x data points on the plot should be jittered.
#'
#' @param y.jitter a logical value indicating if the y data points on the plot should be jittered.
#'
#' @param xlab a character vector to use for the x-axis label
#'
#' @param ylab a character vector to use for the y-axis label
#'
#' @param xlim a numeric vector of length two to use for the lower and uper limits of the x-axis range
#'
#' @param xticks a numeric vector indicate where to place the tick marks of the x-axis
#'
#' @export
#' @return a plot of the fitted model

plot.jagsNECfit <- function(X, CI = TRUE, posterior.median = TRUE, median.model = FALSE,
                            add.NEC = TRUE, legend.loc = "topright", add.EC10 = FALSE,
                            xform = NA, lxform = NA,
                            jitter.x = FALSE, jitter.y = FALSE,
                            ylab = "response",
                            xlab = "concentration",
                            xlim = NA, xticks = NA, ...) {

  # check if y.type is binomial
  y.type <- X$y.type
  if (y.type == "binomial") {
    y.dat <- X$mod.dat$y / X$mod.dat$trials
  } else {
    y.dat <- X$mod.dat$y
  }

  EC10 <- c(NA, NA, NA)
  if (add.EC10 == TRUE & X$y.type != "gaussian") {
    EC10 <- extract_ECx.jagsNECfit(X)
  }
  if (add.EC10 == TRUE & X$y.type == "gaussian") {
    EC10 <- extract_ECx.jagsNECfit(X, type = "relative")
  }

  # check if a transformation is required for x
  if (class(xform) == "function") {
    x.dat <- xform(X$mod.dat$x)
    NEC <- xform(X$NEC)
    x.vec <- xform(X$pred.vals$x)
    EC10 <- xform(EC10)
  } else {
    x.dat <- X$mod.dat$x
    NEC <- X$NEC
    x.vec <- X$pred.vals$x
  }

  if (jitter.x == TRUE) {
    x.dat <- jitter(x.dat)
  }
  if (jitter.y == TRUE) {
    y.dat <- jitter(y.dat)
  }

  # check if a range for the x axis has been specified
  if (max(is.na(xlim)) == 1) {
    x.lim <- range(x.dat)
  } else {
    x.lim <- xlim
  }
  # Check if x axis tick marks have been specified
  if (max(is.na(xticks)) == 1) {
    x.ticks <- seq(min(x.dat), max(x.dat), length = 7)
  } else {
    x.ticks <- xticks
  }

  plot(x.dat, y.dat,
    ylab = ylab,
    xlab = xlab,
    pch = 16, xaxt = "n", xlim = x.lim,
    col = adjustcolor(1, alpha = 0.25),
    cex = 1.5
  )

  if (class(lxform) != "function") {
    if (max(is.na(xticks)) == 1) {
      axis(side = 1)
    } else {
      axis(side = 1, at = x.ticks)
    }
    NEC.legend <- paste("NEC: ", signif(NEC[2], 2),
      " (", signif(NEC[1], 2), "-", signif(NEC[3], 2), ")",
      sep = ""
    )
    EC10.legend <- paste("EC10: ", signif(EC10[1], 2),
      " (", signif(EC10[2], 2), "-", signif(EC10[3], 2), ")",
      sep = ""
    )
  } else {
    x.labs <- signif(lxform(x.ticks), 2)
    axis(side = 1, at = x.ticks, labels = x.labs)
    NEC.legend <- paste("NEC: ", signif(lxform(NEC[2]), 2),
      " (", signif(lxform(NEC[1]), 2), "-",
      signif(lxform(NEC[3]), 2), ")",
      sep = ""
    )
    EC10.legend <- paste("EC10: ", signif(lxform(EC10[1]), 2),
      " (", signif(lxform(EC10[2]), 2), "-",
      signif(lxform(EC10[3]), 2), ")",
      sep = ""
    )
  }

  if (CI == TRUE) {
    lines(x.vec, X$pred.vals$up, lty = 2)
    lines(x.vec, X$pred.vals$lw, lty = 2)
  }
  if (posterior.median == TRUE) {
    lines(x.vec, X$pred.vals$y)
  }
  if (median.model == TRUE) {
    lines(x.vec, X$pred.vals$y.m, col = "red")
  }
  if (add.NEC == TRUE & add.EC10 == FALSE) {
    abline(v = NEC, col = "red", lty = c(3, 1, 3))
    legend(legend.loc,
      bty = "n",
      legend = NEC.legend, lty = 1, col = "red"
    )
  }
  if (add.EC10 == TRUE & add.NEC == FALSE) {
    abline(v = EC10, col = "red", lty = c(1, 3, 3))
    legend(legend.loc,
      bty = "n",
      legend = EC10.legend, lty = 1, col = "red"
    )
  }
  if (add.EC10 == TRUE & add.NEC == TRUE) {
    abline(v = NEC, col = "red", lty = c(3, 1, 3))
    abline(v = EC10, col = "orange", lty = c(1, 3, 3))

    legend(legend.loc,
      bty = "n",
      legend = c(NEC.legend, EC10.legend),
      lty = 1, col = c("red", "orange")
    )
  }
}

#' plot.jagsMANEC
#'
#' Generates a plot of a fitted jags NEC model, as returned by fit.jagsNEC.
#'
#' @param X the jags NEC model fit as returned by fit.jagsNEC.
#'
#' @param CI a logical value indicating if confidence intervals on the model fit should be plotted, calculated as the upper and lower bounds of the individual predicted values from all posterior samples
#'
#' @param posterior.median a logical value indicating if the posterior median of the model fit should be plotted, calculated as the median of the individual predicted values from all posterior samples
#'
#' @param median.model a logical value indicating if the fitted model calculated from the median estimates of the NEC, top and beta parameters should be plotted. This is the fitted model as shown in Fox 2010.
#'
#' @param add.NEC a logical value indicating if the estimated NEC value and 95\% credible intervals should be added to the plot.
#'
#' @param add.EC10 a logical value indicating if an estimated EC10 value and 95\% credible intervals should be added to the plot.
#'
#' @param legend.loc a vector indicating the location of the NEC or EC10 legend, as per a call to legend.
#'
#' @param xform a function to be applied as a transformation of the x data.
#'
#' @param lxform a function to be applied as a transformation only to axis labels and the annoted NEC/EC10 values.
#'
#' @param x.jitter a logical value indicating if the x data points on the plot should be jittered.
#'
#' @param y.jitter a logical value indicating if the y data points on the plot should be jittered.
#'
#' @param xlab a character vector to use for the x-axis label
#'
#' @param ylab a character vector to use for the y-axis label
#'
#' @param xlim a numeric vector of length two to use for the lower and uper limits of the x-axis range
#'
#' @param xticks a numeric vector indicate where to place the tick marks of the x-axis
#'
#' @export
#' @return a plot of the fitted model

plot.jagsMANECfit <- function(X, CI = TRUE, posterior.median = TRUE, median.model = FALSE,
                              add.NEC = TRUE, legend.loc = "topright", add.EC10 = FALSE,
                              xform = NA, lxform = NA,
                              jitter.x = FALSE, jitter.y = FALSE,
                              ylab = "response",
                              xlab = "concentration",
                              xlim = NA,
                              ylim = NA,
                              xticks = NA, xtick.rounding = 5,
                              all_models = FALSE, ...) {
  if (all_models) {
    mod_fits <- X$mod.fits
    par(mfrow = c(ceiling(length(mod_fits) / 2), 2), mar = c(1.5, 1.5, 1.5, 1.5), oma = c(3, 3, 0, 0))
    for (m in 1:length(mod_fits)) {
      plot(
        X = mod_fits[[m]],
        CI = CI, add.NEC = add.NEC,
        legend.loc = legend.loc,
        add.EC10 = add.EC10,
        xform = xform, lxform = lxform,
        jitter.x = jitter.x, jitter.y = jitter.y,
        ylab = "", xlab = "",
        xlim = xlim,
        xticks = xticks, ...
      )
      mtext(xlab, side = 1, outer = T, line = 2)
      mtext(ylab, side = 2, outer = T, line = 2)
      mtext(names(mod_fits)[m], side = 3, outer = FALSE, cex = 0.8)
    }
  } else {


    # check if y.type is binomial
    y.type <- X$y.type
    if (y.type == "binomial") {
      y.dat <- X$mod.dat$y / X$mod.dat$trials
    } else {
      y.dat <- X$mod.dat$y
    }

    ## extract EC10
    EC10 <- c(NA, NA, NA)
    if (add.EC10 == TRUE & X$y.type != "gaussian") {
      EC10 <- extract_ECx.jagsMANECfit(X)
    }
    if (add.EC10 == TRUE & X$y.type == "gaussian") {
      EC10 <- extract_ECx.jagsMANECfit(X, type = "relative")
    }

    # check if a transformation is required for x
    if (class(xform) == "function") {
      x.dat <- xform(X$mod.dat$x)
      NEC <- xform(X$NEC)
      x.vec <- xform(X$pred.vals$x)
      EC10 <- xform(EC10)
    } else {
      x.dat <- X$mod.dat$x
      NEC <- X$NEC
      x.vec <- X$pred.vals$x
    }

    if (jitter.x == TRUE) {
      x.dat <- jitter(x.dat)
    }
    if (jitter.y == TRUE) {
      y.dat <- jitter(y.dat)
    }

    # check if a range for the x axis has been specified
    if (max(is.na(xlim)) == 1) {
      x.lim <- range(x.dat)
    } else {
      x.lim <- xlim
    }
    # Check if x axis tick marks have been specified
    if (max(is.na(xticks)) == 1) {
      x.ticks <- seq(min(x.dat), max(x.dat), length = 7)
    } else {
      x.ticks <- xticks
    }

    if (is.na(xlim[1]) == TRUE) {
      xlim <- range(x.dat)
    }
    if (is.na(ylim[1]) == TRUE) {
      ylim <- range(y.dat)
    }

    plot(x.dat, y.dat,
      ylab = ylab,
      xlab = xlab,
      pch = 16, xaxt = "n",
      xlim = xlim, ylim = ylim,
      col = adjustcolor(1, alpha = 0.25),
      cex = 1.5
    )

    if (class(lxform) != "function") {
      if (max(is.na(xticks)) == 1) {
        axis(side = 1)
      } else {
        axis(side = 1, at = x.ticks)
      }
      NEC.legend <- paste("NEC: ", signif(NEC[2], 2),
        " (", signif(NEC[1], 2), "-",
        signif(NEC[3], 2), ")",
        sep = ""
      )
      EC10.legend <- paste("EC10: ", signif(EC10[1], 2),
        " (", signif(EC10[2], 2), "-",
        signif(EC10[3], 2), ")",
        sep = ""
      )
    } else {
      x.labs <- signif(round(lxform(x.ticks), xtick.rounding), 2)
      axis(side = 1, at = x.ticks, labels = x.labs)
      NEC.legend <- paste("NEC: ", signif(lxform(NEC[2]), 2),
        " (", signif(lxform(NEC[1]), 2), "-",
        signif(lxform(NEC[3]), 2), ")",
        sep = ""
      )
      EC10.legend <- paste("EC10: ", signif(lxform(EC10[1]), 2),
        " (", signif(lxform(EC10[2]), 2), "-",
        signif(lxform(EC10[3]), 2), ")",
        sep = ""
      )
    }

    if (CI == TRUE) {
      lines(x.vec, X$pred.vals$up, lty = 2)
      lines(x.vec, X$pred.vals$lw, lty = 2)
    }
    if (posterior.median == TRUE) {
      lines(x.vec, X$pred.vals$y)
    }
    if (median.model == TRUE) {
      lines(x.vec, X$pred.vals$y.m, col = "red")
    }
    if (add.NEC == TRUE & add.EC10 == FALSE) {
      abline(v = NEC, col = "red", lty = c(3, 1, 3))
      legend(legend.loc,
        bty = "n",
        legend = NEC.legend, lty = 1, col = "red"
      )
    }
    if (add.EC10 == TRUE & add.NEC == FALSE) {
      abline(v = EC10, col = "red", lty = c(1, 3, 3))
      legend(legend.loc,
        bty = "n",
        legend = EC10.legend, lty = 1, col = "red"
      )
    }
    if (add.EC10 == TRUE & add.NEC == TRUE) {
      abline(v = NEC, col = "red", lty = c(3, 1, 3))
      abline(v = EC10, col = "orange", lty = c(1, 3, 3))

      legend(legend.loc,
        bty = "n",
        legend = c(NEC.legend, EC10.legend),
        lty = 1, col = c("red", "orange")
      )
    }
  }
}
