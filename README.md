
<!-- README.md is generated from README.Rmd. Please edit that file -->

# noisemaker

<!-- badges: start -->

[![check-coverage](https://github.com/JustinKracht/noisemaker/workflows/check-coverage/badge.svg)](https://github.com/JustinKracht/noisemaker/actions)
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
#> V1 1.0000000 0.1557502 0.2224619 0.0000000 0.0000000 0.0000000
#> V2 0.1557502 1.0000000 0.2125102 0.0000000 0.0000000 0.0000000
#> V3 0.2224619 0.2125102 1.0000000 0.0000000 0.0000000 0.0000000
#> V4 0.0000000 0.0000000 0.0000000 1.0000000 0.1557502 0.2224619
#> V5 0.0000000 0.0000000 0.0000000 0.1557502 1.0000000 0.2125102
#> V6 0.0000000 0.0000000 0.0000000 0.2224619 0.2125102 1.0000000

# Generate a population correlation matrix with model error (Sigma) using the
# Cudeck and Browne (1992) method
noisemaker(mod, method = "CB", target_rmsea = 0.05)
#> $Sigma
#>             V1         V2          V3          V4          V5          V6
#> V1  1.00000000 0.15575018  0.22246190 -0.02853472 -0.01265823 -0.05314384
#> V2  0.15575018 1.00000000  0.21251016  0.03285690  0.04846020  0.01112478
#> V3  0.22246190 0.21251016  1.00000000  0.02650763  0.04526112 -0.02840005
#> V4 -0.02853472 0.03285690  0.02650763  1.00000000  0.15575018  0.22246190
#> V5 -0.01265823 0.04846020  0.04526112  0.15575018  1.00000000  0.21251016
#> V6 -0.05314384 0.01112478 -0.02840005  0.22246190  0.21251016  1.00000000
#> 
#> $rmsea
#> [1] 0.04999999
#> 
#> $cfi
#> [1] 0.9565284
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
#>              V1         V2           V3          V4           V5           V6
#> V1  1.000000000 0.14105346  0.248653513 -0.01824447 -0.008412114 -0.038447595
#> V2  0.141053457 1.00000000  0.252870710  0.01657956  0.022011141  0.029453101
#> V3  0.248653513 0.25287071  1.000000000  0.03767410 -0.011985452 -0.002592231
#> V4 -0.018244472 0.01657956  0.037674096  1.00000000  0.146536448  0.176135959
#> V5 -0.008412114 0.02201114 -0.011985452  0.14653645  1.000000000  0.205072073
#> V6 -0.038447595 0.02945310 -0.002592231  0.17613596  0.205072073  1.000000000
#> 
#> $rmsea
#> [1] 0.05285529
#> 
#> $cfi
#> [1] 0.9514101
#> 
#> $v
#> [1] 0.2252711
#> 
#> $eps
#> [1] 0.01766372
```
