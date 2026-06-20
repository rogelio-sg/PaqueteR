# PaqueteR

[![R Version](https://img.shields.io/badge/R-4.0+-blue.svg)](https://www.r-project.org/)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

---

## Overview

**PaqueteR** is an R package designed for global optimization of continuous functions through bio-inspired and swarm intelligence algorithms. The package consolidates four recent metaheuristics, vectorially optimized to deliver high computational performance in complex and high-dimensional search spaces.

A key advantage of this library is its **native compatibility and integration with the EEEA package** (*Explicit Exploration Strategy for Evolutionary Algorithms*). This allows activating an explicit exploration phase that diversifies the population based on space distribution stability, mitigating premature stagnation in local optima.

---

## Implemented Metaheuristics

The package includes the following four optimization strategies:

* **Butterfly Optimization Algorithm (BOA):** Simulates the biological fragrance and odor perception system in butterflies to dynamically alternate between global and local search phases.
* **Fireworks Algorithm (FWA):** A swarm intelligence method that emulates fireworks explosions, adaptively regulating the number of sparks and the explosion amplitude according to proximity to the optimum.
* **Ladybug Beetle Optimization (LBO):** Models the behavior of ladybugs under thermal changes, incorporating **Lévy Flights** random walks for exploration, heat-based clustering for exploitation, and dynamic freezing selection.
* **Prairie Dog Optimization (PDO):** Emulates the social and communication behaviors of prairie dogs across 4 adaptive phases: foraging with Lévy flights, stochastic burrow building, food alerts, and predator alerts.

---

## Key Features

- **Consolidation of Recent Metaheuristics:** R implementation of swarm algorithms with little to no prior presence in traditional analytical software.
- **Hybridization with EEEA:** Optional parameter integrated into all main functions to activate explicit exploration strategies.
- **Advanced Stochastic Mechanisms:** Incorporation of Lévy Flights to efficiently jump local barriers in multimodal landscapes.
- **Early Stopping Criteria:** Support for the patience parameter (`pb`) which halts execution if the algorithm detects stagnation, optimizing computation times.
- **Automated Quality Suite:** Validation and mathematical integrity backed by unit tests under the `testthat` framework.

---

## Installation

Since the package is under active development in the `dev` branch, you can install it directly in R using `devtools`:

```r
# Make sure you have devtools installed
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Installation of the development version
devtools::install_github("rogelio-sg/PaqueteR", ref = "dev")
```

### Requirements

- R 4.0.0+
- testthat

---

## Implemented Algorithms

### Butterfly Optimization Algorithm (BOA)

Metaheuristic based on the biological behavior of butterflies, which use their sense of smell to determine fragrance intensity and navigate towards potential food sources or mates. It supports standard execution or hybridization with explicit exploration.

```r
library(boa_metaheuristic)

# Standard execution
result_boa <- boa_metaheuristica(
  objective_function = my_function,
  lower              = rep(-5.12, 10),
  upper              = rep(5.12, 10),
  pop_size           = 30,
  max_iter           = 100,
  p                  = 0.8,    # Probability of switching between global and local search
  c                  = 0.01,   # Sensory modality
  a                  = 0.1     # Power exponent based on intensity
)

# With explicit exploration strategy (EEEA) and early stopping
result_boa_ee <- boa_metaheuristic(
  objective_function = my_function,
  lower              = rep(-5.12, 10),
  upper              = rep(5.12, 10),
  pop_size           = 30,
  max_iter           = 100,
  p                  = 0.8, 
  c                  = 0.01, 
  a                  = 0.1,
  EE                 = TRUE,   # Activates explicit exploration
  pb                 = 15      # Early stopping criterion (patience)
)
```

### Fireworks Algorithm (FWA)

Swarm optimization algorithm inspired by fireworks explosions. It dynamically determines the number of sparks and the explosion radius amplitude to balance global search (faraway sparks) and local search (concentrated sparks).

```r
library(fwa_metaheuristic)

# Standard execution
result_fwa <- fwa_metaheuristica(
  objective_function = my_function,
  lower              = rep(-10, 5),
  upper              = rep(10, 5),
  pop_size           = 25,
  max_iter           = 150,
  m1                 = 10,     # Total number of regular sparks generated
  m2                 = 5,      # Number of Gaussian (mutated) sparks
  A_max              = 40      # Maximum allowed amplitude for the explosion
)

# With explicit exploration strategy (EEEA) and early stopping
result_fwa_ee <- fwa_metaheuristica(
  objective_function = my_function,
  lower              = rep(-10, 5),
  upper              = rep(10, 5),
  pop_size           = 25,
  max_iter           = 150,
  m1                 = 10,
  m2                 = 5,
  A_max              = 40,
  EE                 = TRUE,   # Activates explicit exploration
  pb                 = 20      # Early stopping criterion (patience)
)
```

### Ladybug Beetle Optimization (LBO)

Stochastic strategy inspired by the behavior and survival habits of ladybug beetles. It combines broad spatial displacements using Lévy Flights, aggregation processes based on artificial thermal gradients, and selective scattering mechanisms.

```r
library(lbo_metaheuristic)

# Standard execution
result_lbo <- lbo_metaheuristic(
  objective_function = my_function,
  lower              = rep(-5, 10),
  upper              = rep(5, 10),
  pop_size           = 40,
  max_iter           = 200,
  alpha              = 0.5,    # Scaling factor for Lévy steps
  beta               = 1.5     # Stability parameter for Lévy distribution
)

# With explicit exploration strategy (EEEA) and early stopping
result_lbo_ee <- lbo_metaheuristic(
  objective_function = my_function,
  lower              = rep(-5, 10),
  upper              = rep(5, 10),
  pop_size           = 40,
  max_iter           = 200,
  alpha              = 0.5,
  beta               = 1.5,
  EE                 = TRUE,   # Activates explicit exploration
  pb                 = 30      # Early stopping criterion (patience)
)
```

### Prairie Dog Optimization (PDO)

Metaheuristic optimization algorithm based on the gregarious behavior of prairie dogs. It mathematically models four interactive social behavior patterns (burrow building, foraging, food response alerts, and predator avoidance) assisted by heavy random walks.

```r
library(pdo_metaheuristic)

# Standard execution
result_pdo <- pdo(
  objective_function = my_function,
  lower              = rep(-5.12, 10),
  upper              = rep(5.12, 10),
  pop_size           = 35,
  max_iter           = 100
)

# With explicit exploration strategy (EEEA) and early stopping
result_pdo_ee <- pdo(
  objective_function = my_function,
  lower              = rep(-5.12, 10),
  upper              = rep(5.12, 10),
  pop_size           = 35,
  max_iter           = 100,
  EE                 = TRUE,   # Activates explicit exploration
  pb                 = 10      # Early stopping criterion (patience)
)
```

---

## Result Format

All algorithms return a dictionary with the following keys:

| Key | Type | Description |
|-----|------|-------------|
| `best.sol` | `numeric vector` | Multidimensional vector with the best solution or localized optimum.|
| `best.fit` | `numeric` |The fitness value corresponding to the best solution found.|

---

## Project Structure

```r
PaqueteR/
├── R/
│   ├── pdo.R                     # Prairie Dog Optimization metaheuristic
│   ├── boa.R                     # Butterfly Optimization Algorithm metaheuristic
│   ├── lbo.R                     # Ladybug Beetle Optimization metaheuristic
│   ├── fwa.R                     # Fireworks Algorithm metaheuristic
├── man/                          # R documentation files (.Rd) for each algorithm
├── tests/
│   └── testthat/
│       └── test_metaheuristics.R # Validation Tests 
├── DESCRIPTION                   # Package metadata, dependencies, and authors
├── NAMESPACE                     # Control of functions exported to the global environment
├── LICENSE                       # Repository license
└── README.md                     # Repository main documentation
```

---

## License

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.

---

## Support

For bug reports and feature requests, open an issue on [GitHub](
https://github.com/rogelio-sg/PaqueteR/issues).

--- 

## Citation

If you use this software in your research lines or academic publications, please include the following bibliographic citation:

```r
@software{rogelio2026paqueter,
  title  = {PaqueteR: Recent Metaheuristics and Explicit Exploration Strategies for Global Optimization in R},
  author = {D{\'\i}az Esquivel, Cristina and Gallegos Mart{\'\i}nez, Angela Mar{\'\i}a and 
            Moreno Cruz, Agust{\'\i}n and Moreno Urbina, Miguel Angel and
            Salinas Guti\'errez, Rogelio and Montoya Calzada, Pedro Abraham and 
            Rivas Hern\'andez, Juan de Dios and Sald\'ivar Olvera, Ilse Daniela},
  year   = {2026},
  url    = {https://github.com/rogelio-sg/PaqueteR}
}
```

---

**Version:** 1.0.0

**Authors:** Díaz Esquivel C., Gallegos Martínez A. M., Moreno Cruz A., Moreno Urbina M. Á., Salinas Gutiérrez R., Montoya Calzada P. A., López Hernández C. A. & Saldívar Olvera I. D. — [GitHub](https://github.com/rogelio-sg/PaqueteR)
