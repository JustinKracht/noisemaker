#' Simulate a population correlation matrix with model error
#'
#' This tool lets the user generate a population correlation matrix with
#' model error using one of three methods: (1) the Tucker, Koopman, and
#' Linn (TKL; 1969) method, (2) the Cudeck and Browne (CB; 1992) method, or
#' (3) the Wu and Browne (WB; 2015) method. If the CB or WB methods are used,
#' the user can specify the desired RMSEA value. If the TKL method is used, an
#' optimization procedure finds a solution that produces RMSEA and/or CFI values
#' that are close to the user-specified values.
#'
#' @param mod A `fungible::simFA()` model object.
#' @param target_rmsea (scalar) Target RMSEA value.
#' @param target_cfi (scalar) Target CFI value.
#' @param tkl_ctrl (list) See ##### HELP FILE FOR TKL() #####
#'
#' @return
#' @export
#'
#' @examples
#' set.seed(42)
#' noisemaker(mod, method = "TKL",
#'            target_rmsea = 0.05,
#'            target_cfi = 0.95,
#'            tkl_ctrl = list(optim_type = "optim"))
#' noisemaker(mod, method = "CB",
#'            target_rmsea = 0.05)
#' noisemaker(mod,
#'            method = "WB",
#'            target_rmsea = 0.05)
noisemaker <- function(mod,
                       method = c("TKL", "CB", "WB"),
                       target_rmsea = 0.05,
                       target_cfi = NULL,
                       tkl_ctrl = list()) {

  if (!is.numeric(target_rmsea) & !is.null(target_rmsea)) stop("Target RMSEA value must be a number or NULL.")
  if (!is.numeric(target_cfi) & !is.null(target_cfi)) stop("Target CFI value must be either a number or NULL.")
  if (target_rmsea < 0 | target_rmsea > 1) {
    stop("The target RMSEA value must be a number between 0 and 1.\n",
         crayon::blue("ℹ"), " You've specified a target RMSEA value of ",
                      target_rmsea, ".")
  }
  if (!is.null(target_cfi)) {
    if (target_cfi < 0 | target_cfi > 1) {
    stop("The target CFI value must be a number between 0 and 1.\n",
         crayon::blue("ℹ"), " You've specified a target CFI value of ",
                      target_cfi, ".")
    }
  }
  if (!is.null(target_cfi) & (method != "TKL")) {
    stop(
      "The TKL method must be used when a CFI value is specified.\n",
      crayon::blue("ℹ")," You've selected the ", method," method.\n",
      crayon::blue("ℹ")," You've specified a target CFI value of ", target_cfi, "."
    )
  }

  out_list <- list(Sigma = NA,
                   rmsea = NA,
                   cfi   = NA,
                   v     = NA,
                   eps   = NA)

  k <- ncol(mod$loadings) # number of major factors

  if (method == "WB") {
    out_list$Sigma <- wb(target_rmsea = target_rmsea,
                Omega = mod$Rpop)
    out_list$rmsea <- rmsea(out_list$Sigma, mod$Rpop, k)
    out_list$cfi <- cfi(out_list$Sigma, mod$Rpop)
  } else if (method == "CB") {
    out_list$Sigma <- cb(target_rmsea = target_rmsea,
                         mod = mod)
    out_list$rmsea <- rmsea(out_list$Sigma, mod$Rpop, k)
    out_list$cfi <- cfi(out_list$Sigma, mod$Rpop)
  } else if (method == "TKL") {
    tkl_out <- tkl(mod = mod,
                   target_rmsea = target_rmsea,
                   target_cfi = target_cfi,
                   tkl_ctrl = tkl_ctrl)

    out_list$Sigma <- tkl_out$RpopME
    out_list$rmsea <- tkl_out$rmsea
    out_list$cfi <- tkl_out$cfi
    out_list$v <- tkl_out$v
    out_list$eps <- tkl_out$eps
  }

  out_list
}
