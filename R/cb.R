#' Cudeck & Browne (1992) model error method
#'
#' Generate a population correlation matrix using the model described in Cudeck
#' and Browne (1992).
#'
#' @param mod A `fungible::simFA()` model object.
#' @param target_rmsea (scalar) Target RMSEA value.
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
#'   mod = mod,
#'   target_rmsea = 0.05
#' )
#' # Verify the result
#' rmsea(Sigma, mod$Rpop, k = ncol(mod$loadings))
cb <- function(mod,
               target_rmsea) {

  if (target_rmsea < 0 | target_rmsea > 1) {
    stop("The target RMSEA value must be a number between 0 and 1.\n",
         crayon::cyan("ℹ"), " You've specified a target RMSEA value of ",
         target_rmsea, ".", call. = F)
  }

  if (!(is.list(mod)) |
      is.null(mod$loadings) |
      is.null(mod$Phi) |
      is.null(mod$Rpop)) {
    stop("`mod` must be a valid `simFA()` model object.", call. = F)
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
