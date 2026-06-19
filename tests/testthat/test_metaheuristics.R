library(testthat)

# 1. Define a list of the algorithms to test
algoritmos <- list(
  PDO = pdo_metaheuristic,
  BOA = boa_metaheuristic,
  LBO = lbo_metaheuristic,
  FWA = fwa_metaheuristic
)

# 2. Define standard benchmark objective functions
fn_esfera  <- function(x) sum(x^2)
fn_shifted <- function(x, shift) sum((x - shift)^2)

# --- START OF THE TEST SUITE ---

test_that("Input and Parameter Adjustment Tests", {
  for (nombre in names(algoritmos)) {
    algo <- algoritmos[[nombre]]

    # Run with boundaries passed as a single numeric value
    res <- algo(obj.fun = fn_esfera, dim = 3, lb = -10, ub = 10, gen = 2)

    # Validate that the returned solution has the correct dimension
    expect_length(res$best.sol, 3)
    # Validate that the solution is within the expected boundaries
    expect_true(all(res$best.sol >= -10 & res$best.sol <= 10), info = paste("Algorithm:", nombre))
  }
})

test_that("Output Structure and Format Tests", {
  for (nombre in names(algoritmos)) {
    algo <- algoritmos[[nombre]]

    res <- algo(obj.fun = fn_esfera, dim = 2, lb = -5, ub = 5, gen = 5)

    # Check that it returns the correct structure
    expect_type(res, "list")
    expect_named(res, c("best.sol", "best.fit"), ignore.order = TRUE)
    expect_length(res$best.fit, 1)
    expect_length(res$best.sol, 2)
    expect_true(is.numeric(res$best.fit), info = paste("Numeric structure failure in:", nombre))
  }
})

test_that("Boundary Control Tests", {
  lb_asym <- c(-2, 1)
  ub_asym <- c(3, 6)

  for (nombre in names(algoritmos)) {
    algo <- algoritmos[[nombre]]

    res <- algo(obj.fun = fn_esfera, dim = 2, lb = lb_asym, ub = ub_asym, gen = 10)

    # Check that no coordinate exceeds the boundaries
    expect_true(all(res$best.sol >= lb_asym), info = paste("LB failure in:", nombre))
    expect_true(all(res$best.sol <= ub_asym), info = paste("UB failure in:", nombre))
  }
})

test_that("Robustness Tests for Additional Arguments (...)", {
  for (nombre in names(algoritmos)) {
    algo <- algoritmos[[nombre]]

    # 'shift = 3' must travel through the algorithm to fn_shifted
    res <- algo(obj.fun = fn_shifted, dim = 2, lb = -5, ub = 5, gen = 10, shift = 3)

    expect_true(is.numeric(res$best.fit), info = paste("Type error in:", nombre))
    # It should approximate the shift coordinates (3, 3)
    expect_equal(res$best.sol, c(3, 3), tolerance = 1.0)
  }
})

test_that("Early Stopping Criteria Tests with the Patience Parameter (pb)", {
  fn_constante <- function(x) 100

  for (nombre in names(algoritmos)) {
    algo <- algoritmos[[nombre]]

    # Check that the algorithm handles stagnation with pb > 0 without crashing
    res <- algo(obj.fun = fn_constante, dim = 2, lb = -5, ub = 5, gen = 50, pb = 2)

    expect_equal(res$best.fit, 100)
  }
})

test_that("Integration Tests with Explicit Exploration (EE)", {

  # 1. Create the mock function normally
  mock_ee <- function(fun, lower, upper, n, maxiter, ...) {
    return(list(
      par = matrix(runif(n * length(lower), lower, upper), nrow = n),
      n_gen = 2,
      n.gen = 2
    ))
  }

  # 2. Inject it directly into the algorithms' environment safely
  # We use the environment of one of your algorithms to ensure an exact match
  env_algos <- environment(pdo_metaheuristic)
  assign("ExplicitExploration", mock_ee, envir = env_algos)

  # 3. Run the test loop
  for (nombre in names(algoritmos)) {
    algo <- algoritmos[[nombre]]

    # Verify that it runs with EE=TRUE without throwing errors
    expect_no_error({
      algo(obj.fun = fn_esfera, dim = 2, lb = -5, ub = 5, gen = 10, EE = TRUE)
    })
  }

  # 4. Mandatory cleanup after the test finishes
  if (exists("ExplicitExploration", envir = env_algos, inherits = FALSE)) {
    rm("ExplicitExploration", envir = env_algos)
  }
})

test_that("Minimum Convergence Tests (Functional Optimization)", {
  # Fix the seed to ensure predictability
  set.seed(42)

  for (nombre in names(algoritmos)) {
    algo <- algoritmos[[nombre]]

    # Slightly increase size and generations for stochastic stability
    res <- algo(obj.fun = fn_esfera, pop.size = 40, dim = 2, lb = -5, ub = 5, gen = 150)

    # Global optimum at x = c(0,0), fitness = 0.
    # A threshold of 3.0 is perfect for validating cooperative minimization behavior.
    expect_lt(res$best.fit, 1.0, label = paste0("res$best.fit de ", nombre))
  }
})
