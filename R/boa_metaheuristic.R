# Butterfly Optimization Algorithm (BOA)

#---------------------------------------
#           FUNCIÓN OBJETIVO
#---------------------------------------
obj.fun <- function(x){
  y <- sum(x^2)
  return (y)
}

#---------------------------------------
#     FUNCIÓN DEL ALGORITMO (BOA)
#---------------------------------------
boa_metaheuristic <- function(obj.fun, pop.size=30, dim=5, lb=-5.12, ub=5.12, gen=100, pb=0, EE=FALSE, p=0.8, a=0.1, c=0.01, ...){

  patience <- 0

  if(EE==TRUE){
    pop.ee <-  ExplicitExploration(fun=obj.fun, lower=lb, upper=ub, n=pop.size, maxiter=gen, ...)
    P0 <- pop.ee$par
    n.ee <- pop.ee$n.gen
    gen <- gen-n.ee
  }else{
    P0 <- mapply(runif, lb, ub, MoreArgs=list(n=pop.size))
  }

  fitness <- apply(P0, 1, obj.fun, ...)

  # Identificando la mejor mariposa (inicial)
  bf <- which.min(fitness)
  g.best <- P0[bf, ]
  g.best.fit <- fitness[bf]

  for(i in 1:gen){
    I <- 1/fitness
    P1 <- P0

    for(j in 1:pop.size){
      fragance <- c*(I[j]^a) # Calculo de la fragancia de la mariposa j

      r <- runif(1)
      # Para la mejor mariposa actual (Exploracón)
      if(r<p){
        r2 <- runif(1)
        P1[j, ] <- P0[j, ]+(r2^2*g.best-P0[j, ])*fragance
      } else{
        indices <- sample(1:pop.size, 2, replace=FALSE)
        k <- indices[1]
        l <- indices[2]

        r2 <- runif(1)
        P1[j, ] <- P0[j, ]+(r2^2*P0[k, ]-P0[l, ])*fragance
      }

      # Para asegurar que las mariposas no salgan del espacio de búsqueda
      P1[j, ] <- pmax(pmin(P1[j, ], 5.12), -5.12)
    }
    P0 <- P1
    fitness <- apply(P0, 1, obj.fun)

    # Actualización del mejor global
    current.bf <- which.min(fitness)

    ant.bf <- current.bf

    if(fitness[current.bf]<g.best.fit){
      g.best.fit <- fitness[current.bf]
      g.best <- P0[current.bf, ]
    }

    # Para actualización de la modalidadad sensorial segun el estándar
    c <- c+0.025/(c*gen)

    if (i > 1){
      if (abs(current.bf - ant.bf) < 1e-100){
        patience <- patience+1
      } else {
        patience <- 0
      }
      if (patience >= pb){
        cat(sprintf("\n[!] Convergencia alcanzada en la generación %d\n", i))
        break
      }
    }

  }
  return(list(best.solution=g.best, best.fitness=g.best.fit))
}

#---------------------------------------
#               PRUEBA
#---------------------------------------
set.seed(260526)
resultado <- boa_metaheuristic(obj.fun, pop.size=30, dim=5, lb=-5.12, ub=5.12, gen=100, pb=30, EE=FALSE, p=0.8, a=0.1, c=0.01)

#---------------------------------------
#               RESULTADOS
#---------------------------------------
cat("Mejor fitness:", resultado$best.fitness, "\n")
cat("Coordenadas del Mejor Individuo:\n")
print(resultado$best.solution)
