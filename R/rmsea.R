#' Calculate RMSEA between two correlation/covariance matrices
#'
#' @param Sigma (matrix) Population correlation or covariance matrix (with model error).
#' @param Omega (matrix) Model-implied population correlation or covariance matrix.
#' @param df (scalar) Model degrees of freedom.
#' @param k (scalar) Number of major common factors.
#'
#' @return
#' @export
#'
#' @examples
#' set.seed(42)
#' mod <- fungible::simFA()
#' Omega <- mod$Rpop
#' Sigma <- wu_browne(target_rmsea = 0.05,
#'                    Omega = Omega)
#' rmsea(Sigma, Omega)
rmsea <- function(Sigma, Omega, k) {
  if (!all.equal(Sigma, t(Sigma))) {
    stop("Error: Sigma must be a symmetric matrix.")
  } else if (!all.equal(Omega, t(Omega))) {
    stop("Error: Omega must be a symmetric matrix.")
  } else if (!all.equal(dim(Omega), dim(Sigma))) {
    stop("Error: Sigma and Omega must have the same dimensions.")
  }

  p <- nrow(Sigma)
  df <- (p * (p - 1)/2) - (p * k) + (k * (k - 1)/2)
  Fm <- log(det(Omega)) - log(det(Sigma)) + sum(diag(Sigma %*% solve(Omega))) - p
  sqrt(Fm/df)
}
