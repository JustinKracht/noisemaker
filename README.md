
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

To also build the vignette when the package is installed (highly
recommended), you can use:

``` r
devtools::install_github("JustinKracht/noisemaker", build_vignettes = TRUE)
```

## Examples

In this example, the factor model has two factors, each with three
salient items. I’ll demonstrate using the `noisemaker()` function to
generate a population correlation matrix with model error (*Σ*) such
that RMSEA(*Σ*, *Ω*) = 0.05, where *Ω* is the model-implied correlation
matrix. For this first example, I’ll use the method described by [Cudeck
and Browne (1992)](https://doi-org.ezp1.lib.umn.edu/10.1007/BF02295424).

``` r
library(noisemaker)
library(fungible)

# Generate a simple factor model with two factors and six items
mod <- simFA(Model = list(NFac = 2, NItemPerFac = 3),
             Seed = 42)

(Omega <- mod$Rpop) # the model-implied correlation matrix
#>           V1        V2        V3        V4        V5        V6
#> V1 1.0000000 0.4493845 0.2759954 0.0000000 0.0000000 0.0000000
#> V2 0.4493845 1.0000000 0.2796873 0.0000000 0.0000000 0.0000000
#> V3 0.2759954 0.2796873 1.0000000 0.0000000 0.0000000 0.0000000
#> V4 0.0000000 0.0000000 0.0000000 1.0000000 0.4493845 0.2759954
#> V5 0.0000000 0.0000000 0.0000000 0.4493845 1.0000000 0.2796873
#> V6 0.0000000 0.0000000 0.0000000 0.2759954 0.2796873 1.0000000

set.seed(42)

# Generate a population correlation matrix with model error (Sigma) using the
# Cudeck and Browne (1992) method
noisemaker(mod, method = "CB", target_rmsea = 0.05)
#> $Sigma
#>              V1           V2         V3           V4           V5          V6
#> V1  1.000000000  0.449384535 0.27599542 -0.032181331 -0.028744381 0.009662973
#> V2  0.449384535  1.000000000 0.27968729 -0.007370352 -0.004001275 0.035583143
#> V3  0.275995418  0.279687285 1.00000000  0.047067522  0.051613664 0.070785224
#> V4 -0.032181331 -0.007370352 0.04706752  1.000000000  0.449384535 0.275995418
#> V5 -0.028744381 -0.004001275 0.05161366  0.449384535  1.000000000 0.279687285
#> V6  0.009662973  0.035583143 0.07078522  0.275995418  0.279687285 1.000000000
#> 
#> $rmsea
#> [1] 0.04999999
#> 
#> $cfi
#> [1] 0.9854324
#> 
#> $v
#> [1] NA
#> 
#> $eps
#> [1] NA
```

The `noisemaker()` function implements a method for simulating
correlation matrices with RMSEA values close to a target value based on
the adventitious error framework developed by [Wu and Browne
(2015)](https://link-springer-com.ezp1.lib.umn.edu/article/10.1007/s11336-015-9451-3).

``` r
noisemaker(mod, method = "WB", target_rmsea = 0.05)
#> Warning in .recacheSubclasses(def@className, def, env): undefined subclass
#> "numericVector" of class "Mnumeric"; definition not updated
#> $Sigma
#>             V1           V2           V3          V4           V5           V6
#> V1  1.00000000  0.440586099  0.276744840 -0.01252130 -0.028274417 -0.029007137
#> V2  0.44058610  1.000000000  0.293893396 -0.02663021  0.033773948  0.001035131
#> V3  0.27674484  0.293893396  1.000000000 -0.01450089  0.008299116 -0.006544648
#> V4 -0.01252130 -0.026630207 -0.014500889  1.00000000  0.457114670  0.295925028
#> V5 -0.02827442  0.033773948  0.008299116  0.45711467  1.000000000  0.320625627
#> V6 -0.02900714  0.001035131 -0.006544648  0.29592503  0.320625627  1.000000000
#> 
#> $rmsea
#> [1] 0.04924298
#> 
#> $cfi
#> [1] 0.9864878
#> 
#> $v
#> [1] NA
#> 
#> $eps
#> [1] NA
```

Finally, the `noisemaker()` function implements a procedure that
optimizes the values of the parameters for the [Tucker, Koopman, and
Linn (1969)](https://doi-org.ezp1.lib.umn.edu/10.1007/BF02290601) method
to produce a *Σ* matrix that has both RMSEA and CFI values close to the
user-specified targets:

``` r
noisemaker(mod, method = "TKL", 
           target_rmsea = 0.05, 
           target_cfi = 0.95,
           tkl_ctrl = list(optim_type = "optim"))
#> $Sigma
#>              V1           V2          V3          V4          V5          V6
#> V1  1.000000000  0.500756146  0.25597318 0.003608341 -0.01291235 -0.02667746
#> V2  0.500756146  1.000000000  0.24647748 0.004715913 -0.02456718 -0.01490170
#> V3  0.255973178  0.246477477  1.00000000 0.012761126  0.04327002 -0.05487096
#> V4  0.003608341  0.004715913  0.01276113 1.000000000  0.42463583  0.25647774
#> V5 -0.012912352 -0.024567176  0.04327002 0.424635833  1.00000000  0.24572421
#> V6 -0.026677455 -0.014901702 -0.05487096 0.256477745  0.24572421  1.00000000
#> 
#> $rmsea
#> [1] 0.0679774
#> 
#> $cfi
#> [1] 0.9726869
#> 
#> $v
#> [1] 0.1006799
#> 
#> $eps
#> [1] 0.4196303
```
