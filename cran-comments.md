## Submission preparation

This package is being prepared for its first CRAN submission. It has not been
submitted as part of this work.

## Local checks (2026-10-28)

Environment: macOS (Darwin 25.3.0, arm64), R 4.5.2, terra 1.9.50.

- `devtools::document()`: completed successfully.
- `devtools::test()`: 154 passed, 0 failures, 0 warnings, 0 skips.
- `source("validation/run_validation.R")`, after `devtools::load_all()`:
  all 20 hand-calculated vector/raster checks passed against this checkout.
- `R CMD build .`: passed, including the vignette. Pandoc was found in the
  RStudio application bundle; no installation was needed.
- `R CMD check --as-cran timescapes_0.1.0.tar.gz`: completed from the
  maintainer collaborator's internet-connected Terminal on macOS Tahoe 26.3.1,
  R 4.5.2 (aarch64), with TinyTeX, HTML Tidy 5.8.0, and RStudio-bundled Pandoc.
  The saved check log was inspected: 0 ERRORs, 0 WARNINGs, 1 NOTE.
  All remaining checks, including PDF/HTML manuals, examples, package tests,
  and vignette rebuilding, reported OK.

The sole note is:

```text
Maintainer: 'Logan Hysen <hysenlog@msu.edu>'

New submission
```

This identifies the package as a new submission. The earlier local tooling
and network limitations were resolved for this check.

## Before submission

Obtain checks on Windows, Linux, and R-devel; those results are not yet
verified for these changes. Review all findings and record final results.
Logan should review the final branch, maintainer metadata, citation details,
and source archive before submission. No CRAN submission has been made as
part of this work.

## Downstream dependencies

Downstream dependency status must be verified by the maintainer before
submission.
