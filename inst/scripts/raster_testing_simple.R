library(terra)
library(timescapemetrics)

# dimensions
nrow <- 100
ncol <- 100
nt   <- 20

# create raster stack
r <- rast(nrows = nrow, ncols = ncol, nlyrs = nt)

# random binary habitat
values(r) <- sample(c(0,1), ncell(r) * nt, replace = TRUE)

r

frag_map <- ts_raster_metric(r, "n_periods")


x <- values(r)[1, ]   # first pixel
x
ts_metric(x, "n_periods")

values(frag_map)[1]


set.seed(1)
idx <- sample(1:ncell(r), 5)

for (i in idx) {
  x <- values(r)[i, ]
  expected <- ts_metric(x, "n_periods")
  observed <- values(frag_map)[i]
  
  print(c(expected, observed))
}

system.time({
  frag_map <- ts_raster_metric(r, "n_periods")
})

edge_map <- ts_raster_metric(r, "edge_density")

plot(edge_map)

# fake land cover (values 1–3)
values(r) <- sample(1:3, ncell(r) * nt, replace = TRUE)

forest_map <- ts_raster_metric(r, "n_periods", classes = 1)

plot(forest_map)
forest_map

r_big <- rast(nrows = 200, ncols = 200, nlyrs = 30)

values(r_big) <- sample(c(0,1), ncell(r_big) * 30, replace = TRUE)

system.time({
  ts_raster_metric(r_big, "n_periods")
})
