library(terra)
library(timescapemetrics)

# Simple raster benchmark for all timescape metrics.
# Adjust these values for longer runs or larger rasters.

set.seed(1)

raster_sizes <- c(50L, 100L, 200L)
n_times <- 20L
n_reps <- 3L
metrics <- ts_list_metrics()

make_binary_raster <- function(size, n_times) {
  r <- rast(nrows = size, ncols = size, nlyrs = n_times)
  values(r) <- sample(c(0L, 1L), ncell(r) * n_times, replace = TRUE)
  names(r) <- paste0("t", seq_len(n_times))
  r
}

time_metric <- function(r, metric, n_reps) {
  vapply(seq_len(n_reps), function(rep) {
    gc()
    system.time({
      invisible(ts_raster_metric(r, metric))
    })[["elapsed"]]
  }, numeric(1))
}

benchmark_one_size <- function(size, n_times, metrics, n_reps) {
  message("Benchmarking ", size, " x ", size, " cells, ", n_times, " layers")
  r <- make_binary_raster(size, n_times)

  metric_results <- lapply(metrics, function(metric) {
    message("  ", metric)
    elapsed <- time_metric(r, metric, n_reps)

    data.frame(
      nrow = size,
      ncol = size,
      ncell = ncell(r),
      nlyr = n_times,
      metric = metric,
      rep = seq_along(elapsed),
      elapsed_sec = as.numeric(elapsed),
      row.names = NULL
    )
  })

  do.call(rbind, metric_results)
}

summarize_results <- function(results) {
  summary <- aggregate(
    elapsed_sec ~ nrow + ncol + ncell + nlyr + metric,
    data = results,
    FUN = function(x) {
      c(mean = mean(x), median = median(x), min = min(x), max = max(x))
    }
  )

  summary <- do.call(data.frame, summary)
  names(summary)[names(summary) == "elapsed_sec.mean"] <- "mean_sec"
  names(summary)[names(summary) == "elapsed_sec.median"] <- "median_sec"
  names(summary)[names(summary) == "elapsed_sec.min"] <- "min_sec"
  names(summary)[names(summary) == "elapsed_sec.max"] <- "max_sec"

  summary[order(summary$ncell, summary$metric), ]
}

benchmark_results <- do.call(rbind, lapply(raster_sizes, function(size) {
  benchmark_one_size(size, n_times, metrics, n_reps)
}))

summary_results <- summarize_results(benchmark_results)
print(summary_results, row.names = FALSE)

# Uncomment to save detailed per-replicate timings.
# write.csv(benchmark_results, "inst/scripts/raster_benchmark_results.csv", row.names = FALSE)
