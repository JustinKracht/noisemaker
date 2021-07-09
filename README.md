
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
devtools::install_github("krach018/noisemaker", 
                         host = "https://github.umn.edu/api/v3")
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
#> V1 1.0000000 0.1981889 0.2291600 0.0000000 0.0000000 0.0000000
#> V2 0.1981889 1.0000000 0.2518948 0.0000000 0.0000000 0.0000000
#> V3 0.2291600 0.2518948 1.0000000 0.0000000 0.0000000 0.0000000
#> V4 0.0000000 0.0000000 0.0000000 1.0000000 0.1981889 0.2291600
#> V5 0.0000000 0.0000000 0.0000000 0.1981889 1.0000000 0.2518948
#> V6 0.0000000 0.0000000 0.0000000 0.2291600 0.2518948 1.0000000

# Generate a population correlation matrix with model error (Sigma) using the
# Cudeck and Browne (1992) method
noisemaker(mod, method = "CB", target_rmsea = 0.05)
#> $Sigma
#>             V1           V2          V3          V4          V5           V6
#> V1  1.00000000  0.198188914 0.229159971 -0.04128031 -0.04168172 -0.058880903
#> V2  0.19818891  1.000000000 0.251894774  0.01822893  0.01549020 -0.006599241
#> V3  0.22915997  0.251894774 1.000000000  0.04596273  0.03833374  0.006012658
#> V4 -0.04128031  0.018228930 0.045962729  1.00000000  0.19818891  0.229159971
#> V5 -0.04168172  0.015490204 0.038333744  0.19818891  1.00000000  0.251894774
#> V6 -0.05888090 -0.006599241 0.006012658  0.22915997  0.25189477  1.000000000
#> 
#> $rmsea
#> [1] 0.04999999
#> 
#> $cfi
#> [1] 0.9659823
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
#>              V1         V2          V3           V4          V5          V6
#> V1  1.000000000 0.21001428  0.20433574  0.007837298 -0.01840641 0.001479742
#> V2  0.210014285 1.00000000  0.24103740  0.064996687  0.00945772 0.022886835
#> V3  0.204335744 0.24103740  1.00000000 -0.036301225 -0.02002894 0.042286624
#> V4  0.007837298 0.06499669 -0.03630122  1.000000000  0.21449919 0.231918198
#> V5 -0.018406413 0.00945772 -0.02002894  0.214499191  1.00000000 0.232009574
#> V6  0.001479742 0.02288684  0.04228662  0.231918198  0.23200957 1.000000000
#> 
#> $rmsea
#> [1] 0.05680647
#> 
#> $cfi
#> [1] 0.9542652
#> 
#> $v
#> [1] 0.1304928
#> 
#> $eps
#> [1] 0.06597866
```
