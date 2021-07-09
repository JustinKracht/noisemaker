
<!-- README.md is generated from README.Rmd. Please edit that file -->

# noisemaker

<!-- badges: start -->
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
#> V1 1.0000000 0.4183668 0.3074889 0.0000000 0.0000000 0.0000000
#> V2 0.4183668 1.0000000 0.3445620 0.0000000 0.0000000 0.0000000
#> V3 0.3074889 0.3445620 1.0000000 0.0000000 0.0000000 0.0000000
#> V4 0.0000000 0.0000000 0.0000000 1.0000000 0.4183668 0.3074889
#> V5 0.0000000 0.0000000 0.0000000 0.4183668 1.0000000 0.3445620
#> V6 0.0000000 0.0000000 0.0000000 0.3074889 0.3445620 1.0000000

# Generate a population correlation matrix with model error (Sigma) using the
# Cudeck and Browne (1992) method
noisemaker(mod, method = "CB", target_rmsea = 0.05)
#> $Sigma
#>              V1           V2         V3           V4          V5          V6
#> V1  1.000000000  0.418366799 0.30748888 -0.025307618 -0.03527963 0.003026739
#> V2  0.418366799  1.000000000 0.34456200 -0.009914374 -0.02513820 0.023458808
#> V3  0.307488875  0.344561996 1.00000000  0.047415932  0.04248275 0.070915815
#> V4 -0.025307618 -0.009914374 0.04741593  1.000000000  0.41836680 0.307488875
#> V5 -0.035279627 -0.025138197 0.04248275  0.418366799  1.00000000 0.344561996
#> V6  0.003026739  0.023458808 0.07091582  0.307488875  0.34456200 1.000000000
#> 
#> $rmsea
#> [1] 0.05000001
#> 
#> $cfi
#> [1] 0.9861564
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
#>              V1          V2          V3          V4          V5          V6
#> V1  1.000000000  0.41627805  0.38405052 -0.04108254 -0.03543407 0.002301903
#> V2  0.416278045  1.00000000  0.32253327 -0.02189281 -0.02123447 0.010464820
#> V3  0.384050516  0.32253327  1.00000000 -0.01118517 -0.05320922 0.004194980
#> V4 -0.041082540 -0.02189281 -0.01118517  1.00000000  0.39570873 0.304970927
#> V5 -0.035434070 -0.02123447 -0.05320922  0.39570873  1.00000000 0.356508010
#> V6  0.002301903  0.01046482  0.00419498  0.30497093  0.35650801 1.000000000
#> 
#> $rmsea
#> [1] 0.06785598
#> 
#> $cfi
#> [1] 0.9750104
#> 
#> $v
#> [1] 0.169304
#> 
#> $eps
#> [1] 0.108249
```
