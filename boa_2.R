# ==============================================================================
# 1. FUNCIÓN OBJETIVO: Función Esfera (Minimización)
# ==============================================================================
sphere_function <- function(x) {
  return(sum(x^2))
}

# ==============================================================================
# 2. ALGORITMO DE OPTIMIZACIÓN DE MARIPOSAS (BOA)
# ==============================================================================
butterfly_optimization_algorithm <- function(obj_func, dim, bounds, n = 30, max_iter = 100, p = 0.8, a = 0.1, c = 0.01) {
  
  lower <- bounds$lower
  upper <- bounds$upper
  
  # Inicializar la población de mariposas de forma aleatoria
  X <- matrix(runif(n * dim, min = lower, max = upper), nrow = n, ncol = dim)
  
  # Evaluar la aptitud (fitness) inicial
  fitness <- apply(X, 1, obj_func)
  
  # Identificar la mejor mariposa inicial (Mejor Global)
  best_idx <- which.min(fitness)
  g_best <- X[best_idx, ]
  g_best_fit <- fitness[best_idx]
  
  # Vector para registrar el historial de convergencia
  convergence_curve <- numeric(max_iter)
  
  # Bucle de optimización
  for (t in 1:max_iter) {
    
    # En problemas de minimización, una menor aptitud implica mayor intensidad de estímulo.
    # Transformamos el fitness para que valores cercanos a 0 tengan la mayor intensidad (I).
    I <- 1 / (fitness + 1e-10) 
    
    X_new <- X  # Matriz temporal para las nuevas posiciones
    
    for (i in 1:n) {
      # Calcular la fragancia de la mariposa i
      fragrance <- c * (I[i]^a)
      
      r <- runif(1)
      if (r < p) {
        # Fase de Búsqueda Global (Hacia la mejor mariposa actual)
        r2 <- runif(1)
        X_new[i, ] <- X[i, ] + (r2^2 * g_best - X[i, ]) * fragrance
      } else {
        # Fase de Búsqueda Local (Movimiento aleatorio con otras dos mariposas)
        indices <- sample(1:n, 2, replace = FALSE)
        j <- indices[1]
        k <- indices[2]
        
        r2 <- runif(1)
        X_new[i, ] <- X[i, ] + (r2^2 * X[j, ] - X[k, ]) * fragrance
      }
      
      # Control de límites: Asegurar que las mariposas no salgan del espacio de búsqueda
      X_new[i, ] <- pmax(pmin(X_new[i, ], upper), lower)
    }
    
    # Actualizar la población y evaluar el nuevo fitness
    X <- X_new
    fitness <- apply(X, 1, obj_func)
    
    # Actualizar el Mejor Global si se encuentra una solución superior
    current_best_idx <- which.min(fitness)
    if (fitness[current_best_idx] < g_best_fit) {
      g_best_fit <- fitness[current_best_idx]
      g_best <- X[current_best_idx, ]
    }
    
    # Actualizar la modalidad sensorial 'c' según el estándar del BOA
    c <- c + 0.025 / (c * max_iter)
    
    # Guardar el mejor resultado de esta iteración
    convergence_curve[t] <- g_best_fit
  }
  
  # Retornar los resultados en una lista
  return(list(
    best_solution = g_best,
    best_fitness = g_best_fit,
    convergence = convergence_curve
  ))
}

# ==============================================================================
# 3. PRUEBA Y CONFIGURACIÓN DEL EXPERIMENTO
# ==============================================================================

# Parámetros del problema
dimensiones <- 5
limites <- list(lower = -5.12, upper = 5.12)  # Límites clásicos de la función Esfera

# Ejecución del algoritmo
set.seed(42) # Fijar semilla para reproducibilidad
resultado <- butterfly_optimization_algorithm(
  obj_func = sphere_function,
  dim = dimensiones,
  bounds = limites,
  n = 40,          # Tamaño de la población
  max_iter = 150,  # Iteraciones máximas
  p = 0.8,         # Probabilidad de cambio (Global vs Local)
  a = 0.1,         # Exponente de potencia
  c = 0.01         # Modalidad sensorial inicial
)

# ==============================================================================
# 4. DESPLIEGUE DE RESULTADOS
# ==============================================================================
cat("--- Resultados de la Optimización ---\n")
cat("Mejor Fitness encontrado:", resultado$best_fitness, "\n")
cat("Mejor solución (Coordenadas):\n")
print(resultado$best_solution)

