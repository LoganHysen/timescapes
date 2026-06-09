#' Calculate a temporal metric for each raster cell
#'
#' `ts_raster_metric()` applies a named timescape metric to each cell of a
#' `terra::SpatRaster`, treating raster layers as ordered time steps.
#'
#' @param r A `terra::SpatRaster` with layers representing time steps.
#' @param metric A single character string naming a metric in the timescape
#'   metric registry.
#' @param classes Optional vector of raster values to calculate separately. If
#'   `NULL`, raster values are assumed to already be binary `0`/`1`. If
#'   provided, one output layer is returned for each class, with that class
#'   treated as presence.
#' @param ... Additional arguments passed to the selected metric function.
#'
#' @return A `terra::SpatRaster` where each cell contains the metric value
#'   computed across time. If `classes` is `NULL`, the result has one layer. If
#'   `classes` is provided, the result has one layer per class.
#'
#' @examples
#' if (requireNamespace("terra", quietly = TRUE)) {
#'   r <- terra::rast(nrows = 10, ncols = 10, nlyrs = 5)
#'   terra::values(r) <- sample(c(0, 1), terra::ncell(r) * 5, replace = TRUE)
#'   ts_raster_metric(r, "n_periods")
#'
#'   r_classes <- terra::rast(nrows = 10, ncols = 10, nlyrs = 5)
#'   terra::values(r_classes) <- sample(1:3, terra::ncell(r_classes) * 5, replace = TRUE)
#'   ts_raster_metric(r_classes, "n_periods", classes = c(1, 2, 3))
#' }
#'
#' @export
ts_raster_metric <- function(r, metric, classes = NULL, ...) {
  if (!requireNamespace("terra", quietly = TRUE)) {
    stop("Package `terra` is required for `ts_raster_metric()`.", call. = FALSE)
  }

  if (!inherits(r, "SpatRaster")) {
    stop("`r` must be a terra::SpatRaster.", call. = FALSE)
  }

  metric <- .ts_validate_metric(metric)

  if (!is.null(classes) && (!is.vector(classes) || length(classes) == 0L)) {
    stop("`classes` must be a non-empty vector.", call. = FALSE)
  }

  metric_fun <- .ts_registry[[metric]]
  dots <- list(...)

  calculate_metric <- function(x) {
    if (length(dots) == 0L) {
      return(as.numeric(metric_fun(x)))
    }

    as.numeric(do.call(metric_fun, c(list(x), dots)))
  }

  result <- terra::app(r, fun = function(x) {
    if (is.null(classes)) {
      return(calculate_metric(x))
    }

    vapply(classes, function(class) {
      x_class <- as.integer(x == class)
      calculate_metric(x_class)
    }, numeric(1))
  })

  if (!is.null(classes)) {
    names(result) <- make.unique(paste0(metric, "_class_", classes))
  }

  result
}
