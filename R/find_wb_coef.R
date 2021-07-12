#' Find a cofficient to use with the Wu & Browne (2015) model error method
#'
#' The Wu & Browne (2015) model error method takes advantage of the relationship
#' between v and RMSEA:
#'
#' \deqn{v = RMSEA^2 + o(RMSEA^2).}
#'
#' As RMSEA increases, the approximation \eqn{v ~= RMSEA^2} becomes worse. This
#' function generates population correlation matrices with model error for
#' multiple target RMSEA values and then regresses the median (observed) RMSEA
#' values on the target RMSEA values. The reciprocal of the regression
#' coefficient is returned and can be used to adjust the value of \eqn{v} in
#' calls to `wb()` to ensure that generated matrices have RMSEA values that are
#' close to the target value.
#'
#' @param mod A `fungible::simFA()` model object.
#' @param n The number of times to evaluate `wb()` at each point.
#' @param points The number of target RMSEA points to evaluate betwen 0.02 and
#'   0.1.
#'
#' @return (scalar) A coefficient to use with the `wb()` function to obtain
#'   population correlation matrices with model error that have RMSEA values
#'   closer to the target RMSEA values.
#' @export
#'
#' @examples
find_wb_coef <- function(mod, n = 250, points = 2) {
  # Check arguments
  if (!(is.list(mod)) |
      is.null(mod$loadings) |
      is.null(mod$Phi) |
      is.null(mod$Rpop)) {
    stop("`mod` must be a valid `simFA()` model object.", call. = F)
  }
  if (length(n) != 1L | !is.numeric(n) | n <= 0) {
    stop("`n` must be a number greater than zero.\n",
         crayon::cyan("\u2139"), " You've specified an `n` value of ",
         n, ".", call. = F)
  }
  if (length(points) != 1L | !is.numeric(points) | points < 2) {
    stop("`points` must be a number greater than two.\n",
         crayon::cyan("\u2139"), " You've specified a target RMSEA value of ",
         points, ".", call. = F)
  }

  k <- ncol(mod$loadings)
  Omega <- mod$Rpop
  rmsea_points <- seq(0.02, 0.1, length.out = points)
  rmsea_medians <- sapply(X = rmsea_points,
                          FUN = function(target_rmsea,
                                         Omega,
                                         k) {
                            obs_rmsea <- replicate(n = n,
                                                   expr = wb(Omega, target_rmsea))
                            median(obs_rmsea)
                          }, Omega = Omega, k = k)
  m1 <- lm(rmsea_medians ~ rmsea_points + 0)
  wb_coef <- m1$coefficients[1]
  names(wb_coef) <- NULL
  wb_coef
}
