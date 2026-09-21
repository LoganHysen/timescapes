#' Binary Timescape Metrics
#'
#' `timescapes` calculates mathematical summaries of binary conditions through
#' time, either for one vector or independently for every cell in a raster time
#' series.
#'
#' @keywords internal
"_PACKAGE"

.ts_registry <- list(
  total_time = .ts_total_time,
  n_periods = .ts_n_periods,
  gap_mean = .ts_gap_mean,
  gap_max = .ts_gap_max,
  duration_sd = .ts_duration_sd,
  edge_density = .ts_edge_density,
  autocorr = .ts_autocorr,
  aggregation = .ts_aggregation,
  core_time_index = .ts_core_time_index,
  n_core_periods = .ts_n_core_periods
)

.ts_validate_metric <- function(metric) {
  if (!is.character(metric) || length(metric) != 1L || is.na(metric) || !nzchar(metric)) {
    stop("`metric` must be one non-empty character string.", call. = FALSE)
  }

  if (!metric %in% names(.ts_registry)) {
    stop(
      "Unknown metric `", metric, "`. Available metrics are: ",
      paste(names(.ts_registry), collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  metric
}

.ts_validate_binary <- function(x) {
  if (!is.numeric(x) || !is.atomic(x) || !is.null(dim(x))) {
    stop("`x` must be a numeric vector.", call. = FALSE)
  }
  if (length(x) == 0L) {
    stop("`x` must contain at least one time step.", call. = FALSE)
  }
  if (any(is.nan(x))) {
    stop("`x` must contain only 0, 1, or `NA`.", call. = FALSE)
  }

  observed <- x[!is.na(x)]
  if (any(!is.finite(observed)) || any(!observed %in% c(0, 1))) {
    stop("`x` must contain only 0, 1, or `NA`.", call. = FALSE)
  }

  invisible(x)
}

.ts_validate_metric_args <- function(metric_fun, dots) {
  if (length(dots) == 0L) return(invisible(dots))

  dot_names <- names(dots)
  if (is.null(dot_names) || any(!nzchar(dot_names))) {
    stop("Metric-specific arguments in `...` must be named.", call. = FALSE)
  }
  if (anyDuplicated(dot_names)) {
    stop("Metric-specific arguments in `...` must have unique names.", call. = FALSE)
  }

  allowed <- setdiff(names(formals(metric_fun)), "x")
  unknown <- setdiff(dot_names, allowed)
  if (length(unknown) > 0L) {
    stop(
      "Unused metric argument", if (length(unknown) > 1L) "s" else "", ": ",
      paste0("`", unknown, "`", collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  if ("core_buffer" %in% dot_names) {
    .ts_validate_core_buffer(dots$core_buffer)
  }

  invisible(dots)
}

.ts_resolve_metric <- function(metric, dots = list()) {
  metric <- .ts_validate_metric(metric)
  metric_fun <- .ts_registry[[metric]]
  .ts_validate_metric_args(metric_fun, dots)
  list(name = metric, fun = metric_fun, args = dots)
}

.ts_make_calculator <- function(resolved) {
  metric_fun <- resolved$fun
  metric_args <- resolved$args

  if (length(metric_args) == 0L) {
    return(function(x) {
      .ts_validate_binary(x)
      if (anyNA(x)) return(NA_real_)
      as.numeric(metric_fun(as.integer(x)))
    })
  }

  function(x) {
    .ts_validate_binary(x)
    if (anyNA(x)) return(NA_real_)
    as.numeric(do.call(metric_fun, c(list(x = as.integer(x)), metric_args)))
  }
}

#' Calculate a binary timescape metric
#'
#' Calculates one named metric for a numeric vector in which `1` means that a
#' condition is present and `0` means that it is absent. Metric names must match
#' [ts_list_metrics()] exactly. If `x` contains any missing value, the result is
#' `NA_real_`.
#'
#' @param x A non-empty numeric vector containing only `0`, `1`, or `NA`.
#' @param metric One exact metric name returned by [ts_list_metrics()].
#' @param ... Named metric-specific arguments. `core_time_index` and
#'   `n_core_periods` accept `core_buffer`, a non-negative whole number with a
#'   default of `1`.
#'
#' @return One numeric value.
#'
#' @section Metrics:
#' Let `n` be the number of time steps, let an occupied period be a maximal run
#' of ones, and let a gap be any maximal run of zeros, including leading and
#' trailing runs.
#'
#' - `total_time`: sum of the series; range 0 to `n`.
#' - `n_periods`: number of occupied periods; range 0 to `ceiling(n / 2)`.
#' - `gap_mean`: arithmetic mean of gap lengths, or 0 when no gaps occur.
#' - `gap_max`: maximum gap length, or 0 when no gaps occur.
#' - `duration_sd`: sample standard deviation of occupied-period lengths, or 0
#'   when fewer than two occupied periods occur.
#' - `edge_density`: number of changes between adjacent time steps divided by
#'   `n - 1`; returns 0 for a one-step series.
#' - `autocorr`: Pearson correlation between steps 1 through `n - 1` and steps
#'   2 through `n`; returns `NA` when the correlation is undefined.
#' - `aggregation`: proportion of adjacent time-step pairs that are equal;
#'   returns 0 for a one-step series.
#' - `core_time_index`: proportion of occupied time remaining after removing
#'   `core_buffer` steps from both ends of every occupied period.
#' - `n_core_periods`: number of occupied periods longer than twice
#'   `core_buffer`.
#'
#' @examples
#' x <- c(1, 1, 0, 0, 1, 1, 1, 0)
#' ts_metric(x, "n_periods")
#' ts_metric(x, "gap_mean")
#' ts_metric(x, "core_time_index", core_buffer = 1)
#'
#' @export
ts_metric <- function(x, metric, ...) {
  resolved <- .ts_resolve_metric(metric, list(...))
  .ts_make_calculator(resolved)(x)
}

#' List available binary timescape metrics
#'
#' @return A character vector of exact metric names accepted by [ts_metric()]
#'   and [ts_raster_metric()].
#'
#' @examples
#' ts_list_metrics()
#'
#' @export
ts_list_metrics <- function() {
  names(.ts_registry)
}
