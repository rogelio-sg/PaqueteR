\name{pdo_metaheuristic}

\alias{pdo_metaheuristic}

\title{Prairie Dog Optimization Algorithm (PDO)}

\description{Provides an implementation of the Prairie Dog Optimization (PDO) algorithm for
             optimization problems.}

\details{The Prairie Dog Optimization algorithm is a swarm intelligence metaheuristic inspired
         by the biological behaviors of prairie dogs. The algorithm simulates four distinct
         time-based phases: foraging/exploration using Lévy flights, burrow construction/exploitation
         via cooperative digging, food alarm communication using vocal alerts, and randomized flight
         for predator escape to explore and exploit the feasible search space.}

\usage{
  pdo_metaheuristic(
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
    An integer specifying the population size (number of prairie dogs).
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

  res.sphere <- pdo_metaheuristic(obj.fun, pop.size, dim, lb, ub, gen, pb, EE)

  cat("Best value on Sphere: ", paste(round(res.sphere$best.fit, 4),
      collapse=", "), "\n")
  cat("Best solution en Sphere: ", paste(round(res.sphere$best.sol, 4),
      collapse=", "), "\n")
}

\references{
  Ezugwu, A. E., Agushaka, J. O., Abualigah, L., Mirjalili, S., & Gandomi, A. H. (2022).
  Prairie Dog Optimization Algorithm. \emph{Neural Computing and Applications}, vol 34,
  no. 22, pp. 20017-20065. Springer, London. \doi{10.1007/s00521-022-07530-9}

  Abualigah, L. (2022). Prairie Dog Optimization Algorithm, \emph{MATLAB Central File Exchange}.
  Retrieved June 2026. URL: https://www.mathworks.com/matlabcentral/fileexchange/110980-prairie-dog-optimization-algorithm
}
