# timescapes

`timescapes` calculates interpretable metrics for binary conditions observed
through time. A `1` means that a condition is present and a `0` means that it
is absent. The same metrics can be applied to a single vector or independently
to every cell in a raster time series.

## Installation

Install the stable version via CRAN with:

```r
install.packages("timescapes")
```

You can also install the development version from GitHub:

```r
remotes::install_github("LoganHysen/timescapes")
```

## Vector metrics

Calculate one metric by supplying an exact name from `ts_list_metrics()`:

```r
library(timescapes)

x <- c(1, 1, 0, 0, 1, 1, 1, 0)

ts_list_metrics()
ts_metric(x, "n_periods")
ts_metric(x, "gap_mean")
ts_metric(x, "core_time_index", core_buffer = 1)
```

The available metrics are:

- `total_time`: number of time steps with presence
- `n_periods`: number of distinct presence periods
- `gap_mean`: mean length of absence periods
- `gap_max`: maximum length of an absence period
- `duration_sd`: variability in presence-period lengths
- `edge_density`: proportion of adjacent steps that change state
- `autocorr`: lag-1 Pearson autocorrelation
- `aggregation`: proportion of adjacent steps with the same state
- `core_time_index`: proportion of presence time away from period edges
- `n_core_periods`: number of presence periods containing core time

Metric names must match exactly. Inputs must be non-empty numeric vectors
containing only `0`, `1`, or `NA`. If any time step is missing, the metric is
`NA`.

## Raster metrics

For a `terra::SpatRaster`, layers are treated as ordered time steps and the
metric is calculated independently for every cell:

```r
library(terra)
library(timescapes)

r <- rast(nrows = 2, ncols = 2, nlyrs = 4)
values(r) <- matrix(
  c(
    1, 1, 0, 1,
    0, 0, 0, 0,
    1, 0, 1, 0,
    1, 1, 1, 1
  ),
  nrow = ncell(r),
  byrow = TRUE
)

periods <- ts_raster_metric(r, "n_periods")
plot(periods)
```

Raster values must also be binary. A cell with one or more missing time steps
receives an `NA` result.

## Vignettes



## Development

Run the tests and CRAN checks with:

```r
testthat::test_local()
devtools::check(args = "--as-cran")
```

## License

This package is licensed under the **MIT License** (see the [LICENSE](LICENSE) file).

## Citation

If you use `timescapes` in published work, please cite it as:

TBD

## Authors

Logan Hysen: hysenlog@msu.edu
Ho Yi Wan: hoyiwan@gmail.com

