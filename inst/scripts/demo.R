
# Example usage of timescape metrics

x <- c(1,1,0,0,1,1,1,0)

# compute all metrics
ts_metrics(x)

# compute specific metric
ts_metric(x, "gap_mean")

# compare scenarios
x1 <- rep(1, 10)
x2 <- rep(c(1,0), 5)

ts_metrics(x1)
ts_metrics(x2)
