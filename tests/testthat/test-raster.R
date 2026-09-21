make_test_raster <- function() {
  r <- terra::rast(nrows = 1, ncols = 3, nlyrs = 5)
  terra::values(r) <- matrix(
    c(
      1, 1, 0, 1, 0,
      0, 0, 0, 0, 0,
      1, NA, 1, 1, 1
    ),
    nrow = terra::ncell(r),
    byrow = TRUE
  )
  r
}

test_that("raster metrics preserve geometry and return hand-calculated values", {
  r <- make_test_raster()
  result <- ts_raster_metric(r, "n_periods")

  expect_s4_class(result, "SpatRaster")
  expect_equal(terra::nlyr(result), 1)
  expect_equal(terra::ncell(result), terra::ncell(r))
  expect_equal(as.vector(terra::ext(result)), as.vector(terra::ext(r)))
  expect_equal(terra::crs(result), terra::crs(r))
  expect_equal(names(result), "n_periods")
  expect_equal(unname(terra::values(result)[, 1]), c(2, 0, NA))
})

test_that("raster metric arguments are forwarded", {
  r <- terra::rast(nrows = 1, ncols = 2, nlyrs = 5)
  terra::values(r) <- matrix(
    c(1, 1, 1, 1, 1, 1, 1, 0, 1, 1),
    nrow = terra::ncell(r),
    byrow = TRUE
  )

  result <- ts_raster_metric(r, "core_time_index", core_buffer = 2)
  expect_equal(unname(terra::values(result)[, 1]), c(1 / 5, 0))
})

test_that("raster inputs use binary validation", {
  expect_error(ts_raster_metric(1:3, "total_time"), "SpatRaster")

  r <- terra::rast(nrows = 1, ncols = 1, nlyrs = 3)
  terra::values(r) <- c(0, 0.5, 1)
  expect_error(ts_raster_metric(r, "total_time"), "only 0, 1")
})
