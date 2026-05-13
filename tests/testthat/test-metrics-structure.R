test_that("ts_n_periods counts runs of occupied time", {
  expect_equal(ts_n_periods(c(1, 1, 0, 0, 1, 0, 1, 1, 1)), 3)
  expect_equal(ts_n_periods(c(0, 0, 0)), 0)
  expect_equal(ts_n_periods(integer()), 0)
})

test_that("structural metrics accept numeric and integer binary inputs", {
  x_num <- c(1, 1, 0, 0, 1, 0, 1, 1, 1)
  x_int <- as.integer(x_num)

  expect_equal(ts_n_periods(x_num), ts_n_periods(x_int))
  expect_equal(ts_gap_mean(x_num), ts_gap_mean(x_int))
  expect_equal(ts_gap_max(x_num), ts_gap_max(x_int))
  expect_equal(ts_duration_sd(x_num), ts_duration_sd(x_int))
  expect_equal(ts_core_time_index(x_num), ts_core_time_index(x_int))
  expect_equal(ts_n_core_periods(x_num), ts_n_core_periods(x_int))
})

test_that("structural metric output modes are consistent", {
  x <- c(1, 1, 0, 0, 1, 0, 1, 1, 1)

  expect_type(ts_n_periods(x), "integer")
  expect_type(ts_gap_mean(x), "double")
  expect_type(ts_gap_max(x), "integer")
  expect_type(ts_duration_sd(x), "double")
  expect_type(ts_core_time_index(x), "double")
  expect_type(ts_n_core_periods(x), "integer")
})

test_that("ts_n_periods returns NA_real_ for invalid inputs", {
  expect_identical(ts_n_periods(c(1, 0, 2)), NA_real_)
  expect_identical(ts_n_periods(c("1", "0")), NA_real_)
  expect_identical(ts_n_periods(c(TRUE, FALSE)), NA_real_)
})

test_that("ts_gap_mean computes mean gap length", {
  expect_equal(ts_gap_mean(c(1, 1, 0, 0, 1, 0, 1, 1, 1)), 1.5)
  expect_equal(ts_gap_mean(c(1, 1, 1)), 0)
  expect_equal(ts_gap_mean(integer()), 0)
})

test_that("ts_gap_mean returns NA_real_ for invalid inputs", {
  expect_identical(ts_gap_mean(c(1, 0, 2)), NA_real_)
  expect_identical(ts_gap_mean(c("1", "0")), NA_real_)
  expect_identical(ts_gap_mean(c(TRUE, FALSE)), NA_real_)
})

test_that("ts_gap_max computes maximum gap length", {
  expect_equal(ts_gap_max(c(1, 1, 0, 0, 1, 0, 1, 1, 1)), 2)
  expect_equal(ts_gap_max(c(1, 1, 1)), 0)
  expect_equal(ts_gap_max(integer()), 0)
})

test_that("ts_gap_max returns NA_real_ for invalid inputs", {
  expect_identical(ts_gap_max(c(1, 0, 2)), NA_real_)
  expect_identical(ts_gap_max(c("1", "0")), NA_real_)
  expect_identical(ts_gap_max(c(TRUE, FALSE)), NA_real_)
})

test_that("ts_duration_sd computes standard deviation of occupied run lengths", {
  expect_equal(ts_duration_sd(c(1, 1, 0, 0, 1, 0, 1, 1, 1)), 1)
  expect_equal(ts_duration_sd(c(1, 1, 1)), 0)
  expect_equal(ts_duration_sd(c(0, 0, 0)), 0)
  expect_equal(ts_duration_sd(integer()), 0)
})

test_that("ts_duration_sd returns NA_real_ for invalid inputs", {
  expect_identical(ts_duration_sd(c(1, 0, 2)), NA_real_)
  expect_identical(ts_duration_sd(c("1", "0")), NA_real_)
  expect_identical(ts_duration_sd(c(TRUE, FALSE)), NA_real_)
})

test_that("ts_core_time_index computes core occupied-time proportion", {
  expect_equal(ts_core_time_index(c(1, 1, 0, 0, 1, 0, 1, 1, 1)), 1 / 6)
  expect_equal(ts_core_time_index(c(1, 1, 1), core_buffer = 0L), 1)
  expect_equal(ts_core_time_index(c(0, 0, 0)), 0)
  expect_equal(ts_core_time_index(integer()), 0)
})

test_that("ts_core_time_index allows missing values in valid binary input", {
  expect_equal(ts_core_time_index(c(1, NA, 1, 1), core_buffer = 0L), 1)
})

test_that("ts_core_time_index returns NA_real_ for invalid inputs", {
  expect_identical(ts_core_time_index(c(1, 0, 2)), NA_real_)
  expect_identical(ts_core_time_index(c("1", "0")), NA_real_)
  expect_identical(ts_core_time_index(c(TRUE, FALSE)), NA_real_)
})

test_that("ts_n_core_periods counts occupied runs longer than the buffer edge", {
  expect_equal(ts_n_core_periods(c(1, 1, 0, 0, 1, 0, 1, 1, 1)), 1)
  expect_equal(ts_n_core_periods(c(1, 1, 1), core_buffer = 0L), 1)
  expect_equal(ts_n_core_periods(c(0, 0, 0)), 0)
  expect_equal(ts_n_core_periods(integer()), 0)
})

test_that("ts_n_core_periods returns NA_real_ for invalid inputs", {
  expect_identical(ts_n_core_periods(c(1, 0, 2)), NA_real_)
  expect_identical(ts_n_core_periods(c("1", "0")), NA_real_)
  expect_identical(ts_n_core_periods(c(TRUE, FALSE)), NA_real_)
})
