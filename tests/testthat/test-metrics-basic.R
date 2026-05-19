test_that("ts_total_time sums occupied time and ignores missing values", {
  expect_equal(ts_total_time(c(1, 0, 1, 1, 0)), 3)
  expect_equal(ts_total_time(c(1, NA, 0, 1)), 2)
  expect_equal(ts_total_time(integer()), 0)
})

test_that("basic metrics accept numeric and integer binary inputs", {
  expect_equal(ts_total_time(c(1, 0, 1)), ts_total_time(c(1L, 0L, 1L)))
  expect_equal(ts_edge_density(c(1, 0, 1)), ts_edge_density(c(1L, 0L, 1L)))
  expect_equal(ts_aggregation(c(1, 0, 1)), ts_aggregation(c(1L, 0L, 1L)))
  expect_equal(ts_autocorr(c(1, 0, 1)), ts_autocorr(c(1L, 0L, 1L)))
})

test_that("basic metric output modes are consistent", {
  expect_type(ts_total_time(c(1, 0, 1)), "integer")
  expect_type(ts_edge_density(c(1, 0, 1)), "double")
  expect_type(ts_aggregation(c(1, 0, 1)), "double")
  expect_type(ts_autocorr(c(1, 0, 1)), "double")
})

test_that("ts_total_time returns NA_real_ for invalid inputs", {
  expect_identical(ts_total_time(c(1, 0, 2)), NA_real_)
  expect_identical(ts_total_time(c("1", "0")), NA_real_)
  expect_identical(ts_total_time(c(TRUE, FALSE)), NA_real_)
})

test_that("ts_edge_density computes transition density", {
  expect_equal(ts_edge_density(c(1, 1, 0, 1, 0)), 3 / 4)
  expect_equal(ts_edge_density(c(1)), 0)
  expect_equal(ts_edge_density(integer()), 0)
})

test_that("ts_edge_density allows missing values without changing calculation behavior", {
  expect_true(is.na(ts_edge_density(c(1, NA, 0))))
})

test_that("ts_edge_density returns NA_real_ for invalid inputs", {
  expect_identical(ts_edge_density(c(1, 0, 2)), NA_real_)
  expect_identical(ts_edge_density(c("1", "0")), NA_real_)
  expect_identical(ts_edge_density(c(TRUE, FALSE)), NA_real_)
})

test_that("ts_aggregation computes adjacent-state agreement", {
  expect_equal(ts_aggregation(c(1, 1, 0, 0, 1)), 2 / 4)
  expect_equal(ts_aggregation(c(1)), 0)
  expect_equal(ts_aggregation(integer()), 0)
})

test_that("ts_aggregation allows missing values without changing calculation behavior", {
  expect_true(is.na(ts_aggregation(c(1, NA, 0))))
})

test_that("ts_aggregation returns NA_real_ for invalid inputs", {
  expect_identical(ts_aggregation(c(1, 0, 2)), NA_real_)
  expect_identical(ts_aggregation(c("1", "0")), NA_real_)
  expect_identical(ts_aggregation(c(TRUE, FALSE)), NA_real_)
})

test_that("ts_autocorr computes lag-1 autocorrelation", {
  expect_equal(ts_autocorr(c(0, 1, 0, 1)), -1)
  expect_equal(ts_autocorr(c(1)), 0)
  expect_equal(ts_autocorr(integer()), 0)
})

test_that("ts_autocorr allows missing values and uses complete pairs", {
  expect_equal(ts_autocorr(c(0, 1, 0, NA, 1)), -1)
})

test_that("ts_autocorr returns NA_real_ for invalid inputs", {
  expect_identical(ts_autocorr(c(1, 0, 2)), NA_real_)
  expect_identical(ts_autocorr(c("1", "0")), NA_real_)
  expect_identical(ts_autocorr(c(TRUE, FALSE)), NA_real_)
})

test_that("loss reduces total time", {

  x_full <- rep(1, 10)
  x_loss <- c(rep(0, 3), rep(1, 7))

  expect_lt(ts_total_time(x_loss), ts_total_time(x_full))

})