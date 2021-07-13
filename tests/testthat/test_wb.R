# Tests for wb()

mod <- fungible::simFA(Seed = 42)
Omega <- mod$Rpop

set.seed(42)
Sigma <- wb(target_rmsea = 0.05, Omega)
wb_coef <- find_wb_coef(mod, n = 100, values = 10, lower = 0.045, upper = 0.055)

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

test_that("Function works when wb_coef is specified.", {
  expect_error(wb(Omega = Omega, target_rmsea = 0.05, wb_coef = -0.1))
  expect_lte(abs(rmsea(wb(Omega, target_rmsea = 0.05, wb_coef = wb_coef),
                       Omega, k = ncol(mod$loadings)) - 0.05), 0.01)
})

test_that("RMSEA value is in the ballpark of the target RMSEA value", {
  expect_lte(abs(rmsea(Sigma, Omega, k = ncol(mod$loadings)) - 0.05), .1)
})
