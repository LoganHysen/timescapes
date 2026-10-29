# List available binary timescape metrics

List available binary timescape metrics

## Usage

``` r
ts_list_metrics()
```

## Value

A character vector of exact metric names accepted by
[`ts_metric()`](https://loganhysen.github.io/timescapes/reference/ts_metric.md)
and
[`ts_raster_metric()`](https://loganhysen.github.io/timescapes/reference/ts_raster_metric.md).

## Examples

``` r
ts_list_metrics()
#>  [1] "total_time"      "n_periods"       "gap_mean"        "gap_max"        
#>  [5] "duration_sd"     "edge_density"    "autocorr"        "aggregation"    
#>  [9] "core_time_index" "n_core_periods" 
```
