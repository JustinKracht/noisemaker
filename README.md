
<!-- README.md is generated from README.Rmd. Please edit that file -->

# noisemaker

<!-- badges: start -->

[![check-coverage](https://github.com/JustinKracht/noisemaker/workflows/check-coverage/badge.svg)](https://github.com/JustinKracht/noisemaker/actions)
[![R-CMD-check](https://github.com/JustinKracht/noisemaker/workflows/R-CMD-check/badge.svg)](https://github.com/JustinKracht/noisemaker/actions)
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
#> V1 1.0000000 0.3385032 0.3961073 0.0000000 0.0000000 0.0000000
#> V2 0.3385032 1.0000000 0.3746993 0.0000000 0.0000000 0.0000000
#> V3 0.3961073 0.3746993 1.0000000 0.0000000 0.0000000 0.0000000
#> V4 0.0000000 0.0000000 0.0000000 1.0000000 0.3385032 0.3961073
#> V5 0.0000000 0.0000000 0.0000000 0.3385032 1.0000000 0.3746993
#> V6 0.0000000 0.0000000 0.0000000 0.3961073 0.3746993 1.0000000

# Generate a population correlation matrix with model error (Sigma) using the
# Cudeck and Browne (1992) method
noisemaker(mod, method = "CB", target_rmsea = 0.05)
#> $Sigma
#>             V1         V2         V3          V4          V5          V6
#> V1  1.00000000 0.33850317 0.39610731 -0.05189307 -0.03069826 -0.05539283
#> V2  0.33850317 1.00000000 0.37469929  0.01327438  0.03338358  0.01248675
#> V3  0.39610731 0.37469929 1.00000000  0.02155929  0.04546623  0.01128401
#> V4 -0.05189307 0.01327438 0.02155929  1.00000000  0.33850317  0.39610731
#> V5 -0.03069826 0.03338358 0.04546623  0.33850317  1.00000000  0.37469929
#> V6 -0.05539283 0.01248675 0.01128401  0.39610731  0.37469929  1.00000000
#> 
#> $rmsea
#> [1] 0.05
#> 
#> $cfi
#> [1] 0.9867759
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
#>             V1            V2           V3           V4          V5
#> V1  1.00000000  0.3432877513  0.393611404  0.060756382 -0.04637673
#> V2  0.34328775  1.0000000000  0.345118514 -0.006217739 -0.00332293
#> V3  0.39361140  0.3451185138  1.000000000  0.030154385  0.03536586
#> V4  0.06075638 -0.0062177392  0.030154385  1.000000000  0.30018394
#> V5 -0.04637673 -0.0033229297  0.035365864  0.300183939  1.00000000
#> V6 -0.03058412 -0.0008556287 -0.001461634  0.382959415  0.36802484
#>               V6
#> V1 -0.0305841154
#> V2 -0.0008556287
#> V3 -0.0014616337
#> V4  0.3829594148
#> V5  0.3680248355
#> V6  1.0000000000
#> 
#> $rmsea
#> [1] 0.06845023
#> 
#> $cfi
#> [1] 0.9735605
#> 
#> $v
#> [1] 0.2522006
#> 
#> $eps
#> [1] 0.001400906
```
