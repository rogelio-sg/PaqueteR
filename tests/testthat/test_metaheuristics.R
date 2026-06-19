library(testthat)

# 1. Definimos una lista con los algoritmos a probar
algoritmos <- list(
  PDO = pdo_metaheuristic,
  BOA = boa_metaheuristic,
  LBO = lbo_metaheuristic,
  FWA = fwa_metaheuristic
)

# 2. Definimos funciones objetivo de prueba estándar
fn_esfera  <- function(x) sum(x^2)
fn_shifted <- function(x, shift) sum((x - shift)^2)

# --- INICIO DE LA SUITE DE PRUEBAS ---

test_that("Pruebas de Entrada y Ajuste de Parámetros", {
  for (nombre in names(algoritmos)) {
    algo <- algoritmos[[nombre]]

    # Ejecutar con límites como un único valor numérico
    res <- algo(obj.fun = fn_esfera, dim = 3, lb = -10, ub = 10, gen = 2)

    # Validar que la solución devuelta tenga la dimensión correcta
    expect_length(res$best.sol, 3)
    # Validar que la solución esté dentro de los límites esperados
    expect_true(all(res$best.sol >= -10 & res$best.sol <= 10))
  }
})

test_that("Pruebas de Estructura y Formato de Salida", {
  for (nombre in names(algoritmos)) {
    algo <- algoritmos[[nombre]]

    res <- algo(obj.fun = fn_esfera, dim = 2, lb = -5, ub = 5, gen = 5)

    # Comprobamos que devuelva la estructura correcta
    expect_type(res, "list")
    expect_named(res, c("best.sol", "best.fit"), ignore.order = TRUE)
    expect_length(res$best.fit, 1)
    expect_length(res$best.sol, 2)
    expect_true(is.numeric(res$best.fit))
  }
})

test_that("Pruebas de Control de Fronteras", {
  lb_asym <- c(-2, 1)
  ub_asym <- c(3, 6)

  for (nombre in names(algoritmos)) {
    algo <- algoritmos[[nombre]]

    res <- algo(obj.fun = fn_esfera, dim = 2, lb = lb_asym, ub = ub_asym, gen = 10)

    # Comprobar que ninguna coordenada se salga de los límites
    expect_true(all(res$best.sol >= lb_asym), info = paste(nombre, "paso lb"))
    expect_true(all(res$best.sol <= ub_asym), info = paste(nombre, "paso ub"))
  }
})

test_that("Pruebas de Robustez ante Argumentos Adicionales (...)", {
  for (nombre in names(algoritmos)) {
    algo <- algoritmos[[nombre]]

    # El 'shift = 3' debe viajar a través del algoritmo hasta fn_shifted
    res <- algo(obj.fun = fn_shifted, dim = 2, lb = -5, ub = 5, gen = 10, shift = 3)

    expect_true(is.numeric(res$best.fit))
    # Debería aproximarse a las coordenadas del shift (3, 3)
    expect_equal(res$best.sol, c(3, 3), tolerance = 1.0)
  }
})

test_that("Pruebas de Criterios de Parada Anticipada con el Parámetro de Paciencia (pb)", {
  fn_constante <- function(x) 100

  for (nombre in names(algoritmos)) {
    algo <- algoritmos[[nombre]]

    # Comprobamos que el algoritmo maneje el estancamiento con pb > 0 sin colapsar
    res <- algo(obj.fun = fn_constante, dim = 2, lb = -5, ub = 5, gen = 50, pb = 2)

    expect_equal(res$best.fit, 100)
  }
})

test_that("Pruebas de Integración con Exploración Explícita (EE)", {

  # 1. Creamos la función mock de manera normal
  mock_ee <- function(fun, lower, upper, n, maxiter, ...) {
    return(list(
      par = matrix(runif(n * length(lower), lower, upper), nrow = n),
      n_gen = 2,
      n.gen = 2
    ))
  }

  # 2. Inyectamos directamente en el entorno de los algoritmos de forma segura
  # Usamos el entorno de uno de tus algoritmos para asegurar coincidencia exacta
  env_algos <- environment(pdo_metaheuristic)
  assign("ExplicitExploration", mock_ee, envir = env_algos)

  # 3. Ejecutamos el bucle de pruebas
  for (nombre in names(algoritmos)) {
    algo <- algoritmos[[nombre]]

    # Verifica que corra con EE=TRUE sin arrojar errores
    expect_no_error({
      algo(obj.fun = fn_esfera, dim = 2, lb = -5, ub = 5, gen = 10, EE = TRUE)
    })
  }

  # 4. Limpieza obligatoria al terminar la prueba
  if (exists("ExplicitExploration", envir = env_algos, inherits = FALSE)) {
    rm("ExplicitExploration", envir = env_algos)
  }
})

test_that("Pruebas de Convergencia Mínima (Optimización Funcional)", {
  # Fijamos la semilla para asegurar predictibilidad
  set.seed(42)

  for (nombre in names(algoritmos)) {
    algo <- algoritmos[[nombre]]

    # Incrementamos ligeramente el tamaño para darles más estabilidad estocástica
    res <- algo(obj.fun = fn_esfera, pop.size = 40, dim = 2, lb = -5, ub = 5, gen = 150)

    # Óptimo global en x = c(0,0), fitness = 0.
    # Un umbral de 3.0 es perfecto para validar el comportamiento cooperativo de minimización.
    expect_lt(res$best.fit, 3.0, label = paste0("res$best.fit de ", nombre))
  }
})
