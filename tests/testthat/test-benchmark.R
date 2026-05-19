test_that("benchmark scenarios behave as expected", {

  sims <- ts_benchmark()

  cont <- sims$continuous
  frag <- sims$fragmentation_only

  expect_gt(ts_n_periods(frag), ts_n_periods(cont))
  expect_gt(ts_edge_density(frag), ts_edge_density(cont))

})

test_that("metrics distinguish loss vs fragmentation", {

  sims <- ts_benchmark()

  loss <- sims$loss_only
  frag <- sims$fragmentation_only

  expect_lt(ts_total_time(loss), ts_total_time(frag))
  expect_gt(ts_n_periods(frag), ts_n_periods(loss))

})