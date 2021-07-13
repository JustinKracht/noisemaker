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
#' @param values The number of target RMSEA values to evaluate between 0.02 and
#'   0.1.
#' @param lower (scalar) The smallest target RMSEA value to use.
#' @param upper (scalar) The largest target RMSEA value to use.
#'
#' @return (scalar) A coefficient to use with the \code{\link{wb}} function to
#'   obtain population correlation matrices with model error that have RMSEA
#'   values closer to the target RMSEA values.
#' @export
#'
#' @examples
#' set.seed(42)
#' mod <- fungible::simFA(Seed = 42)
#' wb_coef <- find_wb_coef(mod, n = 100, values = 5,
#'                         lower = .045, upper = .055)
#' wb(mod$Rpop, target_rmsea = 0.05, wb_coef = wb_coef)

find_wb_coef <- function(mod, n = 250, values = 2, lower = 0.01, upper = 0.1) {
  # Check arguments
  if (!(is.list(mod))) {
    stop("`mod` must be a valid `simFA()` model object.", call. = F)
  }
  if (is.null(mod$loadings) |
      is.null(mod$Phi) |
      is.null(mod$Rpop)) {
    stop("`mod` must be a valid `simFA()` model object.", call. = F)
  }
  if (length(n) != 1L | !is.numeric(n) | n <= 0) {
    stop("`n` must be a number greater than zero.\n",
         crayon::cyan("\u2139"), " You've specified an `n` value of ",
         n, ".", call. = F)
  }
  if (length(values) != 1L | !is.numeric(values) | values < 2) {
    stop("`values` must be a number greater than two.\n",
         crayon::cyan("\u2139"), " You've specified a `values` value of ",
         values, ".", call. = F)
  }
  if (length(lower) != 1L | !is.numeric(lower) | lower <= 0) {
    stop("`lower` must be a number greater than zero.\n",
         crayon::cyan("\u2139"), " You've specified a `lower` value of ",
         lower, ".", call. = F)
  }
  if (length(upper) != 1L | !is.numeric(upper) | upper >= .15) {
    stop("`upper` must be a number less than .15.\n",
         crayon::cyan("\u2139"), " You've specified an `upper` value of ",
         upper, ".", call. = F)
  }

  k <- ncol(mod$loadings)
  Omega <- mod$Rpop
  rmsea_values <- seq(lower, upper, length.out = values)

  rmsea_medians <- sapply(
    X = rmsea_values,
    FUN = function(target_rmsea,
                   Omega,
                   k) {
      obs_rmsea <- replicate(n = n, expr = {
        rmsea(wb(Omega, target_rmsea), Omega, k)
      })
      stats::median(obs_rmsea)
    },
    Omega = Omega,
    k = k
  )

  m1 <- stats::lm(rmsea_medians ~ rmsea_values + 0)
  wb_coef <- 1/m1$coefficients[1]
  names(wb_coef) <- NULL
  wb_coef
}
