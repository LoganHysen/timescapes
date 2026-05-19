x_simple <- c(1,1,0,0,1,1)

x_fragmented <- c(1,0,1,0,1,0,1)

x_all_zero <- rep(0, 10)

x_all_one <- rep(1, 10)

test_that("ts_metrics works end-to-end", {
  
  x <- c(1,1,0,0,1,1)
  
  res <- ts_metrics(x)
  
  expect_true(is.numeric(res))
  expect_true(length(res) > 0)
  expect_named(res)
  
})

test_that("metrics behave sensibly across scenarios", {
  
  x1 <- c(1,1,1,1,1)
  x2 <- c(1,0,1,0,1)
  
  res1 <- ts_metrics(x1, "n_periods")
  res2 <- ts_metrics(x2, "n_periods")
  
  expect_true(res1["n_periods"] <= res2["n_periods"])
})


test_that("ts_metrics works on realistic scenarios", {

  ts_examples <- list(
    continuous = rep(1, 10),
    fragmented = rep(c(1,0), 5),
    two_periods = c(1,1,1,0,0,1,1,1)
  )

  res <- lapply(ts_examples, ts_metrics)

  expect_true(all(sapply(res, is.numeric)))
  expect_true(all(sapply(res, function(x) length(x) > 0)))

})
