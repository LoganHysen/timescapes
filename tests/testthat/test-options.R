test_that("boundary selection handles asymmetric and absent gaps", {
  for (metric in c("gap_mean", "gap_max")) {
    expect_equal(ts_metric(c(0, 0, 1, 0, 1, 0, 0, 0), metric,
                           include_boundary_gaps = FALSE), 1)
    for (x in list(rep(0, 4), rep(1, 4), c(0, 1, 0), 0, 1)) {
      expect_equal(ts_metric(x, metric, include_boundary_gaps = FALSE), 0)
    }
    expect_equal(ts_metric(rep(0, 4), metric), 4)
    for (bad in list(NULL, NA, 1, "TRUE", logical(), c(TRUE, FALSE))) {
      expect_error(ts_metric(c(1, NA), metric, include_boundary_gaps = bad),
                   "must be TRUE or FALSE")
    }
  }
})

test_that("core periods use full runs at an inclusive threshold", {
  x <- c(rep(1, 2), 0, rep(1, 3), 0, rep(1, 4))
  expect_equal(ts_metric(x, "core_time_index", min_core_period = 3), 7 / 9)
  expect_equal(ts_metric(x, "n_core_periods", min_core_period = 3), 2)
  for (metric in c("core_time_index", "n_core_periods")) {
    expect_equal(ts_metric(rep(0, 4), metric, min_core_period = 1), 0)
    expect_equal(ts_metric(rep(1, 4), metric, min_core_period = 5), 0)
    expect_equal(ts_metric(1, metric, min_core_period = 1), 1)
    expect_warning(value <- ts_metric(rep(1, 15), metric), "15 time steps")
    expect_equal(value, 1)
    expect_warning(value <- ts_metric(rep(1, 14), metric), "15 time steps")
    expect_equal(value, 0)
    expect_no_warning(ts_metric(x, metric, min_core_period = 15))
    for (bad in list(NULL, NA, NaN, Inf, -1, 0, 1.5, 1e20, TRUE, "3", c(2, 3))) {
      expect_error(ts_metric(c(1, NA), metric, min_core_period = bad),
                   "positive whole number")
    }
    expect_error(ts_metric(x, metric, core_buffer = 1), "Unused metric argument")
    expect_error(ts_metric(x, metric, 3), "must be named")
  }
})

test_that("raster options and warnings are resolved once before cell processing", {
  histories <- rbind(c(0, 0, 1, 0, 1, 0), rep(0, 6), rep(1, 6),
                     c(1, 1, 1, 0, 1, 1), c(1, NA, 0, 0, 0, 0))
  r <- terra::rast(nrows = 1, ncols = 5, nlyrs = 6)
  terra::values(r) <- histories
  for (metric in c("gap_mean", "gap_max")) {
    result <- ts_raster_metric(r, metric, include_boundary_gaps = FALSE)
    expect_equal(as.vector(terra::values(result)), c(1, 0, 0, 1, NA))
    expect_error(ts_raster_metric(r, metric, include_boundary_gaps = 1), "TRUE or FALSE")
  }
  expect_equal(as.vector(terra::values(ts_raster_metric(r, "core_time_index",
               min_core_period = 3))), c(0, 0, 1, 3 / 5, NA))
  expect_equal(as.vector(terra::values(ts_raster_metric(r, "n_core_periods",
               min_core_period = 3))), c(0, 0, 1, 1, NA))
  for (metric in c("core_time_index", "n_core_periods")) {
    warnings <- character()
    result <- withCallingHandlers(ts_raster_metric(r, metric), warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    })
    expect_length(warnings, 1)
    expect_match(warnings, "15 time steps")
    expect_equal(as.vector(terra::values(result)), c(0, 0, 0, 0, NA))
    expect_error(ts_raster_metric(r, metric, min_core_period = 0), "positive whole")
  }
  single <- r[[1]]
  expect_equal(as.vector(terra::values(ts_raster_metric(single, "gap_max",
               include_boundary_gaps = FALSE))), rep(0, 5))
  expect_equal(as.vector(terra::values(ts_raster_metric(single, "core_time_index",
               min_core_period = 1))), c(0, 0, 1, 1, 1))
})
