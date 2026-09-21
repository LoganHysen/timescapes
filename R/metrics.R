.ts_run_lengths <- function(x, value) {
  is_value <- x == value
  changes <- diff(c(FALSE, is_value, FALSE))
  starts <- which(changes == 1L)
  ends <- which(changes == -1L) - 1L

  as.integer(ends - starts + 1L)
}

.ts_validate_core_buffer <- function(core_buffer) {
  if (
    !is.numeric(core_buffer) ||
      length(core_buffer) != 1L ||
      is.na(core_buffer) ||
      !is.finite(core_buffer) ||
      core_buffer < 0 ||
      core_buffer > .Machine$integer.max ||
      core_buffer != floor(core_buffer)
  ) {
    stop("`core_buffer` must be one non-negative whole number.", call. = FALSE)
  }

  as.integer(core_buffer)
}

.ts_total_time <- function(x) {
  as.integer(sum(x))
}

.ts_n_periods <- function(x) {
  as.integer(sum(diff(c(0L, x)) == 1L))
}

.ts_gap_mean <- function(x) {
  gaps <- .ts_run_lengths(x, 0L)
  if (length(gaps) == 0L) return(0)
  mean(gaps)
}

.ts_gap_max <- function(x) {
  gaps <- .ts_run_lengths(x, 0L)
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

.ts_core_time_index <- function(x, core_buffer = 1L) {
  core_buffer <- .ts_validate_core_buffer(core_buffer)
  lengths <- .ts_run_lengths(x, 1L)
  if (length(lengths) == 0L) return(0)

  total <- sum(x)
  if (total == 0L) return(0)

  core_lengths <- pmax(lengths - 2L * core_buffer, 0L)
  sum(core_lengths) / total
}

.ts_n_core_periods <- function(x, core_buffer = 1L) {
  core_buffer <- .ts_validate_core_buffer(core_buffer)
  lengths <- .ts_run_lengths(x, 1L)
  if (length(lengths) == 0L) return(0L)

  as.integer(sum(lengths > 2L * core_buffer))
}
