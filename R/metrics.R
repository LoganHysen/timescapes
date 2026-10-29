.ts_run_lengths <- function(x, value) {
  is_value <- x == value
  changes <- diff(c(FALSE, is_value, FALSE))
  starts <- which(changes == 1L)
  ends <- which(changes == -1L) - 1L

  as.integer(ends - starts + 1L)
}

.ts_validate_min_core_period <- function(min_core_period) {
  if (
    !is.numeric(min_core_period) ||
      length(min_core_period) != 1L ||
      is.na(min_core_period) ||
      !is.finite(min_core_period) ||
      min_core_period < 1 ||
      min_core_period > .Machine$integer.max ||
      min_core_period != floor(min_core_period)
  ) {
    stop("`min_core_period` must be one positive whole number.", call. = FALSE)
  }

  as.integer(min_core_period)
}

.ts_total_time <- function(x) {
  as.integer(sum(x))
}

.ts_n_periods <- function(x) {
  as.integer(sum(diff(c(0L, x)) == 1L))
}

.ts_gap_mean <- function(x, include_boundary_gaps = TRUE) {
  gaps <- .ts_gap_lengths(x, include_boundary_gaps)
  if (length(gaps) == 0L) return(0)
  mean(gaps)
}

.ts_gap_max <- function(x, include_boundary_gaps = TRUE) {
  gaps <- .ts_gap_lengths(x, include_boundary_gaps)
  if (length(gaps) == 0L) return(0L)
  as.integer(max(gaps))
}

.ts_duration_sd <- function(x) {
  runs <- .ts_run_lengths(x, 1L)
  if (length(runs) < 2L) return(0)
  stats::sd(runs)
}

.ts_edge_density <- function(x) {
  if (length(x) < 2L) return(0)
  sum(abs(diff(x))) / (length(x) - 1L)
}

.ts_autocorr <- function(x) {
  if (length(x) < 3L) return(NA_real_)

  previous <- x[-length(x)]
  following <- x[-1L]
  if (length(unique(previous)) < 2L || length(unique(following)) < 2L) {
    return(NA_real_)
  }

  stats::cor(previous, following)
}

.ts_aggregation <- function(x) {
  if (length(x) < 2L) return(0)
  mean(x[-length(x)] == x[-1L])
}

.ts_core_time_index <- function(x, min_core_period = 15L) {
  min_core_period <- .ts_validate_min_core_period(min_core_period)
  lengths <- .ts_run_lengths(x, 1L)
  if (length(lengths) == 0L) return(0)

  total <- sum(x)
  if (total == 0L) return(0)

  core_lengths <- lengths[lengths >= min_core_period]
  sum(core_lengths) / total
}

.ts_n_core_periods <- function(x, min_core_period = 15L) {
  min_core_period <- .ts_validate_min_core_period(min_core_period)
  lengths <- .ts_run_lengths(x, 1L)
  if (length(lengths) == 0L) return(0L)

  as.integer(sum(lengths >= min_core_period))
}

.ts_validate_boundary_gaps <- function(include_boundary_gaps) {
  if (!is.logical(include_boundary_gaps) ||
      length(include_boundary_gaps) != 1L || is.na(include_boundary_gaps)) {
    stop("`include_boundary_gaps` must be TRUE or FALSE.", call. = FALSE)
  }
  invisible(include_boundary_gaps)
}

.ts_gap_lengths <- function(x, include_boundary_gaps) {
  .ts_validate_boundary_gaps(include_boundary_gaps)
  if (!include_boundary_gaps) {
    present <- which(x == 1L)
    if (length(present) == 0L) return(integer())
    x <- x[seq.int(present[1L], present[length(present)])]
  }
  .ts_run_lengths(x, 0L)
}
