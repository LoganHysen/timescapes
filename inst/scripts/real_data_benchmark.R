# Script Goal: Benchmark Timescape metric calculation on real data
# from the Bear River Migratory Bird Refuge.

devtools::load_all()

library(terra)
library(sf)
library(dplyr)

# Load the Bear River Refuge shapefile, obtained from FWS GIS data: https://gis-fws.opendata.arcgis.com/datasets/fws::fws-national-realty-tracts-simplified/explore?location=41.445128%2C-112.150497%2C10
bear_river <- st_read("C:/Users/logan/active/test_timescape_project/data/FWSInterest_Simplified_Authoritative/FWSInterest_Simplified.shp") %>%
    filter(ORGNAME == "BEAR RIVER MIGRATORY BIRD REFUGE") %>%
    st_transform("EPSG:26912")

# Load and clip the Dynamic World land cover data for the Bear River Refuge
dynamic_world_dir <- "G:/My Drive/timescape_GSLdata"
bear_river_buffer_m <- 3000

dynamic_world_files <- list.files(
  dynamic_world_dir,
  pattern = "\\.tiff?$",
  full.names = TRUE,
  recursive = TRUE,
  ignore.case = TRUE
) %>%
  sort()

if (length(dynamic_world_files) == 0) {
  stop("No TIFF files found in: ", dynamic_world_dir)
}

# Buffer in a meter-based CRS, then convert the buffered bounding box to each
# raster CRS before cropping.
bear_river_bbox <- bear_river %>%
  st_transform(26912) %>%
  st_buffer(bear_river_buffer_m) %>%
  st_bbox() %>%
  st_as_sfc()

clipped_dynamic_world <- vector("list", length(dynamic_world_files))

for (i in seq_along(dynamic_world_files)) {
  raster_file <- dynamic_world_files[i]
  clip_start <- Sys.time()

  dynamic_world_raster <- rast(raster_file)
  crop_bbox <- bear_river_bbox %>%
    st_transform(crs(dynamic_world_raster)) %>%
    vect()

  clipped_dynamic_world[[i]] <- crop(dynamic_world_raster, crop_bbox)

  clip_seconds <- round(
    as.numeric(difftime(Sys.time(), clip_start, units = "secs")),
    2
  )

  message(
    "Clipped ",
    basename(raster_file),
    " in ",
    clip_seconds,
    " seconds"
  )
}

dynamic_world_stack <- do.call(c, clipped_dynamic_world)
names(dynamic_world_stack) <- tools::file_path_sans_ext(
  basename(dynamic_world_files)
)

# Clip the Bear River raster stack to the upper-left 500 rows by 500 columns.
crop_nrows <- 1000
crop_ncols <- 1000

if (nrow(dynamic_world_stack) < crop_nrows || ncol(dynamic_world_stack) < crop_ncols) {
  stop(
    "Cannot crop to ",
    crop_nrows,
    " rows by ",
    crop_ncols,
    " columns because the stack is only ",
    nrow(dynamic_world_stack),
    " rows by ",
    ncol(dynamic_world_stack),
    " columns."
  )
}

crop_res <- res(dynamic_world_stack)
crop_extent <- ext(
  xFromCol(dynamic_world_stack, 1) - crop_res[1] / 2,
  xFromCol(dynamic_world_stack, crop_ncols) + crop_res[1] / 2,
  yFromRow(dynamic_world_stack, crop_nrows) - crop_res[2] / 2,
  yFromRow(dynamic_world_stack, 1) + crop_res[2] / 2
)

dynamic_world_stack_1000 <- crop(dynamic_world_stack, crop_extent)

threshold <- 0.5
binary_stack <- ifel(dynamic_world_stack_1000 >= threshold, 1, 0)

# Calculate all Timescape metrics for the Bear River Refuge
timescape_metrics <- c(
  "total_time",
  "n_periods",
  "gap_mean",
  "gap_max",
  "duration_sd",
  "edge_density",
  "autocorr",
  "aggregation",
  "core_time_index",
  "n_core_periods"
)

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






# Single metric tests

ts_tt <- ts_raster_metric(binary_stack, metric = "total_time")

start <- Sys.time()
ts_np <- ts_raster_metric(binary_stack, metric = "n_periods")
end <- Sys.time()
elapsed_seconds <- round(as.numeric(difftime(end, start, units = "secs")), 2)
message("Calculated n_periods in ", elapsed_seconds, " seconds")