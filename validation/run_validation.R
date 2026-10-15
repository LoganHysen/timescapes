# Run from the repository root after R CMD INSTALL .:
# Rscript validation/run_validation.R
# All inputs and expected answers are written out below in comments

library(terra)
library(timescapes)

# One location over eight time steps. Presence runs: 3, 1.
# Absence runs (including the ends): 1, 1, 2.
x <- c(0, 1, 1, 1, 0, 1, 0, 0)

# Four present time steps.
actual <- ts_metric(x, "total_time")
expected <- 4
stopifnot(actual == expected)
cat("PASS vector: total_time\n")

# Two separate presence runs: 111 and 1.
actual <- ts_metric(x, "n_periods")
expected <- 2
stopifnot(actual == expected)
cat("PASS vector: n_periods\n")

# Three absence runs have lengths 1, 1, and 2.
actual <- ts_metric(x, "gap_mean")
expected <- (1 + 1 + 2) / 3
stopifnot(isTRUE(all.equal(actual, expected, tolerance = 1e-12)))
cat("PASS vector: gap_mean\n")

# The longest absence run is the final 00.
actual <- ts_metric(x, "gap_max")
expected <- 2
stopifnot(actual == expected)
cat("PASS vector: gap_max\n")

# Sample SD of presence-run lengths 3 and 1: sqrt(((3-2)^2 + (1-2)^2) / 1).
actual <- ts_metric(x, "duration_sd")
expected <- sqrt(2)
stopifnot(isTRUE(all.equal(actual, expected, tolerance = 1e-12)))
cat("PASS vector: duration_sd\n")

# Four changes among seven adjacent pairs.
actual <- ts_metric(x, "edge_density")
expected <- 4 / 7
stopifnot(isTRUE(all.equal(actual, expected, tolerance = 1e-12)))
cat("PASS vector: edge_density\n")

# The two lagged 7-step vectors each contain four 1s; two positions have 1 in
# both. Binary Pearson correlation = (7*2 - 4*4) / (4*3) = -1/6.
actual <- ts_metric(x, "autocorr")
expected <- -1 / 6
stopifnot(isTRUE(all.equal(actual, expected, tolerance = 1e-12)))
cat("PASS vector: autocorr\n")

# Three equal-state pairs among seven adjacent pairs.
actual <- ts_metric(x, "aggregation")
expected <- 3 / 7
stopifnot(isTRUE(all.equal(actual, expected, tolerance = 1e-12)))
cat("PASS vector: aggregation\n")

# With one step removed from each end, run 111 retains one of four present steps.
actual <- ts_metric(x, "core_time_index", core_buffer = 1)
expected <- 1 / 4
stopifnot(isTRUE(all.equal(actual, expected, tolerance = 1e-12)))
cat("PASS vector: core_time_index\n")

# Only run 111 is longer than twice the one-step buffer.
actual <- ts_metric(x, "n_core_periods", core_buffer = 1)
expected <- 1
stopifnot(actual == expected)
cat("PASS vector: n_core_periods\n")

# One 2 x 2 raster with eight ordered time layers. Each of its four pixels has
# a different history, listed in row-major order:
# top left: x; top right: always present;
# bottom left: always absent; bottom right: one missing time step.
always_present <- c(1, 1, 1, 1, 1, 1, 1, 1)
always_absent <- c(0, 0, 0, 0, 0, 0, 0, 0)
has_missing <- c(1, 1, NA, 1, 0, 1, 0, 0)

r <- rast(nrows = 2, ncols = 2, nlyrs = 8)
values(r) <- rbind(
  x,
  always_present,
  always_absent,
  has_missing
)
stopifnot(nrow(r) == 2, ncol(r) == 2, nlyr(r) == 8)

# Cell totals: top row 4, 8; bottom row 0, NA.
# Any missing step returns an NA for that pixel.
total_time_map <- ts_raster_metric(r, "total_time")
expected <- rbind(
  c(4, 8),
  c(0, NA)
)
actual <- matrix(values(total_time_map)[, 1], nrow = 2, byrow = TRUE)
stopifnot(inherits(total_time_map, "SpatRaster"),
          nrow(total_time_map) == 2, ncol(total_time_map) == 2,
          nlyr(total_time_map) == 1,
          isTRUE(all.equal(actual, expected, tolerance = 1e-12)))
cat("PASS raster: total_time and output dimensions\n")

# Period counts: top row 2, 1; bottom row 0, NA.
n_periods_map <- ts_raster_metric(r, "n_periods")
expected <- rbind(
  c(2, 1),
  c(0, NA)
)
actual <- matrix(values(n_periods_map)[, 1], nrow = 2, byrow = TRUE)
stopifnot(isTRUE(all.equal(actual, expected, tolerance = 1e-12)))
cat("PASS raster: n_periods\n")

# Gap means: top row (1+1+2)/3, 0; bottom row 8, NA.
gap_mean_map <- ts_raster_metric(r, "gap_mean")
expected <- rbind(
  c(4 / 3, 0),
  c(8, NA)
)
actual <- matrix(values(gap_mean_map)[, 1], nrow = 2, byrow = TRUE)
stopifnot(isTRUE(all.equal(actual, expected, tolerance = 1e-12)))
cat("PASS raster: gap_mean\n")

# Transition proportions: top row 4/7, 0; bottom row 0, NA.
edge_density_map <- ts_raster_metric(r, "edge_density")
expected <- rbind(
  c(4 / 7, 0),
  c(0, NA)
)
actual <- matrix(values(edge_density_map)[, 1], nrow = 2, byrow = TRUE)
stopifnot(isTRUE(all.equal(actual, expected, tolerance = 1e-12)))
cat("PASS raster: edge_density\n")

# With buffer 2, runs 3 and 1 are zero; run 8 retains 4/8 steps.
core_time_map <- ts_raster_metric(r, "core_time_index", core_buffer = 2)
expected <- rbind(
  c(0, 1 / 2),
  c(0, NA)
)
actual <- matrix(values(core_time_map)[, 1], nrow = 2, byrow = TRUE)
stopifnot(isTRUE(all.equal(actual, expected, tolerance = 1e-12)))
cat("PASS raster: core_time_index with core_buffer = 2\n")

# Optional visual inspection in an interactive R session:
# plot(r)             # Eight 2 x 2 input layers
# plot(n_periods_map)

cat("All 15 validation checks passed.\n")
