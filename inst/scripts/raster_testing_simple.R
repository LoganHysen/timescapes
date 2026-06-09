library(terra)
library(timescapemetrics)

# Reproducible checks for raster metrics.

set.seed(1)

n_rows <- 100L
n_cols <- 100L
n_times <- 20L

make_binary_raster <- function(n_rows, n_cols, n_times) {
  r <- rast(nrows = n_rows, ncols = n_cols, nlyrs = n_times)
  values(r) <- sample(c(0L, 1L), ncell(r) * n_times, replace = TRUE)
  names(r) <- paste0("t", seq_len(n_times))
  r
}

check_cells <- function(r, result, metric, cells) {
  r_values <- values(r)
  result_values <- values(result)

  checks <- lapply(cells, function(cell) {
    x <- r_values[cell, ]

    data.frame(
      cell = cell,
      expected = as.numeric(ts_metric(x, metric)),
      observed = as.numeric(result_values[cell, 1]),
      row.names = NULL
    )
  })

  checks <- do.call(rbind, checks)
  stopifnot(all.equal(checks$expected, checks$observed, check.attributes = FALSE))
  checks
}

message("Creating binary test raster")
r <- make_binary_raster(n_rows, n_cols, n_times)

message("Calculating n_periods")
n_periods_map <- ts_raster_metric(r, "n_periods")

sample_cells <- sample.int(ncell(r), 5L)
n_periods_checks <- check_cells(r, n_periods_map, "n_periods", sample_cells)
print(n_periods_checks, row.names = FALSE)

message("Calculating edge_density")
edge_density_map <- ts_raster_metric(r, "edge_density")

message("Calculating class-specific n_periods")
land_cover <- r
values(land_cover) <- sample(1:3, ncell(land_cover) * n_times, replace = TRUE)
class_1_map <- ts_raster_metric(land_cover, "n_periods", classes = 1L)

message("Timing a larger n_periods run")
r_big <- make_binary_raster(n_rows = 200L, n_cols = 200L, n_times = 30L)
print(system.time({
  invisible(ts_raster_metric(r_big, "n_periods"))
}))

# Uncomment for quick visual inspection.
# plot(n_periods_map)
# plot(edge_density_map)
# plot(class_1_map)
