.ts_invalid_binary <- function(x) {
  if (!is.numeric(x)) return(TRUE)

  x_non_na <- x[!is.na(x)]
  any(!(x_non_na %in% c(0, 1)))
}

.ts_run_lengths <- function(x, value) {
  x <- as.integer(x)
  is_value <- !is.na(x) & x == value

  changes <- diff(c(FALSE, is_value, FALSE))
  starts <- which(changes == 1L)
  ends <- which(changes == -1L) - 1L

  as.integer(ends - starts + 1L)
}

get_runs <- function(x) {
  x <- as.integer(x)

  if (length(x) == 0) {
    return(list(one_runs = NULL, gap_runs = NULL))
  }

  runs <- rle(x)
  ends <- cumsum(runs$lengths)
  starts <- ends - runs$lengths + 1L

  run_df <- data.frame(
    value = runs$values,
    start = starts,
    end = ends
  )

  one_runs <- run_df[!is.na(run_df$value) & run_df$value == 1L, c("start", "end")]
  gap_runs <- run_df[!is.na(run_df$value) & run_df$value == 0L, c("start", "end")]

  list(
    one_runs = if (nrow(one_runs) == 0) NULL else one_runs,
    gap_runs = if (nrow(gap_runs) == 0) NULL else gap_runs
  )
}

lag1_autocorr <- function(x) {
  x <- as.integer(x)

  if (length(x) < 2) return(0)

  stats::cor(x[-length(x)], x[-1], use = "complete.obs")
}
