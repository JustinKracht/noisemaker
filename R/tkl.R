#' Optimize TKL parameters to find a solution with target RMSEA and CFI values
#'
#' Find the optimal W matrix such that the RMSEA and CFI values are as close as
#' possible to the user-specified target values.
#'
#' @param mod A `fungible::simFA()` model object.
#' @param target_rmsea (scalar) Target RMSEA value.
#' @param target_cfi (scalar) Target CFI value.
#' @param tkl_ctrl (list) A control list containing the following TKL-specific
#' arguments:
#' * weights (vector) Vector of length two indicating how much weight to
#'   give RMSEA and CFI, e.g., `c(1,1)` (default) gives equal weight to both
#'   indices; `c(1,0)` ignores the CFI value.
#' * v_start (scalar) Starting value to use for \eqn{\upsilon}, the
#'   proportion of uniqueness variance reallocated to the minor common factors.
#' * eps_start (scalar) Starting value to use for \eqn{\epsilon}, which
#'   controls how common variance is distributed among the minor common factors.
#' * NminorFac (scalar) Number of minor common factors.
#' * ModelErrorType (character) "U" or "V", as defined in `simFA()`.
#' * WmaxLoading (scalar) Threshold value for `NWmaxLoading`.
#' * NWmaxLoading (scalar) Maximum number of absolute loadings \eqn{\ge}
#'   `WmaxLoading` in any column of \eqn{W}.
#' * penalty (scalar) Penalty applied to objective function if the
#'   NmaxLoading condition isn't satisfied.
#' * optim_type (character)  Which optimization function to use, `optim` or
#'   `ga`? `optim()` is faster, but might not converge in some cases.
#' * ncores (boolean/scalar) Controls whether `ga()` optimization is done in
#'   parallel. If `TRUE`, uses the maximum available number of processor cores. If
#'   `FALSE`, does not use parallel processing. If an integer is provided, that's
#'   how many processor cores will be used (if available).
#' @export
#' @md
#'
#' @references Tucker, L. R., Koopman, R. F., & Linn, R. L. (1969). Evaluation of factor analytic research procedures by means of simulated correlation matrices. \emph{Psychometrika}, \emph{34}(4), 421–459. \url{https://doi.org/10/chcxvf}
#'
#' @examples
#' set.seed(42)
#' mod <- fungible::simFA()
#' tkl(
#'   mod = mod,
#'   target_rmsea = 0.05,
#'   target_cfi = 0.95,
#'   tkl_ctrl = list(optim_type = "optim")
#' )
tkl <- function(mod,
                target_rmsea,
                target_cfi,
                tkl_ctrl = list()) {

  # Create default tkl_ctrl list; modify elements if changed by the user
  tkl_ctrl_default <- list(weights = c(1,1),
                           v_start = 0.1,
                           eps_start = 0.02,
                           NMinorFac = 50,
                           ModelErrorType = "U",
                           WmaxLoading = NULL,
                           NWmaxLoading = 2,
                           debug = FALSE,
                           penalty = 500,
                           optim_type = "ga",
                           ncores = FALSE)

  # Update the elements of the default tkl_ctrl list that have been changed by
  # the user
  tkl_ctrl_default <- tkl_ctrl_default[sort(names(tkl_ctrl_default))]
  tkl_ctrl_default[names(tkl_ctrl)] <- tkl_ctrl

  # Create objects for each of the elements in tkl_ctrl
  for (i in seq_along(tkl_ctrl_default)) {
    assign(names(tkl_ctrl_default[i]), tkl_ctrl_default[[i]])
  }

  # Check arguments
  if (target_rmsea > 1 | target_rmsea < 0) {
    stop("Target RMSEA value must be between 0 and 1.", call. = F)
  }
  if (eps_start < 0 | eps_start > 1) {
    stop("The value of eps_start must be between 0 and 1.", call. = F)
  }
  if (v_start < 0 | v_start > 1) {
    stop("The value of v_start must be between 0 and 1.", call. = F)
  }
  if (mod$cn$ModelError$ModelError == TRUE) {
    warning("The simFA object you provided includes model error parameters that will be ignored by this function.")
  }

  L <- mod$loadings
  Phi <- mod$Phi

  # Create W with eps = 0
  W <- MASS::mvrnorm(
    n = nrow(L),
    mu = rep(0, NMinorFac),
    Sigma = diag(NMinorFac)
  )

  p <- nrow(L) # number of items
  k <- ncol(L) # number of major factors

  CovMajor <- L %*% Phi %*% t(L)
  u <- 1 - diag(CovMajor)
  Rpop <- CovMajor
  diag(Rpop) <- 1 # ensure unit diagonal

  df <- (p * (p - 1) / 2) - (p * k) + (k * (k - 1) / 2) # model df

  # TODO: Feasibility check
  # delta <- target_rmsea - (1 - target_cfi)

  start_vals <- c(v_start, eps_start)

  if (optim_type == "optim") {
    if (debug == TRUE) ctrl <- list(trace = 5, REPORT = 1) else ctrl <- list()
    opt <- optim(
      par = start_vals,
      fn = obj_func,
      method = "L-BFGS-B",
      lower = c(0, 0), # can't go lower than zero;
      upper = c(1, 1), # can't go higher than one
      Rpop = Rpop,
      W = W,
      p = p,
      u = u,
      df = df,
      target_rmsea = target_rmsea,
      target_cfi = target_cfi,
      weights = weights,
      ModelErrorType = ModelErrorType,
      WmaxLoading = WmaxLoading,
      NWmaxLoading = NWmaxLoading,
      control = ctrl,
      penalty = penalty
    )
    par <- opt$par
  } else if (optim_type == "ga") {
    opt <- GA::ga(
      type = "real-valued",
      fitness = function(x) {
        -obj_func(x,
          Rpop = Rpop,
          W = W,
          p = p,
          u = u,
          df = df,
          target_rmsea = target_rmsea,
          target_cfi = target_cfi,
          weights = weights,
          ModelErrorType = ModelErrorType,
          WmaxLoading = WmaxLoading,
          NWmaxLoading = NWmaxLoading,
          penalty = penalty
        )
      },
      lower = c(0, 0),
      upper = c(1, 1),
      popSize = 50,
      maxiter = 1000,
      run = 100,
      parallel = ncores,
      monitor = FALSE,
      seed = seed
    )
    par <- opt@solution[1, ]
  }

  obj_func(
    par = par,
    Rpop = Rpop,
    W = W,
    p = p,
    u = u,
    df = df,
    target_rmsea = target_rmsea,
    target_cfi = target_cfi,
    weights = weights,
    ModelErrorType = ModelErrorType,
    WmaxLoading = WmaxLoading,
    NWmaxLoading = NWmaxLoading,
    return_values = TRUE,
    penalty = penalty
  )
}
