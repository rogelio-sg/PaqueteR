\name{fwa_metaheuristic}

\alias{fwa_metaheuristic}

\title{Fireworks Algorithm for Optimization (FWA)}

\description{Provides an implementation of the Fireworks Algorithm (FWA) for
             optimization problems.}

\details{The Fireworks Algorithm is a swarm intelligence metaheuristic inspired
         by the explosion process of fireworks in the night sky. The algorithm
         maintains a population of "fireworks" (candidate solutions) that
         explode to generate "sparks" (new search agents) across the feasible
         search space.}

\usage{
  fwa_metaheuristic(
    obj.fun,
    pop.size=30,
    dim=2,
    lb,
    ub,
    gen=100,
    pb=0,
    EE=FALSE,
    ...)
}

\arguments{
  \item{obj.fun}{
    A function to be minimized, with first argument the vector of parameters
    over which minimization is to take place.
  }
  \item{pop.size}{
    An integer specifying the population size (number of initial fireworks).
  }
  \item{dim}{
    An integer indicating the dimensionality of the search space.
  }
  \item{lb}{
    A numeric vector defining the lower bounds of the search space.
  }
  \item{ub}{
    A numeric vector defining the upper bounds of the search space.
  }
  \item{gen}{
    An integer specifying the maximum number of generations (iterations).
  }
  \item{pb}{
    An integer specifying the patience limit for early stopping
    (the number of consecutive generations without improvement
    before the algorithm terminates).
  }
  \item{EE}{
    A logical value indicating whether to enable explicit exploration
    mechanisms during population initialization process.
  }
  \item{...}{
    Additional arguments of the objective function.
    }
}

\value{
  Returns a list with the following entries:
  \item{\code{best.fit}}{A numeric value representing the best fitness
              value found by the algorithm.}
  \item{\code{best.sol}}{A numeric vector representing the best individual
              (solution) found that achieved the \code{best.fit} value.}
}

\examples{
  obj.fun <- function (x){
  y <- sum(x^2)
  return (y)
  }
  pop.size <- 30
  dim <- 2
  lb <- -5.12
  ub <- 5.12
  gen <- 100
  pb <- 20
  EE <- TRUE

  res.sphere <- fwa_metaheuristic(obj.fun, pop.size, dim, lb, ub, gen, pb, EE)

  cat("Best value on Sphere: ", paste(round(res.sphere$best.fit, 4),
      collapse=", "), "\n")
  cat("Best solution en Sphere: ", paste(round(res.sphere$best.sol, 4),
      collapse=", "), "\n")
}

\references{
  Tan, Y., & Zhu, Y. (2010). Fireworks Algorithm for Optimization.
  In \emph{Advances in Swarm Intelligence} (ICSI 2010). Lecture Notes in
  Computer Science, vol 6145, pp. 355-364. Springer, Berlin, Heidelberg.
  \doi{10.1007/978-3-642-13495-1_44}
}
