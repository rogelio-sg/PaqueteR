# -----------------------------------------
#     FUNCIÓN DEL ALGORITMO (LBO)
# -----------------------------------------
lbo_metaheuristic <- function(obj.fun, pop.size=30, dim=2, lb, ub, gen=100, pb=0, EE=FALSE, pa=0.1, sigma=0.05, beta=8, temp.init=100){
  
  # Ajustar límites 
  if (length(lb) == 1) lb <- rep(lb, dim)
  if (length(ub) == 1) ub <- rep(ub, dim)
  
  # Inicializar población
  if (EE == 1 || EE == TRUE) {
    if (!requireNamespace("EEEA", quietly = TRUE)) {
      message("La librería 'EEEA' no está instalada. Instalando...")
      install.packages("EEEA", dependencies = TRUE)
    }
    library(EEEA)
    # Guardar los mejores individuos
    res_eeea <- ExplicitExploration(fun = obj.fun, lower = lb, upper = ub, n = pop.size, maxiter = gen)
    X <- res_eeea$par
    
  } else {
    # Inicializar población aleatoria 
    X <- matrix(runif(pop.size * dim), nrow = pop.size)
    X <- t(apply(X, 1, function(x) lb + (ub - lb) * x))
  }
  
  # Evaluar fitness inicial
  fitness <- apply(X, 1, obj.fun)
  
  # Encontrar mejor solución inicial 
  best_idx <- which.min(fitness)
  best.sol <- X[best_idx, ]  
  best.fit <- fitness[best_idx] 
  
  # Inicializar variables
  history <- c()
  patience <- 0
  bfit_prev <- best.fit
  
  # Parámetros para el Vuelo de Lévy
  beta_levy <- 1.5
  sigma_u <- (gamma(1 + beta_levy) * sin(pi * beta_levy / 2) / (gamma((1 + beta_levy) / 2) * beta_levy * 2^((beta_levy - 1) / 2)))^(1 / beta_levy)
  
  # Bucle
  for (t in 1:gen) { 
    
    history <- c(history, best.fit)
    
    # Calcular la temperatura ambiental decreciente
    Temp <- temp.init * (1 - t / gen)
    
    # Calcular probabilidad de selección basada en el calor (ruleta)
    fit_max <- max(fitness)
    fit_min <- min(fitness)
    
    if (fit_max == fit_min) {
      probs <- rep(1/pop.size, pop.size)
    } else {
      # Mayor calor = mayor probabilidad de atraer a otros (menor fitness es mejor)
      weights <- (fit_max - fitness) / (fit_max - fit_min + 1e-8)
      probs <- weights / sum(weights)
    }
    
    X_new <- X
    fitness_new <- fitness
    
    # Movimiento en dos fases 
    for (i in 1:pop.size) {
      
      # Fase 1: Alimentación / Dispersión (Vuelo de Lévy)
      u <- rnorm(dim, 0, sigma_u)
      v <- rnorm(dim, 0, 1)
      step_levy <- u / (abs(v)^(1 / beta_levy))
      
      X_foraging <- X[i, ] + sigma * step_levy
      X_foraging <- pmax(pmin(X_foraging, ub), lb)
      fit_foraging <- obj.fun(X_foraging)
      
      # Actualización greedy para fase 1 
      if (fit_foraging < fitness_new[i]) {
        X_new[i, ] <- X_foraging
        fitness_new[i] <- fit_foraging
      }
      
      # Fase 2: Hibernación / Agregación 
      # Seleccionar compañera j (atraída por el calor global)
      j <- sample(1:pop.size, 1, prob = probs)
      
      # Seleccionar compañera k (con calor similar a j)
      diffs <- abs(fitness - fitness[j])
      diffs[c(i, j)] <- Inf # Ignorar a la mariquita actual y a j
      k <- which.min(diffs)
      
      r1 <- runif(dim)
      r2 <- runif(dim)
      
      X_hibernation <- X_new[i, ] + r1 * (X[j, ] - X_new[i, ]) + r2 * (X[k, ] - X_new[i, ])
      X_hibernation <- pmax(pmin(X_hibernation, ub), lb)
      fit_hibernation <- obj.fun(X_hibernation)
      
      # Actualización greedy para fase 2 
      if (fit_hibernation < fitness_new[i]) {
        X_new[i, ] <- X_hibernation
        fitness_new[i] <- fit_hibernation
      }
    }
    
    # Aplicar los movimientos de toda la población
    X <- X_new
    fitness <- fitness_new
    
    # Actualizar la mejor solución global
    best_idx <- which.min(fitness)
    
    if (fitness[best_idx] < best.fit) {
      best.sol <- X[best_idx, ]
      best.fit <- fitness[best_idx]
    }
    
    # Criterio de paro auxiliar (límite de paciencia)
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
    
    # Fase 3: Muerte por Congelamiento (Fórmula de Probabilidad) 
    if (pop.size > 4) {
      survive <- rep(TRUE, pop.size)
      
      for (i in 1:pop.size) {
        # Mariquitas en la mejor posición no mueren
        if (abs(fitness[i] - best.fit) > 1e-8) { 
          # Ecuación de supervivencia dependiente de temperatura
          diff_fit <- abs(fitness[i] - best.fit)
          P_surv <- exp(-beta * (diff_fit / (Temp + 1e-5))) 
          
          if (runif(1) > P_surv) {
            survive[i] <- FALSE
          }
        }
      }
      
      # Limitar la muerte para no aniquilar demasiado rápido
      num_deaths <- sum(!survive)
      max_kill <- floor(pop.size * pa)
      
      if (num_deaths > max_kill) {
        # Si la temperatura mató a demasiadas, salvamos a las menos peores
        dead_indices <- which(!survive)
        # Ordenamos a las "muertas" por fitness para salvar a las mejores 
        ord <- order(fitness[dead_indices], decreasing = TRUE)
        real_deaths <- dead_indices[ord[1:max_kill]]
        
        survive <- rep(TRUE, pop.size)
        survive[real_deaths] <- FALSE
      }
      
      # Eliminar definitivamente a las mariquitas congeladas (mínimo poblacional = 4)
      if (sum(survive) >= 4 && any(!survive)) {
        X <- X[survive, , drop = FALSE]
        fitness <- fitness[survive]
        pop.size <- nrow(X)
      }
    }
  }
  
  # Retornar resultados
  return(list(best.fit = best.fit, best.sol = best.sol))
}

#---------------------------------------
#           FUNCIONES OBJETIVO
#---------------------------------------
sphere <- function(x) {
  sum(x^2)
}

rosenbrock <- function(x) {
  sum(100 * (x[2:length(x)] - x[1:(length(x)-1)]^2)^2 +
        (x[1:(length(x)-1)] - 1)^2)
}

rastrigin <- function(x) {
  n <- length(x)
  10*n + sum(x^2 - 10*cos(2*pi*x))
}

ackley <- function(x) {
  n <- length(x)
  -20 * exp(-0.2 * sqrt(sum(x^2)/n)) -
    exp(sum(cos(2*pi*x))/n) + 20 + exp(1)
}

griewank <- function(x) {
  sum_term <- sum(x^2) / 4000
  prod_term <- prod(cos(x / sqrt(1:length(x))))
  sum_term - prod_term + 1
}

schwefel <- function(x) {
  418.9829 * length(x) - sum(x * sin(sqrt(abs(x))))
}

himmelblau <- function(x) {
  (x[1]^2 + x[2] - 11)^2 + (x[1] + x[2]^2 - 7)^2
}

beale <- function(x) {
  (1.5 - x[1] + x[1]*x[2])^2 +
    (2.25 - x[1] + x[1]*x[2]^2)^2 +
    (2.625
     
     - x[1] + x[1]*x[2]^3)^2
}

#---------------------------------------
# PRUEBAS CON EE
#---------------------------------------
res1 <- lbo_metaheuristic(sphere, 30, 2, -5.12, 5.12, 100, 20, EE = TRUE)
cat("Sphere Best Fit:", res1$best.fit, " | Best Sol:", res1$best.sol, "\n")
res2 <- lbo_metaheuristic(himmelblau, 40, 2, -5, 5, 150, 0, EE = TRUE)
cat("Himmelblau Best Fit:", res2$best.fit , " | Best Sol:", res2$best.sol, "\n")
#---------------------------------------
# PRUEBAS SIN EE
#---------------------------------------
res1 <- lbo_metaheuristic(sphere, 30, 2, -5.12, 5.12, 100, 20)
cat("Sphere Best Fit:", res1$best.fit, " | Best Sol:", res1$best.sol, "\n")
cat("Rosenbrock Best Fit:", res5$best.fit, " | Best Sol:", res5$best.sol, "\n")
res_schwefel_ok <- lbo_metaheuristic(schwefel, 50, 3, -500, 500, 150, 0, FALSE, 0.1, 0.5)
cat("Schwefel Best Fit:", res_schwefel_ok$best.fit, " | Best Sol:", res_schwefel_ok$best.sol, "\n")
