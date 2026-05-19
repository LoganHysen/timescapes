test_that("all registry metrics run without error", {
  x <- c(1, 1, 0, 0, 1, 1)

  for (m in names(.ts_registry)) {
    expect_no_error(ts_metric(x, m))
  }
})

test_that("ts_metric dispatches named metrics from the registry", {
  x <- c(1, 1, 0, 0, 1, 1)

  expect_equal(ts_metric(x, "total_time"), ts_total_time(x))
  expect_equal(ts_metric(x, "n_periods"), ts_n_periods(x))
  expect_equal(ts_metric(x, "gap_mean"), ts_gap_mean(x))
})

test_that("ts_metric supports partial metric names in registry order", {
  x <- c(1, 1, 0, 0, 1, 1)

  expect_equal(ts_metric(x, "gap"), ts_gap_mean(x))
  expect_equal(ts_metric(x, "edge"), ts_edge_density(x))
})

test_that("ts_metrics returns a named numeric vector for selected registry metrics", {
  x <- c(1, 1, 0, 0, 1, 1)
  metrics <- c("total_time", "n_periods", "gap_mean")

  res <- ts_metrics(x, metrics)

  expect_type(res, "double")
  expect_named(res, metrics)
  expect_equal(unname(res), c(4, 2, 2))
})

test_that("ts_metrics resolves partial names and preserves requested ordering", {
  x <- c(1, 1, 0, 0, 1, 1)
  metrics <- c("gap", "total", "core_time")

  res <- ts_metrics(x, metrics)

  expect_type(res, "double")
  expect_named(res, c("gap_mean", "total_time", "core_time_index"))
  expect_equal(unname(res), c(ts_gap_mean(x), ts_total_time(x), ts_core_time_index(x)))
})

test_that("registry helpers reject unknown or malformed metric names", {
  x <- c(1, 1, 0, 0, 1, 1)

  expect_error(ts_metric(x, "not_a_metric"), "Unknown metric: `not_a_metric`")
  expect_error(ts_metric(x, c("total_time", "n_periods")), "single non-empty metric name")
  expect_error(ts_metric(x, ""), "single non-empty metric name")
  expect_error(ts_metrics(x, c("total_time", NA)), "character vector of non-empty metric names")
  expect_error(ts_metrics(x, c("total_time", "")), "character vector of non-empty metric names")
  expect_error(ts_metrics(x, c("total_time", "not_a_metric")), "Available metrics")
})

test_that("ts_metric works for all registry entries", {

  x <- c(1,1,0,0,1,1)

  for (m in names(.ts_registry)) {
    expect_no_error(ts_metric(x, m))
  }

})

test_that("ts_metrics returns named vector", {

  x <- c(1,1,0,0,1,1)

  res <- ts_metrics(x)

  expect_true(is.numeric(res))
  expect_named(res)

})