pcdid <- function(depvar, treatvar, didvar, indepvar, id, time, data, p) {
  # preprocess data
  data0 <- data[data[[treatvar]] == 0, ]
  data1 <- data[data[[treatvar]] == 1, ]

  X0 <- data0[, indepvar]
  X1 <- data1[, indepvar]

  y0 <- data0[[depvar]]
  y1 <- data1[[depvar]]

  T <- length(unique(data[[time]]))
  Nc <- length(unique(data0[[id]]))
  Nt <- length(unique(data1[[id]]))

  # PCA on residuals
  id0 <- unique(data0[[id]])
  id1 <- unique(data1[[id]])
  U <- matrix(NA, T, Nc)

  for (j in 1:Nc) {
    idx <- which(data0[[id]] == id0[j])
    X0i <- as.matrix(X0[idx, ])
    reg <- lm(y0[idx] ~ X0i)
    U[, j] <- reg$residuals
  }

  pca <- prcomp(U)
  F <- pca$x[, 1:p] / Nc

  # pcdid regression
  beta <- matrix(NA, 1 + p + length(indepvar) + 1, Nt)
  # beta <- matrix(NA, 2 + length(indepvar), Nt)
  for (j in 1:Nt) {
    idx <- which(data1[[id]] == id1[j])
    X1i <- as.matrix(X1[idx, ])
    b0i <- rep(1, length(idx))
    reg <- lm(y1[idx] ~ 0 + data1[[didvar]][idx] + X1i + F + b0i)
    beta[, j] <- coef(reg)
  }

  out <- rowMeans(beta)
  return(out)
}
