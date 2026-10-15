# Validating `timescapes`

A **timescape** is a sequence of observations through time: `1` means a condition is present and
`0` means absent. For a raster, each cell has its own sequence across the
raster's ordered layers. Cells are summarized independently.

This validation script uses **one fixed vector** and **one fixed 2×2 raster with eight time layers**. Each metric
call, hand-calculated answer, and comparison is in its own block. 

## Run

From the repository root, install this checkout and run:

```sh
R CMD INSTALL .
Rscript validation/run_validation.R
```

The script stops at the first mismatch and prints `PASS` after each successful
check. To inspect the raster visually in an interactive R session:

```r
source("validation/run_validation.R")
plot(r)              # Eight 2×2 input layers
plot(n_periods_map)
```

## Vector: all ten metrics

The testing vector is `c(0, 1, 1, 1, 0, 1, 0, 0)`. Its presence runs have lengths
`3, 1`; its absence runs have lengths `1, 1, 2`. Leading and trailing absence
runs count as gaps. The script compares each of these hand-calculated answers
with a separate call to `ts_metric()`:

| Metric | Expected | Reason |
| --- | ---: | --- |
| `total_time` | `4` | Four ones. |
| `n_periods` | `2` | Runs `111` and `1`. |
| `gap_mean` | `4/3` | Mean of `1, 1, 2`. |
| `gap_max` | `2` | Longest zero run. |
| `duration_sd` | `sqrt(2)` | Sample SD of `3, 1`. |
| `edge_density` | `4/7` | Four changes among seven adjacent pairs. |
| `autocorr` | `-1/6` | Pearson correlation of the two lagged seven-step vectors. Each has four ones; two positions have ones in both. |
| `aggregation` | `3/7` | Three equal adjacent pairs among seven. |
| `core_time_index`, buffer `1` | `1/4` | Run `111` retains one of four present steps after trimming both ends. |
| `n_core_periods`, buffer `1` | `1` | Only run `111` is longer than twice the buffer. |

For `autocorr`, the binary Pearson-correlation calculation is
`(7×2 - 4×4) / sqrt((4×3)(4×3)) = -1/6`.

## Raster: five representative metrics

The 2×2 raster has eight time layers. Each pixel has a different history:

| Pixel | Cell history | Meaning |
| --- | --- | --- |
| Top left | `0 1 1 1 0 1 0 0` | The vector we have been using above. |
| Top right | `1 1 1 1 1 1 1 1` | Always present. |
| Bottom left | `0 0 0 0 0 0 0 0` | Always absent. |
| Bottom right | `1 1 NA 1 0 1 0 0` | One unknown step; this pixel's output is `NA`. |

The script constructs this raster and checks the full 2×2 result
for `total_time`, `n_periods`, `gap_mean`, `edge_density`, and
`core_time_index` with buffer `2`. The table gives the hand-calculated value
for each pixel in the output map:

| Metric | Top left | Top right | Bottom left | Bottom right |
| --- | ---: | ---: | ---: | ---: |
| `total_time` | `4` | `8` | `0` | `NA` |
| `n_periods` | `2` | `1` | `0` | `NA` |
| `gap_mean` | `4/3` | `0` | `8` | `NA` |
| `edge_density` | `4/7` | `0` | `0` | `NA` |
| `core_time_index`, buffer `2` | `0` | `1/2` | `0` | `NA` |

The script also checks that the first result is a one-layer, 2×2
`terra::SpatRaster`. More edge cases and expected errors belong in the package's
`tests/testthat/` suite, which you can feel free to explore. All these tests pass on my machine.

Please independently check the math in the function calculations (in the `R/` directory) against each equation in Wan, 2025 (Table 1) 
and review the implementation for clearer organization or easy-to-make performance improvements. The package vignette provides a separate
user-facing walkthrough: `vignette("getting-started", package = "timescapes")`.
