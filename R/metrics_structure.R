# ================================
# Structural / run-based metrics
# ================================

#' Number of occupancy periods
#'
#' @param x Binary time series (0/1)
#' @return Integer
#' @export
ts_n_periods <- function(x) {
  if (.ts_invalid_binary(x)) return(NA_real_)
  x <- as.integer(x)
  x[is.na(x)] <- 0L
  as.integer(sum(diff(c(0L, x)) == 1L))
}

#' Mean gap length
#'
#' @param x Binary time series (0/1)
#' @return Numeric
#' @export
ts_gap_mean <- function(x) {
  if (.ts_invalid_binary(x)) return(NA_real_)
  gaps <- .ts_run_lengths(x, 0L)
  if (length(gaps) == 0L) return(0)
  mean(gaps)
}

#' Maximum gap length
#'
#' @param x Binary time series (0/1)
#' @return Integer
#' @export
ts_gap_max <- function(x) {
  if (.ts_invalid_binary(x)) return(NA_real_)
  gaps <- .ts_run_lengths(x, 0L)
  if (length(gaps) == 0L) return(0L)
  as.integer(max(gaps))
}

#' Duration variability (SD of run lengths)
#'
#' @param x Binary time series (0/1)
#' @return Numeric
#' @export
ts_duration_sd <- function(x) {
  if (.ts_invalid_binary(x)) return(NA_real_)
  runs <- .ts_run_lengths(x, 1L)
  if (length(runs) < 2L) return(0)
  sd(runs)
}

#' Core time index
#'
#' @param x Binary time series (0/1)
#' @param core_buffer Integer buffer
#' @return Numeric (0–1)
#' @export
ts_core_time_index <- function(x, core_buffer = 1L) {
  if (.ts_invalid_binary(x)) return(NA_real_)
  lengths <- .ts_run_lengths(x, 1L)
  if (length(lengths) == 0L) return(0)

  core_lengths <- pmax(lengths - 2L * core_buffer, 0)

  total <- sum(x, na.rm = TRUE)
  if (total == 0) return(0)

  sum(core_lengths) / total
}

#' Number of core periods
#'
#' @param x Binary time series (0/1)
#' @param core_buffer Integer buffer
#' @return Integer
#' @export
ts_n_core_periods <- function(x, core_buffer = 1L) {
  if (.ts_invalid_binary(x)) return(NA_real_)
  lengths <- .ts_run_lengths(x, 1L)
  if (length(lengths) == 0L) return(0L)

  as.integer(sum(lengths > 2L * core_buffer))
}
