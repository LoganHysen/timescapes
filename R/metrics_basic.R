# ================================
# Basic temporal metrics
# ================================

#' Total habitat time
#'
#' @param x Binary time series (0/1)
#' @return Integer
#' @export
ts_total_time <- function(x) {
  if (.ts_invalid_binary(x)) return(NA_real_)
  x <- as.integer(x)
  as.integer(sum(x, na.rm = TRUE))
}

#' Temporal edge density
#'
#' @param x Binary time series (0/1)
#' @return Numeric
#' @export
ts_edge_density <- function(x) {
  if (.ts_invalid_binary(x)) return(NA_real_)
  x <- as.integer(x)
  if (length(x) < 2) return(0)
  sum(abs(diff(x))) / (length(x) - 1)
}

#' Temporal aggregation
#'
#' @param x Binary time series (0/1)
#' @return Numeric (0–1)
#' @export
ts_aggregation <- function(x) {
  if (.ts_invalid_binary(x)) return(NA_real_)
  x <- as.integer(x)
  if (length(x) < 2) return(0)
  mean(x[-length(x)] == x[-1])
}

#' Lag-1 temporal autocorrelation
#'
#' @param x Numeric time series
#' @return Numeric
#' @export
ts_autocorr <- function(x) {
  if (.ts_invalid_binary(x)) return(NA_real_)
  lag1_autocorr(x)
}
