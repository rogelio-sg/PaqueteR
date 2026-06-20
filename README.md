
# PaqueteR

[![R Version](https://img.shields.io/badge/R-4.0+-blue.svg)](https://www.r-project.org/)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

---

## Overview

**PaqueteR** es un paquete de R diseñado para la optimización global de funciones continuas mediante algoritmos bio-inspirados y de inteligencia de enjambre. El paquete consolida cuatro metaheurísticas recientes, optimizadas vectorialmente para ofrecer un alto rendimiento computacional en espacios de búsqueda complejos y de alta dimensionalidad.

Una ventaja clave de esta librería es su **compatibilidad e integración nativa con el paquete EEEA** (*Explicit Exploration Strategy for Evolutionary Algorithms*). Esto permite activar una fase de exploración explícita que diversifica la población basándose en la estabilidad de la distribución del espacio, mitigando el estancamiento prematuro en óptimos locales.

---

## Implemented Metaheuristics

El paquete incluye las siguientes cuatro estrategias de optimización:

* **Butterfly Optimization Algorithm (BOA):** Simula el sistema biológico de percepción de fragancias y olores en las mariposas para alternar dinámicamente entre fases de búsqueda global y local.
* **Fireworks Algorithm (FWA):** Método de inteligencia de enjambre que emula la explosión de fuegos artificiales, regulando de forma adaptativa el número de chispas y la amplitud de la explosión según la cercanía al óptimo.
* **Ladybug Beetle Optimization (LBO):** Modela el comportamiento de las mariquitas ante cambios térmicos, incorporando caminatas aleatorias de **Vuelos de Lévy** para exploración, agrupamiento por calor para explotación y selección dinámica por congelamiento.
* **Prairie Dog Optimization (PDO):** Emula los comportamientos sociales y de comunicación de los perritos de la pradera a través de 4 fases adaptativas: forrajeo con vuelos de Lévy, construcción estocástica de madrigueras, alertas de comida y alertas de depredadores.

---

## Key Features

- **Consolidación de Metaheurísticas Recientes:** Implementación en R de algoritmos de enjambre con nula o escasa presencia previa en el software analítico tradicional.
- **Hibridación con EEEA:** Parámetro opcional integrado en todas las funciones principales para activar estrategias de exploración explícita.
- **Mecanismos Estocásticos Avanzados:** Incorporación de Vuelos de Lévy (*Lévy Flights*) para saltar eficientemente barreras locales en paisajes multimodales.
- **Criterios de Parada Temprana:** Soporte para el parámetro de paciencia (`pb`) que detiene la ejecución si el algoritmo detecta estancamiento, optimizando los tiempos de cómputo.
- **Suite Automática de Calidad:** Validación e integridad matemática respaldada por pruebas unitarias bajo el framework `testthat`.

---

## Installation

Dado que el paquete se encuentra bajo desarrollo activo en la rama `dev`, puedes instalarlo directamente en R utilizando `devtools`:

```r
# Asegúrate de contar con devtools
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Instalación de la versión de desarrollo
devtools::install_github("rogelio-sg/PaqueteR", ref = "dev")
```

### Requirements

- R 4.0.0+
- testthat

---

## Implemented Algorithms

### Butterfly Optimization Algorithm (BOA)
Metaheurística basada en el comportamiento biológico de las mariposas, las cuales utilizan su sentido del olfato para determinar la intensidad de una fragancia y navegar hacia fuentes de alimento o pareja potenciales. Soporta ejecución estándar o hibridación con exploración explícita.
```r
library(boa_metaheuristic)

# Ejecución estándar
result_boa <- boa_metaheuristica(
  objective_function = my_function,
  lower              = rep(-5.12, 10),
  upper              = rep(5.12, 10),
  pop_size           = 30,
  max_iter           = 100,
  p                  = 0.8,    # Probabilidad de cambio entre búsqueda global y local
  c                  = 0.01,   # Modalidad sensorial (sensory modality)
  a                  = 0.1     # Exponente de potencia basado en la intensidad
)

# Con estrategia de exploración explícita (EEEA) y parada temprana
result_boa_ee <- boa_metaheuristic(
  objective_function = my_function,
  lower              = rep(-5.12, 10),
  upper              = rep(5.12, 10),
  pop_size           = 30,
  max_iter           = 100,
  p                  = 0.8, 
  c                  = 0.01, 
  a                  = 0.1,
  EE                 = TRUE,   # Activa la exploración explícita
  pb                 = 15      # Criterio de parada temprana (paciencia)
)
```

### Fireworks Algorithm (FWA)
Algoritmo de optimización de enjambres inspirado en la explosión de fuegos artificiales. Determina de forma dinámica la cantidad de chispas y la amplitud del radio de explosión para equilibrar la búsqueda global (chispas alejadas) y la búsqueda local (chispas concentradas).
```r
library(fwa_metaheuristic)

# Ejecución estándar
result_fwa <- fwa_metaheuristica(
  objective_function = my_function,
  lower              = rep(-10, 5),
  upper              = rep(10, 5),
  pop_size           = 25,
  max_iter           = 150,
  m1                 = 10,     # Número total de chispas regulares generadas
  m2                 = 5,      # Número de chispas Gaussianas (mutadas)
  A_max              = 40      # Amplitud máxima permitida para la explosión
)

# Con estrategia de exploración explícita (EEEA) y parada temprana
result_fwa_ee <- fwa_metaheuristica(
  objective_function = my_function,
  lower              = rep(-10, 5),
  upper              = rep(10, 5),
  pop_size           = 25,
  max_iter           = 150,
  m1                 = 10,
  m2                 = 5,
  A_max              = 40,
  EE                 = TRUE,   # Activa la exploración explícita
  pb                 = 20      # Criterio de parada temprana (paciencia)
)
```

### Ladybug Beetle Optimization (LBO)
Estrategia estocástica inspirada en el comportamiento y hábitos de supervivencia de las mariquitas. Combina desplazamientos espaciales amplios usando Vuelos de Lévy, procesos de agregación basados en gradientes térmicos artificiales y mecanismos de dispersión selectiva.
```r
library(lbo_metaheuristic)

# Ejecución estándar
result_lbo <- lbo_metaheuristic(
  objective_function = my_function,
  lower              = rep(-5, 10),
  upper              = rep(5, 10),
  pop_size           = 40,
  max_iter           = 200,
  alpha              = 0.5,    # Factor de escala para los pasos de Lévy
  beta               = 1.5     # Parámetro de estabilidad para la distribución de Lévy
)

# Con estrategia de exploración explícita (EEEA) y parada temprana
result_lbo_ee <- lbo_metaheuristic(
  objective_function = my_function,
  lower              = rep(-5, 10),
  upper              = rep(5, 10),
  pop_size           = 40,
  max_iter           = 200,
  alpha              = 0.5,
  beta               = 1.5,
  EE                 = TRUE,   # Activa la exploración explícita
  pb                 = 30      # Criterio de parada temprana (paciencia)
)
```

### Prairie Dog Optimization (PDO)
Algoritmo de optimización metaheurístico basado en el comportamiento gregario del perrito de la pradera. Modela matemáticamente cuatro patrones interactivos de conducta social (construcción de madrigueras, forrajeo, respuesta a alarmas por comida y evasión de depredadores) asistido por caminatas aleatorias pesadas.
```r
library(pdo_metaheuristic)

# Ejecución estándar
result_pdo <- pdo(
  objective_function = my_function,
  lower              = rep(-5.12, 10),
  upper              = rep(5.12, 10),
  pop_size           = 35,
  max_iter           = 100
)

# Con estrategia de exploración explícita (EEEA) y parada temprana
result_pdo_ee <- pdo(
  objective_function = my_function,
  lower              = rep(-5.12, 10),
  upper              = rep(5.12, 10),
  pop_size           = 35,
  max_iter           = 100,
  EE                 = TRUE,   # Activa la exploración explícita
  pb                 = 10      # Criterio de parada temprana (paciencia)
)
```

---

## Result Format

All algorithms return a dictionary with the following keys:

| Key | Type | Description |
|-----|------|-------------|
| `best.sol` | `numeric vector` | Vector multidimensional con la mejor solución u óptimo localizado.|
| `best.fit` | `numeric` |El valor de aptitud (fitness) correspondiente a la mejor solución encontrada.|

---

## License

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.

---

## Support

For bug reports and feature requests, open an issue on [GitHub](
https://github.com/rogelio-sg/PaqueteR/issues).

---  
