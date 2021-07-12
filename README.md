
<!-- README.md is generated from README.Rmd. Please edit that file -->

# noisemaker

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/JustinKracht/noisemaker/branch/main/graph/badge.svg)](https://codecov.io/gh/JustinKracht/noisemaker?branch=main)
[![check-standard](https://github.com/JustinKracht/noisemaker/workflows/check-standard/badge.svg)](https://github.com/JustinKracht/noisemaker/actions)
<!-- badges: end -->

The goal of noisemaker is to provide functions to make it easy to
generate population correlation matrices that fit a common factor
analysis model imperfectly. In particular, the `noisemaker()` function
provides an interface to three methods for generating population
correlation matrices with RMSEA and/or CFI values that are close to
user-specified target values.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("JustinKracht/noisemaker")
```

## Example

In this example, the factor model has two factors, each with three
salient items. I’ll demonstrate using the `noisemaker()` function to
generate a population correlation matrix with model error (*Σ*) such
that RMSEA(*Σ*, *Ω*) = 0.05, where *Ω* is the model-implied correlation
matrix. For this first example, I’ll use the method described by [Cudeck
and Browne (1992)](https://doi-org.ezp1.lib.umn.edu/10.1007/BF02295424).

``` r
library(noisemaker)
library(fungible)

set.seed(42)

# Generate a simple factor model with two factors and six items
mod <- simFA(Model = list(NFac = 2,
                          NItemPerFac = 3))
(Omega <- mod$Rpop) # the model-implied correlation matrix
#>           V1        V2        V3        V4        V5        V6
#> V1 1.0000000 0.3439953 0.3728647 0.0000000 0.0000000 0.0000000
#> V2 0.3439953 1.0000000 0.2705444 0.0000000 0.0000000 0.0000000
#> V3 0.3728647 0.2705444 1.0000000 0.0000000 0.0000000 0.0000000
#> V4 0.0000000 0.0000000 0.0000000 1.0000000 0.3439953 0.3728647
#> V5 0.0000000 0.0000000 0.0000000 0.3439953 1.0000000 0.2705444
#> V6 0.0000000 0.0000000 0.0000000 0.3728647 0.2705444 1.0000000

# Generate a population correlation matrix with model error (Sigma) using the
# Cudeck and Browne (1992) method
noisemaker(mod, method = "CB", target_rmsea = 0.05)
#> $Sigma
#>             V1          V2         V3           V4          V5          V6
#> V1  1.00000000 0.343995324 0.37286469 -0.053409084 -0.01220126 -0.01280329
#> V2  0.34399532 1.000000000 0.27054441  0.007971444  0.03140474  0.03357727
#> V3  0.37286469 0.270544412 1.00000000  0.022498954  0.04870680  0.05044623
#> V4 -0.05340908 0.007971444 0.02249895  1.000000000  0.34399532  0.37286469
#> V5 -0.01220126 0.031404738 0.04870680  0.343995324  1.00000000  0.27054441
#> V6 -0.01280329 0.033577270 0.05044623  0.372864692  0.27054441  1.00000000
#> 
#> $rmsea
#> [1] 0.04999998
#> 
#> $cfi
#> [1] 0.9837485
#> 
#> $v
#> [1] NA
#> 
#> $eps
#> [1] NA
```

The `noisemaker()` function also implements a procedure that optimizes
the values of the parameters for the [Tucker, Koopman, and Linn
(1969)](https://doi-org.ezp1.lib.umn.edu/10.1007/BF02290601) method to
produce a *Σ* matrix that has both RMSEA and CFI values close to the
user-specified targets:

``` r
noisemaker(mod, method = "TKL", 
           target_rmsea = 0.05, 
           target_cfi = 0.95,
           tkl_ctrl = list(optim_type = "optim"))
#> $Sigma
#>             V1          V2           V3           V4          V5          V6
#> V1  1.00000000  0.32219941  0.424625295  0.034558184 -0.02266029 -0.01159263
#> V2  0.32219941  1.00000000  0.246092137 -0.018726309 -0.02956467  0.02661360
#> V3  0.42462530  0.24609214  1.000000000  0.001169003 -0.02672423  0.01249006
#> V4  0.03455818 -0.01872631  0.001169003  1.000000000  0.36937229  0.33027555
#> V5 -0.02266029 -0.02956467 -0.026724234  0.369372287  1.00000000  0.25645023
#> V6 -0.01159263  0.02661360  0.012490065  0.330275546  0.25645023  1.00000000
#> 
#> $rmsea
#> [1] 0.06748102
#> 
#> $cfi
#> [1] 0.9705263
#> 
#> $v
#> [1] 0.3060474
#> 
#> $eps
#> [1] 0.03444881
```
