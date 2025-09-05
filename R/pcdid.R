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

# mean-gruop estimate
mg <- function(A) {
  # A is n_var x n_unit
  k <- nrow(A)
  n <- ncol(A)
  m <- rowMeans(A)
  v <- rowSums((A - m)^2) / (n * (n - 1))
  fake_lm <- list(coefficients = m)
  class(fake_lm) <- "lm"
  out <- lmtest::coeftest(fake_lm, vcov. = diag(v, k, k))
  return(out)
}

#' @export
pcdid <- function(
    formula,
    index,
    data,
    alpha = FALSE,
    fproxy = NULL,
    stationary = FALSE,
    kmax = 10,
    nwlag = round(max(data[[index[2]]])^0.25)) {
  # formula
  vars <- all.vars(formula)
  depvar <- vars[1]
  treatvar <- vars[2]
  didvar <- vars[3]
  indepvar <- vars[-(1:3)]
  id <- index[1]
  time <- index[2]

  # preprocess data
  data <- data[order(data[[id]], data[[time]]), ]
  data0 <- data[data[[treatvar]] == 0, ]
  data1 <- data[data[[treatvar]] == 1, ]

  X0 <- as.matrix(data0[, indepvar])
  X1 <- as.matrix(data1[, indepvar])

  y0 <- data0[[depvar]]
  y1 <- data1[[depvar]]

  T <- length(unique(data[[time]]))
  id0 <- unique(data0[[id]])
  id1 <- unique(data1[[id]])
  Nc <- length(id0)
  Nt <- length(id1)

  # compute residuals for control units
  # 1. individual regressions for each control unit
  # U <- matrix(NA, T, Nc)
  # for (j in 1:Nc) {
  #   idx <- which(data0[[id]] == id0[j])
  #   X0i <- as.matrix(X0[idx, ])
  #   reg <- lm(y0[idx] ~ X0i)
  #   U[, j] <- reg$residuals
  # }
  # u <- c(U)

  # 2. fixed effects regression
  X0fe <- X0
  y0fe <- y0
  for (j in 1:Nc) {
    idx <- which(data0[[id]] == id0[j])
    means <- matrix(rep(colMeans(X0[idx, ]), T), T, byrow = TRUE)
    X0fe[idx, ] <- X0fe[idx, ] - means
    y0fe[idx] <- y0fe[idx] - mean(y0[idx])
  }
  reg <- lm(y0fe ~ 0 + X0fe)
  u <- reg$residuals
  U <- matrix(u, T, Nc)

  # pca on residuals
  pca <- prcomp(U)

  # select number of factors
  if (is.null(fproxy)) {
    fproxy <- 0
    if (!stationary) {
      fproxy <- fproxy + grtest(pca, kmax)
    }

    # 1. individual time series regression
    # Uf <- matrix(NA, T, Nc)
    # for (j in 1:Nc) {
    #   reg <- lm(U[, j] ~ pca$x)
    #   Uf[, j] <- reg$residuals
    # }

    # 2. panel data regression
    reg <- lm(u ~ kronecker(rep(1, Nc), pca$x))
    Uf <- matrix(reg$residuals, T, Nc)
    pcaf <- prcomp(Uf)
    fproxy <- fproxy + grtest(pcaf, kmax)
  }
  F <- pca$x[, 1:fproxy] / Nc

  # pcdid regression
  out <- list()
  out$treated <- list()
  out$control <- list()
  beta <- matrix(NA, 1 + fproxy + length(indepvar) + 1, Nt)
  beta_names <- c("(Intercept)", didvar, indepvar, paste0("fproxy", 1:fproxy))
  rownames(beta) <- beta_names

  # treated units
  for (j in 1:Nt) {
    idx <- which(data1[[id]] == id1[j])
    X1i <- as.matrix(X1[idx, ])

    reg <- lm(y1[idx] ~ data1[[didvar]][idx] + X1i + F)
    names(reg$coefficients) <- beta_names
    beta[, j] <- coef(reg)

    vcov <- sandwich::NeweyWest(reg, prewhite = FALSE, adjust = TRUE, lag = nwlag)
    s <- summary(reg)
    s$coefficients <- lmtest::coeftest(reg, vcov. = vcov)
    s$fitted.values <- reg$fitted.values
    out$treated[[id1[j]]] <- s
  }

  # mean-group estimate
  out$mg <- mg(beta)

  # control units
  for (j in 1:Nc) {
    idx <- which(data0[[id]] == id0[j])
    X0i <- as.matrix(X0[idx, ])

    reg <- lm(y0[idx] ~ X1i + F)
    names(reg$coefficients) <- beta_names[-2] # no didvar
    vcov <- sandwich::NeweyWest(reg, prewhite = FALSE, adjust = TRUE, lag = nwlag)

    s <- summary(reg)
    s$coefficients <- lmtest::coeftest(reg, vcov. = vcov)
    s$fitted.values <- reg$fitted.values
    out$control[[id1[j]]] <- s
  }

  # alpha test
  if (alpha) {
    alpha <- matrix(NA, 1, Nt)
    uc <- rowMeans(U)

    for (j in 1:Nt) {
      idx <- which(data1[[id]] == id1[j])
      X1i <- as.matrix(X1[idx, ])
      reg <- lm(y1[idx] ~ uc + data1[[didvar]][idx] + X1i)
      alpha[1, j] <- coef(reg)[2]
    }

    rownames(alpha) <- "alpha"
    out$alpha <- mg(alpha)
  }

  class(out) <- "pcdid"
  return(out)
}
