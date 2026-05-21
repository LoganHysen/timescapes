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


test_that("ts_raster_metric returns one layer per class", {
  skip_on_cran()
  if (!exists("ts_raster_metric", mode = "function")) {
    skip("ts_raster_metric not available in this environment")
  }
  if (!requireNamespace("terra", quietly = TRUE)) {
    skip("Package `terra` is required for this test.")
  }

  r <- terra::rast(nrows = 1, ncols = 3, nlyrs = 4)
  terra::values(r) <- matrix(
    c(
      2, 9, 4, 0,
      9, 9, 2, 4,
      2, 4, 2, 4
    ),
    nrow = terra::ncell(r),
    byrow = TRUE
  )

  result <- ts_raster_metric(r, "total_time", classes = c(2, 4))

  expect_equal(terra::nlyr(result), 2)
  expect_equal(names(result), c("total_time_class_2", "total_time_class_4"))
  expect_equal(unname(terra::values(result)), cbind(c(1, 1, 2), c(1, 1, 2)))
})


test_that("multi-class output has correct structure", {
  
  library(terra)
  
  r <- rast(nrows = 10, ncols = 10, nlyrs = 5)
  values(r) <- sample(1:3, ncell(r) * 5, replace = TRUE)
  
  res <- ts_raster_metric(r, "n_periods", classes = c(1,2,3))
  
  expect_true(inherits(res, "SpatRaster"))
  expect_equal(nlyr(res), 3)
  expect_equal(ncell(res), ncell(r))
  
})

test_that("multi-class output matches manual calculation", {
  
  library(terra)

  r <- rast(nrows=1, ncols=1, nlyrs=5)
  values(r) <- c(1,2,1,3,1)
  
  res <- ts_raster_metric(r, "n_periods", classes = c(1,2,3))
  
  x <- c(1,2,1,3,1)
  
  # class 1
  x1 <- as.integer(x == 1)
  expect_equal(unname(values(res)[1,1]), ts_metric(x1, "n_periods"))
  
})

test_that("multi-class equals repeated single-class calls", {
  r <- rast(nrows = 5, ncols = 5, nlyrs = 5)
  values(r) <- sample(1:3, ncell(r) * 5, replace = TRUE)

  classes <- c(1, 2, 3)

  res_multi <- ts_raster_metric(r, "n_periods", classes = classes)

  for (i in seq_along(classes)) {
    res_single <- ts_raster_metric(r, "n_periods", classes = classes[i])

    expect_equal(values(res_multi)[, i], values(res_single)[, 1])
  }
})

test_that("total_time across classes is bounded", {
  
  r <- rast(nrows=3, ncols=3, nlyrs=10)
  values(r) <- sample(1:3, ncell(r) * 10, replace = TRUE)
  
  res <- ts_raster_metric(r, "total_time", classes = c(1,2,3))
  
  summed <- rowSums(values(res))
  
  expect_true(all(summed <= 10))
})

test_that("NA values are handled correctly", {
  
  r <- rast(nrows=1, ncols=1, nlyrs=5)
  values(r) <- c(1, NA, 1, 2, NA)
  
  res <- ts_raster_metric(r, "n_periods", classes = c(1,2))
  
  expect_true(!all(is.na(values(res))))
})
