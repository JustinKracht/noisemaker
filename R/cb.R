#' Cudeck & Browne (1992) model error method
#'
#' Generate a population correlation matrix using the model described in Cudeck
#' and Browne (1992).
#'
#' @param target_rmsea (scalar) Target RMSEA value.
#' @param mod A `fungible::simFA()` model object.
#'
#' @return
#' @export
#'
#' @references Cudeck, R., & Browne, M. W. (1992). Constructing a covariance matrix that yields a specified minimizer and a specified minimum discrepancy function value. \emph{Psychometrika}, \emph{57}(3), 357–369. \url{https://doi.org/10/cq6ckd}

#'
#' @examples
#' set.seed(42)
#' mod <- fungible::simFA()
#' Sigma <- cb(
#'   target_rmsea = 0.05,
#'   mod = mod
#' )
#' # Verify the result
#' rmsea(Sigma, mod$Rpop, k = ncol(mod$loadings))
cb <- function(target_rmsea,
               mod) {
  if (target_rmsea > 1 | target_rmsea < 0) {
    stop("Target RMSEA value must be between 0 and 1.", call. = F)
  }

  p <- nrow(mod$loadings)
  k <- ncol(mod$loadings)
  df <- (p * (p - 1) / 2) - (p * k) + (k * (k - 1) / 2)
  discrep <- target_rmsea^2 * df
  sem_mod <- semify(mod)
  MBESS::Sigma.2.SigmaStar(
    model = sem_mod$model,
    model.par = sem_mod$theta,
    latent.var = sem_mod$latent_var,
    discrep = discrep
  )$Sigma.star
}
