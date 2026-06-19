# ========================================== #
#  Prairie Dog Optimization Algorithm (PDO)  #
# ========================================== #

pdo_metaheuristic <- function(obj.fun, pop.size = 30, dim = 2, lb, ub, gen = 100, pb = 0, EE = FALSE, ...) {

  # Counters and preparation for secondary criteria
  patience <- 0     # Counts how many consecutive times there has been no improvement
  bfit_prev <- Inf  # Stores the previous round's result for comparison

  # Adjust dimension boundaries only if the user passed a single numerical value
  if (length(lb) == 1) lb <- rep(lb, dim)
  if (length(ub) == 1) ub <- rep(ub, dim)

  # --- CREATE THE PRAIRIE DOGS (INITIALIZATION) ---
  if(EE == 1 || EE == TRUE){
    # Explicit Exploration Method
    pop_eeea <- ExplicitExploration(fun = obj.fun, lower = lb, upper = ub, n = pop.size, maxiter = gen, ...)
    pop <- pop_eeea$par
    n_ee <- pop_eeea$n_gen
    # Subtract the generations already used
    gen <- gen - n_ee

  } else {
    # Original Method
    pop <- matrix(runif(pop.size * dim), nrow = pop.size, ncol = dim)
    for (j in 1:dim) {
      pop[, j] <- pop[, j] * (ub[j] - lb[j]) + lb[j]
    }
  }

  # Ecosystem variables and initializations
  pop_new <- matrix(0, nrow = pop.size, ncol = dim) # Temporary map for the new population
  rho <- 0.005                    # Small difference factor among individual prairie dogs
  eps_val <- .Machine$double.eps  # A tiny number to prevent the computer from dividing by zero
  epsPD <- 0.1                    # Alert level when they find a nutritious food source

  # Evaluate initial fitness
  # Measure how good the current position of each prairie dog is
  fitness <- apply(pop, 1, obj.fun, ...)

  # Find who found the best location at the beginning (The Clan Leader)
  best_idx <- which.min(fitness)
  best_pos <- pop[best_idx, ]
  best_fit <- fitness[best_idx]

  # Internal auxiliary function for Lévy Flight
  levym <- function(n, m, beta = 1.5) {
    # Internal mathematical calculation to control the scale of the jumps
    num <- gamma(1 + beta) * sin(pi * beta / 2)
    den <- gamma((1 + beta) / 2) * beta * 2^((beta - 1) / 2)
    sigma_u <- (num / den)^(1 / beta)
    # Generate normal random movements
    u <- matrix(rnorm(n * m, mean = 0, sd = sigma_u), nrow = n, ncol = m)
    v <- matrix(rnorm(n * m, mean = 0, sd = 1), nrow = n, ncol = m)
    # Combine movements to create the "long jump" effect
    m <- u / (abs(v)^(1 / beta))
    return(m)
  }

  # --- MAIN OPTIMIZATION LOOP ---
  for (t in 1:gen) {

    # Direction-changing parameter (1 or -1) based on whether the round is even or odd
    mu <- if (t %% 2 == 0) -1 else 1

    # Behavioral equations: calculate digging strength (DS) and predator effect/fear (PE)
    DS <- 1.5 * rnorm(1) * (1 - t / gen)^(2 * t / gen) * mu
    PE <- 1.5 * (1 - t / gen)^(2 * t / gen) * mu

    # Generate the long Lévy flight jumps for this round
    RL <- levym(pop.size, dim, 1.5)

    # Replicated leader matrix (Top Prairie Dog)
    TPD <- matrix(rep(best_pos, each = pop.size), nrow = pop.size, ncol = dim)

    # Dimensional position update
    for (i in 1:pop.size) {
      for (j in 1:dim) {

        # Biological parameters: measure distance to the leader and average group position
        cpd <- runif(1) * (TPD[i, j] - pop[sample(1:pop.size, 1), j]) / (TPD[i, j] + eps_val) # Quality of location
        P <- rho + (pop[i, j] - mean(pop[i, ])) / (TPD[i, j] * (ub[j] - lb[j]) + eps_val)     # Individual variation
        eCB <- best_pos[j] * P                                                                # Burrow effect

        # --- THE BIOLOGICAL CLOCK: FOUR TIME-BASED FASES ---
        if (t < (gen / 4)) {
          # PHASE 1: FORAGING (Exploration)
          # (Prairie dogs get hungry and explore new areas by performing long jumps)
          pop_new[i, j] <- best_pos[j] - eCB * epsPD - cpd * RL[i, j]
        } else if (t < (2 * gen / 4) && t >= (gen / 4)) {
          # PHASE 2: BURROW BUILDING (Exploitation)
          # (They cooperate with each other to dig safe burrows)
          pop_new[i, j] <- best_pos[j] * pop[sample(1:pop.size, 1), j] * DS * RL[i, j]
        } else if (t < (3 * gen / 4) && t >= (2 * gen / 4)) {
          # PHASE 3: FOOD ALARM (Communication)
          # (They alert each other about food locations using vocal communication sounds)
          pop_new[i, j] <- best_pos[j] * PE * runif(1)
        } else {
          # PHASE 4: PREDATOR ESCAPE (Escape)
          # (A threat appears and they run desperately to hide)
          pop_new[i, j] <- best_pos[j] - eCB * eps_val - cpd * runif(1)
        }
      }

      # --- INDIVIDUAL BOUNDARY CONTROL ---
      # Keep coordinates strictly within the lower (lb) and upper (ub) boundaries
      pop_new[i, ] <- pmax(pmin(pop_new[i, ], ub), lb)

      # Evaluate if the new location the prairie dog moved to is better than the previous one
      new_fitness <- obj.fun(pop_new[i, ], ...)

      # --- GREEDY SELECTION (THEY ONLY MOVE IF IT BENEFITS THEM) ---
      # Update if the new position is better
      if (new_fitness < fitness[i]) {
        pop[i, ] <- pop_new[i, ]  # The prairie dog officially relocates to the new spot
        fitness[i] <- new_fitness

        # Update Global Leader
        # If this prairie dog found a better location than the Global Leader, it becomes the new Leader
        if (new_fitness < best_fit) {
          best_fit <- new_fitness
          best_pos <- pop[i, ]
        }
      }
    }

    # --- AUXILIARY STOPPING CRITERION (IN CASE CONVERGENCE STAGNATES) ---
    if (pb > 0) {
      if (t > 1){
        # If the improvement compared to the previous round is almost invisible (less than 1e-6)
        if (abs(best_fit - bfit_prev) < 1e-6){
          patience <- patience + 1  # Increment the patience counter
        } else {
          patience <- 0             # If there was a significant improvement, reset patience
        }
        # If the allowed patience (pb) runs out, stop the algorithm early to save computing time
        if (patience >= pb){
          break
        }
      }
      bfit_prev <- best_fit   # Save this result for the next round
    }
  }

  # --- RETURN OF RESULTS ---
  # Return a list containing the fitness value of the best area found and its exact coordinates
  return(list(best.fit = best_fit, best.sol = best_pos))
}
