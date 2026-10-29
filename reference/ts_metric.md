# Calculate a binary timescape metric

Calculates one named metric for a numeric vector in which `1` means that
a condition is present and `0` means that it is absent. Metric names
must match
[`ts_list_metrics()`](https://loganhysen.github.io/timescapes/reference/ts_list_metrics.md)
exactly. If `x` contains any missing value, the result is `NA_real_`.

## Usage

``` r
ts_metric(x, metric, ...)
```

## Arguments

- x:

  A non-empty numeric vector containing only `0`, `1`, or `NA`.

- metric:

  One exact metric name returned by
  [`ts_list_metrics()`](https://loganhysen.github.io/timescapes/reference/ts_list_metrics.md).

- ...:

  Named metric-specific arguments. `core_time_index` and
  `n_core_periods` accept `min_core_period`, a positive whole number of
  time steps. If omitted, 15 is used with a warning once per call.
  `gap_mean` and `gap_max` accept `include_boundary_gaps` (default
  `TRUE`); set it to `FALSE` to count only absence runs between presence
  periods.

## Value

One numeric value.

## Metrics

Let `n` be the number of time steps, let an occupied period be a maximal
run of ones, and let a gap be any maximal run of zeros, including
leading and trailing runs by default. With
`include_boundary_gaps = FALSE`, only gaps between presence periods
count. No qualifying gaps (including an all-zero series with boundary
gaps excluded) returns 0.

- `total_time`: sum of the series; range 0 to `n`.

- `n_periods`: number of occupied periods; range 0 to `ceiling(n / 2)`.

- `gap_mean`: arithmetic mean of gap lengths, or 0 when no gaps occur.

- `gap_max`: maximum gap length, or 0 when no gaps occur.

- `duration_sd`: sample standard deviation of occupied-period lengths,
  or 0 when fewer than two occupied periods occur.

- `edge_density`: number of changes between adjacent time steps divided
  by `n - 1`; returns 0 for a one-step series.

- `autocorr`: Pearson correlation between steps 1 through `n - 1` and
  steps 2 through `n`; returns `NA` when the correlation is undefined.

- `aggregation`: proportion of adjacent time-step pairs that are equal;
  returns 0 for a one-step series.

- `core_time_index`: proportion of occupied time in presence runs whose
  full length is at least `min_core_period`; returns 0 when no presence
  occurs.

- `n_core_periods`: number of such qualifying presence runs.

Time steps are unitless ordered observations; their duration is
user-defined.

## References

Wan, H. Y. (2025). It's about time: Temporal fragmentation and metrics
for habitat change. Landscape Ecology, 40, 226.
[doi:10.1007/s10980-025-02252-4](https://doi.org/10.1007/s10980-025-02252-4)

## Examples

``` r
x <- c(1, 1, 0, 0, 1, 1, 1, 0)
ts_metric(x, "n_periods")
#> [1] 2
ts_metric(x, "gap_mean")
#> [1] 1.5
ts_metric(x, "core_time_index", min_core_period = 3)
#> [1] 0.6
```
