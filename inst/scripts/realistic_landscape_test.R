library(terra)

set.seed(1)

nrow <- 100
ncol <- 100
nt   <- 10

base <- rast(nrows = nrow, ncols = ncol)
values(base) <- runif(ncell(base))

# smooth → creates patches
base <- focal(base, w = matrix(1,7,7), fun = mean, na.policy = "omit")

# classify into 3 land cover classes
base_class <- classify(
  base,
  matrix(c(
    0,    0.45, 1,
    0.45, 0.55, 2,
    0.55, 1,    3
  ), ncol = 3, byrow = TRUE)
)


r <- rast(nrows = nrow, ncols = ncol, nlyrs = nt)

current <- base

for (t in 1:nt) {
  
  # 1. add small noise (local variation)
  noise <- rast(current)
  values(noise) <- rnorm(ncell(noise), mean = 0, sd = 0.03)
  
  current_vals <- values(current) + values(noise)
  values(current) <- pmin(pmax(current_vals, 0), 1)
  
  # 2. smooth → patch evolution
  current <- focal(current, w = matrix(1,5,5), fun = mean, na.policy = "omit")
  
  # 3. classify into land cover classes
  layer <- classify(
    current,
    matrix(c(
      0,    0.45, 1,
      0.45, 0.55, 2,
      0.55, 1,    3
    ), ncol = 3, byrow = TRUE)
  )
  
  r[[t]] <- layer
}

names(r) <- paste0("t", 1:nt)

cols <- c("purple", "blue", "yellow")

plot(
  r,
  breaks = c(0.5, 1.5, 2.5, 3.5),
  col = cols
)

# Calculate timescape metrics on the simulated raster
# notice we are only doing this for class 1 (the "purple" land cover) to speed things up, but you can do it for all classes if you want
frag_map <- ts_raster_metric(r, "n_periods", classes = 1)

plot(frag_map)


# Verify the metric values
# center-ish
idx1 <- cellFromRowCol(r, 50, 50)

# near edge
idx2 <- cellFromRowCol(r, 50, 70)

x1 <- values(r)[idx1, ]
x2 <- values(r)[idx2, ]

# these should be the same
ts_metric(as.integer(x1 == 1), "n_periods")
values(frag_map)[idx1]

# these should also be the same
ts_metric(as.integer(x2 == 1), "n_periods")
values(frag_map)[idx2]

change_map <- ts_raster_metric(r, "edge_density", classes = 1)
plot(change_map)


# Compare metrics and see how they change through time
metrics <- c(
  "total_time",
  "n_periods",
  "edge_density"
)

# Again, only doing this for class 1
metric_maps <- lapply(metrics, function(m) {
  ts_raster_metric(r, m, classes = 1)
})

names(metric_maps) <- metrics

res_stack <- rast(metric_maps)
names(res_stack) <- metrics
plot(res_stack)

library(dplyr)
library(tidyr)

df <- as.data.frame(res_stack, xy = TRUE, na.rm = TRUE)

df_long <- df_long %>%
  group_by(metric) %>%
  mutate(value_scaled = (value - min(value)) / (max(value) - min(value))) %>%
  ungroup()

library(ggplot2)

ggplot(df_long, aes(x, y, fill = value_scaled)) +
  geom_raster() +
  facet_wrap(~metric) +
  scale_fill_viridis_c(name = "Relative value") +
  coord_equal() +
  theme_minimal() +
  theme(
  panel.grid = element_blank(),
  strip.text = element_text(face = "bold"),
  axis.text = element_blank(),
  axis.ticks = element_blank()
)