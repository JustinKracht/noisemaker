
<!-- README.md is generated from README.Rmd. Please edit that file -->

# noisemaker

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/JustinKracht/noisemaker/branch/main/graph/badge.svg)](https://codecov.io/gh/JustinKracht/noisemaker?branch=main)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
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
#> V1 1.0000000 0.2627011 0.3071333 0.0000000 0.0000000 0.0000000
#> V2 0.2627011 1.0000000 0.2975486 0.0000000 0.0000000 0.0000000
#> V3 0.3071333 0.2975486 1.0000000 0.0000000 0.0000000 0.0000000
#> V4 0.0000000 0.0000000 0.0000000 1.0000000 0.2627011 0.3071333
#> V5 0.0000000 0.0000000 0.0000000 0.2627011 1.0000000 0.2975486
#> V6 0.0000000 0.0000000 0.0000000 0.3071333 0.2975486 1.0000000

# Generate a population correlation matrix with model error (Sigma) using the
# Cudeck and Browne (1992) method
noisemaker(mod, method = "CB", target_rmsea = 0.05)
#> $Sigma
#>             V1          V2         V3          V4          V5           V6
#> V1  1.00000000 0.262701140 0.30713331 -0.05294687 -0.03594507 -0.056045582
#> V2  0.26270114 1.000000000 0.29754862  0.01095215  0.02767500  0.009256662
#> V3  0.30713331 0.297548624 1.00000000  0.02602455  0.04442958  0.015867232
#> V4 -0.05294687 0.010952152 0.02602455  1.00000000  0.26270114  0.307133311
#> V5 -0.03594507 0.027675000 0.04442958  0.26270114  1.00000000  0.297548624
#> V6 -0.05604558 0.009256662 0.01586723  0.30713331  0.29754862  1.000000000
#> 
#> $rmsea
#> [1] 0.05
#> 
#> $cfi
#> [1] 0.9785393
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
#>             V1           V2           V3           V4          V5           V6
#> V1  1.00000000  0.300790201  0.274579939  0.044279707 -0.03735308 -0.014927645
#> V2  0.30079020  1.000000000  0.273727584  0.006503299  0.01159769 -0.004656284
#> V3  0.27457994  0.273727584  1.000000000 -0.008789668  0.02837240 -0.034781940
#> V4  0.04427971  0.006503299 -0.008789668  1.000000000  0.24952522  0.269430742
#> V5 -0.03735308  0.011597693  0.028372397  0.249525219  1.00000000  0.279079831
#> V6 -0.01492764 -0.004656284 -0.034781940  0.269430742  0.27907983  1.000000000
#> 
#> $rmsea
#> [1] 0.06386562
#> 
#> $cfi
#> [1] 0.9611129
#> 
#> $v
#> [1] 0.09357188
#> 
#> $eps
#> [1] 0.3738185
```
