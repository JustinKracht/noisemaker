#' Optimize TKL parameters to find a solution with target RMSEA and CFI values
#'
#' Find the optimal W matrix such that the RMSEA and CFI values are as close as
#' possible to the user-specified target values.
#'
#' @param W (matrix) Matrix of provisional minor common factor loadings with
#'   unit column variances.
#' @param L (matrix) Matrix of major common factor loadings.
#' @param Phi (matrix) Major common factor correlation matrix.
#' @param target_rmsea (scalar) Target RMSEA value.
#' @param target_cfi (scalar) Target CFI value.
#' @param weights (vector) Vector of length two indicating how much weight to
#'   give RMSEA and CFI, e.g., `c(1,1)` (default) gives equal weight to both
#'   indices; `c(1,0)` ignores the CFI value.
#' @param v_start (scalar) Starting value to use for \eqn{\upsilon}, the
#'   proportion of uniqueness variance reallocated to the minor common factors.
#' @param eps_start (scalar) Starting value to use for \eqn{\epsilon}, which
#'   controls how common variance is distributed among the minor common factors.
#' @param NminorFac (scalar) Number of minor common factors.
#' @param ModelErrorType (character) "U" or "V", as defined in `simFA()`.
#' @param WmaxLoading (scalar) Threshold value for `NWmaxLoading`.
#' @param NWmaxLoading (scalar) Maximum number of absolute loadings \eqn{\ge}
#'   `WmaxLoading` in any column of \eqn{W}.
#' @param penalty (scalar) Penalty applied to objective function if the
#'   NmaxLoading condition isn't satisfied.
#' @param optim_type (character)  Which optimization function to use, `optim` or
#'   `ga`? `optim()` is faster, but might not converge in some cases.
#' @param seed (scalar) seed for reproducibility.
#' @param ncores (boolean/scalar) Controls whether `ga()` optimization is done in
#'   parallel. If `TRUE`, uses the maximum available number of processor cores. If
#'   `FALSE`, does not use parallel processing. If an integer is provided, that's
#'   how many processor cores will be used (if available).
#' @export
#'
#' @examples
#' mod <- fungible::simFA()
#' tkl_opt(
#'   L = mod$loadings,
#'   Phi = mod$Phi,
#'   target_rmsea = 0.05,
#'   target_cfi = 0.95,
#'   WmaxLoading = .35,
#'   NWmaxLoading = 3,
#'   optim_type = "optim",
#'   seed = 123
#' )
tkl <- function(L, Phi, target_rmsea, target_cfi,
                    weights = c(1,1),
                    v_start = 0.1,
                    eps_start = 0.02,
                    NMinorFac = 50,
                    ModelErrorType = "U",
                    WmaxLoading = NULL,
                    NWmaxLoading = 2,
                    debug = FALSE,
                    penalty = 500,
                    optim_type = "ga",
                    seed = NULL,
                    ncores = FALSE) {

  if (target_rmsea > 1 | target_rmsea < 0) {
    stop("Target RMSEA value must be between 0 and 1.", call. = F)
  }
  if (eps_start < 0 | eps_start > 1) {
    stop("The value of eps_start must be between 0 and 1.", call. = F)
  }
  if (v_start < 0 | v_start > 1) {
    stop("The value of v_start must be between 0 and 1.", call. = F)
  }

  if (!is.null(seed)) set.seed(seed)

  # Create W with eps = 0
  W <- MASS::mvrnorm(n = nrow(L),
                     mu = rep(0, NMinorFac),
                     Sigma = diag(NMinorFac))

  p <- nrow(L) # number of items
  k <- ncol(L) # number of major factors

  CovMajor <- L %*% Phi %*% t(L)
  u <- 1 - diag(CovMajor)
  Rpop <- CovMajor
  diag(Rpop) <- 1 # ensure unit diagonal

  df <- (p * (p-1) / 2) - (p * k) + (k * (k-1) / 2) # model degrees of freedom

  # TODO: Feasibility check
  # delta <- target_rmsea - (1 - target_cfi)

  start_vars <- c(v_start, eps_start)

  if (optim_type == "optim") {
    if (debug == TRUE) ctrl <- list(trace = 5, REPORT = 1) else ctrl = list()
    opt <- optim(par = start_vals,
                 fn = obj_func,
                 method = "L-BFGS-B",
                 lower = c(0,0), # can't go lower than zero;
                 upper = c(1,1), # can't go higher than one
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
                 penalty = penalty)
    par <- opt$par
  } else if (optim_type == "ga") {
    invisible(opt <- GA::ga(type = "real-valued",
                            fitness =  function(x) {
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
                                        penalty = penalty)
                            },
                            lower = c(0,0),
                            upper = c(1,1),
                            popSize = 50,
                            maxiter = 1000,
                            run = 100,
                            parallel = ncores,
                            seed = seed))
    par <- opt@solution[1,]
  }

  obj_func(par = par,
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
           penalty = penalty)
}
