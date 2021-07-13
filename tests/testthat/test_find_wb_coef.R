# Tests for find_wb_coef()

mod <- fungible::simFA(Seed = 42)
set.seed(42)

test_that("Errors are thrown when `mod` isn't a simFA() object.", {
  expect_error(find_wb_coef(mod = "a"))
  expect_error(find_wb_coef(mod = list(a = 1, b = 2)))
}
)

test_that("Errors are thrown when `n` is not valid.", {
  expect_error(find_wb_coef(mod, n = NA))
  expect_error(find_wb_coef(mod, n = -1))
  expect_error(find_wb_coef(mod, n = "a"))
})

test_that("Errors are thrown when `values` is not valid.", {
  expect_error(find_wb_coef(mod, values = NA))
  expect_error(find_wb_coef(mod, values = -1))
  expect_error(find_wb_coef(mod, values = 1))
})

test_that("Errors are thrown when `lower` is not valid.", {
  expect_error(find_wb_coef(mod, lower = NA))
  expect_error(find_wb_coef(mod, lower = -.1))
  expect_error(find_wb_coef(mod, lower = 0))
})

test_that("Errors are thrown when `upper` is not valid.", {
  expect_error(find_wb_coef(mod, upper = NA))
  expect_error(find_wb_coef(mod, upper = .15))
})
