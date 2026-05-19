#' Create benchmark temporal scenarios
#'
#' @param n Integer length of time series
#' @return List of named binary vectors
#' @export
ts_benchmark <- function(n = 100) {

  # Continuous
  S1_continuous <- c(rep(0, 20), rep(1, 60), rep(0, 20))

  # Loss only (shorter duration)
  S2_loss <- c(rep(0, 30), rep(1, 40), rep(0, 30))

  # Fragmentation only (same total as S2, split)
  S3_fragmentation <- c(
    rep(0, 20),
    rep(1, 30),
    rep(0, 10),
    rep(1, 30),
    rep(0, 10)
  )

  # Loss + fragmentation
  S4_loss_frag <- c(
    rep(0, 30),
    rep(1, 15),
    rep(0, 15),
    rep(1, 15),
    rep(0, 25)
  )

  # Irregular
  set.seed(1)
  S5_irregular <- rbinom(n, 1, prob = 0.4)

  list(
    continuous = S1_continuous,
    loss_only = S2_loss,
    fragmentation_only = S3_fragmentation,
    loss_fragmentation = S4_loss_frag,
    irregular = S5_irregular
  )
}

#' Compute metrics for benchmark scenarios
#' @export
ts_benchmark_metrics <- function() {

  sims <- ts_benchmark()

  do.call(
    rbind,
    lapply(names(sims), function(name) {
      x <- sims[[name]]
      res <- ts_metrics(x)
      data.frame(
        scenario = name,
        t(res),
        row.names = NULL
      )
    })
  )
}