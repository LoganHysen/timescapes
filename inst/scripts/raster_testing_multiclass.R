library(terra)
library(timescapemetrics)

# dimensions
nrow <- 100
ncol <- 100
nt   <- 20

r <- rast(nrows = nrow, ncols = ncol, nlyrs = nt)

# initialize empty
values(r) <- NA

# define quadrants
q1 <- 1:(nrow/2)                # top
q2 <- (nrow/2 + 1):nrow         # bottom
p1 <- 1:(ncol/2)                # left
p2 <- (ncol/2 + 1):ncol         # right


# Scenario time series (classes 1, 2, 3)

ts_class1 <- c(rep(1,10), rep(2,10))   # one transition
ts_class2 <- rep(c(1,2), 10)           # highly fragmented
ts_class3 <- rep(1, 20)                # fully constant
ts_class4 <- sample(1:3, 20, replace=TRUE)  # irregular

for (t in 1:nt) {
  
  m <- matrix(NA, nrow = nrow, ncol = ncol)
  
  # top-left: simple transition
  m[q1, p1] <- ts_class1[t]
  
  # top-right: high fragmentation
  m[q1, p2] <- ts_class2[t]
  
  # bottom-left: constant
  m[q2, p1] <- ts_class3[t]
  
  # bottom-right: noisy
  m[q2, p2] <- ts_class4[t]
  
  r[[t]] <- setValues(r[[t]], as.vector(m))
}

names(r) <- paste0("t", 1:nt)


plot(r,
     breaks = c(0.5, 1.5, 2.5, 3.5),
     col = c("purple", "blue", "yellow"))


frag_map <- ts_raster_metric(r, "n_periods", classes = 1)

plot(frag_map)



# pick center of each quadrant
idx_tl <- cellFromRowCol(r, 25, 25)
idx_tr <- cellFromRowCol(r, 25, 75)
idx_bl <- cellFromRowCol(r, 75, 25)
idx_br <- cellFromRowCol(r, 75, 75)

x_tl <- values(r)[idx_tl, ]
x_tr <- values(r)[idx_tr, ]
x_bl <- values(r)[idx_bl, ]
x_br <- values(r)[idx_br, ]

# class = 1
x_tl_bin <- as.integer(x_tl == 1)
x_tr_bin <- as.integer(x_tr == 1)
x_bl_bin <- as.integer(x_bl == 1)
x_br_bin <- as.integer(x_br == 1)

x_tl_bin
x_tr_bin
x_bl_bin
x_br_bin

# manual
ts_metric(x_tl_bin, "n_periods")
ts_metric(x_tr_bin, "n_periods")
ts_metric(x_bl_bin, "n_periods")
ts_metric(x_br_bin, "n_periods")

# raster result
values(frag_map)[idx_tl]
values(frag_map)[idx_tr]
values(frag_map)[idx_bl]
values(frag_map)[idx_br]


check_pixels <- function(r, res, rows, cols, class, metric) {
  
  for (i in seq_along(rows)) {
    
    idx <- cellFromRowCol(r, rows[i], cols[i])
    x <- values(r)[idx, ]
    
    x_bin <- as.integer(x == class)
    
    expected <- ts_metric(x_bin, metric)
    observed <- values(res)[idx]
    
    cat("\nPixel:", idx, "\n")
    print(c(expected = expected, observed = observed))
  }
}

check_pixels(
  r,
  frag_map,
  rows = c(25, 25, 75, 75),
  cols = c(25, 75, 25, 75),
  class = 1,
  metric = "n_periods"
)

# Multi class verification
res_multi <- ts_raster_metric(r, "n_periods", classes = c(1,2,3))

values(res_multi)[idx_tl, ]
values(res_multi)[idx_tr, ]

for (cls in 1:3) {
  x_bin <- as.integer(x_tl == cls)
  print(ts_metric(x_bin, "n_periods"))
}

plot(res_multi)
