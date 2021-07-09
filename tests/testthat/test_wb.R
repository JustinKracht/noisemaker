# Tests for wb()

set.seed(42)
library(noisemaker)
library(fungible)

mod <- fungible::simFA()
Omega <- mod$Rpop
Sigma <- wb(target_rmsea = 0.05, Omega)

# Load an indefinite matrix (BadRBY) and create a non-symmetric matrix
data(BadRBY, package = "fungible")
nonsymmetric_matrix <- fungible::rcor(5)
nonsymmetric_matrix[1,2] <- .1

test_that("Errors are thrown when invalid target RMSEA values are given", {
  expect_error(wb(target_rmsea = "a", Omega))
  expect_error(wb(target_rmsea = -.01, Omega))
  expect_error(wb(target_rmsea = 1.01, Omega))
  expect_error(wb(target_rmsea = NULL, Omega))
}
)

test_that("Errors are thrown when invalid Omega values are given", {
  expect_error(wb(target_rmsea = 0.05, Omega = "a"))
  expect_error(wb(target_rmsea = 0.05, Omega = nonsymmetric_matrix))
  expect_error(wb(target_rmsea = 0.05, Omega = BadRBY))
})

test_that("Function output has the expected dimension and type", {
  expect_equal(dim(Omega), dim(Sigma))
  expect_false(any(eigen(Sigma)$values < 0))
  expect_false(any(diag(Sigma) != 1))
  expect_false(any(abs(Sigma) > 1))
})

test_that("RMSEA value is in the ballpark of the target RMSEA value", {
  expect_true(abs(rmsea(Sigma, Omega, k = 3) - 0.05) < 0.1)
})
