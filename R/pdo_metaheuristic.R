# =========================================================== #
#  Algoritmo de Optimización del Perrito de la Pradera (PDO)  #
# =========================================================== #

pdo_metaheuristic <- function(obj.fun, pop.size = 30, dim = 2, lb, ub, gen = 100, pb = 0, EE = FALSE) {
  
  # Contador de paciencia para criterio de paro secundario
  patience <- 0
  
  lb <- rep(lb, dim)
  ub <- rep(ub, dim)
  
  # 1. Inicialización
  if (EE == TRUE) {
    # Exploración Explícita EEEA: 
    print("Exploracion Explicita con EEEA")
  } else {
    # Crear población inicial aleatoria
    pop <- matrix(runif(pop.size * dim, min = lb, max = ub), 
                  nrow = pop.size, ncol = dim, byrow = TRUE)
  }
  
  # Evaluar aptitud (fitness) inicial
  fitness <- apply(pop, 1, obj.fun)
  
  # Encontrar el mejor perrito (líder)
  best_idx <- which.min(fitness)
  best_pos <- pop[best_idx, ]
  best_fit <- fitness[best_idx]
  
  # 2. Ciclo de Optimización
  for (t in 1:gen) {
    
    # Parámetro dinámico de comunicación (Efecto de sonido/alerta)
    # Disminuye linealmente para balancear exploración y explotación
    DS <- 2 * exp(-(4 * t / gen)^2)
    
    for (i in 1:pop.size) {
      r1 <- runif(1)
      
      if (r1 < 0.5) {
        # --- Fase de Exploración: Comunicación y Vigilancia ---
        # Exploración Estándar PDO (Hacia el líder)
        # Los perritos se mueven basados en el líder y la comunicación del grupo
        pop[i, ] <- best_pos - (pop[i, ] * DS) * runif(dim)
      } else {
        # --- Fase de Explotación: Forrajeo y Construcción ---
        # Movimiento aleatorio local cerca de las mejores zonas de comida
        r2 <- runif(1)
        if (r2 < 0.5) {
          # Forrajeo intensivo
          pop[i, ] <- best_pos + (pop[i, ] - best_pos) * runif(dim)
        } else {
          # Construcción/Refinamiento de madriguera
          random_peer <- sample(1:pop.size, 1)
          pop[i, ] <- pop[i, ] + runif(dim) * (pop[random_peer, ] - pop[i, ])
        }
      }
      
      # Control de límites (Boundary check)
      pop[i, ] <- pmax(pmin(pop[i, ], ub), lb)
      
      # Evaluar nueva posición
      new_fitness <- obj.fun(pop[i, ])
      
      # Actualizar si la nueva posición es mejor
      if (new_fitness < fitness[i]) {
        fitness[i] <- new_fitness
        if (new_fitness < best_fit) {
          best_fit <- new_fitness
          best_pos <- pop[i, ]
        }
      }
    }
    
    # Criterio de paro auxiliar (si en 20 generaciones no hay mejoría mayor al 1e-6, se detiene el ciclo)
    if (pb > 0) {
      if (gen > 1){
        if (abs(best_fit - bfit_prev) < 1e-6){
          patience <- patience + 1
        } else {
          patience <- 0
        }
        if (patience >= pb){
          cat(sprintf("\n[!] Convergencia alcanzada en la generación %d\n", gen))
          break
        }
      }
      
      # Actualizar el valor del mejor fitness anterior
      bfit_prev <- best_fit
    }
  }
  
  return(list(best.fit = best_fit, best.sol = best_pos))
}

# -------------------------------------------------------------------------
# Ejemplo de uso: Función de Sphere (Mínimo global en 0)
# -------------------------------------------------------------------------
res_normal <- pdo_metaheuristic(
  obj.fun = funcion,
  dim = 10, 
  lb = -10, 
  ub = 10, 
  pop.size = 30, 
  gen = 50, 
  EE = FALSE
)

res_ackley <- pdo_metaheuristic(ackley, pop.size=50, dim=2, lb=-32.768, ub=32.768)
res_rosenbrock <- pdo_metaheuristic(rosenbrock, pop.size=50, dim=2, lb=-30, ub=30)
res_sphere <- pdo_metaheuristic(sphere, pop.size=50, dim=2, lb=-100, ub=100)
res_schwefel <- pdo_metaheuristic(schwefel_1.2, pop.size=50, dim=2, lb=-100, ub=100)
res_trid <- pdo_metaheuristic(trid, pop.size=50, dim=2, lb=-(10)^2, ub=(10)^2)
res_griewank <- pdo_metaheuristic(griewank, pop.size=50, dim=2, lb=-600, ub=600)
res_himmelblau <- pdo_metaheuristic(himmelblau, pop.size=50, dim=2, lb=-5, ub=5)

print("Mejor solución encontrada:")
print(res_normal$best.sol)
cat("Valor de la función:", res_normal$best.fit, "\n")

# Graficar convergencia
plot(res_normal$best.sol, type = "l", col = "blue", lwd = 2,
     main = "Convergencia de PDO", xlab = "Iteración", ylab = "Mejor Fitness")

# Con Exploracion Explicita
res_explicita <- pdo_optimizer(
  obj.fun = funcion, 
  pop.size = 20, 
  dim = 10, 
  lb = -10, 
  ub = 10, 
  gen = 50, 
  EE = TRUE
)
cat("Mejor solución encontrada:", res_explicita$best.sol, "\n")
cat("Valor de la función:", res_explicita$best.fit, "\n")
