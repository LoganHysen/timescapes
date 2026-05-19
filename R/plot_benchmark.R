#' Plot benchmark timelines
#' @export
plot_ts_benchmark <- function() {

  sims <- ts_benchmark()

  n <- length(sims)
  offsets <- rev(seq(0, by = 1.5, length.out = n))

  cols <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2")

  plot(
    NULL,
    xlim = c(1, length(sims[[1]])),
    ylim = c(min(offsets) - 0.5, max(offsets) + 1),
    xlab = "Time",
    ylab = "",
    yaxt = "n",
    main = "Temporal habitat scenarios"
  )

  i <- 1
  for (name in names(sims)) {

    x <- sims[[name]]
    y <- x + offsets[i]

    lines(seq_along(x), y, type = "s", lwd = 2, col = cols[i])

    i <- i + 1
  }

  axis(
    2,
    at = offsets,
    labels = names(sims),
    las = 1,
    tick = FALSE
  )

  abline(v = seq(0, length(sims[[1]]), by = 20), col = "grey80", lty = 3)
}


#' Prepare benchmark metrics for plotting
prepare_ts_metrics_long <- function() {
  
  library(tidyr)
  library(dplyr)
  
  df <- ts_benchmark_metrics()
  
  df_long <- df %>%
    pivot_longer(
      cols = -scenario,
      names_to = "metric",
      values_to = "value"
    )
  
  df_long
}

#' Plot metric response across scenarios
#' @export
plot_ts_metric_response <- function() {
  
  library(ggplot2)
  library(dplyr)
  
  df_long <- prepare_ts_metrics_long()
  
  ggplot(df_long, aes(x = scenario, y = value, fill = scenario)) +
    geom_col(show.legend = FALSE) +
    facet_wrap(~metric, scales = "free_y") +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      strip.text = element_text(size = 10, face = "bold")
    ) +
    labs(
      title = "Metric responses to temporal habitat structure",
      x = "Scenario",
      y = "Value"
    )
}