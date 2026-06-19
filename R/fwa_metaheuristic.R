# ================================
# FireWorks Algorithm Optimization
#=================================
fwa.metaheuristic <- function(obj.fun, pop.size=30, dim=2, lb, ub, gen=100, pb=0, EE=FALSE, ...){

  # Patience counter for secondary stopping criterion
  patience <- 0
  # Best fitness and global solution
  global.best.fit <- Inf
  global.best.sol <- rep(NA, dim)

  # Adjust limits to the number of dimensions
  if (length(lb) == 1 ) lb <- rep(lb, dim)
  if (length(ub) == 1 ) ub <- rep(ub, dim)

  # -------------------------
  # Create initial population
  # -------------------------

  # Initial population using Explicit Exploration
  if (EE == TRUE || EE == 1){
    # We store the best individuals returned in $par
    res_eeea <- ExplicitExploration(fun=obj.fun, lower=lb, upper=ub, n=pop.size, maxiter=gen, ...)
    P0 <- res_eeea$par
    gen = gen - res_eeea$n_gen
  }
  # Initial population using randomness
  else{
    P0 <- mapply(runif, lb, ub, MoreArgs = list(n = pop.size))
  }

  for (g in 1:gen){

    # ----------------------------------------------------
    # Evaluate the population using the objective function
    # ----------------------------------------------------

    fitness <- apply(P0, 1, obj.fun, ...)
    fmax <- max(fitness) # Worst result
    fmin <- min(fitness) # Best result
    indice <- which.min(fitness)
    best_sol <- P0[indice, ]

    # -----------------------------------
    # Calculation of the number of sparks
    # -----------------------------------

    m <- 50 # Total number of sparks allowed in each generation
    e <- 1e-40 # Small number to avoid division by zero
    a <- 0.04 # Minimum percentage of sparks per solution
    b <- 0.8 # Maximum percentage of sparks per solution
    s <- m*((fmax - fitness + e) / (sum(fmax - fitness) + e))
    # Limits on the number of sparks
    up_b <- round(m*b)
    if (pop.size >= m){
      low_b <- 0
    } else{
      low_b <- max(1, round(m*a))
    }
    s <- pmax(low_b, pmin(round(s), up_b))

    # --------------------------------------
    # Calculation of the explosion amplitude
    # --------------------------------------

    A.hat <- (ub - lb) * 0.05 # Maximum allowed amplitude
    A <- A.hat*((fitness - fmin + e) / ((fmax - fmin) + e))
    A <- pmax(A, A.hat*0.01)

    # ----------------------------
    # Explosion (spark generation)
    # ----------------------------

    sparks <- list()
    cont <- 1
    for (i in 1:pop.size){
      if (s[i] == 0) next
      fw_actual <- P0[i,]
      clon <- matrix(fw_actual, nrow=s[i], ncol=dim, byrow=TRUE)
      noise <- matrix(runif(s[i]*dim, A[i]*-1, A[i]*1), nrow=s[i], ncol=dim)
      spark_actual <- clon + noise
      # Relocate the spark if it goes outside the search space
      spark_actual <- pmax(pmin(spark_actual, ub), lb)
      sparks[[cont]] <- spark_actual
      cont <- cont + 1
    }

    # -----------------
    # Selection process
    # -----------------

    # Stack the list of matrices into a single matrix
    matriz_sparks <- do.call(rbind, sparks)

    # Gaussian mutation
    m_hat <- 5 # Fixed number of Gaussian sparks per generation
    sparks_gauss <- list()

    for (k in 1:m_hat){
      # Select a random firework from the original population
      idx <- sample(1:pop.size, 1)
      fw_base <- P0[idx, ]

      # Generate Gaussian multiplier e ~ N(1, 1) fot the 'dim' dimensions
      e <- rnorm(dim, mean = 1, sd = 1)

      # Mutation mask: Mutate random dimensions (50% probability)
      mask <- sample(c(TRUE, FALSE), size = dim, replace = TRUE)

      # Multiply the base position by the Gaussian noise
      spark_g <- fw_base
      spark_g[mask] <- spark_g[mask] * e[mask]

      # Clamping (Relocate if it goes outside the lb/ub bounds)
      spark_g <- pmax(pmin(spark_g, ub), lb)

      sparks_gauss[[k]] <- spark_g
    }

    # Stack the Gaussian sparks into a matrix
    matriz_gauss <- do.call(rbind, sparks_gauss)

    # Merge the initial population with the generated sparks
    P_total <- rbind(P0, matriz_sparks, matriz_gauss)

    # Evaluate the entire population
    fitness_total <- apply(P_total, 1, obj.fun, ...)

    # Hybrid selection (exploration and exploitation)
    order_index <- order(fitness_total)
    percentage <- 0.05 + ((0.50-0.05)*(g/gen))
    n_elite <- max(1, round(pop.size*percentage))
    # Best solutions (20% of the population size) to guarantee exploitation
    i_elite <- order_index[1:n_elite]
    i_left <- order_index[(n_elite + 1): length(order_index)]
    # Random solutions (80% of the population size) to guarantee exploration
    i_random <- sample(i_left, pop.size-n_elite)

    # Merge the best and random solutions to generate a new population
    P1 <- P_total[c(i_elite, i_random), ]

    # Update the initial population
    P0 <- P1

    # Find the best value and the best global solution
    best.index <- which.min(fitness_total)
    current.best.fit <- fitness_total[best.index]
    if (current.best.fit < global.best.fit){
      global.best.fit <- current.best.fit
      global.best.sol <- P_total[best.index, ]
    }

    # ----------------------------
    # Auxiliary stopping criterion
    # ----------------------------

    # If there is no improvement greater than 1e-6 in pb generations, the cycle stops
    if (pb > 0){
      if (g > 1){
        if (abs(global.best.fit - fmin_ant) < 1e-6){
          patience <- patience + 1
        } else {
          patience <- 0
        }
        if (patience >= pb){
          cat(sprintf("\n[!] Convergence reached at generation %d\n", g))
          break
        }
      }
      # Update the previous best fitness value
      fmin_ant <- global.best.fit
    }
  }

  # -------------
  # Return values
  # -------------

  return(list(best.fit=global.best.fit, best.sol=global.best.sol))
}
