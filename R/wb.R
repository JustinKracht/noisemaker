#' Wu & Browne model error method
#'
#' Generate a population correlation matrix using the model described in Wu and
#' Browne (2015).
#'
#' @param Omega (matrix) Model-implied population correlation matrix.
#' @param target_rmsea (scalar) Target RMSEA value.
#' @param wb_coef (scalar) An optional coefficient to scale the target_rmsea
#'   value so that generated matrices are more likely to have RMSEA values close
#'   to the target value. See also `find_wb_coef()`.
#'
#' @author Justin Kracht <krach018@umn.edu>
#' @references Wu, H., & Browne, M. W. (2015). Quantifying adventitious error in
#'   a covariance structure as a random effect. *Psychometrika*, *80*(3),
#'   571–600. <https://doi.org/10/gjrkc4>
#'
#' @export
#' @details The Wu and Browne method generates a correlation matrix with model
#'   error (\eqn{\Sigma}) using
#'
#'   \deqn{(\Sigma | \Omega) ~ IW(m, m \Omega),}
#'
#'   where \eqn{m ~= 1/\epsilon^2} is a precision parameter related to RMSEA
#'   (\eqn{\epsilon}) and \eqn{IW(m, m \Omega)} denotes an inverse Wishart
#'   distribution. Note that *there is no guarantee that the RMSEA will be very
#'   close to the target RMSEA*, particularly when the target RMSEA value is
#'   large. Based on experience, the method tends to give solutions with RMSEA
#'   values that are larger than the target RMSEA values. Therefore, it might be
#'   worth using a target RMSEA value that is somewhat lower than what is
#'   actually needed. Alternatively, the \code{\link{find_wb_coef}} function can
#'   be used to estimate a coefficient to shrink the target RMSEA value by an
#'   appropriate amount so that the solution RMSEA values are close to the
#'   (nominal) target values.
#'
#' @examples
#' set.seed(42)
#' mod <- fungible::simFA(Seed = 42)
#' wb_coef <- find_wb_coef(mod, n = 100, values = 5,
#'                         lower = 0.04, upper = 0.06)
#' wb(Omega = mod$Rpop, target_rmsea = 0.05, wb_coef = wb_coef)

wb <- function(Omega,
               target_rmsea,
               wb_coef = NULL) {

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
  if (!is.null(wb_coef)) {
    if ((length(wb_coef) != 1L) | (wb_coef < 0)) {
      stop("`wb_coef` must be a positive number.\n",
           crayon::cyan("\u2139"), " You've specified a `wb_coef` value of ",
           wb_coef, ".", call. = F)
    }
  }

  # If wb_coef is specified, multiply target RMSEA by the coefficient
  if (!is.null(wb_coef)) target_rmsea <- wb_coef * target_rmsea

  v <- target_rmsea^2
  # m <- 1/v + nrow(Omega) - 1
  m <- v^-1 # m is the precision parameter, Wu and Browne (2015), p. 576

  Sigma <- MCMCpack::riwish(m, m * Omega)
  stats::cov2cor(Sigma)
}
