# -----------------------------------------
#  Ladybug Beetle Optimization (LBO)
# -----------------------------------------
lbo_metaheuristic <- function(obj.fun, pop.size=30, dim=2, lb, ub, gen=100, pb=0, EE=FALSE, pa=0.1, sigma=0.05, beta=8, temp.init=100, ...){

  patience <- 0

  # Adjust limits
  if (length(lb) == 1) lb <- rep(lb, dim)
  if (length(ub) == 1) ub <- rep(ub, dim)

  # Initialize population
  if(EE == 1 || EE == TRUE){
    pop.ee <-  ExplicitExploration(fun=obj.fun, lower=lb, upper=ub, n=pop.size, maxiter=gen, ...)
    P0 <- pop.ee$par
    n.ee <- pop.ee$n_gen
    gen <- gen-n.ee
  }else{
    P0 <- mapply(runif, lb, ub, MoreArgs=list(n=pop.size))
  }

  X <- P0
  if(!is.matrix(X)) X <- matrix(X, nrow=pop.size)

  # Evaluate initial fitness
  fitness <- apply(X, 1, obj.fun, ...)

  # Find best initial solution
  best_idx <- which.min(fitness)
  best.sol <- X[best_idx, ]
  best.fit <- fitness[best_idx]

  # Initialize variables
  history <- c()
  bfit_prev <- best.fit

  # Lévy Flight parameters
  beta_levy <- 1.5
  sigma_u <- (gamma(1 + beta_levy) * sin(pi * beta_levy / 2) / (gamma((1 + beta_levy) / 2) * beta_levy * 2^((beta_levy - 1) / 2)))^(1 / beta_levy)

  # Loop
  for (t in 1:gen) {

    history <- c(history, best.fit)

    # Calculate decreasing environmental temperature
    Temp <- temp.init * (1 - t / gen)

    # Calculate selection probability based on heat (roulette)
    fit_max <- max(fitness)
    fit_min <- min(fitness)

    if (fit_max == fit_min) {
      probs <- rep(1/pop.size, pop.size)
    } else {
      # Higher heat = higher probability of attracting others (lower fitness is better)
      weights <- (fit_max - fitness) / (fit_max - fit_min + 1e-8)
      probs <- weights / sum(weights)
    }

    X_new <- X
    fitness_new <- fitness

    # Two-phase movement
    for (i in 1:pop.size) {

      # Phase 1: Foraging / Dispersion (Lévy Flight)
      u <- rnorm(dim, 0, sigma_u)
      v <- rnorm(dim, 0, 1)
      step_levy <- u / (abs(v)^(1 / beta_levy))

      X_foraging <- X[i, ] + sigma * step_levy
      X_foraging <- pmax(pmin(X_foraging, ub), lb)
      fit_foraging <- obj.fun(X_foraging, ...)

      # Greedy update for phase 1
      if (fit_foraging < fitness_new[i]) {
        X_new[i, ] <- X_foraging
        fitness_new[i] <- fit_foraging
      }

      # Phase 2: Hibernation / Aggregation
      # Select partner j (attracted by global heat)
      j <- sample(1:pop.size, 1, prob = probs)

      # Select partner k (with heat similar to j)
      diffs <- abs(fitness - fitness[j])
      diffs[c(i, j)] <- Inf # Ignore the current ladybug and j
      k <- which.min(diffs)

      r1 <- runif(dim)
      r2 <- runif(dim)

      X_hibernation <- X_new[i, ] + r1 * (X[j, ] - X_new[i, ]) + r2 * (X[k, ] - X_new[i, ])
      X_hibernation <- pmax(pmin(X_hibernation, ub), lb)
      fit_hibernation <- obj.fun(X_hibernation, ...)

      # Greedy update for phase 2
      if (fit_hibernation < fitness_new[i]) {
        X_new[i, ] <- X_hibernation
        fitness_new[i] <- fit_hibernation
      }
    }

    # Apply movements to the whole population
    X <- X_new
    fitness <- fitness_new

    # Update the global best solution
    best_idx <- which.min(fitness)

    if (fitness[best_idx] < best.fit) {
      best.sol <- X[best_idx, ]
      best.fit <- fitness[best_idx]
    }

    # Auxiliary stopping criterion (patience limit)
    if (pb > 0) {
      if (t > 1) {
        if (abs(best.fit - bfit_prev) < 1e-6) {
          patience <- patience + 1
        } else {
          patience <- 0
        }
        if (patience >= pb) {
          break
        }
      }
    }

    bfit_prev <- best.fit

    # Phase 3: Freezing Death (Probability Formula)
    if (pop.size > 4) {
      survive <- rep(TRUE, pop.size)

      for (i in 1:pop.size) {
        # Ladybugs in the best position do not die
        if (abs(fitness[i] - best.fit) > 1e-8) {
          # Temperature-dependent survival equation
          diff_fit <- abs(fitness[i] - best.fit)
          P_surv <- exp(-beta * (diff_fit / (Temp + 1e-5)))

          if (runif(1) > P_surv) {
            survive[i] <- FALSE
          }
        }
      }

      # Limit death
      num_deaths <- sum(!survive)
      max_kill <- floor(pop.size * pa)

      if (num_deaths > max_kill) {
        # If the temperature killed too many, we save the least worst
        dead_indices <- which(!survive)
        # Sort the "dead" by fitness to save the best ones
        ord <- order(fitness[dead_indices], decreasing = TRUE)
        real_deaths <- dead_indices[ord[1:max_kill]]

        survive <- rep(TRUE, pop.size)
        survive[real_deaths] <- FALSE
      }

      # Permanently remove frozen ladybugs
      if (sum(survive) >= 4 && any(!survive)) {
        X <- X[survive, , drop = FALSE]
        fitness <- fitness[survive]
        pop.size <- nrow(X)
      }
    }
  }

  # Return results
  return(list(best.fit = best.fit, best.sol = best.sol))
}
