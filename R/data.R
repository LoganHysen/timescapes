#' Bear River example water timescape
#'
#' A small 26-layer binary water-presence raster from Bear River Migratory Bird
#' Refuge, Utah. Layers are biweekly time steps from 2023 and were created from
#' Great Salt Lake water-probability rasters using a `>= 0.5` threshold.
#'
#' This object is a packed `terra::SpatRaster`. Use `terra::rast()` to unpack it.
#'
#' @format A packed `terra::SpatRaster` with 200 rows, 200 columns, and 26 layers.
#' @source In-house Great Salt Lake water-probability rasters.
#' @examples
#' if (requireNamespace("terra", quietly = TRUE)) {
#'   data(gsl_bear_river_water)
#'   water <- terra::rast(gsl_bear_river_water)
#'   ts_raster_metric(water, "n_periods")
#' }
"gsl_bear_river_water"

#' Bear River example refuge boundary
#'
#' The cropped Bear River Migratory Bird Refuge boundary corresponding to
#' `gsl_bear_river_water`.
#'
#' This object is a packed `terra::SpatVector`. Use `terra::vect()` to unpack it.
#'
#' @format A packed `terra::SpatVector` polygon.
#' @source FWS Interest simplified authoritative boundary.
#' @examples
#' if (requireNamespace("terra", quietly = TRUE)) {
#'   data(gsl_bear_river_refuge)
#'   refuge <- terra::vect(gsl_bear_river_refuge)
#'   refuge
#' }
"gsl_bear_river_refuge"
