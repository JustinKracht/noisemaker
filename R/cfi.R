#' Calculate CFI for two correlation matrices
#'
#' Given two correlation matrices of the same dimension, calculate the CFI value
#' value using the independence model as the null model.
#'
#' @param Sigma (matrix) Population correlation or covariance matrix (with model
#'   error).
#' @param Omega (matrix) Model-implied population correlation or covariance
#'   matrix.
#'
#' @return
#' @export
#'
#' @examples
#' set.seed(42)
#' mod <- fungible::simFA(Model = list(NFac = 3))
#' Omega <- mod$Rpop
#' Sigma <- cb(
#'   target_rmsea = 0.05,
#'   Omega = Omega
#' )
#' cfi(Sigma, Omega)
cfi <- function(Sigma, Omega) {
  p <- nrow(Sigma)
  Ft <- log(det(Omega)) - log(det(Sigma)) + sum(diag(Sigma %*% solve(Omega))) - p
  cfi <- 1 - (Ft / -log(det(Sigma)))
  cfi
}
