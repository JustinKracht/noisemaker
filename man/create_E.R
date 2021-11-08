duplication.matrix <- function(n = 1) {
  if ((n < 1) | !is.integer(n)) {
    stop("n must be a positive integer")
  }

  d <- matrix(0, n * n, n * (n + 1) / 2)
  count <- 0

  for (j in 1:n) {
    d[(j - 1) * n + j, count + j] <- 1
    if (j < n) {
      for (i in (j + 1):n) {
        d[(j - 1) * n + i, count + i] <- 1
        d[(i - 1) * n + j, count + i] <- 1
      }
    }
    count <- count + n - j
  }

  d
}

vech <- function(x) {
  t(t(x[!upper.tri(x)]))
}

tr <- function(x) sum(diag(x))

create_E <- function(model, model_pars, latent_vars, discrep, ML = TRUE) {

  t <- length(model_pars)
  k <- length(latent_vars)
  T <- rep(0, t)
  K <- rep(0, k)

  delta <- discrep
  gamma0 <- model_pars

  ram_list <- model.2.ram(model, gamma0, latent_vars)

  Omega <- ram.2.Sigma(gamma0, ram_list)
  q <- ram_list$t # No. of model parameters
  p <- ram_list$n # No. of manifest variables
  p_star <- p * (p + 1) / 2

  Dmat <- duplication.matrix(p)

  D <- crossprod(Dmat)
  if (isTRUE(ML)) W <- Omega
  W.inv <- solve(W)

  h <- 1e-8
  Sigma_deriv <- array(NA, c(p, p, q))
  B <- matrix(NA, p_star, q)

  for (i in 1:q) {
    u <- matrix(0, q, 1)
    u[i, ] <- 1
    gamma <- gamma0 + u * h
    names(gamma) <- names(gamma0)
    Sigma_gamma <- ram.2.Sigma(gamma, ram_list)

    Sigma_deriv[, , i] <- (Sigma_gamma - Omega) * (1 / h)
    B[, i] <- (-1) * D %*% vech(W.inv %*% Sigma_deriv[, , i] %*% W.inv)
  }

  y <- matrix(1:p_star / 100, p_star, 1)
  B.qr <- qr(B)
  e.tilt <- qr.resid(B.qr, y)

  E1 <- matrix(0, p, p)
  index <- 1
  for (i2 in 1:p) {
    for (i1 in i2:p) {
      E1[i1, i2] <- e.tilt[index, 1]
      index <- index + 1
    }
  }

  E2 <- matrix(0, p, p)
  index <- 1
  for (i1 in 1:p) {
    for (i2 in i1:p) {
      E2[i1, i2] <- e.tilt[index, 1]
      index <- index + 1
    }
  }

  E.tilt <- E1 + E2 - diag(diag(E1))

  G <- W.inv %*% E.tilt
  get.kappa <- function(kappa, G, I, delta) {
    target <- abs(kappa * tr(G) - log(det(I + kappa * G)) - delta)
    return(target)
  }

  kappa0 <- sqrt(2 * delta / tr(G %*% G))
  I <- diag(p)
  res.kappa <- suppressWarnings(nlm(get.kappa, kappa0, G = G, I = I, delta = delta))
  kappa <- res.kappa$estimate
  iter <- res.kappa$iterations

  kappa <- as.numeric(kappa)
  E <- kappa * E.tilt
  Sigma <- Omega + E

  list(Sigma = Sigma,
       Omega = Omega,
       E = E)
}
