
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

.ts_match_metric <- function(metric) {
  metric_names <- names(.ts_registry)

  exact_match <- match(metric, metric_names, nomatch = 0L)
  if (exact_match > 0L) return(metric_names[[exact_match]])

  partial_matches <- grep(metric, metric_names, fixed = TRUE, value = TRUE)
  if (length(partial_matches) > 0L) return(partial_matches[[1L]])

  stop(
    "Unknown metric: `", metric, "`. Available metrics are: ",
    paste(metric_names, collapse = ", "),
    call. = FALSE
  )
}

.ts_validate_metric <- function(metric) {
  if (!is.character(metric) || length(metric) != 1L || is.na(metric) || !nzchar(metric)) {
    stop("`metric` must be a single non-empty metric name.", call. = FALSE)
  }

  .ts_match_metric(metric)
}

.ts_validate_metrics <- function(metrics) {
  if (!is.character(metrics) || anyNA(metrics) || any(!nzchar(metrics))) {
    stop("`metrics` must be a character vector of non-empty metric names.", call. = FALSE)
  }

  vapply(metrics, .ts_match_metric, character(1), USE.NAMES = FALSE)
}

#' Calculate a single named timescape metric
#'
#' @param x Binary time series (0/1)
#' @param metric Metric name
#' @return Numeric value
#' @export
ts_metric <- function(x, metric) {
  metric <- .ts_validate_metric(metric)

  .ts_registry[[metric]](x)
}

#' Calculate multiple timescape metrics
#'
#' @param x Binary time series (0/1)
#' @param metrics Character vector of metric names
#' @return Named numeric vector
#' @export
ts_metrics <- function(x, metrics = names(.ts_registry)) {
  metrics <- .ts_validate_metrics(metrics)

  stats::setNames(
    vapply(metrics, function(metric) ts_metric(x, metric), numeric(1)),
    metrics
  )
}
