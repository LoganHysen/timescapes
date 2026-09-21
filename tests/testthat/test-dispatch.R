expected_metrics <- c(
  "total_time", "n_periods", "gap_mean", "gap_max", "duration_sd",
  "edge_density", "autocorr", "aggregation", "core_time_index",
  "n_core_periods"
)

test_that("the public registry is complete and ordered", {
  expect_identical(ts_list_metrics(), expected_metrics)
})

test_that("metric names require exact matches", {
  expect_equal(ts_metric(c(1, 0), "total_time"), 1)
  expect_error(ts_metric(c(1, 0), "total"), "Unknown metric")
  expect_error(ts_metric(c(1, 0), "gap"), "Unknown metric")
  expect_error(ts_metric(c(1, 0), ""), "non-empty")
  expect_error(ts_metric(c(1, 0), NA_character_), "non-empty")
  expect_error(ts_metric(c(1, 0), c("total_time", "n_periods")), "one non-empty")
})

test_that("binary vector validation rejects malformed inputs", {
  expect_error(ts_metric(numeric(), "total_time"), "at least one")
  expect_error(ts_metric(c("1", "0"), "total_time"), "numeric vector")
  expect_error(ts_metric(c(TRUE, FALSE), "total_time"), "numeric vector")
  expect_error(ts_metric(matrix(c(1, 0), nrow = 1), "total_time"), "numeric vector")
  expect_error(ts_metric(c(1, 2), "total_time"), "only 0, 1")
  expect_error(ts_metric(c(0, Inf), "total_time"), "only 0, 1")
  expect_error(ts_metric(c(0, NaN), "total_time"), "only 0, 1")
})

test_that("a missing time step invalidates every metric result", {
  for (metric in ts_list_metrics()) {
    expect_identical(ts_metric(c(1, NA, 0), metric), NA_real_)
  }
})
