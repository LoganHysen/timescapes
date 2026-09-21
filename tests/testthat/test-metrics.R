test_that("all metrics return their documented canonical values", {
  x <- c(1, 1, 0, 0, 1, 0, 1, 1, 1)

  expect_equal(ts_metric(x, "total_time"), 6)
  expect_equal(ts_metric(x, "n_periods"), 3)
  expect_equal(ts_metric(x, "gap_mean"), 1.5)
  expect_equal(ts_metric(x, "gap_max"), 2)
  expect_equal(ts_metric(x, "duration_sd"), 1)
  expect_equal(ts_metric(x, "edge_density"), 0.5)
  expect_equal(
    ts_metric(x, "autocorr"),
    stats::cor(x[-length(x)], x[-1L])
  )
  expect_equal(ts_metric(x, "aggregation"), 0.5)
  expect_equal(ts_metric(x, "core_time_index"), 1 / 6)
  expect_equal(ts_metric(x, "n_core_periods"), 1)
})

test_that("run metrics retain neutral values when features are absent", {
  zeros <- rep(0, 5)
  ones <- rep(1, 5)

  expect_equal(ts_metric(zeros, "total_time"), 0)
  expect_equal(ts_metric(zeros, "n_periods"), 0)
  expect_equal(ts_metric(zeros, "gap_mean"), 5)
  expect_equal(ts_metric(zeros, "duration_sd"), 0)
  expect_equal(ts_metric(ones, "gap_mean"), 0)
  expect_equal(ts_metric(ones, "gap_max"), 0)
  expect_equal(ts_metric(ones, "duration_sd"), 0)
  expect_equal(ts_metric(ones, "core_time_index"), 3 / 5)
  expect_equal(ts_metric(ones, "n_core_periods"), 1)
})

test_that("single-step and undefined autocorrelation behavior is stable", {
  expect_equal(ts_metric(1, "total_time"), 1)
  expect_equal(ts_metric(1, "n_periods"), 1)
  expect_equal(ts_metric(1, "edge_density"), 0)
  expect_equal(ts_metric(1, "aggregation"), 0)
  expect_identical(ts_metric(1, "autocorr"), NA_real_)
  expect_identical(ts_metric(rep(1, 5), "autocorr"), NA_real_)
})

test_that("leading and trailing zero runs count as gaps", {
  x <- c(0, 0, 1, 0, 1, 0, 0, 0)

  expect_equal(ts_metric(x, "gap_mean"), 2)
  expect_equal(ts_metric(x, "gap_max"), 3)
})

test_that("core buffer is forwarded and validated", {
  x <- c(1, 1, 1, 1, 1)

  expect_equal(ts_metric(x, "core_time_index", core_buffer = 0), 1)
  expect_equal(ts_metric(x, "core_time_index", core_buffer = 2), 1 / 5)
  expect_equal(ts_metric(x, "n_core_periods", core_buffer = 2), 1)

  expect_error(ts_metric(x, "core_time_index", core_buffer = -1), "non-negative")
  expect_error(ts_metric(x, "core_time_index", core_buffer = 1.5), "whole number")
  expect_error(ts_metric(x, "core_time_index", core_buffer = 1e20), "whole number")
  expect_error(ts_metric(x, "core_time_index", core_buffer = NA), "whole number")
  expect_error(ts_metric(x, "total_time", core_buffer = 1), "Unused metric argument")
  expect_error(ts_metric(x, "core_time_index", 1), "must be named")
})

test_that("aggregation complements edge density", {
  series <- list(
    c(0, 0),
    c(0, 1, 0, 1),
    c(1, 1, 0, 0, 1),
    rep(1, 8)
  )

  for (x in series) {
    expect_equal(
      ts_metric(x, "aggregation"),
      1 - ts_metric(x, "edge_density")
    )
  }
})
