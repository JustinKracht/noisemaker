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
#'
#' @return
#' @export
#'
#' @examples
#' noisemaker()
noisemaker <- function(mod,
                       method = c("TKL", "CB", "WB"),
                       rmsea = NULL,
                       cfi = NULL,
                       weights = c(rmsea = 0.5, cfi = 0.5),
                       start_vals = c(v = .1, eps = 0.01)) {


}
