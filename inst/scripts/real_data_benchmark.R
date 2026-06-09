# Script Goal: Benchmark Timescape metric calculation on real data
# from the Bear River Migratory Bird Refuge.

if (requireNamespace("pkgload", quietly = TRUE)) {
  pkgload::load_all()
} else {
  library(timescapemetrics)
}

library(terra)

data("gsl_bear_river_water", package = "timescapemetrics")
data("gsl_bear_river_refuge", package = "timescapemetrics")

binary_stack <- rast(gsl_bear_river_water)
bear_river <- vect(gsl_bear_river_refuge)
binary_stack <- ifel(is.na(binary_stack), 0, binary_stack)

message(
  "Loaded packaged Bear River dataset: ",
  nrow(binary_stack), " rows x ",
  ncol(binary_stack), " columns x ",
  nlyr(binary_stack), " layers"
)

timescape_metrics <- ts_list_metrics()

# initialize list to store metric rasters and data frame to store timings
timescape_metric_rasters <- vector("list", length(timescape_metrics))
names(timescape_metric_rasters) <- timescape_metrics

timescape_metric_timings <- data.frame(
  metric = timescape_metrics,
  elapsed_seconds = NA_real_,
  elapsed_minutes = NA_real_
)

# Loop through metrics, calculate each one, and record the time taken
for (i in seq_along(timescape_metrics)) {
  metric_name <- timescape_metrics[i]
  metric_start <- Sys.time()

  timescape_metric_rasters[[metric_name]] <- ts_raster_metric(
    binary_stack,
    metric = metric_name
  )

  elapsed_seconds <- round(
    as.numeric(difftime(Sys.time(), metric_start, units = "secs")),
    2
  )

  timescape_metric_timings$elapsed_seconds[i] <- elapsed_seconds
  timescape_metric_timings$elapsed_minutes[i] <- round(elapsed_seconds / 60, 2)

  message(
    "Calculated ",
    metric_name,
    " in ",
    elapsed_seconds,
    " seconds"
  )
}

dir.create("outputs", showWarnings = FALSE, recursive = TRUE)
write.csv(
  timescape_metric_timings,
  "outputs/timescape_metric_timings.csv",
  row.names = FALSE
)

print(timescape_metric_timings)
