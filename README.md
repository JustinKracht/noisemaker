
<!-- README.md is generated from README.Rmd. Please edit that file -->

# noisemaker

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/krach018/noisemaker/branch/master/graph/badge.svg)](https://codecov.io/gh/krach018/noisemaker?branch=master)
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
#> V1 1.0000000 0.2131060 0.3042363 0.0000000 0.0000000 0.0000000
#> V2 0.2131060 1.0000000 0.2166849 0.0000000 0.0000000 0.0000000
#> V3 0.3042363 0.2166849 1.0000000 0.0000000 0.0000000 0.0000000
#> V4 0.0000000 0.0000000 0.0000000 1.0000000 0.2131060 0.3042363
#> V5 0.0000000 0.0000000 0.0000000 0.2131060 1.0000000 0.2166849
#> V6 0.0000000 0.0000000 0.0000000 0.3042363 0.2166849 1.0000000

# Generate a population correlation matrix with model error (Sigma) using the
# Cudeck and Browne (1992) method
noisemaker(mod, method = "CB", target_rmsea = 0.05)
#> $Sigma
#>             V1         V2          V3           V4          V5          V6
#> V1  1.00000000 0.21310603 0.304236313 -0.054186012 -0.01259594 -0.04225103
#> V2  0.21310603 1.00000000 0.216684946  0.016560273  0.04403313  0.02958308
#> V3  0.30423631 0.21668495 1.000000000  0.008772346  0.05145024  0.02062351
#> V4 -0.05418601 0.01656027 0.008772346  1.000000000  0.21310603  0.30423631
#> V5 -0.01259594 0.04403313 0.051450242  0.213106025  1.00000000  0.21668495
#> V6 -0.04225103 0.02958308 0.020623507  0.304236313  0.21668495  1.00000000
#> 
#> $rmsea
#> [1] 0.05
#> 
#> $cfi
#> [1] 0.9715238
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
#> V1  1.000000000 0.25076780  0.309540040 -0.05067540 -0.035090431 -0.003229498
#> V2  0.250767797 1.00000000  0.213694292  0.03086418  0.018703123  0.011877132
#> V3  0.309540040 0.21369429  1.000000000  0.03778841 -0.001088831  0.042049393
#> V4 -0.050675396 0.03086418  0.037788411  1.00000000  0.214787623  0.257838841
#> V5 -0.035090431 0.01870312 -0.001088831  0.21478762  1.000000000  0.197287550
#> V6 -0.003229498 0.01187713  0.042049393  0.25783884  0.197287550  1.000000000
#> 
#> $rmsea
#> [1] 0.06002572
#> 
#> $cfi
#> [1] 0.9571189
#> 
#> $v
#> [1] 0.3259321
#> 
#> $eps
#> [1] 0
```
