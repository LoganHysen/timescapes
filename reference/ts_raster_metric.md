# Calculate a binary timescape metric for each raster cell

Applies one named timescape metric independently to every cell of a
[`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html),
treating its layers as ordered time steps. Raster cells must contain
only `0`, `1`, or `NA` through time. A cell containing any `NA` receives
an `NA` result.

## Usage

``` r
ts_raster_metric(r, metric, ...)
```

## Arguments

- r:

  A
  [`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
  whose layers are ordered time steps.

- metric:

  One exact metric name returned by
  [`ts_list_metrics()`](https://loganhysen.github.io/timescapes/reference/ts_list_metrics.md).

- ...:

  Named metric-specific arguments passed to
  [`ts_metric()`](https://loganhysen.github.io/timescapes/reference/ts_metric.md),
  including `include_boundary_gaps = TRUE` for gap metrics and a
  positive whole number `min_core_period` for core metrics. Omitting
  `min_core_period` uses 15 time steps and warns once per raster call,
  rather than once per cell.

## Value

A one-layer
[`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
containing the selected metric.

## Examples

``` r
r <- terra::rast(nrows = 2, ncols = 2, nlyrs = 4)
terra::values(r) <- matrix(
  c(
    1, 1, 0, 1,
    0, 0, 0, 0,
    1, 0, 1, 0,
    1, 1, 1, 1
  ),
  nrow = terra::ncell(r),
  byrow = TRUE
)
ts_raster_metric(r, "n_periods")
#> class       : SpatRaster
#> size        : 2, 2, 1  (nrow, ncol, nlyr)
#> resolution  : 180, 90  (x, y)
#> extent      : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (CRS84) (OGC:CRS84)
#> source(s)   : memory
#> name        : n_periods
#> min value   :         0
#> max value   :         2
```
