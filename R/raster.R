#' Calculate a binary timescape metric for each raster cell
#'
#' Applies one named timescape metric independently to every cell of a
#' `terra::SpatRaster`, treating its layers as ordered time steps. Raster cells
#' must contain only `0`, `1`, or `NA` through time. A cell containing any `NA`
#' receives an `NA` result.
#'
#' @param r A `terra::SpatRaster` whose layers are ordered time steps.
#' @param metric One exact metric name returned by [ts_list_metrics()].
#' @param ... Named metric-specific arguments passed to [ts_metric()].
#'
#' @return A one-layer `terra::SpatRaster` containing the selected metric.
#'
#' @examples
#' r <- terra::rast(nrows = 2, ncols = 2, nlyrs = 4)
#' terra::values(r) <- matrix(
#'   c(
#'     1, 1, 0, 1,
#'     0, 0, 0, 0,
#'     1, 0, 1, 0,
#'     1, 1, 1, 1
#'   ),
#'   nrow = terra::ncell(r),
#'   byrow = TRUE
#' )
#' ts_raster_metric(r, "n_periods")
#'
#' @export
ts_raster_metric <- function(r, metric, ...) {
  if (!inherits(r, "SpatRaster")) {
    stop("`r` must be a terra::SpatRaster.", call. = FALSE)
  }
  if (terra::nlyr(r) == 0L) {
    stop("`r` must contain at least one time layer.", call. = FALSE)
  }

  resolved <- .ts_resolve_metric(metric, list(...))
  calculate_cell <- .ts_make_calculator(resolved)

  result <- terra::app(r, fun = calculate_cell)
  names(result) <- resolved$name
  result
}
