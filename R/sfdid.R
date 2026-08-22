#' @title Spatial Factor Difference-in-Differences
#'
#' @description sfdid implements the Spatial Factor Difference-in-Differences estimator.
#'
#' @param formula regression specification: depvar ~ treatvar + didvar + indepvar
#' @param index vector of length 2 indicating c(id, time)
#' @param data a data frame containing variables to be used
#' @param W spatial weight matrix (N x N)
#' @param npc_method method for determining the number of factors: "BN" (Bai-Ng) or "ER" (Eigenvalue Ratio)
#' @param kmax_y max factors for L-step
#' @param kmax_c max factors for D-step
#' @param qml_iters max iterations for QML
#' @param tol_bhat tolerance for early stopping
#' @param rho_hetero spatial parameter heterogeneity setup (1 = full heterogeneous, 2, 3, 4 = homogeneous)
#'
#' @return A list of class \code{sfdid}
#'
#' @export
sfdid <- function(
    formula,
    index,
    data,
    W,
    npc_method = "BN",
    kmax_y = 5,
    kmax_c = 5,
    qml_iters = 15,
    tol_bhat = 1e-4,
    rho_hetero = 1) {
  
  # check inputs
  if (length(all.vars(formula)) < 3) {
    stop("Formula must include at least 3 variables: depvar ~ treatvar + didvar.")
  }
  if (length(index) != 2) {
    stop("Index must be a vector of length 2 indicating c(id, time).")
  }
  
  # formula
  vars <- split_formula(formula)
  depvar <- vars$y
  treatvar <- vars$x[1]
  didvar <- vars$x[2]
  indepvar <- vars$x[-(1:2)]
  
  # index
  id <- index[1]
  time <- index[2]
  
  # Ensure states are sorted logically: Treated first, Controls second
  treated_units <- unique(data[[id]][data[[treatvar]] == 1])
  control_units <- setdiff(unique(data[[id]]), treated_units)
  all_units <- c(treated_units, control_units)
  
  Nt <- length(treated_units)
  Nc <- length(control_units)
  N <- Nt + Nc
  
  # Sort the data appropriately
  data[[id]] <- factor(data[[id]], levels = all_units)
  data <- data[order(data[[id]], data[[time]]), ]
  
  time_periods <- unique(data[[time]])
  T <- length(time_periods)
  
  # Find T0 (number of pre-intervention periods)
  T0 <- min(which(time_periods %in% data[[time]][data[[didvar]] == 1])) - 1
  if (is.infinite(T0) || T0 < 1) {
    T0 <- T # Fallback if no treated_post == 1 found (e.g. pure test)
  }
  T1 <- T - T0
  
  # Reshape y
  y <- matrix(data[[depvar]], nrow = N, ncol = T, byrow = TRUE)
  
  # Reshape x (covariates)
  K <- length(indepvar)
  withx <- K > 0
  if (withx) {
    x_arr <- array(0, dim = c(N, T, K))
    for (k in 1:K) {
      x_arr[, , k] <- matrix(data[[indepvar[k]]], nrow = N, ncol = T, byrow = TRUE)
    }
  } else {
    x_arr <- array(0, dim = c(N, T, 0))
  }
  
  # Reorder W based on states
  if (!all(rownames(W) == all_units)) {
    W <- W[all_units, all_units]
  }
  
  # --- L-step: QML on Pre-intervention Data ---
  S <- diag(N)
  if (is.numeric(npc_method)) {
    npcy_hat <- npc_method
  } else {
    npcy_hat <- estimate_num_factors(y[, 1:T0], kmax_y, npc_method)
  }
  
  ghat <- matrix(0, nrow = npcy_hat, ncol = N)
  se_ghat <- matrix(0, nrow = npcy_hat, ncol = N)
  ypc <- matrix(0, nrow = T0, ncol = npcy_hat)
  
  bhat <- matrix(0, nrow = max(K, 1), ncol = N)
  se_bhat <- matrix(0, nrow = max(K, 1), ncol = N)
  rhat <- rep(0, 4)
  
  actual_iter <- qml_iters
  
  for (l in 1:qml_iters) {
    bhat_old <- bhat
    
    Y_adj <- t(S %*% y[, 1:T0]) # T0 x N
    if (withx) {
      for (i in 1:N) {
        x_ik <- matrix(x_arr[i, 1:T0, ], nrow = T0, ncol = K)
        Y_adj[, i] <- Y_adj[, i] - x_ik %*% bhat[, i]
      }
    }
    
    # PCA
    yy <- crossprod(Y_adj) / T0 # N x N
    eig_res <- eigen(yy, symmetric = TRUE)
    coeff <- eig_res$vectors
    
    actual_npcy <- min(npcy_hat, ncol(coeff))
    coeff <- scale(coeff, center = FALSE, scale = colSums(coeff))
    ypc <- Y_adj %*% coeff[, 1:actual_npcy]
    
    r0 <- rhat
    
    # Optimization
    if (withx) {
      opt_res <- stats::optim(
        par = r0,
        fn = nll_i,
        Y = y[, 1:T0],
        X = x_arr[, 1:T0, , drop = FALSE],
        W = W,
        f = ypc,
        Nt = Nt,
        rho_hetero = rho_hetero,
        method = "L-BFGS-B",
        hessian = TRUE
      )
    } else {
      opt_res <- stats::optim(
        par = r0,
        fn = nll_i_nox,
        Y = y[, 1:T0],
        W = W,
        f = ypc,
        Nt = Nt,
        rho_hetero = rho_hetero,
        method = "L-BFGS-B",
        hessian = TRUE
      )
    }
    
    rhat <- opt_res$par
    llout <- -opt_res$value
    
    # Calculate var_rho
    # Use generalized inverse to avoid singular matrices issues
    var_rho <- tryCatch({
      solve(opt_res$hessian)
    }, error = function(e) {
      MASS::ginv(opt_res$hessian)
    })
    se_rhat <- sqrt(diag(var_rho))
    
    pW <- build_pW(rhat, W, Nt, N, rho_hetero)
    S <- diag(N) - pW
    
    ghat <- matrix(0, nrow = actual_npcy, ncol = N)
    se_ghat <- matrix(0, nrow = actual_npcy, ncol = N)
    
    for (i in 1:N) {
      if (!withx) {
        XX <- crossprod(ypc)
        XY <- crossprod(ypc, as.numeric(S[i, ] %*% y[, 1:T0]))
        theta <- solve(XX, XY)
        
        resid <- as.numeric(S[i, ] %*% y[, 1:T0]) - ypc %*% theta
        s2 <- sum(resid^2) / max(1, T0 - length(theta))
        se_theta <- sqrt(diag(s2 * solve(XX)))
        
        ghat[1:actual_npcy, i] <- theta
        se_ghat[1:actual_npcy, i] <- se_theta
      } else {
        x_ik <- matrix(x_arr[i, 1:T0, ], nrow = T0, ncol = K)
        reg_mat <- cbind(ypc, x_ik)
        XX <- crossprod(reg_mat)
        XY <- crossprod(reg_mat, as.numeric(S[i, ] %*% y[, 1:T0]))
        theta <- solve(XX, XY)
        
        resid <- as.numeric(S[i, ] %*% y[, 1:T0]) - reg_mat %*% theta
        s2 <- sum(resid^2) / max(1, T0 - length(theta))
        se_theta <- sqrt(diag(s2 * solve(XX)))
        
        ghat[1:actual_npcy, i] <- theta[1:actual_npcy]
        se_ghat[1:actual_npcy, i] <- se_theta[1:actual_npcy]
        bhat[, i] <- theta[(actual_npcy + 1):length(theta)]
        se_bhat[, i] <- se_theta[(actual_npcy + 1):length(theta)]
      }
    }
    
    if (!withx) {
      actual_iter <- 1
      break
    } else if (l > 1 && max(abs(bhat - bhat_old)) < tol_bhat) {
      actual_iter <- l
      break
    }
    actual_iter <- l
  }
  
  # --- D-step: PCA on Residuals ---
  uhat <- matrix(0, nrow = N, ncol = T)
  for (i in 1:N) {
    if (!withx) {
      uhat[i, ] <- S[i, ] %*% y
    } else {
      x_i <- matrix(x_arr[i, , ], nrow = T, ncol = K)
      uhat[i, ] <- S[i, ] %*% y - as.numeric(x_i %*% bhat[, i])
    }
  }
  
  if (is.numeric(npc_method)) {
    npc_hat <- npc_method
  } else {
    npc_hat <- estimate_num_factors(uhat[(Nt + 1):N, ], kmax_c, npc_method)
  }
  uu <- uhat[(Nt + 1):N, ] %*% t(uhat[(Nt + 1):N, ]) / T
  eig_res_u <- eigen(uu, symmetric = TRUE)
  coeff_u <- eig_res_u$vectors
  
  actual_npc <- min(npc_hat, ncol(coeff_u))
  coeff_u <- scale(coeff_u, center = FALSE, scale = colSums(coeff_u))
  upc <- t(uhat[(Nt + 1):N, ]) %*% coeff_u[, 1:actual_npc]
  
  # --- T-step: Treatment Effect Regression ---
  time_dummy <- c(rep(0, T0), rep(1, T1))
  delta <- numeric(Nt)
  se_delta <- numeric(Nt)
  
  for (i in 1:Nt) {
    if (!withx) {
      reg_x <- cbind(time_dummy, upc)
      reg_u <- uhat[i, ]
    } else {
      x_i <- matrix(x_arr[i, , ], nrow = T, ncol = K)
      reg_x <- cbind(time_dummy, upc, x_i)
      reg_u <- as.numeric(S[i, ] %*% y)
    }
    res <- regress_full(reg_u, reg_x)
    delta[i] <- res$b[1]
    se_delta[i] <- res$bse[1]
  }
  
  # Spillover Calculations
  ete_tmp <- solve(S, c(delta, rep(0, Nc)))
  ete <- ete_tmp[1:Nt]
  etc <- ete_tmp[(Nt + 1):N]
  aete <- mean(ete)
  aetc <- mean(etc)
  adte <- mean(delta)
  
  # --- SE Calculations for Averages (Analytic Jacobian) ---
  var_dte_naive <- sum(se_delta^2) / (Nt^2)
  
  M_hat <- solve(S)
  w_hat <- t(M_hat[1:Nt, 1:Nt]) %*% rep(1, Nt) / Nt
  w_hat_c <- t(M_hat[(Nt + 1):N, 1:Nt]) %*% rep(1, Nc) / Nc
  
  var_ete_naive <- sum((w_hat^2) * (se_delta^2))
  var_etc_naive <- sum((w_hat_c^2) * (se_delta^2))
  
  d_rho <- 1e-5
  n_rho <- length(rhat)
  J_rho_dte <- numeric(n_rho)
  J_rho_ete <- numeric(n_rho)
  J_rho_etc <- numeric(n_rho)
  
  for (r_idx in 1:n_rho) {
    rho_p <- rhat
    rho_p[r_idx] <- rho_p[r_idx] + d_rho
    
    pW_p <- build_pW(rho_p, W, Nt, N, rho_hetero)
    S_p <- diag(N) - pW_p
    
    uhat_p <- matrix(0, nrow = N, ncol = T)
    for (i in 1:N) {
      if (!withx) {
        uhat_p[i, ] <- S_p[i, ] %*% y
      } else {
        x_i <- matrix(x_arr[i, , ], nrow = T, ncol = K)
        uhat_p[i, ] <- S_p[i, ] %*% y - as.numeric(x_i %*% bhat[, i])
      }
    }
    
    uu_p <- uhat_p[(Nt + 1):N, ] %*% t(uhat_p[(Nt + 1):N, ]) / T
    eig_p <- eigen(uu_p, symmetric = TRUE)
    coeff_p <- eig_p$vectors
    coeff_p <- scale(coeff_p, center = FALSE, scale = colSums(coeff_p))
    upc_p <- t(uhat_p[(Nt + 1):N, ]) %*% coeff_p[, 1:min(actual_npc, ncol(coeff_p))]
    
    delta_p <- numeric(Nt)
    for (i in 1:Nt) {
      if (!withx) {
        reg_x <- cbind(time_dummy, upc_p)
      } else {
        x_i <- matrix(x_arr[i, , ], nrow = T, ncol = K)
        reg_x <- cbind(time_dummy, upc_p, x_i)
      }
      res_p <- regress_full(uhat_p[i, ], reg_x)
      delta_p[i] <- res_p$b[1]
    }
    
    ete_p_tmp <- solve(S_p, c(delta_p, rep(0, Nc)))
    J_rho_dte[r_idx] <- (mean(delta_p) - adte) / d_rho
    J_rho_ete[r_idx] <- (mean(ete_p_tmp[1:Nt]) - aete) / d_rho
    J_rho_etc[r_idx] <- (mean(ete_p_tmp[(Nt + 1):N]) - aetc) / d_rho
  }
  
  var_adj_dte <- t(J_rho_dte) %*% var_rho %*% J_rho_dte
  var_adj_ete <- t(J_rho_ete) %*% var_rho %*% J_rho_ete
  var_adj_etc <- t(J_rho_etc) %*% var_rho %*% J_rho_etc
  
  se_adte <- sqrt(max(var_dte_naive + as.numeric(var_adj_dte), var_dte_naive))
  se_aete_adj <- sqrt(max(var_ete_naive + as.numeric(var_adj_ete), var_ete_naive))
  se_aetc_adj <- sqrt(max(var_etc_naive + as.numeric(var_adj_etc), var_etc_naive))
  
  # --- Pack Outputs ---
  out <- list()
  out$rhat <- rhat
  out$se_rhat <- se_rhat
  out$bhat <- bhat
  out$se_bhat <- se_bhat
  out$ghat <- ghat
  out$se_ghat <- se_ghat
  out$delta <- delta
  out$se_delta <- se_delta
  out$adte <- adte
  out$se_adte <- se_adte
  out$aete <- aete
  out$se_aete <- se_aete_adj
  out$aetc <- aetc
  out$se_aetc <- se_aetc_adj
  out$llout <- llout
  
  class(out) <- "sfdid"
  return(out)
}
