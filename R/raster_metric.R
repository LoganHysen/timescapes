#' Calculate a temporal metric for each raster cell
#'
#' `ts_raster_metric()` applies a named timescape metric to each cell of a
#' `terra::SpatRaster`, treating raster layers as ordered time steps.
#'
#' @param r A `terra::SpatRaster` with layers representing time steps.
#' @param metric A single character string naming a metric in the timescape
#'   metric registry.
#' @param classes Optional vector of raster values to treat as presence. If
#'   `NULL`, raster values are assumed to already be binary `0`/`1`.
#' @param ... Additional arguments passed to the selected metric function.
#'
#' @return A single-layer `terra::SpatRaster` where each cell contains the
#'   metric value computed across time.
#'
#' @examples
#' if (requireNamespace("terra", quietly = TRUE)) {
#'   r <- terra::rast(nrows = 10, ncols = 10, nlyrs = 5)
#'   terra::values(r) <- sample(c(0, 1), terra::ncell(r) * 5, replace = TRUE)
#'   ts_raster_metric(r, "n_periods")
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

  if (!is.null(classes) && !is.vector(classes)) {
    stop("`classes` must be a vector.", call. = FALSE)
  }

  metric_fun <- .ts_registry[[metric]]
  dots <- list(...)

  terra::app(r, fun = function(x) {
    if (!is.null(classes)) {
      x <- ifelse(is.na(x), NA_integer_, as.integer(x %in% classes))
    }

    if (length(dots) == 0L) {
      return(as.numeric(ts_metric(x, metric)))
    }

    as.numeric(do.call(metric_fun, c(list(x), dots)))
  })
}
