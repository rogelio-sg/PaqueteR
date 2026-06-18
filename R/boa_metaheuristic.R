# Butterfly Optimization Algorithm (BOA)

# -----------------------------------------
#  ALGORITHM FUNCTION ( BOA)
# -----------------------------------------

boa_metaheuristic <- function(obj.fun, pop.size=30, dim=5, lb=-5.12, ub=5.12, gen=100, pb=0, EE=FALSE, p=0.8, a=0.1, c=0.01, ...){

  patience <- 0

  # Adjust limits
  if (length(lb) == 1) lb <- rep(lb, dim)
  if (length(ub) == 1) ub <- rep(ub, dim)

  # For initialize population
  if(EE == TRUE||EE == 1){
    pop.ee <-  ExplicitExploration(fun=obj.fun, lower=lb, upper=ub, n=pop.size, maxiter=gen, ...)
    P0 <- pop.ee$par
    n.ee <- pop.ee$n.gen
    gen <- gen-n.ee
  }else{
    P0 <- mapply(runif, lb, ub, MoreArgs=list(n=pop.size))
  }

  # Evaluate initial fitness
  fitness <- apply(P0, 1, obj.fun, ...)

  # Identify initial best butterfly
  bf <- which.min(fitness)
  g.best <- P0[bf, ]
  g.best.fit <- fitness[bf]

  for(i in 1:gen){

    ant.best.fit <- g.best.fit
    max.fit <- max(fitness)
    min.fit <- min(fitness)

    if(max.fit == min.fit){
      I <- rep(1, pop.size)
    }else{
      I <- (max.fit-fitness)/(max.fit-min.fit+1e-10)
    }

    P1 <- P0

    for(j in 1:pop.size){
      fragance <- c*(I[j]^a) # Calculate fragrance for butterfly j

      r <- runif(1)

      # For current best butterfly (Exploration)
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

      # Ensure butterflies remain within the search space
      P1[j, ] <- pmax(pmin(P1[j, ], ub), lb)
    }

    P0 <- P1
    fitness <- apply(P0, 1, obj.fun, ...)

    # Update global best
    current.bf <- which.min(fitness)

    if(fitness[current.bf]<g.best.fit){
      g.best.fit <- fitness[current.bf]
      g.best <- P0[current.bf, ]
    }

    # For updating the sensory modality according to the standard
    c <- c+0.025/(c*gen)

    if (i > 1){
      if (abs(g.best.bf - ant.best.fit) < 1e-100){
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

  # Results
  return(list(best.solution=g.best, best.fitness=g.best.fit))
}
