
.ts_registry <- list(
  total_time = ts_total_time,
  n_periods = ts_n_periods,
  gap_mean = ts_gap_mean,
  gap_max = ts_gap_max,
  duration_sd = ts_duration_sd,
  edge_density = ts_edge_density,
  autocorr = ts_autocorr,
  aggregation = ts_aggregation,
  core_time_index = ts_core_time_index,
  n_core_periods = ts_n_core_periods
)

#' Calculate a single named timescape metric
#'
#' @param x Binary time series (0/1)
#' @param metric Metric name
#' @return Numeric value
#' @export
ts_metric <- function(x, metric) {
  if (!is.character(metric) || length(metric) != 1L || is.na(metric)) {
    stop("`metric` must be a single metric name.", call. = FALSE)
  }

  if (!metric %in% names(.ts_registry)) {
    stop("Unknown metric: ", metric, call. = FALSE)
  }

  .ts_registry[[metric]](x)
}

#' Calculate multiple timescape metrics
#'
#' @param x Binary time series (0/1)
#' @param metrics Character vector of metric names
#' @return Named numeric vector
#' @export
ts_metrics <- function(x, metrics = names(.ts_registry)) {
  if (!is.character(metrics) || anyNA(metrics)) {
    stop("`metrics` must be a character vector of metric names.", call. = FALSE)
  }

  stats::setNames(
    vapply(metrics, function(metric) ts_metric(x, metric), numeric(1)),
    metrics
  )
}
