if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

# R packages ----

## CI/CD packages ----
pkg_cicd = c(
  'remotes'
  , 'rcmdcheck'
  , 'tinytest'
)

## geospatial packages ----
pkg_spatial = c(
  "elevatr"
  , "gdalcubes"
  , "lwgeom"
  , "mapview"
  , "ncdf4"
  , "openeo"
  , "raster"
  , "rgdal"
  , "rstac"
  , "s2"
  , "satellite"
  , "sf"
  , "sp"
  , "stars"
  , "starsExtra"
  , "terra"
  , "units"
  , "whitebox"
)

# System requirements ----

sysreqs_spatial = lapply(
  pkg_spatial
  , \(i) remotes::system_requirements(os = "ubuntu-20.04", package = i)
)

sysreqs_spatial = sysreqs_spatial |>
  lapply(
    gsub, pattern = "apt-get install -y ", replacement = ""
  ) |>
  unlist() |>
  unique() |>
  sort()

# Installation commands ----

cat(
  "apt-get -qq update \\\n "
  , "&&"
  , "apt-get -y --no-install-recommends install \\\n "
  , paste(sysreqs_spatial, collapse = " \\\n  ")
)

cat(
  "install2.r --error --skipinstalled -n $NCPUS \\\n "
  , paste(pkg_cicd, collapse = " \\\n  ")
)

cat(
  "install2.r --error --skipinstalled -n $NCPUS -r https://cran.rstudio.com \\\n "
  , paste(pkg_spatial, collapse = " \\\n  ")
)
