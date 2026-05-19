library(testthat)

test_that("ts_raster_metric function exists and is a function", {
  skip_on_cran()
  if (!exists("ts_raster_metric", mode = "function")) {
    skip("ts_raster_metric not available in this environment")
  }

  expect_true(exists("ts_raster_metric", mode = "function"))
  expect_true(is.function(ts_raster_metric))
})


test_that("ts_raster_metric returns a SpatRaster", {
  skip_on_cran()
  if (!exists("ts_raster_metric", mode = "function")) {
    skip("ts_raster_metric not available in this environment")
  }
  if (!requireNamespace("terra", quietly = TRUE)) {
    skip("Package `terra` is required for this test.")
  }

  r <- terra::rast(nrows = 10, ncols = 10, nlyrs = 5)
  terra::values(r) <- sample(c(0, 1), terra::ncell(r) * 5, replace = TRUE)

  result <- ts_raster_metric(r, "n_periods")
  
  expect_s4_class(result, "SpatRaster")
})