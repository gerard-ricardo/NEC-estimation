#' predict.NECmod
#'
#' Calculates predicted y (response) values for a supplied vector of x (concentration) values for a given set of NEC, top and beta values
#'
#' @param  x.vec the x vector over which to calculate
#' 
#' @param NEC the No-Effect-Concentration
#' 
#' @param top the estimated value of y (response) over the range of x for which no effect occurs
#' 
#' @param beta the exponential decay rate
#'
#' @export
#' @return The $BUGSoutput element of fitted jags model.

predict.NECmod <- function(x.vec, NEC, top, beta, alpha=0){

  x.seq.pre <-  x.vec[which(x.vec<=NEC)] #seq(min.x, NEC.m, length=20)
  x.seq.post <- x.vec[which(x.vec>NEC)] # seq(NEC.m, max.x, length=20)
  
  y.pred.pre <- (rep(top, length(x.seq.pre)))-alpha
  y.pred.post <- (top*exp(-beta*(x.seq.post-NEC)))-alpha    

  y.pred <- c(y.pred.pre, y.pred.post)
  return(y.pred)

}

#' predict.NECbugsmod
#'
#' Calculates predicted y (response) values for a supplied vector of x (concentration) values for a jags fitted NEC model fit (as returned by fit.jagsNEC)
#' 
#' @param X the jags NEC model fit (as returned by fit.jagsNEC)
#'
#' @export
#' @return a list containing x (the x.seq), y (the median predicted y values at each value of x), up.vals (the upper 97.5% percentile of the predicted y values at each value of x), and lw (the lower 2.5% percentile of the predicted y values at each value of x)

predict.NECbugsmod <- function(X){
  mod.dat <- X$mod.dat
  min.x <- min(mod.dat$x)
  max.x <- max(mod.dat$x)
  x.seq <- seq(min.x, max.x, length=100)

  if(X$y.type != "gaussian"){
   pred.vals.out <- do.call("cbind",lapply(1:X$n.sims,FUN=function(x){
    predict.NECmod(x.vec=x.seq,
                   NEC=X$sims.list$NEC[x],
                   top=X$sims.list$top[x],
                   beta=X$sims.list$beta[x])}))}else{
   pred.vals.out <- do.call("cbind",lapply(1:X$n.sims,FUN=function(x){
    predict.NECmod(x.vec=x.seq,
                   NEC=X$sims.list$NEC[x],
                   top=X$sims.list$top[x],
                   beta=X$sims.list$beta[x],
                   alpha=X$sims.list$alpha[x])
     }))                    
  }
  
  m.vals <- apply(pred.vals.out, MARGIN=1, FUN=quantile, probs=0.5)
  up.vals <- apply(pred.vals.out, MARGIN=1, FUN=quantile, probs=0.975)
  lw.vals <- apply(pred.vals.out, MARGIN=1, FUN=quantile, probs=0.025)

  return(list(
    x=x.seq,
    y=m.vals,
    up=up.vals,
    lw=lw.vals
  ))
}