# timescape

`timescape` is an R package for calculating simple temporal landscape
metrics from binary time series and raster time stacks.

The package is currently in active development. It is ready to experiment with,
but the metric definitions and function names may still change.

## Installation

Install the development version from GitHub:

```r
# install.packages("remotes")
remotes::install_github("LoganHysen/timescape")
```

Or, if you have cloned the repository locally:

```r
# install.packages("devtools")
devtools::load_all()
```

## Basic Use

Timescape metrics are calculated from binary time series, where `1` indicates
presence and `0` indicates absence.

```r
library(timescape)

x <- c(1, 1, 0, 0, 1, 1, 1, 0)

ts_metrics(x)
ts_metric(x, "n_periods")
ts_metric(x, "gap_mean")
```

Available metrics include:

- `total_time`: total number of time steps with presence
- `n_periods`: number of presence periods
- `gap_mean`: mean absence gap length
- `gap_max`: maximum absence gap length
- `duration_sd`: standard deviation of presence-period durations
- `edge_density`: rate of temporal transitions between `0` and `1`
- `autocorr`: lag-1 temporal autocorrelation
- `aggregation`: proportion of neighboring time steps with the same value
- `core_time_index`: proportion of presence time away from period edges
- `n_core_periods`: number of presence periods longer than the core buffer

## Raster Time Stacks

Raster layers can be treated as ordered time steps. `ts_raster_metric()` applies
a metric to each cell through time.

```r
library(terra)
library(timescape)

r <- rast(nrows = 10, ncols = 10, nlyrs = 5)
values(r) <- sample(c(0, 1), ncell(r) * nlyr(r), replace = TRUE)

n_periods_map <- ts_raster_metric(r, "n_periods")
plot(n_periods_map)
```

For categorical rasters, pass one or more classes. Each class is converted to a
binary presence/absence series before the metric is calculated.

```r
r_classes <- rast(nrows = 10, ncols = 10, nlyrs = 5)
values(r_classes) <- sample(1:3, ncell(r_classes) * nlyr(r_classes), replace = TRUE)

class_maps <- ts_raster_metric(r_classes, "n_periods", classes = c(1, 2, 3))
plot(class_maps)
```

## Example Scripts

Additional scripts are available in `inst/scripts/`:

- `demo.R`: small vector examples
- `raster_testing_simple.R`: simple raster examples
- `raster_testing_multiclass.R`: categorical raster examples
- `raster_benchmark.R`: basic timing benchmark for raster metrics

## Development

Run the test suite with:

```r
devtools::test()
```

Run a package check with:

```r
devtools::check()
```
