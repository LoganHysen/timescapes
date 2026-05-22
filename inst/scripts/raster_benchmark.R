library(terra)
library(timescapemetrics)

# Simple raster benchmark for all timescape metrics.
# Increase `sizes`, `nt`, or `n_reps` if you want a longer run or to test larger rasters.

set.seed(1)

sizes <- c(50, 100, 200)
nt <- 20
n_reps <- 3
metrics <- ts_list_metrics()

make_binary_raster <- function(n, nt) {
  r <- rast(nrows = n, ncols = n, nlyrs = nt)
  values(r) <- sample(c(0L, 1L), ncell(r) * nt, replace = TRUE)
  r
}

time_metric <- function(r, metric, n_reps) {
  times <- numeric(n_reps)

  for (rep in seq_len(n_reps)) {
    gc()
    elapsed <- system.time({
      result <- ts_raster_metric(r, metric)
      invisible(result)
    })[["elapsed"]]

    times[[rep]] <- elapsed
  }

  times
}

benchmark_one_size <- function(n, nt, metrics, n_reps) {
  message("Benchmarking ", n, " x ", n, " cells, ", nt, " layers")
  r <- make_binary_raster(n, nt)

  do.call(rbind, lapply(metrics, function(metric) {
    message("  ", metric)
    times <- time_metric(r, metric, n_reps)

    data.frame(
      nrow = n,
      ncol = n,
      ncell = ncell(r),
      nlyr = nt,
      metric = metric,
      rep = seq_along(times),
      elapsed_sec = as.numeric(times),
      stringsAsFactors = FALSE
    )
  }))
}

benchmark_results <- do.call(rbind, lapply(sizes, function(n) {
  benchmark_one_size(n, nt, metrics, n_reps)
}))

summary_results <- aggregate(
  elapsed_sec ~ nrow + ncol + ncell + nlyr + metric,
  data = benchmark_results,
  FUN = function(x) c(mean = mean(x), median = median(x), min = min(x), max = max(x))
)

summary_results <- do.call(data.frame, summary_results)
names(summary_results)[names(summary_results) == "elapsed_sec.mean"] <- "mean_sec"
names(summary_results)[names(summary_results) == "elapsed_sec.median"] <- "median_sec"
names(summary_results)[names(summary_results) == "elapsed_sec.min"] <- "min_sec"
names(summary_results)[names(summary_results) == "elapsed_sec.max"] <- "max_sec"

summary_results <- summary_results[order(summary_results$ncell, summary_results$metric), ]

print(summary_results, row.names = FALSE)

# Uncomment to save detailed per-replicate timings.
# write.csv(benchmark_results, "inst/scripts/raster_benchmark_results.csv", row.names = FALSE)
