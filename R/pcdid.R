pcdid <- function(depvar, treatvar, didvar, indepvar, id, time, data, p) {
  # preprocess data
  data <- data[order(data[[id]], data[[time]]), ]
  data0 <- data[data[[treatvar]] == 0, ]
  data1 <- data[data[[treatvar]] == 1, ]

  X0 <- as.matrix(data0[, indepvar])
  X1 <- as.matrix(data1[, indepvar])

  y0 <- data0[[depvar]]
  y1 <- data1[[depvar]]

  T <- length(unique(data[[time]]))
  Nc <- length(unique(data0[[id]]))
  Nt <- length(unique(data1[[id]]))

  id0 <- unique(data0[[id]])
  id1 <- unique(data1[[id]])

  # compute residuals for control units
  # 1. individual regressions for each control unit
  # U <- matrix(NA, T, Nc)
  # for (j in 1:Nc) {
  #   idx <- which(data0[[id]] == id0[j])
  #   X0i <- as.matrix(X0[idx, ])
  #   reg <- lm(y0[idx] ~ X0i)
  #   U[, j] <- reg$residuals
  # }
  # 2. fixed effects regression
  X0fe <- X0
  y0fe <- y0
  # remove individual fixed effects
  for (j in 1:Nc) {
    idx <- which(data0[[id]] == id0[j])
    X0fe[idx, ] <- X0fe[idx, ] - matrix(rep(colMeans(X0[idx, ]), T), T, byrow = TRUE)
    y0fe[idx] <- y0fe[idx] - mean(y0[idx])
  }
  reg <- lm(y0fe ~ 0 + X0fe)
  U <- matrix(reg$residuals, T, Nc)

  # pca on residuals
  pca <- prcomp(U)
  F <- pca$x[, 1:p] / Nc

  # pcdid regression
  beta <- matrix(NA, 1 + p + length(indepvar) + 1, Nt)
  # beta <- matrix(NA, 2 + length(indepvar), Nt)
  for (j in 1:Nt) {
    idx <- which(data1[[id]] == id1[j])
    X1i <- as.matrix(X1[idx, ])
    reg <- lm(y1[idx] ~ data1[[didvar]][idx] + X1i + F)
    beta[, j] <- coef(reg)
  }

  out <- rowMeans(beta)
  return(out)
}
