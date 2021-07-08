#' Calculate RMSEA between two correlation matrices
#'
#' Given two correlation matrices of the same dimension, calculate the RMSEA
#' value using the degrees of freedom for the exploratory factor analysis model
#' (see details).
#'
#' @param Sigma (matrix) Population correlation or covariance matrix (with model
#'   error).
#' @param Omega (matrix) Model-implied population correlation or covariance
#'   matrix.
#' @param df (scalar) Model degrees of freedom.
#' @param k (scalar) Number of major common factors.
#'
#' @details Note that this function uses the degrees of freedom for an
#'   exploratory factor analysis model: \deqn{df = p(p-1)/2-(pk)+k(k-1)/2,}
#'   where \eqn{p} is the number of items and \eqn{k} is the number of major
#'   factors.
#'
#' @md
#' @return
#' @export
#'
#' @examples
#' set.seed(42)
#' mod <- fungible::simFA(Model = list(NFac = 3))
#' Omega <- mod$Rpop
#' Sigma <- cb(
#'   target_rmsea = 0.05,
#'   mod = mod
#' )
#' rmsea(Sigma, Omega, k = 3)
rmsea <- function(Sigma, Omega, k) {
  if (!all.equal(Sigma, t(Sigma))) {
    stop("Error: Sigma must be a symmetric matrix.")
  } else if (!all.equal(Omega, t(Omega))) {
    stop("Error: Omega must be a symmetric matrix.")
  } else if (!all.equal(dim(Omega), dim(Sigma))) {
    stop("Error: Sigma and Omega must have the same dimensions.")
  }

  p <- nrow(Sigma)
  df <- (p * (p - 1) / 2) - (p * k) + (k * (k - 1) / 2)
  Fm <- log(det(Omega)) - log(det(Sigma)) + sum(diag(Sigma %*% solve(Omega))) - p
  sqrt(Fm / df)
}
