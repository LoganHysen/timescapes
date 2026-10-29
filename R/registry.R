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

  if ("min_core_period" %in% dot_names) {
    .ts_validate_min_core_period(dots$min_core_period)
  }

  if ("include_boundary_gaps" %in% dot_names) {
    .ts_validate_boundary_gaps(dots$include_boundary_gaps)
  }

  invisible(dots)
}

.ts_resolve_metric <- function(metric, dots = list()) {
  metric <- .ts_validate_metric(metric)
  metric_fun <- .ts_registry[[metric]]
  .ts_validate_metric_args(metric_fun, dots)
  if (metric %in% c("core_time_index", "n_core_periods") &&
      !"min_core_period" %in% names(dots)) {
    warning("`min_core_period` was omitted; using 15 time steps as the core period.",
            call. = FALSE)
    dots$min_core_period <- 15L
  }
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
#'   `n_core_periods` accept `min_core_period`, a positive whole number of time
#'   steps. If omitted, 15 is used with a warning once per call. `gap_mean` and
#'   `gap_max` accept `include_boundary_gaps` (default `TRUE`); set it to `FALSE`
#'   to count only absence runs between presence periods.
#'
#' @return One numeric value.
#'
#' @section Metrics:
#' Let `n` be the number of time steps, let an occupied period be a maximal run
#' of ones, and let a gap be any maximal run of zeros, including leading and
#' trailing runs by default. With `include_boundary_gaps = FALSE`, only gaps
#' between presence periods count. No qualifying gaps (including an all-zero
#' series with boundary gaps excluded) returns 0.
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
#' - `core_time_index`: proportion of occupied time in presence runs whose full
#'   length is at least `min_core_period`; returns 0 when no presence occurs.
#' - `n_core_periods`: number of such qualifying presence runs.
#'
#' Time steps are unitless ordered observations; their duration is user-defined.
#'
#' @references Wan, H. Y. (2025). It's about time: Temporal fragmentation and
#'   metrics for habitat change. Landscape Ecology, 40, 226.
#'   \doi{10.1007/s10980-025-02252-4}
#'
#' @examples
#' x <- c(1, 1, 0, 0, 1, 1, 1, 0)
#' ts_metric(x, "n_periods")
#' ts_metric(x, "gap_mean")
#' ts_metric(x, "core_time_index", min_core_period = 3)
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
