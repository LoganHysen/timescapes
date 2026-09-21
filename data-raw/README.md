# Bear River reference data

The files under `bear-river-reference/` are retained for research reference but
are excluded from package builds. They must not be moved back into `data/` or
distributed with a CRAN release until every item below is completed.

## Provenance placeholder

- TODO: identify the authoritative source, product name, version, acquisition
  date, spatial and temporal coverage, and original download URL for every
  input used to create `gsl_bear_river_water.rda`.
- TODO: identify the exact U.S. Fish and Wildlife Service boundary product,
  version, acquisition date, feature identifier, and download URL used to
  create `gsl_bear_river_refuge.rda`.
- TODO: record all spatial reference systems, resampling choices, temporal
  aggregation choices, thresholds, crops, masks, and other transformations.

## Redistribution-rights placeholder

- TODO: record the license or public-domain status for every source dataset.
- TODO: retain a copy or stable URL for the applicable terms.
- TODO: confirm that redistribution of transformed subsets inside an MIT-
  licensed R package and through CRAN is permitted.
- TODO: add required attribution and citation text to package documentation.

## Reproducible-generation placeholder

- TODO: add a script that starts from documented source files and recreates
  both `.rda` files without manual steps.
- TODO: pin source versions or checksums and all transformation parameters.
- TODO: validate object classes, dimensions, layer order, binary values,
  coordinate reference systems, extents, and compressed file sizes.
- TODO: add instructions for running the script and reviewing its outputs.

After these requirements are satisfied, decide whether the data materially
improve the package enough to justify including and maintaining them.
