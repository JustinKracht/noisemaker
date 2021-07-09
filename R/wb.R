#' Wu & Browne model error method
#'
#' Generate a population correlation matrix using the model described in Wu and
#' Browne (2015).
#'
#' @param Omega (matrix) Model-implied population correlation matrix.
#' @param target_rmsea (scalar) Target RMSEA value.
#'
#' @author Justin Kracht <krach018@umn.edu>
#' @references Wu, H., & Browne, M. W. (2015). Quantifying adventitious error in
#'   a covariance structure as a random effect. \emph{Psychometrika},
#'   \emph{80}(3), 571–600. \url{https://doi.org/10/gjrkc4}
#'
#' @export
#' @details The Wu and Browne method generates a correlation matrix with model
#'   error (\eqn{\Sigma}) using
#'
#'   \deqn{(\Sigma | \Omega) ~ IW(m, m \Omega),}
#'
#'   where \eqn{m ~= 1/\epsilon^2} is a precision parameter related to
#'   RMSEA (\eqn{\epsilon}) and \eqn{IW(m, m \Omega)} denotes an
#'   inverse Wishart distribution. Note that \emph{there is no guarantee that
#'   the RMSEA will be very close to the target RMSEA}, particularly when the
#'   target RMSEA value is large. Based on experience, the method tends to give
#'   solutions with RMSEA values that are larger than the target RMSEA values.
#'   Therefore, it might be worth using a target RMSEA value that is somewhat
#'   lower than what is actually needed.

wb <- function(Omega,
               target_rmsea) {

  if (!is.matrix(Omega)) stop("Omega must be a correlation matrix.")
  if (target_rmsea < 0 | target_rmsea > 1) {
    stop("The target RMSEA value must be a number between 0 and 1.\n",
         crayon::cyan("\u2139"), " You've specified a target RMSEA value of ",
         target_rmsea, ".", call. = F)
  }
  if (all.equal(Omega, t(Omega)) != TRUE) {
    stop("Omega must be a symmetric correlation matrix.", call. = F)
  }
  if (any(eigen(Omega)$values < 0)) {
    stop("Omega must be a positive semidefinite correlation matrix.", .call = F)
  }

  v <- target_rmsea^2
  m <- v^-1 # m is the precision parameter, Wu and Browne (2015), p. 576

  Sigma <- MCMCpack::riwish(m, m * Omega)
  stats::cov2cor(Sigma)
}
