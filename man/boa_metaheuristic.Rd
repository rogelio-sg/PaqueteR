\name{boa_metaheuristic}

\alias{boa_metaheuristic}

\title{Butterfly Optimization Algorithm (BOA)}

\description{Provides an implementation of the Butterfly Optimization (BOA) for
             optimization problems.}

\details{The Butterfly Optimization Algorithm is a swarm intelligence metaheuristic inspired
         by the biological foraging and mating behaviors of butterflies. The algorithm
         simulates the fragrance emission and perception to create a social network of
         individuals, utilizing global search toward the current best butterfly (highly
         fragrant stimulus) and local random walks when sensory modality drops, effectively
         balancing exploration and exploitation within the feasible search space.
         }

\usage{
  boa_metaheuristic(
    obj.fun,
    pop.size=30,
    dim=2,
    lb,
    ub,
    gen=100,
    pb=0,
    EE=FALSE,
    p=0.8,
    a=0.1,
    c=0.01,
    ...)
}

\arguments{
 \item{obj.fun}{
    A function to be minimized, with first argument the vector of parameters
    over which minimization is to take place.
  }
  \item{pop.size}{
    An integer specifying the population size (number of ladybugs).
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
  \item{p}{
    A numeric value in [0, 1] representing the switch probability.
  }
  \item{a}{
    A numeric value acting as the power exponent for stimulus intensity.
  }
  \item{c}{
    A numeric value representing the initial sensory modality.
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

  res.sphere <- lbo_metaheuristic(obj.fun, pop.size, dim, lb, ub, gen, pb, EE)

  cat("Best value on Sphere: ", paste(round(res.sphere$best.fit, 4),
      collapse=", "), "\n")
  cat("Best solution en Sphere: ", paste(round(res.sphere$best.sol, 4),
      collapse=", "), "\n")
}

\references{
  Arora, S., & Singh, S. (2019). Butterfly optimization algorithm: A novel
  approach for global optimization. \emph{Soft Computing}, \bold{23}(3), 715–734. \doi{10.1007/s00500-018-3102-4}
  Okwu, M. O., & Tartibu, L. K. (2021). Butterfly Optimization Algorithm.
  In \emph{Metaheuristic Optimization: Nature-Inspired Algorithms Swarm and Computational Intelligence, Theory and Applications} (Studies in Computational Intelligence, Vol. 927, pp. 105–114). Springer Nature Switzerland AG. \doi{10.1007/978-3-030-61111-8_11}
}

