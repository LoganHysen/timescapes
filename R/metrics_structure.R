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
  rr <- get_runs(x)
  gaps <- rr$gap_runs
  if (is.null(gaps) || nrow(gaps) == 0) return(0)
  mean(gaps$end - gaps$start + 1)
}

#' Maximum gap length
#'
#' @param x Binary time series (0/1)
#' @return Integer
#' @export
ts_gap_max <- function(x) {
  if (.ts_invalid_binary(x)) return(NA_real_)
  rr <- get_runs(x)
  gaps <- rr$gap_runs
  if (is.null(gaps) || nrow(gaps) == 0) return(0L)
  as.integer(max(gaps$end - gaps$start + 1))
}

#' Duration variability (SD of run lengths)
#'
#' @param x Binary time series (0/1)
#' @return Numeric
#' @export
ts_duration_sd <- function(x) {
  if (.ts_invalid_binary(x)) return(NA_real_)
  rr <- get_runs(x)
  runs <- rr$one_runs
  if (is.null(runs) || nrow(runs) < 2) return(0)
  sd(runs$end - runs$start + 1)
}

#' Core time index
#'
#' @param x Binary time series (0/1)
#' @param core_buffer Integer buffer
#' @return Numeric (0–1)
#' @export
ts_core_time_index <- function(x, core_buffer = 1L) {
  if (.ts_invalid_binary(x)) return(NA_real_)
  rr <- get_runs(x)
  runs <- rr$one_runs
  if (is.null(runs)) return(0)

  lengths <- runs$end - runs$start + 1
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
  rr <- get_runs(x)
  runs <- rr$one_runs
  if (is.null(runs)) return(0L)

  lengths <- runs$end - runs$start + 1
  as.integer(sum(lengths > 2L * core_buffer))
}
