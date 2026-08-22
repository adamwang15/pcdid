# growth ratio test
grtest <- function(pca, kmax) {
  n <- ncol(pca$x)
  T <- nrow(pca$x)

  eigval <- pca$sdev^2
  V <- rev(cumsum(rev(eigval[1:min(n, T)])))[-1]
  ratio <- log(1 + eigval[-n] / V)
  gr <- ratio[-length(ratio)] / ratio[-1]
  fproxy <- min(which.max(gr), kmax)

  return(fproxy)
}

# mean-group estimate
mg <- function(A) {
  # A is n_var x n_unit
  k <- nrow(A)
  n <- ncol(A)
  m <- rowMeans(A, na.rm = TRUE)
  v <- rowSums((A - m)^2, na.rm = TRUE) / (n * (n - 1))
  fake_lm <- list(coefficients = m)
  class(fake_lm) <- "lm"
  out <- lmtest::coeftest(fake_lm, vcov. = diag(v, k, k))
  return(out)
}

split_formula <- function(formula) {
  y <- all.vars(formula[[2]])
  rhs <- formula[[3]]

  if (rhs[[1]] == "|") {
    x <- all.vars(rhs[[2]])
    z <- all.vars(rhs[[3]])
  } else {
    x <- all.vars(rhs)
    z <- NULL
  }

  out <- list(y = y, x = x, z = z)

  return(out)
}

estimate_num_factors <- function(Y, kmax, method) {
  N <- nrow(Y)
  T <- ncol(Y)
  if (N > T) {
    Sigma <- t(Y) %*% Y / (N * T)
  } else {
    Sigma <- Y %*% t(Y) / (N * T)
  }

  evals <- sort(eigen(Sigma, symmetric = TRUE, only.values = TRUE)$values, decreasing = TRUE)
  kmax <- min(c(kmax, N - 1, T - 1))
  if (kmax < 1) {
    return(1)
  }

  if (method == "ER") {
    ER <- numeric(kmax)
    for (k in 1:kmax) {
      ER[k] <- evals[k] / evals[k + 1]
    }
    k_hat <- which.max(ER)
  } else if (method == "BN") {
    IC <- numeric(kmax)
    for (k in 1:kmax) {
      Vk <- max(sum(evals[(k + 1):length(evals)]), 1e-12)
      penalty <- k * ((N + T) / (N * T)) * log(min(N, T))
      IC[k] <- log(Vk) + penalty
    }
    k_hat <- which.min(IC)
  }

  k_hat <- max(k_hat, 1)
  return(k_hat)
}

build_pW <- function(pa, W, Nt, N, rho_hetero) {
  pW <- matrix(0, N, N)
  if (rho_hetero == 1) {
    pW[1:Nt, 1:Nt] <- pa[1] * W[1:Nt, 1:Nt]
    pW[1:Nt, (Nt + 1):N] <- pa[2] * W[1:Nt, (Nt + 1):N]
    pW[(Nt + 1):N, 1:Nt] <- pa[3] * W[(Nt + 1):N, 1:Nt]
    pW[(Nt + 1):N, (Nt + 1):N] <- pa[4] * W[(Nt + 1):N, (Nt + 1):N]
  } else {
    pW[1:Nt, 1:Nt] <- pa[1] * W[1:Nt, 1:Nt]
    pW[1:Nt, (Nt + 1):N] <- pa[1] * W[1:Nt, (Nt + 1):N]
    pW[(Nt + 1):N, 1:Nt] <- pa[1] * W[(Nt + 1):N, 1:Nt]
    pW[(Nt + 1):N, (Nt + 1):N] <- pa[1] * W[(Nt + 1):N, (Nt + 1):N]
  }
  return(pW)
}

nll_i <- function(pa, Y, X, W, f, Nt, rho_hetero) {
  N <- nrow(Y)
  T <- ncol(Y)
  K <- dim(X)[3]
  pW <- build_pW(pa, W, Nt, N, rho_hetero)
  S <- diag(N) - pW

  sigma2 <- numeric(N)
  for (i in 1:N) {
    x_i <- matrix(X[i, , ], nrow = T, ncol = K)
    reg_mat <- cbind(x_i, f)
    XX <- crossprod(reg_mat)
    SY_i <- as.numeric(S[i, ] %*% Y)
    XY <- crossprod(reg_mat, SY_i)
    theta <- solve(XX, XY)
    U <- SY_i - reg_mat %*% theta
    sigma2[i] <- sum(U^2) / T
  }

  detS <- det(S)
  if (detS <= 0) {
    return(1e12)
  }

  fout <- T / 2 * sum(log(sigma2)) - T * log(detS)
  return(fout)
}

nll_i_nox <- function(pa, Y, W, f, Nt, rho_hetero) {
  N <- nrow(Y)
  T <- ncol(Y)
  pW <- build_pW(pa, W, Nt, N, rho_hetero)
  S <- diag(N) - pW

  sigma2 <- numeric(N)
  for (i in 1:N) {
    XX <- crossprod(f)
    SY_i <- as.numeric(S[i, ] %*% Y)
    XY <- crossprod(f, SY_i)
    theta <- solve(XX, XY)
    U <- SY_i - f %*% theta
    sigma2[i] <- sum(U^2) / T
  }

  detS <- det(S)
  if (detS <= 0) {
    return(1e12)
  }

  fout <- T / 2 * sum(log(sigma2)) - T * log(detS)
  return(fout)
}

create_coeftest <- function(estimates, ses, names = NULL) {
  if (is.null(names)) {
    names <- names(estimates)
    if (is.null(names)) {
      names <- paste0("V", seq_along(estimates))
    }
  }
  names(estimates) <- names
  fake_lm <- list(coefficients = estimates)
  class(fake_lm) <- "lm"
  out <- lmtest::coeftest(fake_lm, vcov. = diag(ses^2, length(ses), length(ses)))
  return(out)
}

#' Generate Spatial Weight Matrix
#'
#' @description Generates a row-normalized spatial weight matrix based on state contiguity.
#'
#' @param states A character vector of state abbreviations.
#'
#' @return A spatial weight matrix.
#'
#' @export
generate_W <- function(states) {
  state_neighbors <- list(
    AL = c("FL", "GA", "MS", "TN"),
    AK = character(0),
    AZ = c("CA", "CO", "NV", "NM", "UT"),
    AR = c("LA", "MO", "MS", "OK", "TN", "TX"),
    CA = c("AZ", "NV", "OR"),
    CO = c("AZ", "KS", "NE", "NM", "OK", "UT", "WY"),
    CT = c("MA", "NY", "RI"),
    DE = c("MD", "NJ", "PA"),
    FL = c("AL", "GA"),
    GA = c("AL", "FL", "NC", "SC", "TN"),
    HI = character(0),
    ID = c("MT", "NV", "OR", "UT", "WA", "WY"),
    IL = c("IA", "IN", "KY", "MO", "WI"),
    IN = c("IL", "KY", "MI", "OH"),
    IA = c("IL", "MN", "MO", "NE", "SD", "WI"),
    KS = c("CO", "MO", "NE", "OK"),
    KY = c("IL", "IN", "MO", "OH", "TN", "VA", "WV"),
    LA = c("AR", "MS", "TX"),
    ME = c("NH"),
    MD = c("DE", "PA", "VA", "WV", "DC"),
    MA = c("CT", "NH", "NY", "RI", "VT"),
    MI = c("IN", "OH", "WI"),
    MN = c("IA", "ND", "SD", "WI"),
    MS = c("AL", "AR", "LA", "TN"),
    MO = c("AR", "IA", "IL", "KS", "KY", "NE", "OK", "TN"),
    MT = c("ID", "ND", "SD", "WY"),
    NE = c("CO", "IA", "KS", "MO", "SD", "WY"),
    NV = c("AZ", "CA", "ID", "OR", "UT"),
    NH = c("MA", "ME", "VT"),
    NJ = c("DE", "NY", "PA"),
    NM = c("AZ", "CO", "OK", "TX", "UT"),
    NY = c("CT", "MA", "NJ", "PA", "VT"),
    NC = c("GA", "SC", "TN", "VA"),
    ND = c("MN", "MT", "SD"),
    OH = c("IN", "KY", "MI", "PA", "WV"),
    OK = c("AR", "CO", "KS", "MO", "NM", "TX"),
    OR = c("CA", "ID", "NV", "WA"),
    PA = c("DE", "MD", "NJ", "NY", "OH", "WV"),
    RI = c("CT", "MA"),
    SC = c("GA", "NC"),
    SD = c("IA", "MN", "MT", "ND", "NE", "WY"),
    TN = c("AL", "AR", "GA", "KY", "MO", "MS", "NC", "VA"),
    TX = c("AR", "LA", "NM", "OK"),
    UT = c("AZ", "CO", "ID", "NV", "NM", "WY"),
    VT = c("MA", "NH", "NY"),
    VA = c("KY", "MD", "NC", "TN", "WV"),
    WA = c("ID", "OR"),
    WV = c("KY", "MD", "OH", "PA", "VA"),
    WI = c("IA", "IL", "MI", "MN"),
    WY = c("CO", "ID", "MT", "NE", "SD", "UT")
  )

  N <- length(states)
  W <- matrix(0, nrow = N, ncol = N)
  for (i in 1:N) {
    for (j in 1:N) {
      if (states[j] %in% state_neighbors[[states[i]]]) {
        W[i, j] <- 1
      }
    }
  }
  rownames(W) <- states
  colnames(W) <- states

  return(W)
}
