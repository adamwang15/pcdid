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
  m <- rowMeans(A, na.rm = TRUE)
  v <- rowSums((A - m)^2) / (n * (n - 1))
  fake_lm <- list(coefficients = m)
  class(fake_lm) <- "lm"
  out <- lmtest::coeftest(fake_lm, vcov. = diag(v, k, k))
  return(out)
}

#' @title Principal Components Difference-in-Differences
#'
#' @description pcdid first uses a data-driven method (based on principal component analysis) on the control panel to compute factor proxies, which capture the unobserved trends. Then, among treated unit(s), it runs regression(s) using the factor proxies as extra covariates.  Analogous to a control function approach, these extra covariates capture the endogeneity arising from potentially unparallel trends.
#'
#' @param formula regression specification: depvar ~ treatvar + didvar + indepvar
#' @param index vector of length 2 indicating c(id, time)
#' @param data a data frame containing variables to be used
#' @param alpha perform the parallel trend alpha test. (Note: irrelevant if there is only one treated unit.)
#' @param fproxy set number of factors used. If this option is not specified, the number of factors will be automatically determined by the recursive factor number test.
#' @param stationary advanced option: assume all factors are stationary in the recursive factor number test. (Note: irrelevant if fproxy(#) is specified.)
#' @param kmax advanced option: set maximum number of factors in the recursive factor number test; default is 10. (Note: irrelevant if fproxy(#) is specified.)
#' @param nwlag set maximum lag order of autocorrelation in computing Newey-West standard errors; default is int(T^0.25). (Note: irrelevant if there is more than one treated unit.)
#'
#' @return A list of class \code{pcdid}, the output list includes element:
#'
#' \describe{
#'  \item{mg}{mean-group estimate of the treatment effect}
#'  \item{alpha}{alpha test result}
#'  \item{treated}{list of treated unit regression results}
#'  \item{control}{list of control unit regression results}
#' }
#'
#' @author Xiaolei Wang \email{adamwang15@gmail.com}
#'
#' @examples
#' result <- pcdid(
#'   lncase ~ treated + treated_post + afdcben + unemp + empratio + mon_d2 + mon_d3 + mon_d4,
#'   index = c("state", "trend"),
#'   data = welfare,
#'   alpha = TRUE
#' )
#'
#' result$mg
#'
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
  #   reg <- stats::lm(y0[idx] ~ X0i)
  #   U[, j] <- reg$residuals
  # }
  # u <- c(U)

  # 2. fixed effects regression
  X0fe <- X0
  y0fe <- y0
  for (j in 1:Nc) {
    idx <- which(data0[[id]] == id0[j])
    means <- matrix(rep(colMeans(X0[idx, ], na.rm = TRUE), T), T, byrow = TRUE)
    X0fe[idx, ] <- X0fe[idx, ] - means
    y0fe[idx] <- y0fe[idx] - mean(y0[idx])
  }
  if (ncol(X0fe) == 0) {
    reg <- stats::lm(y0fe ~ 1)
  } else {
    reg <- stats::lm(y0fe ~ 0 + X0fe)
  }
  u <- reg$residuals
  U <- matrix(u, T, Nc)

  # pca on residuals
  pca <- stats::prcomp(U)

  # select number of factors
  if (is.null(fproxy)) {
    fproxy <- 0
    if (!stationary) {
      fproxy <- fproxy + grtest(pca, kmax)
    }

    # 1. individual time series regression
    # Uf <- matrix(NA, T, Nc)
    # for (j in 1:Nc) {
    #   reg <- stats::lm(U[, j] ~ pca$x)
    #   Uf[, j] <- reg$residuals
    # }

    # 2. panel data regression
    reg <- stats::lm(u ~ kronecker(rep(1, Nc), pca$x))
    Uf <- matrix(reg$residuals, T, Nc)
    pcaf <- stats::prcomp(Uf)
    fproxy <- fproxy + grtest(pcaf, kmax)
  }

  # factor proxies
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

    if (ncol(X1i) == 0) {
      reg <- stats::lm(y1[idx] ~ data1[[didvar]][idx] + F)
    } else {
      reg <- stats::lm(y1[idx] ~ data1[[didvar]][idx] + X1i + F)
    }
    names(reg$coefficients) <- beta_names
    beta[, j] <- stats::coef(reg)

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

    if (ncol(X1i) == 0) {
      reg <- stats::lm(y0[idx] ~ F)
    } else {
      reg <- stats::lm(y0[idx] ~ X1i + F)
    }
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
    uc <- rowMeans(U, na.rm = TRUE)

    for (j in 1:Nt) {
      idx <- which(data1[[id]] == id1[j])
      X1i <- as.matrix(X1[idx, ])
      if (ncol(X1i) == 0) {
        reg <- stats::lm(y1[idx] ~ uc + data1[[didvar]][idx])
      } else {
        reg <- stats::lm(y1[idx] ~ uc + data1[[didvar]][idx] + X1i)
      }
      alpha[1, j] <- stats::coef(reg)[2]
    }

    rownames(alpha) <- "alpha"
    out$alpha <- mg(alpha)
  }

  class(out) <- "pcdid"
  return(out)
}
