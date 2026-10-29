# Getting Started with timescapes

`timescapes` summarizes a binary condition through time. A value of `1`
indicates presence and `0` indicates absence. Metric names must match a
value returned by
[`ts_list_metrics()`](https://loganhysen.github.io/timescapes/reference/ts_list_metrics.md)
exactly.

## A binary vector

Here is a small example with two periods of the presence of some
condition separated by the absence of that condition. Each time step in
this case represents a year, so the first two years have the condition,
then two years of absence, followed by three more years of presence and
one year of absence.

``` r

library(timescapes)

x <- c(1, 1, 0, 0, 1, 1, 1, 0)
```

The values can be visualized as a simple timeline.

``` r

plot(
  seq_along(x), x,
  type = "s",
  ylim = c(-0.1, 1.1),
  xlab = "Time step",
  ylab = "Habitat available",
  yaxt = "n",
  main = "Binary habitat availability through time"
)
axis(2, at = c(0, 1), labels = c("No", "Yes"), las = 1)
```

![](getting-started_files/figure-html/plot-example-series-1.png)

Now, calculate a few metrics using ts_metric(), selecting from the
available list of metrics found by using ts_list_metrics().

``` r

ts_list_metrics()
#>  [1] "total_time"      "n_periods"       "gap_mean"        "gap_max"        
#>  [5] "duration_sd"     "edge_density"    "autocorr"        "aggregation"    
#>  [9] "core_time_index" "n_core_periods"
ts_metric(x, "total_time")
#> [1] 5
ts_metric(x, "n_periods")
#> [1] 2
ts_metric(x, "gap_mean")
#> [1] 1.5
```

Time steps are unitless ordered observations with a duration defined by
the user. Gap metrics include leading and trailing absence runs by
default. Set `include_boundary_gaps = FALSE` to count only gaps between
presence periods; no qualifying gaps returns 0, including for an
all-absence series.

For core metrics, supply `min_core_period`, a positive whole number of
time steps. A presence run qualifies when its full length is at least
this threshold. `core_time_index` divides the total length of qualifying
runs by total presence time (0 if there is no presence);
`n_core_periods` counts qualifying runs. Omitting the threshold uses 15
time steps and issues one warning per vector or raster call. The former
`core_buffer` argument is no longer accepted.

For example:

``` r

ts_metric(x, "core_time_index", min_core_period = 3)
#> [1] 0.6
ts_metric(x, "n_core_periods", min_core_period = 3)
#> [1] 1
```

Every observed value must be `0` or `1`. A series containing a missing
time step produces `NA`, because removing or reinterpreting that step
could change the temporal pattern.

``` r

ts_metric(c(1, 1, NA, 0), "n_periods")
#> [1] NA
```

## A raster time series

A
[`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
can represent the same type of series at many locations. Layers are
treated as ordered time steps.

``` r

library(terra)
#> terra 1.9.50

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
values(periods)
#>      n_periods
#> [1,]         2
#> [2,]         0
#> [3,]         2
#> [4,]         1
```

The result is a one-layer raster with the same geometry as the input.
Raster cells containing missing or non-binary values follow the same
validation rules as vector inputs.

## Citation

Wan, H. Y. (2025). It’s about time: Temporal fragmentation and metrics
for habitat change. *Landscape Ecology*, 40, 226.
<https://doi.org/10.1007/s10980-025-02252-4>
